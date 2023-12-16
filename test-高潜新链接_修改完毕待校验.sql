/*对象=先找出终审时间在3月及以后的新品-SPU维度*/
with testspu as
(
select [
'5358173'
]arr
)

,testspulist as(
select *
from (select unnest as testspu,'最小模型' mark
	from testspu ,unnest(arr)
	) tmp
)

-- select * from testspulist
--

,epp as (
select pp.sku,pp.boxsku,pp.spu,date(spu.AuditTime)AuditTime,DATE_FORMAT(spu.AuditTime,'%Y-%m-01') developmon
,year(spu.AuditTime) developyear
,split_part(pc.CategoryPathByChineseName,'>',1) category1 , CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2) ) category2 ,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3) ) category3 ,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4) ) category4,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4),'>',split_part(pc.CategoryPathByChineseName,'>',5) ) category5,IFNULL(fes.newele_name,'其他')ele_name,case pp.productstatus
when 0 then '正常'
when 2 then '停产'
when 3 then '停售'
when 4 then '暂时缺货'
when 5 then '清仓'
end productstatus,
(case when test.mark='最小模型' then test.mark else '竞对开品' end ) as producttype
from erp_product_products pp
join (select spu,min(DevelopLastAuditTime)AuditTime from erp_product_products where ProjectTeam='快百货'
and isdeleted=0  group by spu  ) spu on spu.spu=pp.spu
 left join ( -- 元素映射表，最小粒度是 SKU+NAME
select sku,ele_name,(case when  ele_name like '%冬季%' then '冬季'  when  ele_name like '%夏季%' then '夏季' when  ele_name like '%复活%' then '复活节'when  ele_name like '%开斋%' then '开斋节' when  ele_name like '%圣帕特%' then '圣帕特'  when  ele_name like '%圣诞%' then '圣诞'  when  ele_name like '%万圣%' then '万圣' when  ele_name like '%感恩%' then '感恩' else '其他'  end) newele_name  from
(
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products epp on eppaea.sku = epp.sku
where
epp.ProjectTeam ='快百货' and
epp.IsMatrix=0 and epp.IsDeleted=0
group by eppaea.sku
) a
) fes on fes.sku=pp.sku
join testspulist test on test.testspu=pp.spu
left join (
select pp.sku,concat(pc.CategoryPathByChineseName,'>>>>>') CategoryPathByChineseName from erp_product_products pp
join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId) pc on pc.sku=pp.sku
where pp.ismatrix=0
and pp.ProjectTeam='快百货'
and pp.isdeleted=0
and pp.DevelopLastAuditTime<'2023-12-11' and pp.DevelopLastAuditTime>='2023-11-20'
and (pp.ProductStopTime >='2023-11-27' or pp.ProductStopTime is null)
)



-- select * from epp

,asin as (
select asin,site,sku,PublicationDate,链接可售月份 from (
select asin,site,sku,PublicationDate,链接可售月份,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort from(
select  ASIN, site,sku,PublicationDate,TIMESTAMPDIFF(month,(case when PublicationDate>='2023-11-27'then PublicationDate else  '2023-11-27'end),'2023-12-11')+1 链接可售月份 from (
select ASIN,MarketType site,sku,PublicationDate,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort  from erp_amazon_amazon_listing al
join mysql_store s on s.code =al.shopcode and s.Department='快百货'
where al.sku<>''
)a where sort=1
union
select  ASIN, site,sku,PublicationDate,TIMESTAMPDIFF(month,(case when PublicationDate>='2023-11-27'then PublicationDate else'2023-11-27' end),LastModificationTime)+1 链接可售月份 from (
select ASIN,MarketType site,sku,PublicationDate,LastModificationTime,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort from erp_amazon_amazon_listing_delete al
join mysql_store s on s.code =al.shopcode and s.Department='快百货'
and LastModificationTime>='2023-11-27' and LastModificationTime<'2023-12-11'
where al.sku <>''
)b where sort=1
)c
)d where sort=1
)


,list as
(
select epp.*,asin,site,PublicationDate,链接可售月份,case when ele_name='其他' then '非主题' else '主题' end 主题 from epp
left join asin on asin.sku=epp.sku
-- where ele_name='其他'
)
-- select * from list

,kandeng as(
select spu,count(distinct concat(asin,site))lists,round(avg(ifnull(链接可售月份,0)),4) 链接可售月份 from list
group by spu
)


,ta as
(
select [
'40',
'41',
'42',
'43',
'44',
'45',
'46',
'47',
'48',
'49',
'50',
'51',
'52',
'53',
'54'
]arr
)

,tb as(
select *
from (select unnest as wee
	from ta ,unnest(arr)
	) tmp
)

,total as(/*主表全链接用于匹配*/
select * from tb
cross join list
)


