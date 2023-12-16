/*
 【广告日表】
宋哥，需要存储两个指标，到 wt_adserving_amazon_daily 。历史数据不管，从今天起开始积累快照值。（今天需要有快照哈）
另需注意：日表表结构修改后，备份表策略是否有生效

指标1  字段名： MaxEnabledBidUSD    注释：日最大bid（启用状态）
取值逻辑：
筛选：广告组状态=‘启用’且 广告活动状态=‘启用’且 广告产品状态=‘启用’ 且 投放类型 = ‘自动’ 记录
按照shopcode + sellersku + asin 作为唯一值，去统计最大的默认竞价


指标2  字段名： MaxBidUSD   注释 ：日最大bid（所有状态）
取值逻辑：
筛选：投放类型 = ‘自动  且 默认竞价 > 0.03的记录，
按照shopcode + sellersku + asin 作为唯一值，去统计最大的默认竞价
 */

-- 指标1 SQL
select  current_date() GenerateDate,shopcode ,sellersku ,asin ,ifnull(max(DefaultBid_usd),0) MaxEnabledBidUSD
from (
select ms.code as shopcode ,pr.Asin
        ,pr.sku as sellersku
        ,round(ag.DefaultBid/d.RealTimeExchangeRate,4) DefaultBid_usd
from erp_amazon_amazon_ad_products pr
join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='快百货' and pr.AdState='enabled'
left join ( select distinct code ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId and ca.CampaignState ='enabled' and ca.TargetingType ='auto'
join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId and ag.AdGroupState='enabled'
) t
group by shopcode ,sellersku ,asin



-- 指标2 SQL
select  current_date() GenerateDate,shopcode ,sellersku ,asin ,ifnull(max(DefaultBid_usd),0) MaxBidUSD
from (
select ms.code as shopcode ,pr.Asin
        ,pr.sku as sellersku
        ,round(ag.DefaultBid/d.RealTimeExchangeRate,4) DefaultBid_usd

from erp_amazon_amazon_ad_products pr
join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='快百货'
left join ( select distinct code ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId  and ca.TargetingType ='auto'
join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId  and DefaultBid >= 0.03
) t
group by shopcode ,sellersku ,asin


