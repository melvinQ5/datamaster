--  见美编N天
 
with art_spu as (
select HandleUserName , SKU ,SPU ,ProductId ,AssginTime,AuditTime, date_add(DevelopLastAuditTime,interval - 8 hour ) DevelopLastAuditTime
	, vr.department
 	, vr.NodePathName
 	, vr.dep2
from import_data.erp_product_products epp 
join (
	select ProductId  ,HandleUserName 
		,date_add(AssginTime,interval - 8 hour) AssginTime 
		,date_add(AuditTime,interval - 8 hour ) AuditTime
	from import_data.erp_product_product_statuses epps 
	where date_add(AssginTime,interval - 8 hour)  < '${NextStartDay}' 
		and date_add(AssginTime,interval - 8 hour) >= '${StartDay}' 
		and DevelopStage = 40
	group by ProductId  ,HandleUserName ,AssginTime,AuditTime
	) art on epp.Id = art.ProductId
join ( select case when name in ('唐美丽','金琴2') then '快百货一部' else split(NodePathNameFull,'>')[2] end as dep2 -- 两人曾协助开品，但非商品组人员
			,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName
			,name ,department
		from view_roles 
		where ProductRole ='美工' 
	-- 	and NodePathName in ('快次方-商品组','快次元-商品组','商品组')
		) vr on art.HandleUserName = vr.name
where epp.ProjectTeam = '快百货' 
	and DevelopLastAuditTime is not null -- 有终审
	and epp.Status = 10 
group by HandleUserName , SKU ,SPU ,ProductId ,AssginTime,AuditTime, date_add(DevelopLastAuditTime,interval - 8 hour )
	, vr.department
 	, vr.NodePathName
 	, vr.dep2
)

,t_reje as ( -- 侵权驳回至美工
select HandleTime ,Reason ,Remark ,ProductId 
from erp_product_product_develop_logs
where Stage = 60 
	and PreStatus = 40 -- 待审核
	and AftStatus = 50 -- 被驳回
	and Reason = '图片侵权'
	and HandleTime >= '2023-04-01' and HandleTime < '2023-05-01'
)

-- -- 统计
 select
 	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `美工分配时间范围`
 	,dep2 `团队`
 	,NodePathName `小组`
 	,HandleUserName `处理人`
 	, count(DISTINCT t.sPU) `处理SPU数`
 from art_spu t 
 group by department
 	,dep2
 	,NodePathName
 	,HandleUserName 

