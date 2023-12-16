/*
 ������ձ�
�θ磬��Ҫ�洢����ָ�꣬�� wt_adserving_amazon_daily ����ʷ���ݲ��ܣ��ӽ�����ʼ���ۿ���ֵ����������Ҫ�п��չ���
����ע�⣺�ձ��ṹ�޸ĺ󣬱��ݱ�����Ƿ�����Ч

ָ��1  �ֶ����� MaxEnabledBidUSD    ע�ͣ������bid������״̬��
ȡֵ�߼���
ɸѡ�������״̬=�����á��� ���״̬=�����á��� ����Ʒ״̬=�����á� �� Ͷ������ = ���Զ��� ��¼
����shopcode + sellersku + asin ��ΪΨһֵ��ȥͳ������Ĭ�Ͼ���


ָ��2  �ֶ����� MaxBidUSD   ע�� �������bid������״̬��
ȡֵ�߼���
ɸѡ��Ͷ������ = ���Զ�  �� Ĭ�Ͼ��� > 0.03�ļ�¼��
����shopcode + sellersku + asin ��ΪΨһֵ��ȥͳ������Ĭ�Ͼ���
 */

-- ָ��1 SQL
select  current_date() GenerateDate,shopcode ,sellersku ,asin ,ifnull(max(DefaultBid_usd),0) MaxEnabledBidUSD
from (
select ms.code as shopcode ,pr.Asin
        ,pr.sku as sellersku
        ,round(ag.DefaultBid/d.RealTimeExchangeRate,4) DefaultBid_usd
from erp_amazon_amazon_ad_products pr
join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='��ٻ�' and pr.AdState='enabled'
left join ( select distinct code ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId and ca.CampaignState ='enabled' and ca.TargetingType ='auto'
join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId and ag.AdGroupState='enabled'
) t
group by shopcode ,sellersku ,asin



-- ָ��2 SQL
select  current_date() GenerateDate,shopcode ,sellersku ,asin ,ifnull(max(DefaultBid_usd),0) MaxBidUSD
from (
select ms.code as shopcode ,pr.Asin
        ,pr.sku as sellersku
        ,round(ag.DefaultBid/d.RealTimeExchangeRate,4) DefaultBid_usd

from erp_amazon_amazon_ad_products pr
join mysql_store ms on ms.PlatformId =pr.ShopId and ms.Department='��ٻ�'
left join ( select distinct code ,Currency from erp_user_user_countrys where BaseStatus = 1) c on ms.site =c.Code
left join ( select distinct FromCurrency ,RealTimeExchangeRate from erp_user_user_exchange_rates where ToCurrency ='USD' and BaseStatus = 1 ) d on d.FromCurrency =c.Currency
join erp_amazon_amazon_ad_campaigns ca on pr.CampaignId = ca.CampaignId  and ca.TargetingType ='auto'
join erp_amazon_amazon_ad_groups ag on pr.AdGroupId  = ag.AdGroupId  and DefaultBid >= 0.03
) t
group by shopcode ,sellersku ,asin


