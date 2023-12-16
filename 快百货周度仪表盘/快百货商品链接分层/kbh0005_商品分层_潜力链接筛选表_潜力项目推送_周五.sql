/*
《潜力链接筛选表》的产品范围如下
文件1《潜力链接筛选表_爆旺款在线链接》，需求方商品运营端：当周一计算的爆、旺品对应的在线链接
文件2《潜力链接筛选表_潜力项目推送》，需求方销售端：《潜力项目汇总数据库》潜力款清单表，其中含有旺款无SA链接的，增加一列“推送标准”，以用于区分和文件1重复


当周一计算的爆旺款、潜力款对应的在线链接(其中依据现有潜力款表生效日期进行标注)
导出表1 统计近14天表现： start_stat_days=14 end_stat_days=0
导出表2 统计近7天表现： start_stat_days=7 end_stat_days=0
每周四提供的潜力品清单标签，其生效日期是从下周一开始计算，因此本周五还不能对产品分层打标

 */
-- team 成都 泉州
with topsku as (
select pp.spu ,pp.sku ,pp.productname ,pp.boxsku ,date(pp.DevelopLastAuditTime) DevelopLastAuditTime ,mt.prod_level as push_type ,PushRule ,PushSite ,PushDate
from erp_product_products pp
join ( select spu ,prod_level -- 只推在开始推送和停止推送日期之间 且分层=潜力款的品
            ,group_concat(PushRule) PushRule ,group_concat(PushSite) PushSite ,max(PushDate)  PushDate
       from dep_kbh_product_level_potentail dkplp
    where  '${NextStartDay}' >= dkplp.PushDate
      and  '${NextStartDay}' <= dkplp.StopPushDate
      and prod_level = '潜力款' and isStopPush ='否'
    group by spu ,prod_level
    ) mt on pp.spu= mt.spu -- 此处不能直接标记到数据表,因为爆旺款为当周一计算，而潜力款清单是预备下周一标记。故为了给销售提供链接做了case when
where IsMatrix=0 and IsDeleted=0 and ProjectTeam = '快百货'
group by pp.spu ,pp.sku ,pp.productname ,DevelopLastAuditTime ,pp.boxsku ,mt.prod_level ,PushRule ,PushSite ,PushDate
)
-- select * from topsku where spu =5260504

,od as (
select wo.sellersku,wo.shopcode
     ,round(sum((totalgross)/ExchangeUSD),2) sales_fully
     ,round(sum((totalgross-feegross)/ExchangeUSD),2) sales
     ,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit
     ,count(distinct platordernumber) orders
     ,count(distinct date(PayTime)) order_days
     ,round(sum(feegross/ExchangeUSD),2) freightfee
from wt_orderdetails wo
join mysql_store s on s.code=wo.shopcode and s.department='快百货'
-- and NodePathName regexp '${team}'
join topsku pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -'${end_stat_days}'-1 day))
group by wo.sellersku,wo.shopcode
)

,list as ( -- 爆旺款对应所有的在线链接
select wl.id 
     , NodePathName,sellusername, wl.shopcode,markettype,wl.sellersku,price,wl.asin,wl.spu ,wl.sku,od.boxsku,od.productname ,s.companycode
     ,concat(dklld.ListLevel,'-',dklld.OldListLevel)  近4周链接分层
     ,wl.MinPublicationDate as 首次刊登时间
     ,'在线' 链接是否在线
from wt_listing wl
join topsku od on od.sku=wl.sku
join mysql_store s on s.code=wl.shopcode and s.department='快百货'
    -- and NodePathName regexp '${team}'
    and listingstatus=1 and shopstatus='正常' and IsDeleted = 0
join ( select shopcode ,SellerSKU ,asin  from erp_amazon_amazon_listing group by shopcode ,SellerSKU ,asin ) eaal
    on wl.shopcode = eaal.shopcode and  wl.SellerSKU = eaal.SellerSKU  and  wl.asin = eaal.asin   -- 如果flink同步问题会导致
left join ( select distinct asin ,site ,ListLevel ,OldListLevel from dep_kbh_listing_level_details ) dklld on wl.asin = dklld.asin and wl.MarketType = dklld.site
where wl.IsDeleted = 0
)

,online_stat as (
select spu
     ,count(distinct CompanyCode) as `SPU在线账号数`
     ,count(distinct case when NodePathName regexp '成都' then CompanyCode end ) as `SPU在线账号数_成都`
     ,count(distinct case when NodePathName regexp '泉州' then CompanyCode end ) as `SPU在线账号数_泉州`
     ,count(distinct concat(SellerSKU,ShopCode)) as `SPU在线条数`
     ,count(distinct case when NodePathName regexp '成都' then concat(SellerSKU,ShopCode) end ) as `SPU在线条数_成都`
     ,count(distinct case when NodePathName regexp '泉州' then concat(SellerSKU,ShopCode) end ) as `SPU在线条数_泉州`
from list group by spu
)

-- select * from list


,addetail as ( -- 爆旺款对应所有的在线链接的广告数据
select al.shopcode,al.sellersku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales
from AdServing_Amazon ads
left join erp_amazon_amazon_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
join mysql_store s on s.code=ads.shopcode and s.department='快百货'
join topsku od on od.sku=al.sku
-- and NodePathName regexp '${team}'
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL -'${end_stat_days}'-1 day))
group by al.shopcode,al.sellersku
)

