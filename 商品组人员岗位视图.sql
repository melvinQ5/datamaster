CREATE VIEW view_roles AS 
with ta as (
select eppug.ProductRole ,MemberName ,LeaderUserName
from 
	(select 
		case 
			when GroupType = 1 then '开发' 
			when GroupType = 2 then '美工'
			when GroupType = 3 then '编辑'
			when GroupType = 4 then '知产'
		end as ProductRole
		, id 
		, LeaderUserName
	from import_data.erp_product_product_user_groups eppug 
	where IsActive = 1 and GroupName <> '快百货>采购组' 
	) eppug
join import_data.erp_product_product_user_group_members eppugm on eppug.id = eppugm.UserGroupId 
)

, tb as (
select ProductRole , MemberName from ta
union select ProductRole , LeaderUserName from ta
)

, tc as (
select eua.name 
	, split(euud.nodepathname,'>')[1] as Department
	, euud.Name as NodePathName
	, euud.NodePathName as NodePathNameFull
from import_data.erp_user_abpusers eua 
left join erp_user_user_departments euud on eua.DepartmentId  = euud .Id 
where  BaseStatus = 1 -- 在职
	and NodePathName regexp '特卖汇|快百货|MRO孵化部|商厨汇'
)

select tb.ProductRole , tc.* 
from tb join tc on tb.MemberName = tc.name

