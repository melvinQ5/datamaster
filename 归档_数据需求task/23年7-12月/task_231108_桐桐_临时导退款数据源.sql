select * from (
select
    wo.id ,cast( date(max_refunddate) as char ) �˿�ʱ�� ,week_num_in_year �˿���,wo.OrderNumber ���ж�����,PlatOrderNumber ƽ̨������
    ,BoxSku  ,abs(round( refundamount/ExchangeUSD ,2)) �˿���  ,Product_SPU as spu ,Product_Sku as sku  ,shopcode ���̼���, ms.Site ,SellerSku ����SKU ,asin
    ,date(PayTime) ����ʱ��
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
join dim_date dd on vr.max_refunddate = dd.full_date
where max_refunddate >='2023-01-01'  and TransactionType = '�˿�' ) t where  1=1


select rg.Id,cast(CreationTime as char ) CreationTime, CreatorId, cast(LastModificationTime as char) LastModificationTime, LastModifierId, IsDeleted, DeleterId, DeletionTime, CreateUserName, UpdateUserName, ShopId, ShopCode, Asin, MerchantSku, RefundAmount, OrderId, LabelPaidBy, LabelCurrency, LabelCost, LabelCarrier,cast(ReturnDate as char) ReturnDate, ReturnQuantity, IsPolicy, IsApproved, IsAZClaim, IsPrime, ReturnReasonCode, TrackingId, ReturnReasonCodeType, RefundAmountToUSD, BoxSKU, ProductId, SKU, SPU, LabelCostToUSD, ReturnReasonCodeTypeDesc, ReturnReasonFristLevel, ReturnReasonTwoLevel from erp_amazon_amazon_return_goods rg join wt_store ws on rg.ShopCode = ws.Code and ws.Department='������' and rg.IsDeleted=0 where 1=1 {{template}}