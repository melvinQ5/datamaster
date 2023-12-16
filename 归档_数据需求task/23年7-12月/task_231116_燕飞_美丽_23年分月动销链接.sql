-- �ظ�ֵ�����1 �����Ʒ����ͬ���ӵ��µ�,  ����Ψһֵ�ø�Ϊ���̼���+����SKU+��ƷSKU ��2 join ���ʱ����������nullֵ
-- ��������

with
-- ���� ���̷�Χ ����ʷ+Ŀǰ
-- full_store as ( select memo as Code  , case when c1 regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2 from manual_table where handlename='����_��ٻ����˺�_231116' )
-- ��� ���̷�Χ ��Ŀǰ
full_store as ( select  Code  , case when nodepathname regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2 from mysql_store where department='��ٻ�' )

,od as (
select TransactionType ,PayTime ,max_refunddate
    ,dep2 ����
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd
    ,round( TotalProfit/ExchangeUSD,2) TotalProfit_usd
    ,round( FeeGross/ExchangeUSD,2) FeeGross
    ,round( case when TransactionType = '����' then TotalExpend/ExchangeUSD end ,2) shopfee
    ,round( abs(TotalExpend/ExchangeUSD) + abs(ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then ifnull(AdvertisingCosts/ExchangeUSD,0) end),0))   ,2) Expend_usd_except_ad
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode
    ,case when TransactionType = '����' then '���̷�����' else  wo.SellerSku  end SellerSku
    ,wo.asin ,salecount
    ,year(SettlementTime) set_year
    ,month(SettlementTime) set_month
    ,BoxSku ,month(max_refunddate) re_month ,SettlementTime
from import_data.wt_orderdetails wo
join full_store fs on wo.shopcode=fs.Code
-- join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted=0  and SettlementTime  >='${StartDay}' and SettlementTime < '${NextStartDay}'
)


-- ----------���㶩������
,od_stat as (
select shopcode ,SellerSku ,asin, ifnull(sku,0) sku ,set_year ,set_month
    ,round( sum( TotalGross_usd ),2 ) TotalGross_usd
    ,round( sum( TotalProfit_usd ),2 ) TotalProfit_usd
    ,round( sum( refundamount_usd ),2 ) refund
    ,round( sum(FeeGross ),2) feegross
    ,round( sum(shopfee ),2) shopfee
    ,sum( case when  TransactionType = '����' then SaleCount end  ) SaleCount
    ,count(distinct case when  TransactionType = '����' then PlatOrderNumber end ) orders
from od
group by shopcode ,SellerSku ,asin,sku ,set_year ,set_month
)


,od_ori_stat as ( -- �ҵ�������
select shopcode ,SellerSku ,asin,sku ,set_year ,set_month
    ,round( sum( TotalGross_usd ),2 ) ���۶�_δ���˿�
    ,round( sum( TotalProfit_usd ),2 ) �����_δ���˿�
    ,round(sum(TotalGross_usd-FeeGross),2) �����˷����۶�
from od where TransactionType = '����'
group by shopcode ,SellerSku ,asin,sku ,set_year ,set_month
)

-- ----------���������
,ad as (
select  waad.shopcode ,waad.SellerSku ,asin ,waad.sku ,left(waad.sku,7) spu
     ,year(GenerateDate) ad_year
     ,month(GenerateDate) ad_month
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join full_store fs on waad.shopcode=fs.code and  GenerateDate >=  '2023-07-01'  and GenerateDate <  '${NextStartDay}'
)

, ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
    ( select  shopcode  ,SellerSku  ,asin,sku ,ad_year ,ad_month
        -- �ع���
        , round(sum(Exposure)) as ad_sku_Exposure
        -- ��滨��
        , round(sum(Spend),2) as ad_Spend
        -- ������۶�
        , round(sum(TotalSale7Day),2) as ad_TotalSale7Day
        -- �������
        , round(sum(TotalSale7DayUnit)) as ad_sku_TotalSale7DayUnit
        -- �����
        , round(sum(Clicks)) as ad_sku_Clicks
        from ad  group by  shopcode ,SellerSku ,asin ,sku ,ad_year ,ad_month
    ) tmp
)

