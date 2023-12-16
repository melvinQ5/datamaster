-- ��14��Ա�ǰ14�충��������2���������������У�ȥ��ͣ����ȱ���Ĳ�Ʒ��

with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
union 
select c3 as sku from manual_table mt where c1 REGEXP '��Ʒ�Ƽ�_��14��|��Ʒ�Ƽ�_��15��'
)


,dim_new as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
)

,dim_old as ( -- ��Ʒ
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)

,new_list as ( -- ��Ʒ�Ƽ�
select  'A_23��������' `����Ʒ` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime)  as `��Ʒ����ʱ��` 
	,DevelopUserName ,vr.NodePathName 
	,cat1`һ����Ŀ` 
	,cat2`������Ŀ` 
	,cat3`������Ŀ` 
	,cat4`�ļ���Ŀ` 	
	,wp.TortType `��Ȩ����` ,dwi.ifnull(TotalInventory,0) `������`
	,number1 as '��14���Ʒ������' ,number2 as 'ǰ14���Ʒ������' ,number1-number2 as '��������' 
from
	(select a.BoxSKU,number1 ,number2 
	from
		(select wo.BoxSKU ,count(distinct platordernumber ) as number1 
		from wt_orderdetails wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='��ٻ�'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >= date_add('${NextStartday}',interval -14 day ) and paytime <'${NextStartday}'
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as a
	left join
		(select wo.BoxSKU ,count(distinct platordernumber )  as number2 
		from wt_orderdetails as wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='��ٻ�'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >=date_add('${NextStartday}',interval -28 day ) and paytime <date_add('${NextStartday}',interval -14 day )
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as b
	on a.BoxSKU=b.BoxSKU 
	) as c
join wt_products wp on c.BoxSKU = wp.BoxSKU and IsDeleted=0 and ProductStatus not in ('2','4')
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '����'
join dim_new on c.boxsku = dim_new.boxsku -- ��Ʒ
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
left join import_data.daily_WarehouseInventory dwi on c.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartday}',interval -1 day )
where number1 - ifnull(number2,0) >= 2 -- ǰ14������޶���
)

,old_list as ( -- ��Ʒ�Ƽ�
select 'B_23����ǰ����' `����Ʒ` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `��Ʒ����ʱ��`
	,DevelopUserName ,vr.NodePathName 
	,cat1 `һ����Ŀ` 
	,cat2 `������Ŀ` 
	,cat3 `������Ŀ` 
	,cat4 `�ļ���Ŀ` 
	,wp.TortType ,dwi.ifnull(TotalInventory,0) `������`
	,number1 as '��14���Ʒ������' ,number2 as 'ǰ14���Ʒ������' ,number1-number2 as '��������' 
from
	(select a.BoxSKU,number1 ,number2 
	from
		(select wo.BoxSKU ,count(distinct platordernumber ) as number1 
		from wt_orderdetails wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='��ٻ�'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >= date_add('${NextStartday}',interval -14 day ) and paytime <'${NextStartday}'
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as a
	join
		(select wo.BoxSKU ,count(distinct platordernumber ) as number2 
		from wt_orderdetails as wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='��ٻ�'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >=date_add('${NextStartday}',interval -28 day ) and paytime <date_add('${NextStartday}',interval -14 day )
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as b
	on a.BoxSKU=b.BoxSKU 
	) as c
join wt_products wp on c.BoxSKU = wp.BoxSKU and IsDeleted=0 and ProductStatus not in ('2','4')
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '����'
join dim_old on c.boxsku = dim_old.boxsku -- ��Ʒ
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
left join import_data.daily_WarehouseInventory dwi on c.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartday}',interval -1 day )
where number1 - number2 >= 2 -- ǰ14�����������ҽ�14��Ա�ǰ14������>=2
)

,t_merage as ( -- �ܹ��Ƽ�300�� , ����������Ʒ�Ƽ�����������������Ʒ����
select * from new_list 
union all 
select * from old_list 
)

,t_list_cnt as ( 
select wl.sku 
	,count(distinct concat(SellerSKU,ShopCode)) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(shopcode,SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(shopcode,SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(shopcode,SellerSku) end ) `����������_Ȫ3` 
from wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
join (select sku from t_merage group by sku ) tb on wl.sku = tb.sku 
where wl.ListingStatus =1 and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
group by wl.sku
)

select 'P1-��Ʒ����Ʒ' `������` 
	,ta.* ,`����������` ,`����������_��1` ,`����������_��2` ,`����������_Ȫ1` ,`����������_Ȫ2` ,`����������_Ȫ3` 
from t_merage ta 
left join t_list_cnt tb on ta.sku = tb.sku  
order by `����Ʒ` ASC ,�������� DESC limit 400
