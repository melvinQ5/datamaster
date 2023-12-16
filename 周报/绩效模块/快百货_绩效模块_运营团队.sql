-- Q2业绩 \ 新品业绩 \ 新品精铺链接访客转化率 \ 精铺链接动销率 \ 精铺单链接首单30天以内，新增单量1单以上的链接占比


with 
t_prod as ( -- 23年3月1日至今终审
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-03-01' and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) < '${NextStartDay}' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='快百货' 
	and epp.DevelopUserName != '杨春花'
)

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,wo.BoxSku 
	,timestampdiff(SECOND,t_prod.DevelopLastAuditTime,PayTime)/86400 as ord_days 
	, timestampdiff(SECOND,spu_min_paytime,PayTime)/86400 as ord_days_since_od 
	,t_prod.DevelopUserName 
	,PayTime 
	,ms.Department ,split_part(ms.NodePathNameFull,'>',2) dep2  ,ms.NodePathName  ,ms.SellUserName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join t_prod on wo.Product_SKU = t_prod.sku 
left join ( select Product_SPU , min(PayTime) as spu_min_paytime 
	from import_data.wt_orderdetails  od1
	join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
	and ms1.Department ='快百货' and PayTime >= '2023-03-01' and PayTime < '${NextStartDay}' -- 为了算首单30天 
	where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	SettlementTime  >= '2023-04-01' and SettlementTime < '${NextStartDay}' and wo.IsDeleted=0 
	and ms.Department = '快百货' and OrderStatus <> '作废' 
)

,t_sale_stat as ( -- Q2总业绩  新品业绩
select department `团队`
	,'' `人员`
	,round( sum((TotalGross)/ExchangeUSD)) `Q2_结算销售额`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `Q2_新品结算销售额`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by department
union
select dep2
	,'' `人员`
	,round( sum((TotalGross)/ExchangeUSD)) `结算销售额`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `新品结算销售额`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by dep2
union
select NodePathName
	,'' `人员`
	,round( sum((TotalGross)/ExchangeUSD)) `结算销售额`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `新品结算销售额`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by NodePathName
union
select NodePathName
	,SellUserName `人员`
	,round( sum((TotalGross)/ExchangeUSD)) `结算销售额`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `新品结算销售额`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by NodePathName,SellUserName
)

-- select * from t_sale_stat
-- ,t_new_sale as (
-- select left(paytime)  
-- 	,round( sum((TotalGross)/ExchangeUSD),2) `结算销售额`
-- 	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  ),2) `新品结算销售额`
-- from t_orde 
-- join t_prod on t_orde.boxsku = t_prod.boxsku 
-- group by left(paytime) 
-- )


select 
	case 
		when ta.团队 = '快百货' then 1 
		when ta.团队 = '快百货一部' then 2  
		when ta.团队 = '快百货二部' then 3 
		when ta.团队 = '快次元-成都销售组' and  ta.人员 = '' then 4
		when ta.团队 = '快次方-成都销售组' and  ta.人员 = '' then 5
		when ta.团队 = '运营组-泉州1组' and  ta.人员 = '' then 6
		when ta.团队 = '运营组-泉州2组' and  ta.人员 = '' then 7
		when ta.团队 = '运营组-泉州3组' and  ta.人员 = '' then 8
		when ta.团队 = '快次元-成都销售组' and  ta.人员 != '' then 9
		when ta.团队 = '快次方-成都销售组' and  ta.人员 != '' then 10
		when ta.团队 = '运营组-泉州1组' and  ta.人员 != '' then 11
		when ta.团队 = '运营组-泉州2组' and  ta.人员 != '' then 12
		when ta.团队 = '运营组-泉州3组' and  ta.人员 != '' then 13
	end as 表序
	,*
	,replace(concat(right('2023-04-01',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `结算时间范围`
	,replace(concat(right('2023-03-01',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `产品终审时间范围`
from t_sale_stat ta
order by 表序 asc 