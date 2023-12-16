-- ͳ���·� Ԫ������ Ԫ����sku�� ����Ԫ�س���sku�� �����ܳ���sku�� 

with od as ( 
select left(PayTime,7) set_month ,wo.BoxSku  ,wo.Product_Sku as sku 
	, round(sum((TotalGross+RefundAmount)/ExchangeUSD),2) sales   
	, count(distinct boxsku) `����sku��`
from wt_orderdetails wo 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}'
group by left(PayTime ,7) ,wo.BoxSku ,wo.Product_Sku 
)

, res as (
select od.* , tmp.name
from od 
left join 
	(
	select distinct eppaea.sku ,eppea.Name
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id 
	) tmp 
	on od.sku = tmp.sku 
)

select a.set_month `ͳ���·�` , name `Ԫ������`
	, `����Ԫ��Ʒsku��` , `����sku��` , round(`Ԫ�����۶�`) `Ԫ�����۶�` ,round(`���۶�`) `���۶�`
from (
select set_month , name
	,count(distinct case when name is not null then sku end ) `����Ԫ��Ʒsku��`
	,sum( case when name is not null then sales end ) `Ԫ�����۶�`
from res
where name is not null 
group by set_month ,name
) a 
left join 
(
select 
	set_month
	,count(distinct sku) `����sku��`
	,sum(sales) `���۶�`
from res 
group by set_month 
) b on a.set_month = b.set_month