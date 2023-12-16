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
		epp.DevelopUserName as dev_user -- �������������Ķ�Ӧ������Ա
	 	, month(DevelopLastAuditTime) as dev_month
	 	, n.ChineseValueName as newpath1-- ����Ŀ1��
	 	, epp.BoxSKU 
	 	, epp.SKU
	  	, epp.SkuSource 
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
union all 
	select dev_month, '�ϼ�' as dev_user, '�ϼ�' newpath1 , count(sku) as ÿ������ͨ��SKU��
	from tmp_epp
	where dev_user is not null 
	group by dev_month
)

-- �����2 ÿ������������
, join_listing as ( -- ����������ϸ������������Ա����
select dev_month, Department , dev_user, newpath1, eaal.Id , month(eaal.PublicationDate) as pub_month , PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������') and ms.ShopStatus='����'
join tmp_epp on  eaal.sku = tmp_epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate>'2022-01-01' and dev_month <= month(eaal.PublicationDate) 
)

, listing_online_cnt as ( -- ��Ϊ�ǻ�����ʷ���ݣ��Ե�ǰ���ݿ�״̬�Ŀ���ʱ��С�ڴ��µ�һ�죬��Ϊ������������
-- ÿ�¹�����ۺ����ȣ�group by���������� 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `����������`
	from (select dev_month, Department, dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, Department, dev_user, newpath1, pub_month ) a 
union all 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `����������`
	from (select dev_month, 'PM' as Department, dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, dev_user, newpath1, pub_month ) a 
union all 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `����������`
	from (select dev_month, 'PM' as Department, '�ϼ�' as dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, newpath1, pub_month ) a 
union all -- �ܺϼ�
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `����������`
	from (select dev_month, 'PM' as Department, '�ϼ�' as dev_user, '�ϼ�' as newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, pub_month ) a 
)

-- �����3 �¶ȳ���ָ�� �� ���ۼӳ���ָ��
, join_orders as ( -- ɸѡ���ڿ���sku�Ķ�����ϸ
select tmp_epp.dev_month, ms.Department, tmp_epp.dev_user, tmp_epp.newpath1
	, month(PayTime) as pay_month, concat(SellerSku, ShopIrobotId) as ord_listing_id
	, (if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalGross
	, (if(TaxGross>0, TotalProfit, TotalProfit-(TotalGross*IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalProfit
	, od.*
from import_data.OrderDetails od 
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('���۶���', '��������')
-- left join 
-- 	( -- ������ʷ���»���
-- 	select left(firstday,7) as RatioMonth, DepSite, reporttype, TaxRatio
-- 	from import_data.Basedata
-- 	where reporttype = '�±�' 
-- 	group by RatioMonth, DepSite, reporttype, TaxRatio
-- 	) t
-- 	on t.DepSite = RIGHT(od.ShopIrobotId,2)  and t.RatioMonth = left(od.PayTime,7) 
left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
join import_data.erp_product_products epp on od.BoxSku =epp.BoxSKU 
join tmp_epp on od.BoxSku =tmp_epp.BoxSKU
left join 
	( -- ������ʷ��������˶���
	select OrderNumber from (select OrderNumber, GROUP_CONCAT(TransactionType) alltype 
		FROM import_data.OrderDetails od
		where ShipmentStatus = 'δ����' and OrderStatus = '����' and SettlementTime >= '2021-01-01'
		group by OrderNumber) a
	where alltype = '����'
	) b 
	on b.OrderNumber = od.OrderNumber
where b.OrderNumber is null  
	and tmp_epp.dev_month <= month(PayTime) and od.PayTime >= '2022-01-01' 
	and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0
)

, ord_meric as ( -- �¶ȳ���ָ�꣬������ۺ����ȣ�group by��
	select dev_month, pay_month, Department , dev_user, newpath1 
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum(AfterTax_TotalGross)) `�¶����۶�USD` 
		, round(sum(AfterTax_TotalProfit)) `�¶������USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, Department, dev_user, newpath1 -- ��Ŀ+����+����
union all
	select dev_month, pay_month,'PM' as Department, dev_user, newpath1
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum(AfterTax_TotalGross)) `�¶����۶�USD` 
		, round(sum(AfterTax_TotalProfit)) `�¶������USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, dev_user, newpath1 -- ��Ŀ+���ۺϼ�+����
union all  
	select dev_month, pay_month,'PM' as Department, '�ϼ�' dev_user, newpath1
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum(AfterTax_TotalGross)) `�¶����۶�USD` 
		, round(sum(AfterTax_TotalProfit)) `�¶������USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month, newpath1 -- ��Ŀ+���ۺϼ�+�����ϼ�
union all  
	select dev_month, pay_month,'PM' as Department, '�ϼ�' dev_user, '�ϼ�' newpath1
		, count(distinct BoxSku) `�¶ȳ���sku��`
		, round(sum(AfterTax_TotalGross)) `�¶����۶�USD` 
		, round(sum(AfterTax_TotalProfit)) `�¶������USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `�¶�������` 
		, count(distinct PlatOrderNumber) `������`
		, count(distinct concat(SellerSku, ShopIrobotId)) `����������`
	from join_orders
	group by dev_month, pay_month -- ��Ŀ�ϼ�+���ۺϼ�+�����ϼ�
)
-- ���ۼӳ���sku��
-- �ۼӼ���˼·����һ��ͳ������sku�״γ�����1�Σ����������ۼơ�
-- ������������ÿ���������boxsku �Ȱ�����ʱ�����򣬶����Ϊ1��ֵ��ͣ�����ÿ���·ݿ�����
, ord_meric_running_total_partA as ( -- ���ۼ�ָ���һ���֣�ȥ�صĳ���sku���������ӡ�����
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���sku��`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӶ�����`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���������`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month, Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- ��ÿ���������boxsku ��pay_month����	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���sku��`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӶ�����`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���������`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- ��ÿ���������boxsku ��pay_month����	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���sku��`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӶ�����`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���������`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, '�ϼ�' as dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- ��ÿ���������boxsku ��pay_month����	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���sku��`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӶ�����`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `���ۼӳ���������`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, '�ϼ�' as dev_user, '�ϼ�' as newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- ��ÿ���������boxsku ��pay_month����	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
)

, ord_meric_running_total_partB as ( -- ���ۼ�ָ��ڶ����֣�
	select * , round(`���ۼ������USD`/`���ۼ����۶�USD`,2) as `���ۼ�������`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ����۶�USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ������USD`
		from ( select dev_month, Department, dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, Department, dev_user, newpath1, pay_month 
			) tmp1 
		) tmp2
union all
	select * , round(`���ۼ������USD`/`���ۼ����۶�USD`,2) as `���ۼ�������`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ����۶�USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ������USD`
		from ( select dev_month,'PM' as Department, dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, dev_user, newpath1, pay_month 
			) tmp1 
		) tmp2
union all
	select * , round(`���ۼ������USD`/`���ۼ����۶�USD`,2) as `���ۼ�������`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ����۶�USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ������USD`
		from ( select dev_month,'PM' as Department, '�ϼ�' as dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, newpath1, pay_month 
			) tmp1 
		) tmp2	
union all
	select * , round(`���ۼ������USD`/`���ۼ����۶�USD`,2) as `���ۼ�������`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ����۶�USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `���ۼ������USD`
		from ( select dev_month,'PM' as Department, '�ϼ�' as dev_user, '�ϼ�' as newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, pay_month 
			) tmp1 
		) tmp2	
)

