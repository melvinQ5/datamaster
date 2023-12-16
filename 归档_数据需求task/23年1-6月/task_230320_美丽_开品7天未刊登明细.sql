with 
-- step1 ����Դ����
t_prod as (
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,SPU ,CreationTime ,boxSKU ,SKUSource ,DevelopUserName 
from import_data.erp_product_products
where IsDeleted =0 and IsMatrix = 0
)

select count(1) from ( 

select  tmp1.SKU ,tmp1.spu ,ProjectTeam ,DevelopUserName 
	,CreationTime `���ʱ��`
	,DevelopLastAuditTime `����ʱ��`
	,tmp2.min_pub_date `�״ο���ʱ��`
	,round(timestampdiff(SECOND,CreationTime,min_pub_date)/86400,1) `�״ο���-���ʱ��`
from 
	(select SKU,SPU,ProjectTeam,CreationTime ,DevelopUserName ,DevelopLastAuditTime
	from t_prod where CreationTime >= '2023-01-01' and DevelopLastAuditTime is not null 
	and ProjectTeam = '��ٻ�' 
	) tmp1 
left join (
	select wl.SKU ,wl.min_pub_date -- 23�������� �� ��Ʒ��Ӻ�7�����п��ǵĲ�Ʒ
	from (
		select SKU ,CreationTime 
		from t_prod where CreationTime >= '2023-01-01' 
		) tmp 
	join 
		(
		select sku ,min(PublicationDate) as min_pub_date
		from wt_listing group by sku 
		) wl
	group by wl.SKU ,wl.min_pub_date
	) tmp2
on tmp1.SKU = tmp2.SKU
where min_pub_date > CreationTime or min_pub_date is null 
-- group by tmp1.SKU ,tmp1.spu,ProjectTeam,CreationTime 

) a 


