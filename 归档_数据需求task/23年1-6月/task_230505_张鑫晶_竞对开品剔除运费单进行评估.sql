-- 3�����������Ʒ��������ƽ���͵���


with epp as ( -- sku 
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-05-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�' and Status != 20
group by SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)
)
-- select * from epp where sku =  5211271.01

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join epp on eppaea.sku = epp.sku 
group by eppaea.sku 
)

-- ,t_list as ( -- ����ʱ����2��1������
-- select wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
-- 	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
-- from import_data.wt_listing wl 
-- join import_data.mysql_store ms on wl.ShopCode = ms.Code 
-- join epp on wl.sku = epp.sku 
-- where 
-- 	MinPublicationDate>= '${StartDay}' 
-- 	and MinPublicationDate <'${NextStartDay}' 
-- 	and wl.IsDeleted = 0 
-- 	and ms.Department = '��ٻ�' 
-- )

,t_orde as ( 
select OrderNumber ,wo.PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin 
	,ExchangeUSD,TransactionType,wo.SellerSku,RefundAmount,wo.SaleCount 
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
-- 	,timestampdiff(second,MinPublicationDate,PayTime)/86400 as ord_days -- ��������Ϊ���翯��ʱ��
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
-- left join (
-- 	select shopcode,SellerSku,MinPublicationDate from t_list group by shopcode,SellerSku,MinPublicationDate 
-- 	) t_list
-- 	on wo.shopcode = t_list.shopcode and wo.SellerSku = t_list.SellerSku 
join epp on wo.Product_SKU = epp.sKU
left join (select PlatOrderNumber from wt_orderdetails 
	where FeeGross > 0 
		and PayTime >= '2023-03-01' and PayTime < '2023-05-01'
		and IsDeleted=0 
	group by PlatOrderNumber 
	) tb on wo.PlatOrderNumber =tb.PlatOrderNumber
where 
	PayTime >= '2023-03-01' and PayTime < '2023-05-01'
	and wo.IsDeleted=0 
	and ms.Department = '��ٻ�' 
	and tb.PlatOrderNumber is null  -- �޳��˷ѵ�
)
-- select * from t_orde 


-- ,t_list_stat as ( -- ����ͳ��
-- select t_list.sku
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=15 then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
-- 	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
-- 	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
-- 	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
-- 	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
-- 	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode,t_list.asin) ) list_cnt
-- 	,min(MinPublicationDate) as min_pub_date 
-- from t_list 
-- group by t_list.sku
-- )
-- select * from t_list_stat

-- ,t_ord_list_stat as (
-- select t_orde.sku 
-- 	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `�׵�30���ڳ���������`
-- from t_orde
-- join (
-- 	select sku ,min(MinPublicationDate) as min_pub_date from t_list group by sku
-- 	) tmp 
-- 	on tmp.sku = t_orde.sku
-- where PayTime <= DATE_ADD(min_pub_date,interval 30 day)
-- group by t_orde.sku 
-- )

-- ,t_ad as ( 
-- select t_list.sku, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
-- 	, DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- ���
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '��' else '��' end `�Ƿ�7��`
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 14*86400 then '��' else '��' end `�Ƿ�14��`
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 30*86400 then '��' else '��' end `�Ƿ�30��`
-- from t_list
-- join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
-- -- 	and t_list.spu= 5202143
-- where asa.CreatedTime >= '${StartDay}'
-- )
-- 
-- ,t_ad_stat as (
-- select tmp.* 
-- 	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `����30������`
-- 	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `����30����ת����`
-- from 
-- 	( select sku
-- 		-- �ع���
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
-- 		-- �����
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
-- 		-- ����	
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
-- 		from t_ad  group by sku
-- 	) tmp
-- )
-- select * from t_ad_stat where spu = 5203342 