, ord_meric_running_total as ( -- ���ۼ�ָ�������ֺϲ�
select a.dev_month, a.Department, a.dev_user, a.newpath1, a.pay_month
	, `���ۼӶ�����`, `���ۼ����۶�USD`, `���ۼ������USD`, `���ۼ�������`, `���ۼӳ���sku��`, `���ۼӳ���������`
from ord_meric_running_total_partA a
join ord_meric_running_total_partB b 
	on a.dev_month=b.dev_month and a.Department=b.Department and a.dev_user=b.dev_user and a.newpath1=b.newpath1 and a.pay_month=b.pay_month
)

-- =============== ��excel�� ==================
-- ==== sheet1 �¶ȳ���ָ��
-- select o.dev_month `�����·�`, o.Department `���۲���`, o.dev_user `������Ա`, o.newpath1 `��Ŀ`, o.pay_month `�����·�`
-- 	, `������`, `�¶����۶�USD`, `�¶������USD`, `�¶�������`, `�¶ȳ���sku��`, `����������`
-- 	, a.ÿ������ͨ��SKU��, round(o.�¶ȳ���SKU��/a.ÿ������ͨ��SKU��,4) as `SKU������`
-- 	, l.����������, round(o.����������/l.����������,4) as `���Ӷ�����`
-- 	, round(l.����������/a.ÿ������ͨ��SKU��,1) as `SKUƽ������������`
-- from listing_online_cnt l
-- left join ord_meric o
-- 	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.pub_month and l.Department = o.Department
-- left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
-- where o.dev_user is not null 
-- order by o.dev_month, o.pay_month , o.dev_user, o.newpath1

-- ==== sheet2 ���ۼƳ���ָ�� + SKU������
select o.dev_month `�����·�`, o.Department `���۲���`, o.dev_user `������Ա`, o.newpath1 `��Ŀ`, o.pay_month `�����·�`
	, `���ۼӶ�����`, `���ۼ����۶�USD`, `���ۼ������USD`, `���ۼ�������`, `���ۼӳ���sku��`, `���ۼӳ���������`
	, a.ÿ������ͨ��SKU��, round(o.���ۼӳ���SKU��/a.ÿ������ͨ��SKU��,4) as `�ۼ�SKU������`
	, l.����������, round(o.���ۼӳ���������/l.����������,4) as `�ۼ����Ӷ�����`
	, round(l.����������/a.ÿ������ͨ��SKU��,1) as `�ۼ�SKUƽ������������`
from listing_online_cnt l
left join ord_meric_running_total o
	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.pub_month and l.Department = o.Department
left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
where o.dev_user is not null 
order by o.dev_month, o.pay_month , o.dev_user, o.newpath1
