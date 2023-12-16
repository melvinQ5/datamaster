/*
��Ʒ����N��������������ܡ�����
ÿ��skuֻ��һ�� �׵������������������-����������ڣ�,ÿ�ʶ�����ÿ��skuֻ��1�� �׵�����,
���׵���������"30���׵�������"��ҵ�����ǣ�7�¿�����ɵ�sku�У��ж��ٸ�����30���ھ������ٿ���1��
*/

with 
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, de.dep2
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)as dev_week 
from import_data.erp_product_products epp
left join (
	select case when sku = '����' then '����1688' else sku end  as name 
	,boxsku as department
	,case when spu = '��Ʒ��' then 'Ȫ����Ʒ��' when sku='֣���' then 'Ȫ����Ʒ��' else '�ɶ���Ʒ��' end as dep2
	from JinqinSku js where Monday= '2023-03-31' 
	) de 
	on epp.DevelopUserName = de.name 
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	AND epp.ProjectTeam ='��ٻ�' 
)

, orders as ( 
select * from (
	select tmp.* 
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days  -- ����ʱ��
		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst 
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
			, od.PublicationDate as min_pubtime -- ����������м����״ο���ʱ��
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
			and ms1.Department ='��ٻ�' and PayTime >= '2023-01-01'
			where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku 
		) tmp
	) tmp2 
)

, join_listing as ( 
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime 
	, DATE_FORMAT(MinPublicationDate,'%Y%m') as pub_month ,t.dev_month ,t.dep2 
	, timestampdiff(SECOND,DevelopLastAuditTime,CURRENT_DATE())/86400 as dev_days 
	, eaal.MinPublicationDate  
from import_data.wt_listing  eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='��ٻ�' 
join tmp_epp t on  eaal.sku = t.SKU 
)

-- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select * from (
	select '����' `����ά��`, tmp.dev_month `������`, tmp.DevelopUserName `������Ա`, dev_cnt `����SPU��` 
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, round(ord60_sku_cnt/dev_cnt,4) as `����60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `����90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `����120�춯����`
		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`	
		
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `����7�춯����`, round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `����14�춯����`, round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `����30�춯����`
		, round(ord60_sku_cnt_since_lst/dev_pub_cnt,4) as `����60�춯����`, round(ord90_sku_cnt_since_lst/dev_pub_cnt,4) as `����90�춯����`, round(ord120_sku_cnt_since_lst/dev_pub_cnt,4) as `����120�춯����`
-- 		,dev_pub_cnt , dev_cnt `����SPU��` ,ord14_sku_cnt ,ord14_sku_cnt_since_lst
		from ( 
		select t.dev_month, '�����ϼ�' as DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then od.SPU end) as ord30_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 60 then od.SPU end) as ord60_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 90 then od.SPU end) as ord90_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 120 then od.SPU end) as ord120_sku_cnt_since_lst
			
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month
		) tmp
-- 		left join ( select dev_month ,pub_month 
-- 		,count( distinct  spu ) dev_pub_cnt 
-- 		from join_listing group by dev_month ,pub_month ) tmp3 
-- 		on tmp.dev_month =tmp3.pub_month and  tmp.dev_month =tmp3.dev_month 
		
		left join ( select dev_month 
		,count( distinct  spu ) dev_pub_cnt 
		from join_listing group by dev_month ) tmp3 
		on tmp.dev_month = tmp3.dev_month 
	union all 
	select '����/������Ա' `����ά��`, tmp.dev_month `������`, tmp.DevelopUserName `������Ա`, dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`	
		
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `7�춯����`, round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `14�춯����`, round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `30�춯����`
		, round(ord60_sku_cnt_since_lst/dev_pub_cnt,4) as `60�춯����`, round(ord90_sku_cnt_since_lst/dev_pub_cnt,4) as `90�춯����`, round(ord120_sku_cnt_since_lst/dev_pub_cnt,4) as `120�춯����`
	from ( select t.dev_month, t.DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then od.SPU end) as ord30_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 60 then od.SPU end) as ord60_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 90 then od.SPU end) as ord90_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 120 then od.SPU end) as ord120_sku_cnt_since_lst
			
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
		group by t.dev_month, t.DevelopUserName
		) tmp
		left join ( select dev_month ,DevelopUserName 
		,count( distinct  spu ) dev_pub_cnt 
		from join_listing group by dev_month , DevelopUserName ) tmp3 
		on tmp.dev_month  = tmp3.dev_month and tmp.DevelopUserName =tmp3.DevelopUserName  
	union all 
	select '����/�����Ŷ�'  `����ά��`, tmp.dev_month `������`, tmp.dep2 `�����Ŷ�`, dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`	
		
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `7�춯����`, round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `14�춯����`, round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `30�춯����`
		, round(ord60_sku_cnt_since_lst/dev_pub_cnt,4) as `60�춯����`, round(ord90_sku_cnt_since_lst/dev_pub_cnt,4) as `90�춯����`, round(ord120_sku_cnt_since_lst/dev_pub_cnt,4) as `120�춯����`
	from ( 
		select  t.dev_month, t.dep2 
		, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then od.SPU end) as ord30_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 60 then od.SPU end) as ord60_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 90 then od.SPU end) as ord90_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 120 then od.SPU end) as ord120_sku_cnt_since_lst
			
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t 
		left join orders od on od.BoxSku =t.BoxSKU 
		where t.dep2 regexp 'Ȫ����Ʒ��|�ɶ���Ʒ��' 
		group by t.dev_month, t.dep2  
		) tmp
		left join ( select dev_month ,dep2 
		,count( distinct  spu ) dev_pub_cnt 
		from join_listing group by dev_month ,dep2 ) tmp3 
		on tmp.dev_month  = tmp3.dev_month and tmp.dep2 =tmp3.dep2
) union_tmp
order by  `����ά��`, `������`, `������Ա`