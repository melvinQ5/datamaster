
-- 导出表1 统计近14天表现： start_stat_days=14 end_stat_days=7
-- 导出表2 统计近30天表现： start_stat_days=30 end_stat_days=7



with topsku as (
select pp.spu ,pp.sku ,pp.productname ,pp.boxsku ,mt.prod_level as push_type
from erp_product_products pp
join dep_kbh_product_level mt on pp.spu= mt.spu
where FirstDay = date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval - 1 week ) and Department='快百货'
-- where MarkDate = '${NextStartDay}' and Department='快百货'  -- 错误写法,因为每周一会生成周报月报两份数据，其markdate都是周一
and IsMatrix=0 and pp.IsDeleted=0 and mt.isdeleted=0
)

,listtype as ( -- 0710开始有过链接标记，写上最新标签
 select distinct asin , site ,list_level as listtype ,old_list_level as OldListLevel from dep_kbh_listing_level
where isdeleted=0 and  FirstDay = ( select max(firstday) from dep_kbh_listing_level where isdeleted=0 )
)

,listype_history as (
select asin ,site ,group_concat(list_level) list_level
from dep_kbh_listing_level where isdeleted=0 and  Department regexp '${team}' and list_level regexp 'S|A'  group by  asin ,site
)

,torttype as (
select pp.sku,pp.boxsku,date(min(pt.CreationTime))`tortdate`,GROUP_CONCAT(
case torttype
when 1 then '版权侵权'
when 2 then '商标侵权'
when 3 then '专利侵权'
when 4 then '违禁品'
when 5 then '不侵权'
when 6 then '律所侵权'
end) torttype_name
FROM import_data.erp_product_product_tort_types pt
join import_data.erp_product_products pp on pp.id=pt.ProductId
where pp.sku is not null and pp.ismatrix=0 and  pp.IsDeleted=0
group by pp.sku,pp.boxsku
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products epp on eppaea.sku = epp.sku
where epp.ProjectTeam ='快百货' and epp.IsMatrix=0 and epp.IsDeleted=0
group by eppaea.sku
)

,epp as ( -- sku
select a.SKU ,a.SPU ,date(a.DevelopLastAuditTime)AuditTime,a.productname,ele_name,torttype_name,
case productstatus
when 0 then '正常'
when 2 then '停产'
when 3 then '停售'
when 4 then '暂时缺货'
when 5 then '清仓'
end productstatus
from import_data.erp_product_products a
left join torttype b on a.sku=b.sku
left join t_elem c on c.sku=a.sku
where IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='快百货'
group by a.SKU ,a.SPU ,a.DevelopLastAuditTime,a.productname,ele_name,torttype_name,productstatus
)

,t_list as ( -- 当月刊登所有链接 （包含新老品）
select wl.id,wl.SPU ,wl.SKU  ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin,price
	,AccountCode  ,ms.Site
	,ms.SellUserName  ,ms.NodePathName
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where wl.IsDeleted = 0
	and ms.Department = '快百货'
	and ms.NodePathName regexp '${team}'
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and sku<>''
)

,addetail as ( -- 14及30天广告
select al.markettype,al.shopcode,al.sellersku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales  from AdServing_Amazon ads
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL  -1 day))
group by  al.markettype,al.shopcode,al.sellersku
)

, t_od as ( -- 14及30天订单
select wo.shopcode,wo.sellersku,round(sum((totalgross-feegross)/ExchangeUSD),2) sales,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount/ExchangeUSD),2)refund,count(distinct date(PayTime))solddays
from wt_orderdetails wo
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货'
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1  day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -1 day))   and asin<>''
group by  wo.shopcode,wo.sellersku
)

,onlinead as (
select distinct tb.ListingId ,b.code shopcode,sku sellersku
from import_data.erp_amazon_amazon_ad_products tb
join erp_user_user_platform_account_sites b on b.id=tb.shopid
-- where sku = 'QK-NBFR-1014-JW-100' and code = 'NB-FR'
)

, lastt_od as ( -- 订单表  asin+sitem明细
select wo.shopcode,wo.sellersku,round(sum((totalgross-feegross)/ExchangeUSD),2) lastsales,round(sum((totalprofit-feegross)/ExchangeUSD),2) lastprofit,count(distinct platordernumber) lastorders,round(sum(feegross/ExchangeUSD),2) lastfreightfee,round(sum(-RefundAmount/ExchangeUSD),2)lastrefund,count(distinct date(PayTime))lastsolddays
from wt_orderdetails wo
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货'
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL  -'${start_stat_days}'-7-1 day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -7-1 day))   and asin<>''
group by  wo.shopcode,wo.sellersku
)

