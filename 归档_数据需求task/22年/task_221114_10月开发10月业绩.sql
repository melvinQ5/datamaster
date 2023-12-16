/*
10������10�µ���ҵ��
*/

with 
newcateg as ( -- ����Ŀӳ��
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = 'С�����' and bpv.ChineseValueName is Not null
)

, tmp_epp as (
select
	n.ChineseValueName as newpath1-- ����Ŀ1��
 	, epp.BoxSKU 
 	, epp.SKU 
 	, epp.SPU 
 	, epp.DevelopLastAuditTime 
 	, epp.DevelopUserName 
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.erp_product_products epp
join newcateg n on n.sku = epp.SKU -- ֻ�����д��·����ǩ��sku
where epp.DevelopLastAuditTime >= '2022-10-01' and epp.DevelopLastAuditTime <= '2022-10-31' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
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
			where TransactionType = '����'  and OrderStatus <> '����' group by BoxSku) tmp_min on tmp_min.BoxSku =od.BoxSku 
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

-- sku��ϸ���
select newpath1, round(sum(AfterTax_TotalGross),2) `�ۼ�����`
from orders od
group by newpath1
