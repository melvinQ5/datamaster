with
-- step1 数据源处理
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)

,t_mysql_store as (  -- 组织架构临时改变前
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,NodePathName
	,department as department_old
from import_data.mysql_store
)

,t_prod as (
select
	SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,SPU ,CreationTime ,boxSKU ,SKUSource ,DevelopUserName ,Status
from import_data.erp_product_products
where IsDeleted = 0 and IsMatrix = 0
)

,t_list as (
select Id ,ListingStatus ,SKU ,SPU ,MinPublicationDate ,IsDeleted  ,ShopCode ,SellerSKU ,ASIN 
	,ms.*
from wt_listing  eaal  
join t_mysql_store ms on eaal.ShopCode = ms.Code and eaal.IsDeleted = 0 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
,t_list_in7d_over20 as ( -- 销售组每组10条 ,快百货40条
select nodepathname as dep 
	,count( distinct sku ) `上周刊登新品SKU数`
	,round(count(distinct case when list_cnt_in7d >=10 then sku end )/count( distinct sku ),4) as `终审7天刊登达标率`
from (
	select nodepathname ,ta.sku 
		,count(distinct concat(shopcode ,sellersku ,asin) ) list_cnt	
		,count(distinct case when timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate)/86400 < 7 then concat(shopcode ,sellersku ,asin) end ) list_cnt_in7d	
	from ( select SPU ,SKU ,DevelopLastAuditTime 
		from t_prod 
		where DevelopLastAuditTime >= DATE_ADD('${StartDay}',interval - 7 day) and DevelopLastAuditTime <  DATE_ADD('${NextStartDay}',interval - 7 day) and ProjectTeam = '快百货'
		) ta 
	join (select sku ,shopcode ,sellersku ,asin ,MinPublicationDate ,department ,ms.nodepathname
		from wt_listing wl join t_mysql_store ms on wl.ShopCode = ms.Code where department_old = '快百货' and isdeleted = 0 
		) tb on ta.SKU = tb.SKU
	group by nodepathname ,ta.sku 
	) t
group by nodepathname
union 
select dep 
	,count( distinct sku ) `上周刊登新品SKU数`
	,round(count( distinct case when list_cnt_in7d >=40 then sku end )/count( distinct sku ),4) as `终审7天刊登达标率`
from (
	select '快百货' dep ,ta.sku 
		,count(distinct concat(shopcode ,sellersku ,asin) ) list_cnt	
		,count(distinct case when timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate)/86400 < 7 then concat(shopcode ,sellersku ,asin) end ) list_cnt_in7d	
	from ( select SPU ,SKU ,DevelopLastAuditTime 
		from t_prod 
		where DevelopLastAuditTime >= DATE_ADD('${StartDay}',interval - 7 day) and DevelopLastAuditTime <  DATE_ADD('${NextStartDay}',interval - 7 day) and ProjectTeam = '快百货'
		) ta 
	join (select sku ,shopcode ,sellersku ,asin ,MinPublicationDate ,department ,ms.nodepathname
		from wt_listing wl join t_mysql_store ms on wl.ShopCode = ms.Code where department_old = '快百货' and isdeleted = 0 
		) tb on ta.SKU = tb.SKU
	group by ta.sku 
	) t
group by dep
)


-- select * from t_list_in7d 
-- select * from t_list_in7d_over20 

-- step3 派生指标数据集
select
	'${NextStartDay}' `统计日期`
	,t_key.dep `团队` 
	,`上周刊登新品SKU数`
	,`终审7天刊登达标率`
from t_key
left join t_list_in7d_over20 on t_key.dep = t_list_in7d_over20.dep
order by `团队` desc
