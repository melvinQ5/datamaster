
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
InventoryOccupied,InventoryTurnover)
select '${StartDay}' ,'${ReportType}' ,a.department ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/10000,0) `����ʽ�ռ��` -- ��Ԫ
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${NextStartDay}','${StartDay}'),1) `�����ת����`
from
(
select department , sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����` , ifnull(sum(SkuFreight),0) `��;��Ʒ�ɹ��˷�`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku
	where ordertime < '${NextStartDay}' and isOnWay = "��" and WarehouseName = '��ݸ��' and department = '��ٻ�'
	) tmp
group by department
) a
left join (
	SELECT department ,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��`
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '��ݸ��' and TotalInventory > 0
		  and CreatedTime = date_add('${NextStartDay}',-1) and department = '��ٻ�'
		)  tmp
	group by department
) b on a.department = b.department
left join (
	select department , round(sum(pc)) `���������ɹ����`
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,ms.department
		from import_data.daily_PackageDetail pd
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.wt_orderdetails od
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0
				and TransactionType ='����' and orderstatus != '����' and totalgross > 0
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='��ݸ��' and ms.department = '��ٻ�'
		) a
	group by department
) c on a.department = c.department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'�ܶ�����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct platordernumber)  ,0 ,0 ,'�ܱ�' type
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >= '${StartDay}' and  PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '����' and orderstatus != '����';