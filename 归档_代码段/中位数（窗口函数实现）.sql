-- �� ������Ͷ������λ��Ϊ��
with a as (
select * from
(
select c.Month,c.site,c.asin,c.TotalCount,c.PriceUSD,c.MarketSize,rank() over ( order by c.MarketSize desc) as 'number' from
(
select '2023-01-01' Month, a.site, a.asin, a.TotalCount, b.PriceUSD, a.TotalCount * b.PriceUSD MarketSize from (
select StoreSite site, ChildAsin asin, max(TotalCount) TotalCount from Top_Asin
where Monday = '2023-01-01' and ReportType = '�±�'
group by StoreSite, ChildAsin
) a
join (
select MarketType site, asin , price * RealTimeExchangeRate PriceUSD from (
select t1.ASIN, MarketType, price, CurrencyCode from
(select ASIN,MarketType,min(price) price , min(CurrencyCode) CurrencyCode from erp_amazon_amazon_listing al
inner join mysql_store s   /*GM������������*/
on al.ShopCode=s.Code
and s.Department='������'
and ShopStatus='����'
and ListingStatus=1
group by ASIN,MarketType) as t1
inner join
(select Asin,Site from import_data.erp_gather_gather_asin
where IsDeleted=0  /*GM�Լ���ASIN*/
group by Asin, Site) t2
on t1.ASIN=t2.Asin
and t1.MarketType=t2.Site
) a
join erp_user_user_exchange_rates r on r.FromCurrency = a.CurrencyCode and r.ToCurrency = 'USD'
) b on a.site = b.site and a.asin = b.asin
order by MarketSize desc ) c
) d
)


select tmp2.*
from (
	select a.* 
		,number as sort 
		,count(number)over() as len_days
	from a
) tmp2
where sort < round(len_days*0.1) 

