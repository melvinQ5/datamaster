
-- ��Ʒ����
-- �ϰ������Ʒ�Ķ��壬ÿ���°��յ��¼�ǰ�����������Ϊ��Ʒ������SKU0001����ʱ����2��1�գ� 5��2����һ�ʳ�������ñʶ���������Ʒ���۶ͳ��5��ʱ����ƷΪ3��4��5�����£�
-- �°������Ʒ���壬��7��1��֮����������Ʒ
-- ʱ��ͳ�� 230101-231001

-- ʹ�ý���ʱ��
-- ��Ʒ14�춯���� �� ��Ʒ����14�춯��������ָ������Դ ֱ�ӻ�ȡÿ�����ɵġ���ƷN�쿪�������ʱ�



with
wp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01'
    and ProjectTeam = '��ٻ�' )

,od as (
select wo.*
    ,case
        when settlementtime < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( settlementtime,interval -day(settlementtime)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) >= 0  then '��Ʒ'
        when settlementtime < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( settlementtime,interval -day(settlementtime)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) < 0  then '��Ʒ'
        when DevelopLastAuditTime >= '2023-07-01' then '��Ʒ' end ����Ʒ
    , timestampdiff(SECOND,DevelopLastAuditTime,settlementtime)/86400 as ord_days
    , timestampdiff(SECOND,PublicationDate,settlementtime)/86400 as ord_days_since_lst
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms
	on wo.shopcode=ms.Code
left join (select boxsku ,min(DevelopLastAuditTime) DevelopLastAuditTime from  wt_products where ProjectTeam='��ٻ�' group by boxsku ) wp on wo.BoxSku = wp.BoxSku
where settlementtime >= '${StartDay}' and settlementtime <'${NextStartDay}' and wo.IsDeleted=0
)

,r1 as (  -- ��Ʒͳ��
select  DATE_FORMAT(settlementtime,'%Y%m') ͳ���·�
    ,round(sum(TotalGross/ExchangeUSD),2) ��Ʒ���۶�
    ,round(sum(TotalProfit/ExchangeUSD),2) ��Ʒ�����
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) ��Ʒ������_δ�۹��
    ,count(distinct Product_SPU) ��Ʒ����SPU��
    ,round(sum(TotalGross/ExchangeUSD)/count(distinct Product_SPU),4) ��Ʒ����SPU����
from od where ����Ʒ = '��Ʒ'
group by DATE_FORMAT(settlementtime,'%Y%m')
)

,tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)as dev_week
from import_data.erp_product_products epp
where epp.IsDeleted = 0 and epp.IsMatrix = 0 AND epp.ProjectTeam ='��ٻ�'
)

,tmp_lst as (
select DATE_FORMAT(MinPublicationDate,'%Y%m') pub_month ,MinPublicationDate
    ,ShopCode ,SellerSKU ,asin ,spu
    ,case
        when MinPublicationDate < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( MinPublicationDate,interval -day(MinPublicationDate)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) >= 0  then '��Ʒ'
        when MinPublicationDate < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( MinPublicationDate,interval -day(MinPublicationDate)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) < 0  then '��Ʒ'
        when DevelopLastAuditTime >= '2023-07-01' then '��Ʒ' end ����Ʒ
from wt_listing wl join mysql_store ms on wl.ShopCode = ms.Code and ms.Department='��ٻ�'
left join (select sku ,min(DevelopLastAuditTime) DevelopLastAuditTime from  wt_products where ProjectTeam='��ٻ�' group by sku ) wp on wl.sku = wp.sku
where MinPublicationDate  >= '${StartDay}'
)

-- ��Ʒ����14�춯���� = �״ο��Ǻ�14���ڳ�����SPU �� �״ο���SPU
-- �����¿���ƽ��������

,r2 as (
select a.* , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `��Ʒ����14�춯����`
from (
    select t.dev_month
            , count(distinct t.SPU) as dev_cnt
            , count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.Product_Sku end) as ord14_sku_cnt
            , round( count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.Product_Sku end) /  count(distinct t.SPU) ,4 ) ��Ʒ14�춯����
            , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.Product_Sku end) as ord14_sku_cnt_since_lst
    from tmp_epp t
    left join od on od.BoxSku =t.BoxSKU and od.����Ʒ = '��Ʒ' -- �Գ������㵱����˵����Ʒ
    group by t.dev_month ) a
left join ( select  pub_month ,count( distinct spu ) dev_pub_cnt from tmp_lst where ����Ʒ='��Ʒ' group by pub_month ) b -- ��Ʒ����SPU��
    on a.dev_month = b.pub_month
)


,r3 as (  -- �¿���ͳ��
select a.pub_month
    ,�¿������۶�
    ,�¿���������
    ,round( �¿��ǳ���������/�¿��������� ,4) �¿������Ӷ�����
    ,�����¿���ƽ��������
from (
    select  DATE_FORMAT(PublicationDate,'%Y%m') pub_month , DATE_FORMAT(settlementtime,'%Y%m') set_month
        ,round(sum( TotalGross/ExchangeUSD),2) �¿������۶�
        ,count(distinct concat(SellerSku,shopcode)) �¿��ǳ���������
    from od
    group by DATE_FORMAT(PublicationDate,'%Y%m') , DATE_FORMAT(settlementtime,'%Y%m')
    ) a
left join (
    select pub_month
         ,count(distinct concat(SellerSku,shopcode)) �¿���������
        ,round( count(distinct concat(SellerSku,shopcode)) /count(distinct spu ) ,4) �����¿���ƽ��������
    from tmp_lst group by pub_month
    ) b on a.pub_month = b.pub_month
where a.pub_month=set_month -- ���¿����ҵ��³���
)


,t_ad as (
select *,case when pre_ad_days < 0 then 0.1 else pre_ad_days end ad_days -- ���ڹ��ʱ�������״ο���ʱ�䣬��������ϴ
    ,DATE_FORMAT(GenerateDate,'%Y%m') ad_month
from (
select asa.ShopCode ,asa.Asin  ,asa.SellerSKU ,GenerateDate
    , AdExposure ,AdClicks ,AdSaleUnits
	, timestampdiff(SECOND,MinPublicationDate,asa.GenerateDate)/86400 as pre_ad_days -- ���Ǻ�14����
from tmp_lst t_list
join import_data.wt_adserving_amazon_daily asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
where asa.GenerateDate >= '2023-07-01' and  asa.GenerateDate < '${NextStartDay}'
) t1
)



, r4 as (
select ad_month
    ,ad7_lst
    , round(ad7_sku_Exposure/ad7_lst,2) as `����7��ƽ���ع���`
    , round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`
    , round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`
from
	( select ad_month
	    -- �ع�������
	    , count( distinct case when 0 <= ad_days and ad_days <= 7 then concat(SellerSku,shopcode) end ) ad7_lst
		-- �ع���
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_Exposure
		-- �������
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end),2) as ad14_sku_TotalSale7DayUnit
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_Clicks
		from t_ad  group by ad_month
	) tmp
)



-- ��Ʒ14�춯���� �� ��Ʒ����14�춯��������Դ ֱ�ӻ�ȡÿ�����ɵġ���ƷN�쿪�������ʱ�
select
    r1.*
     -- ,��Ʒ14�춯����
     ,�¿������۶� ,�¿������Ӷ�����
     -- ,��Ʒ����14�춯����
     ,�����¿���ƽ��������
    ,����7��ƽ���ع���
    ,round(r4.ad7_lst/�¿���������,4) ����7���ع���
    ,����14�������� ,����14����ת����
from r1
left join r2 on r1.ͳ���·�=r2.dev_month
left join r3 on r1.ͳ���·�=r3.pub_month
left join r4 on r1.ͳ���·�=r4.ad_month
order by r1.ͳ���·