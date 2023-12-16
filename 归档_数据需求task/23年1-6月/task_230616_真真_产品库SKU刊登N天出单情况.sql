-- sku boxsku ����ʱ��
with
tmp_epp as (
select  BoxSku ,sku
     ,date(DevelopLastAuditTime) dev_date ,left(DevelopLastAuditTime,7) dev_month
     ,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
    ,ProductName  from wt_products wp where  ProjectTeam <> '�������' and BoxSku is not null
)

, orders as (
select wo.salecount, wo.BoxSku
    , timestampdiff(SECOND,wo.PublicationDate,PayTime)/86400 as ord_days_since_lst  -- ����������м����״ο���ʱ��
from import_data.wt_orderdetails wo
join wt_store ws on wo.AccountCode = ws.AccountCode and ws.Department <> ''
where wo.isdeleted = 0 and TransactionType ='����'and OrderStatus <> '����'
)

select
    a.BoxSku `����SKU`
     ,b.dev_month `���������·�`
     ,b.dev_date `������������`
     ,b.sku
     ,ifnull( a.ord45_orders_since_lst ,0) `����0-45���������`
     ,ifnull( a.ord90_orders_since_lst ,0) `����46-90���������`
     ,ifnull( a.ord180_orders_since_lst ,0) `����91-180���������`
     ,ifnull( a.ord270_orders_since_lst ,0) `����181-270���������`
     ,ifnull( a.ord365_orders_since_lst ,0) `����271-365���������`
     ,ifnull( a.ord_over365_orders_since_lst ,0) `����366���������������`
     ,ifnull( InventoryAge45 ,0) `0-45�������`
     ,ifnull( InventoryAge90  ,0) `46-90�������`
     ,ifnull( InventoryAge180  ,0) `91-180�������`
     ,ifnull( InventoryAge270  ,0) `181-270�������`
     ,ifnull( InventoryAge365  ,0) `271-365�������`
     ,ifnull( InventoryAgeOver ,0) `����365�������`
      ,ifnull( InventoryAgeAmount45 ,0) '0-45�������'
      ,ifnull( InventoryAgeAmount90 ,0) '46-90�������'
      ,ifnull( InventoryAgeAmount180 ,0) '91-180�������'
      ,ifnull( InventoryAgeAmount270 ,0) '181-270�������'
      ,ifnull( InventoryAgeAmount365 ,0) '271-365�������'
      ,ifnull( InventoryAgeAmountOver ,0) '����365�������'
     ,b.ProductName `��Ʒ����`
     ,b.ProductStatus `��Ʒ״̬`
from
    ( -- ����ÿ�ʳ������Ӵӿ����� N ���ڳ���
     select t.BoxSku
        , sum( case when 0 < ord_days_since_lst and ord_days_since_lst  <= 45 then salecount end) as ord45_orders_since_lst
        , sum( case when 45 < ord_days_since_lst and ord_days_since_lst  <= 90 then salecount end) as ord90_orders_since_lst
        , sum( case when 90 < ord_days_since_lst and ord_days_since_lst  <= 180 then salecount end) as ord180_orders_since_lst
        , sum( case when 180 < ord_days_since_lst and ord_days_since_lst  <= 270 then salecount end) as ord270_orders_since_lst
        , sum( case when 270 < ord_days_since_lst and ord_days_since_lst  <= 365 then salecount end) as ord365_orders_since_lst
        , sum( case when 365 < ord_days_since_lst then salecount end) as ord_over365_orders_since_lst
    from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU
    group by t.BoxSku
    ) a
left join tmp_epp b on a.BoxSku =b.BoxSku
left join (
    select BoxSku
        ,InventoryAge45 ,InventoryAge90 ,InventoryAge180 ,InventoryAge270 ,InventoryAge365 ,InventoryAgeOver
        ,InventoryAgeAmount45 ,InventoryAgeAmount90 ,InventoryAgeAmount180 ,InventoryAgeAmount270 ,InventoryAgeAmount365 ,InventoryAgeAmountOver
    from daily_WarehouseInventory where CreatedTime= '2023-06-16'
     ) c on a.BoxSku =c.BoxSku
order by ord45_orders_since_lst desc;

-- select Status  from erp_product_products where sku='5015664.01'  -- ����״̬Ϊ������

