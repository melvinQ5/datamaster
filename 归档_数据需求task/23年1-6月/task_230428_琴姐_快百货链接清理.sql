/*
 * 刊登6个月以上且（2021-2023 asin+站点）未动销在线链接，全部删除
 */


-- , t_test as ( -- 对上一步标记删除链接 去匹配渠道销量月报 , 
-- select eaaossm.SiteCode , eaaossm.asin , BoxDataTime ,SalesNum ,BoxSKU,eaaossm.ShopCode 
-- from t_mark
-- join import_data.erp_amazon_amazon_order_source_sku_mouthreport eaaossm  -- 渠道销量月报表，通过链接月度统计订单数
-- 	on t_mark.site = eaaossm.SiteCode and t_mark.asin = eaaossm.asin
-- where BoxDataTime >= '2021-01-01' 
-- -- group by eaaossm.SiteCode , eaaossm.asin
-- )
-- -- select * from t_test -- 结论：不能用于匹配  渠道销量表中没剔除作废单


-- ----------------------------------------------

-- （琴姐）最新版 增加 ASIN 大于5的逻辑
with 
t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,publicationdate
from erp_amazon_amazon_listing eaal 
join mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department='快百货' 
	and ShopStatus='正常'
	and listingstatus=1  
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
	and publicationdate<'2022-03-01'
)

, t_od as ( -- 订单表  86w 在线链接
select Asin , Site ,count(*) ord_cnt 
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2021-01-01'  and TransactionType='付款' 
group by Asin , Site 
)


, t_od2 as ( -- 订单表 按照ASIN聚合目的是保留更多跨市场同步的链接
select Asin ,count(*) ord_cnt2 
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2021-01-01'  and TransactionType='付款' 
group by Asin having ord_cnt2>5
)


, t_od3 as ( --订单表 按照ASIN聚合目的是保留更多跨市场同步的链接2019年起
select Asin ,count(*) ord_cnt3  
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2019-01-01'  and TransactionType='付款' 
group by Asin having ord_cnt3>10
)
-- select count(1) from t_od 

,t_mark as ( -- 标记删除链接
select  '删除' as mark ,t_list.* 
from t_list 
left join t_od on t_list.site = t_od.site and t_list.asin = t_od.asin
where t_od.ord_cnt is null 
)


,t_mark2 as ( -- 标记删除链接，排除掉跨市场asin有5单的链接
select t_mark.* ,t_od2.ord_cnt2
from t_mark
left join t_od2 on t_mark.asin = t_od2.asin
where t_od2.ord_cnt2 is null 
order by t_od2.ord_cnt2 desc
)



,t_mark3 as ( -- 标记删除链接，排除掉2019年跨市场asin有5单的链接
select t_mark2.* ,t_od3.ord_cnt3
from t_mark2
left join t_od3 on t_mark2.asin = t_od3.asin
where t_od3.ord_cnt3 is  null 
order by t_od3.ord_cnt3 desc

)



select NodePathName ,count(distinct Asin , Site) `标记删除链接数` from t_mark3
group by grouping sets ((),(NodePathName))

