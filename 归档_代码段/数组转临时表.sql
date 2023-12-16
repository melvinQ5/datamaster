with 
ta as (
select [1915557,3107718,4231239] arr 
)

,tb as (
select * 
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)

SELECT boxsku ,sum(SaleCount)
from  wt_orderdetails wo 
join tb on wo.boxsku = tb.arr
where PayTime > '2020-03-23' and PayTime <= '2023-03-23'
group by boxsku