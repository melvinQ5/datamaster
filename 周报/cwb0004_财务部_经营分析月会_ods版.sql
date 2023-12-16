
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4  )
with od as (
select ms.Department ,wo.SettlementTime ,wo.TotalProfit ,wo.TotalGross ,wo.ExchangeUSD ,spu as product_spu ,sku as product_sku ,wo.PlatOrderNumber ,wo.SellerSku ,wo.ShopIrobotId as shopcode
     ,TransactionType ,wo.asin ,wo.OrderCountry as site ,wo.PurchaseCosts ,wo.TradeCommissions ,wo.AdvertisingCosts ,LocalFreight ,OverseasDeliveryFee , HeadFreight , FBAFee ,RefundAmount
from ods_orderdetails wo
join mysql_store ms on wo.ShopIrobotId  = ms.Code
    and ms.Department regexp '��ٻ�|�̳���|ľ����|������'
    and IsDeleted = 0  and SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}'
left join (select distinct  boxsku ,sku ,spu from  wt_products ) wp on wo.BoxSku = wp.BoxSku
)

-- ��Ӫ���ָ��
select '${StartDay}' as ���ڵ�һ�� ,'Ӫҵ��' as ָ��  , ifnull(Department,'��˾')  as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'ë����' as ָ��  ,  ifnull(Department,'��˾')  as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round( sum(  TotalProfit/ExchangeUSD ) ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'ë����' as ָ��  ,  ifnull(Department,'��˾')  as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round( sum( TotalProfit ) / sum( TotalGross ) ,4 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
-- ���
union all
select '${StartDay}' as ���ڵ�һ�� ,'�����˿��' as ָ��  ,  ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  RefundAmount /ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'�����˿��ռӪҵ���' as ָ��  ,  ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs(  round( sum( RefundAmount ) / sum( TotalGross ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))

-- ��ӪЧ��-SPUά��
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SPU����' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,count( distinct product_spu )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��λ���۶�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��λë����' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��λ������' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  count(distinct PlatOrderNumber ) / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
-- ��ӪЧ��-SKUά��
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SKU����' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,count(distinct product_sku )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SKU��λ���۶�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SKU��λë����' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'����SKU��λ������' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  count(distinct PlatOrderNumber ) / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))


-- ��ӪЧ��-����ά��
union all
select '${StartDay}' as ���ڵ�һ�� ,'������������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    , count(distinct case when TransactionType = '����' then concat(shopcode,SellerSku) end )
from od where Department regexp '��ٻ�|�̳���|ľ����' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ���۶�' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct case when TransactionType = '����' then concat(shopcode,SellerSku) end )  ,0 )
from od where Department regexp '��ٻ�|�̳���|ľ����' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ�����' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct case when TransactionType = '����' then concat(shopcode,SellerSku) end ) ,0 )
from od where Department regexp '��ٻ�|�̳���|ľ����' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  count(distinct PlatOrderNumber ) / count(distinct case when TransactionType = '����' then concat(shopcode,SellerSku) end )  ,0 )
from od where Department regexp '��ٻ�|�̳���|ľ����' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'������������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
   ,count(distinct case when TransactionType = '����' then concat(asin,site) end )
from od where Department regexp '������' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ���۶�' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalGross/ExchangeUSD )  /  count(distinct case when TransactionType = '����' then concat(asin,site) end )  ,0 )
from od where Department regexp '������' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ�����' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  sum(  TotalProfit/ExchangeUSD )  /  count(distinct case when TransactionType = '����' then concat(asin,site) end )  ,0 )
from od where Department regexp '������' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ�λ������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,round(  count(distinct PlatOrderNumber ) /  count(distinct case when TransactionType = '����' then concat(asin,site) end )  ,0 )
from od where Department regexp '������' group by Department ,year(SettlementTime)  ,month(SettlementTime)


-- ��Ч
union all
select '${StartDay}' as ���ڵ�һ�� ,'������Ч' as ָ��  , a.Department as ���� ,'��Ӫ�����»�' ,set_year ������� ,set_month �����·�
    ,round ( totalgross / EmpCount )
