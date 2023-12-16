with t0 as (  -- sku x ��Ʒ������
select distinct eaapis.SellUserName ,wp.spu  ,wp.sku
    ,wp.BoxSku ,ProductName ��Ʒ����,wp.CategoryPathByChineseName ������Ŀ
    ,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ��Ʒ״̬
    ,DevelopUserName ������Ա ,date(DevelopLastAuditTime) ��������
    ,ele_name_group Ԫ�� ,isnew ����Ʒ ,ele_name_priority ���ȼ�Ԫ��
    ,left(wp.CreationTime,7) ��Ʒ�������
    ,case when  wp.CreationTime >= '2023-07-01' then '��' else '��' end �Ƿ�23��7�º����
    ,dep2
from erp_amazon_amazon_product_in_sells eaapis
join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0
left join dep_kbh_product_test dk on wp.sku =dk.sku
left join  ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,SellUserName
    from import_data.mysql_store where department regexp '��') ms on eaapis.SellUserName=ms.SellUserName
)

,t0_seller as (
select spu ,dep2  ,count(distinct SellUserName)  ����SPU�������� from t0 group by spu ,dep2  )

,online_lists as ( -- �����˺��嵥
select  eaal.sku ,SellUserName  ,CompanyCode  ,SellerSKU,ShopCode ,dep2 ,eaal.spu
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '����'
group by eaal.sku ,SellUserName  ,CompanyCode  ,SellerSKU,ShopCode ,dep2 ,eaal.spu
)

,online_comp_stat as ( select sku ,SellUserName ,count(distinct CompanyCode) �������� ,group_concat(CompanyCode)  �����˺Ŵ���
   from (select distinct sku ,SellUserName  ,CompanyCode from online_lists ) tmp  group by sku ,SellUserName )
,online_comp_stat_sku_dep2 as ( select sku  ,dep2 ,count(distinct CompanyCode) ������������_sku
   from (select distinct sku ,dep2  ,CompanyCode from online_lists ) tmp  group by sku,dep2  )
,online_comp_stat_spu as ( select spu   ,count(distinct CompanyCode) ��������_spu
   from (select distinct spu   ,CompanyCode from online_lists ) tmp  group by spu  )


,online_lst_stat as ( select sku ,SellUserName ,count(distinct concat(SellerSKU,ShopCode)) �������� from online_lists group by sku ,SellUserName )
,online_lst_stat_sku_dep2 as ( select sku ,dep2 ,count(distinct concat(SellerSKU,ShopCode)) ������������_sku from online_lists group by sku ,dep2 )
,online_lst_stat_spu as ( select spu  ,count(distinct concat(SellerSKU,ShopCode)) ��������_spu from online_lists group by spu  )

,od as (
select TransactionType ,PayTime ,max_refunddate
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
     ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month ,BoxSku ,SellUserName
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted=0  and ms.Department='��ٻ�' and PayTime  >=date_add('${NextStartDay}',interval -90-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day)
)

,od14 as (
select sku ,SellUserName
    ,sum(TotalGross_usd_pay) ��14�����۶�S2
    ,sum(TotalProfit_usd_pay) ��14�������M2
    ,round( sum(TotalProfit_usd_pay) / sum(TotalGross_usd_pay) ) ��14��������R2
    ,sum(salecount) ��14������
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='����'
group by sku ,SellUserName
)

,od14_seller as ( -- �����жϸ��˽�14���Ƿ����
select  SellUserName
    ,sum(salecount) ��14������_��Ա
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='����'
group by SellUserName
)


,od14_re as ( select sku ,SellUserName ,sum(refundamount_usd) ��14���˿��
from od where max_refunddate  >=date_add('${NextStartDay}',interval -14-1 day)  and max_refunddate <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='�˿�'
group by sku ,SellUserName )
   
,od30_re as ( select sku ,SellUserName ,sum(refundamount_usd) ��30���˿��
from od where max_refunddate  >=date_add('${NextStartDay}',interval -30-1 day)  and max_refunddate <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='�˿�'
group by sku ,SellUserName )

