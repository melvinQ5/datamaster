
select
generatedate
,count(1) ��¼��
,count(sku) ��sku��¼��
,count(1) - count(sku) ��ֵ
from wt_adserving_amazon_daily waad
join mysql_store ms on waad.ShopCode=ms.Code and ms.Department='��ٻ�'
where generatedate > '2023-09-01'
group by generatedate
order by generatedate desc
