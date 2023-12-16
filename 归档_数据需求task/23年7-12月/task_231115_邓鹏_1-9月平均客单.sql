-- 2023��1-9�£�ÿ��������Ϳ�ٻ�ƽ���͵����Ƕ��ٰ���
with
od as (
select TransactionType ,PayTime
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month
    ,month(settlementtime) set_month
     ,ms.Department
,BoxSku
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
where wo.IsDeleted=0  and ms.Department regexp '��ٻ�|������' and settlementtime  >='${StartDay}' and settlementtime < '${NextStartDay}'
)

select  Department ,set_month
    ,ROUND(sum(TotalGross_usd_pay)) �������۶�S3
    ,count( distinct  PlatOrderNumber) ������
    ,round( sum(TotalGross_usd_pay) / count( distinct  PlatOrderNumber),2 ) ����͵���
from od
group by Department ,set_month
ORDER BY Department ,set_month