,lst as ( -- �г��� ���й�滨�ѵ�����
select distinct shopcode ,SellerSku  ,asin ,set_year ,set_month ,a.sku
     ,spu ,BoxSku ,DevelopLastAuditTime
from (
select    shopcode ,SellerSku ,asin  ,set_year ,set_month,sku  from od_stat
union select  shopcode ,SellerSku ,asin  ,ad_year ,ad_month,sku from ad_stat where ad_Spend > 0
) a
left join wt_products wp on a.sku = wp.sku and wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0
)


-- ���������� 14% ��Ԥ����9%�� �������й�滨�ѣ�������ʱ���ڵĶ�����Ĺ�滨�Ѳ������е���

,undel_lst as ( -- δɾ������
select lst.shopcode ,lst.SellerSku ,lst.sku ,ListingStatus
from lst join erp_amazon_amazon_listing eaal on lst.shopcode=eaal.shopcode and lst.SellerSku=eaal.SellerSku and ListingStatus != 5 -- ����ѷ��̨API��ѡ״̬1��3��4��IT�����ӳ�ɾ��״̬5
group by  lst.shopcode ,lst.SellerSku ,lst.sku ,ListingStatus
)


,merge as (
select
    lst.set_year �������
    ,lst.set_month �����·�
    ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��' then 'Ȫ��' else '��ʷ�˺�' end ����
    ,ms.NodePathName `�����Ŷ�`
	,ms.SellUserName `��ѡҵ��Ա`
    ,right(lst.shopcode,2) `վ��`
	,ms.AccountCode `�˺�`
     ,lst.shopcode ���̼���
    ,ms.ShopStatus ����״̬
    ,lst.SellerSku ����SKU
    ,lst.asin
    ,wl.`��������`
    ,case when un.ListingStatus = 1 then '����' else '������' end ����״̬
    ,case when un.shopcode is null then '��ɾ��' else 'δɾ��' end �����Ƿ�ɾ��
    ,ifnull(feegross,0) `�˷�����`
    ,round(ifnull(TotalGross_usd,0),2) `�������۶�`
	,round(ifnull(TotalProfit_usd,0),2) `���������_δ��ad`
	,case when lst.set_month >=7 then round(ifnull(TotalProfit_usd,0) - ifnull(ad_Spend,0),2)  else 0 end `���������_7�����ad` -- 7��������������±�
    ,refund �˿���
    ,case when lst.SellerSku = '���̷�����' then '��' else '��'  end �Ƿ������̷�����
    ,shopfee ���̷���
    ,���۶�_δ���˿�
    ,�����_δ���˿�
    ,round(�����_δ���˿� /���۶�_δ���˿� ,4)  �ҵ�������
    ,ad_Spend `��滨��`
    ,ad_sku_Exposure `����ع���`
    ,ad_sku_Clicks `�������`
    ,ad_TotalSale7Day   `������۶�`
    ,ad_sku_TotalSale7DayUnit    `�������`
    ,lst.spu ,lst.sku ,lst.boxsku
    ,date(wp.DevelopLastAuditTime) ��������
    ,dkpt.ele_name_priority ���ȼ�Ԫ��
    ,dkpt.cat1 һ����Ŀ
    ,case when dp.spu is not null then '��' else '��' end �Ƿ��ǹ�������
    ,SaleCount ����
    ,orders ������
    ,�����˷����۶�
    ,case when orders >= 30 then '��30+' end ������30��
    ,case when �����˷����۶� >= 250 then '��SA' end �²����˷�ҵ����250
    ,concat(lst.SellerSku,'_',lst.shopcode) ����sku_����
    ,concat(lst.asin,'_',right(lst.shopcode,2)) asin_վ��
    ,wp.ProductStatusName ��Ʒ״̬
    ,wp.ProductStopTime ��Ʒͣ��ʱ��
from lst
left join mysql_store ms on lst.shopcode=ms.code
left join od_stat t1 on lst.shopcode=t1.shopcode and lst.SellerSku=t1.SellerSku and lst.sku=t1.sku and lst.set_month=t1.set_month and lst.set_year=t1.set_year
left join od_ori_stat t3 on lst.shopcode=t3.shopcode and lst.SellerSku=t3.SellerSku and lst.sku=t3.sku and lst.set_month=t3.set_month and lst.set_year=t3.set_year
left join ad_stat t2 on lst.shopcode=t2.shopcode and lst.SellerSku=t2.SellerSku and lst.sku=t2.sku and lst.set_month=t2.ad_month and lst.set_year=t2.ad_year
left join ( select ShopCode ,sellersku , left(min(MinPublicationDate),7) ��������  from wt_listing wl join mysql_store ms on ms.code = wl.ShopCode
   where  ms.Department='��ٻ�' group by shopcode,SellerSku ) wl
    on lst.shopcode=wl.shopcode and lst.SellerSku=wl.SellerSku
left join undel_lst un on lst.shopcode=un.shopcode and lst.SellerSku=un.SellerSku and lst.sku=un.sku
left join (select spu from dep_kbh_product_level where  isdeleted = 0 and prod_level regexp '����|����' and FirstDay  >='${StartDay}' group by spu ) dp on lst.spu = dp.spu
left join dep_kbh_product_test dkpt on dkpt.sku =lst.sku
left join wt_products wp on lst.sku = wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='��ٻ�'
)





