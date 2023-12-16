/*
һ��ָ�����߼�
�����=����*��Ʒ������*������������-��滨��ռ��-�˿��ʣ�
1 �������� ע�⣺���չ�������� �����ӹ���ع���������ʡ�ת���� ȥ������Ȼ�������֡�
���� = ����SPU�� *������/����SPU����
���� = ����SPU�� *���������+��Ȼ������/ ����SPU��
���� = ����SPU�� *������ع���+��Ȼ�ع�����* �ܵ����* ��ת���� / ����SPU��
����ع��� = ����SPU������ع��� * ���ع�SPU����ع���
����ع��� = ����SPU������ * ������SPU�������� * �������ӵ��ܹ���ع��� * ���ع����ӵ��ܹ���ع���
��Ȼ�ع��� = ����SPU������ * ��SPU�������� * 100% * �����ӹ���ع���

2 ���������ʲ���
���������� - ��滨��ռ�� -�˿��� = ����������+�˷�����ռ��-��������-���CPC*�������ռ��%/�����ת����*��Ʒ�����ۣ�-�˿���
���������� = ���������� - �˷�����ռ�� + ��������
��滨��ռ�� = ���CPC*�������ռ�� /�����ת����*��Ʒ�����ۣ�
��滨��ռ�� = ��滨��/������� * �������/���� * ��


����ά��˵������Ʒ��Χ��
1 ���Կ�Ʒ�� ������ 88 ��SPU�嵥�� ������2023��11��20�պ��¿�Ʒ���ԣ���Сģ�ͣ�������������Ʒ
2 ���Կ�Ʒ��spu����ʱ�� > 2023��11��20�� �� spu���ڷ�����Ʒ

�����������ɷ���
��Ϊ���� running total �ļ��㣬���ܴ������������⿪�����޷����㲿�ֹ����ۼ�ȥ�ء�ͬʱ��ǿ����ɶ��ԡ�
StartDay = 2023-11-27 ��49�ܿ�ʼ

 */

with
mysql_store_team as ( -- �޳�������Ӫ��,����dep2����ά��
select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,* from import_data.mysql_store where Department = '��ٻ�' and NodePathName != '������Ӫ��' )

,prod as (
select * from (
    select epp.spu ,min_DevelopLastAuditTime
         ,case when mt.spu is not null then '���Կ�Ʒ' when ele.spu is null then '���Կ�Ʒ' else '����' end as dev_method ,dd.week_num_in_year as dev_week
    from ( select spu ,min(DevelopLastAuditTime) min_DevelopLastAuditTime from erp_product_products epp
        where IsMatrix=0  and isdeleted = 0 and ProjectTeam = '��ٻ�'  group by spu ) epp
    left join ( select memo as spu from manual_table where handlename='�ٽ�_��ٻ�����ѡƷSPU_231212' ) mt on mt.spu =epp.spu
    left join ( select distinct spu from dep_kbh_product_test where ele_name_group regexp '����|�ļ�|�����|��ի��|ʥ����|ʥ����|��ʥ��|�ж�') ele on epp.spu =ele.spu
    join dim_date dd on date(min_DevelopLastAuditTime) = dd.full_date
    where epp.min_DevelopLastAuditTime >='2023-11-27' ) t
where dev_method != '����' )

,prod_stat as (
select  dev_method , count(spu) �ۼ�����SPU�� from prod
where min_DevelopLastAuditTime >='2023-11-27' -- ��49�ܿ�ʼͳ��
    and min_DevelopLastAuditTime < '${NextStartDay}' group by dev_method )

,od as ( -- ���ܶ���
select prod.dev_method ,dd.week_num_in_year as pay_week ,
TotalProfit,TotalGross,TotalExpend,RefundAmount,ExchangeUSD,BoxSku,SaleCount,TransactionType,PromotionalDiscounts,FeeGross
from wt_orderdetails  wo
join mysql_store_team ms on wo.shopcode = ms.code and ms.Department='��ٻ�'
join dim_date dd on date(PayTime) = dd.full_date
join prod on wo.product_spu = prod.spu -- ��join���޳��� ��������=�������̳ɱ�����
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and IsDeleted=0  -- ���ﲻɸ�������ͣ��ǿ���ֻ�㸶��ʱ���ڵ��˿ÿ�����������ܴΣ��˿��½������;����1214ֻ�����ϵ��˿�
)

,od_stat as (
select dev_method
,round(sum( TotalGross/ExchangeUSD) ,2) ���۶�S3
,round(sum( TotalProfit/ExchangeUSD) ,2) �����M3_δ��ad
,round(sum( TotalExpend/ExchangeUSD) ,2) �ɱ���
,abs( round(sum( RefundAmount/ExchangeUSD) ,2) )�˿���
,sum(SaleCount) ����
,sum(PromotionalDiscounts) �����ۿ�
,sum(FeeGross) �˷�����
from od group by dev_method )

