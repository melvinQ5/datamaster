-- �������� �Ѹ��´��룬��ο� task_231103_�ξ�_SPUҵ��topվ�����Ա.sql
with epp as ( -- sku
select SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
from manual_table mt
left join import_data.erp_product_products epp on mt.c1 = epp.spu
join dim_date dd on dd.full_date = date(epp.DevelopLastAuditTime)
where IsMatrix = 0 and IsDeleted = 0  and mt.handlename='�ξ���ʱ231103'
group by SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
)

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount ,ms.site
	,wo.Product_SPU as SPU
	,wo.Product_SKU as SKU
    ,PayTime
    ,left(PayTime,7) pay_month
    ,SellUserName
    ,DevelopUserName,week_num_in_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_Sku  = epp.sku
where PayTime >= '2023-01-01'and wo.IsDeleted=0 and ms.Department = '��ٻ�' and OrderStatus != '����' and TransactionType='����'  -- S1���۶�
)

,seller_stat as (
select *
    , dense_rank() over (partition by spu order by TotalGross desc) seller_sort
    ,round (TotalGross / sum(TotalGross) over (partition by spu ) ,4 )  TotalGross_seller_rate
    from (select spu, SellUserName, round(sum(TotalGross / ExchangeUSD), 4) TotalGross  from t_orde group by spu, SellUserName) t)

,site_stat as (
select *
     , dense_rank() over (partition by spu order by TotalGross desc) site_sort
    ,round (TotalGross / sum(TotalGross) over (partition by spu ) ,4 )  TotalGross_site_rate
    from (select spu, site, round(sum(TotalGross / ExchangeUSD), 4) TotalGross  from t_orde group by spu, site) t)

-- select * from site_stat;

,t_merage as (
select epp.*
    ,t1.site ����top1վ��
    ,t1.TotalGross_site_rate ����top1վ��ҵ��ռ��
    ,t2.site ����top2վ��
    ,t2.TotalGross_site_rate ����top2վ��ҵ��ռ��

    ,t11.SellUserName ����top1����Ա
    ,t11.TotalGross_seller_rate ����top1����ҵ��ռ��
    ,t22.SellUserName ����top2����Ա
    ,t22.TotalGross_seller_rate ����top2����ҵ��ռ��

from ( select distinct  SPU  from epp ) epp
left join site_stat t1 on t1.site_sort = 1 and epp.SPU =t1.SPU
left join site_stat t2 on t2.site_sort = 2 and epp.SPU =t2.SPU
left join seller_stat t11 on t11.seller_sort = 1 and epp.SPU =t11.SPU
left join seller_stat t22 on t22.seller_sort = 2 and epp.SPU =t22.SPU
)

select *
from t_merage

-- WHERE spu=5177363

