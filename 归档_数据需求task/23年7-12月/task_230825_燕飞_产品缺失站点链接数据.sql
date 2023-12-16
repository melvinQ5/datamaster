/*
产品账号缺失链接数据
站点范围： UK DE FR US CA ES IT MX
账号范围：快百货所有存在店铺状态='正常'的账号
产品范围： 产品元素包含“万圣节、圣诞节” 且 在线链接的站点不全的SPU
字段：元素名称 spu 站点 正常账号 是否有在线链接  asin sellersku
数据量太大，缩小数据量：当在线链接的站点不全的SPU才输出
 */


with
online_lst as ( -- 所有在线链接
select spu ,CompanyCode ,Site ,asin ,SellerSKU
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.ShopCode=ms.Code and ListingStatus=1 and ShopStatus='正常' and Department='快百货'
and IsDeleted=0
)

, unfull_spu as ( -- 在线站点不全的SPU
select spu
from online_lst where site regexp 'UK|DE|FR|US|CA|ES|IT|MX'
group by spu HAVING count(distinct site) <8
)

,ele as ( -- 元素映射表，最小粒度是 SKU+NAME
select spu ,group_concat(Name) ele_name
from (
    select eppaea.spu ,eppea.Name
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name regexp '万圣节|圣诞节'
    group by eppaea.spu ,eppea.Name
    ) t
group by spu
)

, wp as (
select epp.spu ,ele.ele_name  from erp_product_products epp
join ele on epp.SPU=ele.Spu and IsDeleted=0 and IsMatrix=1 and DevelopLastAuditTime is not null and ProjectTeam='快百货'
)

, t_key as (
select wp.* ,ms.CompanyCode from wp
join ( select distinct CompanyCode from mysql_store where Department='快百货' and ShopStatus='正常') ms on 1=1
join unfull_spu usp on wp.spu = usp.spu
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,banneds as (
select wp.spu , GROUP_CONCAT( channelsitecode ) AS banneds_site
from unfull_spu join wt_products wp on unfull_spu.spu = wp.SPU and wp.ProjectTeam='快百货'
join ( SELECT productid,  channelsitecode
    FROM erp_product_product_banneds
    WHERE platformcode = 'Amazon'
    ) pb ON pb.productid = wp.id
group by wp.spu
)




, res as (
select
    t1.spu
    ,t1.ele_name as 产品主题
    ,t2.seller_list as 产品分配销售
    ,t1.CompanyCode as 账号
    ,banneds_site as 账号禁售站点
    ,'是' 是否在线站点不全
    ,case when tuk.asin is not null then 'UK' end as 有UK站
    ,case when tde.asin is not null then 'DE' end as 有DE站
    ,case when tfr.asin is not null then 'FR' end as 有FR站
    ,case when tus.asin is not null then 'US' end as 有US站
    ,case when tca.asin is not null then 'CA' end as 有CA站
    ,case when tes.asin is not null then 'ES' end as 有ES站
    ,case when tit.asin is not null then 'IT' end as 有IT站
    ,case when tmx.asin is not null then 'MX' end as 有MX站

    ,tuk.asin as uk_asin
    ,tde.asin as de_asin
    ,tfr.asin as fr_asin
    ,tus.asin as us_asin
    ,tca.asin as ca_asin
    ,tes.asin as es_asin
    ,tit.asin as it_asin
    ,tmx.asin as mx_asin

    ,tuk.sellersku as uk_渠道sku
    ,tde.sellersku as de_渠道sku
    ,tfr.sellersku as fr_渠道sku
    ,tus.sellersku as us_渠道sku
    ,tca.sellersku as ca_渠道sku
    ,tes.sellersku as es_渠道sku
    ,tit.sellersku as it_渠道sku
    ,tmx.sellersku as mx_渠道sku
from t_key t1
left join prod_seller t2 on t1.SPU = t2.spu
left join banneds t3 on t1.SPU = t3.spu
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'UK' group by spu, CompanyCode ) tuk on t1.SPU = tuk.spu and t1.CompanyCode = tuk.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'DE' group by spu, CompanyCode ) tde on t1.SPU = tde.spu and t1.CompanyCode = tde.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'FR' group by spu, CompanyCode ) tfr on t1.SPU = tfr.spu and t1.CompanyCode = tfr.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'US' group by spu, CompanyCode ) tus on t1.SPU = tus.spu and t1.CompanyCode = tus.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'CA' group by spu, CompanyCode ) tca on t1.SPU = tca.spu and t1.CompanyCode = tca.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'ES' group by spu, CompanyCode ) tes on t1.SPU = tes.spu and t1.CompanyCode = tes.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'IT' group by spu, CompanyCode ) tit on t1.SPU = tit.spu and t1.CompanyCode = tit.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'MX' group by spu, CompanyCode ) tmx on t1.SPU = tmx.spu and t1.CompanyCode = tmx.CompanyCode
)

select * from res
-- select count(*) from res
-- select count(*) from t_key
