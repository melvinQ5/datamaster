
with
t0 as (
select distinct dk1.spu
    ,case when ele_name_priority regexp '����|ʥ����' then ele_name_priority else '����' end as theme_ele
from dep_kbh_product_level_potentail dk1
left join ( select distinct spu ,ele_name_priority from dep_kbh_product_test ) dk2 on dk1.spu = dk2.spu
where  isStopPush ='��'
)

,t_list as (  -- 10-11���¿��ǵ�����
select distinct wl.SPU ,wl.SKU  ,wl.MarketType ,wl.SellerSKU ,wl.ShopCode ,wl.asin ,CompanyCode ,theme_ele
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
    and ms.Department = '��ٻ�'
     AND MinPublicationDate >= '2023-10-01' and MinPublicationDate < '2023-12-01' and IsDeleted=0
join t0 on wl.spu = t0.spu
)

select round( sum( TotalGross/ExchangeUSD ),2) 11���¿������۶�S2
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t0 on wo.Product_SPU  = t0.spu
where wo.IsDeleted=0 and TransactionType='����'
    and PayTime >= '2023-11-01' and PayTime < '2023-12-01'
	and ms.Department = '��ٻ�'



,od as (  -- ���� spu x ��������
select ifnull(theme_ele,'�ϼ�') theme_ele
    ,round( sum( TotalGross/ExchangeUSD ),2) 11���¿������۶�S2
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_list on wo.shopcode  = t_list.ShopCode and wo.SellerSku=t_list.SellerSKU -- �¿������ӳ���
where wo.IsDeleted=0 and TransactionType='����'
    and PayTime >= '2023-11-01' and PayTime < '2023-12-01'
	and ms.Department = '��ٻ�'
group by grouping sets ((),(theme_ele))
)

,ad as (
select ifnull(theme_ele,'�ϼ�') theme_ele
    , round(sum(AdClicks)) as AdClicks
    , round(sum(Adspend)) as Adspend
    , round(sum(AdSales)) as AdSales
from wt_adserving_amazon_daily waad
join t_list on waad.shopcode  = t_list.ShopCode and waad.SellerSku=t_list.SellerSKU and waad.asin = t_list.asin -- �¿������ӳ���
where GenerateDate >= '2023-11-01' and GenerateDate < '2023-12-01'
group by grouping sets ((),(theme_ele))
)

select theme_ele 10��11���¿��Ǹ�ǱƷ
,11���¿������۶�S2
,Adspend 11���¿��ǹ�滨��
,AdSales 11���¿��ǹ��ҵ��
,round( Adspend / AdClicks ,4) 11���¿���CPC
from od left join ad on od.theme_ele = ad.theme_ele