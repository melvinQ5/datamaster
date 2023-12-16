-- ���㹫˾�������۶� �ж�Ԫ��ҵ��ռ��
with 
t_new_prod as ( -- �����ٻ��ܱ���Ʒ������ʱ���ڽ�90���SPU������2023-03-01
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, epp.ProductStatus 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-01-01'  
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='��ٻ�' 
)

,od as (
select left(SettlementTime,7) set_month ,wo.BoxSku ,wo.Product_Sku as sku
	, round(sum((TotalGross)/ExchangeUSD),2) sales
	, round(sum( case when b.spu is not null then (TotalGross)/ExchangeUSD end  )  ,2) new_pp_sales
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
left join wt_products pp on wo.BoxSku=pp.BoxSku and pp.IsDeleted=0
left join t_new_prod b on  wo.Product_SPU = b.spu  
where wo.IsDeleted = 0 and SettlementTime < '${NextStartDay}' and SettlementTime >= '2022-01-01' 
and ms.Department  = '��ٻ�'
group by left(SettlementTime,7) ,wo.BoxSku ,wo.Product_Sku
)

, ele as ( 
select distinct eppaea.sku ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
)

, data_set as (
select od.* , ele.name ,pp.Spu
from od
left join ele on od.sku = ele.sku -- һ���
left join wt_products pp on ele.sku=pp.sku
)
-- ---------
, res1 as (
select set_month , name
	,count( distinct sku ) `����Ԫ��Ʒsku��`
	,sum( sales ) `Ԫ�����۶�`
	,sum( new_pp_sales ) `Ԫ����Ʒ���۶�`
    ,count( SPU ) `����Ԫ��Ʒspu��`
from data_set
where name is not null
group by set_month , name
)

, res2 as (
select  set_month 
	, count( distinct boxsku ) `����sku��`
	, sum( sales ) `�������۶�`
from data_set 
group by set_month 
)

, res3 as ( 
select name ,count(distinct sku) `ERP���sku��`
from ele 
group by name 
)
         
select res1.name `Ԫ������` ,res3. `ERP���sku��` , res1.set_month `ͳ���·�` 
	,`����Ԫ��Ʒsku��` , `����sku��` , ����Ԫ��Ʒspu��
	,round(`Ԫ�����۶�`) `Ԫ��Ʒ���۶�` 
	,round(`Ԫ����Ʒ���۶�`) `23���������Ԫ��Ʒ���۶�` 
	,round(`�������۶�`) `���۶�`
	,round( `Ԫ�����۶�`/`�������۶�`,4) `Ԫ��ҵ��ռ��`
	,round( `Ԫ�����۶�`/`����Ԫ��Ʒspu��`,2 ) `Ԫ��spu����`
	,round( `����Ԫ��Ʒsku��`/`ERP���sku��`,4 ) `����Ԫ��skuռ��`
from res1  
left join res2 on res1.set_month =res2.set_month
left join res3 on res1.name =res3.name
order by `Ԫ������` , `ͳ���·�`