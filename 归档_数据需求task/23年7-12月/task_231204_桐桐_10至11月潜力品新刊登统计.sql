
with
t0 as (
select distinct dk1.spu
    ,case when ele_name_priority regexp '冬季|圣诞节' then ele_name_priority else '其他' end as theme_ele
from dep_kbh_product_level_potentail dk1
left join ( select distinct spu ,ele_name_priority from dep_kbh_product_test ) dk2 on dk1.spu = dk2.spu
where  isStopPush ='否'
)

,t_list as (  -- 10-11月新刊登的链接
select distinct wl.SPU ,wl.SKU  ,wl.MarketType ,wl.SellerSKU ,wl.ShopCode ,wl.asin ,CompanyCode ,theme_ele
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
    and ms.Department = '快百货'
     AND MinPublicationDate >= '2023-10-01' and MinPublicationDate < '2023-12-01' and IsDeleted=0
join t0 on wl.spu = t0.spu
)

select round( sum( TotalGross/ExchangeUSD ),2) 11月新刊登销售额S2
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t0 on wo.Product_SPU  = t0.spu
where wo.IsDeleted=0 and TransactionType='付款'
    and PayTime >= '2023-11-01' and PayTime < '2023-12-01'
	and ms.Department = '快百货'



,od as (  -- 主键 spu x 推送日期
select ifnull(theme_ele,'合计') theme_ele
    ,round( sum( TotalGross/ExchangeUSD ),2) 11月新刊登销售额S2
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_list on wo.shopcode  = t_list.ShopCode and wo.SellerSku=t_list.SellerSKU -- 新刊登链接出单
where wo.IsDeleted=0 and TransactionType='付款'
    and PayTime >= '2023-11-01' and PayTime < '2023-12-01'
	and ms.Department = '快百货'
group by grouping sets ((),(theme_ele))
)

,ad as (
select ifnull(theme_ele,'合计') theme_ele
    , round(sum(AdClicks)) as AdClicks
    , round(sum(Adspend)) as Adspend
    , round(sum(AdSales)) as AdSales
from wt_adserving_amazon_daily waad
join t_list on waad.shopcode  = t_list.ShopCode and waad.SellerSku=t_list.SellerSKU and waad.asin = t_list.asin -- 新刊登链接出单
where GenerateDate >= '2023-11-01' and GenerateDate < '2023-12-01'
group by grouping sets ((),(theme_ele))
)

select theme_ele 10至11月新刊登高潜品
,11月新刊登销售额S2
,Adspend 11月新刊登广告花费
,AdSales 11月新刊登广告业绩
,round( Adspend / AdClicks ,4) 11月新刊登CPC
from od left join ad on od.theme_ele = ad.theme_ele