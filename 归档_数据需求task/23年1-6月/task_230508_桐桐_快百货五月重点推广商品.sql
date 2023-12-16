
with push as ( -- ͩͩ�����ֹ����ṩ����
select c2 as sku ,c3 as boxsku
from manual_table mt where c1 = '��ٻ�_5���ص��ƹ���Ʒ_0509v1' 
)


,tb as ( -- ��ٻ��黹�����600���˺�
select c2 as arr from  manual_table mt where c1 = '��ٻ��˻ز����˺�0427'
)

,ware as (
select dwi.* 
	,case when ProductStatus =  0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as ProductStatus
	,wp.ChangeReasons
	,wp.TortType 
	,wp.DevelopLastAuditTime 
from import_data.daily_WarehouseInventory dwi 
join  import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '��ٻ�'
where dwi.CreatedTime = DATE_ADD(current_date(),-1) and WarehouseName = '��ݸ��' 
and wp.isdeleted = 0
)

,rela as (
select *
from 
	(select 
		epp1.sku as ori_sku ,epp1.BoxSKU as ori_boxsku ,epp1.ProjectTeam as ori_team 
		,epp2.sku as new_sku ,epp2.BoxSKU as new_boxsku ,epp2.ProjectTeam as new_team 
	from import_data.erp_product_product_copy_relations eppcr 
	left join import_data.erp_product_products epp1 on eppcr.OrigProdId = epp1.Id and epp1.IsMatrix =0
	left join import_data.erp_product_products epp2 on eppcr.NewProdId = epp2.Id and epp2.IsMatrix =0
	where eppcr.IsDeleted = 0 and epp1.Id is not null -- ȥ��ĸ�帴�ƹ�ϵ�ļ�¼
	) tb
where ori_team <> '��ٻ�' and new_team = '��ٻ�'  -- ���������Ÿ��Ƶ���ٻ���sku
)

,od_pre as ( -- �����ֶ�����¼����ٻ������˺ų���(����sku����������ƹ�ϵ���ԴSKU) + ��ٻ��˻ز����˺�(����sku����������ƹ�ϵ���ԴSKU) 
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as targetsku 		
	,case when GroupSkuNumber > 0 then '��ϳ���' else '����ϳ���' end as isgroup_pre 		
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- ��ʱ���� ���ƹ�ϵ
where wo.IsDeleted = 0 and OrderStatus != '����' and ms.Department = '��ٻ�'
	and PayTime >= '2022-01-01' 
union 
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,case when GroupSkuNumber > 0  then GroupSku else BoxSku end  as targetsku 
	,case when GroupSkuNumber > 0 then '��ϳ���' else '����ϳ���' end as isgroup_pre 	
from import_data.wt_orderdetails wo 
join tb on wo.shopcode = tb.arr -- ��ٻ��黹�����600���˺�
-- join rela on wo.BoxSku = rela.ori_boxsku  -- ��ʱ���� ���ƹ�ϵ
where wo.IsDeleted = 0 and OrderStatus != '����'  
	and PayTime >= '2022-01-01'
)

, boxsku_2_groupsku as ( -- ����������� ����SKUֱ��ͬ����ת��Ϊ���SKU������ɲ鶩���� boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup regexp '��ϳ���' then '��ϳ���' else '����ϳ���' end as isgroup -- ֻҪ���й���ϳ���������Ϊ��ϳ���
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku  ,site 
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)
-- select * from od 

,orde as (  -- ����sku����������ƹ�ϵ���ԴSKU
select targetsku as BoxSku ,isgroup
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as KBH������12����
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then salecount end ) as KBH������7
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then salecount end ) as KBH������8_14
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then salecount end ) as KBH������15_21
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then salecount end ) as KBH������22_28
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'US' then salecount end ) as US������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'UK' then salecount end ) as UK������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'DE' then salecount end ) as DE������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'FR' then salecount end ) as FR������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'CA' then salecount end ) as CA������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'AU' then salecount end ) as AU������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'ES' then salecount end ) as ES������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'IT' then salecount end ) as IT������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'SE' then salecount end ) as SE������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'NL' then salecount end ) as NL������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'BE' then salecount end ) as BE������3��
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'MX' then salecount end ) as MX������3��

	
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then totalgross/exchangeUSD end ) as KBH���۶��12����
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalgross/exchangeUSD end )) as KBH���۶��7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalgross/exchangeUSD end )) as KBH���۶��8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalgross/exchangeUSD end )) as KBH���۶��15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalgross/exchangeUSD end )) as KBH���۶��22_28
-- 	,sum(case when left(paytime,4)='2021' then totalgross/exchangeUSD end ) as KBH���۶�21��

	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then totalprofit/exchangeUSD end ) as KBH������12����
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalprofit/exchangeUSD end )) as KBH������7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalprofit/exchangeUSD end )) as KBH������8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalprofit/exchangeUSD end )) as KBH������15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalprofit/exchangeUSD end )) as KBH������22_28
-- 	,sum(case when left(paytime,4)='2021' then totalprofit/exchangeUSD end ) as KBH�����21��
from od
group by targetsku ,isgroup
)
-- select * from orde

