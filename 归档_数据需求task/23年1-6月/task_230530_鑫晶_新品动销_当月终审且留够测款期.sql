/*
15�տ�ʼ���� �����ۼ�����Ĳ�Ʒ���ڵ���14�춯��
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
	,case when spu = '��Ʒ��' then 'Ȫ����Ʒ��' when sku='֣���' then 'Ȫ����Ʒ��' else  '�ɶ���Ʒ��' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
where date_add(epp.DevelopLastAuditTime,interval - 8 hour) >= '${StartDay}' and date_add(epp.DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
    and epp.IsDeleted = 0 and epp.IsMatrix = 0
	AND epp.ProjectTeam ='��ٻ�'
)

, orders as (
select * from (
	select tmp.*
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days  -- ����ʱ��
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�' and PayTime >= '${StartDay}'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0
			and ms1.Department ='��ٻ�' and PayTime >= '${StartDay}'
			where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku
		) tmp
	) tmp2
)

, join_listing as (
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.MinPublicationDate
from import_data.wt_listing  eaal
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='��ٻ�' and ms.ShopStatus='����'
join tmp_epp t on  eaal.sku = t.SKU
where eaal.ListingStatus = 1  and IsDeleted = 0
)

-- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select  concat('${StartDay}','��', date(date_add('${NextStartDay}',interval -1 day )))  '����ʱ�䷶Χ' ,* from (
	select
	    '����' `����ά��`, dev_month `������`, DevelopUserName `������Ա`, dev_cnt `����SPU��`
		, round(ord7_sku_cnt/dev_cnt,4) as `7�춯����`, round(ord14_sku_cnt/dev_cnt,4) as `14�춯����`, round(ord30_sku_cnt/dev_cnt,4) as `30�춯����`
		, round(ord60_sku_cnt/dev_cnt,4) as `60�춯����`, round(ord90_sku_cnt/dev_cnt,4) as `90�춯����`, round(ord120_sku_cnt/dev_cnt,4) as `120�춯����`
		, ord7_sku_sales `7�����۶�`, ord14_sku_sales `14�����۶�`, ord30_sku_sales `30�����۶�`, ord60_sku_sales `60�����۶�`, ord90_sku_sales `90�����۶�`, ord120_sku_sales `120�����۶�`
		from (
		select t.dev_month, '�����ϼ�' as DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month
		) tmp

	union all
	select '����/������Ա' `����ά��`, dev_month `������`, DevelopUserName `������Ա`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_month, t.DevelopUserName
		, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU
-- 		where  DevelopUserName in('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����')
		group by t.dev_month, t.DevelopUserName
		) tmp

	union all
	select '����/�����Ŷ�'  `����ά��`, dev_month `������`, dep2 `�����Ŷ�`, dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,10) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate
		, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales
		, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from (
		select  t.dev_month, t.dep2
		, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
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
) union_tmp
order by  `����ά��`, `������`, `������Ա`