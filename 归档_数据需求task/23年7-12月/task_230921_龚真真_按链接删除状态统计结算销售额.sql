-- ����ɾ�����ӵ�Ӱ��
-- ���������ӷ�Ϊ ��ǰ��ɾ�� �� ��ǰδɾ�������֣�
-- ������ x ����ά��ͳ�ƽ������۶�


select ms.Department ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) ����ѷ�������۶�
    ,round( sum( case when onli.shopcode is not null then TotalGross/ExchangeUSD end ) ,0 ) ��ǰδɾ�����Ӳ���
    ,round( sum( case when onli.shopcode is null then TotalGross/ExchangeUSD end ) ,0 ) ��ǰ��ɾ�����Ӳ���
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
    and ms.Department regexp '��ٻ�|�̳���|ľ����'
    and IsDeleted = 0  and SettlementTime >= '2023-03-01' and SettlementTime < '2023-09-01'
left join ( select distinct sellersku ,shopcode from erp_amazon_amazon_listing eaal
    join mysql_store ms on eaal.shopcode = ms.Code
        and ms.Department regexp '��ٻ�|�̳���|ľ����'
        and ListingStatus!=5 ) onli
    on wo.shopcode = onli.ShopCode and wo.SellerSku = onli.SellerSKU  -- δɾ������
group by ms.Department ,year(SettlementTime)  ,month(SettlementTime)
order by Department,�����·�


select ms.Department ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) ����ѷ�������۶�
    ,round( sum( case when onli.shopcode is not null then TotalGross/ExchangeUSD end ) ,0 ) ��ǰδɾ�����Ӳ���
    ,round( sum( case when onli.shopcode is null then TotalGross/ExchangeUSD end ) ,0 ) ��ǰ��ɾ�����Ӳ���
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
    and ms.Department regexp '������'
    and IsDeleted = 0  and SettlementTime >= '2023-03-01' and SettlementTime < '2023-09-01'
left join ( select distinct sellersku ,shopcode ,asin from ads_tmh_online_listing where listing_status != '��ɾ��' ) onli
    on wo.shopcode = onli.ShopCode and wo.SellerSku = onli.SellerSKU and wo.asin = onli.ASIN -- δɾ������
group by ms.Department ,year(SettlementTime)  ,month(SettlementTime)
order by Department,�����·�

