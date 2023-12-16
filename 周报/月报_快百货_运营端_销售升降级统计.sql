
-- 我们这个要每个月月初要上个月的，月中要当月的。然后季度要季度的
-- StartDay = 统计月1号


with amzuser as (
select distinct SellUserName from mysql_store where department='快百货'
)

-- 季度销售额和销售额排名
,salesort as (
select *,row_number() over(order by sales desc) as salesort,row_number() over(order by profit desc) as profitsort
from
    ( select SellUserName,round(sum(totalgross/ExchangeUSD) ,0)sales, round(sum(TotalProfit/ExchangeUSD) ,4) profit
    , round(sum(TotalProfit) /sum(totalgross) ,4) profitrate
    from wt_orderdetails od
    join  mysql_store s on s.code=od.shopcode and s.department='快百货'
    where SettlementTime>='${StartDay}' and  SettlementTime< '${NextStartDay}' and od.IsDeleted=0
    and SellUserName is not null
    group by SellUserName
    )a
)

-- select * from salesort

/*利润额增长*/
-- 月度环比 季度环比
,upsort as(
select SellUserName,profitup, row_number() over(order by profitup desc) as upsort
from (
select salesort.*,a.profit lastprofit,round (salesort.profit-a.profit,2) profitup
from
(
select SellUserName,round(sum(totalgross/ExchangeUSD) ,0)sales, round(sum(TotalProfit/ExchangeUSD) ,4) profit
     , round(sum(TotalProfit) /sum(totalgross) ,4) profitrate
from wt_orderdetails od
join  mysql_store s on s.code=od.shopcode and s.department='快百货'
where SettlementTime>=date_add('${StartDay}',interval -1 month) and  SettlementTime< '${StartDay}' and od.IsDeleted=0 -- 月度
-- where SettlementTime>=date_add('${StartDay}',interval -3 month) and  SettlementTime< '${StartDay}' and od.IsDeleted=0  -- 季度
and SellUserName is not null
group by SellUserName
) a
left join salesort on salesort.SellUserName=a.SellUserName
)b
)


-- /*

-- 1.爆旺款下重点链接总数

-- * 爆旺款为公司定义为爆旺款的商品

-- * 重点链接为日均0.5单以上链接（取近30天数据）

-- * 单链接需达到扣广告后利润率红线12%

-- */



,listsort as(
select SellUserNamenew,sa链接数,row_number()over(order by sa链接数 desc) SA链接sort
from(
    select SellUserNamenew,count(distinct concat(asin,site))sa链接数
    from(
        select asin,site,list_level,SellUserName,split_part(concat(SellUserName,','),',',1) SellUserNamenew
        from (
            Select a.asin,a.site,list_level,avg(sales_in30d)sales_in30d,avg(profit_in30d)profit_in30d
                 ,round((avg(profit_in30d))/avg(sales_in30d),4)profitrate,GROUP_CONCAT(SellUserName)SellUserName
            from
                ( select dkll.asin ,dkll.site ,list_level ,sales_in30d ,profit_in30d  ,round(profit_in30d/sales_in30d,2) profitrate,sellusername,shopcode
                from dep_kbh_listing_level dkll
                join ( select asin ,MarketType ,sellusername,shopcode from erp_amazon_amazon_listing al
                    join mysql_store ms on ms.code= al.shopcode and al.ListingStatus =1 and ms.shopstatus = '正常' and al.sku<>''  and al.asin<>''
                    group by asin ,MarketType ,sellusername,shopcode ) al
                    on al.asin=dkll.asin and al.MarketType=dkll.site
                where dkll.isdeleted = 0 and dkll.FirstDay ='${StartDay}' and list_level regexp 'S|A' -- 季度则使用最后一个月的月SA快照
                ) a
            group by  a.asin,a.site,list_level
            ) b
        where profitrate>=0.11
        ) e
    group by SellUserNamenew
    )d
)

-- select * from listsort

-- /*链接质量
-- 1.链接转化率 *40%
-- 2.链接动销率*20%
-- 3.链接单产*40%
-- */

-- 转化率%

,cvrsort as(
select SellUserName,CVR,row_number()over(order by CVR desc) cvrsort from (
select SellUserName,ROUND(sum(TotalSale7DayUnit)/sum(clicks),4) CVR  from AdServing_Amazon ads
join mysql_store ms on ms.Code = ads.shopcode and ms.Department ='快百货'
where createdtime>='${StartDay}' and  createdtime< '${NextStartDay}'
group by  SellUserName
)a
)

-- 链接动销率% 在线链接
,t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,CompanyCode,publicationdate,SellUserName
from erp_amazon_amazon_listing eaal
join mysql_store ms on ms.code= eaal.shopcode
where  ms.department='快百货' and ShopStatus='正常' and listingstatus=1 and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
)

, t_od as (
select Asin , Site ,count(distinct PlatOrderNumber) ord_cnt
from wt_orderdetails wo
-- join erp_product_products pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0 and  PayTime>='${StartDay}' and  PayTime< '${NextStartDay}'
group by Asin , Site
)

,t_mark as (
select t_list.* ,ord_cnt
from t_list
left join t_od on t_list.site = t_od.site and t_list.asin = t_od.asin
)

,deatilscal as( -- 在线链接 动销链接
select SellUserName,count(distinct concat(Asin , Site))onlinelist,count(distinct case when ord_cnt>0 then concat(Asin , Site) end) 1monthsoldlist
from t_mark
group by SellUserName
)

,dongxiaosort as(
Select SellUserName,onlinelist,1monthsoldlist,`在线asin近1个月动销率`,row_number()over(order by `在线asin近1个月动销率` desc) 动销率sort
from(
select deatilscal.*, round(1monthsoldlist/onlinelist,4) `在线asin近1个月动销率` from deatilscal
where SellUserName is not null
)a
)

,ahr as
-- /*所管理负责账号的平均平台分*/
(
SELECT s.SellUserName,round(avg(pc.AhrScore),1)AhrScore FROM `erp_amazon_amazon_shop_performance_check` pc
join mysql_store s on s.code=pc.shopcode and s.department='快百货'
where date(CreationTime)='${NextStartDay}'
group by s.SellUserName
)

select a.*,row_number()over(order by 单产 desc) as 单产sort from
(
select amzuser.SellUserName
     ,sales 销售额S3 ,profit 利润额M3 ,profitrate 利润率R3 ,profitup 增长利润额,sa链接数,CVR,`在线asin近1个月动销率`,round(sales/1monthsoldlist,2) 单产,AhrScore`店铺评分`,salesort 销售额排名 ,profitsort 利润额排名,upsort 增长额排名,SA链接sort,CVRsort,动销率sort
from amzuser
left join salesort on salesort.SellUserName=amzuser.SellUserName
left join listsort on listsort.SellUserNamenew=amzuser.SellUserName
left join cvrsort on cvrsort.SellUserName=amzuser.SellUserName
left join dongxiaosort on dongxiaosort.SellUserName=amzuser.SellUserName
left join ahr on ahr.SellUserName=amzuser.SellUserName
left join upsort on upsort.SellUserName=amzuser.SellUserName
where amzuser.SellUserName is not null
)a

order by 销售额S3 desc







