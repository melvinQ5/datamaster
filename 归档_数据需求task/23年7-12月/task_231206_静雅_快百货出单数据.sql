-- ����SQL

-- SQL1 ������ϸ �ֱ𵼳� 22�ꡢ23�����°���
with
mysql_store_team as ( -- �����ṩ��ʷ�˺��˻��������
select c2 as ������ʼʱ�� ,c1 as ��������ʱ�� ,ws.* from manual_table mt join wt_store ws on mt.memo = ws.code and handlename='����_��ٻ��˺�ת�����_231206'
union select '2000-01-01' ,'9999-12-31' ,* from wt_store where department = '��ٻ�'
)

,od_pay as (
select
    ordernumber ϵͳ������,
    PlatOrderNumber ƽ̨������,
    wo.shopcode ���̼���,
    Seller ���۸�����,
    wo.Site վ��,
    wo.BoxSku ��Ʒsku,
    wo.asin,
    wo.SellerSku ����sku,
    PayTime ����ʱ��,
    month(PayTime) �����·�,
    round( OrderTotalPrice / ExchangeUSD ,2) �����ܽ��usd,
    round( TotalGross / ExchangeUSD ,2) ������usd,
    round( TotalProfit / ExchangeUSD ,2) ������usd,
    DevelopLastAuditTime sku����ʱ��,
    ProductStatusName ��ǰSKU״̬,
    case when ListingStatus=1 then '����'
         when ListingStatus=3 then '�¼�'
         when ListingStatus=4 then '��������' else 'ɾ��' end ��ǰ����״̬
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= ��������ʱ�� and PayTime >= ������ʼʱ��
left join wt_products wp on wo.BoxSku = wp.BoxSku
left join erp_amazon_amazon_listing eaal on wo.shopcode=eaal.ShopCode  and wo.SellerSku = eaal.SellerSKU and wo.Product_Sku=eaal.sku
where  wo.IsDeleted = 0 and PayTime >= '${StartDay}' and PayTime < '${NextStartDay}'  and TransactionType = '����' )

,od_refund as (
select BoxSku , vr.OrderNumber ,round( sum(RefundAmount / ExchangeUSD ) ,2) �˿���usd  ,max_refunddate �˿�ʱ��
from import_data.wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= ��������ʱ�� and PayTime >= ������ʼʱ��
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate< '${NextStartDay}'  and TransactionType = '�˿�'
group by BoxSku, vr.OrderNumber, max_refunddate
)

select t1.* ,t2.�˿�ʱ�� ,t2.�˿���usd
from od_pay t1 left join od_refund t2 on t1.��Ʒsku  = t2.BoxSku and t1.ϵͳ������ = t2.OrderNumber;



-- SQL2

with
mysql_store_team as ( -- �����ṩ��ʷ�˺��˻��������
select c2 as ������ʼʱ�� ,c1 as ��������ʱ�� ,ws.* from manual_table mt join wt_store ws on mt.memo = ws.code and handlename='����_��ٻ��˺�ת�����_231206'
union select '2000-01-01' ,'9999-12-31' ,* from wt_store where department = '��ٻ�'
)

,new_lst_stat as (
select year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month ,ProductSalesName as SellUserName ,AccountCode
    ,count( distinct concat(ShopCode,SellerSKU) ) ���¿���������
    ,count( distinct spu ) ���¿���SPU��
from wt_listing wl
join mysql_store_team  ms on wl.shopcode=ms.Code and MinPublicationDate <= ��������ʱ�� and MinPublicationDate >= ������ʼʱ��
where  MinPublicationDate >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
group by year(MinPublicationDate) ,month(MinPublicationDate) ,ProductSalesName ,AccountCode
)

, od_lst_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month ,Seller as SellUserName ,ms.AccountCode
     ,year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month
     ,count( distinct concat(wo.ShopCode,wo.SellerSKU) ) od_lst_cnt
     ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) od_lst_totalgross
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= ��������ʱ�� and PayTime >= ������ʼʱ��
left join (select asin ,MarketType as site ,min(MinPublicationDate) MinPublicationDate from wt_listing group by asin ,site ) wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType = '����' -- �������͵�sellersku�����ɵĹ����õ���Ϣ,����ʵsellersku
  and PayTime >= '${StartDay}'  and PayTime < '${NextStartDay}'
