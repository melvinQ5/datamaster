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
 	, date(DevelopLastAuditTime) as dev_date
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
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days
		, timestampdiff(SECOND,min_paytime,PayTime)/86400 as ord_days_since_od
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- ��������ʱ��������翯��ʱ���������,�����տ���ʱ��Ϊ���󣬱��⿯�Ƕ�����С������������
	from (
		select od.PlatOrderNumber
			,  epp.DevelopLastAuditTime
			, od.PayTime , ms.Department ,ms.NodePathName
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime as min_paytime
			, wl.min_pubtime
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
		left join (select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl group by BoxSku )  wl on  wl.BoxSku = od.boxsku
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


, t1 as (  -- ά��1
	select '����' `����ά��`, tmp.dev_month `������`, tmp.DevelopUserName `������Ա`, dev_cnt `����SPU��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	    , ord14_sku_sales `����14�����۶�`
	    , ord30_sku_sales `����30�����۶�`
	    , ord_all_sku_sales `�����������۶�`
	    , ord30_sku_sales_since_od `�׵�30�����۶�`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `����30���3��ռ��`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `����30���6��ռ��`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `����7�춯����`
	     , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `����14�춯����`
	     , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `����30�춯����`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `����14���1��ռ��`
	     , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `����14���2��ռ��`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���1��ռ��`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���2��ռ��`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���3��ռ��`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���6��ռ��`
		from (
		select t.dev_month, '�����ϼ�' as DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt

			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then od.SPU end) as ord30_sku_cnt_since_lst

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days  then AfterTax_TotalGross end)) as ord_all_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month
		) tmp
        left join (
            select dev_month
                 ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
                 ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
                 ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
            from
                ( select t.dev_month ,od.SPU
                    , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                    , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                    , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
                from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month ,od.SPU
                ) ta
            group by dev_month
            ) tmp2 on tmp.dev_month =tmp2.dev_month
		left join ( select dev_month
            ,count( distinct  spu ) dev_pub_cnt
            from join_listing group by dev_month ) tmp3
            on tmp.dev_month = tmp3.dev_month
)

, t2 as (
   select '����/������Ա' `����ά��`, tmp.dev_month `������`, tmp.DevelopUserName `������Ա`, dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	    , ord14_sku_sales `����14�����۶�`
	    , ord30_sku_sales `����30�����۶�`
        , ord_all_sku_sales `�����������۶�`
	    , ord30_sku_sales_since_od `�׵�30�����۶�`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `����30���3��ռ��`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `����30���6��ռ��`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `����30�춯����`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `����14���1��ռ��`
	    , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `����14���2��ռ��`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���1��ռ��`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���2��ռ��`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���3��ռ��`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `����30���6��ռ��`
	from ( select t.dev_month, t.DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt

			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then od.SPU end) as ord30_sku_cnt_since_lst

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
	        , round(sum(case when 0 <= ord_days  then AfterTax_TotalGross end)) as ord_all_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU
		group by t.dev_month, t.DevelopUserName
		) tmp
	    left join (
            select dev_month ,DevelopUserName
                 ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
                 ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
                 ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
                 ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
            from
                ( select t.dev_month ,t.DevelopUserName,od.SPU
                    , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                    , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                    , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
                from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month ,t.DevelopUserName,od.SPU
                ) ta
            group by dev_month ,DevelopUserName
            ) tmp2 on tmp.dev_month =tmp2.dev_month and tmp.DevelopUserName = tmp2.DevelopUserName
		left join ( select dev_month ,DevelopUserName
		,count( distinct  spu ) dev_pub_cnt
		from join_listing group by dev_month , DevelopUserName ) tmp3
		on tmp.dev_month  = tmp3.dev_month and tmp.DevelopUserName =tmp3.DevelopUserName
)

-- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
, res as  (
    select * from t1
    union all select * from t2
)

select
    `����ά��`
    ,`������`
    ,`������Ա`
    ,`����spu��`
    ,`����7�춯����`
    ,`����14�춯����`
    ,`����30�춯����`
    ,`����7�����۶�`
    ,`����14�����۶�`
    ,`����30�����۶�`
    ,`�����������۶�`
    ,`�׵�30�����۶�`
    ,`����30���3��ռ��`
    ,`����30���6��ռ��`
    ,case when `����7�춯����` < `����7�춯����` then `����7�춯����` else `����7�춯����` end `����7�춯����`
    ,case when `����14�춯����` < `����14�춯����` then `����14�춯����` else `����14�춯����` end `����14�춯����`
    ,case when `����30�춯����` < `����30�춯����` then `����30�춯����`else `����30�춯����` end `����30�춯����`
    ,`����14�춯����`
    ,`����30�춯����`
    ,`����14���1��ռ��`
    ,`����14���2��ռ��`
    ,`����30���1��ռ��`
    ,`����30���2��ռ��`
     ,case when `����30���3��ռ��` < `����30���3��ռ��` then `����30���3��ռ��` else `����30���3��ռ��`  end `����30���3��ռ��`
     ,case when `����30���6��ռ��` < `����30���6��ռ��` then `����30���6��ռ��` else `����30���6��ռ��` end `����30���6��ռ��`
from  res
order by  `����ά��`, `������`, `������Ա`