-- Q2ҵ�� \ ��Ʒҵ�� \ ��Ʒ�������ӷÿ�ת���� \ �������Ӷ����� \ ���̵������׵�30�����ڣ���������1�����ϵ�����ռ��


with 
t_prod as ( -- 23��3��1����������
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
	and epp.ProjectTeam ='��ٻ�' 
	and epp.DevelopUserName != '���'
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
	and ms1.Department ='��ٻ�' and PayTime >= '2023-03-01' and PayTime < '${NextStartDay}' -- Ϊ�����׵�30�� 
	where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	SettlementTime  >= '2023-04-01' and SettlementTime < '${NextStartDay}' and wo.IsDeleted=0 
	and ms.Department = '��ٻ�' and OrderStatus <> '����' 
)

,t_sale_stat as ( -- Q2��ҵ��  ��Ʒҵ��
select department `�Ŷ�`
	,'' `��Ա`
	,round( sum((TotalGross)/ExchangeUSD)) `Q2_�������۶�`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `Q2_��Ʒ�������۶�`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by department
union
select dep2
	,'' `��Ա`
	,round( sum((TotalGross)/ExchangeUSD)) `�������۶�`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `��Ʒ�������۶�`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by dep2
union
select NodePathName
	,'' `��Ա`
	,round( sum((TotalGross)/ExchangeUSD)) `�������۶�`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `��Ʒ�������۶�`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by NodePathName
union
select NodePathName
	,SellUserName `��Ա`
	,round( sum((TotalGross)/ExchangeUSD)) `�������۶�`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  )) `��Ʒ�������۶�`
from t_orde 
left join t_prod  on t_orde.boxsku = t_prod.boxsku 
group by NodePathName,SellUserName
)

-- select * from t_sale_stat
-- ,t_new_sale as (
-- select left(paytime)  
-- 	,round( sum((TotalGross)/ExchangeUSD),2) `�������۶�`
-- 	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  ),2) `��Ʒ�������۶�`
-- from t_orde 
-- join t_prod on t_orde.boxsku = t_prod.boxsku 
-- group by left(paytime) 
-- )


select 
	case 
		when ta.�Ŷ� = '��ٻ�' then 1 
		when ta.�Ŷ� = '��ٻ�һ��' then 2  
		when ta.�Ŷ� = '��ٻ�����' then 3 
		when ta.�Ŷ� = '���Ԫ-�ɶ�������' and  ta.��Ա = '' then 4
		when ta.�Ŷ� = '��η�-�ɶ�������' and  ta.��Ա = '' then 5
		when ta.�Ŷ� = '��Ӫ��-Ȫ��1��' and  ta.��Ա = '' then 6
		when ta.�Ŷ� = '��Ӫ��-Ȫ��2��' and  ta.��Ա = '' then 7
		when ta.�Ŷ� = '��Ӫ��-Ȫ��3��' and  ta.��Ա = '' then 8
		when ta.�Ŷ� = '���Ԫ-�ɶ�������' and  ta.��Ա != '' then 9
		when ta.�Ŷ� = '��η�-�ɶ�������' and  ta.��Ա != '' then 10
		when ta.�Ŷ� = '��Ӫ��-Ȫ��1��' and  ta.��Ա != '' then 11
		when ta.�Ŷ� = '��Ӫ��-Ȫ��2��' and  ta.��Ա != '' then 12
		when ta.�Ŷ� = '��Ӫ��-Ȫ��3��' and  ta.��Ա != '' then 13
	end as ����
	,*
	,replace(concat(right('2023-04-01',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('2023-03-01',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `��Ʒ����ʱ�䷶Χ`
from t_sale_stat ta
order by ���� asc 