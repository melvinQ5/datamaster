-- 两段SQL

-- SQL1 订单明细 分别导出 22年、23年上下半年
with
mysql_store_team as ( -- 财务提供历史账号退还交接情况
select c2 as 归属开始时间 ,c1 as 归属结束时间 ,ws.* from manual_table mt join wt_store ws on mt.memo = ws.code and handlename='真真_快百货账号转移情况_231206'
union select '2000-01-01' ,'9999-12-31' ,* from wt_store where department = '快百货'
)

,od_pay as (
select
    ordernumber 系统订单号,
    PlatOrderNumber 平台订单号,
    wo.shopcode 店铺简码,
    Seller 销售负责人,
    wo.Site 站点,
    wo.BoxSku 产品sku,
    wo.asin,
    wo.SellerSku 渠道sku,
    PayTime 付款时间,
    month(PayTime) 付款月份,
    round( OrderTotalPrice / ExchangeUSD ,2) 订单总金额usd,
    round( TotalGross / ExchangeUSD ,2) 总收入usd,
    round( TotalProfit / ExchangeUSD ,2) 总利润usd,
    DevelopLastAuditTime sku终审时间,
    ProductStatusName 当前SKU状态,
    case when ListingStatus=1 then '在线'
         when ListingStatus=3 then '下架'
         when ListingStatus=4 then '创建作废' else '删除' end 当前链接状态
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= 归属结束时间 and PayTime >= 归属开始时间
left join wt_products wp on wo.BoxSku = wp.BoxSku
left join erp_amazon_amazon_listing eaal on wo.shopcode=eaal.ShopCode  and wo.SellerSku = eaal.SellerSKU and wo.Product_Sku=eaal.sku
where  wo.IsDeleted = 0 and PayTime >= '${StartDay}' and PayTime < '${NextStartDay}'  and TransactionType = '付款' )

,od_refund as (
select BoxSku , vr.OrderNumber ,round( sum(RefundAmount / ExchangeUSD ) ,2) 退款金额usd  ,max_refunddate 退款时间
from import_data.wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= 归属结束时间 and PayTime >= 归属开始时间
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate< '${NextStartDay}'  and TransactionType = '退款'
group by BoxSku, vr.OrderNumber, max_refunddate
)

select t1.* ,t2.退款时间 ,t2.退款金额usd
from od_pay t1 left join od_refund t2 on t1.产品sku  = t2.BoxSku and t1.系统订单号 = t2.OrderNumber;



-- SQL2

with
mysql_store_team as ( -- 财务提供历史账号退还交接情况
select c2 as 归属开始时间 ,c1 as 归属结束时间 ,ws.* from manual_table mt join wt_store ws on mt.memo = ws.code and handlename='真真_快百货账号转移情况_231206'
union select '2000-01-01' ,'9999-12-31' ,* from wt_store where department = '快百货'
)

,new_lst_stat as (
select year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month ,ProductSalesName as SellUserName ,AccountCode
    ,count( distinct concat(ShopCode,SellerSKU) ) 当月刊登链接数
    ,count( distinct spu ) 当月刊登SPU数
from wt_listing wl
join mysql_store_team  ms on wl.shopcode=ms.Code and MinPublicationDate <= 归属结束时间 and MinPublicationDate >= 归属开始时间
where  MinPublicationDate >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
group by year(MinPublicationDate) ,month(MinPublicationDate) ,ProductSalesName ,AccountCode
)

, od_lst_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month ,Seller as SellUserName ,ms.AccountCode
     ,year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month
     ,count( distinct concat(wo.ShopCode,wo.SellerSKU) ) od_lst_cnt
     ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) od_lst_totalgross
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= 归属结束时间 and PayTime >= 归属开始时间
left join (select asin ,MarketType as site ,min(MinPublicationDate) MinPublicationDate from wt_listing group by asin ,site ) wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType = '付款' -- 其他类型的sellersku是生成的广告费用的信息,非真实sellersku
  and PayTime >= '${StartDay}'  and PayTime < '${NextStartDay}'
group by Seller ,ms.AccountCode ,year(PayTime) ,month(PayTime) ,year(MinPublicationDate) ,month(MinPublicationDate)
)

, od_lst_stat_pivot as (
select pub_year ,pub_month ,SellUserName ,AccountCode
    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_cnt end )  lst_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_cnt end )  lst_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_cnt end )  lst_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_cnt end )  lst_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_cnt end )  lst_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_cnt end )  lst_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_cnt end )  lst_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_cnt end )  lst_2308
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_cnt end )  lst_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_cnt end )  lst_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_cnt end )  lst_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_cnt end )  lst_2312

    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_totalgross end )  lst_gross_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_totalgross end )  lst_gross_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_totalgross end )  lst_gross_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_totalgross end )  lst_gross_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_totalgross end )  lst_gross_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_totalgross end )  lst_gross_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_totalgross end )  lst_gross_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_totalgross end )  lst_gross_2308
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_totalgross end )  lst_gross_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_totalgross end )  lst_gross_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_totalgross end )  lst_gross_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_totalgross end )  lst_gross_2312
from od_lst_stat
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- 清洗个别出单月份早于刊登月份脏数据
group by pub_year ,pub_month ,SellUserName ,AccountCode
)
   
, od_spu_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month ,Seller as SellUserName ,ms.AccountCode
     ,year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month
    ,Product_SPU as spu 
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= 归属结束时间 and PayTime >= 归属开始时间
left join (select asin ,MarketType as site ,min(MinPublicationDate) MinPublicationDate from wt_listing group by asin ,site ) wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType = '付款' -- 其他类型的sellersku是生成的广告费用的信息,非真实sellersku
  and PayTime >= '2023-01-01'
