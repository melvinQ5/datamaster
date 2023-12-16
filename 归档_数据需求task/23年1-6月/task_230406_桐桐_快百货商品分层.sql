-- ���±��˺� +  Ŀǰ���������˺�ȥ�� ����


with 
tb as ( -- ��ٻ�����ʹ�ù����˺�
select memo as arr from  manual_table mt where c1 = '��ٻ��˻ز����˺�0702'
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
join import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '��ٻ�'
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
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as 	 targetsku		
	,case when GroupSkuNumber > 0 then '��ϳ���' else '����ϵ�' end as isgroup_pre
from import_data.wt_orderdetails wo 
join (select code from mysql_store ms where Department = '��ٻ�' 
	union select arr from tb ) ms 
	on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- ��ʱ���� ���ƹ�ϵ
where wo.IsDeleted = 0 and OrderStatus != '����'
	and PayTime >= '2022-01-01' 
)

, boxsku_2_groupsku as ( -- ����������� ����SKUֱ��ͬ����ת��Ϊ���SKU������ɲ鶩���� boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup  regexp '��ϳ���' then '��ϳ���' else '����ϳ���' end as isgroup -- ֻҪ���й���ϳ���������Ϊ��ϳ���
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)
-- select * from od where targetsku = 4223503

,orde as (  -- ����sku����������ƹ�ϵ���ԴSKU
select targetsku as BoxSku ,isgroup
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as KBH������12����
	,sum(SaleCount) as KBH����22������
	,sum(case when left(paytime,7)='2022-01' then SaleCount end ) as KBH����2201
	,sum(case when left(paytime,7)='2022-02' then SaleCount end ) as KBH����2202
	,sum(case when left(paytime,7)='2022-03' then SaleCount end ) as KBH����2203
	,sum(case when left(paytime,7)='2022-04' then SaleCount end ) as KBH����2204
	,sum(case when left(paytime,7)='2022-05' then SaleCount end ) as KBH����2205
	,sum(case when left(paytime,7)='2022-06' then SaleCount end ) as KBH����2206
	,sum(case when left(paytime,7)='2022-07' then SaleCount end ) as KBH����2207
	,sum(case when left(paytime,7)='2022-08' then SaleCount end ) as KBH����2208
	,sum(case when left(paytime,7)='2022-09' then SaleCount end ) as KBH����2209
	,sum(case when left(paytime,7)='2022-10' then SaleCount end ) as KBH����2210
	,sum(case when left(paytime,7)='2022-11' then SaleCount end ) as KBH����2211
	,sum(case when left(paytime,7)='2022-12' then SaleCount end ) as KBH����2212

	,sum(case when left(paytime,7)='2023-01' then SaleCount end ) as KBH����2301
	,sum(case when left(paytime,7)='2023-02' then SaleCount end ) as KBH����2302
	,sum(case when left(paytime,7)='2023-03' then SaleCount end ) as KBH����2303
	,sum(case when left(paytime,7)='2023-04' then SaleCount end ) as KBH����2304
	,sum(case when left(paytime,7)='2023-05' then SaleCount end ) as KBH����2305
	,sum(case when left(paytime,7)='2023-06' then SaleCount end ) as KBH����2306
	,sum(case when left(paytime,7)='2023-07' then SaleCount end ) as KBH����2307
	,sum(case when left(paytime,7)='2023-08' then SaleCount end ) as KBH����2308
	,sum(case when left(paytime,7)='2023-09' then SaleCount end ) as KBH����2309
	,sum(case when left(paytime,7)='2023-10' then SaleCount end ) as KBH����2310
	,sum(case when left(paytime,7)='2023-11' then SaleCount end ) as KBH����2311
	,sum(case when left(paytime,7)='2023-12' then SaleCount end ) as KBH����2312
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then salecount end ) as KBH������7
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then salecount end ) as KBH������8_14
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then salecount end ) as KBH������15_21
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then salecount end ) as KBH������22_28
-- 	,sum(case when left(paytime,4)='2021' then SaleCount end ) as KBH����21��
	
	,round(sum(case when left(paytime,7)='2022-01' then totalgross/exchangeUSD end )) as KBH���۶�2201
	,round(sum(case when left(paytime,7)='2022-02' then totalgross/exchangeUSD end )) as KBH���۶�2202
	,round(sum(case when left(paytime,7)='2022-03' then totalgross/exchangeUSD end )) as KBH���۶�2203
	,round(sum(case when left(paytime,7)='2022-04' then totalgross/exchangeUSD end )) as KBH���۶�2204
	,round(sum(case when left(paytime,7)='2022-05' then totalgross/exchangeUSD end )) as KBH���۶�2205
	,round(sum(case when left(paytime,7)='2022-06' then totalgross/exchangeUSD end )) as KBH���۶�2206
	,round(sum(case when left(paytime,7)='2022-07' then totalgross/exchangeUSD end )) as KBH���۶�2207
	,round(sum(case when left(paytime,7)='2022-08' then totalgross/exchangeUSD end )) as KBH���۶�2208
	,round(sum(case when left(paytime,7)='2022-09' then totalgross/exchangeUSD end )) as KBH���۶�2209
	,round(sum(case when left(paytime,7)='2022-10' then totalgross/exchangeUSD end )) as KBH���۶�2210
	,round(sum(case when left(paytime,7)='2022-11' then totalgross/exchangeUSD end )) as KBH���۶�2211
	,round(sum(case when left(paytime,7)='2022-12' then totalgross/exchangeUSD end )) as KBH���۶�2212
	,round(sum(case when left(paytime,7)='2023-01' then totalgross/exchangeUSD end )) as KBH���۶�2301
	,round(sum(case when left(paytime,7)='2023-02' then totalgross/exchangeUSD end )) as KBH���۶�2302
	,round(sum(case when left(paytime,7)='2023-03' then totalgross/exchangeUSD end )) as KBH���۶�2303
	,round(sum(case when left(paytime,7)='2023-04' then totalgross/exchangeUSD end )) as KBH���۶�2304
	,round(sum(case when left(paytime,7)='2023-05' then totalgross/exchangeUSD end )) as KBH���۶�2305
	,round(sum(case when left(paytime,7)='2023-06' then totalgross/exchangeUSD end )) as KBH���۶�2306
	,round(sum(case when left(paytime,7)='2023-07' then totalgross/exchangeUSD end )) as KBH���۶�2307
	,round(sum(case when left(paytime,7)='2023-08' then totalgross/exchangeUSD end )) as KBH���۶�2308
	,round(sum(case when left(paytime,7)='2023-09' then totalgross/exchangeUSD end )) as KBH���۶�2309
	,round(sum(case when left(paytime,7)='2023-10' then totalgross/exchangeUSD end )) as KBH���۶�2310
	,round(sum(case when left(paytime,7)='2023-11' then totalgross/exchangeUSD end )) as KBH���۶�2311
	,round(sum(case when left(paytime,7)='2023-12' then totalgross/exchangeUSD end )) as KBH���۶�2312
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalgross/exchangeUSD end )) as KBH���۶��7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalgross/exchangeUSD end )) as KBH���۶��8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalgross/exchangeUSD end )) as KBH���۶��15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalgross/exchangeUSD end )) as KBH���۶��22_28
-- 	,sum(case when left(paytime,4)='2021' then totalgross/exchangeUSD end ) as KBH���۶�21��

	,round(sum(case when left(paytime,7)='2022-01' then totalprofit/exchangeUSD end )) as KBH�����2201
	,round(sum(case when left(paytime,7)='2022-02' then totalprofit/exchangeUSD end )) as KBH�����2202
	,round(sum(case when left(paytime,7)='2022-03' then totalprofit/exchangeUSD end )) as KBH�����2203
	,round(sum(case when left(paytime,7)='2022-04' then totalprofit/exchangeUSD end )) as KBH�����2204
	,round(sum(case when left(paytime,7)='2022-05' then totalprofit/exchangeUSD end )) as KBH�����2205
	,round(sum(case when left(paytime,7)='2022-06' then totalprofit/exchangeUSD end )) as KBH�����2206
	,round(sum(case when left(paytime,7)='2022-07' then totalprofit/exchangeUSD end )) as KBH�����2207
	,round(sum(case when left(paytime,7)='2022-08' then totalprofit/exchangeUSD end )) as KBH�����2208
	,round(sum(case when left(paytime,7)='2022-09' then totalprofit/exchangeUSD end )) as KBH�����2209
	,round(sum(case when left(paytime,7)='2022-10' then totalprofit/exchangeUSD end )) as KBH�����2210
	,round(sum(case when left(paytime,7)='2022-11' then totalprofit/exchangeUSD end )) as KBH�����2211
	,round(sum(case when left(paytime,7)='2022-12' then totalprofit/exchangeUSD end )) as KBH�����2212
	,round(sum(case when left(paytime,7)='2023-01' then totalprofit/exchangeUSD end )) as KBH�����2301
	,round(sum(case when left(paytime,7)='2023-02' then totalprofit/exchangeUSD end )) as KBH�����2302
	,round(sum(case when left(paytime,7)='2023-03' then totalprofit/exchangeUSD end )) as KBH�����2303
	,round(sum(case when left(paytime,7)='2023-04' then totalprofit/exchangeUSD end )) as KBH�����2304
	,round(sum(case when left(paytime,7)='2023-05' then totalprofit/exchangeUSD end )) as KBH�����2305
	,round(sum(case when left(paytime,7)='2023-06' then totalprofit/exchangeUSD end )) as KBH�����2306
	,round(sum(case when left(paytime,7)='2023-07' then totalprofit/exchangeUSD end )) as KBH�����2307
	,round(sum(case when left(paytime,7)='2023-08' then totalprofit/exchangeUSD end )) as KBH�����2308
	,round(sum(case when left(paytime,7)='2023-09' then totalprofit/exchangeUSD end )) as KBH�����2309
	,round(sum(case when left(paytime,7)='2023-10' then totalprofit/exchangeUSD end )) as KBH�����2310
	,round(sum(case when left(paytime,7)='2023-11' then totalprofit/exchangeUSD end )) as KBH�����2311
	,round(sum(case when left(paytime,7)='2023-12' then totalprofit/exchangeUSD end )) as KBH�����2312
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalprofit/exchangeUSD end )) as KBH������7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalprofit/exchangeUSD end )) as KBH������8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalprofit/exchangeUSD end )) as KBH������15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalprofit/exchangeUSD end )) as KBH������22_28
-- 	,sum(case when left(paytime,4)='2021' then totalprofit/exchangeUSD end ) as KBH�����21��

    ,count( distinct case when left(paytime,7)='2022-05' then date(paytime) end ) as KBH��������2205
	,count( distinct case when left(paytime,7)='2022-06' then date(paytime) end ) as KBH��������2206
	,count( distinct case when left(paytime,7)='2022-07' then date(paytime) end ) as KBH��������2207
	,count( distinct case when left(paytime,7)='2022-08' then date(paytime) end ) as KBH��������2208
	,count( distinct case when left(paytime,7)='2022-09' then date(paytime) end ) as KBH��������2209
	,count( distinct case when left(paytime,7)='2022-10' then date(paytime) end ) as KBH��������2210
	,count( distinct case when left(paytime,7)='2022-11' then date(paytime) end ) as KBH��������2211
	,count( distinct case when left(paytime,7)='2022-12' then date(paytime) end ) as KBH��������2212

	,count( distinct case when left(paytime,7)='2023-01' then date(paytime) end ) as KBH��������2301
	,count( distinct case when left(paytime,7)='2023-02' then date(paytime) end ) as KBH��������2302
	,count( distinct case when left(paytime,7)='2023-03' then date(paytime) end ) as KBH��������2303
	,count( distinct case when left(paytime,7)='2023-04' then date(paytime) end ) as KBH��������2304
	,count( distinct case when left(paytime,7)='2023-05' then date(paytime) end ) as KBH��������2305
	,count( distinct case when left(paytime,7)='2023-06' then date(paytime) end ) as KBH��������2306
	,count( distinct case when left(paytime,7)='2023-07' then date(paytime) end ) as KBH��������2307
