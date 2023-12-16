
-- �������
�����ۣ�
��վ��ռ�ı��أ�ÿ��top���ޱ仯

-- ��վ��
select ifnull(site,'����վ��') վ�� ,year(SettlementTime) year
     ,round(sum(totalgross/exchangeusd)/10000) ���۶�_wUSD
     ,round(sum(TotalProfit/exchangeusd)/10000) �����_wUSD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) ������
     ,count(distinct PlatOrderNumber) ������
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) �͵�_USD
from wt_orderdetails where SettlementTime>='2020-01-01' and OrderStatus!= '����'
group by grouping sets ((year(SettlementTime)),(site ,year(SettlementTime)))


-- ��Ʒ��
select wp.cat1 ,year(SettlementTime) year
      ,round(sum(totalgross/exchangeusd)/10000,2) ���۶�_wUSD
     ,round(sum(TotalProfit/exchangeusd)/10000,2) �����_wUSD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) ������
     ,count(distinct PlatOrderNumber) ������
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) �͵�_USD
from wt_orderdetails wo
left join wt_products wp on wo.BoxSku = wp.BoxSku
where SettlementTime>='2020-01-01'
group by wp.cat1 ,year(SettlementTime)-

-- ��Ʒ��
select  row_number() over (partition by year order by ���۶�_wUSD desc ) �������۶�����,*
from (select wp.cat1
           , wp.cat2
           , year(SettlementTime)                                                        year
           , round(sum(totalgross / exchangeusd) / 10000, 2)                            ���۶�_wUSD
           , round(sum(TotalProfit / exchangeusd) / 10000, 2)                           �����_wUSD
           , round(sum(TotalProfit / exchangeusd) / sum(totalgross / exchangeusd), 4)   ������
           , count(distinct PlatOrderNumber)                                            ������
           , round(sum(TotalProfit / exchangeusd) / count(distinct PlatOrderNumber), 2) �͵�_USD
      from wt_orderdetails wo
               left join wt_products wp on wo.BoxSku = wp.BoxSku
      where SettlementTime >= '2020-01-01'
        and Cat1 regexp 'A3'
      group by wp.cat1, wp.cat2, year(SettlementTime)) ta


-- ��Ŀxվ��
select wp.cat1 һ����Ŀ,site վ��,year(SettlementTime) year
      ,round(sum(totalgross/exchangeusd)) ���۶�_USD
     ,round(sum(TotalProfit/exchangeusd)) �����_USD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) ������
     ,count(distinct PlatOrderNumber) ������
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) �͵�_USD
from wt_orderdetails wo
left join wt_products wp on wo.BoxSku = wp.BoxSku
where SettlementTime>='2023-01-01'
group by wp.cat1,site ,year(SettlementTime)
