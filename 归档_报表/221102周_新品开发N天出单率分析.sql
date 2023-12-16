/*
��Ʒ����N�������=��Ӧ���۶�����������SKU��/�������SKU��
�Կ�������ʱ�䰴��������sk������ÿ��sku���׵�������

ÿ��skuֻ��һ�� �׵������������������-����������ڣ�,ÿ�ʶ�����ÿ��skuֻ��1�� �׵�����,
���׵���������"30���׵�������"��ҵ�����ǣ�7�¿�����ɵ�sku�У��ж��ٸ�����30���ھ������ٿ���1��

����GMתPM���п�������ʱ����skuSource=2��SKU������SKU�ȸ�����Ч���ģ����ǽ���SKU��������Ȼ���ö�������ȥ����
���Լ������������ʱ���ʱ��Ҳ�ǿ�������֮��������׵�����ҲΪ������
*/

with 
newcateg as ( -- �õ�����Ŀ -- ���ڿ����ò�Ʒ���
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = 'С�����' and bpv.ChineseValueName is Not null
)

, tmp_epp as (
select
	n.ChineseValueName as newpath1 -- ����Ŀ1��
 	, epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week -- 23����ܼ�������1
from import_data.erp_product_products epp
join newcateg n on n.sku = epp.SKU -- ֻ�����д��·����ǩ��sku
where epp.DevelopLastAuditTime >= '2022-05-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
)


, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- ����ʱ��
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department, epp.newpath1
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
-- 			, b.OrderNumber
			, (if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalGross
			, (if(TaxGross>0, TotalProfit, TotalProfit-(TotalGross*IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalProfit
		from import_data.OrderDetails od
		join import_data.mysql_store ms on ms.Code = od.ShopIrobotId 
			and ms.Department in ('���۶���', '��������') and PayTime >= '2022-05-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join (select BoxSku, min(PayTime) as min_paytime from import_data.OrderDetails od1
			join import_data.mysql_store ms1 on ms1.Code = od1.ShopIrobotId and ms1.Department in ('���۶���', '��������') and PayTime >= '2022-05-01'
			where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 group by BoxSku) tmp_min on tmp_min.BoxSku =od.BoxSku 
		left join 
			( -- ������ʷ��������˶���
			select OrderNumber , pay_month
			from (select left(PayTime,7) as pay_month, OrderNumber, GROUP_CONCAT(TransactionType) alltype 
				FROM import_data.OrderDetails where ShipmentStatus = 'δ����' and OrderStatus = '����' and PayTime >= '2022-05-01'
				group by OrderNumber, pay_month) a
			where alltype = '����'
			) b 
			on b.OrderNumber = od.OrderNumber and b.pay_month = left(od.PayTime,7)
		left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
		where  b.OrderNumber is null 
		) tmp
	) tmp2 
)

, join_listing as ( 
select t.newpath1, t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������') and ms.ShopStatus='����'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)



-- ��1 sku��ϸ���
select ords.*,jl.`����������`,round(`�ۼƳ���������`/jl.`����������`,4) `���Ӷ�����`, DATE_FORMAT(jl.`�״ο���ʱ��`,'%Y/%m/%d') `�״ο�������` from
	(select newpath1 `��Ŀ`, SPU, SKU, BoxSku, DevelopUserName `������Ա`, SkuSource_cn `������`, ord_days`�׵�����`, WEEKOFYEAR(DevelopLastAuditTime)+1 `�����ܴ�` 
		, DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `������������`, DATE_FORMAT(min_paytime,'%Y/%m/%d') `�׵�����`
		, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `����ͳ�ƽ�ֹ����`
		, round(sum(AfterTax_TotalGross),2) `�ۼ�����`, round(sum(AfterTax_TotalProfit),2) `�ۼ�����`, count(distinct PlatOrderNumber) `�ۼƶ�����`
		, count(distinct concat(SellerSku,ShopIrobotId)) `�ۼƳ���������`
	from orders group by newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, ord_days, WEEKOFYEAR(DevelopLastAuditTime)+1
		, `������������`, `�׵�����`, `����ͳ�ƽ�ֹ����`
	) ords
left join (
	select newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) 
		, count(1) `����������`, min(PublicationDate) `�״ο���ʱ��`
	from join_listing
	group by newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime)
	) jl on ords.SKU = jl.SKU


-- ��2 ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select * from (
	select '����' `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( 
		select t.dev_week, 'ȫ��Ŀ' newpath1, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
		) tmp
	union all 
	select '����/��Ŀ'  `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.newpath1
		) tmp
	
	union all 
	select '����/������Ա'  `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, 'ȫ��Ŀ' as newpath1, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.DevelopUserName
		) tmp
	union all 
	select '����/������Դ'  `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, 'ȫ��Ŀ' as newpath1, '�����ϼ�' DevelopUserName, t.SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.SkuSource_cn
		) tmp
	union all 
	select '����/������Դ/��Ŀ'  `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, '�����ϼ�' DevelopUserName, t.SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.SkuSource_cn, t.newpath1
		) tmp
	union all 
	select '����/������Ա/��Ŀ'  `����ά��`, dev_week `������`, newpath1 `����Ŀ`, DevelopUserName `������Ա`, SkuSource_cn `������Դ`, dev_cnt `����sku��`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, t.DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.DevelopUserName, t.newpath1
		) tmp
) union_tmp
order by  `����ά��`, `������`, `����Ŀ`, `������Ա`, `������Դ`