/*
	,count( distinct case when left(paytime,7)='2023-08' then date(paytime) end ) as KBH��������2308
	,count( distinct case when left(paytime,7)='2023-09' then date(paytime) end ) as KBH��������2309
	,count( distinct case when left(paytime,7)='2023-10' then date(paytime) end ) as KBH��������2310
	,count( distinct case when left(paytime,7)='2023-11' then date(paytime) end ) as KBH��������2311
	,count( distinct case when left(paytime,7)='2023-12' then date(paytime) end ) as KBH��������2312
 */

from od
group by targetsku ,isgroup
)

-- select * from orde where isgroup is  null 

,orde_tmh as (
select wo.BoxSku 
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as TMH������12����
	,sum(case when left(paytime,7)='2023-01' then SaleCount end ) as TMH����2301
	,sum(case when left(paytime,7)='2023-02' then SaleCount end ) as TMH����2302
	,sum(case when left(paytime,7)='2023-03' then SaleCount end ) as TMH����2303
	,sum(case when left(paytime,7)='2023-04' then SaleCount end ) as TMH����2304
	,sum(case when left(paytime,7)='2023-05' then SaleCount end ) as TMH����2305
	,sum(case when left(paytime,7)='2023-06' then SaleCount end ) as TMH����2306
	,sum(case when left(paytime,7)='2023-07' then SaleCount end ) as TMH����2307
	,sum(case when left(paytime,7)='2023-08' then SaleCount end ) as TMH����2308
	,sum(case when left(paytime,7)='2023-09' then SaleCount end ) as TMH����2309
	,sum(case when left(paytime,7)='2023-10' then SaleCount end ) as TMH����2310
	,sum(case when left(paytime,7)='2023-11' then SaleCount end ) as TMH����2311
	,sum(case when left(paytime,7)='2023-12' then SaleCount end ) as TMH����2312
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
where wo.IsDeleted = 0 and OrderStatus != '����'  and ms.Department = '������'
	and paytime >= '2023-01-01'
group by wo.BoxSku 
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
	,count(distinct case when NodePathName ='��Ӫ�ɶ�1��' then concat(shopcode,SellerSku) end ) `����������_��1`
	,count(distinct case when NodePathName ='��Ӫ�ɶ�2��' then concat(shopcode,SellerSku) end ) `����������_��2`
	,count(distinct case when NodePathName ='��Ӫ�ɶ�3��' then concat(shopcode,SellerSku) end ) `����������_��3`
	,count(distinct case when NodePathName ='��ӪȪ��1��' then concat(shopcode,SellerSku) end ) `����������_Ȫ1`
	,count(distinct case when NodePathName ='��ӪȪ��2��' then concat(shopcode,SellerSku) end ) `����������_Ȫ2`
	,count(distinct case when NodePathName ='��ӪȪ��3��' then concat(shopcode,SellerSku) end ) `����������_Ȫ3`
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
		,wp.projectteam `��Ʒ���������`
		,wp.ori_boxsku  `Դboxsku���и��ƹ�ϵ��`
		,wp.ori_team `Դboxsku��������`
		,case when coalesce(orde.isgroup,orde2.isgroup) is null then '��ٻ��˺�(���˻�)�޶�����¼' else orde.isgroup end as `�Ƿ���ϳ���`
		,ware.BoxSku `�п��boxsku`
	 	,case when wp.ProductStatus =  0 then '����'
	 			when wp.ProductStatus = 2 then 'ͣ��'
	 			when wp.ProductStatus = 3 then 'ͣ��'
	 			when wp.ProductStatus = 4 then '��ʱȱ��'
	 			when wp.ProductStatus = 5 then '���'
	 	end as  `��Ʒ״̬`
	 	,wp.ChangeReasons `ͣ��ԭ��`
	 	,wp.TortType `��Ȩ����`
	 	
	 	,round(timestampdiff(second,wp.DevelopLastAuditTime,CURRENT_DATE())/86400/30)  `����������_��30��`
		,ifnull(orde.KBH������12����,0) + ifnull(orde2.KBH������12����,0) as KBH������12����
		,TMH������12����
		,ifnull(orde.KBH����22������,0) + ifnull(orde2.KBH����22������,0) as KBH����22������
	
		,ifnull(orde.KBH����2201,0) + ifnull(orde2.KBH����2201,0) as KBH����2201
		,ifnull(orde.KBH����2202,0) + ifnull(orde2.KBH����2202,0) as KBH����2202
		,ifnull(orde.KBH����2203,0) + ifnull(orde2.KBH����2203,0) as KBH����2203
		,ifnull(orde.KBH����2204,0) + ifnull(orde2.KBH����2204,0) as KBH����2204
		,ifnull(orde.KBH����2205,0) + ifnull(orde2.KBH����2205,0) as KBH����2205
		,ifnull(orde.KBH����2206,0) + ifnull(orde2.KBH����2206,0) as KBH����2206
		,ifnull(orde.KBH����2207,0) + ifnull(orde2.KBH����2207,0) as KBH����2207
		,ifnull(orde.KBH����2208,0) + ifnull(orde2.KBH����2208,0) as KBH����2208
		,ifnull(orde.KBH����2209,0) + ifnull(orde2.KBH����2209,0) as KBH����2209
		,ifnull(orde.KBH����2210,0) + ifnull(orde2.KBH����2210,0) as KBH����2210
		,ifnull(orde.KBH����2211,0) + ifnull(orde2.KBH����2211,0) as KBH����2211
		,ifnull(orde.KBH����2212,0) + ifnull(orde2.KBH����2212,0) as KBH����2212
		,ifnull(orde.KBH����2301,0) + ifnull(orde2.KBH����2301,0) as KBH����2301
		,ifnull(orde.KBH����2302,0) + ifnull(orde2.KBH����2302,0) as KBH����2302
		,ifnull(orde.KBH����2303,0) + ifnull(orde2.KBH����2303,0) as KBH����2303
		,ifnull(orde.KBH����2304,0) + ifnull(orde2.KBH����2304,0) as KBH����2304
		,ifnull(orde.KBH����2305,0) + ifnull(orde2.KBH����2305,0) as KBH����2305
		,ifnull(orde.KBH����2306,0) + ifnull(orde2.KBH����2306,0) as KBH����2306
		,ifnull(orde.KBH����2307,0) + ifnull(orde2.KBH����2307,0) as KBH����2307
		,ifnull(orde.KBH����2308,0) + ifnull(orde2.KBH����2308,0) as KBH����2308
		,ifnull(orde.KBH����2309,0) + ifnull(orde2.KBH����2309,0) as KBH����2309
		,ifnull(orde.KBH����2310,0) + ifnull(orde2.KBH����2310,0) as KBH����2310
		,ifnull(orde.KBH����2311,0) + ifnull(orde2.KBH����2311,0) as KBH����2311
		,ifnull(orde.KBH����2312,0) + ifnull(orde2.KBH����2312,0) as KBH����2312
		, TMH����2301
		, TMH����2302
		, TMH����2303
		, TMH����2304
		, TMH����2305
		, TMH����2306
		, TMH����2307
		, TMH����2308
		, TMH����2309
		, TMH����2310
		, TMH����2311
		, TMH����2312
		
		,ifnull(orde.KBH���۶�2201,0) + ifnull(orde2.KBH���۶�2201,0) as KBH���۶�2201
		,ifnull(orde.KBH���۶�2202,0) + ifnull(orde2.KBH���۶�2202,0) as KBH���۶�2202
		,ifnull(orde.KBH���۶�2203,0) + ifnull(orde2.KBH���۶�2203,0) as KBH���۶�2203
		,ifnull(orde.KBH���۶�2204,0) + ifnull(orde2.KBH���۶�2204,0) as KBH���۶�2204
		,ifnull(orde.KBH���۶�2205,0) + ifnull(orde2.KBH���۶�2205,0) as KBH���۶�2205
		,ifnull(orde.KBH���۶�2206,0) + ifnull(orde2.KBH���۶�2206,0) as KBH���۶�2206
		,ifnull(orde.KBH���۶�2207,0) + ifnull(orde2.KBH���۶�2207,0) as KBH���۶�2207
		,ifnull(orde.KBH���۶�2208,0) + ifnull(orde2.KBH���۶�2208,0) as KBH���۶�2208
		,ifnull(orde.KBH���۶�2209,0) + ifnull(orde2.KBH���۶�2209,0) as KBH���۶�2209
		,ifnull(orde.KBH���۶�2210,0) + ifnull(orde2.KBH���۶�2210,0) as KBH���۶�2210
		,ifnull(orde.KBH���۶�2211,0) + ifnull(orde2.KBH���۶�2211,0) as KBH���۶�2211
		,ifnull(orde.KBH���۶�2212,0) + ifnull(orde2.KBH���۶�2212,0) as KBH���۶�2212
		,ifnull(orde.KBH���۶�2301,0) + ifnull(orde2.KBH���۶�2301,0) as KBH���۶�2301
		,ifnull(orde.KBH���۶�2302,0) + ifnull(orde2.KBH���۶�2302,0) as KBH���۶�2302
		,ifnull(orde.KBH���۶�2303,0) + ifnull(orde2.KBH���۶�2303,0) as KBH���۶�2303
		,ifnull(orde.KBH���۶�2304,0) + ifnull(orde2.KBH���۶�2304,0) as KBH���۶�2304
		,ifnull(orde.KBH���۶�2305,0) + ifnull(orde2.KBH���۶�2305,0) as KBH���۶�2305
		,ifnull(orde.KBH���۶�2306,0) + ifnull(orde2.KBH���۶�2306,0) as KBH���۶�2306
		,ifnull(orde.KBH���۶�2307,0) + ifnull(orde2.KBH���۶�2307,0) as KBH���۶�2307
		,ifnull(orde.KBH���۶�2308,0) + ifnull(orde2.KBH���۶�2308,0) as KBH���۶�2308
		,ifnull(orde.KBH���۶�2309,0) + ifnull(orde2.KBH���۶�2309,0) as KBH���۶�2309
		,ifnull(orde.KBH���۶�2310,0) + ifnull(orde2.KBH���۶�2310,0) as KBH���۶�2310
		,ifnull(orde.KBH���۶�2311,0) + ifnull(orde2.KBH���۶�2311,0) as KBH���۶�2311
		,ifnull(orde.KBH���۶�2312,0) + ifnull(orde2.KBH���۶�2312,0) as KBH���۶�2312
		
		,ifnull(orde.KBH�����2201,0) + ifnull(orde2.KBH�����2201,0) as KBH�����2201
		,ifnull(orde.KBH�����2202,0) + ifnull(orde2.KBH�����2202,0) as KBH�����2202
		,ifnull(orde.KBH�����2203,0) + ifnull(orde2.KBH�����2203,0) as KBH�����2203
		,ifnull(orde.KBH�����2204,0) + ifnull(orde2.KBH�����2204,0) as KBH�����2204
		,ifnull(orde.KBH�����2205,0) + ifnull(orde2.KBH�����2205,0) as KBH�����2205
		,ifnull(orde.KBH�����2206,0) + ifnull(orde2.KBH�����2206,0) as KBH�����2206
		,ifnull(orde.KBH�����2207,0) + ifnull(orde2.KBH�����2207,0) as KBH�����2207
		,ifnull(orde.KBH�����2208,0) + ifnull(orde2.KBH�����2208,0) as KBH�����2208
		,ifnull(orde.KBH�����2209,0) + ifnull(orde2.KBH�����2209,0) as KBH�����2209
		,ifnull(orde.KBH�����2210,0) + ifnull(orde2.KBH�����2210,0) as KBH�����2210
		,ifnull(orde.KBH�����2211,0) + ifnull(orde2.KBH�����2211,0) as KBH�����2211
		,ifnull(orde.KBH�����2212,0) + ifnull(orde2.KBH�����2212,0) as KBH�����2212
		,ifnull(orde.KBH�����2301,0) + ifnull(orde2.KBH�����2301,0) as KBH�����2301
		,ifnull(orde.KBH�����2302,0) + ifnull(orde2.KBH�����2302,0) as KBH�����2302
		,ifnull(orde.KBH�����2303,0) + ifnull(orde2.KBH�����2303,0) as KBH�����2303
		,ifnull(orde.KBH�����2304,0) + ifnull(orde2.KBH�����2304,0) as KBH�����2304
		,ifnull(orde.KBH�����2305,0) + ifnull(orde2.KBH�����2305,0) as KBH�����2305
		,ifnull(orde.KBH�����2306,0) + ifnull(orde2.KBH�����2306,0) as KBH�����2306
		,ifnull(orde.KBH�����2307,0) + ifnull(orde2.KBH�����2307,0) as KBH�����2307
		,ifnull(orde.KBH�����2308,0) + ifnull(orde2.KBH�����2308,0) as KBH�����2308
		,ifnull(orde.KBH�����2309,0) + ifnull(orde2.KBH�����2309,0) as KBH�����2309
		,ifnull(orde.KBH�����2310,0) + ifnull(orde2.KBH�����2310,0) as KBH�����2310
		,ifnull(orde.KBH�����2311,0) + ifnull(orde2.KBH�����2311,0) as KBH�����2311
		,ifnull(orde.KBH�����2312,0) + ifnull(orde2.KBH�����2312,0) as KBH�����2312

        , orde.KBH��������2205
        , orde.KBH��������2206
        , orde.KBH��������2207
        , orde.KBH��������2208
        , orde.KBH��������2209
        , orde.KBH��������2210
        , orde.KBH��������2211
        , orde.KBH��������2212
        , orde.KBH��������2301
        , orde.KBH��������2302
        , orde.KBH��������2303
        , orde.KBH��������2304
        , orde.KBH��������2305
        , orde.KBH��������2306
        , orde.KBH��������2307


		,ifnull(orde.KBH������7,0) + ifnull(orde2.KBH������7,0) as KBH������7
		,ifnull(orde.KBH������8_14,0) + ifnull(orde2.KBH������8_14,0) as KBH������8_14
		,ifnull(orde.KBH������15_21,0) + ifnull(orde2.KBH������15_21,0) as KBH������15_21
		,ifnull(orde.KBH������22_28,0) + ifnull(orde2.KBH������22_28,0) as KBH������22_28
		
		,ifnull(orde.KBH���۶��7,0) + ifnull(orde2.KBH���۶��7,0) as KBH���۶��7
		,ifnull(orde.KBH���۶��8_14,0) + ifnull(orde2.KBH���۶��8_14,0) as KBH���۶��8_14
		,ifnull(orde.KBH���۶��15_21,0) + ifnull(orde2.KBH���۶��15_21,0) as KBH���۶��15_21
		,ifnull(orde.KBH���۶��22_28,0) + ifnull(orde2.KBH���۶��22_28,0) as KBH���۶��22_28
		
		,ifnull(orde.KBH������7,0) + ifnull(orde2.KBH������7,0) as KBH������7
		,ifnull(orde.KBH������8_14,0) + ifnull(orde2.KBH������8_14,0) as KBH������8_14
		,ifnull(orde.KBH������15_21,0) + ifnull(orde2.KBH������15_21,0) as KBH������15_21
		,ifnull(orde.KBH������22_28,0) + ifnull(orde2.KBH������22_28,0) as KBH������22_28
			
		,`����������`
	 	,`����������_��1` 
	 	,`����������_��2` 
	 	,`����������_��3`
	 	,`����������_Ȫ1`
	 	,`����������_Ȫ2` 
	 	,`����������_Ȫ3` 
	 	
	 	,round(timestampdiff(second,wp.DevelopLastAuditTime,CURRENT_DATE())/86400)  `����������`
	 	,wp.DevelopLastAuditTime `����ʱ��`
		,wp.ProductName `��Ʒ��` 
	 	,IsPackage `�Ƿ����`
	 	,AverageUnitPrice `ƽ������`
	 	,TotalInventory `���������`
	 	,TotalPrice `����ܽ��`
	 	,InventoryAge45 `0-45�������`
	 	,InventoryAge90 `46-90�������`
	 	,InventoryAge180 `91-180�������`
	 	,InventoryAge270 `181-270�������`
	 	,InventoryAge365 `271-365�������`
	 	,InventoryAgeOver `����365�������`
	 	,max_InstockTime `���ɹ������`
	 	,datediff(CURRENT_DATE(),max_InstockTime) `���ɹ����������` 
	from 
		( select wp.* ,rela.ori_boxsku ,rela.ori_team
		from import_data.wt_products wp
		left join rela on wp.BoxSku = rela.new_boxsku  
		) wp 
	left join ware on ware.BoxSku = wp.boxsku
	left join orde on orde.BoxSku = wp.boxsku -- ��Ʒ�������ٻ������ۣ���ٻ��˺ų���
	left join orde orde2 on orde2.BoxSku = wp.ori_boxsku -- ��Ʒ������������ţ���ٻ��˺ų���
	left join orde_tmh on orde_tmh.BoxSku = wp.boxsku
	left join inst on inst.BoxSku = wp.boxsku
	left join list on list.BoxSku = wp.boxsku
	where  wp.DevelopLastAuditTime is not null 
		and wp.projectteam = '��ٻ�' -- ��ʱ���� ���ƹ�ϵ
		and wp.BoxSku is not null 
) 


