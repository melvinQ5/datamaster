

With cdtopspu as(-- ���㵱�ܵ���Ʒ�ֲ�
select 'week1' weeknum,spu,date(min(DevelopLastAuditTime))AuditTime
,(case when min(DevelopLastAuditTime)>='2023-04-01' then '��Ʒ'end) ��Ʒ
, (case when sum((totalgross-FeeGross)/ExchangeUSD)>=1500 then 'Ȫ�ݱ���' 
when  sum((totalgross-FeeGross)/ExchangeUSD)>=500 and  sum((totalgross-FeeGross)/ExchangeUSD)<1500 
then 'Ȫ������' when sum((totalgross-FeeGross)/ExchangeUSD)<500 then 'Ȫ�ݳ���' end) as producttype

,round(sum((totalgross)/ExchangeUSD),2) sales
,round(sum((totalprofit)/ExchangeUSD),2) profit
,count(distinct platordernumber) orders
,round(sum(feegross/ExchangeUSD),2) freightfee
,round(sum(-RefundAmount),2) refund
,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort
,row_number() over(order by count(distinct platordernumber) desc) as ordersort
,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalgross/ExchangeUSD end),2) weeksales
,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
left join erp_product_products pp on pp.boxsku=wo.boxsku
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�' 
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -30 day) and paytime<'${NextStartDay}' and OrderStatus<>'����'
and wo.boxsku<>''  and wo.boxsku!='shopfee'
and ms.NodePathName regexp 'Ȫ��'
group by spu
order by salesort
)


,cdskumark as(-- ������Ʒ�ֲ���ҳ�sku���������ӷֲ�
select pp.boxsku ,pp.sku,cdtopspu.spu, cdtopspu.producttype  from cdtopspu
join erp_product_products pp on pp.spu=cdtopspu.spu
where boxsku is not null
)

,allspu as (-- ͳ��������Ʒ�ֲ������ͳ��
select 'ȫ��' type,IFNULL(producttype,'ȫ��')�ֲ�,count(distinct spu)����,round(sum(sales),2) monthsales
,round(sum(profit),2) monthprofit,round(sum(weeksales),2)weeksales
,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct spu),2) `��ֵ`
from cdtopspu
group by grouping sets((),(producttype))
order by producttype desc
)

,newspu as(-- ͳ����Ʒ����Ʒ�ֲ�����ͳ��
select '��Ʒ' type,IFNULL(producttype,'ȫ��')�ֲ�,count(distinct spu)����,round(sum(sales),2) monthsales,round(sum(profit),2) monthprofit,round(sum(weeksales),2)weeksales,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct spu),2) `��ֵ`
from cdtopspu
where ��Ʒ is not null
group by grouping sets((),(producttype))
order by producttype desc
)


,listdetail as (
select wo.asin,wo.site,wo.boxsku,producttype,
round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�' 
and ms.NodePathName regexp 'Ȫ��'
left join cdskumark d on d.boxsku=wo.boxsku
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -30 day) and paytime<'${NextStartDay}' and OrderStatus<>'����'
and asin<>'' and wo.boxsku <>'' and wo.boxsku!='shopfee'
group by wo.asin,wo.site,wo.boxsku,producttype
order by salesort
)

,listtype as (
select listdetail.*,(case when producttype in('Ȫ�ݱ���','Ȫ������') and orders/30 >= 5 then 'S' 
when orders/30 >= 1  and producttype in('Ȫ�ݱ���','Ȫ������') then 'A' 
when orders/30>=0.5 then 'B' else 'C' end) as listtype
from listdetail
-- where producttype is not null
)

,list as(
select '����'type,ifnull(listtype,'ȫ������') �ֲ�,count(distinct concat(asin,site))����, round(sum(sales),2)monthsales,round(sum(profit),2)monthprofit,round(sum(weeksales),2)weeksales,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct concat(asin,site)),2) `��ֵ`
from listtype
group by grouping sets((),(listtype))
order by �ֲ�
)

-- ,cal as(-- ͳ���ܱ��ֶ�
select * from allspu
union all
select * from newspu
union all
select * from list
-- )

-- �����ϸ��ܴε�����
,cdtopspu0 as(-- ���㵱�ܵ���Ʒ�ֲ�
select 'week0' weeknum0,spu,date(min(DevelopLastAuditTime))AuditTime,(case when min(DevelopLastAuditTime)>='2023-04-01' then '��Ʒ'end) ��Ʒ,  (case when sum((totalgross-FeeGross)/ExchangeUSD)>=1500 then 'Ȫ�ݱ���' when  sum((totalgross-FeeGross)/ExchangeUSD)>=500 and  sum((totalgross-FeeGross)/ExchangeUSD)<1500 
then 'Ȫ������' when sum((totalgross-FeeGross)/ExchangeUSD)<500 then 'Ȫ�ݳ���' end) as producttype0,round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
left join erp_product_products pp on pp.boxsku=wo.boxsku
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�' 
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -37 day) and paytime<date_add('${NextStartDay}',interval -7 day) and OrderStatus<>'����'
and wo.boxsku<>''  and wo.boxsku!='shopfee'
and ms.NodePathName regexp 'Ȫ��'
group by spu
order by salesort
)

