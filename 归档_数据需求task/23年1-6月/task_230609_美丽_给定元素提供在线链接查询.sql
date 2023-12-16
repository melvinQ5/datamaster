with 
tb as (
select eppaea.sku as arr 
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '${ele}' 
group by eppaea.sku 

)

,od as (
select sellersku ,shopcode  ,count(distinct PlatOrderNumber) 23���ۼƶ�����
from wt_orderdetails wo 
join tb on tb.arr = wo.product_sku and wo.IsDeleted = 0 and orderstatus != '����' and paytime >= '2023-01-01'
group by sellersku ,shopcode 
)

select * from (
select '${ele}' Ԫ�� ,tb.arr as sku ,ms.code ,ms.NodePathName ,ms.SellUserName ,eaal.sellersku 
	,case when ms.shopstatus = '����' and eaal.listingstatus = 1  then '����' else 'δ����' end ����״̬
	,ifnull(23���ۼƶ�����,0) 23���ۼƶ�����
from erp_amazon_amazon_listing eaal 
join tb on tb.arr = eaal.sku 
left join mysql_store ms on eaal.shopcode = ms.code and department = '��ٻ�' 
left join od on od.sellersku = eaal.SellerSKU and od.shopcode = eaal.ShopCode 
) t 
where ����״̬ ='����'
