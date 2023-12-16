

-- 快百货在线SPU
with 
t_list as (
select spu, sku,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
, sellersku,shopcode,asin
,ShopStatus as 店铺状态 ,  case when ListingStatus = 1 then '在线' when ListingStatus = 5 then '待删除' end as 链接状态
from erp_amazon_amazon_listing eaal 
join ( select case when NodePathName regexp '泉州' then '快百货泉州' when NodePathName regexp '成都' then '快百货成都' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '快百货'
    and ShopStatus='正常'
    and listingstatus=1
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
)

,online_spu as (
select spu, group_concat(listing_info) listing_info
from (select spu, concat('[渠道SKU:',SellerSKU,'  在线店铺:',shopcode,'  首选业务员:',SellUserName,']') as listing_info
      from t_list
      group by spu, ShopCode, SellUserName ,SellerSKU) t
group by spu
)

,prod as ( -- 存在多个状态
select spu
    ,case when ProductStatus = 0 then '正常'
		when ProductStatus = 2 then '停产'
		when ProductStatus = 3 then '停售'
		when ProductStatus = 4 then '暂时缺货'
		when ProductStatus = 5 then '清仓'
		end as 产品状态
	,case when status = 10 then '开发完成' when status = 20 then '作废' when status =0 then '开发中' end 开发状态
from erp_product_products epp where ismatrix = 1 and IsDeleted = 0 and ProjectTeam = '快百货'
)



,online_stat_by_spu as (
SELECT
	t_list.spu as 在线SPU
	, 产品状态
	, 开发状态
    ,case when 开发状态 ='开发完成' then '普通产品库' when 开发状态 ='开发中' then '产品开发列表' when 开发状态 ='作废' then '不显示' end as erp产品表
	,count(distinct case when dep2='快百货成都' then CompanyCode end ) 快百货成都在线账号数
	,count(distinct case when dep2='快百货泉州' then CompanyCode end ) 快百货泉州在线账号数
	,count(distinct CompanyCode ) 快百货在线账号数
	,count(distinct concat(SellerSKU,ShopCode) ) 快百货在线链接数
    , CURRENT_DATE() 数据更新日期
from t_list
left join prod
 on t_list.spu = prod.spu
group by t_list.spu ,产品状态 ,开发状态
)

,online_stat as (
select
    count( case when 快百货在线账号数 > 6 then 在线SPU end ) as 超6套SPU数
from online_stat_by_spu
)

,dev_stat as (
select
    count(distinct case when 产品状态 not regexp '停产|停售' and 开发状态 = '开发完成' then spu end ) 非停产停售SPU数
from prod
)

, res1_rate as (
select 超6套SPU数 ,非停产停售SPU数 ,round(超6套SPU数/非停产停售SPU数,4) 超6套SPU占比 from dev_stat,online_stat
)

, res2_detail as ( -- 停产停售且在线的SPU
select date(now()) 数据查询日期 ,p.*
     ,快百货在线账号数
     ,快百货成都在线账号数
     ,快百货泉州在线账号数
     ,快百货在线链接数 ,os.listing_info 在线链接详情
from online_spu os
join prod p on os.SPU = p.spu  and p.产品状态 regexp '停产|停售'
left join online_stat_by_spu osbs on os.SPU = osbs.在线SPU
order by 快百货在线链接数
)

-- select * from res1_rate
-- select * from res2_detail

select t_list.spu, ShopCode, SellUserName ,SellerSKU ,NodePathName ,dep2
from t_list
join prod p on t_list.SPU = p.spu  and p.产品状态 regexp '停产|停售'
group by t_list.spu, ShopCode, SellUserName ,SellerSKU ,NodePathName ,dep2
