
-- ����������������
select distinct  GenerateDate  from wt_adserving_amazon_daily where MaxEnabledBidUSD=0


select MaxEnabledBidUSD,MaxBidUSD,SellerSku from wt_adserving_amazon_daily where GenerateDate='2023-11-12' and MaxBidUSD > 0


-- ��������ձ�
select CreatedTime ,count(1)
from import_data.AdServing_Amazon
where CreatedTime >= '2023-05-28' and CreatedTime < '2023-06-15'
group by CreatedTime
order by CreatedTime desc


-- ��������ձ�
select CreatedTime ,count(1)
from import_data.AdServing_Amazon
where CreatedTime >= '2023-04-28' and CreatedTime < '2023-05-15'
group by CreatedTime
order by CreatedTime desc


-- 1-6�� û����

select *
from import_data.AdServing_Amazon
where Exposure < 0 or cost < 0 or ExchangeUSD <0 or TotalSale7Day <0 or TotalSale7DayUnit<0 or Clicks < 0 or  AdSkuSaleCount7Day < 0  or AdSkuSale7Day < 0
group by CreatedTime

-- 2-3�� �����ͷ��쳣
select
*
from import_data.AdServing_Amazon
where CreatedTime > '2023-01-01' and CreatedTime < '2023-06-05'