with 
ta as (
select [1915557,
2069281,
2138907,
2971225,
2971229,
2971265,
3050102,
3074472,
3074486,
3097045,
3104544,
3107718,
4231239] arr 
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
where 
-- 	IsDeleted = 0 
-- 	and 
	PayTime > '2020-03-23' and PayTime <= '2023-03-23'
group by boxsku