,cdskumark0 as(-- ������Ʒ�ֲ���ҳ�sku���������ӷֲ�
select pp.boxsku ,pp.sku,cdtopspu0.spu, cdtopspu0.producttype0  from cdtopspu0
join erp_product_products pp on pp.spu=cdtopspu0.spu
where boxsku is not null
)

,listdetail0 as (
select wo.asin,wo.site,wo.boxsku,producttype0,
round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�' 
and ms.NodePathName regexp 'Ȫ��'
left join cdskumark0 d on d.boxsku=wo.boxsku
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -37 day) and paytime<date_add('${NextStartDay}',interval -7 day) and OrderStatus<>'����'
and asin<>'' and wo.boxsku <>'' and wo.boxsku!='shopfee'
group by wo.asin,wo.site,wo.boxsku,producttype0
order by salesort
)

,listtype0 as (
select listdetail0.*,(case when producttype0 in('Ȫ�ݱ���','Ȫ������') and orders>=15 then 'S' when orders>=5 and orders<15 and producttype0 in('Ȫ�ݱ���','Ȫ������') then 'A' when orders>=5 then 'B' when  orders>=1 and orders<5 then 'C' end) as listtype0
from listdetail0
-- where producttype is not null
)

,addallproduct as (
select '��Ʒ����������'mark, cdtopspu.*from cdtopspu
left join cdtopspu0 on cdtopspu0.spu=cdtopspu.spu and  producttype0 in ('Ȫ�ݱ���','Ȫ������') 
where producttype0 is null 
and producttype in ('Ȫ�ݱ���','Ȫ������')

)

,deleteallproduct as( -- ͳ��2���ܴ��б��������
select '��Ʒ���������'mark,cdtopspu0.* from cdtopspu0
left join cdtopspu on cdtopspu.spu=cdtopspu0.spu and  producttype in ('Ȫ�ݱ���','Ȫ������') 
where producttype is null 
and producttype0 in ('Ȫ�ݱ���','Ȫ������')
)
,addspu as( -- ͳ��2���ܴ��б���������
select '����������' type,producttype �ֲ�, count(*)����  from addallproduct
group by producttype
order by  producttype desc
)

,deletespu as( -- ͳ��2���ܴ��б��������
select '���������' type,producttype0 �ֲ�, count(*)����  from deleteallproduct
group by producttype0
order by  producttype0 desc
)


,addproduct as (
select '��Ʒ����������'mark, cdtopspu.*from cdtopspu
left join cdtopspu0 on cdtopspu0.spu=cdtopspu.spu and  producttype0 in ('Ȫ�ݱ���','Ȫ������') and cdtopspu0.��Ʒ is not null
where producttype0 is null 
and producttype in ('Ȫ�ݱ���','Ȫ������')
and cdtopspu.��Ʒ is not null
)

,deleteproduct as( -- ͳ��2���ܴ��б��������
select '��Ʒ���������'mark,cdtopspu0.* from cdtopspu0
left join cdtopspu on cdtopspu.spu=cdtopspu0.spu and  producttype in ('Ȫ�ݱ���','Ȫ������') and cdtopspu.��Ʒ is not null
where producttype is null 
and cdtopspu0.��Ʒ is not null
and producttype0 in ('Ȫ�ݱ���','Ȫ������')
)

,addnewspu as( -- ͳ��2���ܴ��б���������
select '��Ʒ����������' type,producttype �ֲ�, count(*)����  from addproduct
group by producttype
order by  producttype desc
)

,deletenewspu as( -- ͳ��2���ܴ��б��������
select '��Ʒ���������' type,producttype0 �ֲ�, count(*)����  from deleteproduct
group by producttype0
order by  producttype0 desc
)

,addlistmark as (
select 'SA����'mark,listtype.*from listtype
left join listtype0 on listtype.asin=listtype0.asin and listtype.site=listtype0.site and listtype0 in ('S','A')
where listtype0 is null 
and listtype in ('S','A')
)

,reducelistmark as(
select 'SA����'mark,listtype0.*from listtype0
left join listtype on listtype.asin=listtype0.asin and listtype.site=listtype0.site and listtype in ('S','A')
where listtype is null 
and listtype0 in ('S','A')
)


,addlist as( -- ͳ��2���ܴ���SA��������
select 'SA��������' type,listtype �ֲ�, count(*)����  from  addlistmark
group by listtype
order by listtype desc
)
,deletelist as( -- ͳ��2���ܴ���SA���Ӽ���
select 'SA���Ӽ���' type,listtype0 �ֲ�, count(*)����  from reducelistmark
group by listtype0
order by listtype0 desc
)


-- ͳ�ƽ������
-- select * from addspu
-- union all
-- select * from deletespu
-- union all
-- select * from addnewspu
-- union all
-- select * from deletenewspu
-- union all
-- select * from addlist
-- union all
-- select * from deletelist


-- ͳ�ƹ�������
-- select * from addallproduct
-- union all
-- select * from deleteallproduct
-- union all
-- select * from addproduct
-- union all
-- select * from deleteproduct
-- 


-- select * from addlistmark
-- union all
-- select * from reducelistmark
-- 