from (
select ifnull(Department,'��˾') department ,year(SettlementTime)  set_year ,month(SettlementTime) set_month ,round(  sum(  TotalGross/ExchangeUSD )  ,0 ) totalgross
from od  group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime))) ) a
left join ads_staff_stat b on a.department = b.department and a.set_month = month(b.FirstDay) and a.set_year = year(b.FirstDay)
union all
select '${StartDay}' as ���ڵ�һ�� ,'������Ч' as ָ��  , a.Department as ���� ,'��Ӫ�����»�' ,set_year ������� ,set_month �����·�
    ,round ( totalgross / SaleCount )
from (
select ifnull(Department,'��˾') department ,year(SettlementTime)  set_year ,month(SettlementTime) set_month ,round(  sum(  TotalGross/ExchangeUSD )  ,0 ) totalgross
from od  group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime))) ) a
left join ads_staff_stat b on a.department = b.department and a.set_month = month(b.FirstDay) and a.set_year = year(b.FirstDay)

-- ���۳ɱ�
union all
select '${StartDay}' as ���ڵ�һ�� ,'�ɹ��ɱ�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  PurchaseCosts/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'Ӷ��ɱ�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  TradeCommissions/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'���ɱ�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  AdvertisingCosts/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'�����ɱ�' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))

-- ���۳ɱ�ռ��
union all
select '${StartDay}' as ���ڵ�һ�� ,'�ɹ��ɱ�ռ��' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  PurchaseCosts/ExchangeUSD ) / sum(  TotalGross/ExchangeUSD ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'Ӷ��ɱ�ռ��' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  TradeCommissions/ExchangeUSD )  / sum(  TotalGross/ExchangeUSD )  ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'���ɱ�ռ��' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  AdvertisingCosts/ExchangeUSD )  / sum(  TotalGross/ExchangeUSD )  ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as ���ڵ�һ�� ,'�����ɱ�ռ��' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year(SettlementTime) ������� ,month(SettlementTime) �����·�
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD )  / sum(  TotalGross/ExchangeUSD ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)));



-- ---------------------------------------------------------
-- ��ʽȡ��

-- SPU������
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'SPU������' as ָ��  , ifnull(ProjectTeam,'��˾') as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,count( distinct SPU)
from erp_product_products where ProductStatus != 2 and IsDeleted = 0 and IsMatrix = 0 and DevelopLastAuditTime is not null and status = 10 
	and ProjectTeam  regexp '��ٻ�|�̳���|ľ����'
group by grouping sets (() ,(ProjectTeam)) ;

-- SPU������ ������ʷ��: ��ȡ�������ݣ���ʷ�������¿��ǹ���Ŀǰδɾ���ģ� �һ�ȡ��Ʒ���ݣ�Ŀǰδͣ���ģ��ۺ��ж�ͳ��SPU��Sku��
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as ���ڵ�һ�� ,'SPU������' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
--     ,count( distinct wl.SPU)
-- from wt_listing wl join mysql_store ms on wl.shopcode = ms.Code and wl.IsDeleted=0
-- join wt_products wp on wl.sku = wp.sku and wp.ProductStatus !=2 and wp.IsDeleted=0
-- where MinPublicationDate < '${NextStartDay}'
-- group by grouping sets (() ,(Department)) ;


-- SKU������
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'SKU������' as ָ��  , ifnull(ProjectTeam,'��˾') as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,count( distinct SKU)
from erp_product_products where ProductStatus != 2 and IsDeleted = 0 and IsMatrix = 0 and DevelopLastAuditTime is not null and ProjectTeam  regexp '��ٻ�|�̳���|ľ����'
group by grouping sets (() ,(ProjectTeam)) ;

