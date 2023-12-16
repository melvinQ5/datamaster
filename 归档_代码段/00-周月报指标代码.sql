-- GM转PM  新品GM转PMsku数：来源为逆向 且开发终审时间10/31-11/06 且非删除的sku数

select '所有部门' as department,count(*) as sku_new_r_count from import_data.erp_product_products
where SkuSource = 2
and DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07' and IsDeleted = 0 and IsMatrix = 0


-- 正向开发  PM新品开发sku数：来源为正向 且开发终审时间10/31-11/06 且非删除的sku数

select '所有部门' as department,count(*) as sku_new_count from import_data.erp_product_products
where SkuSource = 1
and DevelopLastAuditTime >= '2022-10-01' and DevelopLastAuditTime < '2022-11-01' and IsDeleted = 0 and IsMatrix = 0

-- 逆向开发SKU数

select '所有部门' as department,count(*) as sku_new_rc_count from import_data.erp_product_products
where SkuSource = 2 and DevelopLastAuditTime is null
and CreationTime >= 'StartDay' and CreationTime < 'EndDay' and IsDeleted = 0 and IsMatrix = 0

-- 产品，庆典

select '所有部门' department, count(*) product_total_sku_count_celebration from import_data.Celi
where ProductStatus <> 2 and  DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07'


-- 园林sku开发数
select '所有部门' department, count(*) product_total_sku_count_park from import_data.Parts
where ProductStatus <> 2 and  DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07'