,od30 as (
select sku ,SellUserName
    ,sum(TotalGross_usd_pay) ��30�����۶�S2
    ,sum(TotalProfit_usd_pay) ��30�������M2
    ,round( sum(TotalProfit_usd_pay) / sum(TotalGross_usd_pay) ) ��30��������R2
    ,sum(salecount) ��30������
from od where PayTime  >=date_add('${NextStartDay}',interval -30-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='����'
group by sku ,SellUserName
)

,od14_sku as (
select sku
    ,sum(salecount) ��14������_sku
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='����'
group by sku
)

,ad as ( --
select  waad.shopcode ,waad.SellerSku ,waad.sku ,month(GenerateDate) ad_month
     ,AdSales  , AdSaleUnits 
    , waad.AdClicks , waad.AdExposure  ,waad.AdSpend 
    , AdROAS  ,AdAcost  ,SellUserName
from wt_adserving_amazon_daily waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '��ٻ�'
    and GenerateDate  >=date_add('${NextStartDay}',interval -14-1 day)  and GenerateDate <  date_add( '${NextStartDay}' ,interval -1 day)
)

, ad14 as (
select tmp.*
    , round(AdClicks/AdExposure,4) as click_rate -- `�������`
    , round(AdSaleUnits/AdClicks,6) as adsale_rate  -- `���ת����`
    , round(AdSales/AdSpend,2) as ROAS
    , round(AdSpend/AdSales,2) as ACOS
from
    ( select  sku ,SellUserName
        -- �ع���
        , round(sum(AdExposure)) as AdExposure
        -- ��滨��
        , round(sum(AdSpend),2) as AdSpend
        -- ������۶�
        , round(sum(AdSales),2) as AdSales
        -- �������
        , round(sum(AdSaleUnits),2) as AdSaleUnits
        -- �����
        , round(sum(AdClicks)) as AdClicks
        from ad  group by  sku ,SellUserName
    ) tmp
)

,res as (
select curdate() ������������ ,a.dep2 ����, NodePathName С��
, a.SellUserName ,a.spu ,a.sku ,a.boxsku ,a.��Ʒ���� ,a.������Ŀ ,a.��Ʒ״̬ ,a.�������� ,a.���ȼ�Ԫ��
,b.�������� ,c.�������� ,�����˺Ŵ���
,��14������_sku
,round(��14�����۶�S2,2) ��14�����۶�S2
,��14������
,AdExposure ��14���ع���
,AdClicks ��14������
,click_rate ��14������
,adsale_rate ��14��ת����
,ROAS ��14��ROI
,AdSpend ��14���滨��
,AdSales ��14�������۶�
,round( AdSpend /��14�����۶�S2 ,4 ) ��14���滨��ռ��
,��14��������R2
,round( ��14���˿�� / (ifnull(��14���˿��,0) + ��14�����۶�S2) ,4 ) ��14���˿���
,round( ��30�����۶�S2,2) ��30�����۶�S2
,��30��������R2
,round( ��30���˿�� / (ifnull(��30���˿��,0) + ��30�����۶�S2) ,4 ) ��30���˿���
,��Ʒ�������
,�Ƿ�23��7�º����
,����SPU��������
,������������_sku
,������������_sku
,��������_spu
,��������_spu
,case when ��14������_��Ա > 0 then '��' else '��' end ��14���Ƿ����_��Ա

from t0 a
left join online_comp_stat b on a.sku =b.sku and a.SellUserName = b.SellUserName
left join online_comp_stat_sku_dep2 b2 on a.sku =b2.sku and a.dep2 = b2.dep2
left join online_comp_stat_spu b3 on a.spu =b3.spu
left join online_lst_stat c on a.sku =c.sku and a.SellUserName = c.SellUserName
left join online_lst_stat_sku_dep2 c2 on a.sku =c2.sku and a.dep2 = c2.dep2
left join online_lst_stat_spu c3 on a.spu =c3.spu
left join ( select distinct case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,SellUserName,NodePathName
    from import_data.mysql_store where department regexp '��' ) ms on a.SellUserName =ms.SellUserName
left join od14 on a.sku =od14.sku and a.SellUserName = od14.SellUserName  
left join od14_seller on  a.SellUserName = od14_seller.SellUserName
left join od30 on a.sku =od30.sku and a.SellUserName = od30.SellUserName
left join od14_sku on a.sku =od14_sku.sku
left join ad14 on a.sku =ad14.sku and a.SellUserName = ad14.SellUserName
left join od14_re on a.sku =od14_re.sku and a.SellUserName = od14_re.SellUserName
left join od30_re on a.sku =od30_re.sku and a.SellUserName = od30_re.SellUserName
left join t0_seller on a.spu =t0_seller.spu and a.dep2 = t0_seller.dep2 )

select * from res ;