, inst as (
select wp.BoxSku ,max(CompleteTime) as max_InstockTime
from import_data.wt_purchaseorder wp 
join ware on wp.BoxSku = ware.boxsku 
where isOnWay = '��' 
group by wp.BoxSku
)

, list as (
select wl.BoxSku 
	,count(distinct concat(shopcode,SellerSku)) as `����������`
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(shopcode,SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(shopcode,SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(shopcode,SellerSku) end ) `����������_Ȫ3` 
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
	and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku 
	and ListingStatus = 1 
	and wl.IsDeleted = 0 
	and wp.projectteam = '��ٻ�'
	and wp.IsDeleted = 0 
-- where wp.sku =5032084.01
group by wl.BoxSku
)

-- select count(1) from (
, t_merge as (
 select 
		wp.sku 
		,wp.BoxSku 
		,wp.ProductName `��Ʒ��` 
		,wp.DevelopUserName `������Ա`
		,date(date_add(wp.DevelopLastAuditTime,interval - 8 hour)) `��������`
		,wp.cat1
		,wp.cat2
		,wp.cat3
		,wp.cat4
		,TotalInventory `������`
-- 		,wp.projectteam `��Ʒ���������`
-- 		,wp.ori_boxsku  `Դboxsku���и��ƹ�ϵ��`
-- 		,wp.ori_team `Դboxsku��������`
-- 		,case when coalesce(orde.isgroup,orde2.isgroup) is null then '��ٻ��˺�(���˻�)�޶�����¼' else orde.isgroup end as `�Ƿ���ϳ���`
-- 		,ware.BoxSku `�п��boxsku`
	 	,case when wp.ProductStatus =  0 then '����'
	 			when wp.ProductStatus = 2 then 'ͣ��'
	 			when wp.ProductStatus = 3 then 'ͣ��'
	 			when wp.ProductStatus = 4 then '��ʱȱ��'
	 			when wp.ProductStatus = 5 then '���'
	 	end as  `��Ʒ״̬`
-- 	 	,wp.ChangeReasons `ͣ��ԭ��`
	 	,wp.TortType `��Ȩ����`
	 	
-- 	 	,round(timestampdiff(second,date_add(wp.DevelopLastAuditTime,interval - 8 hour),CURRENT_DATE())/86400/30)  `����������_��30��`
		,ifnull(orde.KBH������12����,0) + ifnull(orde2.KBH������12����,0) as KBH������12����
		,ifnull(orde.KBH���۶��12����,0) + ifnull(orde2.KBH���۶��12����,0) as KBH���۶��12����
		,ifnull(orde.KBH������12����,0) + ifnull(orde2.KBH������12����,0) as KBH������12����
	
		
		,ifnull(orde.KBH������7,0) + ifnull(orde2.KBH������7,0) + ifnull(orde.KBH������8_14,0) + ifnull(orde2.KBH������8_14,0) as KBH������14��
		,ifnull(orde.KBH������15_21,0) + ifnull(orde2.KBH������15_21,0) + ifnull(orde.KBH������22_28,0) + ifnull(orde2.KBH������22_28,0) as KBH����ǰ14��
		
		,ifnull(orde.KBH���۶��7,0) + ifnull(orde2.KBH���۶��7,0) + ifnull(orde.KBH���۶��8_14,0) + ifnull(orde2.KBH���۶��8_14,0) as KBH���۶��14��
		,ifnull(orde.KBH���۶��15_21,0) + ifnull(orde2.KBH���۶��15_21,0) + ifnull(orde.KBH���۶��22_28,0) + ifnull(orde2.KBH���۶��22_28,0) as KBH���۶�ǰ14��
		
		,ifnull(orde.KBH������7,0) + ifnull(orde2.KBH������7,0) + ifnull(orde.KBH������8_14,0) + ifnull(orde2.KBH������8_14,0) as KBH������14��
		,ifnull(orde.KBH������15_21,0) + ifnull(orde2.KBH������15_21,0) + ifnull(orde.KBH������22_28,0) + ifnull(orde2.KBH������22_28,0) as KBH�����ǰ14��
		
		,ifnull(orde.KBH������7,0) + ifnull(orde2.KBH������7,0) + ifnull(orde.KBH������8_14,0) + ifnull(orde2.KBH������8_14,0) 
			- ( ifnull(orde.KBH������15_21,0) + ifnull(orde2.KBH������15_21,0) + ifnull(orde.KBH������22_28,0) + ifnull(orde2.KBH������22_28,0) ) as ��14�Ա�ǰ14��������

		,ifnull(orde.US������3��,0) + ifnull(orde2.US������3��,0) as US������3��
		,ifnull(orde.UK������3��,0) + ifnull(orde2.UK������3��,0) as UK������3��
		,ifnull(orde.DE������3��,0) + ifnull(orde2.DE������3��,0) as DE������3��
		,ifnull(orde.FR������3��,0) + ifnull(orde2.FR������3��,0) as FR������3��
		,ifnull(orde.CA������3��,0) + ifnull(orde2.CA������3��,0) as CA������3��
		,ifnull(orde.AU������3��,0) + ifnull(orde2.AU������3��,0) as AU������3��
		,ifnull(orde.ES������3��,0) + ifnull(orde2.ES������3��,0) as ES������3��
		,ifnull(orde.IT������3��,0) + ifnull(orde2.IT������3��,0) as IT������3��
		,ifnull(orde.SE������3��,0) + ifnull(orde2.SE������3��,0) as SE������3��
		,ifnull(orde.NL������3��,0) + ifnull(orde2.NL������3��,0) as NL������3��
		,ifnull(orde.BE������3��,0) + ifnull(orde2.BE������3��,0) as BE������3��
		,ifnull(orde.MX������3��,0) + ifnull(orde2.MX������3��,0) as MX������3��
		
-- 		,`����������`
-- 	 	,`����������_��1` 
-- 	 	,`����������_��2` 
-- 	 	,`����������_Ȫ1` 
-- 	 	,`����������_Ȫ2` 
-- 	 	,`����������_Ȫ3` 
	 	
-- 	 	,round(timestampdiff(second,date_add(wp.DevelopLastAuditTime,interval - 8 hour),CURRENT_DATE())/86400)  `����������`
-- 	 	,IsPackage `�Ƿ����`
-- 	 	,AverageUnitPrice `ƽ������`
-- 	 	,TotalPrice `����ܽ��`
-- 	 	,InventoryAge45 `0-45�������`
-- 	 	,InventoryAge90 `46-90�������`
-- 	 	,InventoryAge180 `91-180�������`
-- 	 	,InventoryAge270 `181-270�������`
-- 	 	,InventoryAge365 `271-365�������`
-- 	 	,InventoryAgeOver `����365�������`
-- 	 	,max_InstockTime `���ɹ������`
-- 	 	,datediff(CURRENT_DATE(),max_InstockTime) `���ɹ����������` 
	from 
		( select wp.* ,rela.ori_boxsku ,rela.ori_team
		from import_data.wt_products wp
		join push on wp.sku =push.sku  -- ͩͩ�ṩ��������
		left join rela on wp.BoxSku = rela.new_boxsku  
		) wp 
	left join ware on ware.BoxSku = wp.boxsku
	left join orde on orde.BoxSku = wp.boxsku -- ��Ʒ�������ٻ������ۣ���ٻ��˺ų���
	left join orde orde2 on orde2.BoxSku = wp.ori_boxsku -- ��Ʒ������������ţ���ٻ��˺ų���
	-- left join orde_tmh on orde_tmh.BoxSku = wp.boxsku
	left join inst on inst.BoxSku = wp.boxsku
	left join list on list.BoxSku = wp.boxsku
	where  wp.DevelopLastAuditTime is not null 
		and wp.projectteam = '��ٻ�' -- ��ʱ���� ���ƹ�ϵ
		and wp.BoxSku is not null 
)

, t_site_sort as (
select sku ,GROUP_CONCAT(site) ����top2վ��
from (
select * , ROW_NUMBER () over (partition by sku order by sales desc ) sort 
	from (
		select sku , US������3�� as sales, 'US' as site from t_merge 
		union all select sku , UK������3�� , 'UK' as site from t_merge 
		union all select sku , DE������3�� , 'DE' as site from t_merge 
		union all select sku , FR������3�� , 'FR' as site from t_merge 
		union all select sku , CA������3�� , 'CA' as site from t_merge 
		union all select sku , AU������3�� , 'AU' as site from t_merge 
		union all select sku , ES������3�� , 'ES' as site from t_merge 
		union all select sku , IT������3�� , 'IT' as site from t_merge 
		union all select sku , SE������3�� , 'SE' as site from t_merge 
		union all select sku , NL������3�� , 'NL' as site from t_merge 
		union all select sku , BE������3�� , 'BE' as site from t_merge 
		union all select sku , MX������3�� , 'MX' as site from t_merge 
		) tb 
	where sales > 0
	) tc
where sort <= 2 
group by sku
)

select t_merge.* ,t_site_sort.����top2վ��
from t_merge left join t_site_sort on t_merge.sku = t_site_sort.sku 


		