group by Seller ,ms.AccountCode ,year(PayTime) ,month(PayTime) ,year(MinPublicationDate) ,month(MinPublicationDate)
)

, od_lst_stat_pivot as (
select pub_year ,pub_month ,SellUserName ,AccountCode
    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_cnt end )  lst_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_cnt end )  lst_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_cnt end )  lst_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_cnt end )  lst_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_cnt end )  lst_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_cnt end )  lst_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_cnt end )  lst_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_cnt end )  lst_2308
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_cnt end )  lst_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_cnt end )  lst_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_cnt end )  lst_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_cnt end )  lst_2312

    ,sum( case when pay_year =2023 and pay_month = 1 then od_lst_totalgross end )  lst_gross_2301
    ,sum( case when pay_year =2023 and pay_month = 2 then od_lst_totalgross end )  lst_gross_2302
    ,sum( case when pay_year =2023 and pay_month = 3 then od_lst_totalgross end )  lst_gross_2303
    ,sum( case when pay_year =2023 and pay_month = 4 then od_lst_totalgross end )  lst_gross_2304
    ,sum( case when pay_year =2023 and pay_month = 5 then od_lst_totalgross end )  lst_gross_2305
    ,sum( case when pay_year =2023 and pay_month = 6 then od_lst_totalgross end )  lst_gross_2306
    ,sum( case when pay_year =2023 and pay_month = 7 then od_lst_totalgross end )  lst_gross_2307
    ,sum( case when pay_year =2023 and pay_month = 8 then od_lst_totalgross end )  lst_gross_2308
    ,sum( case when pay_year =2023 and pay_month = 9 then od_lst_totalgross end )  lst_gross_2309
    ,sum( case when pay_year =2023 and pay_month = 10 then od_lst_totalgross end )  lst_gross_2310
    ,sum( case when pay_year =2023 and pay_month = 11 then od_lst_totalgross end )  lst_gross_2311
    ,sum( case when pay_year =2023 and pay_month = 12 then od_lst_totalgross end )  lst_gross_2312
from od_lst_stat
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- ��ϴ��������·����ڿ����·�������
group by pub_year ,pub_month ,SellUserName ,AccountCode
)
   
, od_spu_stat as (
select  year(PayTime) pay_year ,month(PayTime) pay_month ,Seller as SellUserName ,ms.AccountCode
     ,year(MinPublicationDate) pub_year ,month(MinPublicationDate) pub_month
    ,Product_SPU as spu 
from wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code and PayTime <= ��������ʱ�� and PayTime >= ������ʼʱ��
left join (select asin ,MarketType as site ,min(MinPublicationDate) MinPublicationDate from wt_listing group by asin ,site ) wl on wo.asin=wl.asin  and wo.site = wl.site
where wo.IsDeleted = 0
  and wo.TransactionType = '����' -- �������͵�sellersku�����ɵĹ����õ���Ϣ,����ʵsellersku
  and PayTime >= '2023-01-01'
group by Seller ,ms.AccountCode ,year(PayTime) ,month(PayTime) ,year(MinPublicationDate) ,month(MinPublicationDate) ,Product_SPU
)

, od_spu_stat_pivot as (
select pub_year ,pub_month ,SellUserName ,AccountCode
    ,count( distinct  case when pay_year =2023 and pay_month = 1 then spu end )  spu_2301
    ,count( distinct  case when pay_year =2023 and pay_month = 2 then spu end )  spu_2302
    ,count( distinct  case when pay_year =2023 and pay_month = 3 then spu end )  spu_2303
    ,count( distinct  case when pay_year =2023 and pay_month = 4 then spu end )  spu_2304
    ,count( distinct  case when pay_year =2023 and pay_month = 5 then spu end )  spu_2305
    ,count( distinct  case when pay_year =2023 and pay_month = 6 then spu end )  spu_2306
    ,count( distinct  case when pay_year =2023 and pay_month = 7 then spu end )  spu_2307
    ,count( distinct  case when pay_year =2023 and pay_month = 8 then spu end )  spu_2308
    ,count( distinct  case when pay_year =2023 and pay_month = 9 then spu end )  spu_2309
    ,count( distinct  case when pay_year =2023 and pay_month = 10 then spu end )  spu_2310
    ,count( distinct  case when pay_year =2023 and pay_month = 11 then spu end )  spu_2311
    ,count( distinct  case when pay_year =2023 and pay_month = 12 then spu end )  spu_2312
from od_spu_stat
where timestampdiff(day, date(concat(pub_year,'-',pub_month,'-01')),  date(concat(pay_year,'-',pay_month,'-01')) ) >= 0  -- ��ϴ��������·����ڿ����·�������
group by pub_year ,pub_month ,SellUserName ,AccountCode
)

