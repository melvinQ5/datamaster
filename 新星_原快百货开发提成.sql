1.开发提成# rita姐销售额及利润额   /*注意开发人员会有变化*/
select 'Rita',sum(od.InCome),sum(od.GrossProfit)from (SELECT BoxSKU from erp_product_products
                                                      where DevelopUserName not in ('金磊','陈倩','李琴1688','李云霞','杨梅','夏菲','王婉君')
                                                      and IsDeleted=0
                                                      and IsMatrix=0
                                                     ) as t1
                    inner join OrderProfitSettle as od
                    on t1.BoxSku=od.BoxSku
                    and od.SettlementTime>='StartDay' and od.SettlementTime <'EndDay'
                    inner join erp_amazon_amazon_listing as al
                    on od.ShopIrobotId=al.ShopCode
                    and od.SellerSku=al.SellerSKU
                    and al.PublicationDate >=date_add('EndDay',interval -3 month ) and al.PublicationDate<'EndDay'
                    inner join mysql_store as s
                    on od.ShopIrobotId=s.Code
                    where s.Department in ('销售二部','销售三部')
                    and od.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime >= 'StartDay' and SettlementTime <'EndDay'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'));
# 金磊及其他人员
select '金磊',sum(t3.InCome),sum(t3.GrossProfit) from
                    erp_product_products as t1
                    inner join OrderProfitSettle as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='金磊'
                    and DevelopLastAuditTime >=date_add('EndDay',interval -3 month ) and DevelopLastAuditTime<'EndDay'
                    and t3.SettlementTime >= 'StartDay' and t3.SettlementTime<'EndDay'
                    inner join mysql_store as t4
                    on t3.ShopIrobotId=t4.Code
                    where t4.Department in ('销售二部','销售三部')
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime>= 'StartDay' and SettlementTime< 'EndDay '
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'))
union all
select '金磊',sum(t3.InCome),sum(t3.GrossProfit) from
                    erp_product_products as t1
                    inner join OrderProfitSettle as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='金磊'
                    and DevelopLastAuditTime >=date_add('EndDay',interval -6 month ) and DevelopLastAuditTime<date_add('EndDay',interval -3 month )
                    and t3.SettlementTime >='StartDay' and t3.SettlementTime< 'EndDay '
                    inner join mysql_store as t4
                    on t3.ShopIrobotId=t4.Code
                    where t4.Department in ('销售二部','销售三部')
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime>='StartDay' and SettlementTime<'EndDay'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'))
union all
select '金磊',sum(t3.InCome),sum(t3.GrossProfit)from
                    erp_product_products as t1
                    inner join OrderProfitSettle as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='金磊'
                    and DevelopLastAuditTime <date_add('EndDay',interval -6 month )
                    and t3.SettlementTime >= 'StartDay' and t3.SettlementTime <'EndDay'
                    inner join erp_amazon_amazon_listing as t4
                    on t3.ShopIrobotId=t4.ShopCode
                    and t3.SellerSku=t4.SellerSKU
                    and t4.PublicationDate>=date_add('EndDay',interval -3 month ) and t4.PublicationDate<'EndDay'
                    inner join mysql_store as t5
                    on t3.ShopIrobotId=t5.Code
                    where t5.Department in ('销售二部','销售三部')
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime >='StartDay' and SettlementTime <'EndDay'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'));



# rita姐销售额及利润额  /*注意开发人员会有变化*/
select 'Rita',sum(od.TotalGross/ExchangeRMB),sum(od.TotalProfit/ExchangeUSD)from (SELECT Sku from JinqinSku
                                                      where Monday='2023-03-09'
                                                    ) as t1
                    inner join ods_orderdetails as od
                    on t1.Sku=od.BoxSku
                    and od.SettlementTime>='${StartDay}' and od.SettlementTime <'${EndDay}'
                    and IsDeleted=0
                    inner join erp_amazon_amazon_listing as al
                    on od.ShopIrobotId=al.ShopCode
                    and od.SellerSku=al.SellerSKU
                    and al.PublicationDate >=date_add('${EndDay}',interval -3 month ) and al.PublicationDate<'${EndDay}'
                    inner join mysql_store as s
                    on od.ShopIrobotId=s.Code
                    where s.Department='快百货'
                    and od.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime>= '${StartDay}' and SettlementTime< '${EndDay}'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'));
# 金磊及其他人员
select '${name}',sum(t3.TotalGross/ExchangeUSD),sum(t3.TotalProfit/ExchangeUSD) from
                    erp_product_products as t1
                    inner join ods_orderdetails as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='${name}'
                    and ProjectTeam='快百货'
                    and t3.IsDeleted=0
                    and DevelopLastAuditTime >=date_add('${EndDay}',interval -3 month ) and DevelopLastAuditTime<'2023-03-01'
                    and t3.SettlementTime >= '${StartDay}' and t3.SettlementTime<'${EndDay}'
                    inner join mysql_store as t4
                    on t3.ShopIrobotId=t4.Code
                    where t4.Department ='快百货'
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime>= '${StartDay}' and SettlementTime<'${EndDay}'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'))
union all
select '${name}',sum(t3.TotalGross/ExchangeUSD),sum(t3.TotalProfit/ExchangeUSD) from
                    erp_product_products as t1
                    inner join ods_orderdetails as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='${name}'
                    and ProjectTeam='快百货'
                    and t3.IsDeleted=0
                    and DevelopLastAuditTime >=date_add('${StartDay}',interval -6 month ) and DevelopLastAuditTime<date_add('2023-03-01',interval -3 month )
                    and t3.SettlementTime >='${StartDay}' and t3.SettlementTime< '${EndDay}'
                    inner join mysql_store as t4
                    on t3.ShopIrobotId=t4.Code
                    where t4.Department ='快百货'
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime>='${StartDay}' and SettlementTime<'${EndDay}'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'))
union all
select '${name}',sum(t3.TotalGross/ExchangeUSD),sum(t3.TotalProfit/ExchangeUSD)from
                    erp_product_products as t1
                    inner join ods_orderdetails as t3
                    on t1.BoxSku=t3.BoxSku
                    and DevelopUserName ='${name}'
                    and t3.IsDeleted=0
                    and t1.ProjectTeam='快百货'
                    and DevelopLastAuditTime <date_add('${EndDay}',interval -6 month )
                    and t3.SettlementTime >= '${StartDay}' and t3.SettlementTime <'${EndDay}'
                    inner join erp_amazon_amazon_listing as t4
                    on t3.ShopIrobotId=t4.ShopCode
                    and t3.SellerSku=t4.SellerSKU
                    and t4.PublicationDate>=date_add('${EndDay}',interval -3 month ) and t4.PublicationDate<'${EndDay}'
                    inner join mysql_store as t5
                    on t3.ShopIrobotId=t5.Code
                    where t5.Department ='快百货'
                    and t3.OrderNumber not in(
                                            select OrderNumber from (
                                            SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM OrderProfitSettle
                                            where OrderStatus = '作废'
                                            and SettlementTime >='${StartDay}' and SettlementTime <'${EndDay}'
                                            group by OrderNumber) as a
                                            where a.alltype in ('付款', '其他'));

