/*
��Ʒ����N�������=��ӦPM����SKU��/�������SKU��
�Կ�������ʱ�䰴��������sk������ÿ��sku���׵�������

ÿ��skuֻ��һ�� �׵������������������-����������ڣ�,ÿ�ʶ�����ÿ��skuֻ��1�� �׵�����,
���׵���������"30���׵�������"��ҵ�����ǣ�7�¿�����ɵ�sku�У��ж��ٸ�����30���ھ������ٿ���1��

����GMתPM���п�������ʱ����skuSource=2��SKU������SKU�ȸ�����Ч���ģ����ǽ���SKU��������Ȼ���ö�������ȥ����
���Լ������������ʱ���ʱ��Ҳ�ǿ�������֮��������׵�����ҲΪ������
*/

with 
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(epp.DevelopLastAuditTime) = dd.full_date
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	AND epp.ProjectTeam ='��ٻ�' 
-- 	and DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','����' ,'��','��ٻ' ,'����1688' ,'������','����') 
)

, orders as ( 
select * from (
	select tmp.* 
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days -- ����ʱ��
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department , epp.dev_week
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
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
	, eaal.MinPublicationDate ,shopcode ,sellersku
from import_data.wt_listing  eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='��ٻ�' and ms.ShopStatus='����'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  and eaal.IsDeleted = 0 
)

-- sku��ϸ���
-- select count(1) from (
select ords.*,jl.`����������`,round(`�ۼƳ���������`/jl.`����������`,4) `���Ӷ�����`
from
	(select  SPU, SKU, BoxSku, DevelopUserName `������Ա`
		, SkuSource_cn `������`, ord_days`�׵�����`
	    , dev_week `�����ܴ�`
		, DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `������������`
		, DATE_FORMAT(min_paytime,'%Y/%m/%d') `�׵�����`
		, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `����ͳ�ƽ�ֹ����`
		, round(sum(AfterTax_TotalGross),2) `�ۼ�����`
		, round(sum(AfterTax_TotalProfit),2) `�ۼ�����`
		, count(distinct PlatOrderNumber) `�ۼƶ�����`
		, count(distinct concat(SellerSku,ShopIrobotId)) `�ۼƳ���������`
		, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 
			then AfterTax_TotalGross end)) as ord30_sku_sales
	from orders group by SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, ord_days, dev_week
		, `������������`, `�׵�����`, `����ͳ�ƽ�ֹ����`
	) ords
left join (
-- 	select SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) ,MinPublicationDate `�״ο���ʱ��`
	select SKU, count(DISTINCT concat(shopcode,sellersku)) `����������`
	from join_listing
	group by SKU
	) jl on ords.SKU = jl.SKU
-- 	) t 
