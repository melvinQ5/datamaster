-- ��2022��9�µ�2023��8�£����ǹ�˾��ٻ�ҵ��������۶����������ݣ������¸�

select left(SettlementTime,7) as �����·�
    ,round( sum( TotalGross/ExchangeUSD ) ,2) ���۶�usd
    ,round( sum( TotalProfit/ExchangeUSD ) ,2) �����usd
    ,round( sum( TotalProfit/ExchangeUSD ) / sum( TotalGross/ExchangeUSD ) ,4) ������
from wt_orderdetails wo
join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '��ٻ�'
where IsDeleted=0 and SettlementTime >= '2022-09-01' and SettlementTime < '2023-09-01'
group by left(SettlementTime,7)
order by left(SettlementTime,7)