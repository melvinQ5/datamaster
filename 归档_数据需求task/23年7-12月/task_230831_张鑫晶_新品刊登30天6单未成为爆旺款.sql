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
 	, DevelopLastAuditTime
    , tmp_min.min_pubtime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
left join ( select SPU, min(MinPublicationDate) as min_pubtime from import_data.wt_listing
    where IsDeleted = 0 group by SPU
    ) tmp_min on tmp_min.SPU =epp.SPU
where DevelopLastAuditTime >= '2023-07-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0
	and epp.ProjectTeam ='��ٻ�'
)


, orders as (
select * from (
	select tmp.*
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- ��������ʱ��������翯��ʱ���������,�����տ���ʱ��Ϊ���󣬱��⿯�Ƕ�����С������������
	from (
		select od.PlatOrderNumber
			,  epp.DevelopLastAuditTime 
			, od.PayTime , ms.Department ,ms.NodePathName
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, wl.min_pubtime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join (select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl
            join import_data.mysql_store ms on ms.Code = wl.shopcode and wl.IsDeleted = 0
			and ms.Department ='��ٻ�' group by BoxSku )  wl on  wl.BoxSku = od.boxsku
		) tmp
	) tmp2

)

, t0 as (
select spu ,ord30_orders_since_lst
from
    ( select od.SPU
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
    from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by od.SPU
    ) ta
where ord30_orders_since_lst >= 6
)

select t0.spu ,t0.ord30_orders_since_lst ����30�������
    ,ProductName ��Ʒ����
    ,date(DevelopLastAuditTime) ����ʱ��
    ,DevelopUserName ������Ա
from t0
left join erp_product_products epp on t0.spu =epp.spu and epp.IsDeleted=0 and epp.IsMatrix=1
order by ord30_orders_since_lst asc 