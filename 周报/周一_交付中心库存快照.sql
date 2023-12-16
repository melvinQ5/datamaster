select 
	'${NextStartDay}' `ͳ����`
	,a.department `����`
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`),0) `���زֿ���ʽ�ռ��`
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${NextStartDay}','${StartDay}'),1) `�����ת����`
	, concat('${StartDay}','��','${NextStartDay}' ) `��ת����ͳ����`
	,`���������ɹ����`
	,`�ڲ�sku����`,`�ڲ�sku��` 
	,`��;��Ʒ�ɹ����`, `��;��Ʒ�ɹ��˷�` , `�ڲֲ�Ʒ���`
from
(
select case when department is null THEN '��˾' ELSE department END AS department
	, sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����` , ifnull(sum(SkuFreight),0) `��;��Ʒ�ɹ��˷�`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp 
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku 
	where ordertime < '${NextStartDay}'
		and isOnWay = "��" and WarehouseName = '��ݸ��'
	) tmp	
group by grouping sets ((),(department))
) a 

left join (
	SELECT case when department is null THEN '��˾' ELSE department END AS department  
		,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��` 
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '��ݸ��' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (	
	select case when department is null THEN '��˾' ELSE department END AS department 
		, round(sum(pc)) `���������ɹ����` 
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='��ݸ��'
		) a 
	group by grouping sets ((),(department))
) c on a.department = c.department
where `���������ɹ����` is not null 