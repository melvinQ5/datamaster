-- 为了避免搬家链接对最早刊登时间的影响，使用asin+site计算首次刊登时间（搬家动作导致有一个新的sellersku编码，但实际asin是以前以前刊登过的)

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
select distinct year ,month from dim_date where full_date >= '2022-09-01' and full_date < '2024-01-01'
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
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_cnt end )  lst_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_cnt end )  lst_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_cnt end )  lst_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_cnt end )  lst_2312

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
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_totalgross end )  lst_gross_2308
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_totalgross end )  lst_gross_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_totalgross end )  lst_gross_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_totalgross end )  lst_gross_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_totalgross end )  lst_gross_2312
from od_lst_stat
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- 清洗个别出单月份早于刊登月份脏数据
group by pub_year ,pub_month
)

,res2 as ( -- 分月刊登动销分布
select t0.*
    ,new_lst_cnt 新刊登链接
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2209 / new_lst_cnt  end ,4) 2209动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2210 / new_lst_cnt  end ,4) 2210动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2211 / new_lst_cnt  end ,4) 2211动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2212 / new_lst_cnt  end ,4) 2212动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2301 / new_lst_cnt  end ,4) 2301动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2302 / new_lst_cnt  end ,4) 2302动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2303 / new_lst_cnt  end ,4) 2303动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2304 / new_lst_cnt  end ,4) 2304动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2305 / new_lst_cnt  end ,4) 2305动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2306 / new_lst_cnt  end ,4) 2306动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2307 / new_lst_cnt  end ,4) 2307动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2308 / new_lst_cnt  end ,4) 2308动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2309 / new_lst_cnt  end ,4) 2309动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2310 / new_lst_cnt  end ,4) 2310动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2311 / new_lst_cnt  end ,4) 2311动销率
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2312 / new_lst_cnt  end ,4) 2312动销率

    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2209   end ,4) 2209动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2210   end ,4) 2210动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2211   end ,4) 2211动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2212   end ,4) 2212动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2301   end ,4) 2301动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2302   end ,4) 2302动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2303   end ,4) 2303动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2304   end ,4) 2304动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2305   end ,4) 2305动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2306   end ,4) 2306动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2307   end ,4) 2307动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2308   end ,4) 2308动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2309   end ,4) 2309动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2310   end ,4) 2310动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2311   end ,4) 2311动销业绩
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2312   end ,4) 2312动销业绩
from t0
left join new_lst_stat t1 on t0.year = t1.pub_year and t0.month =t1.pub_month
left join od_lst_stat_pivot t2 on t0.year = t2.pub_year and t0.month =t2.pub_month
order by year,month
)

select * from res1
-- select * from res2