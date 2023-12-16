/* 
��Ʒ����ģ��\ͳ�Ʒ�����\��Ʒ�Ŷ�_��Ʒͳ�ƿ��
��λ�������Ӳ�Ʒ��ӻ��� һֱ��֮������۱��ֵ�ȫ���̱���
������ͣ���ά������
ά�ȣ���Ʒ�Ŷ� x ��Ʒ����ʱ�䣨��+�£� 
	��Ʒ�Ŷ�ά��ö�٣�1����ٻ� 2����ٻ�һ���� 3������С�� 4��������Ա
ָ�꣺
	��Ʒ��
		����SPU��
		����SKU��
	�������
		����7��SPU�����ʣ�
		����14��SPU�����ʣ�
		����30��SPU�����ʣ�
		����7��SKU�����ʣ�
		����14��SKU�����ʣ�
		����30��SKU�����ʣ�
	����
		�׵�30��SPU���۶�
		�׵�30��SPU���� �׵�30��SPU���۶� / ����SPU��
		����30��SPU����: �׵�30��SPU���۶� / ����SPU��
	����
		�ۼ�������
		�¿�����ƷLST�����ʣ�
	���Ͷ��
		�����ع�
			����7���ع�SKUռ�ȣ����ѿ���SKU������ʼͳ�ƺ������֣���ͬ��
			����14���ع�SKUռ��
			����30���ع�SKUռ��
		���ع����ӵĹ�����
			����7/15/30�� ���ѡ��ع⡢��������������۶�
			����7/15/30�� ����ʡ�ת���ʡ�CPC��ROAS��ACOS	���������ع�			
��Ҫ����Դ�����ӱ������ϸ��
*/

-- NextStartDay 23-03-01 ��NextStartDay ����


with
t_prod as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
 	, left(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour),7) dev_month
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, vr.department
 	, vr.NodePathName
 	, vr.dep2
from import_data.erp_product_products epp
left join 
	( select split(NodePathNameFull,'>')[2] as dep2 
		,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName
		,name ,department
	from view_roles 
	where ProductRole ='����'
-- 	and NodePathName in ('��η�-��Ʒ��','���Ԫ-��Ʒ��','��Ʒ��')
	) vr on epp.DevelopUserName = vr.name
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-01-01' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='��ٻ�' 
	and epp.DevelopUserName != '���'
)


-- select * from t_prod where department is null 

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,shopcode ,asin 
	,TransactionType,SellerSku,RefundAmount
	, TotalGross/ExchangeUSD as AfterTax_TotalGross
	, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,wo.BoxSku 
	,PayTime
	,timestampdiff(SECOND,t_prod.DevelopLastAuditTime,PayTime)/86400 as ord_days 
	, timestampdiff(SECOND,spu_min_paytime,PayTime)/86400 as ord_days_since_od 
	,t_prod.Department
	,t_prod.dep2 
	,t_prod.NodePathName 
	,t_prod.DevelopUserName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_prod on wo.Product_SKU = t_prod.sku 
left join ( select Product_SPU , min(PayTime) as spu_min_paytime 
	from import_data.wt_orderdetails  od1
	join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
	and ms1.Department ='��ٻ�' and PayTime >= '2023-01-01'  -- Ϊ�����׵�30�� 
	where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	wo.IsDeleted=0 
-- 	and TransactionType = '����'  
	and OrderStatus <> '����' and OrderTotalPrice > 0 
	and ms.Department = '��ٻ�'
)


,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, wl.SPU ,wl.SKU ,MinPublicationDate  ,MarketType 
	,DevelopLastAuditTime
	,t_prod.Department
	,t_prod.dep2 
	,t_prod.NodePathName 
	,t_prod.DevelopUserName 
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- ֻ����Ʒ
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)

,t_ad as ( -- �����ϸ
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
	,t_list.site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, Department
	, dep2 
	, NodePathName 
	, DevelopUserName 
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
)


