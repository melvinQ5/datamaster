

with 

-- step1 ����Դ���� 
t_key as ( -- �������ά��
select '��˾' as dep
union select '��ٻ�' 
union
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union
select NodePathName from import_data.mysql_store where department regexp '��' 
)



-- ����ʽ�ռ��
,t_warehouse_stat as (
select a.department as dep 
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/10000,0) `���زֿ���ʽ�ռ��` -- ��Ԫ
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${NextStartDay}','${StartDay}'),1) `�����ת����`
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
) 


-- ���Ϳ��ռ�� 
-- ������ڵ���365��ģ�����100%
-- ����(180,365)��ģ�
-- 	����֧����������365�첿�֣�����100%
-- 	����֧������(180��365]���֣�����50%
-- 	����֧������С��180�첿�֣�����0%
-- ����С�ڵ���180��ģ�����0%
-- ����֧������=�ÿ���Ĵ������/ͳ����ǰ�����¸ò�Ʒ�վ�����

-- ��� InventoryAgeAmount180 + InventoryAgeAmount270 ���ݣ��жϿ�������
, t_slow_moving_inve as (  -- ���Ϳ��
select '��˾' as dep
	,sum(case 
		when InventoryAgeOver>0 then InventoryAgeOver 
		when InventoryAge270*InventoryAge365 > 0 and `��������` > 365 then (InventoryAge270+InventoryAge365)
		when InventoryAge270*InventoryAge365 > 0 and `��������` > 180 and `��������` <=365  then (InventoryAge270+InventoryAge365)*0.5
	end)/10000 `������Ϳ����` -- ��Ԫ
from import_data.daily_WarehouseInventory wi 
left join  
	(
	select wi.boxsku
		, SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver) `����180��������`
		, a.daily90 `��90���վ�����`
		, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily90,0) `��������` 
		, round((SUM(wi.InventoryAgeOver))/a.daily90,0) `����365�첿�ֵĿ�������` 
		, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365))/a.daily90,0) `180��365�Ŀ�������` 
	from import_data.daily_WarehouseInventory wi
	left join 
		( select wo.boxsku
			,round(sum(wo.SaleCount)/90,2) daily90 -- 90���վ�����
		from import_data.wt_orderdetails wo 
		where SettlementTime>=date_add('${StartDay}',interval -2 month) and wo.SettlementTime< '${NextStartDay}'
			and wo.ShipWarehouse='��ݸ��' and isdeleted = 0 
		group by wo.boxsku
		) a 
	on wi.boxsku=a.boxsku
	where CreatedTime = date_add('${NextStartDay}',-1)
	group by wi.boxsku,a.daily90 having `����180��������`>0
	) tmp
	on wi.BoxSku = tmp.BoxSku
where wi.CreatedTime = date_add('${NextStartDay}',-1)
) 

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep `�Ŷ�` 
	,`���زֿ���ʽ�ռ��`
	,`�����ת����`
	,`�ڲ�sku����`
	,`�ڲ�sku��` 
	,`��;��Ʒ�ɹ����`
	,`��;��Ʒ�ɹ��˷�` 
	,`�ڲֲ�Ʒ���`
	,`���������ɹ����`
	,`������Ϳ����`
-- 	,`����Ʒ������`
from t_key
left join t_warehouse_stat on t_key.dep = t_warehouse_stat.dep
left join t_slow_moving_inve on t_key.dep = t_slow_moving_inve.dep
)

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,t_merge.*
	,round(`�ڲ�sku����`/`�ڲ�sku��`,4) `�ڲ�SKUƽ������` 
	,round(`������Ϳ����`/`���زֿ���ʽ�ռ��`,4) `���Ϳ��ռ��` 
from t_merge
order by `�Ŷ�` desc 

