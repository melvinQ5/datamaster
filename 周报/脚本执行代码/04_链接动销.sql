

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


,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else '��ٻ�����' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '��'
)

,t_elem as ( -- Ԫ��ά��
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products t_prod on eppaea.sku = t_prod.sku and t_prod.ismatrix = 0 and t_prod.IsDeleted =0 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_copy_new_pp as ( -- 2�¸��Ʋ�Ʒ����Ʒ
select eppcr.NewProdId, null spu ,epp.sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.sku
union 
select eppcr.NewProdId, epp.spu ,null sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =1 and eppcr.IsDeleted = 0 
group by eppcr.NewProdId, epp.spu
)

,t_orde as (
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts ,wo.shopcode ,wo.Asin 
-- 	,pp.Spu
	,ms.*
	,elem.ele_boxsku
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
left join ( select spu ,BoxSku as ele_boxsku ,DevelopLastAuditTime from t_elem group by spu ,BoxSku ,DevelopLastAuditTime ) elem 
	on wo.BoxSku = elem.ele_boxsku -- ɸѡԪ��Ʒ
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
)

,t_new_list as ( -- �¿�������ά��
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.*
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)


-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
,t_ware_sku as (
select case when department is null then '��˾' else department end as dep
	, count(distinct tmp.BoxSku ) `����ƷSKU��` -- �ϸ�ͳ����ĩ�ڲ�sku U ��ͳ����ĩ�ڲ�sku U �ڼ�ɹ�����SKU
from (
	select BoxSku -- �����ڲ�sku
	from import_data.daily_WarehouseInventory dwi 
	where CreatedTime = DATE_ADD('${NextStartDay}', -1) and WarehouseName = '��ݸ��' 
	group by BoxSku 
	union 
	select BoxSku -- �����ڲ�sku
	from import_data.daily_WarehouseInventory dwi 
	where CreatedTime = DATE_ADD('${StartDay}', -1) and WarehouseName = '��ݸ��' 
	group by BoxSku 
	union 
	select BoxSku -- �ڼ�ɹ�sku
	from wt_purchaseorder wp 
	where ordertime  <  '${NextStartDay}'  and ordertime >= '${StartDay}' and WarehouseName = '��ݸ��' 
	) tmp 
join (select BoxSku , ProjectTeam as department from import_data.wt_products where IsDeleted = 0 ) wp2 
	on tmp.BoxSku =wp2.BoxSku 
group by grouping sets ((),(department))
)

,t_erp_sku as (
select case when ProjectTeam is null then '��˾' else ProjectTeam end as dep
	,count(distinct SKU) `��Ʒ��SKU��`
	,count(distinct SPU) `��Ʒ��SPU��`
from import_data.erp_product_products epp 
where IsDeleted = 0 and ProductStatus != 2 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))
)

,t_sale_sku as ( 
select case when ms.department is null then '��˾' else ms.department end as dep
	, count(distinct boxsku) `����sku��`
	, count(distinct Product_SPU) `����spu��`
	, count(distinct shopcode) `����������`	
from wt_orderdetails wo 
join t_mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' 
	and TransactionType ='����' and OrderStatus <> '����' and TotalGross>0 
group by grouping sets ((),(ms.department))
union 
select '��ٻ�' as department
	, count(distinct boxsku) `����sku��`
	, count(distinct Product_SPU) `����spu��`
	, count(distinct shopcode) `����������`	
from wt_orderdetails wo 
join t_mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}'  and ms.department regexp '��' 
	and TransactionType ='����' and OrderStatus <> '����' and TotalGross>0 
)

-- ����������ϸ
-- select t_orde.department ,t_orde.ShopCode ,t_orde.Asin ,t_orde.SellerSku 
-- from t_orde
-- join (
-- 	select department,shopcode,SellerSku,Asin 
-- 	from t_new_list where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
-- 	group by department,shopcode,SellerSku,Asin 
-- 	) t_new_list 
-- 	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
-- 	where t_orde.department  regexp '��'
	

,t_new_pub as (  -- �¿�������
select case when t_orde.department is null then '��˾' else t_orde.department end as dep
	,round(sum(TotalGross/ExchangeUSD)) `�¿����������۶�`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `�¿��ǳ���������`
from t_orde
join (
	select department,shopcode,SellerSku,Asin 
	from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_orde.department))
union
select '��ٻ�' as department
	,round(sum(TotalGross/ExchangeUSD)) `�¿����������۶�`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `�¿��ǳ���������`
