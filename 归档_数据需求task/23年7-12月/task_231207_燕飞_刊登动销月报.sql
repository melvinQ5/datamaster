-- Ϊ�˱��������Ӷ����翯��ʱ���Ӱ�죬ʹ��asin+site�����״ο���ʱ�䣨��Ҷ���������һ���µ�sellersku���룬��ʵ��asin����ǰ��ǰ���ǹ���)

with
min_lst as (
select  asin ,site  ,min( PublicationDate  ) min_pubtime
from wt_listing wl
join mysql_store ms on wl.ShopCode=ms.Code and ms.Department ='��ٻ�'
group by asin ,site
)

, new_lst_stat as (
select year(min_pubtime) pub_year ,month(min_pubtime) pub_month
    ,count( distinct concat(ShopCode,SellerSKU) ) new_lst_cnt
from wt_listing wl
join mysql_store ms on wl.ShopCode=ms.Code and ms.Department ='��ٻ�'
join min_lst on wl.asin = min_lst.asin and wl.MarketType=min_lst.site
group by year(min_pubtime) ,month(min_pubtime)
)

, od_lst_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month
     ,year(min_pubtime) pub_year ,month(min_pubtime) pub_month
     ,count( distinct concat(wo.ShopCode,wo.SellerSKU) ) od_lst_cnt
     ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) od_lst_totalgross
from wt_orderdetails wo
join mysql_store ms on wo.ShopCode=ms.Code and ms.Department ='��ٻ�'
left join min_lst wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType != '����' -- �������͵�sellersku�����ɵĹ����õ���Ϣ,����ʵsellersku
  and PayTime >= '2022-09-01'
group by year(PayTime) ,month(PayTime) ,year(min_pubtime) ,month(min_pubtime)
)

,t0 as (
select distinct year ,month from dim_date where full_date >= '2022-09-01' and full_date < '2024-01-01'
)

,res1 as ( -- ���¶���
select t0.*
    ,new_lst_cnt �¿�������
    ,round( od_lst_cnt / new_lst_cnt ,4) �¿������Ӷ�����
    ,od_lst_totalgross ���¶���ҵ��
    ,round( od_lst_totalgross / new_lst_cnt ,4) �������ӵ���
    ,round( od_lst_totalgross / od_lst_cnt ,4) �������ӵ���
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
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- ��ϴ��������·����ڿ����·�������
group by pub_year ,pub_month
)

,res2 as ( -- ���¿��Ƕ����ֲ�
select t0.*
    ,new_lst_cnt �¿�������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2209 / new_lst_cnt  end ,4) 2209������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2210 / new_lst_cnt  end ,4) 2210������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2211 / new_lst_cnt  end ,4) 2211������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2212 / new_lst_cnt  end ,4) 2212������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2301 / new_lst_cnt  end ,4) 2301������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2302 / new_lst_cnt  end ,4) 2302������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2303 / new_lst_cnt  end ,4) 2303������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2304 / new_lst_cnt  end ,4) 2304������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2305 / new_lst_cnt  end ,4) 2305������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2306 / new_lst_cnt  end ,4) 2306������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2307 / new_lst_cnt  end ,4) 2307������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2308 / new_lst_cnt  end ,4) 2308������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2309 / new_lst_cnt  end ,4) 2309������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2310 / new_lst_cnt  end ,4) 2310������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2311 / new_lst_cnt  end ,4) 2311������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_2312 / new_lst_cnt  end ,4) 2312������

    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2209   end ,4) 2209����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2210   end ,4) 2210����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2211   end ,4) 2211����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2212   end ,4) 2212����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2301   end ,4) 2301����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2302   end ,4) 2302����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2303   end ,4) 2303����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2304   end ,4) 2304����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2305   end ,4) 2305����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2306   end ,4) 2306����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2307   end ,4) 2307����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2308   end ,4) 2308����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2309   end ,4) 2309����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2310   end ,4) 2310����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2311   end ,4) 2311����ҵ��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(year,'-',month,'-01') ) ) >= 0 then lst_gross_2312   end ,4) 2312����ҵ��
from t0
left join new_lst_stat t1 on t0.year = t1.pub_year and t0.month =t1.pub_month
left join od_lst_stat_pivot t2 on t0.year = t2.pub_year and t0.month =t2.pub_month
order by year,month
)

select * from res1
-- select * from res2