-- sku boxsku 终审时间
with
tmp_epp as (
select  BoxSku ,sku
     ,date(DevelopLastAuditTime) dev_date ,left(DevelopLastAuditTime,7) dev_month
     ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
    ,ProductName  from wt_products wp where  ProjectTeam <> '深圳领科' and BoxSku is not null
)

, orders as (
select wo.salecount, wo.BoxSku
    , timestampdiff(SECOND,wo.PublicationDate,PayTime)/86400 as ord_days_since_lst  -- 订单宽表中有计算首次刊登时间
from import_data.wt_orderdetails wo
join wt_store ws on wo.AccountCode = ws.AccountCode and ws.Department <> ''
where wo.isdeleted = 0 and TransactionType ='付款'and OrderStatus <> '作废'
)

select
    a.BoxSku `塞盒SKU`
     ,b.dev_month `开发终审月份`
     ,b.dev_date `开发终审日期`
     ,b.sku
     ,ifnull( a.ord45_orders_since_lst ,0) `刊登0-45天出单件数`
     ,ifnull( a.ord90_orders_since_lst ,0) `刊登46-90天出单件数`
     ,ifnull( a.ord180_orders_since_lst ,0) `刊登91-180天出单件数`
     ,ifnull( a.ord270_orders_since_lst ,0) `刊登181-270天出单件数`
     ,ifnull( a.ord365_orders_since_lst ,0) `刊登271-365天出单件数`
     ,ifnull( a.ord_over365_orders_since_lst ,0) `刊登366天以上天出单件数`
     ,ifnull( InventoryAge45 ,0) `0-45天库龄数`
     ,ifnull( InventoryAge90  ,0) `46-90天库龄数`
     ,ifnull( InventoryAge180  ,0) `91-180天库龄数`
     ,ifnull( InventoryAge270  ,0) `181-270天库龄数`
     ,ifnull( InventoryAge365  ,0) `271-365天库龄数`
     ,ifnull( InventoryAgeOver ,0) `大于365天库龄数`
      ,ifnull( InventoryAgeAmount45 ,0) '0-45天库龄金额'
      ,ifnull( InventoryAgeAmount90 ,0) '46-90天库龄金额'
      ,ifnull( InventoryAgeAmount180 ,0) '91-180天库龄金额'
      ,ifnull( InventoryAgeAmount270 ,0) '181-270天库龄金额'
      ,ifnull( InventoryAgeAmount365 ,0) '271-365天库龄金额'
      ,ifnull( InventoryAgeAmountOver ,0) '大于365天库龄金额'
     ,b.ProductName `产品名称`
     ,b.ProductStatus `产品状态`
from
    ( -- 计算每笔出单链接从刊登起 N 天内出单
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

-- select Status  from erp_product_products where sku='5015664.01'  -- 开发状态为开发中

