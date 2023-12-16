
-- �������Ҫÿ�����³�Ҫ�ϸ��µģ�����Ҫ���µġ�Ȼ�󼾶�Ҫ���ȵ�
-- StartDay = ͳ����1��


with amzuser as (
select distinct SellUserName from mysql_store where department='��ٻ�'
)

-- �������۶�����۶�����
,salesort as (
select *,row_number() over(order by sales desc) as salesort,row_number() over(order by profit desc) as profitsort
from
    ( select SellUserName,round(sum(totalgross/ExchangeUSD) ,0)sales, round(sum(TotalProfit/ExchangeUSD) ,4) profit
    , round(sum(TotalProfit) /sum(totalgross) ,4) profitrate
    from wt_orderdetails od
    join  mysql_store s on s.code=od.shopcode and s.department='��ٻ�'
    where SettlementTime>='${StartDay}' and  SettlementTime< '${NextStartDay}' and od.IsDeleted=0
    and SellUserName is not null
    group by SellUserName
    )a
)

-- select * from salesort

/*���������*/
-- �¶Ȼ��� ���Ȼ���
,upsort as(
select SellUserName,profitup, row_number() over(order by profitup desc) as upsort
from (
select salesort.*,a.profit lastprofit,round (salesort.profit-a.profit,2) profitup
from
(
select SellUserName,round(sum(totalgross/ExchangeUSD) ,0)sales, round(sum(TotalProfit/ExchangeUSD) ,4) profit
     , round(sum(TotalProfit) /sum(totalgross) ,4) profitrate
from wt_orderdetails od
join  mysql_store s on s.code=od.shopcode and s.department='��ٻ�'
where SettlementTime>=date_add('${StartDay}',interval -1 month) and  SettlementTime< '${StartDay}' and od.IsDeleted=0 -- �¶�
-- where SettlementTime>=date_add('${StartDay}',interval -3 month) and  SettlementTime< '${StartDay}' and od.IsDeleted=0  -- ����
and SellUserName is not null
group by SellUserName
) a
left join salesort on salesort.SellUserName=a.SellUserName
)b
)


-- /*

-- 1.���������ص���������

-- * ������Ϊ��˾����Ϊ���������Ʒ

-- * �ص�����Ϊ�վ�0.5���������ӣ�ȡ��30�����ݣ�

-- * ��������ﵽ�۹��������ʺ���12%

-- */



,listsort as(
select SellUserNamenew,sa������,row_number()over(order by sa������ desc) SA����sort
from(
    select SellUserNamenew,count(distinct concat(asin,site))sa������
    from(
        select asin,site,list_level,SellUserName,split_part(concat(SellUserName,','),',',1) SellUserNamenew
        from (
            Select a.asin,a.site,list_level,avg(sales_in30d)sales_in30d,avg(profit_in30d)profit_in30d
                 ,round((avg(profit_in30d))/avg(sales_in30d),4)profitrate,GROUP_CONCAT(SellUserName)SellUserName
            from
                ( select dkll.asin ,dkll.site ,list_level ,sales_in30d ,profit_in30d  ,round(profit_in30d/sales_in30d,2) profitrate,sellusername,shopcode
                from dep_kbh_listing_level dkll
                join ( select asin ,MarketType ,sellusername,shopcode from erp_amazon_amazon_listing al
                    join mysql_store ms on ms.code= al.shopcode and al.ListingStatus =1 and ms.shopstatus = '����' and al.sku<>''  and al.asin<>''
                    group by asin ,MarketType ,sellusername,shopcode ) al
                    on al.asin=dkll.asin and al.MarketType=dkll.site
                where dkll.isdeleted = 0 and dkll.FirstDay ='${StartDay}' and list_level regexp 'S|A' -- ������ʹ�����һ���µ���SA����
                ) a
            group by  a.asin,a.site,list_level
            ) b
        where profitrate>=0.11
        ) e
    group by SellUserNamenew
    )d
)

-- select * from listsort

-- /*��������
-- 1.����ת���� *40%
-- 2.���Ӷ�����*20%
-- 3.���ӵ���*40%
-- */

-- ת����%

,cvrsort as(
select SellUserName,CVR,row_number()over(order by CVR desc) cvrsort from (
select SellUserName,ROUND(sum(TotalSale7DayUnit)/sum(clicks),4) CVR  from AdServing_Amazon ads
join mysql_store ms on ms.Code = ads.shopcode and ms.Department ='��ٻ�'
where createdtime>='${StartDay}' and  createdtime< '${NextStartDay}'
group by  SellUserName
)a
)

-- ���Ӷ�����% ��������
,t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,CompanyCode,publicationdate,SellUserName
from erp_amazon_amazon_listing eaal
join mysql_store ms on ms.code= eaal.shopcode
where  ms.department='��ٻ�' and ShopStatus='����' and listingstatus=1 and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
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

,deatilscal as( -- �������� ��������
select SellUserName,count(distinct concat(Asin , Site))onlinelist,count(distinct case when ord_cnt>0 then concat(Asin , Site) end) 1monthsoldlist
from t_mark
group by SellUserName
)

,dongxiaosort as(
Select SellUserName,onlinelist,1monthsoldlist,`����asin��1���¶�����`,row_number()over(order by `����asin��1���¶�����` desc) ������sort
from(
select deatilscal.*, round(1monthsoldlist/onlinelist,4) `����asin��1���¶�����` from deatilscal
where SellUserName is not null
)a
)

,ahr as
-- /*���������˺ŵ�ƽ��ƽ̨��*/
(
SELECT s.SellUserName,round(avg(pc.AhrScore),1)AhrScore FROM `erp_amazon_amazon_shop_performance_check` pc
join mysql_store s on s.code=pc.shopcode and s.department='��ٻ�'
where date(CreationTime)='${NextStartDay}'
group by s.SellUserName
)

select a.*,row_number()over(order by ���� desc) as ����sort from
(
select amzuser.SellUserName
     ,sales ���۶�S3 ,profit �����M3 ,profitrate ������R3 ,profitup ���������,sa������,CVR,`����asin��1���¶�����`,round(sales/1monthsoldlist,2) ����,AhrScore`��������`,salesort ���۶����� ,profitsort ���������,upsort ����������,SA����sort,CVRsort,������sort
from amzuser
left join salesort on salesort.SellUserName=amzuser.SellUserName
left join listsort on listsort.SellUserNamenew=amzuser.SellUserName
left join cvrsort on cvrsort.SellUserName=amzuser.SellUserName
left join dongxiaosort on dongxiaosort.SellUserName=amzuser.SellUserName
left join ahr on ahr.SellUserName=amzuser.SellUserName
left join upsort on upsort.SellUserName=amzuser.SellUserName
where amzuser.SellUserName is not null
)a

order by ���۶�S3 desc







