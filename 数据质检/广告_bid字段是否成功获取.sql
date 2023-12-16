select GenerateDate ,count(*)
from wt_adserving_amazon_daily
where GenerateDate>= '2023-11-13' and MaxBidUSD > 0
group by GenerateDate
order by GenerateDate desc