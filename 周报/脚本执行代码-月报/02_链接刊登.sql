with
-- step1 ����Դ����
t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union select '�̳���' 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)

,t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select 
	Code 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�����' 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department 
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

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
,t_list_in7d_over20 as ( -- ������ÿ��10�� ,��ٻ�40��
select nodepathname as dep 
	,count( distinct sku ) `���ܿ�����ƷSKU��`
	,round(count(distinct case when list_cnt_in7d >=10 then sku end )/count( distinct sku ),4) as `����7�쿯�Ǵ����`
from (
	select nodepathname ,ta.sku 
		,count(distinct concat(shopcode ,sellersku ,asin) ) list_cnt	
		,count(distinct case when timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate)/86400 < 7 then concat(shopcode ,sellersku ,asin) end ) list_cnt_in7d	
	from ( select SPU ,SKU ,DevelopLastAuditTime 
		from t_prod 
		where DevelopLastAuditTime >= DATE_ADD('${StartDay}',interval - 7 day) and DevelopLastAuditTime <  DATE_ADD('${NextStartDay}',interval - 7 day) and ProjectTeam = '��ٻ�'
		) ta 
	join (select sku ,shopcode ,sellersku ,asin ,MinPublicationDate ,department ,ms.nodepathname
		from wt_listing wl join t_mysql_store ms on wl.ShopCode = ms.Code where department_old = '��ٻ�' and isdeleted = 0 
		) tb on ta.SKU = tb.SKU
	group by nodepathname ,ta.sku 
	) t
group by nodepathname
union 
select dep 
	,count( distinct sku ) `���ܿ�����ƷSKU��`
	,round(count( distinct case when list_cnt_in7d >=40 then sku end )/count( distinct sku ),4) as `����7�쿯�Ǵ����`
from (
	select '��ٻ�' dep ,ta.sku 
		,count(distinct concat(shopcode ,sellersku ,asin) ) list_cnt	
		,count(distinct case when timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate)/86400 < 7 then concat(shopcode ,sellersku ,asin) end ) list_cnt_in7d	
	from ( select SPU ,SKU ,DevelopLastAuditTime 
		from t_prod 
		where DevelopLastAuditTime >= DATE_ADD('${StartDay}',interval - 7 day) and DevelopLastAuditTime <  DATE_ADD('${NextStartDay}',interval - 7 day) and ProjectTeam = '��ٻ�'
		) ta 
	join (select sku ,shopcode ,sellersku ,asin ,MinPublicationDate ,department ,ms.nodepathname
		from wt_listing wl join t_mysql_store ms on wl.ShopCode = ms.Code where department_old = '��ٻ�' and isdeleted = 0 
		) tb on ta.SKU = tb.SKU
	group by ta.sku 
	) t
group by dep
)


-- select * from t_list_in7d 
-- select * from t_list_in7d_over20 

-- step3 ����ָ�����ݼ�
select
	'${NextStartDay}' `ͳ������`
	,t_key.dep `�Ŷ�` 
	,`���ܿ�����ƷSKU��`
	,`����7�쿯�Ǵ����`
from t_key
left join t_list_in7d_over20 on t_key.dep = t_list_in7d_over20.dep
order by `�Ŷ�` desc
