
/*
����ͳ����Ʒ14�춯����
*/

with 
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	,epp.ProductName 
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week 
from import_data.erp_product_products epp
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	AND epp.ProjectTeam ='��ٻ�' 
-- 	and  DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.spu ,eppaea.sku ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join tmp_epp on eppaea.sku = tmp_epp.sku 
group by eppaea.spu ,eppaea.sku ,eppea.Name 
)

, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- ����ʱ��
		, datediff(paytime,min_paytime) as ord_days_since_sale -- �״γ�����ʼ����ʱ��
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU  -- 23���������г���
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
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='��ٻ�' and ms.ShopStatus='����'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)


-- �ܶ���_sku  (��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
-- select * from (
-- 	select '����' `����ά��`
-- 		, dev_week `������`
-- 		, DevelopUserName `������Ա`, dev_cnt `����sku��`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
-- 		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`
-- 	from ( 
-- 		select t.dev_week, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
-- 		) tmp
-- 	union all 
-- 	select '����/������Ա'  `����ά��`, dev_week `������`, DevelopUserName `������Ա`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_week, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
-- 		group by t.dev_week, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `����ά��`, `������`, `������Ա`



-- �ܶ���_spu  (��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
-- select * from (
-- 	select '����' `����ά��`
-- 		, dev_week `������`
-- 		, DevelopUserName `������Ա`, dev_cnt `����sku��`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
-- 		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`
-- 	from ( 
-- 		select t.dev_week, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu  end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
-- 		) tmp
-- 	union all 
-- 	select '����/������Ա'  `����ά��`, dev_week `������`, DevelopUserName `������Ա`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_week, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
-- 		group by t.dev_week, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `����ά��`, `������`, `������Ա`


-- �ն���_sku  (��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
-- select * from (
-- 	select '����' `����ά��`
-- 		, dev_date `��������`
-- 		, DevelopUserName `������Ա`, dev_cnt `����sku��`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
-- 		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`
-- 	from ( 
-- 		select t.dev_date, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_date
-- 		) tmp
-- 	union all 
-- 	select '����/������Ա'  `����ά��`, dev_date `��������`, DevelopUserName `������Ա`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_date, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
-- 		group by t.dev_date, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `����ά��`, `��������`, `������Ա`


-- �ն���_spu  (��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
-- select * from (
-- 	select '����' `����ά��`
-- 		, dev_date `��������`
-- 		, DevelopUserName `������Ա`, dev_cnt `����sku��`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
-- 		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`
-- 	from ( 
-- 		select t.dev_date, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt 
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_date
-- 		) tmp
-- 	union all 
-- 	select '����/������Ա'  `����ά��`, dev_date `��������`, DevelopUserName `������Ա`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_date, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
-- 		group by t.dev_date, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `����ά��`, `��������`, `������Ա`



-- sku��ϸ��� 
	select tmp_epp.sku 
		,tmp_epp.spu
		,tmp_epp.productname
		,ele_name `Ԫ��`
		, Festival`����`
		,`��Ʒ״̬`
		,`��Ȩ״̬`
		,`������������`
		,`�����ܴ�`
		,ords.*
		,case when `�׵�30�����۶�` >=100 then 1 else 0 end as `�׵�30�����Ƿ��100����`
	from tmp_epp 
	left join (select  SKU, BoxSku, DevelopUserName `������Ա`
			, DATE_FORMAT(min_paytime,'%Y/%m/%d') `�׵�����`
			, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `����ͳ�ƽ�ֹ����`
			, round(sum(AfterTax_TotalGross),2) `����0326���۶�`
			, round(sum(AfterTax_TotalProfit),2) `����0326�����`
			,  count(distinct to_date(paytime)) `����0326��������`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalGross end ),2) `�׵�30�����۶�`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalProfit end ),2) `�׵�30�������`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalProfit end )/sum( case when ord_days_since_sale <= 30 then AfterTax_TotalGross end ),2) `�׵�30��ë����`
			, count(distinct case when ord_days_since_sale <= 30 then PlatOrderNumber end ) `�׵�30�충����`
			, count(distinct case when ord_days_since_sale <= 30 then concat(SellerSku,ShopIrobotId) end  ) `�׵�30�����������`
		from orders 
		 �״γ�����30����
		group by  SKU, BoxSku, DevelopUserName
			, `�׵�����`, `����ͳ�ƽ�ֹ����`
		) ords
		on tmp_epp.sku = ords.sku 
	left join (
		select SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) 
			, count(1) `����������`
		from join_listing
		group by SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime)
		) jl on ords.SKU = jl.SKU
	left join (
		select sku , productname ,Festival 
			,DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `������������` , WEEKOFYEAR(DevelopLastAuditTime) `�����ܴ�` 
			,TortType `��Ȩ״̬` 
			,case when wp.ProductStatus = 0 then '����'
				when wp.ProductStatus = 2 then 'ͣ��'
				when wp.ProductStatus = 3 then 'ͣ��'
				when wp.ProductStatus = 4 then '��ʱȱ��'
				when wp.ProductStatus = 5 then '���'
				end as  `��Ʒ״̬`
		from import_data.wt_products wp 
	) wp on tmp_epp.sku = wp.sku 
	left join (select sku,GROUP_CONCAT(name) ele_name from t_elem group by sku) t_elem on tmp_epp.sku = t_elem.sku 
