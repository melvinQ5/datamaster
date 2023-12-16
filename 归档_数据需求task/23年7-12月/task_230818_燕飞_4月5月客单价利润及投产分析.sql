

with
od_pay as ( -- ��������
select Product_SPU as spu ,left(PayTime,7) pay_month
    ,count(distinct PlatOrderNumber) orders -- ������
    ,count(distinct case when FeeGross = 0 then PlatOrderNumber end ) orders_minusFreight -- �޳��˷ѵ��Ķ�����
    ,round(sum(totalgross/wo.ExchangeUSD),2) pay_sales
    ,round(sum(totalprofit/wo.ExchangeUSD),2) pay_profit
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) pay_sales_minusFreight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2)  pay_profit_minusFreight
    ,round(sum(feegross/wo.ExchangeUSD),2) feegross
from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>''
group by wo.Product_SPU ,left(PayTime,7)
)

,od_refund as ( -- �˿�����
select  Product_SPU as spu ,left(SettlementTime,7) refund_month
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
from wt_orderdetails wo join mysql_store  ms on ms.code=wo.shopcode
and SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '�˿�'  and wo.asin <>''  and wo.boxsku<>''
group by  wo.Product_SPU ,left(SettlementTime,7)
)

, lst_ad_spend as ( -- ������SKU�ۺϼ�����ѣ���ֹ����������ӵĹ�滨�ѣ���Ҫ�����������ӵĹ�滨��
select SPU , left(GenerateDate,7) ad_month
    , round(sum(AdExposure)) as ad_Exposure
    , round(sum(AdClicks)) as ad_Clicks
    , round(sum(AdSpend),2) as ad_Spend
    , round(sum(AdSales),2) as ad_TotalSale7Day
    , round(sum(AdSaleUnits),2) as ad_TotalSale7DayUnit
	, round(sum(AdClicks)/sum(AdExposure),4) as ctr
	, round(sum(AdSaleUnits)/sum(AdClicks),4) as cvr
	, round(sum(AdSpend)/sum(AdClicks),4) as cpc
	, round(sum(AdSales)/sum(AdSpend),4) as roas
	, round(sum(AdSpend)/sum(AdSales),4) as acost
from (select sellersku ,shopcode ,od.SPU -- ������Ʒ����������
    from ( -- ������Ʒ
    select product_spu as spu
    from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
        and PayTime >= '${StartDay}' and PayTime <'${NextStartDay}' and ms.department regexp '��'
        and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>'' group by product_spu
    ) od
    join wt_listing wl on od.spu = wl.spu
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
        from import_data.mysql_store where department regexp '��') ms on wl.shopcode=ms.Code
    group by  sellersku ,shopcode ,od.spu
    ) wl
-- join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
join import_data.wt_adserving_amazon_daily ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
where GenerateDate >= '${StartDay}' and GenerateDate<  '${NextStartDay}'
group by SPU , left(GenerateDate,7)
)

, prod as (
select distinct  spu ,DevelopLastAuditTime
from erp_product_products where IsMatrix = 1 and IsDeleted=0 and ProjectTeam = '��ٻ�'
)

-- , res as (
select
    pay_month as �·�
    ,t1.SPU
    ,date(DevelopLastAuditTime) as ��������ʱ��
    ,orders as ������
    ,orders_minusFreight as ������_���˷ѵ�
    ,pay_sales as �������۶�
    ,pay_sales_minusFreight as �������۶�_���˷�
    ,round( pay_sales_minusFreight / orders ,2) �͵���
    ,pay_profit as �����_δ�۹��
    ,round(pay_profit/pay_sales,2) as ������_δ�۹��
    ,pay_profit_minusFreight  as �����_δ�۹����˷�
    ,round(pay_profit_minusFreight/pay_sales_minusFreight,2) as ������_δ�۹����˷�
    ,refund as �˿��
    ,feegross as �˷�����
    ,pay_profit - ifnull(ad_Spend,0) as �����_�۹��
    ,round( (pay_profit - ifnull(ad_Spend,0)) / pay_sales ,2) ������_�۹��
    ,ad_Exposure as �ع���
    ,ad_Clicks as �����
    ,ad_Spend as ��滨��
    ,ad_TotalSale7DayUnit as �������
    ,ad_TotalSale7Day as ���ҵ��
    ,ctr
    ,cvr
    ,cpc
    ,acost
    ,roas
    ,round(ad_TotalSale7Day / ( pay_sales - ifnull(refund,0) ),2) as ���ҵ��ռ��
from od_pay t1
left join od_refund t2 on t1.spu = t2.spu and t1.pay_month = t2.refund_month
left join lst_ad_spend t3 on t1.spu = t3.spu and t1.pay_month = t3.ad_month
left join prod t4 on t1.spu =t4.spu
where t1.spu is not null
order by pay_month ,spu


-- select �·�, sum(�����_δ�۹��)  , sum(�����_�۹��) ,sum(�����_δ�۹��-�����_�۹��),sum(��滨��) from res group by �·�
-- select * from res;