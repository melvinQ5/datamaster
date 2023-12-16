-- CREATE
Alter VIEW dep_kbp_product_defect_view AS
with
pre_return as ( -- ��ȡ�����˻���¼
select id from (
select OrderId ,BoxSKU ,CreationTime ,id ,row_number() over (partition by OrderId ,BoxSKU order by CreationTime desc ) sort
from erp_amazon_amazon_return_goods where IsDeleted=0
) tmp where sort = 1
)

,return as (
select '�˻�����' SourceType
    ,rg.spu ,rg.sku ,rg.BoxSKU
    ,productname
    ,ASIN ,ws.site ,ShopCode ,date(ReturnDate) as IssueDate
    ,t.IssueType1
    ,rg.ReturnReasonTwoLevel as IssueType2
    ,ReturnReasonCodeTypeDesc memo
    ,OrderId as PlatOrderNumber
    ,dr.RefundStatus as RefundStatus-- �ͷ��˿��״̬
    ,'' ETLnote  -- �������ɱ�ע
from erp_amazon_amazon_return_goods rg
join pre_return pr on rg.id =pr.id
join wt_store ws on rg.ShopCode = ws.Code and ws.Department='��ٻ�' and rg.IsDeleted=0
left join daily_RefundOrders dr on rg.OrderId = dr.PlatOrderNumber
left join  wt_products wp on wp.id = rg.ProductId and ProjectTeam = '��ٻ�' and rg.IsDeleted=0
left join dep_kbp_product_defect_category_maps t  on rg.ReturnReasonFristLevel = t.SourceCat1 and rg.ReturnReasonTwoLevel = t.SourceCat2 and t.SourceType = '�˻�����'
)

, feedback as (
select  '�в���' SourceType
    ,spu , sku ,BoxSku
    ,Product_Name
    ,wo.ASIN ,wo.site ,df.ShopCode ,date(CommentTime) as IssueDate
    ,t.IssueType1
    ,df.BadCommentRe as IssueType2
    ,df.Memo as memo
    ,df.PlatOrderNumber
    ,ifnull(dr.RefundStatus,'�޼�¼') �ͷ��˿��״̬
    ,concat('�ͷ��˿��״̬:',ifnull(dr.RefundStatus,'�޼�¼'),',�Ա��в�������Դ״̬��',df.RefundType) as  �˿��ԴУ��
from daily_feedback df
join ( select distinct PlatOrderNumber ,wo.Product_SPU as spu,wo.Product_Sku as sku ,wo.BoxSku ,Product_Name ,wo.asin ,ms.site
    from  wt_orderdetails wo
    join mysql_store ms on ms.Code= wo.ShopCode and IsDeleted = 0  and ms.Department='��ٻ�'
    ) wo on df.PlatOrderNumber = wo.PlatOrderNumber
left join daily_RefundOrders dr on df.PlatOrderNumber = dr.PlatOrderNumber
left join dep_kbp_product_defect_category_maps t  on df.BadCommentRe = t.SourceCat1 and t.SourceType = '�в���'
)

,az as (
 select 'AZͶ��' SourceType
    ,spu , sku ,BoxSku
    ,Product_Name
    ,wo.ASIN ,wo.site ,da.ShopCode ,date(ReciveTime) as IssueDate
    ,issuetype1
    ,ClaimReason  as issuetype2
    ,ReasonType as memo
    ,da.PlatOrderNumber
    ,dr.RefundStatus �ͷ��˿��״̬
    ,'-' as  �������ɱ�ע
from daily_AmazonAZclaim da
join ( select distinct PlatOrderNumber ,wo.Product_SPU as spu,wo.Product_Sku as sku ,wo.BoxSku ,Product_Name ,wo.asin ,ms.site
    from  wt_orderdetails wo
    join mysql_store ms on ms.Code= wo.ShopCode and IsDeleted = 0 and ms.Department='��ٻ�'
    ) wo on da.PlatOrderNumber = wo.PlatOrderNumber
left join daily_RefundOrders dr on da.PlatOrderNumber = dr.PlatOrderNumber
left join dep_kbp_product_defect_category_maps t  on da.memo= t.SourceCat1 and da.ClaimReason = t.SourceCat2 and t.SourceType = 'AZͶ��'
)




,pdl as (
 select  '��Ʒ�����ʼ�' SourceType
    ,wp.spu , dp.sku ,dp.BoxSku
    ,Product_Name
    ,wo.ASIN ,wo.site ,dp.ShopCode ,date(dp.CreationTime) as IssueDate
    ,IssueType1
    ,'-'    as IssueType2
    ,DefectDetails as memo
    ,dp.PlatOrderNumber
    ,dr.RefundStatus �ͷ��˿��״̬
    ,dp.OrderNumber as  �������ɱ�ע
from daily_ProductDefectLog dp
join ( select distinct PlatOrderNumber ,wo.Product_SPU as spu,wo.Product_Sku as sku ,wo.BoxSku ,Product_Name ,wo.asin ,ms.site
    from  wt_orderdetails wo
    join mysql_store ms on ms.Code= wo.ShopCode and IsDeleted = 0 and ms.Department='��ٻ�'
    ) wo on dp.PlatOrderNumber = wo.PlatOrderNumber
left join daily_RefundOrders dr on dp.PlatOrderNumber = dr.PlatOrderNumber
left join  wt_products wp on wp.sku = dp.sku and ProjectTeam = '��ٻ�'
left join dep_kbp_product_defect_category_maps t  on dp.DefectType = t.SourceCat1 and t.SourceType = '��Ʒ�����ʼ�'
)

, refund as (
 select  '�˿��' SourceType
    ,wo.spu , wo.sku ,wo.BoxSku
    ,Product_Name
    ,wo.ASIN ,wo.site ,dr.OrderSource ,date(dr.RefundDate) as IssueDate
    ,IssueType1
    ,RefundReason2 as IssueType2
    ,'-' as memo
    ,dr.PlatOrderNumber
    ,dr.RefundStatus �ͷ��˿��״̬
    ,dr.OrderNumber as  �������ɱ�ע
from daily_RefundOrders dr
join ( select distinct PlatOrderNumber ,wo.Product_SPU as spu,wo.Product_Sku as sku ,wo.BoxSku ,Product_Name ,wo.asin ,ms.site
    from  wt_orderdetails wo
    join mysql_store ms on ms.Code= wo.ShopCode and IsDeleted = 0 and ms.Department='��ٻ�' and wo.ShipTime > '2000-01-01 00:00:00'
    ) wo on dr.PlatOrderNumber = wo.PlatOrderNumber
left join dep_kbp_product_defect_category_maps t  on dr.RefundReason1 = t.SourceCat1 and dr.RefundReason2 = t.SourceCat2 and t.SourceType = '�˿��'
)

, merge as (
select * from return
union all
select * from feedback
union all
select * from az
union all
select * from pdl
union all
select * from refund
)

select
    SourceType,
    merge.spu,
    merge.sku,
    merge.BoxSKU,
    merge.productname,
    ASIN,
    site,
    ShopCode,
    IssueDate,
    IssueType1,
    IssueType2,
    memo,
    merge.PlatOrderNumber,
    ShipTime,
    RefundStatus,
    date(wp.DevelopLastAuditTime) dev_date,
    wp.Artist,
    wp.Editor,
    wp.DevelopUserName,
    wp.NewCategory
from merge
left join  ( select  PlatOrderNumber ,min( ShipTime ) ShipTime
    from  wt_orderdetails wo
    join mysql_store ms on ms.Code= wo.ShopCode and IsDeleted = 0 and ms.Department='��ٻ�' and wo.ShipTime > '2000-01-01 00:00:00'
    group by wo.PlatOrderNumber
    ) wo on merge.PlatOrderNumber = wo.PlatOrderNumber
left join wt_products wp on merge.sku = wp.Sku and wp.IsDeleted=0 and wp.ProjectTeam='��ٻ�';


