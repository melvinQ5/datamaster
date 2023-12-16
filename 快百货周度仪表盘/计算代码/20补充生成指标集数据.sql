   -- 统计期 团队  指标名称 指标值 分子 分母
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'在线链接数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'  ,count(1) as 指标值 ,0 as 比率分子  ,0 as 比率分母
from (select ShopCode ,SellerSKU ,ASIN,dep2
	from erp_amazon_amazon_listing eaal
	join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on eaal.shopcode=ms.Code
	 and ListingStatus = 1 and ms.ShopStatus = '正常'
	group by shopcode,SellerSku,Asin ,dep2
	) tmp1
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'出单链接数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
	,count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin)) `出单链接数`
    ,0 ,0
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
    and isdeleted = 0 and TransactionType !='其他' and OrderStatus <> '作废'
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'链接动销率' as 指标  ,ifnull(a.dep2,'快百货') as 团队 ,'快百货周报指标表'
	,round(出单链接数/在线链接数,4) ,出单链接数 ,在线链接数
from (select ifnull(dep2,'快百货') dep2 ,count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin)) `出单链接数`
	from wt_orderdetails wo
	join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
		    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
	where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
	    and isdeleted = 0 and TransactionType !='其他' and OrderStatus <> '作废'
	group by grouping sets ((),(dep2))
	) a
join
	(select ifnull(dep2,'快百货') as dep2 ,count(1) as 在线链接数
	from (select ShopCode ,SellerSKU ,ASIN,dep2
		from erp_amazon_amazon_listing eaal
		join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
		    from import_data.mysql_store where department regexp '快')  ms on eaal.shopcode=ms.Code
		 and ListingStatus = 1 and ms.ShopStatus = '正常'
		group by shopcode,SellerSku,Asin ,dep2
		) tmp1
	group by grouping sets ((),(dep2))
	) b
on a.dep2 = b.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'出单链接单产' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
	,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , round(sum(totalgross/ExchangeUSD),2)
    , count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin))
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
    and isdeleted = 0 and TransactionType !='其他' and OrderStatus <> '作废'
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'新刊登链接数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
	,count(1) `新刊登链接数` ,0 ,0
from (select dep2,shopcode,SellerSku,Asin
      from import_data.wt_listing  eaal
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on eaal.shopcode=ms.Code
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}'
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0
	group by dep2,shopcode,SellerSku,Asin
	) tmp1
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'近30天刊登链接数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct shopcode,SellerSku,Asin ) `近30天刊登链接数`
     ,0 ,0
from import_data.wt_listing  eaal
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on eaal.shopcode=ms.Code
where MinPublicationDate >= date_add('${NextStartDay}',interval - 30 day)  and MinPublicationDate <'${NextStartDay}'
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'刊登7天链接单产' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '作废'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 7 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'刊登14天链接单产' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '作废'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 14 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'刊登30天链接单产' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '作废'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 30 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'定制销售额' as 指标  ,ifnull(a.dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round(gross_include_refunds - ifnull(refunds,0),2) ,0 ,0
from (
    select
        ifnull(ms.dep2,'快百货') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
        ,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
        ,count(distinct shopcode) `出单店铺数`
        ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'快百货') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'快百货') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'定制利润额' as 指标  ,ifnull(a.dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
     ,0 ,0
from (
    select
        ifnull(ms.dep2,'快百货') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
        ,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
        ,count(distinct shopcode) `出单店铺数`
        ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'快百货') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'快百货') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'定制利润率' as 指标  ,ifnull(a.dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) /
	        (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
     ,0 ,0
from (
    select
        ifnull(ms.dep2,'快百货') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
        ,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
        ,count(distinct shopcode) `出单店铺数`
        ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'快百货') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'快百货') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'S链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type = '新增S' then CONCAT( asin,site) end ) S链接新增数
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'S链接留存数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type = '留存S' then CONCAT( asin,site) end ) S链接留存数
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'A链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type = '新增A' then CONCAT( asin,site) end ) A链接新增数
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'SA链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type regexp '新增A|新增S' then CONCAT( asin,site) end ) SA链接新增数
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'作废订单率' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `作废订单率`
    ,count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber  end)
    ,count(distinct PlatOrderNumber)
from import_data.wt_orderdetails  wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on wo.shopcode=ms.Code and wo.IsDeleted = 0
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}'
group by grouping sets ((),(ms.dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'非SA链接近30天单产' as 指标  ,ifnull(Department,'快百货') as 团队 ,'快百货周报指标表'
    ,round(sum(case when list_level not regexp  'S|A' then sales_in30d end) /count(case when list_level not regexp  'S|A' then 1 end),2) as 非SA链接近30天单产
    , sum(case when list_level not regexp  'S|A' then sales_in30d end)
    , count(case when list_level not regexp  'S|A' then 1 end)
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
group by grouping sets ((),(Department));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'爆旺款SA链接比' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( SA链接数 /爆旺款spu数,2) , SA链接数 , 爆旺款spu数
from (
select count(case when prod_level regexp '爆款|旺款' then 1 end) 爆旺款spu数
from import_data.dep_kbh_product_level akpl where akpl.FirstDay= '${StartDay}'
)a ,
(
select count(distinct case when list_level regexp 'S|A' then concat(asin,site) end) SA链接数
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
) b;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'月度累计推广链接数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    , count( distinct CONCAT( asin,site)  )
    ,0 ,0
from (
    select distinct c2 as site , c4 as asin ,c5 as dep2
    from import_data.manual_table  where handletime='2023-07-27' and handlename ='潜力链接标签'
    ) t
group by grouping sets ((),(dep2));




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'产品库SPU单产' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( 近30天销售额/产品库SPU数 ,0) ,0 ,0
from (
select
    round(sum((totalgross)/ExchangeUSD),2) 近30天销售额
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '其他'  and asin <>''  and ms.department regexp '快'
)a ,
(select count(distinct wp.spu) `产品库SPU数`
from import_data.wt_products wp
where ProjectTeam = '快百货'
and wp.ProductStatus != 2
and IsDeleted = 0
and DevelopLastAuditTime is not null) b;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'店铺的违规记录总数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,sum(records)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2 ,sum(count) records
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
            , case when itemtype=40 then '涉嫌侵犯知识产权'
            when itemtype=41 then '知识产权投诉'
            when itemtype=42 then '商品真实性买家投诉'
            when itemtype=43 then '商品状况买家投诉'
            when itemtype=44 then '食品和商品安全问题'
            when itemtype=45 then '上架政策违规'
            when itemtype=46 then '违反受限商品政策'
            when itemtype=47 then '违反买家商品评论政策'
            when itemtype=48 then '其他违反政策'
            when itemtype=49 then '违反政策警告'
            when itemtype=50 then '商品安全买家投诉'
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
                from import_data.mysql_store where department regexp '快')  ms  on list.shopcode=ms.Code  and ms.Department='快百货'
            where date(detail.CreationTime)='${NextStartDay}' -- v2表落库时间是统计日的凌晨
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','45','46','48','49')
    group by shopcode,shopstatus,SellUserName ,site ,dep2
    ) a
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'单店铺超过5条违规记录店铺数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct shopcode)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
            , case when itemtype=40 then '涉嫌侵犯知识产权'
            when itemtype=41 then '知识产权投诉'
            when itemtype=42 then '商品真实性买家投诉'
            when itemtype=43 then '商品状况买家投诉'
            when itemtype=44 then '食品和商品安全问题'
            when itemtype=45 then '上架政策违规'
            when itemtype=46 then '违反受限商品政策'
            when itemtype=47 then '违反买家商品评论政策'
            when itemtype=48 then '其他违反政策'
            when itemtype=49 then '违反政策警告'
            when itemtype=50 then '商品安全买家投诉'
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
                from import_data.mysql_store where department regexp '快')  ms  on list.shopcode=ms.Code  and ms.Department='快百货'
            where date(detail.CreationTime)='${NextStartDay}' -- v2表落库时间是统计日的凌晨
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','45','46','48','49')
    group by shopcode,shopstatus,SellUserName ,site ,dep2 having sum(count) >=5
    ) a
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'0至200分的正常渠道数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct shopcode)   ,0 ,0
from erp_amazon_amazon_shop_performance_check ahr
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
      from import_data.mysql_store where department regexp '快')  ms  on ahr.shopcode=ms.Code  and ms.Department='快百货'
where date(CreationTime)='${NextStartDay}' -- v2表落库时间是统计日的凌晨
and ms.shopstatus = '正常'
and ahrscore<200
group by grouping sets ((),(dep2));




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'商品原因的违规记录数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,sum(records)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2 ,sum(count) records
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
            , case when itemtype=40 then '涉嫌侵犯知识产权'
            when itemtype=41 then '知识产权投诉'
            when itemtype=42 then '商品真实性买家投诉'
            when itemtype=43 then '商品状况买家投诉'
            when itemtype=44 then '食品和商品安全问题'
            when itemtype=45 then '上架政策违规'
            when itemtype=46 then '违反受限商品政策'
            when itemtype=47 then '违反买家商品评论政策'
            when itemtype=48 then '其他违反政策'
            when itemtype=49 then '违反政策警告'
            when itemtype=50 then '商品安全买家投诉'
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
                from import_data.mysql_store where department regexp '快')  ms  on list.shopcode=ms.Code  and ms.Department='快百货'
            where date(detail.CreationTime)='${NextStartDay}' -- v2表落库时间是统计日的凌晨
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','46')
    group by shopcode,shopstatus,SellUserName ,site ,dep2
    ) a
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'高潜商品数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct spu) ,0 ,0
from dep_kbh_product_level_potentail where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = '潜力款';


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'高潜商品来源_新品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct dkplp.spu) ,0 ,0
from dep_kbh_product_level_potentail dkplp
join (select spu from view_kbp_new_products group by spu) vknp on dkplp.spu = vknp.spu
where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = '潜力款';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'高潜商品来源_老品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct dkplp.spu) ,0 ,0
from dep_kbh_product_level_potentail dkplp
left join (select spu from view_kbp_new_products group by spu) vknp on dkplp.spu = vknp.spu
where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = '潜力款' and vknp.spu is null;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品28天成功率_新品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) / count( distinct w0.spu) ,4)  高潜商品28天成功率_新品
     , count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) ,count( distinct w0.spu) ,'周报' as type
from ( select distinct dkpl.spu,StartDay  from  dep_kbh_product_level_potentail dkpl join (select spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    WHERE  StartDay >=  date(date_add('${NextStartDay}',interval -4 week )) and prod_level regexp '潜力款'  ) w0 -- 上周潜力款
left join ( select distinct spu,FirstDay from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${NextStartDay}',interval -4 week ))  and prod_level regexp '旺款|爆款' ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品28天成功率_老品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) / count( distinct w0.spu) ,4)  高潜商品28天成功率_老品
     , count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) ,count( distinct w0.spu) ,'周报' as type
from ( select distinct dkpl.spu,StartDay  from  dep_kbh_product_level_potentail dkpl left join (select spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    WHERE  StartDay >=  date(date_add('${NextStartDay}',interval -4 week )) and prod_level regexp '潜力款' and vknp.spu is null ) w0 -- 上周潜力款
left join ( select distinct spu,FirstDay from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${NextStartDay}',interval -4 week ))  and prod_level regexp '旺款|爆款' ) w1
    on w0.SPU = w1.SPU;




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'高潜打造成功数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct dkpl.spu) ,0 ,0
from dep_kbh_product_level dkpl
join ( select spu,min(StartDay) min_StartDay from dep_kbh_product_level_potentail where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay
    and prod_level = '潜力款'group by spu ) t
    on dkpl.spu = t.SPU and dkpl.prod_level regexp '爆|旺'  and dkpl.FirstDay > t.min_StartDay;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'单SPU在线超过6套SPU数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(*) ,0 ,0
from (select spu
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp '泉州' then '快百货泉州' when NodePathName regexp '成都' then '快百货成都' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '快百货' and ShopStatus='正常' and listingstatus=1
    and sku<>''
group by spu having count(distinct CompanyCode) > 6
) t;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'产品库当周侵权产品SPU数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct spu ) ,0 ,0
from erp_product_product_tort_infos eppti
join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
join wt_products wp on eppti.Id =wp.id and eppti.TorStatusChangeTime >= '${StartDay}' and  eppti.TorStatusChangeTime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and IsDeleted = 0;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'近3个月终审当周新品侵权数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct spu ) ,0 ,0
from erp_product_product_tort_infos eppti
join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
join wt_products wp on eppti.Id =wp.id and eppti.TorStatusChangeTime >= '${StartDay}' and  eppti.TorStatusChangeTime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and IsDeleted = 0
    and wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}';


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'近3个月终审新品侵权率' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round(近3月终审侵权产品/近3月终审产品,4) ,近3月终审侵权产品 ,近3月终审产品
from (select count(distinct spu ) 近3月终审产品 from wt_products wp where wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}' and ProjectTeam = '快百货') t1
join (select count(distinct spu ) 近3月终审侵权产品
    from erp_product_product_tort_infos eppti
    join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
    join wt_products wp on eppti.Id =wp.id and wp.ProjectTeam = '快百货' and IsDeleted = 0 and TorStatusChangeTime>= '${StartDay}'
        and wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}') t2;



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct case when week_0.prod_level='爆款' and week_bf1.prod_level != '爆款' then week_0.spu end )   -- 爆款新增数
    ,0 ,0 ,'周报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when week_0.prod_level='旺款' and week_bf1.prod_level not regexp  '旺款|爆款' then week_0.spu end )
    ,0 ,0 ,'周报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品爆款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when week_0.prod_level='爆款' and week_0.isnew = '新品' and !(week_bf1.prod_level='爆款' and week_bf1.isnew = '新品') then week_0.spu end )   -- 新品爆款新增数
    ,0 ,0 ,'周报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when week_0.prod_level='旺款' and week_0.isnew = '新品' and !(week_bf1.prod_level='旺款' and week_bf1.isnew = '新品') then week_0.spu end )   -- 新品旺款新增数
   ,0 ,0 ,'周报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品爆旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'周报' type
from manual_table where  handletime = '${StartDay}' and memo regexp '新品爆款新增数|新品旺款新增数' and c5 ='周报';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆旺款订单数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    , count(distinct PlatOrderNumber )
     ,0 ,0 ,'周报' type
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款'
join ( select spu from import_data.dep_kbh_product_level  where Department = '快百货'  and prod_level regexp '爆款|旺款' group by spu ) dkpl on dkpl.SPU = wo.Product_SPU
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}';
