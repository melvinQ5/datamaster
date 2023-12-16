/*
一、指标拆解逻辑
利润额=销量*商品件单价*（订单利润率-广告花费占比-退款率）
1 销量部分 注意：按照广告流量的 单链接广告曝光量、点击率、转化率 去计算自然流量部分。
销量 = 终审SPU数 *（销量/终审SPU数）
销量 = 终审SPU数 *（广告销量+自然销量）/ 终审SPU数
销量 = 终审SPU数 *（广告曝光量+自然曝光量）* 总点击率* 总转化率 / 终审SPU数
广告曝光量 = 终审SPU数广告曝光率 * 单曝光SPU广告曝光量
广告曝光量 = 终审SPU刊登率 * 单刊登SPU刊登条数 * 刊登链接当周广告曝光率 * 单曝光链接当周广告曝光量
自然曝光量 = 终审SPU刊登率 * 单SPU刊登条数 * 100% * 单链接广告曝光量

2 订单利润率部分
订单利润率 - 广告花费占比 -退款率 = 定价利润率+运费收入占比-促销费率-广告CPC*广告销量占比%/（广告转化率*商品件单价）-退款率
定价利润率 = 订单利润率 - 运费收入占比 + 促销费率
广告花费占比 = 广告CPC*广告销量占比 /（广告转化率*商品件单价）
广告花费占比 = 广告花费/广告点击量 * 广告销量/销量 * 光


二、维度说明（产品范围）
1 测试开品： 给定的 88 个SPU清单， 含义是2023年11月20日后新开品测试（最小模型）开发的所有新品
2 竞对开品：spu终审时间 > 2023年11月20日 且 spu属于非主题品

三、数据生成方案
因为存在 running total 的计算，按周传参跑批，避免开窗在无法计算部分滚动累计去重。同时增强代码可读性。
StartDay = 2023-11-27 第49周开始

 */

with
mysql_store_team as ( -- 剔除定制运营组,增加dep2区域维度
select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,* from import_data.mysql_store where Department = '快百货' and NodePathName != '定制运营组' )

,prod as (
select * from (
    select epp.spu ,min_DevelopLastAuditTime
         ,case when mt.spu is not null then '测试开品' when ele.spu is null then '竞对开品' else '其他' end as dev_method ,dd.week_num_in_year as dev_week
    from ( select spu ,min(DevelopLastAuditTime) min_DevelopLastAuditTime from erp_product_products epp
        where IsMatrix=0  and isdeleted = 0 and ProjectTeam = '快百货'  group by spu ) epp
    left join ( select memo as spu from manual_table where handlename='琴姐_快百货竞对选品SPU_231212' ) mt on mt.spu =epp.spu
    left join ( select distinct spu from dep_kbh_product_test where ele_name_group regexp '冬季|夏季|复活节|开斋节|圣帕特|圣诞节|万圣节|感恩') ele on epp.spu =ele.spu
    join dim_date dd on date(min_DevelopLastAuditTime) = dd.full_date
    where epp.min_DevelopLastAuditTime >='2023-11-27' ) t
where dev_method != '其他' )

,prod_stat as (
select  dev_method , count(spu) 累计终审SPU数 from prod
where min_DevelopLastAuditTime >='2023-11-27' -- 从49周开始统计
    and min_DevelopLastAuditTime < '${NextStartDay}' group by dev_method )

,od as ( -- 当周订单
select prod.dev_method ,dd.week_num_in_year as pay_week ,
TotalProfit,TotalGross,TotalExpend,RefundAmount,ExchangeUSD,BoxSku,SaleCount,TransactionType,PromotionalDiscounts,FeeGross
from wt_orderdetails  wo
join mysql_store_team ms on wo.shopcode = ms.code and ms.Department='快百货'
join dim_date dd on date(PayTime) = dd.full_date
join prod on wo.product_spu = prod.spu -- 用join会剔除掉 交易类型=其他店铺成本数据
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and IsDeleted=0  -- 这里不筛交易类型，是考虑只算付款时间内的退款，每次重跑所有周次，退款会陆续进来;截至1214只有作废单退款
)

,od_stat as (
select dev_method
,round(sum( TotalGross/ExchangeUSD) ,2) 销售额S3
,round(sum( TotalProfit/ExchangeUSD) ,2) 利润额M3_未扣ad
,round(sum( TotalExpend/ExchangeUSD) ,2) 成本额
,abs( round(sum( RefundAmount/ExchangeUSD) ,2) )退款金额
,sum(SaleCount) 销量
,sum(PromotionalDiscounts) 促销折扣
,sum(FeeGross) 运费收入
from od group by dev_method )

,ad as ( -- 当周广告
select left(waad.sku,7) as spu ,sku  ,dev_method ,dd.week_num_in_year as ad_week,
ShopCode, SellerSku, asin,
AdSkuSaleCount7Day, AdExposure ,AdClicks ,AdSpend
from wt_adserving_amazon_daily waad join prod on prod.SPU = left(waad.sku,7) and GenerateDate >='${StartDay}' and GenerateDate<'${NextStartDay}'
join dim_date dd on GenerateDate= dd.full_date )

,ad_stat as (
select dev_method  ,sum(AdSkuSaleCount7Day) 广告销量 ,sum(AdClicks) 广告点击量, sum(AdExposure) 广告曝光量, sum(AdSpend) 广告花费
from ad group by dev_method  )

,lst as ( -- 累计刊登
select wl.spu ,wl.sku ,asin ,ShopCode ,SellerSKU ,dd.week_num_in_year as lst_week ,dev_method
from wt_listing wl
join prod on wl.spu = prod.spu  and min_DevelopLastAuditTime >='2023-11-27'  and min_DevelopLastAuditTime < '${NextStartDay}'  -- 截至当周的产品
join dim_date dd on date(MinPublicationDate) = dd.full_date
where MinPublicationDate  >= '2023-11-27' -- 从49周开始统计
  and MinPublicationDate < '${NextStartDay}' )

,lst_stat as (
select dev_method  ,count(distinct spu) 累计刊登SPU数
,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct spu)   ,2) 累计单刊登SPU链接条数
, count(distinct concat(shopcode,sellersku) ) 累计刊登链接数
from lst group by dev_method  )

,lst_ad_stat as (
select lst.dev_method
, round( count(distinct concat(lst.shopcode,lst.sellersku) ) / count(distinct lst.spu) ,2) 当周单曝光SPU刊登条数
, count(distinct concat(lst.shopcode,lst.sellersku) ) 当周曝光链接数
, round( sum(AdExposure) /  count(distinct concat(lst.shopcode,lst.sellersku) )   ,2)  单曝光链接当周广告曝光量
from lst join ad on ad.spu=lst.spu and ad.ShopCode = lst.ShopCode and ad.SellerSku = lst.SellerSKU
group by lst.dev_method  )

,res1 as (
select t0.自然周, t0.dev_method 开品方法,
累计终审SPU数,
round(累计刊登SPU数 / 累计终审SPU数 ,2) 累计SPU刊登率,
累计单刊登SPU链接条数,
round(当周曝光链接数 / 累计刊登链接数 ,2) 刊登链接当周广告曝光率,
单曝光链接当周广告曝光量,
round(广告点击量/广告曝光量,4) as 广告点击率,
round(ifnull(广告销量,0)/广告点击量,4) as 广告转化率,
round(销售额S3/销量,2) as 件单价,
round( (利润额M3_未扣ad + 退款金额 - 运费收入 + 促销折扣   )/销售额S3,4) as 定价利润率,
round(促销折扣/销售额S3,4) as 促销费率,
round(运费收入/销售额S3,4) as 运费收入占比,
round(广告花费/广告点击量,4) as 广告CPC,

销售额S3,
ROUND(利润额M3_未扣ad - 广告花费,2) as 利润额M3,

round( (利润额M3_未扣ad - 广告花费) /销售额S3,4) as 利润率,
round( (利润额M3_未扣ad + 退款金额)/销售额S3,4) as 订单利润率,
round(广告花费/销售额S3,4) as 广告花费率,
round(退款金额/销售额S3,4) as 退款率,


销量,
round(销量/累计终审SPU数,2) as SPU平均销量,

ifnull(广告销量,0) 广告销量,
销量 - ifnull(广告销量,0) as 自然销量,
round(广告销量/累计终审SPU数,2) as SPU平均广告销量,
round( (销量 - ifnull(广告销量,0)) /累计终审SPU数,2) as SPU平均自然销量,
广告曝光量

from ( select distinct dev_method ,dd.week_num_in_year as 自然周 from prod,dim_date dd where dd.full_date = '${StartDay}' ) t0
left join od_stat t1 on t1.dev_method = t0.dev_method
left join ad_stat t2 on t0.dev_method = t2.dev_method
left join prod_stat t3 on t0.dev_method = t3.dev_method
left join lst_ad_stat t4 on t0.dev_method = t4.dev_method
left join lst_stat t5 on t0.dev_method = t5.dev_method
order by 自然周,开品方法 )

select round(累计终审SPU数*累计SPU刊登率*累计单刊登SPU链接条数*刊登链接当周广告曝光率*单曝光链接当周广告曝光量,2) , 广告曝光量 ,*
from res1