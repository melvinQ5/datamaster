-- SELECT COUNT(1) FROM (

select js.spu ,js.sku ,js.boxsku , js.ProjectTeam , rela.PlatformSku as `����sku` ,rela.ShopCode 
	,`boxsku��Ӧ������` ,`ͳ������������ʱ��`,`��Ʒ״̬`
	,wp.Festival
from (select spu, sku ,boxsku ,ProjectTeam 
		, case when ProductStatus = 0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as `��Ʒ״̬`
	from import_data.erp_product_products epp 
	where ProjectTeam  <> '��ٻ�' and IsMatrix = 0 and IsDeleted =0
	group by spu, sku ,boxsku ,ProjectTeam  ,`��Ʒ״̬`
	) js 
left join ( -- ERP����������������Դ����� ������������ҳ��+����ѷAPI
	select BoxSku , PlatformSku ,ShopCode
	from import_data.erp_amazon_amazon_channelskus eaac 
	group by BoxSku , PlatformSku ,ShopCode
	) rela
	on js.BoxSku=rela.BoxSku
left join (
	select boxsku ,count(distinct platordernumber) `boxsku��Ӧ������`  --������δ����������
		, max(paytime) `ͳ������������ʱ��`
	from wt_orderdetails wo where IsDeleted =0 and paytime  < '${NextStartDay}' and paytime >= '${StartDay}'
	group by boxsku
	) od 
	on js.BoxSku=od.BoxSku
left join (
	select sku,Festival
	from import_data.wt_products wp 
	where isdeleted = 0 
	) wp on js.sku = wp.sku -- ��Ԫ�ر�ǩ�����ȶ���ֱ��ʹ��wt��

-- ) TMP 
	
-- with
-- kbh_sellersku as (
-- select js.BoxSku ,rela.cnt `��ٻ�����SKU��������`
-- from 
-- (select BoxSku from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js
-- left join (
-- 	select BoxSku , count(1) cnt
-- 	from ( 
-- 		select BoxSku , PlatformSku 
-- 		from import_data.erp_amazon_amazon_channelskus eaac 
-- 		group by BoxSku , PlatformSku 
-- 		) tmp
-- 	group by BoxSku 
-- ) rela
-- on js.BoxSku=rela.BoxSku
-- )
-- 
-- , kbh_listing_cnt as (
-- select SKU , count(1) `��ٻ�������������`
-- from (
-- select js.SKU , eaal.Id 
-- from import_data.erp_amazon_amazon_listing eaal 
-- join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaal.SKU = js.SKU and ListingStatus = 1
-- join import_data.mysql_store ms on ms.Code =eaal.ShopCode and ms.ShopStatus = '����'
-- group by js.SKU , eaal.Id 
-- ) tmo 
-- group by SKU
-- )
-- 
-- 
-- SELECT  SKU , BoxSku ,department
-- 	,`��ٻ�����SKU��������`, `��ٻ�������������`
-- 	, case when `��ٻ��״ο���ʱ��_ɾ����` is not null then `��ٻ��״ο���ʱ��_ɾ����` else `��ٻ��״ο���ʱ��_δɾ����` end as `��ٻ��״ο���ʱ��`
-- 	, case when `�������״ο���ʱ��_ɾ����` is not null then `�������״ο���ʱ��_ɾ����` else `�������״ο���ʱ��_δɾ����` end as `�������״ο���ʱ��`
-- FROM ( 
-- 
-- select js.SKu ,js.boxsku ,js.department 
-- 	,kbh_sellersku.`��ٻ�����SKU��������`
-- 	,kbh_listing_cnt.`��ٻ�������������`
-- 	,kbh_listing_fristtime_delete.`��ٻ��״ο���ʱ��_ɾ����`
-- 	,kbh_listing_fristtime_nodelete.`��ٻ��״ο���ʱ��_δɾ����`
-- 	,tmh_listing_fristtime_delete.`�������״ο���ʱ��_ɾ����`
-- 	,tmh_listing_fristtime_nodelete.`�������״ο���ʱ��_δɾ����`
-- from 
-- 	(select SKu,boxsku,SPU as department from import_data.JinqinSku where Monday ='2099-01-01' and SPU in ('GM','PM')) js
-- left join kbh_sellersku on js.BoxSku = kbh_sellersku.BoxSku
-- left join kbh_listing_cnt on js.SKU = kbh_listing_cnt.SKU
-- left join 
-- 	(  -- ��ٻ������״ο���ʱ��
-- 	select js.SKU , min(eaald.PublicationDate) `��ٻ��״ο���ʱ��_ɾ����`
-- 	from import_data.erp_amazon_amazon_listing_delete eaald
-- 	join (select SKU from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaald.SKU = js.SKU 
-- 	group by js.SKU
-- 	) kbh_listing_fristtime_delete
-- 	on js.SKU = kbh_listing_fristtime_delete.SKU
-- left join 
-- 	(
-- 	select js.SKU , min(eaal.PublicationDate) `��ٻ��״ο���ʱ��_δɾ����`
-- 	from import_data.erp_amazon_amazon_listing eaal
-- 	join (select SKU from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaal.SKU = js.SKU 
-- 	group by js.SKU
-- 	) kbh_listing_fristtime_nodelete
-- 	on js.SKU = kbh_listing_fristtime_nodelete.SKU
-- 	
-- left join 
-- 	(  -- �����������״ο���ʱ��
-- 	select js.SKU , min(eaald.PublicationDate) `�������״ο���ʱ��_ɾ����`
-- 	from import_data.erp_amazon_amazon_listing_delete eaald
-- 	join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='GM') js 
-- 		on eaald.SKU = js.SKU 
-- 	group by js.SKU
-- 	) tmh_listing_fristtime_delete
-- 	on js.SKU = tmh_listing_fristtime_delete.SKU
-- left join 
-- 	(
-- 	select js.SKU , min(eaal.PublicationDate) `�������״ο���ʱ��_δɾ����`
-- 	from import_data.erp_amazon_amazon_listing eaal
-- 	join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='GM') js on eaal.SKU = js.SKU 
-- 	group by js.SKU
-- 	) tmh_listing_fristtime_nodelete
-- 	on js.SKU = tmh_listing_fristtime_nodelete.SKU
-- 	
-- 
-- ) TMP
-- 
-- 
	