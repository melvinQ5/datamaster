
select
generatedate
,count(1) 记录数
,count(sku) 有sku记录数
,count(1) - count(sku) 差值
from wt_adserving_amazon_daily waad
join mysql_store ms on waad.ShopCode=ms.Code and ms.Department='快百货'
where generatedate > '2023-09-01'
group by generatedate
order by generatedate desc
