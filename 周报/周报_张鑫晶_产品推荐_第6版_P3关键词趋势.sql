/*
 * �ؼ������Ʋ�Ʒ�Ƽ�����
ĸ�׽� ��Ʒ����+��Ʒȥ��3-5��������
��Ʒ��ĸ�׽� ���������� ��ի�� �����
*/


-- ��ͷ�����ƽ̨��P1 �� P3 ͳһ 

with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
union 
select c3 as sku from manual_table mt where c1 REGEXP '��Ʒ�Ƽ�_��14��'
)

,dim_new as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '��ٻ�'
)

,dim_old as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProductName regexp '
������������|��ɹ˪ͿĨ��|�����̺|�ҹ�|�ҹ�����������|�����ǹ|̫���ܻ��|̫���ܻ�԰��|Ұ��̺|԰������|�Ĵ�|��ʿ̫����|�տ���|��԰��|
����Ǯ��|���汣���� 180x200|���޵�̺�����ִ����ɶ��޵�̺|
�ֳַ���|���а�|LED ҰӪ��|Ůʿ͸����|�����������|������|���|��ԡ�Źҹ�|�ɶԵ�|������'
and ProjectTeam = '��ٻ�'
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)



, t_sku_stat as ( -- 'ĸ�׽�|����������|��ի��|�����'
-- select *
-- from (
-- select 'A_23��������' `����Ʒ` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `��Ʒ����ʱ��`
-- 	,DevelopUserName ,vr.NodePathName 
-- 	,wp.CategoryPathByChineseName ,Cat1 ,'��Ʒ' `��������`
-- from wt_products wp 
-- join t_elem on wp.sku = t_elem .sku and ele_name regexp 'ĸ�׽�|����������|��ի��|�����'
-- join dim_new on wp.boxsku = dim_new.boxsku -- ��Ʒ
-- left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '����'

-- union all 
select 'B_23����ǰ����' `����Ʒ` 
	,ele_name 
	,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `��Ʒ����ʱ��`
	,DevelopUserName ,vr.NodePathName 
	,cat1`һ����Ŀ` 
	,cat2`������Ŀ` 
	,cat3`������Ŀ` 
	,cat4`�ļ���Ŀ` 	
	,wp.TortType `��Ȩ����` 
	,salecount as `��2��������`
from wt_products wp 
join dim_old on wp.boxsku = dim_old.boxsku -- ��Ʒ
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '����'
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
join 
	(
	select wo.product_sku  ,sum(SaleCount) as salecount  
	from wt_orderdetails wo
	left join t_black_list on wo.product_sku = t_black_list.sku 
	where paytime >= date_add('${NextStartDay}', interval - 60 day ) and paytime <'${NextStartDay}'
		and wo.Department='��ٻ�' 
		and wo.isdeleted = 0 
		and t_black_list.sku is null 
	group by wo.product_sku  having sum(SaleCount) > 0
	) wo 
	on wo.product_sku = wp.sku 
) 


-- ����������
, t_mearge_stock as (
select t.* ,dwi.ifnull(TotalInventory,0) `������`
from t_sku_stat	t 
left join import_data.daily_WarehouseInventory dwi on t.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartDay}', interval -1 day )
)

,t_list as ( -- ��������
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl -- ��Ϊ��������䵽����sku,���Բ���Ҫʹ��erp��
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join (select sku from t_mearge_stock group by sku ) ta on ta.sku = wl.SKU 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
-- 	and SellerSku not regexp 'bJ|Bj|bj|BJ'
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(SellerSKU,ShopCode)) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(shopcode,SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(shopcode,SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(shopcode,SellerSku) end ) `����������_Ȫ3` 
	,min(PublicationDate) `�״ο���ʱ��`
from t_list
group by BoxSKU  
)

, t_mearge_list as (
select 'P3-Ԫ��Ʒ-�ؼ�������' `������` 
	,ta.* 
	, `����������` 
	, `����������_��1` 
	, `����������_��2` 
	, `����������_Ȫ1` 
	, `����������_Ȫ2` 
	, `����������_Ȫ3` 
from t_mearge_stock ta 
left join t_list_stat tb on ta.boxsku = tb.boxsku 
)

select * ,'' `��or��ȷ�����ǣ������Ա�ͳ��Ч����`
from t_mearge_list
order by  `��2��������` desc  , `������` desc 
limit 200 