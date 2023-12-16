select epp.id as product_key ,AreaTag as TopSalesStateTag -- Top销售州标签
from (
    select *,row_number() over (partition by spu order by SaleCount desc) sort
    from (
        select spu ,RecivedState ,AreaTag ,sum(SaleCount) SaleCount
        from (
            select distinct do.OrderNumber ,do.RecivedState ,wo.Product_SPU as spu ,wo.Product_Sku , wo.SaleCount ,da.AreaTag
            from (
                select
                    case -- 清洗部分塞盒订单导出数据州地址不规范
                        when RecivedState = 'Florida' then 'FL'
                        when RecivedState = 'VIRGINIA' then 'VA'
                        when RecivedState = 'Georgia' then 'GA'
                        when RecivedState = 'NEW YORK' then 'NY'
                        when RecivedState = 'Ca' then 'CA'
                        when RecivedState = 'Az' then 'AZ'
                        when RecivedState = 'INDIANA' then 'IN'
                        when RecivedState = 'California' then 'CA'
                        else  RecivedState
                    END as RecivedState
                    ,OrderNumber,RecivedCountry
                from daily_Orders where ShipTime >= date_add('${NextStartDay}',interval - 90 day ) and ShipTime < '${NextStartDay}' and RecivedState is not null
                 ) do
            join dim_AbroadRegion da on do.RecivedCountry = da.CountryCode and do.RecivedState = da.StateCode
            join wt_orderdetails wo on do.OrderNumber = wo.OrderNumber and wo.OrderStatus != '作废' and wo.IsDeleted = 0
            ) t1
        group by spu ,RecivedState ,AreaTag
        ) t2
    ) t3
left join erp_product_products epp on epp.IsMatrix=0 and epp.spu = t3.spu and epp.IsDeleted = 0
where sort = 1