from t_orde
join ( 
	select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '��' 
	group by shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
where t_orde.department regexp '��' 
union
select t_orde.NodePathName 
	,round(sum(TotalGross/ExchangeUSD)) `�¿����������۶�`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `�¿��ǳ���������`
from t_orde
join (
	select NodePathName,shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '��' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
where t_orde.department regexp '��' 
group by t_orde.NodePathName
)

,t_ord_lst as (
select case when t_orde.department is null then '��˾' else t_orde.department end as dep
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `����������`
from t_orde where TransactionType ='����' and OrderStatus <> '����' and TotalGross>0
group by grouping sets ((),(t_orde.department))
union 
select  '��ٻ�' as department
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `����������`
from t_orde where TransactionType ='����' and OrderStatus <> '����' and TotalGross>0 and department regexp '��' 
union 
select t_orde.NodePathName 
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `����������`
from t_orde where TransactionType ='����' and OrderStatus <> '����' and TotalGross>0  and department regexp '��' 
group by t_orde.NodePathName
)

,t_online_list_spu as ( 
select case when department is null then '��˾' else department end as dep
	,count( distinct spu ) `����SPU��`
from (select ShopCode ,SellerSKU ,ASIN ,ms.department ,spu
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code and ListingStatus = 1 and ms.ShopStatus = '����'
	group by department,shopcode,SellerSku,Asin,spu
	) tmp1
group by grouping sets ((),(department))
union 
select  '��ٻ�' as department ,count(distinct spu) `����SPU��`
from (select ShopCode ,SellerSKU ,ASIN ,spu
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
		on eaal.ShopCode = ms.Code and ListingStatus = 1 and ms.ShopStatus = '����'
	where department regexp '��' 
	group by shopcode,SellerSku,Asin,spu
	) tmp1
)

,t_online_list as (
select case when department is null then '��˾' else department end as dep
	,count(1) `����������`
from (select ShopCode ,SellerSKU ,ASIN ,ms.department 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����'
		and department <> '������' -- ���������Ե���+����ȷ��һ�����ӣ�����������ݱ�
	group by department,shopcode,SellerSku,Asin
	) tmp1
group by grouping sets ((),(department))
union	
select '��ٻ�' as department ,count(1) `����������`
from (select ShopCode ,SellerSKU ,ASIN 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����'
	where department regexp '��' 
	group by shopcode,SellerSku,Asin
	) tmp1
union	
select NodePathName ,count(1) `����������`
from ( select ShopCode ,SellerSKU ,ASIN ,ms.NodePathName 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����'
	where department regexp '��' 
	group by NodePathName,shopcode,SellerSku,Asin
	) tmp1
group by NodePathName
)

, t_new_list_cnt as (
select case when department is null then '��˾' else department end as dep
	,count(1) `�¿���������`
from (select department,shopcode,SellerSku,Asin from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '��ٻ�' as department ,count(1) `�¿���������`
from (select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '��' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `�¿���������`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '��' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) tmp3 
group by NodePathName
)

,t_new_list_in30d as ( -- ��30�쿯��
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.*
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= date_add('${NextStartDay}',interval - 30 day)  and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)

, t_new_list_in30d_cnt as (
select case when department is null then '��˾' else department end as dep
	,count(1) `��30�쿯��������`
from (select department,shopcode,SellerSku,Asin from t_new_list_in30d 
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '��ٻ�' as department ,count(1) `��30�쿯��������`
from (select shopcode,SellerSku,Asin 
	from t_new_list_in30d
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '��' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `��30�쿯��������`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list_in30d
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '��' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) tmp3 
group by NodePathName
)


-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep `�Ŷ�`
	,t_new_pub.`�¿����������۶�` ,t_new_pub.`�¿��ǳ���������`
	,t_sale_sku.`����sku��`
	,t_sale_sku.`����spu��`
	,t_sale_sku.`����������`
	,t_ware_sku.`����ƷSKU��`
	,t_new_list_cnt.`�¿���������`
	,t_new_list_in30d_cnt.`��30�쿯��������`
	,t_online_list.`����������`
	,t_ord_lst.`����������`
	,t_erp_sku.`��Ʒ��SKU��`
	,t_erp_sku.`��Ʒ��SPU��`
	,t_online_list_spu.`����SPU��`
from t_key
left join t_new_pub on t_key.dep = t_new_pub.dep
left join t_sale_sku on t_key.dep = t_sale_sku.dep
left join t_ware_sku on t_key.dep = t_ware_sku.dep
left join t_new_list_cnt on t_key.dep = t_new_list_cnt.dep
left join t_online_list on t_key.dep = t_online_list.dep
left join t_ord_lst on t_key.dep = t_ord_lst.dep
left join t_erp_sku on t_key.dep = t_erp_sku.dep
left join t_online_list_spu on t_key.dep = t_online_list_spu.dep
left join t_new_list_in30d_cnt on t_key.dep = t_new_list_in30d_cnt.dep
)

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,t_merge.*
	, round(`����sku��`/`����ƷSKU��`,4) as `���SKU������`
	, round(`����spu��`/`��Ʒ��SPU��`,4) as `��Ʒ��SPU������`
	, round(`�¿��ǳ���������`/`�¿���������`,4 ) `�¿������Ӷ�����`
	, round(`����������`/`����������`,4 ) `���Ӷ�����`
from t_merge
order by `�Ŷ�` desc 