,t0 as (
select pub_year ,pub_month ,SellUserName ,AccountCode  from new_lst_stat
union select pub_year ,pub_year ,SellUserName ,AccountCode  from od_lst_stat_pivot where pub_year >= '2023-01-01'
)

,res2 as ( -- ���¿��Ƕ����ֲ�
select t1.*
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2301  end ,0) 2301����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2302  end ,0) 2302����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2303  end ,0) 2303����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2304  end ,0) 2304����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2305  end ,0) 2305����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2306  end ,0) 2306����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2307  end ,0) 2307����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2308  end ,0) 2308����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2309  end ,0) 2309����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2310  end ,0) 2310����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2311  end ,0) 2311����������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2312  end ,0) 2312����������
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2301 / ���¿���������  end ,4) 2301���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2302 / ���¿���������  end ,4) 2302���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2303 / ���¿���������  end ,4) 2303���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2304 / ���¿���������  end ,4) 2304���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2305 / ���¿���������  end ,4) 2305���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2306 / ���¿���������  end ,4) 2306���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2307 / ���¿���������  end ,4) 2307���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2308 / ���¿���������  end ,4) 2308���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2309 / ���¿���������  end ,4) 2309���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2310 / ���¿���������  end ,4) 2310���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2311 / ���¿���������  end ,4) 2311���Ӷ�����
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_2312 / ���¿���������  end ,4) 2312���Ӷ�����
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2301  end ,0) 2301����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2302  end ,0) 2302����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2303  end ,0) 2303����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2304  end ,0) 2304����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2305  end ,0) 2305����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2306  end ,0) 2306����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2307  end ,0) 2307����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2308  end ,0) 2308����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2309  end ,0) 2309����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2310  end ,0) 2310����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2311  end ,0) 2311����SPU��
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2312  end ,0) 2312����SPU��
     
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2301 / ���¿���SPU��  end ,4) 2301SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2302 / ���¿���SPU��  end ,4) 2302SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2303 / ���¿���SPU��  end ,4) 2303SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2304 / ���¿���SPU��  end ,4) 2304SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2305 / ���¿���SPU��  end ,4) 2305SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2306 / ���¿���SPU��  end ,4) 2306SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2307 / ���¿���SPU��  end ,4) 2307SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2308 / ���¿���SPU��  end ,4) 2308SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2309 / ���¿���SPU��  end ,4) 2309SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2310 / ���¿���SPU��  end ,4) 2310SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2311 / ���¿���SPU��  end ,4) 2311SPU������
    ,round(case when timestampdiff(day, '2022-09-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then spu_2312 / ���¿���SPU��  end ,4) 2312SPU������
     
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2301   end ,4) 2301����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2302   end ,4) 2302����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2303   end ,4) 2303����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2304   end ,4) 2304����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2305   end ,4) 2305����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2306   end ,4) 2306����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2307   end ,4) 2307����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2308   end ,4) 2308����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2309   end ,4) 2309����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2310   end ,4) 2310����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2311   end ,4) 2311����ҵ��
    ,round(case when timestampdiff(day, '2023-01-01',  date(concat(t1.pub_year,'-',t1.pub_month,'-01') ) ) >= 0 then lst_gross_2312   end ,4) 2312����ҵ��
from t0
left join new_lst_stat t1 on t1.pub_year = t0.pub_year and t1.pub_month =t0.pub_month and t1.SellUserName =t0.SellUserName and t1.AccountCode =t0.AccountCode
left join od_lst_stat_pivot t2 on t0.pub_year = t2.pub_year and t0.pub_month =t2.pub_month and t0.SellUserName =t2.SellUserName and t0.AccountCode =t2.AccountCode
left join od_spu_stat_pivot t3 on t0.pub_year = t3.pub_year and t0.pub_month =t3.pub_month and t0.SellUserName =t3.SellUserName and t0.AccountCode =t3.AccountCode
order by t1.AccountCode ,t1.SellUserName , t1.pub_month
)

select * from res2  