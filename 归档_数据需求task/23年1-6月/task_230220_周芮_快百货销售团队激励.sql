
-- with  ele as ( -- Ԫ��ӳ�����С������ SPU+SKU+NAME
-- select eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime
-- from import_data.erp_product_product_associated_element_attributes eppaea 
-- left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
-- left join products on eppaea.sku = products.sku 
-- where products.ismatrix = 0
-- group by eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime
-- )
-- 
-- select 
-- from import_data.erp_product_products epp 
-- where DevelopLastAuditTime  < '2023-02-20' and DevelopLastAuditTime >= '2023-02-13' and ProjectTeam ='��ٻ�'



with products as (
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,spu ,CreationTime ,boxsku
from import_data.erp_product_products
where IsDeleted =0 
)

-- , ele as ( -- Ԫ��ӳ�����С������ SPU+SKU+NAME
select eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join products on eppaea.sku = products.sku 
where products.ismatrix = 0
group by eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime
-- )


-- ͳ������
-- select eppea.name  ,count(distinct  eppaea.sku )
-- from import_data.erp_product_product_associated_element_attributes eppaea 
-- left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
-- group by  eppea.name