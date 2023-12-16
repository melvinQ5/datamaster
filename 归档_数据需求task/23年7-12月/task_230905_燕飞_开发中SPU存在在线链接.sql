-- 快百货在线SPU
with
prod as (
select spu ,ProjectTeam 产品当前归属部门
     ,case when IsDeleted = 1 then '删除' when IsDeleted = 0 then '未删除' end ERP是否删除产品
from erp_product_products epp where ismatrix = 1 and
spu in (
    1000616,
5141746,
5291798,
5190659,
5039086,
5131782,
1125989,
1125977,
5101824,
5116889,
5105691,
5097568,
5007080,
1005774,
5133239,
5087298,
5040261,
5216118,
5147050,
5099828,
5159506
  )
)

,t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp '泉州' then '快百货泉州' when NodePathName regexp '成都' then '快百货成都' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '快百货' and ShopStatus='正常' and listingstatus=1
    and eaal.isdeleted=0
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
)



SELECT
	a.sellersku
    ,a.shopcode
    ,a.asin
    ,a.dep2
    ,a.nodepathname
    ,b.*
from prod b left join t_list a
 on a.spu = b.spu

