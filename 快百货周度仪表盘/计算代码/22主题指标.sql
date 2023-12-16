

--  万圣节
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
with a as (
select
    round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
    ,round( sum( case when concat(vknp.sku,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_new_theme -- 新品 且 主题
    ,round( sum( case when concat(level.spu,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_level_theme -- 爆旺分层 且 主题
    ,round( sum( case when tag.spu is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_theme -- 主题
    ,count(distinct case when tag.spu is not null then product_spu end ) as od_spu_theme -- 主题
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '万圣节'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '爆|旺' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '付款'
)
,b as (
select
    abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
    ,abs(round(sum( case when  concat(vknp.sku,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_new_theme
    ,abs(round(sum( case when  concat(level.spu,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_level_theme
    ,abs(round(sum( case when tag.spu is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_theme
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=wo.shopcode and ms.department='快百货'
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '万圣节'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '爆|旺' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where wo.IsDeleted = 0 and TransactionType = '退款' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)
,c as (select count(distinct wp.spu) spu_total_theme
    from wt_products wp
    join ( select eppaea.spu
        from import_data.erp_product_product_associated_element_attributes eppaea
        left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
        where eppea.name =  '万圣节'
        group by spu ) tag
    on wp.spu = tag.spu where wp.ProductStatus !=2 )

select '${StartDay}' as 当期第一天 ,'主题当周销售额_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,round(gross_include_refunds_theme - ifnull(refunds_theme,0),2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题新品业绩 ÷ 当周主题业绩
select '${StartDay}' as 当期第一天 ,'主题当周新品业绩占比_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round( ( gross_include_refunds_new_theme - ifnull(refunds_new_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题爆旺款业绩 ÷ 当周主题业绩
select '${StartDay}' as 当期第一天 ,'主题爆旺款销售额占比_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round( ( gross_include_refunds_level_theme - ifnull(refunds_level_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题业绩 ÷ 当周快百货总业绩
select '${StartDay}' as 当期第一天 ,'主题当周销售额占比_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round(  (gross_include_refunds_theme - ifnull(refunds_theme,0))  / (gross_include_refunds - ifnull(refunds,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all
select '${StartDay}' as 当期第一天 ,'主题当周出单SPU数_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,od_spu_theme ,0 ,0 ,'周报' type
from  a,b,c
union all
select '${StartDay}' as 当期第一天 ,'主题当周SPU动销率_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,round( od_spu_theme / spu_total_theme ,4)  ,0 ,0 ,'周报' type
from  a,b,c;



-- 主题当周广告统计
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'主题当周曝光量_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,sum(Exposure) Exposure  ,0 ,0 ,'周报' type
from wt_listing wl
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on wl.shopcode=ms.Code
join ( select eppaea.spu
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name =  '万圣节'
    group by spu ) tag on wl.spu = tag.spu
join AdServing_Amazon ad  on wl.ShopCode=ad.ShopCode and wl.SellerSKU=ad.SellerSKU and wl.ASIN = ad.Asin
where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day);


-- SPU数

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆款SPU数_主题_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when prod_level='爆款' and tag.spu is not null then akpl.spu end) 爆款spu数_主题
     ,0 ,0 ,'周报' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '万圣节'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'旺款SPU数_主题_万圣节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when prod_level='旺款' and tag.spu is not null then akpl.spu end) 爆款spu数_主题
     ,0 ,0 ,'周报' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '万圣节'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

-- -------------------------------------


--  圣诞节
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
with a as (
select
    round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
    ,round( sum( case when concat(vknp.sku,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_new_theme -- 新品 且 主题
    ,round( sum( case when concat(level.spu,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_level_theme -- 爆旺分层 且 主题
    ,round( sum( case when tag.spu is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_theme -- 主题
    ,count(distinct case when tag.spu is not null then product_spu end ) as od_spu_theme -- 主题
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '圣诞节'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '爆|旺' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '付款'
)
,b as (
select
    abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
    ,abs(round(sum( case when  concat(vknp.sku,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_new_theme
    ,abs(round(sum( case when  concat(level.spu,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_level_theme
    ,abs(round(sum( case when tag.spu is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_theme
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=wo.shopcode and ms.department='快百货'
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '圣诞节'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '爆|旺' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where wo.IsDeleted = 0 and TransactionType = '退款' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)
,c as (select count(distinct wp.spu) spu_total_theme
    from wt_products wp
    join ( select eppaea.spu
        from import_data.erp_product_product_associated_element_attributes eppaea
        left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
        where eppea.name =  '圣诞节'
        group by spu ) tag
    on wp.spu = tag.spu where wp.ProductStatus !=2 )

select '${StartDay}' as 当期第一天 ,'主题当周销售额_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,round(gross_include_refunds_theme - ifnull(refunds_theme,0),2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题新品业绩 ÷ 当周主题业绩
select '${StartDay}' as 当期第一天 ,'主题当周新品业绩占比_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round( ( gross_include_refunds_new_theme - ifnull(refunds_new_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题爆旺款业绩 ÷ 当周主题业绩
select '${StartDay}' as 当期第一天 ,'主题爆旺款销售额占比_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round( ( gross_include_refunds_level_theme - ifnull(refunds_level_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all -- 当周主题业绩 ÷ 当周快百货总业绩
select '${StartDay}' as 当期第一天 ,'主题当周销售额占比_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,round(  (gross_include_refunds_theme - ifnull(refunds_theme,0))  / (gross_include_refunds - ifnull(refunds,0))  ,2) 指标值 ,0 ,0 ,'周报' type
from a,b,c
union all
select '${StartDay}' as 当期第一天 ,'主题当周出单SPU数_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,od_spu_theme ,0 ,0 ,'周报' type
from  a,b,c
union all
select '${StartDay}' as 当期第一天 ,'主题当周SPU动销率_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,round( od_spu_theme / spu_total_theme ,4)  ,0 ,0 ,'周报' type
from  a,b,c;



-- 主题当周广告统计
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'主题当周曝光量_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表' ,sum(Exposure) Exposure  ,0 ,0 ,'周报' type
from wt_listing wl
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on wl.shopcode=ms.Code
join ( select eppaea.spu
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name =  '圣诞节'
    group by spu ) tag on wl.spu = tag.spu
join AdServing_Amazon ad  on wl.ShopCode=ad.ShopCode and wl.SellerSKU=ad.SellerSKU and wl.ASIN = ad.Asin
where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day);


-- SPU数

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆款SPU数_主题_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when prod_level='爆款' and tag.spu is not null then akpl.spu end) 爆款spu数_主题
     ,0 ,0 ,'周报' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '圣诞节'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'旺款SPU数_主题_圣诞节' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when prod_level='旺款' and tag.spu is not null then akpl.spu end) 爆款spu数_主题
     ,0 ,0 ,'周报' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '圣诞节'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';