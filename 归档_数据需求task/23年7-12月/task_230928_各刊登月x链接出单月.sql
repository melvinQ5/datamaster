with
min_lst as (
select  asin ,site  ,min( PublicationDate  ) min_pubtime
from wt_listing wl
join mysql_store ms on wl.ShopCode=ms.Code and ms.Department ='快百货'
group by asin ,site
)

, new_lst_stat as (
select year(min_pubtime) pub_year ,month(min_pubtime) pub_month
    ,count( distinct concat(ShopCode,SellerSKU) ) new_lst_cnt
from wt_listing wl
join mysql_store ms on wl.ShopCode=ms.Code and ms.Department ='快百货'
join min_lst on wl.asin = min_lst.asin and wl.MarketType=min_lst.site
group by year(min_pubtime) ,month(min_pubtime)
)

, od_lst_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month
     ,year(min_pubtime) pub_year ,month(min_pubtime) pub_month
     ,count( distinct concat(wo.ShopCode,wo.SellerSKU) ) od_lst_cnt
     ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) od_lst_totalgross
from wt_orderdetails wo
join mysql_store ms on wo.ShopCode=ms.Code and ms.Department ='快百货'
left join min_lst wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType != '其他' -- 其他类型的sellersku是生成的广告费用的信息,非真实sellersku
  and PayTime >= '2022-09-01'
group by year(PayTime) ,month(PayTime) ,year(min_pubtime) ,month(min_pubtime)
)

,t0 as (
select distinct year ,month from dim_date where full_date >= '2022-09-01' and full_date < '2023-09-01'
)

,res1 as ( -- 当月动销
select t0.*
    ,new_lst_cnt 新刊登链接
    ,round( od_lst_cnt / new_lst_cnt ,4) 新刊登链接动销率
    ,od_lst_totalgross 当月动销业绩
    ,round( od_lst_totalgross / new_lst_cnt ,4) 刊登链接单产
    ,round( od_lst_totalgross / od_lst_cnt ,4) 出单链接单产
from t0
left join new_lst_stat t1 on t0.year = t1.pub_year and t0.month =t1.pub_month
left join od_lst_stat t2 on t0.year = t2.pay_year and t0.month =t2.pay_month
    and t2.pay_year =t2.pub_year  and t2.pay_month=t2.pub_month
order by year,month
)

, od_lst_stat_pivot as (
select pub_year ,pub_month
    ,sum( case when pay_year =2022 and pay_month = 9 then od_lst_cnt end )  lst_2209
    ,sum( case when pay_year =2022 and pay_month = 10 then od_lst_cnt end )  lst_2210
    ,sum( case when pay_year =2022 and pay_month = 11 then od_lst_cnt end )  lst_2211
    ,sum( case when pay_year =2022 and pay_month = 12 then od_lst_cnt end )  lst_2212
    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_cnt end )  lst_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_cnt end )  lst_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_cnt end )  lst_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_cnt end )  lst_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_cnt end )  lst_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_cnt end )  lst_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_cnt end )  lst_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_cnt end )  lst_2308
    ,sum( case when pay_year =2022 and pay_month = 9 then od_lst_totalgross end )  lst_gross_2209
    ,sum( case when pay_year =2022 and pay_month = 10 then od_lst_totalgross end )  lst_gross_2210
    ,sum( case when pay_year =2022 and pay_month = 11 then od_lst_totalgross end )  lst_gross_2211
    ,sum( case when pay_year =2022 and pay_month = 12 then od_lst_totalgross end )  lst_gross_2212
    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_totalgross end )  lst_gross_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_totalgross end )  lst_gross_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_totalgross end )  lst_gross_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_totalgross end )  lst_gross_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_totalgross end )  lst_gross_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_totalgross end )  lst_gross_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_totalgross end )  lst_gross_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_totalgross end ) as  lst_gross_2308
from od_lst_stat
group by pub_year ,pub_month
)



select * from od_lst_stat_pivot