


with lst as (
select  dkll .*
from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add('${NextStartDay}',interval -1 week) -- NextStartDay 是周报计算日，FirstDay 是存储快照当周的周一，因此 -1-1
    and list_level regexp 'S|A|潜力'
	-- and dkll.Department = '快百货成都'
)

,lst_1 as ( -- 上周
select  asin ,site ,list_level as mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add('${NextStartDay}',interval -1-1 week)
)

,lst_2 as (  -- 再上周
select  asin ,site ,list_level as mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add('${NextStartDay}',interval -2-1 week)
)

,lst_3 as ( -- 再上周
select  asin ,site ,list_level as mark_3 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add('${NextStartDay}',interval -3-1 week)
)

, od_list_in30d as ( -- 链接分层主键为asin+site，找到对应最小粒度
select wo.site,asin,boxsku,Product_Sku as sku,shopcode,ms.AccountCode,SellerSku,SellUserName,NodePathName,dep2,date(wo.PublicationDate)  PublicationDate
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'
group by wo.site,asin,boxsku,Product_Sku,shopcode,ms.AccountCode,SellerSku,SellUserName,NodePathName,dep2,PublicationDate
)


, listings as ( -- 最小粒度
select
     lst.asin
     , oli.shopcode
     , oli.SellerSku
     , lst.FirstDay as 统计周当周一
     , week as 周序
     , Department as 团队
     , case when list_level = '散单' then '其他' else list_level end as list_level

     , lst.site

     , oli.PublicationDate
     , oli.AccountCode
     , oli.SellUserName
     , oli.NodePathName
     , ListingStatus as 链接状态
     , sales_no_freight as 近30天不含运费销售额
     , sales_in30d 近30天销售额
     , profit_in30d 近30天利润额
     , list_orders 近30天订单量
     , prod_level
     , oli.BoxSku
     , lst.spu
     , oli.sku
     , lst.ProductStatus as 产品状态
     , lst.isnew as 新老品状态
     , lst.ele_name as 元素
     , wp.ProductName
     , date(wp.DevelopLastAuditTime) 终审时间
     , lst.wttime as 数据统计时间
     -- ,od.code 上半年链接单量top1店铺简码, od.SellUserName 首选业务员
from lst
left join od_list_in30d oli on lst.asin = oli.asin and lst.site = oli.site
left join erp_product_products wp on lst.spu = wp.spu and wp.ismatrix = 1
-- left join wt_listing wl on lst.asin =wl.asin and lst.site =wl.MarketType
-- left join od on od.asin = lst.asin and od.site =lst.site and od.spu =lst.spu
)

, od as (
select asin,wo.SellerSku,wo.shopcode 
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 1 day ) and PayTime< '${NextStartDay}' then SaleCount end ) T_1销量
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 2 day ) and PayTime< date_add('${NextStartDay}',interval - 1 day ) then SaleCount end ) T_2销量
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 3 day ) and PayTime< date_add('${NextStartDay}',interval - 2 day ) then SaleCount end ) T_3销量
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 1 week ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) 近1周销量
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 2 week ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) 近2周销量
    ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 30 day ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) 近30天销量
    ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 90 day ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) 近90天销量
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= date_add('${NextStartDay}',interval - 90 day ) and PayTime < '${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'
  -- and  NodePathName regexp '成都'
group by asin,wo.SellerSku,wo.shopcode 
)

, ad as (
select od.asin,od.SellerSku,od.shopcode
    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then Exposure end ),0) `T_2曝光`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then Exposure end ),0) `T_3曝光`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then Exposure end ),0) `T_4曝光`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then Exposure end ),0) 近1周曝光
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then Exposure end ),0) 近2周曝光

    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then clicks end ),0) `T_2点击`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then clicks end ),0) `T_3点击`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then clicks end ),0) `T_4点击`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then clicks end ),0) 近1周点击
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then clicks end ),0) 近2周点击

    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then spend end ),0) `T_2广告花费`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then spend end ),0) `T_3广告花费`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then spend end ),0) `T_4广告花费`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then spend end ),0) 近1周广告花费
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then spend end ),0) 近2周广告花费

from import_data. AdServing_Amazon asa
join mysql_store ms on asa.shopcode=ms.Code and ms.department regexp '快'
join od on asa.ShopCode = od.ShopCode and asa.SellerSKU = od.SellerSKU and asa.Asin =od.Asin
and CreatedTime >= date_add('${NextStartDay}',interval - 90 day ) and CreatedTime < '${NextStartDay}'
group by od.asin,od.SellerSku,od.shopcode
)

-- select * from ad;
, res as (
select
    '${NextStartDay}' as  计算标签日期
    ,list_level as 当前链接标签
    ,concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  历史链接标签
    ,l.asin
    ,l.site
    ,l.shopcode
    ,l.sellersku 渠道SKU
    ,l.PublicationDate 首次刊登时间
    ,l.AccountCode
    ,l.NodePathName
    ,l.SellUserName
    ,od.T_1销量
    ,od.T_2销量
    ,od.T_3销量
    ,od.近1周销量
    ,od.近2周销量
    ,od.近30天销量
    ,od.近90天销量
    ,ad.T_2曝光 ,ad.T_3曝光 ,ad.T_4曝光 ,ad.近1周曝光 ,ad.近2周曝光
    ,ad.T_2点击 ,ad.T_3点击 ,ad.T_4点击 ,ad.近1周点击 ,ad.近2周点击
    ,ad.T_2广告花费 ,ad.T_3广告花费 ,ad.T_4广告花费 ,ad.近1周广告花费 ,ad.近2周广告花费
from listings l
left join od on  l.ShopCode = od.ShopCode and l.SellerSKU = od.SellerSKU and l.Asin =od.Asin
left join ad on  l.ShopCode = ad.ShopCode and l.SellerSKU = ad.SellerSKU and l.Asin =ad.Asin
left join lst_1 on l.site = lst_1.site  and l.Asin =lst_1.Asin
left join lst_2 on l.site = lst_2.site  and l.Asin =lst_2.Asin
left join lst_3 on l.site = lst_3.site  and l.Asin =lst_3.Asin
)

 select * from res
-- select * from od_list_in30d
-- where SellerSku='U6PWA230422WQ0YSCA-01' and shopcode='YS-CA'
-- select * from lst where asin='B0C38GKNKJ' and site='CA'