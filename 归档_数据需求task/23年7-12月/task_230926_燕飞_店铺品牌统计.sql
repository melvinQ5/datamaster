-- �嵥1 IT��ȡ����x�̱�
with map as ( -- IT��ȡƷ�ƹ�ϵ
select c4 as shopcode ,c1 as site ,c2 as brand ,c3 as ismark ,ws.AccountCode ,ws.Market ,ws.ShopStatus ,SellUserName ,NodePathName
from manual_table  mb
left join wt_store ws on mb.c4 = ws.Code
where handlename = '��ٻ�����Ʒ�ƹ�ϵ' and handletime = '2023-09-26'
)

, od_stat as (
select  map.AccountCode ,map.shopcode, map.brand
    ,map.SellUserName
    ,map.NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*1 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��30��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*3 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��90��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*6 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��180��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*12 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��360��������۶�
from wt_orderdetails wo
join map on wo.shopcode = map.shopcode
left join wt_products wp on wp.sku = wo.Product_Sku
where  wo.IsDeleted =0 and SettlementTime >= '2022-09-01'
group by map.AccountCode ,map.shopcode , map.brand ,SellUserName ,NodePathName ,category
)

,lst_stat as (
select  eaal.BrandName as brand ,AccountCode,shopcode ,SellUserName ,NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,count( distinct concat(ShopCode,SellerSKU) ) ����������
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='��ٻ�' and ListingStatus=1 and ShopStatus='����'
left join wt_products wp on wp.sku = eaal.sku
group by eaal.BrandName ,AccountCode,shopcode ,SellUserName ,NodePathName ,category
)
-- select * from lst_stat

,t0 as ( -- ���������
select distinct  AccountCode ,shopcode ,brand , category , Market ,ShopStatus ,SellUserName as ������Ա ,NodePathName as �Ŷ�
from map
join (select distinct concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category from wt_products wp ) wp
)

select t0.*
    ,����������
    ,��30��������۶�
    ,��90��������۶�
    ,��180��������۶�
    ,��360��������۶�
from t0
left join  od_stat t1 on t0.shopcode = t1.shopcode and t0.brand = t1.brand and t0.category = t1.category
left join  lst_stat t2 on t0.shopcode = t2.shopcode and t0.brand = t2.brand and t0.category = t2.category
where concat(t1.shopcode,t2.ShopCode) is not null ;-- �����ǵ���x�̱�x��Ŀ���޳�����û���������ӣ���û�г����ļ�¼


-- �嵥2 ��ٻ��������ӵĵ���x�̱�
with map as ( -- �����������ӵ�Ʒ�ƹ�ϵ
select  distinct shopcode , site ,BrandName as brand  ,ms.AccountCode ,ms.Market ,ms.ShopStatus ,SellUserName ,NodePathName
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='��ٻ�' and ListingStatus=1 and ShopStatus='����'
)

, od_stat as (
select  map.AccountCode ,map.shopcode, map.brand
    ,map.SellUserName
    ,map.NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*1 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��30��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*3 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��90��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*6 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��180��������۶�
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*12 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) ��360��������۶�
from wt_orderdetails wo
join map on wo.shopcode = map.shopcode
left join wt_products wp on wp.sku = wo.Product_Sku
where  wo.IsDeleted =0 and SettlementTime >= '2022-09-01'
group by map.AccountCode ,map.shopcode , map.brand ,SellUserName ,NodePathName ,category
)

,lst_stat as (
select  eaal.BrandName as brand ,AccountCode,shopcode ,SellUserName ,NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,count( distinct concat(ShopCode,SellerSKU) ) ����������
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='��ٻ�' and ListingStatus=1 and ShopStatus='����'
left join wt_products wp on wp.sku = eaal.sku
group by eaal.BrandName ,AccountCode,shopcode ,SellUserName ,NodePathName ,category
)
-- select * from lst_stat

,t0 as ( -- ���������
select distinct  AccountCode ,shopcode ,brand , category , Market ,ShopStatus ,SellUserName as ������Ա ,NodePathName as �Ŷ�
from map
join (select distinct concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category from wt_products wp ) wp
)

select t0.*
    ,����������
    ,��30��������۶�
    ,��90��������۶�
    ,��180��������۶�
    ,��360��������۶�
from t0
left join  od_stat t1 on t0.shopcode = t1.shopcode and t0.brand = t1.brand and t0.category = t1.category
left join  lst_stat t2 on t0.shopcode = t2.shopcode and t0.brand = t2.brand and t0.category = t2.category
where concat(t1.shopcode,t2.ShopCode) is not null -- �����ǵ���x�̱�x��Ŀ���޳�����û���������ӣ���û�г����ļ�¼

-- �嵥3
select  shopcode ,SellUserName as ������Ա ,NodePathName as �Ŷ�
    ,count( distinct concat(ShopCode,SellerSKU) ) ����������
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='��ٻ�' and ListingStatus=1 and ShopStatus='����'
group by shopcode ,SellUserName  ,NodePathName