, t_add as (
select 
	case 
		when ��Ʒ״̬ = 'ͣ��' then 'ͣ��'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and ( �����ܶԱ�ǰ������������ = '>-10' or (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '>40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and ( �����ܶԱ�ǰ������������ = '>-10' or (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '<40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and �����ܶԱ�ǰ������������ = '<-10' and ��4���ۼ������ж� = '>40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and �����ܶԱ�ǰ������������ = '<-10' and ��4���ۼ������ж� = '<40' then 'ƽ����'
		
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and �����ܶԱ�ǰ������������ = '<2' and (KBH������8_14 + KBH������7) > 5  then 'Ǳ����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and �����ܶԱ�ǰ������������ = '<2' and ��4���ۼ������ж� = '' then 'ƽ����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and �����ܶԱ�ǰ������������ = '>2' and ��4���ۼ������ж� = '' then 'Ǳ����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '0-5' and �����ܶԱ�ǰ������������ = '' and ��4���ۼ������ж� = '' then '����'
		
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '0-5' and �����ܶԱ�ǰ������������ = '' and ��4���ۼ������ж� = '' then '��Ʒ'
		when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and �ۼƳ������� = '5-30' and ( �����ܶԱ�ǰ������������ = '>2' or  (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '' then 'Ǳ����'
		when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and �ۼƳ������� = '5-30' and �����ܶԱ�ǰ������������ = '<2' and ��4���ۼ������ж� = '' then 'ƽ����'
		when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and �ۼƳ������� = '1-5' and �����ܶԱ�ǰ������������ = '' and ��4���ۼ������ж� = '' then 'ƽ����'
		when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and �ۼƳ������� = '0' and �����ܶԱ�ǰ������������ = '' and ��4���ۼ������ж� = '' then '����'
		
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and ( �����ܶԱ�ǰ������������ = '>-10' or (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '>40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and ( �����ܶԱ�ǰ������������ = '>-10' or (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '<40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and �����ܶԱ�ǰ������������ = '<-10' and ��4���ۼ������ж� = '>40' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '>30' and �����ܶԱ�ǰ������������ = '<-10' and ��4���ۼ������ж� = '<40' then 'ƽ����'

		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '0-5' and �����ܶԱ�ǰ������������ = '' and ��4���ۼ������ж� = '' then '����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and ( �����ܶԱ�ǰ������������ = '>2' or  (KBH������8_14 + KBH������7) > 5 ) and ��4���ۼ������ж� = '' then 'Ǳ����'
		when ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and �����ܶԱ�ǰ������������ = '<2' and ��4���ۼ������ж� = '' then 'ƽ����'
	end ��Ʒ�ֲ�
	,*
from (
	select 
		case 
			when �������� = '�ɳ���' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) > 2 and KBH������12���� >5 then '>2'
			when �������� = '�ɳ���' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) <= 2 and KBH������12���� >5 then '<2'
			when �������� = '������' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) > -10 
				and KBH������12���� >30 and (KBH������8_14 + KBH������7) > 0 then '>-10'
			when �������� = '������' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) > -10 
				and KBH������12���� >30 and (KBH������8_14 + KBH������7) = 0 then '<-10'
			when �������� = '������' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) <= -10 
				and KBH������12���� >30 then '<-10'
			when �������� = '������' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) > 2 
				and �ۼƳ������� = '5-30' then '>2'
			when �������� = '������' and (KBH������8_14 + KBH������7) - (KBH������22_28 + KBH������15_21) <= 2 
				and �ۼƳ������� = '5-30' then '<2'
			else ''
		end �����ܶԱ�ǰ������������
		,case 
			when �������� = '������' and KBH������12���� > 30 and (KBH������22_28 + KBH������15_21 + KBH������8_14 + KBH������7) > 40 then '>40'
			when �������� = '������' and KBH������12���� > 30 and (KBH������22_28 + KBH������15_21 + KBH������8_14 + KBH������7) <= 40 then '<40'
			else ''
		end ��4���ۼ������ж�
		,*   
	from (
		select 
			case when ����Ʒ = '��Ʒ' and KBH������12���� >30 then '>30'
				when ����Ʒ = '��Ʒ' and KBH������12���� >5 then '5-30'
				when ����Ʒ = '��Ʒ' then '0-5'
				when ����Ʒ = '��Ʒ' and �������� = '������' and KBH������12���� >30 then '>30'
				when ����Ʒ = '��Ʒ' and �������� = '������' and KBH������12���� >5 then '5-30'
				when ����Ʒ = '��Ʒ' and �������� = '������' then '0-5'
				when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and KBH������12���� >5 then '5-30'
				when ����Ʒ = '��Ʒ' and �������� = '�ɳ���' and KBH������12���� >0 then '1-5'
				when ����Ʒ = '��Ʒ' and �������� = '������' then '0-5'
				else 0
			end as �ۼƳ�������
			,*
		from (
			select 
				case when kbh������12���� <=5 and ����������_��30�� <=1 then '������'
					when kbh������12���� <=30 and ����������_��30�� <3 then '�ɳ���'
					else '������'
				end ��������
				,case when year(����ʱ��) >= 2023 then '��Ʒ' else '��Ʒ'  end as `����Ʒ`
				,*
			from t_merge
			) ta
		) tb 
	) tc
)

select * from t_add 
-- select ��Ʒ�ֲ�  from t_add 
-- where ����Ʒ = '��Ʒ' and �������� = '������' and �ۼƳ������� = '5-30' and (KBH������8_14 + KBH������7) > 5 group by ��Ʒ�ֲ�

-- select count(1) from t_add where ��Ʒ�ֲ� <> 'ͣ��'

-- 	select 
-- 	-- 	count(����������_��30��)
-- 	-- 	,count(KBH������12����)
-- 	-- 	,count(��������)
-- 	-- 	,count(����Ʒ)
-- 	-- 	,count(�����ܶԱ�ǰ������������)
-- 	-- 	,count(��4���ۼ������ж�)
-- 	-- 	,count(��Ʒ�ֲ�) 
-- 		��Ʒ�ֲ� ,count(1) 
-- 	from t_add
-- 	group by ��Ʒ�ֲ�
	-- ) tmp 