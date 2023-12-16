
with lst as (
select  dkll .*
from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023
--  and dkll.FirstDay = '2023-07-10'
  and dkll.FirstDay = '2023-07-17'
	-- and dkll.Department = '快百货成都'
)

-- select * from lst where asin ='B0BMF1WF74'

, od_list_in30d as ( -- site,asin,spu,boxsku 聚合
select wo.site,asin,boxsku,shopcode,SellerSku,SellUserName,NodePathName,dep2
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('2023-07-24', INTERVAL -30 DAY) and PayTime<'2023-07-24' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'
group by wo.site,asin,boxsku,shopcode,SellerSku,SellUserName,NodePathName,dep2
)

/*
, od as ( -- site,asin,spu,boxsku 聚合
select * from (
select ROW_NUMBER () over ( partition by site,asin, spu order by orders desc ) as sort ,ta.*
from (
	select wo.site,asin, Product_SPU as spu ,ms.Code ,ms.SellUserName  ,count(distinct PlatOrderNumber) orders -- 订单数
	from import_data.wt_orderdetails wo
	join mysql_store ms on wo.shopcode=ms.Code
	where PayTime >='2023-01-01' and PayTime< '2023-07-01' and wo.IsDeleted=0
		and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快' and  NodePathName regexp '成都'
	group by wo.site,asin, spu ,ms.Code ,ms.SellUserName
	) ta
) tb
where tb.sort = 1
)
*/


, res as (
select
    date(date_add (date_add(lst.FirstDay,interval 1 week) ,interval -30 day )) as 近30天开始日期
    ,date(date_add (date_add(lst.FirstDay,interval 1 week) ,interval -1 day )) as 近30天结束日期
     -- , week as 周序
     , Department as 团队
     , case when list_level = '散单' then '其他' else list_level end as list_level
     , lst.site
     , oli.shopcode
     , lst.asin
     , oli.sellersku  as 渠道SKU
     , oli.SellUserName
     , oli.NodePathName
    --  , case when wl.asin is not null then '在线' else '未在线' end as 链接状态
     , sales_no_freight as 近30天不含运费销售额
     , sales_in30d 近30天销售额
     , profit_in30d 近30天利润额
     , list_orders 近30天订单量
     , prod_level
     , oli.BoxSku
     , lst.spu
     , wp.sku
     , lst.ProductStatus as 产品状态
     , lst.isnew as 新老品状态
     , lst.ele_name as 元素
     , wp.ProductName
     , date(wp.DevelopLastAuditTime) 终审时间
     -- ,od.code 上半年链接单量top1店铺简码, od.SellUserName 首选业务员
from lst
join od_list_in30d oli on lst.asin = oli.asin and lst.site = oli.site
left join wt_products wp on oli.BoxSku = wp.BoxSku
    /*
left join
    (select asin ,wl.shopcode ,wl.sellersku from wt_listing wl join mysql_store ms
        on  wl.ShopCode =ms.Code and ms.ShopStatus='正常' and wl.ListingStatus= 1 group by asin ,wl.shopcode ,wl.sellersku ) wl
      on oli.asin = wl.asin and oli.shopcode =wl.shopcode and oli.sellersku =wl.sellersku

     */
)

-- select count(1) from res where list_level regexp 'S|A'

select count(1) from res where list_level regexp 'S|A'
-- where 渠道SKU = 'IQBJQG-UK-230526-176'
--  select 链接状态 ,count(1) from res group by 链接状态

/*
select distinct wo.sellersku ,wo.BoxSku ,wo.shopcode
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('2023-07-24', INTERVAL -30 DAY) and PayTime<'2023-07-24' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'
    and asin = 'B0C8CJXVR7'