with
od as ( -- ����ͳ�Ʒ�Χ
select wo.*,dd.week_num_in_year
from wt_orderdetails wo
join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '��ٻ�'
left join dim_date dd on date(paytime) = full_date
where PayTime >= '2023-07-31' -- 0731����һ
)

,prod as ( -- ��Ʒ��Χ
select distinct product_spu as spu ,ProductName ��Ʒ����,Logistic_Attr �������� ,CategoryPathByChineseName ϵͳ��Ŀ
    ,case when wp.ProductStatus = 0 then '����'
            when wp.ProductStatus = 2 then 'ͣ��'
            when wp.ProductStatus = 3 then 'ͣ��'
            when wp.ProductStatus = 4 then '��ʱȱ��'
            when wp.ProductStatus = 5 then '���'
            end as ��Ʒ״̬
from od left join wt_products wp on od.Product_Sku = wp.sku and wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0
)

,od_total_stat as ( -- �ۼ�ͳ��
select spu ,count(distinct Product_Sku) ����������SKU��
from od
join wt_products wp on od.Product_Sku = wp.sku and wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0 and wp.ProductStatus=0
group by spu
)

, od_week_stat as (
select Product_SPU as spu ,week_num_in_year
     ,round( sum((totalgross-feegross)/ExchangeUSD),2 ) �����˷����۶�
     ,round( sum((TotalProfit-feegross)/ExchangeUSD),2 ) �����˷������
     ,case
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 15 then '15+'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 10 then '10-15'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 5 then '5-10'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) >= 0 then '0-5'
     end �۸��
     ,sum(salecount) ����
     ,min(PayTime) min_paytime
from od
group by spu ,week_num_in_year
)

,refund_in30d_stat as ( -- ��30��ͳ��
select a.spu  ,round( ifnull(refund_amount,0) / totalgross ,2 ) ��30���ۼ��˿���
from (
    select Product_SPU as spu
     ,round( sum((totalgross)/ExchangeUSD),2 ) totalgross
    from wt_orderdetails wo
    join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '��ٻ�'
    left join dim_date dd on date(paytime) = full_date
    where PayTime >= date_add('${NextStartDay}' , INTERVAL -30 DAY)
    group by spu
     ) a
left join (
    select spu
        ,abs(round( sum( RefundUSDPrice ),2 )) refund_amount
    from ( select distinct PlatOrderNumber, RefundUSDPrice ,dim_date.week_num_in_year as refund_week
        from daily_RefundOrders rf
        join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='���˿�'  and ms.Department = '��ٻ�'
        join dim_date on dim_date.full_date = date(rf.RefundDate)
        where RefundDate  >= date_add('${NextStartDay}' , INTERVAL -30 DAY) and RefundDate < '${NextStartDay}'
        ) t1
    join (
        select PlatOrderNumber ,Product_SPU as spu   from wt_orderdetails wo
        where IsDeleted=0 and TransactionType='����' and department = '��ٻ�' group by PlatOrderNumber  ,Product_SPU
        ) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
    group by spu
    ) b
on a.spu = b.spu
)

select
t0.spu
,����������SKU��
,��Ʒ����
,��������
,'' ��Ʒ�ߴ�
,ϵͳ��Ŀ
,'' ��Ʒ����
,'' ��Ŀ
,'' ����
,'' ����
,'' ���Ԫ��
,'' ����Ԫ��
,'' ����ԭ��
,'' ����
,'' ���
,'' ��װ
,'' PCS
,'' ͨ����
,'' ʹ�ù���
,'' ʹ�ó���
,'' ʹ�ÿ�Ⱥ
,'' �����
,'' ������
,'' �ɳ���
,'' ˥����
,�����˷����۶�
,�����˷������
,����
,�۸��
,��30���ۼ��˿���
,��Ʒ״̬
,'' ͣ��ԭ��
,'' �������
,'' ԭ�����
,'' ԭ����ϸ
,'' ���Զ���
,'' �������
from prod t0
left join od_total_stat t1 on  t0.spu =t1.Spu
left join ( select * from od_week_stat where week_num_in_year = (select max(week_num_in_year) from od_week_stat)  ) t2 on t0.spu =t2.Spu -- ȡ����һ��
left join refund_in30d_stat t3 on  t0.spu =t3.Spu




