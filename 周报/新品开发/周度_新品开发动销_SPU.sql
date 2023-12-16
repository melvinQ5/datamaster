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
 	, epp.DevelopLastAuditTime as DevelopLastAuditTime
    , tmp_min.min_pubtime
 	, epp.DevelopUserName
 	, de.dep2
 	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then 'GMתPM'
		when epp.SkuSource=3 then '�ɼ�' when epp.SkuSource is null then '��ԴΪ��' end  SkuSource_cn -- `sku��Դ`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(epp.DevelopLastAuditTime) = dd.full_date
left join (
	select case when sku = '����' then '����1688' else sku end  as name
	,boxsku as department
	,case when spu = '��Ʒ��' then 'Ȫ����Ʒ��' when sku='֣���' then 'Ȫ����Ʒ��' else '�ɶ���Ʒ��' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
left join ( select SPU, min(MinPublicationDate) as min_pubtime from import_data.wt_listing wl join mysql_store ms on wl.shopcode = ms.code
    where IsDeleted = 0 group by SPU
    ) tmp_min on tmp_min.SPU =epp.SPU
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0
	and epp.ProjectTeam ='��ٻ�'
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
			where TransactionType = '����'   group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku
		left join (select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl group by BoxSku )  wl on  wl.BoxSku = od.boxsku 
		) tmp
	) tmp2
-- where boxsku =4543290
)


, join_listing as (
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
     , WEEKOFYEAR(MinPublicationDate) +1  as pub_week ,t.dev_week  ,t.dep2
	, eaal.MinPublicationDate ,eaal.ListingStatus ,ms.ShopStatus
from import_data.wt_listing  eaal
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='��ٻ�' 
join tmp_epp t on  eaal.sku = t.SKU
)

-- ����14�충����
-- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )

, res as (
select dd.week_begin_date as ���յ�����һ ,union_tmp.*
from (
	select '��ٻ�' �����Ŷ�,'����' `����ά��`, tmp.dev_week `�����ܴ�`, DevelopUserName `������Ա`
	    , dev_cnt `����spu��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	    , ord14_sku_sales `����14�����۶�`
	    , ord30_sku_sales `����30�����۶�`
	    ,ord30_sku_sales_since_od `�׵�30�����۶�`
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
	    , dep_pub_online_cnt `��������SPU��`
	from (
		select t.dev_week, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt

			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 14 then od.SPU end) as ord14_sku_cnt_since_lst
			, count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst <= 30 then od.SPU end) as ord30_sku_cnt_since_lst

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
		) tmp
	left join (
	    select dev_week 
	         ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
	         ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
	         ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
	    from
            ( select t.dev_week ,od.SPU
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week ,od.SPU
            ) ta
	    group by dev_week 
	    ) tmp2 on tmp.dev_week =tmp2.dev_week
	left join ( select dev_week
	            ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '����' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week  ) tmp3 on  tmp.dev_week = tmp3.dev_week


    union all
	select '��ٻ��ɶ�' �����Ŷ� ,'����' `����ά��`, tmp.dev_week `�����ܴ�`, DevelopUserName `������Ա`
	     , dev_cnt `����spu��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	     , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	     , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	     , ord14_sku_sales `����14�����۶�`
	     , ord30_sku_sales `����30�����۶�`
	     ,ord30_sku_sales_since_od `�׵�30�����۶�`
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
	    , dep_pub_online_cnt `��������SPU��`
	from (
		select t.dev_week, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
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

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '�ɶ�' group by t.dev_week
		) tmp
	left join (
	    select dev_week
	        ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
	         ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
	         ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
	    from
            ( select t.dev_week ,od.SPU
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '�ɶ�' group by t.dev_week ,od.SPU
            ) ta
	    group by dev_week ) tmp2 on tmp.dev_week =tmp2.dev_week
	left join ( select dev_week  ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '����' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week ) tmp3 on tmp.dev_week = tmp3.dev_week

    union all
	select '��ٻ�Ȫ��' �����Ŷ� ,'����' `����ά��`, tmp.dev_week `�����ܴ�`, tmp.DevelopUserName `������Ա`

	     , dev_cnt `����spu��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	     , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	     , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	     , ord14_sku_sales `����14�����۶�`
	     , ord30_sku_sales `����30�����۶�`
	     ,ord30_sku_sales_since_od `�׵�30�����۶�`
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
	    , dep_pub_online_cnt `��������SPU��`
	from (
		select t.dev_week, '�����ϼ�' as DevelopUserName, '��Դ�ϼ�' as SkuSource_cn
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

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp 'Ȫ��' group by t.dev_week
		) tmp
	left join (
	    select dev_week
	         ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
	         ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
	         ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
	    from
            ( select t.dev_week ,od.SPU
                 , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp 'Ȫ��' group by t.dev_week ,od.SPU
            ) ta
	    group by dev_week ) tmp2 on tmp.dev_week =tmp2.dev_week
	left join ( select dev_week ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '����' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week  ) tmp3 on tmp.dev_week= tmp3.dev_week



	union all
	select '��ٻ�' �����Ŷ� ,'����/������Ա'  `����ά��`, tmp.dev_week `�����ܴ�`, tmp.DevelopUserName `������Ա`

	    , dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	    , ord14_sku_sales `����14�����۶�`
	    , ord30_sku_sales `����30�����۶�`
	    ,ord30_sku_sales_since_od `�׵�30�����۶�`
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
        , dep_pub_online_cnt `��������SPU��`
	from (
		select t.dev_week, t.DevelopUserName
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

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU
		group by t.dev_week, t.DevelopUserName
		) tmp
	left join ( select dev_week ,DevelopUserName ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '����' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week ,DevelopUserName ) tmp3
		on tmp.dev_week = tmp3.dev_week and tmp.DevelopUserName = tmp3.DevelopUserName
	left join (
	    select dev_week ,DevelopUserName
	         ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_sku_cnt_since_lst
	         ,count( case when ord14_orders_since_lst >= 2 then SPU end ) as ord14_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 2 then SPU end ) as ord30_sale2_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_lst
	         ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_sku_cnt_since_dev
	         ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_sku_cnt_since_dev
	    from
            ( select t.dev_week ,od.SPU , t.DevelopUserName
                 , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
                , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
                , count(distinct case when 0 <= ord_days and ord_days  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week ,od.SPU  ,t.DevelopUserName
            ) ta
	    group by dev_week , DevelopUserName ) tmp2 on tmp.dev_week =tmp2.dev_week and tmp.DevelopUserName = tmp2.DevelopUserName

	union all
	select '��ٻ�' �����Ŷ� ,'����/�����Ŷ�'  `����ά��`, tmp.dev_week `�����ܴ�`, tmp.dep2 `�����Ŷ�`
	    , dev_cnt `����sku��`
		, round(ord7_sku_cnt/dev_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt/dev_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt/dev_cnt,4) as `����30�춯����`
		, ord7_sku_sales `����7�����۶�`
	    , ord14_sku_sales `����14�����۶�`
	    , ord30_sku_sales `����30�����۶�`
	    ,ord30_sku_sales_since_od `�׵�30�����۶�`
	    , null ����30���3��ռ��
	    , null ����30���6��ռ��
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `����7�춯����`
	    , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `����14�춯����`
	    , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `����30�춯����`
	    , null `����14���1��ռ��`
	    , null `����14���2��ռ��`
	    , null `����30���1��ռ��`
	    , null `����30���2��ռ��`
	    , null `����30���3��ռ��`
	    , null `����30���6��ռ��`
	    , null  `��������SPU��`
	from (
		select  t.dev_week, t.dep2
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

			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
			, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od
		from tmp_epp t
		left join orders od on od.BoxSku =t.BoxSKU
		where t.dep2 regexp 'Ȫ����Ʒ��|�ɶ���Ʒ��'
		group by t.dev_week, t.dep2
		) tmp
	left join ( select dev_week ,dep2 ,count(distinct spu) dev_pub_cnt from join_listing group by dev_week ,dep2 ) tmp3
	on tmp.dev_week = tmp3.dev_week and tmp.dep2 = tmp3.dep2 
) union_tmp
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date) dd on year('2023-01-01') = dd.year and union_tmp.`�����ܴ�` = dd.week_num_in_year
)

select
    ���յ�����һ
    ,`�����Ŷ�`
    ,`����ά��`
    ,`�����ܴ�`
    ,`������Ա`
    ,`����spu��`
    ,`����7�춯����`
    ,`����14�춯����`
    ,`����30�춯����`
    ,`����7�����۶�`
    ,`����14�����۶�`
    ,`����30�����۶�`
    ,`�׵�30�����۶�`
    ,`����30���3��ռ��`
    ,`����30���6��ռ��`
    ,case when `����7�춯����` < `����7�춯����` then `����7�춯����` else `����7�춯����` end `����7�춯����`
    ,case when `����14�춯����` < `����14�춯����` then `����14�춯����` else `����14�춯����` end `����14�춯����`
    ,case when `����30�춯����` < `����30�춯����` then `����30�춯����`else `����30�춯����` end `����30�춯����`
    ,`����14���1��ռ��`
    ,`����14���2��ռ��`
    ,`����30���1��ռ��`
    ,`����30���2��ռ��`
     ,case when `����30���3��ռ��` < `����30���3��ռ��` then `����30���3��ռ��` else `����30���3��ռ��`  end `����30���3��ռ��`
     ,case when `����30���6��ռ��` < `����30���6��ռ��` then `����30���6��ռ��` else `����30���6��ռ��` end `����30���6��ռ��`
    ,`��������SPU��`
from  res 
order by  `����ά��`, `�����ܴ�`, `�����Ŷ�`, `������Ա` 