-- ,t_orde_stat as (
-- select sku 
-- 	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
-- 	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
-- 	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
-- -- 	,sum(TotalGross) TotalGross
-- 	,round( count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'),4) orders_daily
-- 	,count( distinct PlatOrderNumber) orders_total
-- 	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
-- 	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
-- 	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
-- 	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30�����������`
-- 	,to_date(min(paytime)) `�״γ���ʱ��`
-- from t_orde 
-- group by sku 
-- )

-- ����������Ϊ���� ���Ŷ���������
,t_orde_stat as (
select sku 
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
-- 
-- 	,count(distinct concat(shopcode,sellersku) ) `����������` 
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��1`
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��2`
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then  concat(shopcode,sellersku) end ) `����������_Ȫ1` 
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then  concat(shopcode,sellersku) end ) `����������_Ȫ2` 
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then  concat(shopcode,sellersku) end ) `����������_Ȫ3` 

-- 	,count(distinct Market ) `�����г���` 
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  Market end ) `�����г���_��1` 
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  Market end ) `�����г���_��2` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��1��' then  Market end ) `�����г���_Ȫ1` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��2��' then  Market end ) `�����г���_Ȫ2` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��3��' then  Market end ) `�����г���_Ȫ3` 

from t_orde
group by sku
)
-- 5207230

,t_merage as (
select 
	left(DATE_ADD(DevelopLastAuditTime,interval - 8 hour),7) `�����·�`
	,epp.sku 
	,ProductName 
	,DevelopUserName `������Ա`
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name `Ԫ��` 
	
	,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) `����ʱ��`
	,replace(concat(right('2023-03-01',5),'��',right(to_date(date_add('2023-05-01',-1)),5)),'-','') `����ͳ��ʱ�䷶Χ`
	
	,round(���۶�/������,2)  `ƽ���͵�`
	,round(���۶�_��1/������_��1,2)  `ƽ���͵�_��1`
	,round(���۶�_��2/������_��2,2)  `ƽ���͵�_��2`
	,round(���۶�_Ȫ1/������_Ȫ1,2)  `ƽ���͵�_Ȫ1`
	,round(���۶�_Ȫ2/������_Ȫ2,2)  `ƽ���͵�_Ȫ2`
	,round(���۶�_Ȫ3/������_Ȫ3,2)  `ƽ���͵�_Ȫ3`
	
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
	
	,round(����� / ���۶�,2)  `ë����`
	,round(�����_��1 / ���۶�_��1,2)  `ë����_��1`
	,round(�����_��2 / ���۶�_��2,2)  `ë����_��2`
	,round(�����_Ȫ1 / ���۶�_Ȫ1,2)  `ë����_Ȫ1`
	,round(�����_Ȫ2 / ���۶�_Ȫ2,2)  `ë����_Ȫ2`
	,round(�����_Ȫ3 / ���۶�_Ȫ3,2)  `ë����_Ȫ3`
	
	,`������`
	,`������_��1` 
	,`������_��2` 
	,`������_Ȫ1` 
	,`������_Ȫ2` 
	,`������_Ȫ3` 
	
-- 	,`����SKU����`
-- 	,`����SKU����_��1` 
-- 	,`����SKU����_��2` 
-- 	,`����SKU����_Ȫ1` 
-- 	,`����SKU����_Ȫ2` 
-- 	,`����SKU����_Ȫ3` 

	
-- 	,Artist  `����`
-- 	,Editor  `�༭`
-- 	,to_date(DATE_ADD(CreationTime,interval - 8 hour)) `���ʱ��`
from (select sku from epp group by sku ) epp 
left join 
	(select sku ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 0
	) epp_spu on epp.sku =epp_spu.sku
left join (
	select sku ,case when TortType is null then 'δ���' else TortType end TortType ,Festival ,Artist ,Editor 
		from import_data.wt_products 
		where IsDeleted =0  and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and ProjectTeam='��ٻ�' 
	) epp_spu_Tort on epp.sku =epp_spu_Tort.sku 
left join t_elem on epp.sku =t_elem.sku 
-- left join t_list_stat on epp.sku =t_list_stat.sku
-- left join t_ad_stat on epp.sku =t_ad_stat.sku
left join t_orde_stat on epp.sku =t_orde_stat.sku 
-- left join t_ord_list_stat on epp.sku =t_ord_list_stat.sku
)

-- select count(1)
select * 
from t_merage
order by �����·� 