-- SKU������ ������ʷ��: ��ȡ�������ݣ���ʷ�������¿��ǹ���Ŀǰδɾ���ģ� �һ�ȡ��Ʒ���ݣ�Ŀǰδͣ���ģ��ۺ��ж�ͳ��SPU��SKU��
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as ���ڵ�һ�� ,'SKU������' as ָ��  , ifnull(Department,'��˾') as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
--     ,count( distinct wl.SKU)
-- from wt_listing wl join mysql_store ms on wl.shopcode = ms.Code and wl.IsDeleted=0
-- join wt_products wp on wl.sku = wp.sku and wp.ProductStatus !=2 and wp.IsDeleted=0
-- where MinPublicationDate < '${NextStartDay}'
-- group by grouping sets (() ,(Department)) ;


-- ����������
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}' ) �·�
    ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) online_lst
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '��ٻ�|�̳���|ľ����'  and eaal.ListingStatus =1 and ms.ShopStatus='����'
group by Department
union all 
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  , Department as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}' ) �·�
    ,count( distinct concat(asin,site) ) online_lst
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '������'  and eaal.ListingStatus =1 and ms.ShopStatus='����'
group by Department;


-- ���������� ������ʷ��:��ʷ�·�8�µ����������� = ��ǰ���������������� - 8�����񿯵������� + 8������ɾ����������
-- ��ٻ� �̳��� ľ����
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  , a.Department as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}' ) �·�
--     ,online_lst - add_lst + dele_lst
-- from (
-- select Department
--     ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) online_lst
--     ,count(distinct case when PublicationDate >= '${NextStartDay}' then concat(eaal.ShopCode,eaal.SellerSKU) end ) add_lst
-- from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '��ٻ�|�̳���|ľ����' and eaal.IsDeleted =0 and eaal.ListingStatus =1 and ms.ShopStatus='����'
-- group by Department
-- ) a
-- left join (
-- select Department ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) dele_lst
-- from erp_amazon_amazon_listing_delete eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '��ٻ�|�̳���|ľ����' and  eaal.LastModificationTime >= '${NextStartDay}'  -- ��ë����ͨ��LastModificationTime,�����������ɾ�����ʱ��
-- group by Department
-- ) b
-- on a.Department=b.Department
-- union all 
-- select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  , a.Department as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}' ) �·�
--     ,online_lst - add_lst + dele_lst
-- from (
-- select Department
--     ,count( distinct concat(asin,site) ) online_lst
--     ,count(distinct case when PublicationDate >= '${NextStartDay}' then concat(eaal.ShopCode,eaal.SellerSKU) end ) add_lst
-- from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '������' and eaal.IsDeleted =0 and eaal.ListingStatus =1 and ms.ShopStatus='����'
-- group by Department
-- ) a
-- left join (
-- select Department ,count( distinct concat(asin,site) ) dele_lst
-- from erp_amazon_amazon_listing_delete eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '������' and  eaal.LastModificationTime >= '${NextStartDay}'  -- ��ë����ͨ��LastModificationTime,�����������ɾ�����ʱ��
-- group by Department
-- ) b
-- on a.Department=b.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  , '��˾' as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,sum(c4 + 0) �������������
from  manual_table where memo = '����������' and c3 = month('${StartDay}');



-- ����SPUռ��
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����SPUռ��' as ָ��  , a.handlename as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,round( a.ָ��ֵ /  b.ָ��ֵ ,4 )
from ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = '����SPU����' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = 'SPU������' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.�·� = b.�·� ;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����SKUռ��' as ָ��  , a.handlename as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,round( a.ָ��ֵ /  b.ָ��ֵ ,4 )
from ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = '����SKU����' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = 'SKU������' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.�·� = b.�·� ;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��������ռ��' as ָ��  , a.handlename as ���� ,'��Ӫ�����»�' ,year( '${StartDay}') ��� ,month( '${StartDay}') �·�
    ,round( a.ָ��ֵ /  b.ָ��ֵ ,4 )
from ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = '������������' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as �·� ,c4 as ָ��ֵ from manual_table where memo = '����������' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.�·� = b.�·� ;


