-- ��æ��һ��ϵͳ��ǩΪ������������Ʒȥ��4-6�¼�����3-4�£����¼�����������ë��
with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
)

,dim_new as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '��ٻ�'
)

,dim_old as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '��ٻ�'
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)

,t_prod as (
select wp.sku ,wp.BoxSku , '������' ele_name  ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `��Ʒ����ʱ��`
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,DevelopUserName `������Ա`
	,vr.NodePathName `����״̬`
	,wp.CategoryPathByChineseName ,Cat1
from import_data.wt_products wp
join (select sku from t_elem where ele_name = '������' group by sku ) ele on wp.sku = ele.sku 
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '����'
where IsDeleted = 0 
)

,t_orde_stat as (
select wo.BoxSku 
	,sum(case when left(SettlementTime,7)='2022-04' then SaleCount end ) as ����2204
	,sum(case when left(SettlementTime,7)='2022-05' then SaleCount end ) as ����2205
	,sum(case when left(SettlementTime,7)='2022-06' then SaleCount end ) as ����2206
	,sum(case when left(SettlementTime,7)='2023-03' then SaleCount end ) as ����2303
	,sum(case when left(SettlementTime,7)='2023-04' then SaleCount end ) as ����2304
	
	,sum(case when left(SettlementTime,7)='2022-04' then totalgross end ) as ���۶�2204
	,sum(case when left(SettlementTime,7)='2022-05' then totalgross end ) as ���۶�2205
	,sum(case when left(SettlementTime,7)='2022-06' then totalgross end ) as ���۶�2206
	,sum(case when left(SettlementTime,7)='2023-03' then totalgross end ) as ���۶�2303
	,sum(case when left(SettlementTime,7)='2023-04' then totalgross end ) as ���۶�2304
	
	,sum(case when left(SettlementTime,7)='2022-04' then totalprofit end ) as �����2204
	,sum(case when left(SettlementTime,7)='2022-05' then totalprofit end ) as �����2205
	,sum(case when left(SettlementTime,7)='2022-06' then totalprofit end ) as �����2206
	,sum(case when left(SettlementTime,7)='2023-03' then totalprofit end ) as �����2303
	,sum(case when left(SettlementTime,7)='2023-04' then totalprofit end ) as �����2304
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on  t_prod.boxsku = wo.BoxSku 
where wo.IsDeleted = 0 and OrderStatus != '����'  and ms.Department = '��ٻ�'
	and SettlementTime > '2022-01-01'
group by wo.BoxSku 
)

-- ����������
, t_mearge_stock as (
select t.* ,dwi.ifnull(TotalInventory,0) `0413�������`
from t_prod	t 
left join import_data.daily_WarehouseInventory dwi on t.boxsku = dwi.boxsku and dwi.CreatedTime = '2023-04-13'
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
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ3` 
from t_list
group by BoxSKU  
)

select a.* , b.* ,c. `0413�������` 
	, `����������_��1` 
	, `����������_��2` 
	, `����������_Ȫ1` 
	, `����������_Ȫ2`  
	, `����������_Ȫ3`  
from t_prod a 
left join t_orde_stat b on a.boxsku = b.boxsku 
left join t_mearge_stock c on a.boxsku =c.boxsku 
left join t_list_stat d on a.boxsku = d.boxsku 
