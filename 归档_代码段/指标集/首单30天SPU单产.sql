-- ͳ�������״γ�����SPU�����㵥��=ÿ��SPU30�����ۼƳ��������� �� ����SPU��
SELECT ifnull(department,"���в���") department 
	,round(sum(sales_in30d)/count(distinct spu_in30d)) `�׵�30��SPU����`
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
	where wo.IsDeleted=0 and TransactionType = '����'  and OrderStatus <> '����' and product_spu is not null 
		and DepSpuMinPayTime >= '${StartDay}' and DepSpuMinPayTime < '${EndDay}'
	) ta 
GROUP BY grouping sets ((),(department))


