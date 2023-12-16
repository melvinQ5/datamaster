-- 2023��1-9�£�ÿ��������Ϳ�ٻ�ƽ���͵����Ƕ��ٰ���
with
od as (
select TransactionType ,PayTime
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( FeeGross/ExchangeUSD,2) FeeGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month
    ,month(settlementtime) set_month
    ,year(settlementtime) set_year
     ,ms.Department
,BoxSku
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
where wo.IsDeleted=0  and ms.Department regexp '��ٻ�|������' and settlementtime  >='${StartDay}' and settlementtime < '${NextStartDay}'
)
,od_stat as (
select  wp.spu ,set_year,set_month
    ,ROUND(sum(TotalGross_usd_pay),4) �������۶�S3
    ,ROUND(sum(TotalProfit_usd_pay),4) ���������M3
    ,ROUND(sum(refundamount_usd),4) �˿��
    ,ROUND(sum(FeeGross_usd_pay),4) �˷�����
    ,ROUND(sum(SaleCount)) ����
    ,count( distinct  PlatOrderNumber) ������
    ,count( distinct  date(PayTime)) ��������
    ,round( count( distinct  PlatOrderNumber) / count( distinct  date(PayTime)),2 ) �վ�����
    ,round( sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross_usd_pay end ) ,4) �ҵ����۶�
    ,round( sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit_usd_pay end ) /
        sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then  TotalGross_usd_pay end ) ,4) �ҵ�������
from od
join wt_products wp on od.BoxSku =wp.BoxSku and wp.IsDeleted=0 and wp.ProjectTeam = '��ٻ�'
group by wp.spu ,set_year ,set_month
ORDER BY wp.spu ,set_year ,set_month )

,onlinelst as (select spu ,count(distinct concat(sellersku,shopcode)) ���������� , min(MinPublicationDate) �״ο���ʱ�� from wt_listing wl join mysql_store ms on ms.Code=wl.ShopCode and ms.Department = '��ٻ�' and ms.ShopStatus = '����' and wl.ListingStatus= 1 group by spu )
,ware as ( select spu
,sum(TotalInventory) ��ǰ�����
,sum(TotalPrice) ��ǰ�����
,sum(InventoryAge45) 0��45�������
,sum(InventoryAge90) 46��90�������
,sum(InventoryAge180) 91��180�������
,sum(InventoryAge270) 181��270�������
,sum(InventoryAge365) 271��365�������
,sum(InventoryAgeOver) ����365�������
from daily_WarehouseInventory dw join wt_products wp on dw.BoxSku=wp.BoxSku and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0 where CreatedTime = '2023-11-24' group by spu )

select t1.*
,����������
,�״ο���ʱ��
,ProductName ��Ʒ����
,CategoryPathByChineseName ȫ��Ŀ
,Logistics_Attr ��������
,TortType  ��Ȩ����

,��ǰ�����
, ��ǰ�����
, 0��45�������
,46��90�������
, 91��180�������
,181��270�������
, 271��365�������
,����365�������
from od_stat t1
left join erp_product_products epp on t1.spu = epp.spu and epp.IsDeleted=0 and epp.IsMatrix=1 and epp.ProjectTeam='��ٻ�'
left join (select distinct  spu ,CategoryPathByChineseName,Logistics_Attr,TortType from wt_products where ProjectTeam='��ٻ�' and IsDeleted=0 ) wp on t1.spu=wp.spu
left join onlinelst o on t1.spu = o.SPU
left join ware  on t1.spu = ware.SPU