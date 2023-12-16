/*��Ʒ����������2��1����*/

with 
-- step1 ����Դ����
t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku 
)


,t_prod as (
select ta.* ,tb.TortType
from (
	select wp.Spu ,wp.SKU ,BoxSku ,DevelopUserName 
		,date_add(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
		,Cat1 ,Cat2 ,ProductName ,CreationTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		,t_elem.ele 
	from import_data.wt_products wp 
	left join t_elem on wp.sku =t_elem.sku 
	where IsDeleted =0 and date_add(DevelopLastAuditTime,interval - 8 hour) >= '2023-02-01' and ProjectTeam='��ٻ�'
	) ta
left join (
	select SKU ,group_concat(case when TortType is null then 'δ���' else TortType end ) TortType from import_data.wt_products 
	where IsDeleted =0 and date_add(DevelopLastAuditTime,interval - 8 hour) >= '2023-02-01' and ProjectTeam='��ٻ�' 
	group by SKU
	) tb
	on ta.SKU = tb.SKU
)


,t_copy_new_pp as ( -- 2�¸��Ʋ�Ʒ����Ʒ
select eppcr.NewProdId, null spu ,epp.sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr .NewProdId = epp.Id 
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.sku
union 
select eppcr.NewProdId, epp.spu ,null sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =1 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.spu
)


,t_orde as (  -- ÿ�ܳ�����ϸ
select 
	OrderNumber ,PlatOrderNumber ,wo.Market	
	,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
-- 	and paytime >= '2023-02-01'
	and paytime >= '${PayStartDay}'and paytime <'${NextStartDay}'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
) 

,t_list as ( -- ��������
select wl.BoxSku ,wl.SKU ,MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,WEEKOFYEAR( MinPublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from wt_listing wl -- ��Ϊ��������䵽����sku,���Բ���Ҫʹ��erp��
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on t_prod.sku = wl.SKU 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
	and SellerSku not regexp 'bJ|Bj|bj|BJ'
)
-- select * from t_list

,t_onway_sku  as (
select boxsku
-- 	, sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����CNY` 
-- 	, ROUND(ifnull(sum(SkuFreight),0),2) `��;��Ʒ��̯�˷�CNY`
	,ifnull(sum(Quantity),0) `��;SKU����`
from (
	select Price ,DiscountedPrice , SkuFreight ,boxsku,Quantity
	from wt_purchaseorder wp 
	where ordertime < '${NextStartDay}' and ordertime >= '2023-01-01'
		and isOnWay = "��" and WarehouseName = '��ݸ��' 
	) tmp	
group by boxsku 
)

,t_instock_sku as (
SELECT boxsku
-- 	,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���CNY`
	,sum(ifnull(TotalInventory,0)) `�ڲ�sku����`
-- 	,count(*) `�ڲ�sku��` 
FROM ( -- local_warehouse ���زֱ�
	select TotalPrice, TotalInventory ,boxsku
	FROM import_data.daily_WarehouseInventory wi
	where WarehouseName = '��ݸ��' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
	)  tmp 
group by boxsku 
)

,t_list_stat as ( -- ��1 ���Ǽ���
select BoxSKU 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ3` 
	,min(MinPublicationDate) `�״ο���ʱ��`
from t_list
group by BoxSKU  
)
-- select * from t_list_stat where boxsku = 4478758

,t_ad as ( 
select t_list.boxsku, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
	, DevelopLastAuditTime
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- ���
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '2023-02-01'
)

,t_ad_stat as (
select tmp.* 
	, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `����30������`
	, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `����30����ת����`
from 
	( select boxsku
		-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
		-- ����	
		, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by boxsku
	) tmp
)


,t_sale_stat as (
select BoxSKU 
	,round(sum(TotalGross/ExchangeUSD)) `���۶�` 
	,round(sum(case when NodePathName ='���Ԫ-�ɶ�������' then TotalGross/ExchangeUSD end )) `���۶�_��1` 
	,round(sum(case when NodePathName ='��η�-�ɶ�������' then TotalGross/ExchangeUSD end )) `���۶�_��2` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��1��' then TotalGross/ExchangeUSD end )) `���۶�_Ȫ1` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��2��' then TotalGross/ExchangeUSD end )) `���۶�_Ȫ2` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��3��' then TotalGross/ExchangeUSD end )) `���۶�_Ȫ3` 
	
	,round(sum(TotalProfit/ExchangeUSD)) `�����` 
	,round(sum(case when NodePathName ='���Ԫ-�ɶ�������' then TotalProfit/ExchangeUSD end )) `�����_��1` 
	,round(sum(case when NodePathName ='��η�-�ɶ�������' then TotalProfit/ExchangeUSD end )) `�����_��2` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��1��' then TotalProfit/ExchangeUSD end )) `�����_Ȫ1` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��2��' then TotalProfit/ExchangeUSD end )) `�����_Ȫ2` 
	,round(sum(case when NodePathName ='��Ӫ��-Ȫ��3��' then TotalProfit/ExchangeUSD end )) `�����_Ȫ3` 
	
	,sum(salecount) `����SKU����` 
	,sum( case when NodePathName ='���Ԫ-�ɶ�������' then salecount end ) `����SKU����_��1` 
	,sum( case when NodePathName ='��η�-�ɶ�������' then salecount end ) `����SKU����_��2` 
	,sum( case when NodePathName ='��Ӫ��-Ȫ��1��' then salecount end ) `����SKU����_Ȫ1` 
	,sum( case when NodePathName ='��Ӫ��-Ȫ��2��' then salecount end ) `����SKU����_Ȫ2` 
	,sum( case when NodePathName ='��Ӫ��-Ȫ��3��' then salecount end ) `����SKU����_Ȫ3` 

	,count(distinct PlatOrderNumber) `������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  PlatOrderNumber end ) `������_��1`
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  PlatOrderNumber end ) `������_��2`
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then  PlatOrderNumber end ) `������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then  PlatOrderNumber end ) `������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then  PlatOrderNumber end ) `������_Ȫ3` 

	,count(distinct concat(shopcode,sellersku) ) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��1`
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��2`
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then  concat(shopcode,sellersku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then  concat(shopcode,sellersku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then  concat(shopcode,sellersku) end ) `����������_Ȫ3` 

	,count(distinct Market ) `�����г���` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  Market end ) `�����г���_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  Market end ) `�����г���_��2` 
	,count(distinct case when NodePathName ='���Ԫ-Ȫ��1��' then  Market end ) `�����г���_Ȫ1` 
	,count(distinct case when NodePathName ='���Ԫ-Ȫ��2��' then  Market end ) `�����г���_Ȫ2` 
	,count(distinct case when NodePathName ='���Ԫ-Ȫ��3��' then  Market end ) `�����г���_Ȫ3` 

	
	,if('${PayStartDay}'= date_add(CURRENT_DATE(),-1),'���ۼƳ�����', to_date(min(PayTime))) `�״γ���ʱ��`
from t_orde
group by BoxSKU
)

-- select NodePathName from mysql_store ms  group by NodePathName

-- select * from t_sale_stat
-- 
-- -- ��1 sku��ϸ���
-- select count(1) from (
 
select 
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,t_prod.ele `Ԫ��`
	,t_prod.cat1 `һ����Ŀ`
	,t_prod.spu 
	,t_prod.sku
	,t_prod.boxsku
	,t_prod.ProductStatus `��Ʒ״̬`
	,t_prod.TortType `��Ȩ״̬`
	,t_prod.ProductName
	,t_prod.DevelopUserName `������Ա`
	,to_date(t_prod.DevelopLastAuditTime) `����ʱ��`
	,to_date(t_prod.CreationTime) `��Ʒ���ʱ��`
	, `���۶�`
	, `���۶�_��1` 
	, `���۶�_��2` 
	, `���۶�_Ȫ1` 
	, `���۶�_Ȫ2` 
	, `���۶�_Ȫ3` 
	
	,`�����`
	,`�����_��1` 
	,`�����_��2` 
	,`�����_Ȫ1` 
	,`�����_Ȫ2` 
	,`�����_Ȫ3` 
	
	,`������`
	,`������_��1` 
	,`������_��2` 
	,`������_Ȫ1` 
	,`������_Ȫ2` 
	,`������_Ȫ3` 
	
	,`����SKU����`
	,`����SKU����_��1` 
	,`����SKU����_��2` 
	,`����SKU����_Ȫ1` 
	,`����SKU����_Ȫ2` 
	,`����SKU����_Ȫ3` 
	
	,`����������`
	,`����������_��1`
	,`����������_��2`
	,`����������_Ȫ1` 
	,`����������_Ȫ2` 
	,`����������_Ȫ3` 

	,`����������`
	,`����������_��1` 
	,`����������_��2` 
	,`����������_Ȫ1`
	,`����������_Ȫ2` 
	,`����������_Ȫ3` 

	,`�����г���`
	,`�����г���_��1`
	,`�����г���_��2`
	,`�����г���_Ȫ1` 
	,`�����г���_Ȫ2` 
	,`�����г���_Ȫ3` 

	,`�״γ���ʱ��`
	,to_date(`�״ο���ʱ��`) `�״ο���ʱ��`
	,ad30_sku_Exposure `����30���ع�`
	,ad30_sku_Clicks `����30����`
	,`����30������`
	,`��;SKU����`
	,`�ڲ�SKU����`
-- 	,`��;��Ʒ�ɹ����CNY` 
-- 	,`��;��Ʒ��̯�˷�CNY`
-- 	, `�ڲֲ�Ʒ���CNY`

from t_prod
left join t_sale_stat on t_prod.boxsku =t_sale_stat.boxsku
left join t_list_stat on t_prod.boxsku =t_list_stat.boxsku
left join t_ad_stat on t_prod.boxsku =t_ad_stat.boxsku
left join t_onway_sku on t_prod.boxsku =t_onway_sku.boxsku
left join t_instock_sku on t_prod.boxsku =t_instock_sku.boxsku
-- where t_prod.CreationTime >= '2023-01-01'  
-- where t_prod.boxsku =4747105 

-- ) tmp 