,lastaddetail as (
select al.markettype,al.shopcode,al.sellersku,sum(exposure)lastexposure,sum(clicks)lastclicks,sum(spend) lastspend,sum(AdSkuSaleCount7Day) lastadorders,sum(AdSkuSale7Day) lastadsales  from AdServing_Amazon ads
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-7-1  day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL -7-1 day))
group by  al.markettype,al.shopcode,al.sellersku
)

,prod_1 as ( -- 本周
select  distinct spu ,prod_level as mark_1 from dep_kbh_product_level
where isdeleted=0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,prod_2 as (  -- w-1周
select  distinct spu ,prod_level as mark_2 from dep_kbh_product_level
where isdeleted=0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,prod_3 as ( -- w-2周
select  distinct spu ,prod_level as mark_3 from dep_kbh_product_level
where isdeleted=0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)



,res as (
select
    concat('在线链接近','${start_stat_days}','天表现') type
     ,date('${NextStartDay}')`数据刷新日期`
     ,listtype 链接分层
     ,OldListLevel 前3周链接标签
     ,topsku.push_type 商品分层
     ,concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  前三周商品分层
     ,a.SPU ,a.SKU ,a.BoxSku
     ,f.AuditTime 终审日期
     ,f.productname 产品名称
     ,f.ele_name 元素
     ,f.torttype_name 侵权类型
     ,f.productstatus 产品状态
     ,date(MinPublicationDate) 首次刊登时间
     ,a.MarketType 站点
     ,a.SellerSKU
     ,a.ShopCode
     ,a.asin
     ,price
     ,AccountCode
     ,SellUserName 首选业务员
     ,NodePathName 销售组
     ,case when d.sellersku is not null then '开过广告'
        else '暂未匹配到广告数据'
    end as 广告状态
     ,round(sales+freightfee,2) 销售额
     ,round(profit+freightfee,2) 利润额
     ,round(profit/sales,4) 挂单利润率_不含运费
     ,orders 订单数
     ,freightfee 运费收入
     ,refund 退款金额
     ,round((profit-ifnull(spend,0)+freightfee),2) 扣广告利润额
     ,round((profit-ifnull(spend,0)+freightfee) /(sales+freightfee),4) 扣广告利润率
     ,solddays 出单天数
     ,exposure 曝光量
     ,clicks 点击量
     ,spend 广告花费
     ,adorders 广告销量
     ,adsales 广告产品销售额
     ,round(clicks/exposure,4) ctr
     ,round(adorders/clicks,4) cvr
     ,round(spend/clicks,4) cpc
     ,round(SPEND/adsales,4) acost
     ,round(adsales/spend,2) ROI
     -- ,round(adsales*profit/sales-spend,2) adprofit
        ,round(lastfreightfee+lastsales,2) 销售额_上期
     ,round(lastfreightfee+lastprofit,2) 利润额_上期
     ,lastorders 订单数_上期
     ,lastfreightfee 运费收入_上期
     ,lastexposure 曝光量_上期
     ,lastclicks 点击量_上期
     ,lastspend 广告花费_上期
     ,lastadorders 广告销量_上期
     ,lastadsales 广告产品销售额_上期
     ,lastsolddays 出单天数_上期
    ,case when listype_history.asin is not null then '是' else '' end as 是否往期曾标记过SA

from t_list a -- 在线链接
join topsku on topsku.sku=a.sku -- 筛选本期商品分层的产品
left join listtype on listtype.asin=a.asin and listtype.site=a.site
left join listype_history on listype_history.asin=a.asin and listype_history.site=a.site
left join t_od b on b.shopcode=a.shopcode and b.sellersku=a.sellersku
left join addetail c on c.shopcode=a.shopcode and c.sellersku= a.sellersku
left join onlinead d on a.shopcode =d.shopcode and a.sellersku=d.sellersku
left join epp f on f.sku=a.sku
left join lastt_od g on g.shopcode=a.shopcode and g.sellersku=a.sellersku
left join lastaddetail i on i.shopcode=a.shopcode and i.sellersku= a.sellersku
left join prod_1 on a.spu = prod_1.spu
left join prod_2 on a.spu = prod_2.spu
left join prod_3 on a.spu = prod_3.spu
where  NodePathName regexp '${team}'
order by sales desc
)

select * from res

