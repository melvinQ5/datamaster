


-- 竞价查询方式
 select ms.code as shopcode ,pr.Asin
    ,pr.sku as sellersku
    ,ca.CampaignName 活动名称
    ,TargetingType 投放类型
    ,ag.AdGroupName 广告组名称
      ,ag.DefaultBid 广告组默认竞价_原币种
      ,d.RealTimeExchangeRate 实时汇率
      ,Currency
 ,round(ag.DefaultBid*d.RealTimeExchangeRate,4) DefaultBid_usd
 from erp_amazon_amazon_ad_products pr
  join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='快百货' and pr.AdState='enabled'
  left join ( select distinct case when code = 'GB' then 'UK' else code end as code  ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
  left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
  join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId and ca.CampaignState ='enabled' and ca.TargetingType ='auto'
  join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId and ag.AdGroupState='enabled'
where  ms.code ='A08-US'  and pr.sku ='YMXA08US2023101102'


-- 验证调度结果
select distinct  GenerateDate  from wt_adserving_amazon_daily where MaxBidUSD>0