,t_prod_stat as ( 
select concat(ifnull(Department,''),ifnull(NodePathName,''),ifnull(DevelopUserName,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	, Department,NodePathName,DevelopUserName,dev_month,dev_week
	, dev_sku_cnt `����sku��`
	, dev_spu_cnt `����spu��`
	, round(ord7_sku_cnt/dev_sku_cnt,4) as `����7��SKU������`, round(ord14_sku_cnt/dev_sku_cnt,4) as `����14��SKU������`, round(ord30_sku_cnt/dev_sku_cnt,4) as `����30��SKU������`
	, round(ord7_spu_cnt/dev_spu_cnt,4) as `����7��SPU������`, round(ord14_spu_cnt/dev_spu_cnt,4) as `����14��SPU������`
	, round(ord30_spu_cnt/dev_spu_cnt,4) as `����30��SPU������`
	, round(ord_spu_cnt/dev_spu_cnt,4) as `�ۼ�SPU������`
	, ord7_sku_sales `����7�����۶�`, ord14_sku_sales `����14�����۶�`, ord30_sku_sales `����30�����۶�` 
	, ord30_sku_sales_since_od `�׵�30�����۶�`
	,round(ord30_sku_sales_since_od/dev_spu_cnt) `����30��SPU����`
	,round(ord30_sku_sales_since_od/ord30_spu_cnt_since_od) `�׵�30��SPU����`
	,���۶�2301
	,���۶�2302
	,���۶�2303
	,���۶�2304
	,���۶�2305
	,���۶�2306
	,���۶�2307
	,���۶�2308
	,���۶�2309
	,���۶�2310
	,���۶�2311
	,���۶�2312
from ( 
	select t.Department,t.NodePathName,t.DevelopUserName,t.dev_month ,t.dev_week
		, count(distinct t.SPU) as dev_spu_cnt
		, count(distinct t.SKU) as dev_sku_cnt
		
		, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_spu_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_spu_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_spu_cnt
		, count(distinct case when 0 <= ord_days then od.SPU end) as ord_spu_cnt
		, count(distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then od.spu end) as ord30_spu_cnt_since_od

		, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.sku end) as ord7_sku_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.sku end) as ord14_sku_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.sku end) as ord30_sku_cnt
		
		, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
		, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
		, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
		, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od 

			
		,round(sum(case when left(paytime,7)='2023-01' then AfterTax_TotalGross end )) as ���۶�2301
		,round(sum(case when left(paytime,7)='2023-02' then AfterTax_TotalGross end )) as ���۶�2302
		,round(sum(case when left(paytime,7)='2023-03' then AfterTax_TotalGross end )) as ���۶�2303
		,round(sum(case when left(paytime,7)='2023-04' then AfterTax_TotalGross end )) as ���۶�2304
		,round(sum(case when left(paytime,7)='2023-05' then AfterTax_TotalGross end )) as ���۶�2305
		,round(sum(case when left(paytime,7)='2023-06' then AfterTax_TotalGross end )) as ���۶�2306
		,round(sum(case when left(paytime,7)='2023-07' then AfterTax_TotalGross end )) as ���۶�2307
		,round(sum(case when left(paytime,7)='2023-08' then AfterTax_TotalGross end )) as ���۶�2308
		,round(sum(case when left(paytime,7)='2023-09' then AfterTax_TotalGross end )) as ���۶�2309
		,round(sum(case when left(paytime,7)='2023-10' then AfterTax_TotalGross end )) as ���۶�2310
		,round(sum(case when left(paytime,7)='2023-11' then AfterTax_TotalGross end )) as ���۶�2311
		,round(sum(case when left(paytime,7)='2023-12' then AfterTax_TotalGross end )) as ���۶�2312
		
		-- 3������Ĳ�Ʒ�ڸ���ʱ��3�µ����۶�
	from t_prod t left join t_orde od on od.BoxSku =t.BoxSKU  
	group by grouping sets (
		(t.Department,t.dev_month) -- ����x��
		,(t.Department,t.dev_week) -- ����x��
		,(t.Department,t.NodePathName,t.dev_month) -- ������x��
		,(t.Department,t.NodePathName,t.dev_week) -- ������x��
		,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_month) -- ������Աx��
		,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_week) -- ������Աx��
		) 
	) tmp
)
-- select * from t_prod_stat where 

,t_list_stat as ( -- ����ͳ��
select concat(ifnull(Department,''),ifnull(NodePathName,''),ifnull(DevelopUserName,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,Department,NodePathName,DevelopUserName,dev_month,dev_week
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
	,count(distinct t_list.SKU ) list_sku_cnt
	,count(distinct t_list.SPU ) list_spu_cnt
	from t_list 
group by grouping sets (
	(Department,dev_month) -- ����x��
	,(Department,dev_week) -- ����x��
	,(Department,NodePathName,dev_month) -- ������x��
	,(Department,NodePathName,dev_week) -- ������x��
	,(Department,NodePathName,DevelopUserName,dev_month) -- ������Աx��
	,(Department,NodePathName,DevelopUserName,dev_week) -- ������Աx��
	) 
)
-- select * from t_list_stat

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `����30��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `����30����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `����30��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `����30��ACOS`
from 
	( select 
		concat(ifnull(t.Department,''),ifnull(t.NodePathName,''),ifnull(t.DevelopUserName,''),ifnull(t.dev_month,''),ifnull(t.dev_week,'')) tbcode 
		,t.Department,t.NodePathName,t.DevelopUserName,t.dev_month ,t.dev_week
		-- �ع���
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then cost*ExchangeUSD end),2) as ad30_Spend
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
		-- ������۶�
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7Day end),2) as ad30_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������	
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7DayUnit end),2) as ad30_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Clicks end)) as ad30_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad t
		group by grouping sets (
			(t.Department,t.dev_month) -- ����x��
			,(t.Department,t.dev_week) -- ����x��
			,(t.Department,t.NodePathName,t.dev_month) -- ������x��
			,(t.Department,t.NodePathName,t.dev_week) -- ������x��
			,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_month) -- ������Աx��
			,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_week) -- ������Աx��
			) 
	) tmp  
)
-- select * from t_ad_stat

,t_merage as (
select
	case 
		when concat(t_prod_stat.Department,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is null then  '��ٻ�x������' 
		when concat(t_prod_stat.Department,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is null then  '��ٻ�x������' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is null then  '�����Ŷ�x������' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is null then  '�����Ŷ�x������' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.dev_week) is null then  '������Աx������' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.dev_month) is null then  '������Աx������' 
	end as `Ԥ�÷���ά��`
-- 	,t_prod_stat.Department
	,t_prod_stat.NodePathName `�����Ŷ�`
	,t_prod_stat.DevelopUserName `������Ա`
	,t_prod_stat.dev_month  `�����·�`
	,t_prod_stat.dev_week `�����ܴ�`

	,`����sku��`
	,`����spu��`
	
	,`����7��SPU������`
	,`����14��SPU������`
	,`����30��SPU������`
	,`�ۼ�SPU������`

	,`����7��SKU������`
	,`����14��SKU������`
	,`����30��SKU������`
	
	,���۶�2301
	,���۶�2302
	,���۶�2303
	,���۶�2304
	,���۶�2305
	,���۶�2306
	,���۶�2307
	,���۶�2308
	,���۶�2309
	,���۶�2310
	,���۶�2311
	,���۶�2312
	
	,`����7�����۶�`
	,`����14�����۶�`
	,`����30�����۶�` 
	
	,`�׵�30�����۶�`
	,`����30��SPU����`
	,`�׵�30��SPU����`
	
	,round(list_cnt/list_sku_cnt,1) `��SKU����������`
	,round(list_cnt/list_spu_cnt,1) `��SPU����������`
	,list_cnt `����������`
	,list_cnt_in3d `����3�쿯��������`
	,list_cnt_in7d `����7�쿯��������`
	
	,ad_sku_Exposure `�ۼ��ع�`
	,ad7_sku_Exposure `����7���ع�`
	,ad14_sku_Exposure `����14���ع�`
	,ad30_sku_Exposure `����30���ع�`
	
	,ad_sku_Clicks `�ۼƵ��` 
	,ad7_sku_Clicks `����7����` 
	,ad14_sku_Clicks `����14����`
	,ad30_sku_Clicks `����30����`
	
	,`�ۼƹ������`
	,`����7��������`
	,`����14��������`
	,`����30��������`
	
	,ad_sku_TotalSale7DayUnit `�ۼƹ������`
	,ad7_sku_TotalSale7DayUnit `����7��������`
	,ad14_sku_TotalSale7DayUnit `����14��������`
	,ad30_sku_TotalSale7DayUnit `����30��������`
	,`�ۼƹ��ת����`
	,`����7����ת����`
	,`����14����ת����`
	,`����30����ת����`
	
	,ad_Spend `�ۼƹ�滨��`
	,ad7_Spend `����7���滨��`
	,ad14_Spend `����14���滨��`
	,ad30_Spend `����14���滨��`
	
	,ad_TotalSale7Day `�ۼƹ�����۶�`
	,ad7_TotalSale7Day `����7�������۶�`
	,ad14_TotalSale7Day `����14�������۶�`
	,ad30_TotalSale7Day `����14�������۶�`
	
	,`�ۼ�ROAS`
	,`����7��ROAS`
	,`����14��ROAS`
	,`����30��ROAS`
	
	,`�ۼ�ACOS`
	,`����7��ACOS`
	,`����14��ACOS`
	,`����30��ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `�ۼ�CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `����7��CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `����14��CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `����30��CPC`
	
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `���ʱ�䷶Χ`

from t_prod_stat
left join t_ad_stat on t_prod_stat.tbcode =t_ad_stat.tbcode 
left join t_list_stat on t_prod_stat.tbcode =t_list_stat.tbcode 
)

select t_merage.* ,dd.week_num_in_year as ��������� ,dd.week_begin_date as ���յ�����һ
from t_merage
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date)  dd on year('${StartDay}') = dd.year and t_merage.`�����ܴ�` = dd.week_num_in_year
order by `Ԥ�÷���ά��` desc ,`�����Ŷ�`,`������Ա`,`�����·�`,`�����ܴ�`


