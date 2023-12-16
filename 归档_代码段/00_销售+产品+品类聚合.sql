
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SKU,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross
	,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku
	,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join proall_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-10-24',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-10-24',interval -28 day)
and PayTime <'2022-10-24'
and od.OrderNumber not in
	(
	select OrderNumber from (
	SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
	where
	ShipmentStatus = 'δ����' and OrderStatus = '����'
	and PayTime >=date_add('2022-10-24',interval -28 day) and PayTime < '2022-10-24'
	group by OrderNumber) a
	where alltype = '����')
)

/*���в���С����Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTim

e>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-10-24') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca






