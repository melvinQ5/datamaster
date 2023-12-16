
insert into dep_kbh_listing_level_details ( MarkDate ,asin ,ShopCode ,sellersku ,ListingId
    ,`ListLevel`
    ,`OldListLevel`
    ,`MinPublicationDate`
    ,`site`
    ,`AccountCode`
    ,`NodePathName`
    ,`SellUserName`

    ,`salescountInt1`
    ,`SalesCountInt2`
    ,`SalesCountInt3`
    ,`SalesCountIn1w`
    ,`SalesCountIn2w`
    ,`SalesCountIn30d`
    ,`SalesCountIn90d`

    ,`ExposureInt2`
    ,`ExposureInt3`
    ,`ExposureInt4`
    ,`ExposureIn1w`
    ,`ExposureIn2w`

    ,`ClicksInt2`
    ,`ClicksInt3`
    ,`ClicksInt4`
    ,`ClicksIn1w`
    ,`ClicksIn2w`

    ,`AdSpendInt2`
    ,`AdSpendInt3`
    ,`AdSpendInt4`
    ,`AdSpendIn1w`
    ,`AdSpendIn2w`
    ,`BoxSku`
    ,`SPU`
    ,`SKU`
    ,`wttime`
 )

with
lst as ( -- 近30天出单的所有链接
select  dkll .*
from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay =  date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2 week) -- 本周一再减7天是清单存储的firstday
	-- and dkll.Department = '快百货成都'
)
-- select * from lst where asin ='B07V8FFXT7' and site = 'ES'

,lst_1 as ( -- 上周
select  distinct asin ,site ,list_level as mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-2 week)
)

,lst_2 as (  -- 再上周
select  distinct asin ,site ,list_level as mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-2 week)
)

,lst_3 as ( -- 再上周
select  distinct asin ,site ,list_level as mark_3 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-2 week)
)

, od_list_in30d as ( -- 链接分层主键为asin+site，找到对应最小粒度
select distinct wo.site,asin,boxsku,Product_Sku as sku,shopcode,ms.AccountCode,SellerSku,SellUserName,NodePathName,dep2 ,date(wo.PublicationDate)  PublicationDate
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >=  date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1), INTERVAL -30 DAY) and PayTime<  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'
)



-- select * from od_list_in30d where  asin ='B0C5C83VQ9'  ;

, listings as ( -- 最小粒度
select
     lst.asin
     , oli.shopcode
     , oli.SellerSku
     , lst.FirstDay as 统计周当周一
     -- , week as 周序
     , dep2 as 团队
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
left join  od_list_in30d oli on lst.asin = oli.asin and lst.site = oli.site
left join (select distinct spu, productname ,DevelopLastAuditTime from wt_products where ProjectTeam='快百货' and IsDeleted=0) wp on lst.spu = wp.spu
-- left join wt_listing wl on lst.asin =wl.asin and lst.site =wl.MarketType
-- left join od on od.asin = lst.asin and od.site =lst.site and od.spu =lst.spu
where oli.SellerSku is not null
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

,add_listing_id as (
select wl.id ,t.asin  ,t.shopcode ,t.SellerSku
from  listings t
left join (select asin, shopcode, sellersku ,id from  erp_amazon_amazon_listing group by asin, shopcode, sellersku ,id ) wl
on t.asin = wl.asin and t.ShopCode=wl.ShopCode and t.SellerSKU=wl.SellerSKU
order by wl.asin ,wl.shopcode ,wl.sellersku
)

-- select * from ad;
, res as (
select
    date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1 week) as  计算标签日期
    ,l.asin
    ,l.shopcode
    ,l.sellersku 渠道SKU
    ,ali.id
    ,list_level as 当前链接标签
    ,concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  历史链接标签
    ,date(l.PublicationDate) 首次刊登时间
    ,l.site
    ,l.AccountCode
    ,l.NodePathName
    ,l.SellUserName
    ,ifnull(od.T_1销量,0)
    ,ifnull(od.T_2销量,0)
    ,ifnull(od.T_3销量,0)
    ,ifnull(od.近1周销量,0)
    ,ifnull(od.近2周销量,0)
    ,ifnull(od.近30天销量,0)
    ,ifnull(od.近90天销量,0)
    ,ifnull(ad.T_2曝光,0) ,ifnull(ad.T_3曝光,0) ,ifnull(ad.T_4曝光,0) ,ifnull(ad.近1周曝光,0) ,ifnull(ad.近2周曝光,0)
    ,ifnull(ad.T_2点击,0) ,ifnull(ad.T_3点击,0) ,ifnull(ad.T_4点击,0) ,ifnull(ad.近1周点击,0) ,ifnull(ad.近2周点击,0)
    ,ifnull(ad.T_2广告花费,0) ,ifnull(ad.T_3广告花费,0) ,ifnull(ad.T_4广告花费,0) ,ifnull(ad.近1周广告花费,0) ,ifnull(ad.近2周广告花费,0)
    ,l.BoxSku
    ,l.spu
    ,l.sku
    ,now()
from listings l
left join od on  l.ShopCode = od.ShopCode and l.SellerSKU = od.SellerSKU and l.Asin =od.Asin
left join ad on  l.ShopCode = ad.ShopCode and l.SellerSKU = ad.SellerSKU and l.Asin =ad.Asin
left join lst_1 on l.site = lst_1.site  and l.Asin =lst_1.Asin
left join lst_2 on l.site = lst_2.site  and l.Asin =lst_2.Asin
left join lst_3 on l.site = lst_3.site  and l.Asin =lst_3.Asin
left join add_listing_id ali on l.ShopCode = ali.ShopCode and l.SellerSKU = ali.SellerSKU and l.Asin =ali.Asin
)

select * from res;

