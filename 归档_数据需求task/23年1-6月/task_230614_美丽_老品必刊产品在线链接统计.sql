-- 表1
select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
    ,kbh_online_code as '快百货在线账号套数'
    ,kbh_cd_online_code  as '快百货成都在线账号套数'
    ,kbh_qz_online_code  as '快百货泉州在线账号套数'
from ( -- 7日前终审非停产产品信息
    select SPU,SKU
    	,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime
    	,ProductName
    	,split(CategoryPathByChineseName, '>')[1] as cat1
    from erp_product_products epp -- 使用实时表,避免宽表调度延误
    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
    where ismatrix = 0 and productstatus != 2  and projectteam = '快百货'
    ) epp
left join ( -- 在线账号数
	select sku ,count(distinct ms.CompanyCode) kbh_online_code
	     ,count(distinct case when nodepathname regexp '成都' then ms.CompanyCode end) kbh_cd_online_code
	     ,count(distinct case when nodepathname regexp '泉州' then ms.CompanyCode end) kbh_qz_online_code
	from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='快百货' and ms.shopstatus = '正常' and eaal.listingstatus = 1
	group by sku
	) eaal on epp.sku = eaal.sku


select distinct  CompanyCode
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='快百货' and ms.shopstatus = '正常' and eaal.listingstatus = 1
and sku = 1024599.01
-- and Code = 'CN'

-- 表2
select cat1 ,CompanyCode ,round(sum(totalgross/exchangeusd)) 3月1日至今销售额
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.ShopStatus = '正常' and ms.department = '快百货' and nodepathname regexp '成都'
join ( select distinct sku ,split(CategoryPathByChineseName, '>')[1] as cat1  from erp_product_products epp  
	left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
	where ismatrix = 0 and productstatus != 2 and projectteam = '快百货'  
	) wp on wp.sku =wo.Product_Sku
where paytime >= '2023-03-01' and wo.isdeleted = 0
group by cat1 ,CompanyCode 