,adstate as( -- 是否开过广告
select  b.code shopcode,sku sellersku
from import_data.erp_amazon_amazon_ad_products tb
join erp_user_user_platform_account_sites b on b.id=tb.shopid
group by b.code, sku
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,ele as ( -- 元素映射表，最小粒度是 SKU+NAME
select spu ,group_concat(Name) ele_name
from (
    select eppaea.spu ,eppea.Name
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name regexp '万圣节|圣诞节'
    group by eppaea.spu ,eppea.Name
    ) t
group by spu
)

,res1 as (
select
     date('${NextStartDay}')`统计日期`
     ,PushDate `潜力款推送日期`
     ,push_type
     ,list.*
     ,a.sales_fully as 销售额
     ,a.orders as 订单量
     ,a.order_days  as 出单天数
     ,a.sales as 扣运费销售额
     ,a.profit as 扣运费利润额
     ,round(profit/sales,4)`挂单利润率_扣运费`
     ,a.freightfee 运费收入
     ,round((profit-spend),2)`扣广告扣运费利润额`
     ,round((profit-spend) /sales,4) `扣广告扣运费利润率`
     ,exposure as 曝光量
     ,clicks as 点击量
     ,spend as 广告花费
     ,adorders as 广告产品销量
     ,adsales as 广告销售额
     ,round(clicks/exposure,4) ctr
     ,round(adorders/clicks,4) cvr
     ,round(spend/clicks,4) cpc
     ,round(SPEND/adsales,4) acost
     ,round(adsales/spend,2) ROI
--     ,round(adsales*profit/sales-spend,2) adprofit
     ,case when f.sellersku is not null then '开过广告'
        else '暂未匹配到广告数据'
    end as 广告状态
    ,PushRule as 推送标准
    ,PushSite as 主推站点
    ,SPU在线条数
    ,SPU在线账号数
    ,g.seller_list as 产品销售负责人

    ,SPU在线账号数_成都
    ,SPU在线账号数_泉州
    ,SPU在线条数_成都
    ,SPU在线条数_泉州
    ,ele_name as 元素
    ,DevelopLastAuditTime as 终审日期
from list
left join od a on a.sellersku=list.sellersku and a.shopcode=list.shopcode
left join addetail ad on ad.shopcode=list.shopcode and ad.sellersku=list.sellersku
left join adstate f on f.shopcode = list.shopcode and f.sellersku=list.sellersku
LEFT join topsku d on d.sku=list.sku
LEFT join online_stat e on e.spu=list.spu
LEFT join prod_seller g on g.spu=list.spu
LEFT join ele h on h.spu=list.spu
)

, topsite as (
select spu ,group_concat(MarketType) 销售额top站点
from ( select * ,dense_rank() over (partition by spu order by spu_site_sales desc) spu_site_sales_sort
    from ( SELECT spu,MarketType,sum(销售额) as spu_site_sales FROM res1 where 销售额>0 group by spu,MarketType ) t1
    ) t2
where spu_site_sales_sort <= 4 group by spu
)

, topseller as (
select spu ,group_concat(SellUserName) 销售额top人员
from (select * ,dense_rank() over (partition by spu order by spu_seller_sales desc) spu_seller_sales_sort
    from ( SELECT spu,SellUserName,sum(销售额) as spu_seller_sales FROM res1 where 销售额>0 group by spu,SellUserName ) t1
    ) t2
where spu_seller_sales_sort <= 4 group by spu
)

, res2 as ( -- 销售额及曝光量排序，如果数值=0则用站点排序，站点顺序uk de ca fr us it es au mx
select
    t2.销售额top站点
    ,t3.销售额top人员
    ,dense_rank() over (partition by res1.spu order by spu_sales desc) 销售额_站点排序
    ,dense_rank() over (partition by res1.spu order by spu_exposure desc) 曝光量_站点排序
    ,res1.*

from res1
left join  ( SELECT Id
        ,case when 销售额>0 then 销售额
        when 销售额 is null and MarketType ='UK' then -1
        when 销售额 is null and MarketType ='DE' then -2
        when 销售额 is null and MarketType ='CA' then -3
        when 销售额 is null and MarketType ='FR' then -4
        when 销售额 is null and MarketType ='US' then -5
        when 销售额 is null and MarketType ='IT' then -6
        when 销售额 is null and MarketType ='ES' then -7
        when 销售额 is null and MarketType ='AU' then -8
        when 销售额 is null and MarketType ='MX' then -9
        end as spu_sales

        ,case when 曝光量>0 then 曝光量
        when 曝光量 is null and MarketType ='UK' then -1
        when 曝光量 is null and MarketType ='DE' then -2
        when 曝光量 is null and MarketType ='CA' then -3
        when 曝光量 is null and MarketType ='FR' then -4
        when 曝光量 is null and MarketType ='US' then -5
        when 曝光量 is null and MarketType ='IT' then -6
        when 曝光量 is null and MarketType ='ES' then -7
        when 曝光量 is null and MarketType ='AU' then -8
        when 曝光量 is null and MarketType ='MX' then -9
        end as spu_exposure

FROM res1 ) t1 on res1.id = t1.id
left join topsite t2 on res1.spu = t2.spu
left join topseller t3 on res1.spu = t3.spu
)

select * from res2 order by 潜力款推送日期 desc ,spu ,销售额_站点排序




-- SELECT count(*) FROM res

-- SELECT * FROM res where id = 'a0d9def9-2505-4731-9d99-34bde6056398'
-- SELECT id  FROM res group by id having count(*) >1
-- WHERE  list_level ='S'
-- and markettype ='CA' AND ASIN = 'B0C38PK7G9'

-- select sum(IFNULL(含运费销售额,0)) from res where markettype ='CA' AND ASIN = 'B0C38PK7G9';
