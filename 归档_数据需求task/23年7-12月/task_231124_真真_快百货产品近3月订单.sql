
with prod as (
    select memo as spu ,c2 as ��Ʒ״̬ ,c3 ״̬����ԭ�� ,c4 ������Ա ,c5 ���� ,DevelopLastAuditTime ����ʱ��
    from manual_table mt
    left join erp_product_products epp on mt.memo =epp.spu and epp.IsMatrix=1 and epp.IsDeleted=0 and ProjectTeam='��ٻ�'
    where handlename = '����_�²�Ʒ����_231124'
)

,od as (
select Product_Spu as spu
	,count( distinct case when month(PayTime) = 8 then PlatOrderNumber end ) 8�¶���
	,count( distinct case when month(PayTime) = 9 then PlatOrderNumber end ) 9�¶���
	,count( distinct case when month(PayTime) = 10 then PlatOrderNumber end ) 10�¶���
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.spu = wo.Product_Spu
join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= '2023-08-01' and PayTime < '2023-11-01'
    and wo.IsDeleted=0
	and ms.Department = '��ٻ�' and TransactionType='����'
group by Product_Spu )

select prod.* ,ifnull(8�¶���,0) 8�¶��� ,ifnull(9�¶���,0) 9�¶��� ,ifnull(10�¶���,0) 10�¶���
from prod left join od on prod.spu =od.spu