group by Seller ,ms.AccountCode ,year(PayTime) ,month(PayTime) ,year(MinPublicationDate) ,month(MinPublicationDate) ,Product_SPU
)

, od_spu_stat_pivot as (
select pub_year ,pub_month ,SellUserName ,AccountCode
    ,count( distinct  case when pay_year =2023 and pay_month = 1 then spu end )  spu_2301
    ,count( distinct  case when pay_year =2023 and pay_month = 2 then spu end )  spu_2302
    ,count( distinct  case when pay_year =2023 and pay_month = 3 then spu end )  spu_2303
    ,count( distinct  case when pay_year =2023 and pay_month = 4 then spu end )  spu_2304
    ,count( distinct  case when pay_year =2023 and pay_month = 5 then spu end )  spu_2305
    ,count( distinct  case when pay_year =2023 and pay_month = 6 then spu end )  spu_2306
    ,count( distinct  case when pay_year =2023 and pay_month = 7 then spu end )  spu_2307
    ,count( distinct  case when pay_year =2023 and pay_month = 8 then spu end )  spu_2308
    ,count( distinct  case when pay_year =2023 and pay_month = 9 then spu end )  spu_2309
    ,count( distinct  case when pay_year =2023 and pay_month = 10 then spu end )  spu_2310
    ,count( distinct  case when pay_year =2023 and pay_month = 11 then spu end )  spu_2311
    ,count( distinct  case when pay_year =2023 and pay_month = 12 then spu end )  spu_2312
from od_spu_stat
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- 清洗个别出单月份早于刊登月份脏数据
group by pub_year ,pub_month ,SellUserName ,AccountCode
)

,t0 as (
select pub_year ,pub_month ,SellUserName ,AccountCode  from new_lst_stat
union select pub_year ,pub_year ,SellUserName ,AccountCode  from od_lst_stat_pivot where pub_year >= '2023-01-01'
)

,res2 as ( -- 分月刊登动销分布
select t1.*
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2301  end ,0) 2301出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2302  end ,0) 2302出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2303  end ,0) 2303出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2304  end ,0) 2304出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2305  end ,0) 2305出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2306  end ,0) 2306出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2307  end ,0) 2307出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2308  end ,0) 2308出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2309  end ,0) 2309出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2310  end ,0) 2310出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2311  end ,0) 2311出单链接数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2312  end ,0) 2312出单链接数
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2301 / 当月刊登链接数  end ,4) 2301链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2302 / 当月刊登链接数  end ,4) 2302链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2303 / 当月刊登链接数  end ,4) 2303链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2304 / 当月刊登链接数  end ,4) 2304链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2305 / 当月刊登链接数  end ,4) 2305链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2306 / 当月刊登链接数  end ,4) 2306链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2307 / 当月刊登链接数  end ,4) 2307链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2308 / 当月刊登链接数  end ,4) 2308链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2309 / 当月刊登链接数  end ,4) 2309链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2310 / 当月刊登链接数  end ,4) 2310链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2311 / 当月刊登链接数  end ,4) 2311链接动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2312 / 当月刊登链接数  end ,4) 2312链接动销率
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2301  end ,0) 2301出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2302  end ,0) 2302出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2303  end ,0) 2303出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2304  end ,0) 2304出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2305  end ,0) 2305出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2306  end ,0) 2306出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2307  end ,0) 2307出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2308  end ,0) 2308出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2309  end ,0) 2309出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2310  end ,0) 2310出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2311  end ,0) 2311出单SPU数
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2312  end ,0) 2312出单SPU数
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2301 / 当月刊登SPU数  end ,4) 2301SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2302 / 当月刊登SPU数  end ,4) 2302SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2303 / 当月刊登SPU数  end ,4) 2303SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2304 / 当月刊登SPU数  end ,4) 2304SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2305 / 当月刊登SPU数  end ,4) 2305SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2306 / 当月刊登SPU数  end ,4) 2306SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2307 / 当月刊登SPU数  end ,4) 2307SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2308 / 当月刊登SPU数  end ,4) 2308SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2309 / 当月刊登SPU数  end ,4) 2309SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2310 / 当月刊登SPU数  end ,4) 2310SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2311 / 当月刊登SPU数  end ,4) 2311SPU动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2312 / 当月刊登SPU数  end ,4) 2312SPU动销率
     
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2301   end ,4) 2301动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2302   end ,4) 2302动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2303   end ,4) 2303动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2304   end ,4) 2304动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2305   end ,4) 2305动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2306   end ,4) 2306动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2307   end ,4) 2307动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2308   end ,4) 2308动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2309   end ,4) 2309动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2310   end ,4) 2310动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2311   end ,4) 2311动销业绩
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2312   end ,4) 2312动销业绩
from t0
left join new_lst_stat t1 on t1.pub_year = t0.pub_year and t1.pub_month =t0.pub_month and t1.SellUserName =t0.SellUserName and t1.AccountCode =t0.AccountCode
left join od_lst_stat_pivot t2 on t0.pub_year = t2.pub_year and t0.pub_month =t2.pub_month and t0.SellUserName =t2.SellUserName and t0.AccountCode =t2.AccountCode
left join od_spu_stat_pivot t3 on t0.pub_year = t3.pub_year and t0.pub_month =t3.pub_month and t0.SellUserName =t3.SellUserName and t0.AccountCode =t3.AccountCode
order by t1.AccountCode ,t1.SellUserName , t1.pub_month
)

select * from res2  