,res as (
select
    ������� ,�����·� ,���� ,�����Ŷ� ,��ѡҵ��Ա ,վ�� ,�˺� ,���̼��� ,����״̬ ,����SKU ,asin ,�������� ,����״̬ ,�����Ƿ�ɾ��
    ,�˷����� ,�������۶� ,���������_δ��ad ,���������_7�����ad ,�˿��� ,�Ƿ������̷����� ,���̷��� ,���۶�_δ���˿� ,�����_δ���˿�
    ,�ҵ������� ,��滨�� ,����ع��� ,������� ,������۶� ,������� ,spu ,sku ,boxsku ,�������� ,���ȼ�Ԫ�� ,һ����Ŀ ,�Ƿ��ǹ�������
    ,���� ,������
     ,�����˷����۶� ,������30�� ,�²����˷�ҵ����250
     -- ,����sku_���� ,asin_վ��
     ,��Ʒ״̬ ,��Ʒͣ��ʱ��
from merge
group by ������� ,�����·� ,���� ,�����Ŷ� ,��ѡҵ��Ա ,վ�� ,�˺� ,���̼��� ,����״̬ ,����SKU ,asin ,�������� ,����״̬ ,�����Ƿ�ɾ��
    ,�˷����� ,�������۶� ,���������_δ��ad ,���������_7�����ad ,�˿��� ,�Ƿ������̷����� ,���̷��� ,���۶�_δ���˿� ,�����_δ���˿�
    ,�ҵ������� ,��滨�� ,����ع��� ,������� ,������۶� ,������� ,spu ,sku ,boxsku ,�������� ,���ȼ�Ԫ�� ,һ����Ŀ ,�Ƿ��ǹ�������
    ,���� ,������
       ,�����˷����۶� ,������30�� ,�²����˷�ҵ����250
       -- ,����sku_���� ,asin_վ��
       ,��Ʒ״̬ ,��Ʒͣ��ʱ��
)


-- ���
select * from res where ���̼��� = 'TR-US' and ����SKU ='04PY566526F8UWYS4';
-- select ������� ,�����·�,����SKU ,asin ,���̼���,sku  from res group by ������� ,�����·�,����SKU ,asin ,���̼���,sku having  count(*) >1
-- ����
-- select * from res where ������ >= 5;


-- ���� �����ƶ�����5����ͳ��
select �������,�����·�
    ,round( sum(�������۶� ),2)  �������۶�
    ,round( sum(���������_δ��ad ) ,2) ���������_δ��ad
    ,round( sum(���������_δ��ad ) / sum(�������۶� )  ,4) ������
    ,sum(������ ) ������
    ,sum(���� ) ����
    ,count(distinct ����sku_����) ����������

    ,round( sum(case when ������30�� ='��30+' then �������۶� end ),2) ��30_�������۶�
    ,round( sum(case when ������30�� ='��30+' then ���������_δ��ad end ),2) ��30_���������_δ��ad
    ,sum(case when ������30�� ='��30+' then ������ end ) ��30_������
    ,count(distinct case when ������30�� ='��30+' then ����sku_���� end ) ��30_����������

    ,round( sum(case when �²����˷�ҵ����250 ='��SA' then �������۶� end ),2) ��SA_�������۶�
    ,round( sum(case when �²����˷�ҵ����250 ='��SA' then ���������_δ��ad end ),2) ��SA_���������_δ��ad
    , sum(case when �²����˷�ҵ����250 ='��SA' then ������ end ) ��SA_������
    ,count(distinct case when �²����˷�ҵ����250 ='��SA' then ����sku_���� end ) ��SA_����������
from res
group by �������,�����·�
order by �������,�����·�
