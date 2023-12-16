/*
Ŀ�꣺������Ŀ1��������ʷ�·����ݣ������¶ȳ���ָ�ꡢ���ۼӳ���ָ��
����ƫ�
	1.ͳһʹ�õ�ǰ״̬�����ݣ�����4~10������״̬���ӡ�δɾ��sku������
����ṹ��
	��������׼��2����ʱ��ѯ�����������Ŀӳ�䡢ɸѡ��Ĳ�Ʒ��
	�����1��ÿ�¿���sku������������
	�����2��ÿ������������
	�����3���¶ȳ���ָ�ꡢ���ۼӳ���ָ��
	�������ݼ���
*/
with 
-- ������
newcateg as ( -- ����Ŀӳ��
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = 'С�����' and bpv.ChineseValueName is Not null
)

, tmp_epp as ( -- ����Ʒ�����Ӹ����У�����ͬ������Ա����������ʱ�䡢��������������ϳ�һ����ʱ�������븴�ã� 
select dev_month,dev_user,newpath1,BoxSKU,SKU 
from (
	select
		case when epp.DevelopUserName='����' and epp.DevelopLastAuditTime >= '2022-04-02' then '����'
	 	when epp.DevelopUserName='��ٻ' and epp.DevelopLastAuditTime >= '2022-07-04' then '��ٻ'
	 	when epp.DevelopUserName='����1688' and epp.DevelopLastAuditTime >= '2022-07-04' 
	 		and epp.SkuSource=1 then '����1688'
	 	when epp.DevelopUserName='��÷' and epp.DevelopLastAuditTime >= '2022-07-04'then '��÷'
	 	when epp.DevelopUserName='����ϼ' and epp.DevelopLastAuditTime >= '2022-07-04' then '����ϼ'
	 	when epp.DevelopUserName not in ('��÷','����ϼ','����1688','����') and epp.DevelopLastAuditTime >= '2022-04-01' 
	 		and epp.SkuSource=2 then '�µ���_GMתPM'
	 	end as dev_user -- �������������Ķ�Ӧ������Ա
	 	, month(DevelopLastAuditTime) as dev_month
	 	, n.ChineseValueName as newpath1-- ����Ŀ1��
	 	, epp.BoxSKU 
	 	, epp.SKU
	from import_data.erp_product_products epp
	join erp_product_product_category eppc on epp.ProductCategoryId =eppc.Id 
	join newcateg n on n.sku = epp.SKU -- ֻ�����д��·����ǩ��sku
	where epp.DevelopLastAuditTime >= '2022-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	) tmp
where dev_user is not null  -- ɸѡ��Ʒ����Ա��صĲ�Ʒ����ϸ
group by dev_month,dev_user,newpath1,BoxSKU,SKU
)


-- �����1 ÿ�¿���sku������������
, audited_sku_cnt as ( 
select dev_month, dev_user, newpath1 , count(sku) as ÿ������ͨ��SKU��
from tmp_epp
where dev_user is not null -- ֻ�����Ͽ�����Ա������ʱ�䡢�������������������
group by dev_month, dev_user, newpath1
union all 
select dev_month, '�ϼ�' as dev_user, newpath1 , count(sku) as ÿ������ͨ��SKU��
from tmp_epp
where dev_user is not null -- ֻ�����Ͽ�����Ա������ʱ�䡢�������������������
group by dev_month,  newpath1
)

-- �����2 ÿ������������
, join_listing as ( -- ����������ϸ������������Ա����
select dev_month, Department , dev_user, newpath1,  eaal.Id , month(eaal.PublicationDate) as pub_month , PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������') and ms.ShopStatus='����'
join tmp_epp on  eaal.sku = tmp_epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate>'2022-01-01' and dev_month <= month(eaal.PublicationDate) 
)

, listing_online_cnt as ( -- ��Ϊ�ǻ�����ʷ���ݣ��Ե�ǰ���ݿ�״̬�Ŀ���ʱ��С�ڴ��µ�һ�죬��Ϊ������������
-- ÿ�¹�����ۺ����ȣ�group by���������� 
	select dev_month, 4 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 4 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 4 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, newpath1
union all
	select dev_month, 5 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 5 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 5 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, newpath1
union all
	select dev_month, 6 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 6 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 6 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, newpath1
union all
	select dev_month, 7 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 7 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 7 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, newpath1
union all
	select dev_month, 8 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 8 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 8 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, newpath1
union all
	select dev_month, 9 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 9 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 9 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, newpath1
union all
	select dev_month, 10 as online_month, Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 10 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 10 as online_month, 'PM' as Department , '�ϼ�' as dev_user, newpath1 , count(Id) `����������`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, newpath1
)

-- �����3 �¶ȳ���ָ�� �� ���ۼӳ���ָ��
, join_orders as ( -- ɸѡ���ڿ���sku�Ķ�����ϸ
select tmp_epp.dev_month, ms.Department, tmp_epp.dev_user, tmp_epp.newpath1, b.TaxRatio
	, month(PayTime) as pay_month, od.*
from import_data.OrderDetails od 
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('���۶���', '��������')
left join 
	( -- ������ʷ���»���
	select left(firstday,7) as RatioMonth, DepSite, reporttype, TaxRatio
	from import_data.Basedata
	where reporttype = '�±�' 
	group by RatioMonth, DepSite, reporttype, TaxRatio
	) b
	on b.DepSite = RIGHT(od.ShopIrobotId,2)  and b.RatioMonth = left(od.PayTime,7) 
join import_data.erp_product_products epp on od.BoxSku =epp.BoxSKU 
join tmp_epp on od.BoxSku =tmp_epp.BoxSKU 
where tmp_epp.dev_month <= month(PayTime) and od.PayTime >= '2022-01-01' 
	and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0
)

, ord_meric as ( -- �¶ȳ���ָ�꣬������ۺ����ȣ�group by��
	select dev_month, pay_month, Department , dev_user, newpath1 
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶����۶�USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2)  `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, Department, dev_user, newpath1 -- ��Ŀ+����+����
union all
	select dev_month, pay_month,'PM' as Department, dev_user, newpath1
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶����۶�USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, dev_user, newpath1 -- ��Ŀ+���ۺϼ�+����
union all  
	select dev_month, pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶����۶�USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `�¶������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, newpath1 -- ��Ŀ+���ۺϼ�+�����ϼ�
)

, ord_meric_running_total as ( -- ���ۼӳ���ָ�꣬���¶�ָ�����һ����ÿ����������ۺ����ȣ�group by��
-- 5���ۼ�
	select dev_month, 5 as pay_month, Department , dev_user, newpath1 , count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 5 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������`
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 5 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������`
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 6���ۼ�
	select dev_month, 6 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������`
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 6 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 6 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 7���ۼ�
	select dev_month, 7 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 7 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 7 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 8 ���ۼ�
	select dev_month, 8 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������`
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 8 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 8 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 9 ���ۼ�
	select dev_month, 9 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������`
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 9 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 9 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, newpath1
union all -- 10 ���ۼ�
	select dev_month, 10 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 10 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 10 as pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1, count(distinct BoxSku) `���ۼӳ���sku��`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ����۶�USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `���ۼ������USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `���ۼ�������` 
		, count(distinct PlatOrderNumber) `������`, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, newpath1
)

-- =============== ��excel�� ==================
-- ==== sheet1 �¶ȳ���ָ��
-- select o.*, a.ÿ������ͨ��SKU��, o.�¶ȳ���SKU��/a.ÿ������ͨ��SKU�� as `SKU������`
-- 	, l.����������, round(o.����������/l.����������,4) as `���Ӷ�����`
-- 	, round(l.����������/a.ÿ������ͨ��SKU��,1) as `SKUƽ������������`
-- from listing_online_cnt l
-- left join ord_meric o
-- 	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.online_month and l.Department = o.Department
-- left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
-- where o.dev_user is not null 
-- order by dev_month, pay_month , dev_user, newpath1

-- ==== sheet2 ���ۼƳ���ָ�� + SKU������
select o.*, a.ÿ������ͨ��SKU��, o.���ۼӳ���SKU��/a.ÿ������ͨ��SKU�� as `SKU������`
	, l.����������, round(o.����������/l.����������,4) as `���Ӷ�����`
	, round(l.����������/a.ÿ������ͨ��SKU��,1) as `SKUƽ������������`
from listing_online_cnt l
left join ord_meric_running_total o
	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.online_month and l.Department = o.Department
left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
where o.dev_user is not null 
order by dev_month, pay_month , dev_user, newpath1
