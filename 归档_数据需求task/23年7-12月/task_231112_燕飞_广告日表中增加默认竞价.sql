


-- ���۲�ѯ��ʽ
 select ms.code as shopcode ,pr.Asin
    ,pr.sku as sellersku
    ,ca.CampaignName �����
    ,TargetingType Ͷ������
    ,ag.AdGroupName ���������
      ,ag.DefaultBid �����Ĭ�Ͼ���_ԭ����
      ,d.RealTimeExchangeRate ʵʱ����
      ,Currency
 ,round(ag.DefaultBid*d.RealTimeExchangeRate,4) DefaultBid_usd
 from erp_amazon_amazon_ad_products pr
  join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='��ٻ�' and pr.AdState='enabled'
  left join ( select distinct case when code = 'GB' then 'UK' else code end as code  ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
  left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
  join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId and ca.CampaignState ='enabled' and ca.TargetingType ='auto'
  join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId and ag.AdGroupState='enabled'
where  ms.code ='A08-US'  and pr.sku ='YMXA08US2023101102'


-- ��֤���Ƚ��
select distinct  GenerateDate  from wt_adserving_amazon_daily where MaxBidUSD>0

