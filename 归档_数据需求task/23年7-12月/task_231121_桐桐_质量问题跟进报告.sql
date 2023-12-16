-- ͳ����Ʒ�������������֮�󣬸�SPU��һ���ɹ�������ʱ���ǰ�����ݶԱȡ�
-- ������Χ���ѷ���������������ʱ���ȡ�����������㷢��ʱ���ڷ����ĸ���˿�

with mt as (
select  memo as spu ,c1 as �˿���� ,c2 as �Ƿ�Ӳɹ������� ,date(c3) as pre_date
from manual_table mt
where handlename='ͩͩ_��������SPU_231118' )

,purc as ( -- ��������֮�󣬸�SPU��һ���ɹ�������ʱ��
select spu ,OrderNumber as min_ordernumber ,DeliveryTime as min_deliverytime
from (
select t.* ,row_number() over (partition by spu order by DeliveryTime) sort
    from (
    select mt.spu ,dp.OrderNumber ,DeliveryTime
    from daily_PurchaseOrder dp
    join wt_products wp on dp.BoxSku = wp.BoxSku and wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0
    join mt on wp.spu =mt.spu
    where timestampdiff(second ,pre_date,OrderTime) >= 0
    group by mt.spu ,dp.OrderNumber,DeliveryTime
    ) t ) t2
where sort = 1 )

,t0 as ( -- ����������ƺ����²ɹ�����SPU
select mt.spu ,�˿���� ,pre_date ,ifnull(min_ordernumber,'������ƺ����²ɹ���') min_ordernumber ,min_deliverytime
from mt left join purc on mt.spu =purc.spu )

,od_pay_bf as (
select wo.Product_Spu as spu
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join t0 on wo.Product_Spu =t0.spu
where wo.IsDeleted = 0
  and timestampdiff(day ,min_deliverytime,ShipTime) >= -30 and timestampdiff(day ,min_deliverytime,ShipTime) < 0 -- �������ǰ30��
  and ShipTime > '2000-01-01 00:00:00' -- ��������
group by wo.Product_Spu
)

,od_refund_bf as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select  wo.Product_Spu as spu
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join t0 on wo.Product_Spu =t0.spu
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and TransactionType = '�˿�'
  and timestampdiff(day ,min_deliverytime,ShipTime) >= -30 and timestampdiff(day ,min_deliverytime,ShipTime) < 0 -- �������ǰ30��
and ShipTime > '2000-01-01 00:00:00' -- ��������
group by wo.Product_Spu
)

,od_stat_bf as(
select a. spu
     ,sales_undeduct_refunds ����ǰ30�����۶�S2
     ,profit_undeduct_refunds ����ǰ30�������M2
     ,sales_refund ����ǰ30���˿���
     ,round( sales_refund / (sales_undeduct_refunds) ,4) ����ǰ30���˿���
     ,round( profit_undeduct_refunds / sales_undeduct_refunds ,4) ����ǰ30��������R2
from od_pay_bf a left join od_refund_bf b on a.spu =b.spu
)
   
,od_pay_af as (
select wo.Product_Spu as spu
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join t0 on wo.Product_Spu =t0.spu
where wo.IsDeleted = 0
  and timestampdiff(day ,min_deliverytime,ShipTime) >= 0 and timestampdiff(day ,min_deliverytime,ShipTime) < 30 -- �������ǰ30��
  and ShipTime > '2000-01-01 00:00:00' -- ��������
group by wo.Product_Spu
)

,od_refund_af as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select  wo.Product_Spu as spu
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join t0 on wo.Product_Spu =t0.spu
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and TransactionType = '�˿�'
  and timestampdiff(day ,min_deliverytime,ShipTime) >= 0 and timestampdiff(day ,min_deliverytime,ShipTime) < 30 -- �������ǰ30��
    and ShipTime > '2000-01-01 00:00:00' -- ��������
group by wo.Product_Spu
)

,od_stat_af as(
select a. spu
     ,sales_undeduct_refunds ���ƺ�30�����۶�S2
     ,profit_undeduct_refunds ���ƺ�30�������M2
     ,sales_refund ���ƺ�30���˿���
     ,round( sales_refund / (sales_refund + sales_undeduct_refunds) ,4) ���ƺ�30���˿���
     ,round( profit_undeduct_refunds / sales_undeduct_refunds ,4) ���ƺ�30��������R2
from od_pay_af a left join od_refund_af b on a.spu =b.spu
)



select t0.spu ,�˿���� ,pre_date ����������� ,min_ordernumber ������ױʵ����µ��� ,min_deliverytime �ñʵ���ʱ��
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 then '��' else '��' end ���ƾ���Ƿ���30��
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 then round( ifnull(����ǰ30���˿���,0) - ifnull(���ƺ�30���˿���,0) ,4) end ��30���˿��ʽ���
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 and  ifnull(����ǰ30���˿���,0) - ifnull(���ƺ�30���˿���,0) >= 0.03 then '��' else '��' end �Ƿ���Ƴɹ�
     , ifnull(����ǰ30���˿���,0) ����ǰ30���˿���
     , ifnull(���ƺ�30���˿���,0) ���ƺ�30���˿���

     , ����ǰ30�����۶�S2
     , ����ǰ30�������M2
     , ����ǰ30���˿���
     , ����ǰ30��������R2

     , ���ƺ�30�����۶�S2
     , ���ƺ�30�������M2
     , ���ƺ�30���˿���
     , ���ƺ�30��������R2

from t0 
left join od_stat_af t1 on t0.spu =t1.spu 
left join od_stat_bf t2 on t0.spu =t2.spu
order by ��30���˿��ʽ��� desc