,ad as ( -- ���ܹ��
select left(waad.sku,7) as spu ,sku  ,dev_method ,dd.week_num_in_year as ad_week,
ShopCode, SellerSku, asin,
AdSkuSaleCount7Day, AdExposure ,AdClicks ,AdSpend
from wt_adserving_amazon_daily waad join prod on prod.SPU = left(waad.sku,7) and GenerateDate >='${StartDay}' and GenerateDate<'${NextStartDay}'
join dim_date dd on GenerateDate= dd.full_date )

,ad_stat as (
select dev_method  ,sum(AdSkuSaleCount7Day) ������� ,sum(AdClicks) �������, sum(AdExposure) ����ع���, sum(AdSpend) ��滨��
from ad group by dev_method  )

,lst as ( -- �ۼƿ���
select wl.spu ,wl.sku ,asin ,ShopCode ,SellerSKU ,dd.week_num_in_year as lst_week ,dev_method
from wt_listing wl
join prod on wl.spu = prod.spu  and min_DevelopLastAuditTime >='2023-11-27'  and min_DevelopLastAuditTime < '${NextStartDay}'  -- �������ܵĲ�Ʒ
join dim_date dd on date(MinPublicationDate) = dd.full_date
where MinPublicationDate  >= '2023-11-27' -- ��49�ܿ�ʼͳ��
  and MinPublicationDate < '${NextStartDay}' )

,lst_stat as (
select dev_method  ,count(distinct spu) �ۼƿ���SPU��
,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct spu)   ,2) �ۼƵ�����SPU��������
, count(distinct concat(shopcode,sellersku) ) �ۼƿ���������
from lst group by dev_method  )

,lst_ad_stat as (
select lst.dev_method
, round( count(distinct concat(lst.shopcode,lst.sellersku) ) / count(distinct lst.spu) ,2) ���ܵ��ع�SPU��������
, count(distinct concat(lst.shopcode,lst.sellersku) ) �����ع�������
, round( sum(AdExposure) /  count(distinct concat(lst.shopcode,lst.sellersku) )   ,2)  ���ع����ӵ��ܹ���ع���
from lst join ad on ad.spu=lst.spu and ad.ShopCode = lst.ShopCode and ad.SellerSku = lst.SellerSKU
group by lst.dev_method  )

,res1 as (
select t0.��Ȼ��, t0.dev_method ��Ʒ����,
�ۼ�����SPU��,
round(�ۼƿ���SPU�� / �ۼ�����SPU�� ,2) �ۼ�SPU������,
�ۼƵ�����SPU��������,
round(�����ع������� / �ۼƿ��������� ,2) �������ӵ��ܹ���ع���,
���ع����ӵ��ܹ���ع���,
round(�������/����ع���,4) as �������,
round(ifnull(�������,0)/�������,4) as ���ת����,
round(���۶�S3/����,2) as ������,
round( (�����M3_δ��ad + �˿��� - �˷����� + �����ۿ�   )/���۶�S3,4) as ����������,
round(�����ۿ�/���۶�S3,4) as ��������,
round(�˷�����/���۶�S3,4) as �˷�����ռ��,
round(��滨��/�������,4) as ���CPC,

���۶�S3,
ROUND(�����M3_δ��ad - ��滨��,2) as �����M3,

round( (�����M3_δ��ad - ��滨��) /���۶�S3,4) as ������,
round( (�����M3_δ��ad + �˿���)/���۶�S3,4) as ����������,
round(��滨��/���۶�S3,4) as ��滨����,
round(�˿���/���۶�S3,4) as �˿���,


����,
round(����/�ۼ�����SPU��,2) as SPUƽ������,

ifnull(�������,0) �������,
���� - ifnull(�������,0) as ��Ȼ����,
round(�������/�ۼ�����SPU��,2) as SPUƽ���������,
round( (���� - ifnull(�������,0)) /�ۼ�����SPU��,2) as SPUƽ����Ȼ����,
����ع���

from ( select distinct dev_method ,dd.week_num_in_year as ��Ȼ�� from prod,dim_date dd where dd.full_date = '${StartDay}' ) t0
left join od_stat t1 on t1.dev_method = t0.dev_method
left join ad_stat t2 on t0.dev_method = t2.dev_method
left join prod_stat t3 on t0.dev_method = t3.dev_method
left join lst_ad_stat t4 on t0.dev_method = t4.dev_method
left join lst_stat t5 on t0.dev_method = t5.dev_method
order by ��Ȼ��,��Ʒ���� )

select round(�ۼ�����SPU��*�ۼ�SPU������*�ۼƵ�����SPU��������*�������ӵ��ܹ���ع���*���ع����ӵ��ܹ���ع���,2) , ����ع��� ,*
from res1