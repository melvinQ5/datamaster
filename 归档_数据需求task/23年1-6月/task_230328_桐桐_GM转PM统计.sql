-- NextStartDay = ÿ��һ
-- 

with 
t_od_last_week as ( -- ���ܳ���SKU
select BoxSku ,count(distinct PlatOrderNumber) as ords_last_week_cnt
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
where IsDeleted = 0 and ms.Department = '������'
	and PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and OrderStatus !='����' and OrderTotalPrice > 0
group by BoxSku having count(distinct PlatOrderNumber) >= 5
)

, t_od as ( -- asin ����
select wo.BoxSku ,asin ,ms.Site 
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `W��`
	,round(sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then TotalGross/ExchangeUSD end ),2) `W�����۶�`
	,round(sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) `W�������`
	,sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then SaleCount end ) `W������`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then TotalGross/ExchangeUSD end ),2) `W-1�����۶�`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then TotalProfit/ExchangeUSD end ),2) `W-1�������`
	,sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then SaleCount end ) `W-1������`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then TotalGross/ExchangeUSD end ),2) `W-2�����۶�`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then TotalProfit/ExchangeUSD end ),2) `W-2�������`
	,sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then SaleCount end ) `W-2������`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
join t_od_last_week on wo.BoxSku = t_od_last_week.BoxSku 
where  PayTime >=date_add('${StartDay}' ,interval -21 day) and PayTime< '${NextStartDay}' 
	and IsDeleted = 0 and ms.Department = '������' and OrderStatus != '����'
group by wo.BoxSku ,asin ,ms.Site 
)

-- select date_add('2023-04-03' ,interval -7 day)

select 
	t_od_last_week.ords_last_week_cnt `W��boxsku������`
	,t_od.*
	,wp.Spu 
	,wp.ProductName
	,case when wp.ProductStatus =  0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
		end as  `��Ʒ״̬`
	,wp.CreationTime `���ʱ��`
	,Site `վ��`
	,PurchaseLink `�ɹ�����`
	,PurchasePrice `�ɹ���`
	,NetWeight `����`
	,GrossWeight `ë��`
	,concat(ProductLong,'x',ProductWidth,'x',ProductHeight) `��Ʒ�����`
	,concat(PackageLong,'x',PackageWidth,'x',PackageHeight) `��װ�����`
	
from t_od
left join wt_products wp on wp.BoxSku = t_od.BoxSku 
left join erp_product_products epp  on epp.id = wp.id   
left join erp_product_product_suppliers epps on epps.ProductId = wp.id  
left join t_od_last_week on t_od.boxsku = t_od_last_week.boxsku 
where t_od.boxsku <> 'ShopFee' and wp.ProductStatus != 2  -- δͣ��

