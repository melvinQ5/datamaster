/*
新品开发N天出单率=对应PM出单SKU数/开发完成SKU数
对开发终审时间按周来分组sk，计算每个sku的首单天数。

每个sku只有一个 首单天数（最早出单日期-开发完成日期）,每笔订单的每个sku只有1个 首单天数,
按首单天数，则"30天首单动销率"的业务含义是：7月开发完成的sku中，有多少个能在30天内就能至少开出1单

对于GM转PM（有开发终审时间且skuSource=2的SKU），即SKU先跟卖出效果的，我们进行SKU开发终审，然后让二部三部去卖。
所以计算其最早出单时间的时候也是开发终审之后，因此其首单天数也为正数。
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
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(epp.DevelopLastAuditTime) = dd.full_date
left join (
	select case when sku = '李琴' then '李琴1688' else sku end  as name
	,boxsku as department
	,case when spu = '商品组' then '泉州商品组' when sku='郑燕飞' then '泉州商品组' else '成都商品组' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
left join ( select SPU, min(MinPublicationDate) as min_pubtime from import_data.wt_listing wl join mysql_store ms on wl.shopcode = ms.code
    where IsDeleted = 0 group by SPU
    ) tmp_min on tmp_min.SPU =epp.SPU
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0
	and epp.ProjectTeam ='快百货'
)


, orders as (
select * from (
	select tmp.*
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days
		, timestampdiff(SECOND,min_paytime,PayTime)/86400 as ord_days_since_od
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- 处理终审时间大于最早刊登时间的脏数据,以最终刊登时间为终审，避免刊登动销率小于了终审动销率
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
			and ms.Department ='快百货' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0
			and ms1.Department ='快百货' and PayTime >= '2023-01-01'
			where TransactionType = '付款'   group by BoxSku
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
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='快百货' 
join tmp_epp t on  eaal.sku = t.SKU
)

-- 刊登14天订单数
-- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )

, res as (
select dd.week_begin_date as 对照当周周一 ,union_tmp.*
from (
	select '快百货' 出单团队,'日期' `分析维度`, tmp.dev_week `终审周次`, DevelopUserName `开发人员`
	    , dev_cnt `开发spu数`
		, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`
	    , round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`
	    , round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
		, ord7_sku_sales `终审7天销售额`
	    , ord14_sku_sales `终审14天销售额`
	    , ord30_sku_sales `终审30天销售额`
	    ,ord30_sku_sales_since_od `首单30天销售额`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `终审30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `终审30天出6单占比`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登7天动销率`
	     , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天动销率`
	     , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天动销率`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出1单占比`
	     , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出2单占比`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出1单占比`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出2单占比`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出6单占比`
	    , dep_pub_online_cnt `刊登在线SPU数`
	from (
		select t.dev_week, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
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
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week  ) tmp3 on  tmp.dev_week = tmp3.dev_week


    union all
	select '快百货成都' 出单团队 ,'日期' `分析维度`, tmp.dev_week `终审周次`, DevelopUserName `开发人员`
	     , dev_cnt `开发spu数`
		, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`
	     , round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`
	     , round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
		, ord7_sku_sales `终审7天销售额`
	     , ord14_sku_sales `终审14天销售额`
	     , ord30_sku_sales `终审30天销售额`
	     ,ord30_sku_sales_since_od `首单30天销售额`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `终审30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `终审30天出6单占比`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登7天动销率`
	     , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天动销率`
	     , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天动销率`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出1单占比`
	     , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出2单占比`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出1单占比`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出2单占比`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出6单占比`
	    , dep_pub_online_cnt `刊登在线SPU数`
	from (
		select t.dev_week, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
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
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '成都' group by t.dev_week
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
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '成都' group by t.dev_week ,od.SPU
            ) ta
	    group by dev_week ) tmp2 on tmp.dev_week =tmp2.dev_week
	left join ( select dev_week  ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week ) tmp3 on tmp.dev_week = tmp3.dev_week

    union all
	select '快百货泉州' 出单团队 ,'日期' `分析维度`, tmp.dev_week `终审周次`, tmp.DevelopUserName `开发人员`

	     , dev_cnt `开发spu数`
		, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`
	     , round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`
	     , round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
		, ord7_sku_sales `终审7天销售额`
	     , ord14_sku_sales `终审14天销售额`
	     , ord30_sku_sales `终审30天销售额`
	     ,ord30_sku_sales_since_od `首单30天销售额`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `终审30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `终审30天出6单占比`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登7天动销率`
	     , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天动销率`
	     , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天动销率`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出1单占比`
	     , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出2单占比`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出1单占比`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出2单占比`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出6单占比`
	    , dep_pub_online_cnt `刊登在线SPU数`
	from (
		select t.dev_week, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
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
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '泉州' group by t.dev_week
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
            from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU and NodePathName regexp '泉州' group by t.dev_week ,od.SPU
            ) ta
	    group by dev_week ) tmp2 on tmp.dev_week =tmp2.dev_week
	left join ( select dev_week ,count(distinct spu) dev_pub_cnt
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then spu end ) dep_pub_online_cnt
	            from join_listing group by dev_week  ) tmp3 on tmp.dev_week= tmp3.dev_week



	union all
	select '快百货' 出单团队 ,'日期/开发人员'  `分析维度`, tmp.dev_week `终审周次`, tmp.DevelopUserName `开发人员`

	    , dev_cnt `开发sku数`
		, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`
	    , round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`
	    , round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
		, ord7_sku_sales `终审7天销售额`
	    , ord14_sku_sales `终审14天销售额`
	    , ord30_sku_sales `终审30天销售额`
	    ,ord30_sku_sales_since_od `首单30天销售额`
	    , round(ord30_sale3_sku_cnt_since_dev/dev_cnt,4) as `终审30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_dev/dev_cnt,4) as `终审30天出6单占比`
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登7天动销率`
	    , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天动销率`
	    , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天动销率`
	    , round(ord14_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出1单占比`
	     , round(ord14_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天出2单占比`
	    , round(ord30_sale1_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出1单占比`
	    , round(ord30_sale2_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出2单占比`
	    , round(ord30_sale3_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出3单占比`
	    , round(ord30_sale6_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天出6单占比`
        , dep_pub_online_cnt `刊登在线SPU数`
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
	            ,count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then spu end ) dep_pub_online_cnt
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
	select '快百货' 出单团队 ,'日期/开发团队'  `分析维度`, tmp.dev_week `终审周次`, tmp.dep2 `开发团队`
	    , dev_cnt `开发sku数`
		, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`
	    , round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`
	    , round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
		, ord7_sku_sales `终审7天销售额`
	    , ord14_sku_sales `终审14天销售额`
	    , ord30_sku_sales `终审30天销售额`
	    ,ord30_sku_sales_since_od `首单30天销售额`
	    , null 终审30天出3单占比
	    , null 终审30天出6单占比
		, round(ord7_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登7天动销率`
	    , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登14天动销率`
	    , round(ord30_sku_cnt_since_lst/dev_pub_cnt,4) as `刊登30天动销率`
	    , null `刊登14天出1单占比`
	    , null `刊登14天出2单占比`
	    , null `刊登30天出1单占比`
	    , null `刊登30天出2单占比`
	    , null `刊登30天出3单占比`
	    , null `刊登30天出6单占比`
	    , null  `刊登在线SPU数`
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
		where t.dep2 regexp '泉州商品组|成都商品组'
		group by t.dev_week, t.dep2
		) tmp
	left join ( select dev_week ,dep2 ,count(distinct spu) dev_pub_cnt from join_listing group by dev_week ,dep2 ) tmp3
	on tmp.dev_week = tmp3.dev_week and tmp.dep2 = tmp3.dep2 
) union_tmp
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date) dd on year('2023-01-01') = dd.year and union_tmp.`终审周次` = dd.week_num_in_year
)

select
    对照当周周一
    ,`出单团队`
    ,`分析维度`
    ,`终审周次`
    ,`开发人员`
    ,`开发spu数`
    ,`终审7天动销率`
    ,`终审14天动销率`
    ,`终审30天动销率`
    ,`终审7天销售额`
    ,`终审14天销售额`
    ,`终审30天销售额`
    ,`首单30天销售额`
    ,`终审30天出3单占比`
    ,`终审30天出6单占比`
    ,case when `刊登7天动销率` < `终审7天动销率` then `终审7天动销率` else `刊登7天动销率` end `刊登7天动销率`
    ,case when `刊登14天动销率` < `终审14天动销率` then `终审14天动销率` else `刊登14天动销率` end `刊登14天动销率`
    ,case when `刊登30天动销率` < `终审30天动销率` then `终审30天动销率`else `刊登30天动销率` end `刊登30天动销率`
    ,`刊登14天出1单占比`
    ,`刊登14天出2单占比`
    ,`刊登30天出1单占比`
    ,`刊登30天出2单占比`
     ,case when `刊登30天出3单占比` < `终审30天出3单占比` then `终审30天出3单占比` else `刊登30天出3单占比`  end `刊登30天出3单占比`
     ,case when `刊登30天出6单占比` < `终审30天出6单占比` then `终审30天出6单占比` else `刊登30天出6单占比` end `刊登30天出6单占比`
    ,`刊登在线SPU数`
from  res 
order by  `分析维度`, `终审周次`, `出单团队`, `开发人员` 