,ad as(
select a.sku1 sku, spu,year,week,asin,site,sum(AdExposure)AdExposure,sum(adclicks)adclicks,round(sum(adspend),2)adspend,round(sum(adsales),2)adsales ,round(sum(adsaleunits),2)adorders from (
select ad.*,list.sku sku1 ,list.spu,right(ad.shopcode,2)site from wt_adserving_amazon_weekly ad
join list  on list.asin=ad.asin and list.site=right(ad.shopcode,2)
where Year='2023' and week=weekofyear('2023-12-11')
)a
group by a.sku1,year,week,asin,site,spu
)
,baoguang as(
select spu,count( distinct case when AdExposure>0 then concat(asin,site) end) 曝光链接数 from(
select spu,asin,site,sum(AdExposure)AdExposure from ad
group by spu,asin,site
)adspu
group by spu
)


,ods as(
select (WEEKOFYEAR(paytime)+1)wee,od.asin,od.site
,round(sum(TotalGross/ExchangeUSD),2)sales
,round(sum(TotalProfit/ExchangeUSD),2)profit
,round(sum(refundamount/ExchangeUSD),2)refund
,round(sum(promotionaldiscounts/ExchangeUSD),2) promotionaldiscounts
,round(sum(feegross/ExchangeUSD),2) 运费收入
,round(sum(PromotionalDiscounts/ExchangeUSD),2) 营销折扣
,round(sum(OtherExpend/ExchangeUSD),2) 平台其他支出
,round(sum(TradeCommissions/ExchangeUSD),2) 平台佣金
,round(sum(AdvertisingCosts/ExchangeUSD),2) 广告非拆分
,round(sum(PurchaseCosts/ExchangeUSD),2) 采购成本
,round(sum(localfreight/ExchangeUSD),2) 物流成本
,count(distinct PlatOrderNumber) orders
,sum(salecount) 销量
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='快百货'
and  product_spu not regexp '5358176|5358173'
and paytime>='2023-11-27' and paytime<'2023-12-11'
and orderstatus<>'作废'
group by wee,od.asin,od.site
order by wee asc
)



-- select weekofyear('2023-08-03')+1

,ods1 as(
select list.spu,count( distinct DATE_FORMAT(od.paytime,'%Y-%m-01'))salesmon,count (distinct weekofyear(od.paytime))salewee
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='快百货'
and paytime>='2023-11-27' and paytime<'2023-12-11'
group by list.spu
)

,ods2 as(select spu,sum(listsalemon)listsalemon,count(distinct(concat(asin,site))) salelist,(sum(listsalemon)/count(distinct(concat(asin,site))) ) 平均链接销售月份 from(
select list.asin,list.site,list.spu,count( distinct DATE_FORMAT(od.paytime,'%Y-%m-01'))listsalemon,count (distinct weekofyear(od.paytime))listsalewee
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='快百货'
and paytime>='2023-11-27' and paytime<'2023-12-11'
group by list.asin,list.site,list.spu
)a
group by spu
)
-- select * from ods2

,huizong as(
select
total.producttype,
total.wee,
total.sku,
total.boxsku,
total.spu,
total.AuditTime,
developmon,
developyear,
category1,
category2,
category3,
category4,
category5,
ele_name,
主题,
productstatus,
total.asin,
total.site,
total.PublicationDate,
sales,
profit,
refund,
promotionaldiscounts,
运费收入,
营销折扣,
平台其他支出,
平台佣金,
广告非拆分,
采购成本,
物流成本,
orders,
销量,
AdExposure,
adclicks,
adspend,
adsales,
adorders
from total
left join ad on ad.asin=total.asin and ad.site=total.site and ad.week=total.wee
left join ods on ods.asin=total.asin and ods.site=total.site and ods.wee=total.wee
)

-- select * from  wt_orderdetails od
-- where TransactionType='付款' Limit 10
--
-- select * from  huizong
--
,spulist as(
select spu,主题,producttype prodtype,sum(orders) orders
,sum(销量) 销量
,round(sum(sales),2)sales
,round(sum(profit),2)profit
,round(sum(ifnull(profit,0))-sum(ifnull(adspend,0)),2)profitnew
,round(sum(refund),2)refund
,round(sum(promotionaldiscounts),2) promotional
,round(sum(运费收入),2) 运费收入
,round(sum(营销折扣),2) 营销折扣
,round(sum(平台其他支出),2) 平台其他支出
,round(sum(平台佣金),2) 平台佣金
,round(sum(采购成本),2) 采购成本
,round(sum(物流成本),2) 物流成本
,sum(AdExposure)AdExposure
,sum(adclicks)adclicks
,round(sum(adspend),2)adspend
,round(sum(adsales),2)adsales
,round(sum(adorders),2)adorders
,round((sum(ifnull(profit,0))-sum(ifnull(adspend,0)))/sum(sales),4) 利润率
,round(sum(adspend)/sum(sales),4) 广告花费率
,round(sum(refund)/sum(sales-refund),4) 退款率
,round(sum(运费收入)/sum(sales),4) 运费收入率
,round(sum(营销折扣)/sum(sales),4) 营销折扣率
,round(sum(平台其他支出)/sum(sales),4) 平台其他支出率
,round(sum(平台佣金)/sum(sales),4) 平台佣金率
,round(sum(采购成本)/sum(sales),4) 采购成本率
,round(sum(物流成本)/sum(sales),4) 物流成本率
,round(sum(adsales)/sum(sales),4) 广告业绩占比
,round(sum(adclicks)/sum(AdExposure),4) CTR
,round(sum(adorders)/sum(adclicks),4) CVR
,round(sum(adspend)/sum(adclicks),4) CPC
from huizong
group by spu,主题,producttype
)

