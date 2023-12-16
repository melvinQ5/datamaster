-- 统计期内首次出单的SPU，计算单产=每个SPU30天内累计出单金额求和 ÷ 出单SPU数
SELECT ifnull(department,"所有部门") department 
	,round(sum(sales_in30d)/count(distinct spu_in30d)) `首单30天SPU单产`
from (  
	select wo.department , wo.product_spu as spu 
		, case when timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 
			and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0 then TotalGross/ExchangeUSD else 0 
		end as sales_in30d
		, case when timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 
			and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0 then product_spu 
		end as spu_in30d
	from import_data.wt_orderdetails wo 
	join mysql_store ms on wo.shopcode = ms.code
	where wo.IsDeleted=0 and TransactionType = '付款'  and OrderStatus <> '作废' and product_spu is not null 
		and DepSpuMinPayTime >= '${StartDay}' and DepSpuMinPayTime < '${EndDay}'
	) ta 
GROUP BY grouping sets ((),(department))


