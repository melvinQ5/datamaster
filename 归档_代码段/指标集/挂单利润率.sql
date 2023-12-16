-- �ҵ�������
select shopcode ,SellerSku
        ,round( (gross_include_refunds - ifnull(expend_include_ads,0)  ) /  (gross_include_refunds) ,4) Ori_Profit
from ( select wo.shopcode ,wo.SellerSku
     ,round( sum((TotalGross )/ExchangeUSD),2) as gross_include_refunds -- ���������˿���
    ,round( sum(
        -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
        ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
    from import_data.wt_orderdetails wo
    join import_data.mysql_store  ms on wo.shopcode=ms.Code and ms.department regexp '��'
    where PayTime >='${StartDay}' and PayTime<' ${NextStartDay}' and wo.IsDeleted=0 and FeeGross = 0 and OrderStatus <> '����'
             and TransactionType = '����'
             group by wo.shopcode ,wo.SellerSku
     ) t
