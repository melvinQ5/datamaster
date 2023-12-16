
-- 快百货在线SPU
with
t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp '泉州' then '快百货泉州' when NodePathName regexp '成都' then '快百货成都' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '快百货' and ShopStatus='正常' and listingstatus=1
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
)

,online_spu as (
select spu, group_concat(shopcode) shopcode, group_concat(SellUserName) SellUserName
from (select spu, ShopCode, SellUserName
      from t_list
      group by spu, ShopCode, SellUserName) t
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


-- select p.* from online_spu os join prod p on os.SPU = p.spu  and p.ProductStatus regexp '停产|停售'


SELECT
	t_list.spu as 在线SPU
	,产品状态
	,开发状态
    ,case when 开发状态 ='开发完成' then '普通产品库' when 开发状态 ='开发中' then '产品开发列表' when 开发状态 ='作废' then '不显示' end as erp产品表
    ,tag 放宽类产品标签
	,count(distinct case when dep2='快百货成都' then CompanyCode end ) 快百货成都在线账号数
	,count(distinct case when dep2='快百货泉州' then CompanyCode end ) 快百货泉州在线账号数
	,count(distinct CompanyCode ) 快百货在线账号数
    , CURRENT_DATE() 数据更新日期
from t_list
left join prod on t_list.spu = prod.spu
left join (
        select spu , group_concat(tag ) tag
       from (
            select distinct spu , unique_brand_shop as tag from dep_kbh_product_test where unique_brand_shop ='一标一店品'
            union select distinct spu ,ispotenial as tag from dep_kbh_product_test where ispotenial ='高潜品'
            ) dkpt group by spu
           ) t
    on t_list.spu = t.spu
group by t_list.spu ,产品状态 ,开发状态  ,t_list.department ,tag
order by 快百货在线账号数 desc



