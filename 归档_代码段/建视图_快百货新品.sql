-- 新品SKU
ALTER VIEW view_kbp_new_products AS
select sku,boxsku,epp.spu
from erp_product_products epp
where IsMatrix=0  and isdeleted = 0 and ProjectTeam = '快百货' and DevelopLastAuditTime >= date_add( DATE_ADD(current_date(),interval -day(current_date())+1 day) ,interval -2 month) ;


-- 新品SPU
CREATE VIEW view_kbp_new_products_spu AS
select spu
from  (
    select spu ,min(DevelopLastAuditTime) min_DevelopLastAuditTime
    from erp_product_products where IsMatrix=0  and isdeleted = 0 and ProjectTeam = '快百货'  group by spu
    ) t
where min_DevelopLastAuditTime >= date_add( DATE_ADD(current_date(),interval -day(current_date())+1 day) ,interval -2 month) ;



select count(distinct sku) from view_kbp_new_products ;


select count(distinct sku) from ( select sku,boxsku,epp.spu
from erp_product_products epp
where IsMatrix=0  and isdeleted = 0 and ProjectTeam = '快百货' and DevelopLastAuditTime >= date_add( DATE_ADD(current_date(),interval -day(current_date())+1 day) ,interval -2 month) ) t

