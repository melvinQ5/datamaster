with 
tb as (
select eppaea.sku as arr 
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '${ele}' 
group by eppaea.sku 

)

,od as (
select sellersku ,shopcode  ,count(distinct PlatOrderNumber) 23年累计订单量
from wt_orderdetails wo 
join tb on tb.arr = wo.product_sku and wo.IsDeleted = 0 and orderstatus != '作废' and paytime >= '2023-01-01'
group by sellersku ,shopcode 
)

select * from (
select '${ele}' 元素 ,tb.arr as sku ,ms.code ,ms.NodePathName ,ms.SellUserName ,eaal.sellersku 
	,case when ms.shopstatus = '正常' and eaal.listingstatus = 1  then '在线' else '未在线' end 在线状态
	,ifnull(23年累计订单量,0) 23年累计订单量
from erp_amazon_amazon_listing eaal 
join tb on tb.arr = eaal.sku 
left join mysql_store ms on eaal.shopcode = ms.code and department = '快百货' 
left join od on od.sellersku = eaal.SellerSKU and od.shopcode = eaal.ShopCode 
) t 
where 在线状态 ='在线'