-- select * from spulist

,spuhuizong as(
select a.spu,a.developmon,ifnull(a.商品可售月份,0)商品可售月份,(case when AuditTime>='2023-01-01' then '新品' else '老品' end) prod,主题,prodtype,
orders,
销量,
sales,
profit,
profitnew,
refund,
promotional,
运费收入,
营销折扣,
平台其他支出,
平台佣金,
采购成本,
物流成本,
AdExposure,
adclicks,
adspend,
adsales,
adorders,
利润率,
广告花费率,
退款率,
运费收入率,
营销折扣率,
平台其他支出率,
平台佣金率,
采购成本率,
物流成本率,
广告业绩占比,
CTR,
CVR,
CPC,
salesmon,
salewee,
lists,
曝光链接数,
salelist 出单链接数,
平均链接销售月份,
链接可售月份
from (select spu,min(AuditTime)AuditTime, DATE_FORMAT(min(AuditTime),'%Y-%m-01') developmon,(case when min(AuditTime)<'2023-01-01' then 10 else (TIMESTAMPDIFF(month,DATE_FORMAT(min(AuditTime),'%Y-%m-01'),'2023-12-11')+1) end) 商品可售月份 from epp
-- where ele_name='其他'
group by spu )a
left join spulist on spulist.spu=a.spu
left join ods1 on a.spu=ods1.spu
left join kandeng on kandeng.spu=a.spu
left join baoguang on baoguang.spu=a.spu
left join ods2 on a.spu=ods2.spu
)

-- select * from spuhuizong
-- order by profitnew asc
--
select ifnull(prodtype,'汇总') prodtype,ifnull(主题,'汇总')主题 ,round(sum(case when orders>0 then sales end),2) sales,round(sum(case when orders>0 then profitnew end),2) profitnew,count(distinct spu) spu总数,count(case when lists>0 then spu end)刊登SPU数,sum(case when lists>0 then lists end)刊登总条数, count(case when orders>0 then spu end) 出单SPU数,round(count(case when orders>0 then spu end) /count(distinct spu),6)spu动销率,round(avg(case when orders>0 then orders end),3) 出单平均订单数
,round(avg(case when orders>0 then 销量 end),3) 出单平均销量
,sum(曝光链接数)曝光链接数
,sum(AdExposure)AdExposure
,sum(adclicks)adclicks
,round(sum(adspend),2)adspend
,round(sum(adsales),2)adsales
,round(sum(adorders),2)adorders
,round(sum(adsales)/sum(sales),4) 广告业绩占比
,round(sum(adclicks)/sum(AdExposure),4) CTR
,round(sum(adorders)/sum(adclicks),4) CVR
,round(sum(adspend)/sum(adclicks),4) CPC
,round(sum(case when orders>0 then sales end)/sum(case when orders>0 then orders end),4)平均客单价
,round(sum(case when orders>0 then sales end)/sum(case when orders>0 then 销量 end),4)平均件单价
,round(sum(case when orders>0 then profitnew end)/sum(case when orders>0 then sales end),6)平均利润率
,round(avg(商品可售月份),4)商品年均可售月
,round(sum(链接可售月份*lists)/sum(lists),4)链接年均可售月
,sum(出单链接数)出单链接数
,count(distinct case when 曝光链接数>0 then spu end) 曝光SPU数
,round( avg(case when orders>0 then salesmon end),4) 商品年均销售月
,round( sum(case when orders>0 then 平均链接销售月份*出单链接数 end),4) 链接总销售月
,round(sum(refund),2)refund
,round(sum(promotional),2)promotional
,round(sum(运费收入),2) 运费收入
,round(sum(营销折扣),2) 营销折扣
,round(sum(平台其他支出),2) 平台其他支出
,round(sum(平台佣金),2) 平台佣金
,round(sum(采购成本),2) 采购成本
,round(sum(物流成本),2) 物流成本
from spuhuizong
where prod='新品'
and  spu<>'5355698'
group by grouping sets((),(prodtype,主题),(prodtype))
order by prodtype desc,主题 asc


-- select * from wt_adserving_amazon_weekly where year='2023' order by week desc limit 10
