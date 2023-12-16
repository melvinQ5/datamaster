-- 刊登6个月以上且（2021-2023 asin+站点）未动销在线链接，全部删除
-- 不动销链接删除逻辑如下：

-- theDate 等于昨日(有数据那天)

with 
t_mysql_store as (  -- 组织架构临时改变前
select  
	case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,department as department_old
	,code ,ShopStatus ,NodePathName ,AccountCode
-- 	,*
from import_data.mysql_store
)

,t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,publicationdate ,department 
from erp_amazon_amazon_listing eaal 
join t_mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department_old ='快百货' 
	and ShopStatus='正常'
	and listingstatus= 1   
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
	and publicationdate <= date_add('${theDate}',interval - 6 month )  -- 指定日期及以前
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

, t_od3 as ( -- 订单表 按照ASIN聚合目的是保留更多跨市场同步的链接2019年起
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
where t_od3.ord_cnt3 is null
order by t_od3.ord_cnt3 desc
)

-- 统计待删除链接数
select department `部门`
	, '站点合计 'site 
	,count(distinct Asin , Site) `剩余待删除不动销链接数`
	,concat(left(date_add('${theDate}',interval - 6 month ),10),'及以前') `刊登时间范围（刊登6个月以上）`
from t_mark3 
group by department  
union all 
select department `部门`
	,site 
	,count(distinct Asin , Site) `剩余待删除不动销链接数`
	,concat(left(date_add('${theDate}',interval - 6 month ),10),'及以前') `刊登时间范围（刊登6个月以上）`
from t_mark3 
group by department ,site 

