/*全部业绩*/

select pp.boxsku, pp.ProductName`产品中文名`,wp.TortType`侵权类型`,wp.Logistics_Group_Attr,wp.Festival`季节节日`
,pp.ProductStatus`产品状态`,`21年出单月份`,`22年出单月份`,`近30天出单天数`,`12月出单天数`,近90天出单天数
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -30 day),'%Y/%m/%d') `近30天统计开始日期`
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -90 day),'%Y/%m/%d') `近90天统计开始日期`
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -1 day),'%Y/%m/%d') `统计截止日期`
from import_data.erp_product_products pp
left join (select distinct Sku,Logistics_Group_Attr,TortType, Festival  
from import_data.wt_products) wp on pp.SKU = wp.Sku


left join (
SELECT boxsku, count(distinct( left(PayTime,7) )) '21年出单月份'from import_data.OrderProfitSettle op 
where paytime >= '2021-01-01' and paytime < '2022-01-01' and OrderStatus<>'作废' and TransactionType='付款'
group by BoxSku
) a10 on a10.BoxSKU = pp.boxsku


left join (
SELECT boxsku, count(distinct( left(PayTime,7) )) '22年出单月份'from import_data.OrderProfitSettle op 
where paytime >= '2022-01-01' and paytime < '2022-12-01' and OrderStatus<>'作废' and TransactionType='付款'
group by BoxSku

) a11 on a11.BoxSKU = pp.boxsku



left join 
/*近30天出单天数*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '近30天出单天数' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime >= DATE_ADD( CURRENT_DATE(),interval -30 day) 
-- '2022-11-12'
and BoxDataTime < CURRENT_DATE() 
-- '2022-12-14'
group by BoxSKU) sd
on pp.BoxSku=sd.BoxSKU

left join
/*12月出单天数*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '12月出单天数' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime>='2022-12-01'
and BoxDataTime < CURRENT_DATE() 
group by BoxSKU) sd1
on pp.BoxSku=sd1.BoxSKU

left join 
/*近90天出单天数*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '近90天出单天数' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime>=DATE_ADD( CURRENT_DATE(),interval -90 day)
and BoxDataTime<CURRENT_DATE() 
group by BoxSKU) sd2
on pp.BoxSku=sd2.BoxSKU

where pp.IsMatrix=0 and pp.boxsku is not null and pp.IsDeleted=0 and ProductStatus<>2 

