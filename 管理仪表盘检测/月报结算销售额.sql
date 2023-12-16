
select 
	case when department IS NULL THEN '��˾' ELSE department END AS dep 
		,round( sum((TotalGross)/ExchangeUSD),2) `�������۶�`
		,round( sum(TotalProfit/ExchangeUSD),2) `���������`
		,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `�վ�������`
from 
(
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate
	,pp.SPU
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join wt_products pp on wo.BoxSku=pp.BoxSku
where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
) tmp 
group by grouping sets ((),(department))


