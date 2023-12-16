/*细分类目-所有部门*/

select a9.三级类目,a9.SKU数, a7.`2年出单月份`,`2年销售额`, `2年利润额`, `2年利润率`, `2年退款金额`, `2年订单数`, a7.`2021年出单月份`,`2021年销售额`, `2021年利润额`, `2021年利润率`, `2021年退款金额`, `2021年订单数`,a7.`2022年出单月份` ,`2022年销售额`, `2022年利润额`, `2022年利润率`, `2022年退款金额`, `2022年订单数`, `202101销售额`, `202101利润额`, `202101利润率`, `202101退款金额`, `202101订单数`, `202102销售额`, `202102利润额`, `202102利润率`, `202102退款金额`, `202102订单数`, `202103销售额`, `202103利润额`, `202103利润率`, `202103退款金额`, `202103订单数`, `202104销售额`, `202104利润额`, `202104利润率`, `202104退款金额`, `202104订单数`, `202105销售额`, `202105利润额`, `202105利润率`, `202105退款金额`, `202105订单数`, `202106销售额`, `202106利润额`, `202106利润率`, `202106退款金额`, `202106订单数`, `202107销售额`, `202107利润额`, `202107利润率`, `202107退款金额`, `202107订单数`, `202108销售额`, `202108利润额`, `202108利润率`, `202108退款金额`, `202108订单数`, `202109销售额`, `202109利润额`, `202109利润率`, `202109退款金额`, `202109订单数`, `202110销售额`, `202110利润额`, `202110利润率`, `202110退款金额`, `202110订单数`, `202111销售额`, `202111利润额`, `202111利润率`, `202111退款金额`, `202111订单数`, `202112销售额`, `202112利润额`, `202112利润率`, `202112退款金额`, `202112订单数`, `202201销售额`, `202201利润额`, `202201利润率`, `202201退款金额`, `202201订单数`, `202202销售额`, `202202利润额`, `202202利润率`, `202202退款金额`, `202202订单数`, `202203销售额`, `202203利润额`, `202203利润率`, `202203退款金额`, `202203订单数`, `202204销售额`, `202204利润额`, `202204利润率`, `202204退款金额`, `202204订单数`, `202205销售额`, `202205利润额`, `202205利润率`, `202205退款金额`, `202205订单数`, `202206销售额`, `202206利润额`, `202206利润率`, `202206退款金额`, `202206订单数`, `202207销售额`, `202207利润额`, `202207利润率`, `202207退款金额`, `202207订单数`, `202208销售额`, `202208利润额`, `202208利润率`, `202208退款金额`, `202208订单数`, `202209销售额`, `202209利润额`, `202209利润率`, `202209退款金额`, `202209订单数`, `202210销售额`, `202210利润额`, `202210利润率`, `202210退款金额`, `202210订单数` from

(select concat(od.一级类目,'>',od.二级类目) as '三级类目',count(distinct SKU) 'SKU数',

round(sum(od.`2年业绩`),2)'2年销售额',round(sum(od.`2年利润额`),2) '2年利润额',round(sum(od.`2年利润额`)/sum(od.`2年业绩`),4) '2年利润率' ,round(sum(od.`2年退款金额`),2)'2年退款金额',sum(od.`2年订单数`) '2年订单数',

round(sum(od.`2021年业绩`),2)'2021年销售额',round(sum(od.`2021年利润额`),2) '2021年利润额',round(sum(od.`2021年利润额`)/sum(od.`2021年业绩`),4) '2021年利润率' ,round(sum(od.`2021年退款金额`),2)'2021年退款金额',sum(od.`2021年订单数`) '2021年订单数',

round(sum(od.`2022年业绩`),2)'2022年销售额',round(sum(od.`2022年利润额`),2) '2022年利润额',round(sum(od.`2022年利润额`)/sum(od.`2022年业绩`),4) '2022年利润率' ,round(sum(od.`2022年退款金额`),2)'2022年退款金额',sum(od.`2022年订单数`) '2022年订单数',

round(sum(od.`202101业绩`),2)'202101销售额',round(sum(od.`202101利润额`),2) '202101利润额',round(sum(od.`202101利润额`)/sum(od.`202101业绩`),4) '202101利润率' ,round(sum(od.`202101退款金额`),2)'202101退款金额',sum(od.`202101订单`) '202101订单数',

round(sum(od.`202102业绩`),2)'202102销售额',round(sum(od.`202102利润额`),2) '202102利润额',round(sum(od.`202102利润额`)/sum(od.`202102业绩`),4) '202102利润率' , round(sum(od.`202102退款金额`),2)'202102退款金额',sum(od.`202102订单`) '202102订单数',

round(sum(od.`202103业绩`),2)'202103销售额',round(sum(od.`202103利润额`),2) '202103利润额',round(sum(od.`202103利润额`)/sum(od.`202103业绩`),4) '202103利润率' ,round(sum(od.`202103退款金额`),2)'202103退款金额',sum(od.`202103订单`) '202103订单数',

round(sum(od.`202104业绩`),2)'202104销售额',round(sum(od.`202104利润额`),2) '202104利润额',round(sum(od.`202104利润额`)/sum(od.`202104业绩`),4) '202104利润率' ,round(sum(od.`202104退款金额`),2)'202104退款金额',sum(od.`202104订单`) '202104订单数',

round(sum(od.`202105业绩`),2)'202105销售额',round(sum(od.`202105利润额`),2) '202105利润额',round(sum(od.`202105利润额`)/sum(od.`202105业绩`),4) '202105利润率' ,round(sum(od.`202105退款金额`),2)'202105退款金额',sum(od.`202105订单`) '202105订单数',

round(sum(od.`202106业绩`),2)'202106销售额',round(sum(od.`202106利润额`),2) '202106利润额',round(sum(od.`202106利润额`)/sum(od.`202106业绩`),4) '202106利润率' ,round(sum(od.`202106退款金额`),2)'202106退款金额',sum(od.`202106订单`) '202106订单数',

round(sum(od.`202107业绩`),2)'202107销售额',round(sum(od.`202107利润额`),2) '202107利润额',round(sum(od.`202107利润额`)/sum(od.`202107业绩`),4) '202107利润率' ,round(sum(od.`202107退款金额`),2)'202107退款金额',sum(od.`202107订单`) '202107订单数',

round(sum(od.`202108业绩`),2)'202108销售额',round(sum(od.`202108利润额`),2) '202108利润额',round(sum(od.`202108利润额`)/sum(od.`202108业绩`),4) '202108利润率' ,round(sum(od.`202108退款金额`),2)'202108退款金额',sum(od.`202108订单`) '202108订单数',

round(sum(od.`202109业绩`),2)'202109销售额',round(sum(od.`202109利润额`),2) '202109利润额',round(sum(od.`202109利润额`)/sum(od.`202109业绩`),4) '202109利润率' ,round(sum(od.`202109退款金额`),2)'202109退款金额',sum(od.`202109订单`) '202109订单数',

round(sum(od.`202110业绩`),2)'202110销售额',round(sum(od.`202110利润额`),2) '202110利润额',round(sum(od.`202110利润额`)/sum(od.`202110业绩`),4) '202110利润率' ,round(sum(od.`202110退款金额`),2)'202110退款金额',sum(od.`202110订单`) '202110订单数',

round(sum(od.`202111业绩`),2)'202111销售额',round(sum(od.`202111利润额`),2) '202111利润额',round(sum(od.`202111利润额`)/sum(od.`202111业绩`),4) '202111利润率' ,round(sum(od.`202111退款金额`),2)'202111退款金额',sum(od.`202111订单`) '202111订单数',

round(sum(od.`202112业绩`),2)'202112销售额',round(sum(od.`202112利润额`),2) '202112利润额',round(sum(od.`202112利润额`)/sum(od.`202112业绩`),4) '202112利润率' ,round(sum(od.`202112退款金额`),2)'202112退款金额',sum(od.`202112订单`) '202112订单数',

round(sum(od.`202201业绩`),2)'202201销售额',round(sum(od.`202201利润额`),2) '202201利润额',round(sum(od.`202201利润额`)/sum(od.`202201业绩`),4) '202201利润率' ,round(sum(od.`202201退款金额`),2)'202201退款金额',sum(od.`202201订单`) '202201订单数',

round(sum(od.`202202业绩`),2)'202202销售额',round(sum(od.`202202利润额`),2) '202202利润额',round(sum(od.`202202利润额`)/sum(od.`202202业绩`),4) '202202利润率' ,round(sum(od.`202202退款金额`),2)'202202退款金额',sum(od.`202202订单`) '202202订单数',

round(sum(od.`202203业绩`),2)'202203销售额',round(sum(od.`202203利润额`),2) '202203利润额',round(sum(od.`202203利润额`)/sum(od.`202203业绩`),4) '202203利润率' ,round(sum(od.`202203退款金额`),2)'202203退款金额',sum(od.`202203订单`) '202203订单数',

round(sum(od.`202204业绩`),2)'202204销售额',round(sum(od.`202204利润额`),2) '202204利润额',round(sum(od.`202204利润额`)/sum(od.`202204业绩`),4) '202204利润率' ,round(sum(od.`202204退款金额`),2)'202204退款金额',sum(od.`202204订单`) '202204订单数',

round(sum(od.`202205业绩`),2)'202205销售额',round(sum(od.`202205利润额`),2) '202205利润额',round(sum(od.`202205利润额`)/sum(od.`202205业绩`),4) '202205利润率' ,round(sum(od.`202205退款金额`),2)'202205退款金额',sum(od.`202205订单`) '202205订单数',

round(sum(od.`202206业绩`),2)'202206销售额',round(sum(od.`202206利润额`),2) '202206利润额',round(sum(od.`202206利润额`)/sum(od.`202206业绩`),4) '202206利润率' ,round(sum(od.`202206退款金额`),2)'202206退款金额',sum(od.`202206订单`) '202206订单数',

round(sum(od.`202207业绩`),2)'202207销售额',round(sum(od.`202207利润额`),2) '202207利润额',round(sum(od.`202207利润额`)/sum(od.`202207业绩`),4) '202207利润率' ,round(sum(od.`202207退款金额`),2)'202207退款金额',sum(od.`202207订单`) '202207订单数',

round(sum(od.`202208业绩`),2)'202208销售额',round(sum(od.`202208利润额`),2) '202208利润额',round(sum(od.`202208利润额`)/sum(od.`202208业绩`),4) '202208利润率' ,round(sum(od.`202208退款金额`),2)'202208退款金额',sum(od.`202208订单`) '202208订单数',

round(sum(od.`202209业绩`),2)'202209销售额',round(sum(od.`202209利润额`),2) '202209利润额',round(sum(od.`202209利润额`)/sum(od.`202209业绩`),4) '202209利润率' ,round(sum(od.`202209退款金额`),2)'202209退款金额',sum(od.`202209订单`) '202209订单数',

round(sum(od.`202210业绩`),2)'202210销售额',round(sum(od.`202210利润额`),2) '202210利润额',round(sum(od.`202210利润额`)/sum(od.`202210业绩`),4) '202210利润率' ,round(sum(od.`202210退款金额`),2)'202210退款金额',sum(od.`202210订单`) '202210订单数' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`一级类目`,split_part(pc.CategoryPathByChineseName,'>',2)`二级类目`,split_part(pc.CategoryPathByChineseName,'>',3)`三级类目`,split_part(pc.CategoryPathByChineseName,'>',4)`四级类目`,split_part(pc.CategoryPathByChineseName,'>',5)`五级类目`,

`2年业绩`, `2021年业绩`,`2022年业绩`,`202101业绩` ,`202102业绩`,`202103业绩`,`202104业绩`,`202105业绩`,`202106业绩`,`202107业绩`,`202108业绩`,`202109业绩`,`202110业绩`,`202111业绩`,`202112业绩`,`202201业绩`,`202202业绩`,`202203业绩`,`202204业绩`,`202205业绩`,`202206业绩`,`202207业绩`,`202208业绩`,`202209业绩`,`202210业绩`,

`2年利润额`, `2021年利润额`,`2022年利润额`,`202101利润额` ,`202102利润额`,`202103利润额`,`202104利润额`,`202105利润额`,`202106利润额`,`202107利润额`,`202108利润额`,`202109利润额`,`202110利润额`,`202111利润额`,`202112利润额`,`202201利润额`,`202202利润额`,`202203利润额`,`202204利润额`,`202205利润额`,`202206利润额`,`202207利润额`,`202208利润额`,`202209利润额`,`202210利润额`,

`2年退款金额`, `2021年退款金额`,`2022年退款金额`,`202101退款金额` ,`202102退款金额`,`202103退款金额`,`202104退款金额`,`202105退款金额`,`202106退款金额`,`202107退款金额`,`202108退款金额`,`202109退款金额`,`202110退款金额`,`202111退款金额`,`202112退款金额`,`202201退款金额`,`202202退款金额`,`202203退款金额`,`202204退款金额`,`202205退款金额`,`202206退款金额`,`202207退款金额`,`202208退款金额`,`202209退款金额`,`202210退款金额`,

`2年订单数`, `2021年订单数`,`2022年订单数`,`202101订单` ,`202102订单`,`202103订单`,`202104订单`,`202105订单`,`202106订单`,`202107订单`,`202108订单`,`202109订单`,`202110订单`,`202111订单`,`202112订单`,`202201订单`,`202202订单`,`202203订单`,`202204订单`,`202205订单`,`202206订单`,`202207订单`,`202208订单`,`202209订单`,`202210订单`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2年业绩' ,round(sum(GrossProfit)/6.5,1) '2年利润额',round(sum(RefundPrice)/6.5,1) '2年退款金额',count(distinct(ordernumber)) '2年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021年业绩' ,round(sum(GrossProfit)/6.5,1) '2021年利润额',round(sum(RefundPrice)/6.5,1) '2021年退款金额',count(distinct(ordernumber)) '2021年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022年业绩' ,round(sum(GrossProfit)/6.5,1) '2022年利润额',round(sum(RefundPrice)/6.5,1) '2022年退款金额',count(distinct(ordernumber)) '2022年订单数'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101业绩' ,round(sum(GrossProfit)/6.5,1) '202101利润额',round(sum(RefundPrice)/6.5,1) '202101退款金额',count(distinct(ordernumber)) '202101订单'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102业绩' ,round(sum(GrossProfit)/6.5,1) '202102利润额',round(sum(RefundPrice)/6.5,1) '202102退款金额',count(distinct(ordernumber)) '202102订单'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103业绩' ,round(sum(GrossProfit)/6.5,1) '202103利润额',round(sum(RefundPrice)/6.5,1) '202103退款金额',count(distinct(ordernumber)) '202103订单'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104业绩' ,round(sum(GrossProfit)/6.5,1) '202104利润额',round(sum(RefundPrice)/6.5,1) '202104退款金额',count(distinct(ordernumber)) '202104订单'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105业绩' ,round(sum(GrossProfit)/6.5,1) '202105利润额',round(sum(RefundPrice)/6.5,1) '202105退款金额',count(distinct(ordernumber)) '202105订单'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106业绩' ,round(sum(GrossProfit)/6.5,1) '202106利润额',round(sum(RefundPrice)/6.5,1) '202106退款金额',count(distinct(ordernumber)) '202106订单'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107业绩' ,round(sum(GrossProfit)/6.5,1) '202107利润额',round(sum(RefundPrice)/6.5,1) '202107退款金额',count(distinct(ordernumber)) '202107订单'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108业绩' ,round(sum(GrossProfit)/6.5,1) '202108利润额',round(sum(RefundPrice)/6.5,1) '202108退款金额',count(distinct(ordernumber)) '202108订单'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109业绩' ,round(sum(GrossProfit)/6.5,1) '202109利润额',round(sum(RefundPrice)/6.5,1) '202109退款金额',count(distinct(ordernumber)) '202109订单'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110业绩' ,round(sum(GrossProfit)/6.5,1) '202110利润额',round(sum(RefundPrice)/6.5,1) '202110退款金额',count(distinct(ordernumber)) '202110订单'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111业绩' ,round(sum(GrossProfit)/6.5,1) '202111利润额',round(sum(RefundPrice)/6.5,1) '202111退款金额',count(distinct(ordernumber)) '202111订单'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112业绩' ,round(sum(GrossProfit)/6.5,1) '202112利润额',round(sum(RefundPrice)/6.5,1) '202112退款金额',count(distinct(ordernumber)) '202112订单'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201业绩' ,round(sum(GrossProfit)/6.5,1) '202201利润额',round(sum(RefundPrice)/6.5,1) '202201退款金额',count(distinct(ordernumber)) '202201订单' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202业绩' ,round(sum(GrossProfit)/6.5,1) '202202利润额',round(sum(RefundPrice)/6.5,1) '202202退款金额',count(distinct(ordernumber)) '202202订单'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203业绩' ,round(sum(GrossProfit)/6.5,1) '202203利润额',round(sum(RefundPrice)/6.5,1) '202203退款金额',count(distinct(ordernumber)) '202203订单'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204业绩' ,round(sum(GrossProfit)/6.5,1) '202204利润额',round(sum(RefundPrice)/6.5,1) '202204退款金额',count(distinct(ordernumber)) '202204订单'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205业绩' ,round(sum(GrossProfit)/6.5,1) '202205利润额',round(sum(RefundPrice)/6.5,1) '202205退款金额',count(distinct(ordernumber)) '202205订单'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206业绩' ,round(sum(GrossProfit)/6.5,1) '202206利润额',round(sum(RefundPrice)/6.5,1) '202206退款金额',count(distinct(ordernumber)) '202206订单'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207业绩' ,round(sum(GrossProfit)/6.5,1) '202207利润额',round(sum(RefundPrice)/6.5,1) '202207退款金额',count(distinct(ordernumber)) '202207订单'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208业绩' ,round(sum(GrossProfit)/6.5,1) '202208利润额',round(sum(RefundPrice)/6.5,1) '202208退款金额',count(distinct(ordernumber)) '202208订单'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209业绩' ,round(sum(GrossProfit)/6.5,1) '202209利润额',round(sum(RefundPrice)/6.5,1) '202209退款金额',count(distinct(ordernumber)) '202209订单'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210业绩' ,round(sum(GrossProfit)/6.5,1) '202210利润额',round(sum(RefundPrice)/6.5,1) '202210退款金额',count(distinct(ordernumber)) '202210订单'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.一级类目,'>',od.二级类目)) a9

left join

(select concat(od.一级类目,'>',od.二级类目) '三级类目',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2年出单月份',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021年出单月份',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022年出单月份' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`一级类目`,split_part(CategoryPathByChineseName,'>',2)`二级类目`,split_part(CategoryPathByChineseName,'>',3)`三级类目`,split_part(CategoryPathByChineseName,'>',4)`四级类目`,split_part(CategoryPathByChineseName,'>',5)`五级类目`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.一级类目,'>',od.二级类目)) a7

on a9.三级类目=a7.三级类目

order by `2年销售额` desc;





/*三级类目*/

/*细分类目-所有部门*/

select a9.三级类目,a9.SKU数, a7.`2年出单月份`,`2年销售额`, `2年利润额`, `2年利润率`, `2年退款金额`, `2年订单数`, a7.`2021年出单月份`,`2021年销售额`, `2021年利润额`, `2021年利润率`, `2021年退款金额`, `2021年订单数`,a7.`2022年出单月份` ,`2022年销售额`, `2022年利润额`, `2022年利润率`, `2022年退款金额`, `2022年订单数`, `202101销售额`, `202101利润额`, `202101利润率`, `202101退款金额`, `202101订单数`, `202102销售额`, `202102利润额`, `202102利润率`, `202102退款金额`, `202102订单数`, `202103销售额`, `202103利润额`, `202103利润率`, `202103退款金额`, `202103订单数`, `202104销售额`, `202104利润额`, `202104利润率`, `202104退款金额`, `202104订单数`, `202105销售额`, `202105利润额`, `202105利润率`, `202105退款金额`, `202105订单数`, `202106销售额`, `202106利润额`, `202106利润率`, `202106退款金额`, `202106订单数`, `202107销售额`, `202107利润额`, `202107利润率`, `202107退款金额`, `202107订单数`, `202108销售额`, `202108利润额`, `202108利润率`, `202108退款金额`, `202108订单数`, `202109销售额`, `202109利润额`, `202109利润率`, `202109退款金额`, `202109订单数`, `202110销售额`, `202110利润额`, `202110利润率`, `202110退款金额`, `202110订单数`, `202111销售额`, `202111利润额`, `202111利润率`, `202111退款金额`, `202111订单数`, `202112销售额`, `202112利润额`, `202112利润率`, `202112退款金额`, `202112订单数`, `202201销售额`, `202201利润额`, `202201利润率`, `202201退款金额`, `202201订单数`, `202202销售额`, `202202利润额`, `202202利润率`, `202202退款金额`, `202202订单数`, `202203销售额`, `202203利润额`, `202203利润率`, `202203退款金额`, `202203订单数`, `202204销售额`, `202204利润额`, `202204利润率`, `202204退款金额`, `202204订单数`, `202205销售额`, `202205利润额`, `202205利润率`, `202205退款金额`, `202205订单数`, `202206销售额`, `202206利润额`, `202206利润率`, `202206退款金额`, `202206订单数`, `202207销售额`, `202207利润额`, `202207利润率`, `202207退款金额`, `202207订单数`, `202208销售额`, `202208利润额`, `202208利润率`, `202208退款金额`, `202208订单数`, `202209销售额`, `202209利润额`, `202209利润率`, `202209退款金额`, `202209订单数`, `202210销售额`, `202210利润额`, `202210利润率`, `202210退款金额`, `202210订单数` from

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目) as '三级类目',count(distinct SKU) 'SKU数',

round(sum(od.`2年业绩`),2)'2年销售额',round(sum(od.`2年利润额`),2) '2年利润额',round(sum(od.`2年利润额`)/sum(od.`2年业绩`),4) '2年利润率' ,round(sum(od.`2年退款金额`),2)'2年退款金额',sum(od.`2年订单数`) '2年订单数',

round(sum(od.`2021年业绩`),2)'2021年销售额',round(sum(od.`2021年利润额`),2) '2021年利润额',round(sum(od.`2021年利润额`)/sum(od.`2021年业绩`),4) '2021年利润率' ,round(sum(od.`2021年退款金额`),2)'2021年退款金额',sum(od.`2021年订单数`) '2021年订单数',

round(sum(od.`2022年业绩`),2)'2022年销售额',round(sum(od.`2022年利润额`),2) '2022年利润额',round(sum(od.`2022年利润额`)/sum(od.`2022年业绩`),4) '2022年利润率' ,round(sum(od.`2022年退款金额`),2)'2022年退款金额',sum(od.`2022年订单数`) '2022年订单数',

round(sum(od.`202101业绩`),2)'202101销售额',round(sum(od.`202101利润额`),2) '202101利润额',round(sum(od.`202101利润额`)/sum(od.`202101业绩`),4) '202101利润率' ,round(sum(od.`202101退款金额`),2)'202101退款金额',sum(od.`202101订单`) '202101订单数',

round(sum(od.`202102业绩`),2)'202102销售额',round(sum(od.`202102利润额`),2) '202102利润额',round(sum(od.`202102利润额`)/sum(od.`202102业绩`),4) '202102利润率' , round(sum(od.`202102退款金额`),2)'202102退款金额',sum(od.`202102订单`) '202102订单数',

round(sum(od.`202103业绩`),2)'202103销售额',round(sum(od.`202103利润额`),2) '202103利润额',round(sum(od.`202103利润额`)/sum(od.`202103业绩`),4) '202103利润率' ,round(sum(od.`202103退款金额`),2)'202103退款金额',sum(od.`202103订单`) '202103订单数',

round(sum(od.`202104业绩`),2)'202104销售额',round(sum(od.`202104利润额`),2) '202104利润额',round(sum(od.`202104利润额`)/sum(od.`202104业绩`),4) '202104利润率' ,round(sum(od.`202104退款金额`),2)'202104退款金额',sum(od.`202104订单`) '202104订单数',

round(sum(od.`202105业绩`),2)'202105销售额',round(sum(od.`202105利润额`),2) '202105利润额',round(sum(od.`202105利润额`)/sum(od.`202105业绩`),4) '202105利润率' ,round(sum(od.`202105退款金额`),2)'202105退款金额',sum(od.`202105订单`) '202105订单数',

round(sum(od.`202106业绩`),2)'202106销售额',round(sum(od.`202106利润额`),2) '202106利润额',round(sum(od.`202106利润额`)/sum(od.`202106业绩`),4) '202106利润率' ,round(sum(od.`202106退款金额`),2)'202106退款金额',sum(od.`202106订单`) '202106订单数',

round(sum(od.`202107业绩`),2)'202107销售额',round(sum(od.`202107利润额`),2) '202107利润额',round(sum(od.`202107利润额`)/sum(od.`202107业绩`),4) '202107利润率' ,round(sum(od.`202107退款金额`),2)'202107退款金额',sum(od.`202107订单`) '202107订单数',

round(sum(od.`202108业绩`),2)'202108销售额',round(sum(od.`202108利润额`),2) '202108利润额',round(sum(od.`202108利润额`)/sum(od.`202108业绩`),4) '202108利润率' ,round(sum(od.`202108退款金额`),2)'202108退款金额',sum(od.`202108订单`) '202108订单数',

round(sum(od.`202109业绩`),2)'202109销售额',round(sum(od.`202109利润额`),2) '202109利润额',round(sum(od.`202109利润额`)/sum(od.`202109业绩`),4) '202109利润率' ,round(sum(od.`202109退款金额`),2)'202109退款金额',sum(od.`202109订单`) '202109订单数',

round(sum(od.`202110业绩`),2)'202110销售额',round(sum(od.`202110利润额`),2) '202110利润额',round(sum(od.`202110利润额`)/sum(od.`202110业绩`),4) '202110利润率' ,round(sum(od.`202110退款金额`),2)'202110退款金额',sum(od.`202110订单`) '202110订单数',

round(sum(od.`202111业绩`),2)'202111销售额',round(sum(od.`202111利润额`),2) '202111利润额',round(sum(od.`202111利润额`)/sum(od.`202111业绩`),4) '202111利润率' ,round(sum(od.`202111退款金额`),2)'202111退款金额',sum(od.`202111订单`) '202111订单数',

round(sum(od.`202112业绩`),2)'202112销售额',round(sum(od.`202112利润额`),2) '202112利润额',round(sum(od.`202112利润额`)/sum(od.`202112业绩`),4) '202112利润率' ,round(sum(od.`202112退款金额`),2)'202112退款金额',sum(od.`202112订单`) '202112订单数',

round(sum(od.`202201业绩`),2)'202201销售额',round(sum(od.`202201利润额`),2) '202201利润额',round(sum(od.`202201利润额`)/sum(od.`202201业绩`),4) '202201利润率' ,round(sum(od.`202201退款金额`),2)'202201退款金额',sum(od.`202201订单`) '202201订单数',

round(sum(od.`202202业绩`),2)'202202销售额',round(sum(od.`202202利润额`),2) '202202利润额',round(sum(od.`202202利润额`)/sum(od.`202202业绩`),4) '202202利润率' ,round(sum(od.`202202退款金额`),2)'202202退款金额',sum(od.`202202订单`) '202202订单数',

round(sum(od.`202203业绩`),2)'202203销售额',round(sum(od.`202203利润额`),2) '202203利润额',round(sum(od.`202203利润额`)/sum(od.`202203业绩`),4) '202203利润率' ,round(sum(od.`202203退款金额`),2)'202203退款金额',sum(od.`202203订单`) '202203订单数',

round(sum(od.`202204业绩`),2)'202204销售额',round(sum(od.`202204利润额`),2) '202204利润额',round(sum(od.`202204利润额`)/sum(od.`202204业绩`),4) '202204利润率' ,round(sum(od.`202204退款金额`),2)'202204退款金额',sum(od.`202204订单`) '202204订单数',

round(sum(od.`202205业绩`),2)'202205销售额',round(sum(od.`202205利润额`),2) '202205利润额',round(sum(od.`202205利润额`)/sum(od.`202205业绩`),4) '202205利润率' ,round(sum(od.`202205退款金额`),2)'202205退款金额',sum(od.`202205订单`) '202205订单数',

round(sum(od.`202206业绩`),2)'202206销售额',round(sum(od.`202206利润额`),2) '202206利润额',round(sum(od.`202206利润额`)/sum(od.`202206业绩`),4) '202206利润率' ,round(sum(od.`202206退款金额`),2)'202206退款金额',sum(od.`202206订单`) '202206订单数',

round(sum(od.`202207业绩`),2)'202207销售额',round(sum(od.`202207利润额`),2) '202207利润额',round(sum(od.`202207利润额`)/sum(od.`202207业绩`),4) '202207利润率' ,round(sum(od.`202207退款金额`),2)'202207退款金额',sum(od.`202207订单`) '202207订单数',

round(sum(od.`202208业绩`),2)'202208销售额',round(sum(od.`202208利润额`),2) '202208利润额',round(sum(od.`202208利润额`)/sum(od.`202208业绩`),4) '202208利润率' ,round(sum(od.`202208退款金额`),2)'202208退款金额',sum(od.`202208订单`) '202208订单数',

round(sum(od.`202209业绩`),2)'202209销售额',round(sum(od.`202209利润额`),2) '202209利润额',round(sum(od.`202209利润额`)/sum(od.`202209业绩`),4) '202209利润率' ,round(sum(od.`202209退款金额`),2)'202209退款金额',sum(od.`202209订单`) '202209订单数',

round(sum(od.`202210业绩`),2)'202210销售额',round(sum(od.`202210利润额`),2) '202210利润额',round(sum(od.`202210利润额`)/sum(od.`202210业绩`),4) '202210利润率' ,round(sum(od.`202210退款金额`),2)'202210退款金额',sum(od.`202210订单`) '202210订单数' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`一级类目`,split_part(pc.CategoryPathByChineseName,'>',2)`二级类目`,split_part(pc.CategoryPathByChineseName,'>',3)`三级类目`,split_part(pc.CategoryPathByChineseName,'>',4)`四级类目`,split_part(pc.CategoryPathByChineseName,'>',5)`五级类目`,

`2年业绩`, `2021年业绩`,`2022年业绩`,`202101业绩` ,`202102业绩`,`202103业绩`,`202104业绩`,`202105业绩`,`202106业绩`,`202107业绩`,`202108业绩`,`202109业绩`,`202110业绩`,`202111业绩`,`202112业绩`,`202201业绩`,`202202业绩`,`202203业绩`,`202204业绩`,`202205业绩`,`202206业绩`,`202207业绩`,`202208业绩`,`202209业绩`,`202210业绩`,

`2年利润额`, `2021年利润额`,`2022年利润额`,`202101利润额` ,`202102利润额`,`202103利润额`,`202104利润额`,`202105利润额`,`202106利润额`,`202107利润额`,`202108利润额`,`202109利润额`,`202110利润额`,`202111利润额`,`202112利润额`,`202201利润额`,`202202利润额`,`202203利润额`,`202204利润额`,`202205利润额`,`202206利润额`,`202207利润额`,`202208利润额`,`202209利润额`,`202210利润额`,

`2年退款金额`, `2021年退款金额`,`2022年退款金额`,`202101退款金额` ,`202102退款金额`,`202103退款金额`,`202104退款金额`,`202105退款金额`,`202106退款金额`,`202107退款金额`,`202108退款金额`,`202109退款金额`,`202110退款金额`,`202111退款金额`,`202112退款金额`,`202201退款金额`,`202202退款金额`,`202203退款金额`,`202204退款金额`,`202205退款金额`,`202206退款金额`,`202207退款金额`,`202208退款金额`,`202209退款金额`,`202210退款金额`,

`2年订单数`, `2021年订单数`,`2022年订单数`,`202101订单` ,`202102订单`,`202103订单`,`202104订单`,`202105订单`,`202106订单`,`202107订单`,`202108订单`,`202109订单`,`202110订单`,`202111订单`,`202112订单`,`202201订单`,`202202订单`,`202203订单`,`202204订单`,`202205订单`,`202206订单`,`202207订单`,`202208订单`,`202209订单`,`202210订单`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2年业绩' ,round(sum(GrossProfit)/6.5,1) '2年利润额',round(sum(RefundPrice)/6.5,1) '2年退款金额',count(distinct(ordernumber)) '2年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021年业绩' ,round(sum(GrossProfit)/6.5,1) '2021年利润额',round(sum(RefundPrice)/6.5,1) '2021年退款金额',count(distinct(ordernumber)) '2021年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022年业绩' ,round(sum(GrossProfit)/6.5,1) '2022年利润额',round(sum(RefundPrice)/6.5,1) '2022年退款金额',count(distinct(ordernumber)) '2022年订单数'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101业绩' ,round(sum(GrossProfit)/6.5,1) '202101利润额',round(sum(RefundPrice)/6.5,1) '202101退款金额',count(distinct(ordernumber)) '202101订单'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102业绩' ,round(sum(GrossProfit)/6.5,1) '202102利润额',round(sum(RefundPrice)/6.5,1) '202102退款金额',count(distinct(ordernumber)) '202102订单'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103业绩' ,round(sum(GrossProfit)/6.5,1) '202103利润额',round(sum(RefundPrice)/6.5,1) '202103退款金额',count(distinct(ordernumber)) '202103订单'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104业绩' ,round(sum(GrossProfit)/6.5,1) '202104利润额',round(sum(RefundPrice)/6.5,1) '202104退款金额',count(distinct(ordernumber)) '202104订单'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105业绩' ,round(sum(GrossProfit)/6.5,1) '202105利润额',round(sum(RefundPrice)/6.5,1) '202105退款金额',count(distinct(ordernumber)) '202105订单'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106业绩' ,round(sum(GrossProfit)/6.5,1) '202106利润额',round(sum(RefundPrice)/6.5,1) '202106退款金额',count(distinct(ordernumber)) '202106订单'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107业绩' ,round(sum(GrossProfit)/6.5,1) '202107利润额',round(sum(RefundPrice)/6.5,1) '202107退款金额',count(distinct(ordernumber)) '202107订单'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108业绩' ,round(sum(GrossProfit)/6.5,1) '202108利润额',round(sum(RefundPrice)/6.5,1) '202108退款金额',count(distinct(ordernumber)) '202108订单'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109业绩' ,round(sum(GrossProfit)/6.5,1) '202109利润额',round(sum(RefundPrice)/6.5,1) '202109退款金额',count(distinct(ordernumber)) '202109订单'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110业绩' ,round(sum(GrossProfit)/6.5,1) '202110利润额',round(sum(RefundPrice)/6.5,1) '202110退款金额',count(distinct(ordernumber)) '202110订单'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111业绩' ,round(sum(GrossProfit)/6.5,1) '202111利润额',round(sum(RefundPrice)/6.5,1) '202111退款金额',count(distinct(ordernumber)) '202111订单'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112业绩' ,round(sum(GrossProfit)/6.5,1) '202112利润额',round(sum(RefundPrice)/6.5,1) '202112退款金额',count(distinct(ordernumber)) '202112订单'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201业绩' ,round(sum(GrossProfit)/6.5,1) '202201利润额',round(sum(RefundPrice)/6.5,1) '202201退款金额',count(distinct(ordernumber)) '202201订单' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202业绩' ,round(sum(GrossProfit)/6.5,1) '202202利润额',round(sum(RefundPrice)/6.5,1) '202202退款金额',count(distinct(ordernumber)) '202202订单'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203业绩' ,round(sum(GrossProfit)/6.5,1) '202203利润额',round(sum(RefundPrice)/6.5,1) '202203退款金额',count(distinct(ordernumber)) '202203订单'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204业绩' ,round(sum(GrossProfit)/6.5,1) '202204利润额',round(sum(RefundPrice)/6.5,1) '202204退款金额',count(distinct(ordernumber)) '202204订单'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205业绩' ,round(sum(GrossProfit)/6.5,1) '202205利润额',round(sum(RefundPrice)/6.5,1) '202205退款金额',count(distinct(ordernumber)) '202205订单'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206业绩' ,round(sum(GrossProfit)/6.5,1) '202206利润额',round(sum(RefundPrice)/6.5,1) '202206退款金额',count(distinct(ordernumber)) '202206订单'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207业绩' ,round(sum(GrossProfit)/6.5,1) '202207利润额',round(sum(RefundPrice)/6.5,1) '202207退款金额',count(distinct(ordernumber)) '202207订单'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208业绩' ,round(sum(GrossProfit)/6.5,1) '202208利润额',round(sum(RefundPrice)/6.5,1) '202208退款金额',count(distinct(ordernumber)) '202208订单'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209业绩' ,round(sum(GrossProfit)/6.5,1) '202209利润额',round(sum(RefundPrice)/6.5,1) '202209退款金额',count(distinct(ordernumber)) '202209订单'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210业绩' ,round(sum(GrossProfit)/6.5,1) '202210利润额',round(sum(RefundPrice)/6.5,1) '202210退款金额',count(distinct(ordernumber)) '202210订单'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目)) a9

left join

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目) '三级类目',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2年出单月份',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021年出单月份',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022年出单月份' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`一级类目`,split_part(CategoryPathByChineseName,'>',2)`二级类目`,split_part(CategoryPathByChineseName,'>',3)`三级类目`,split_part(CategoryPathByChineseName,'>',4)`四级类目`,split_part(CategoryPathByChineseName,'>',5)`五级类目`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目)) a7

on a9.三级类目=a7.三级类目

order by `2年销售额` desc;





/*四级类目*/

/*细分类目-所有部门*/

select a9.三级类目,a9.SKU数, a7.`2年出单月份`,`2年销售额`, `2年利润额`, `2年利润率`, `2年退款金额`, `2年订单数`, a7.`2021年出单月份`,`2021年销售额`, `2021年利润额`, `2021年利润率`, `2021年退款金额`, `2021年订单数`,a7.`2022年出单月份` ,`2022年销售额`, `2022年利润额`, `2022年利润率`, `2022年退款金额`, `2022年订单数`, `202101销售额`, `202101利润额`, `202101利润率`, `202101退款金额`, `202101订单数`, `202102销售额`, `202102利润额`, `202102利润率`, `202102退款金额`, `202102订单数`, `202103销售额`, `202103利润额`, `202103利润率`, `202103退款金额`, `202103订单数`, `202104销售额`, `202104利润额`, `202104利润率`, `202104退款金额`, `202104订单数`, `202105销售额`, `202105利润额`, `202105利润率`, `202105退款金额`, `202105订单数`, `202106销售额`, `202106利润额`, `202106利润率`, `202106退款金额`, `202106订单数`, `202107销售额`, `202107利润额`, `202107利润率`, `202107退款金额`, `202107订单数`, `202108销售额`, `202108利润额`, `202108利润率`, `202108退款金额`, `202108订单数`, `202109销售额`, `202109利润额`, `202109利润率`, `202109退款金额`, `202109订单数`, `202110销售额`, `202110利润额`, `202110利润率`, `202110退款金额`, `202110订单数`, `202111销售额`, `202111利润额`, `202111利润率`, `202111退款金额`, `202111订单数`, `202112销售额`, `202112利润额`, `202112利润率`, `202112退款金额`, `202112订单数`, `202201销售额`, `202201利润额`, `202201利润率`, `202201退款金额`, `202201订单数`, `202202销售额`, `202202利润额`, `202202利润率`, `202202退款金额`, `202202订单数`, `202203销售额`, `202203利润额`, `202203利润率`, `202203退款金额`, `202203订单数`, `202204销售额`, `202204利润额`, `202204利润率`, `202204退款金额`, `202204订单数`, `202205销售额`, `202205利润额`, `202205利润率`, `202205退款金额`, `202205订单数`, `202206销售额`, `202206利润额`, `202206利润率`, `202206退款金额`, `202206订单数`, `202207销售额`, `202207利润额`, `202207利润率`, `202207退款金额`, `202207订单数`, `202208销售额`, `202208利润额`, `202208利润率`, `202208退款金额`, `202208订单数`, `202209销售额`, `202209利润额`, `202209利润率`, `202209退款金额`, `202209订单数`, `202210销售额`, `202210利润额`, `202210利润率`, `202210退款金额`, `202210订单数` from

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目) as '三级类目',count(distinct SKU) 'SKU数',

round(sum(od.`2年业绩`),2)'2年销售额',round(sum(od.`2年利润额`),2) '2年利润额',round(sum(od.`2年利润额`)/sum(od.`2年业绩`),4) '2年利润率' ,round(sum(od.`2年退款金额`),2)'2年退款金额',sum(od.`2年订单数`) '2年订单数',

round(sum(od.`2021年业绩`),2)'2021年销售额',round(sum(od.`2021年利润额`),2) '2021年利润额',round(sum(od.`2021年利润额`)/sum(od.`2021年业绩`),4) '2021年利润率' ,round(sum(od.`2021年退款金额`),2)'2021年退款金额',sum(od.`2021年订单数`) '2021年订单数',

round(sum(od.`2022年业绩`),2)'2022年销售额',round(sum(od.`2022年利润额`),2) '2022年利润额',round(sum(od.`2022年利润额`)/sum(od.`2022年业绩`),4) '2022年利润率' ,round(sum(od.`2022年退款金额`),2)'2022年退款金额',sum(od.`2022年订单数`) '2022年订单数',

round(sum(od.`202101业绩`),2)'202101销售额',round(sum(od.`202101利润额`),2) '202101利润额',round(sum(od.`202101利润额`)/sum(od.`202101业绩`),4) '202101利润率' ,round(sum(od.`202101退款金额`),2)'202101退款金额',sum(od.`202101订单`) '202101订单数',

round(sum(od.`202102业绩`),2)'202102销售额',round(sum(od.`202102利润额`),2) '202102利润额',round(sum(od.`202102利润额`)/sum(od.`202102业绩`),4) '202102利润率' , round(sum(od.`202102退款金额`),2)'202102退款金额',sum(od.`202102订单`) '202102订单数',

round(sum(od.`202103业绩`),2)'202103销售额',round(sum(od.`202103利润额`),2) '202103利润额',round(sum(od.`202103利润额`)/sum(od.`202103业绩`),4) '202103利润率' ,round(sum(od.`202103退款金额`),2)'202103退款金额',sum(od.`202103订单`) '202103订单数',

round(sum(od.`202104业绩`),2)'202104销售额',round(sum(od.`202104利润额`),2) '202104利润额',round(sum(od.`202104利润额`)/sum(od.`202104业绩`),4) '202104利润率' ,round(sum(od.`202104退款金额`),2)'202104退款金额',sum(od.`202104订单`) '202104订单数',

round(sum(od.`202105业绩`),2)'202105销售额',round(sum(od.`202105利润额`),2) '202105利润额',round(sum(od.`202105利润额`)/sum(od.`202105业绩`),4) '202105利润率' ,round(sum(od.`202105退款金额`),2)'202105退款金额',sum(od.`202105订单`) '202105订单数',

round(sum(od.`202106业绩`),2)'202106销售额',round(sum(od.`202106利润额`),2) '202106利润额',round(sum(od.`202106利润额`)/sum(od.`202106业绩`),4) '202106利润率' ,round(sum(od.`202106退款金额`),2)'202106退款金额',sum(od.`202106订单`) '202106订单数',

round(sum(od.`202107业绩`),2)'202107销售额',round(sum(od.`202107利润额`),2) '202107利润额',round(sum(od.`202107利润额`)/sum(od.`202107业绩`),4) '202107利润率' ,round(sum(od.`202107退款金额`),2)'202107退款金额',sum(od.`202107订单`) '202107订单数',

round(sum(od.`202108业绩`),2)'202108销售额',round(sum(od.`202108利润额`),2) '202108利润额',round(sum(od.`202108利润额`)/sum(od.`202108业绩`),4) '202108利润率' ,round(sum(od.`202108退款金额`),2)'202108退款金额',sum(od.`202108订单`) '202108订单数',

round(sum(od.`202109业绩`),2)'202109销售额',round(sum(od.`202109利润额`),2) '202109利润额',round(sum(od.`202109利润额`)/sum(od.`202109业绩`),4) '202109利润率' ,round(sum(od.`202109退款金额`),2)'202109退款金额',sum(od.`202109订单`) '202109订单数',

round(sum(od.`202110业绩`),2)'202110销售额',round(sum(od.`202110利润额`),2) '202110利润额',round(sum(od.`202110利润额`)/sum(od.`202110业绩`),4) '202110利润率' ,round(sum(od.`202110退款金额`),2)'202110退款金额',sum(od.`202110订单`) '202110订单数',

round(sum(od.`202111业绩`),2)'202111销售额',round(sum(od.`202111利润额`),2) '202111利润额',round(sum(od.`202111利润额`)/sum(od.`202111业绩`),4) '202111利润率' ,round(sum(od.`202111退款金额`),2)'202111退款金额',sum(od.`202111订单`) '202111订单数',

round(sum(od.`202112业绩`),2)'202112销售额',round(sum(od.`202112利润额`),2) '202112利润额',round(sum(od.`202112利润额`)/sum(od.`202112业绩`),4) '202112利润率' ,round(sum(od.`202112退款金额`),2)'202112退款金额',sum(od.`202112订单`) '202112订单数',

round(sum(od.`202201业绩`),2)'202201销售额',round(sum(od.`202201利润额`),2) '202201利润额',round(sum(od.`202201利润额`)/sum(od.`202201业绩`),4) '202201利润率' ,round(sum(od.`202201退款金额`),2)'202201退款金额',sum(od.`202201订单`) '202201订单数',

round(sum(od.`202202业绩`),2)'202202销售额',round(sum(od.`202202利润额`),2) '202202利润额',round(sum(od.`202202利润额`)/sum(od.`202202业绩`),4) '202202利润率' ,round(sum(od.`202202退款金额`),2)'202202退款金额',sum(od.`202202订单`) '202202订单数',

round(sum(od.`202203业绩`),2)'202203销售额',round(sum(od.`202203利润额`),2) '202203利润额',round(sum(od.`202203利润额`)/sum(od.`202203业绩`),4) '202203利润率' ,round(sum(od.`202203退款金额`),2)'202203退款金额',sum(od.`202203订单`) '202203订单数',

round(sum(od.`202204业绩`),2)'202204销售额',round(sum(od.`202204利润额`),2) '202204利润额',round(sum(od.`202204利润额`)/sum(od.`202204业绩`),4) '202204利润率' ,round(sum(od.`202204退款金额`),2)'202204退款金额',sum(od.`202204订单`) '202204订单数',

round(sum(od.`202205业绩`),2)'202205销售额',round(sum(od.`202205利润额`),2) '202205利润额',round(sum(od.`202205利润额`)/sum(od.`202205业绩`),4) '202205利润率' ,round(sum(od.`202205退款金额`),2)'202205退款金额',sum(od.`202205订单`) '202205订单数',

round(sum(od.`202206业绩`),2)'202206销售额',round(sum(od.`202206利润额`),2) '202206利润额',round(sum(od.`202206利润额`)/sum(od.`202206业绩`),4) '202206利润率' ,round(sum(od.`202206退款金额`),2)'202206退款金额',sum(od.`202206订单`) '202206订单数',

round(sum(od.`202207业绩`),2)'202207销售额',round(sum(od.`202207利润额`),2) '202207利润额',round(sum(od.`202207利润额`)/sum(od.`202207业绩`),4) '202207利润率' ,round(sum(od.`202207退款金额`),2)'202207退款金额',sum(od.`202207订单`) '202207订单数',

round(sum(od.`202208业绩`),2)'202208销售额',round(sum(od.`202208利润额`),2) '202208利润额',round(sum(od.`202208利润额`)/sum(od.`202208业绩`),4) '202208利润率' ,round(sum(od.`202208退款金额`),2)'202208退款金额',sum(od.`202208订单`) '202208订单数',

round(sum(od.`202209业绩`),2)'202209销售额',round(sum(od.`202209利润额`),2) '202209利润额',round(sum(od.`202209利润额`)/sum(od.`202209业绩`),4) '202209利润率' ,round(sum(od.`202209退款金额`),2)'202209退款金额',sum(od.`202209订单`) '202209订单数',

round(sum(od.`202210业绩`),2)'202210销售额',round(sum(od.`202210利润额`),2) '202210利润额',round(sum(od.`202210利润额`)/sum(od.`202210业绩`),4) '202210利润率' ,round(sum(od.`202210退款金额`),2)'202210退款金额',sum(od.`202210订单`) '202210订单数' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`一级类目`,split_part(pc.CategoryPathByChineseName,'>',2)`二级类目`,split_part(pc.CategoryPathByChineseName,'>',3)`三级类目`,split_part(pc.CategoryPathByChineseName,'>',4)`四级类目`,split_part(pc.CategoryPathByChineseName,'>',5)`五级类目`,

`2年业绩`, `2021年业绩`,`2022年业绩`,`202101业绩` ,`202102业绩`,`202103业绩`,`202104业绩`,`202105业绩`,`202106业绩`,`202107业绩`,`202108业绩`,`202109业绩`,`202110业绩`,`202111业绩`,`202112业绩`,`202201业绩`,`202202业绩`,`202203业绩`,`202204业绩`,`202205业绩`,`202206业绩`,`202207业绩`,`202208业绩`,`202209业绩`,`202210业绩`,

`2年利润额`, `2021年利润额`,`2022年利润额`,`202101利润额` ,`202102利润额`,`202103利润额`,`202104利润额`,`202105利润额`,`202106利润额`,`202107利润额`,`202108利润额`,`202109利润额`,`202110利润额`,`202111利润额`,`202112利润额`,`202201利润额`,`202202利润额`,`202203利润额`,`202204利润额`,`202205利润额`,`202206利润额`,`202207利润额`,`202208利润额`,`202209利润额`,`202210利润额`,

`2年退款金额`, `2021年退款金额`,`2022年退款金额`,`202101退款金额` ,`202102退款金额`,`202103退款金额`,`202104退款金额`,`202105退款金额`,`202106退款金额`,`202107退款金额`,`202108退款金额`,`202109退款金额`,`202110退款金额`,`202111退款金额`,`202112退款金额`,`202201退款金额`,`202202退款金额`,`202203退款金额`,`202204退款金额`,`202205退款金额`,`202206退款金额`,`202207退款金额`,`202208退款金额`,`202209退款金额`,`202210退款金额`,

`2年订单数`, `2021年订单数`,`2022年订单数`,`202101订单` ,`202102订单`,`202103订单`,`202104订单`,`202105订单`,`202106订单`,`202107订单`,`202108订单`,`202109订单`,`202110订单`,`202111订单`,`202112订单`,`202201订单`,`202202订单`,`202203订单`,`202204订单`,`202205订单`,`202206订单`,`202207订单`,`202208订单`,`202209订单`,`202210订单`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2年业绩' ,round(sum(GrossProfit)/6.5,1) '2年利润额',round(sum(RefundPrice)/6.5,1) '2年退款金额',count(distinct(ordernumber)) '2年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021年业绩' ,round(sum(GrossProfit)/6.5,1) '2021年利润额',round(sum(RefundPrice)/6.5,1) '2021年退款金额',count(distinct(ordernumber)) '2021年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022年业绩' ,round(sum(GrossProfit)/6.5,1) '2022年利润额',round(sum(RefundPrice)/6.5,1) '2022年退款金额',count(distinct(ordernumber)) '2022年订单数'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101业绩' ,round(sum(GrossProfit)/6.5,1) '202101利润额',round(sum(RefundPrice)/6.5,1) '202101退款金额',count(distinct(ordernumber)) '202101订单'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102业绩' ,round(sum(GrossProfit)/6.5,1) '202102利润额',round(sum(RefundPrice)/6.5,1) '202102退款金额',count(distinct(ordernumber)) '202102订单'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103业绩' ,round(sum(GrossProfit)/6.5,1) '202103利润额',round(sum(RefundPrice)/6.5,1) '202103退款金额',count(distinct(ordernumber)) '202103订单'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104业绩' ,round(sum(GrossProfit)/6.5,1) '202104利润额',round(sum(RefundPrice)/6.5,1) '202104退款金额',count(distinct(ordernumber)) '202104订单'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105业绩' ,round(sum(GrossProfit)/6.5,1) '202105利润额',round(sum(RefundPrice)/6.5,1) '202105退款金额',count(distinct(ordernumber)) '202105订单'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106业绩' ,round(sum(GrossProfit)/6.5,1) '202106利润额',round(sum(RefundPrice)/6.5,1) '202106退款金额',count(distinct(ordernumber)) '202106订单'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107业绩' ,round(sum(GrossProfit)/6.5,1) '202107利润额',round(sum(RefundPrice)/6.5,1) '202107退款金额',count(distinct(ordernumber)) '202107订单'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108业绩' ,round(sum(GrossProfit)/6.5,1) '202108利润额',round(sum(RefundPrice)/6.5,1) '202108退款金额',count(distinct(ordernumber)) '202108订单'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109业绩' ,round(sum(GrossProfit)/6.5,1) '202109利润额',round(sum(RefundPrice)/6.5,1) '202109退款金额',count(distinct(ordernumber)) '202109订单'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110业绩' ,round(sum(GrossProfit)/6.5,1) '202110利润额',round(sum(RefundPrice)/6.5,1) '202110退款金额',count(distinct(ordernumber)) '202110订单'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111业绩' ,round(sum(GrossProfit)/6.5,1) '202111利润额',round(sum(RefundPrice)/6.5,1) '202111退款金额',count(distinct(ordernumber)) '202111订单'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112业绩' ,round(sum(GrossProfit)/6.5,1) '202112利润额',round(sum(RefundPrice)/6.5,1) '202112退款金额',count(distinct(ordernumber)) '202112订单'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201业绩' ,round(sum(GrossProfit)/6.5,1) '202201利润额',round(sum(RefundPrice)/6.5,1) '202201退款金额',count(distinct(ordernumber)) '202201订单' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202业绩' ,round(sum(GrossProfit)/6.5,1) '202202利润额',round(sum(RefundPrice)/6.5,1) '202202退款金额',count(distinct(ordernumber)) '202202订单'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203业绩' ,round(sum(GrossProfit)/6.5,1) '202203利润额',round(sum(RefundPrice)/6.5,1) '202203退款金额',count(distinct(ordernumber)) '202203订单'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204业绩' ,round(sum(GrossProfit)/6.5,1) '202204利润额',round(sum(RefundPrice)/6.5,1) '202204退款金额',count(distinct(ordernumber)) '202204订单'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205业绩' ,round(sum(GrossProfit)/6.5,1) '202205利润额',round(sum(RefundPrice)/6.5,1) '202205退款金额',count(distinct(ordernumber)) '202205订单'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206业绩' ,round(sum(GrossProfit)/6.5,1) '202206利润额',round(sum(RefundPrice)/6.5,1) '202206退款金额',count(distinct(ordernumber)) '202206订单'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207业绩' ,round(sum(GrossProfit)/6.5,1) '202207利润额',round(sum(RefundPrice)/6.5,1) '202207退款金额',count(distinct(ordernumber)) '202207订单'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208业绩' ,round(sum(GrossProfit)/6.5,1) '202208利润额',round(sum(RefundPrice)/6.5,1) '202208退款金额',count(distinct(ordernumber)) '202208订单'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209业绩' ,round(sum(GrossProfit)/6.5,1) '202209利润额',round(sum(RefundPrice)/6.5,1) '202209退款金额',count(distinct(ordernumber)) '202209订单'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210业绩' ,round(sum(GrossProfit)/6.5,1) '202210利润额',round(sum(RefundPrice)/6.5,1) '202210退款金额',count(distinct(ordernumber)) '202210订单'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目)) a9

left join

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目) '三级类目',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2年出单月份',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021年出单月份',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022年出单月份' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`一级类目`,split_part(CategoryPathByChineseName,'>',2)`二级类目`,split_part(CategoryPathByChineseName,'>',3)`三级类目`,split_part(CategoryPathByChineseName,'>',4)`四级类目`,split_part(CategoryPathByChineseName,'>',5)`五级类目`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目)) a7

on a9.三级类目=a7.三级类目

order by `2年销售额` desc;





/*五级类目*/

/*细分类目-所有部门*/

select a9.三级类目,a9.SKU数, a7.`2年出单月份`,`2年销售额`, `2年利润额`, `2年利润率`, `2年退款金额`, `2年订单数`, a7.`2021年出单月份`,`2021年销售额`, `2021年利润额`, `2021年利润率`, `2021年退款金额`, `2021年订单数`,a7.`2022年出单月份` ,`2022年销售额`, `2022年利润额`, `2022年利润率`, `2022年退款金额`, `2022年订单数`, `202101销售额`, `202101利润额`, `202101利润率`, `202101退款金额`, `202101订单数`, `202102销售额`, `202102利润额`, `202102利润率`, `202102退款金额`, `202102订单数`, `202103销售额`, `202103利润额`, `202103利润率`, `202103退款金额`, `202103订单数`, `202104销售额`, `202104利润额`, `202104利润率`, `202104退款金额`, `202104订单数`, `202105销售额`, `202105利润额`, `202105利润率`, `202105退款金额`, `202105订单数`, `202106销售额`, `202106利润额`, `202106利润率`, `202106退款金额`, `202106订单数`, `202107销售额`, `202107利润额`, `202107利润率`, `202107退款金额`, `202107订单数`, `202108销售额`, `202108利润额`, `202108利润率`, `202108退款金额`, `202108订单数`, `202109销售额`, `202109利润额`, `202109利润率`, `202109退款金额`, `202109订单数`, `202110销售额`, `202110利润额`, `202110利润率`, `202110退款金额`, `202110订单数`, `202111销售额`, `202111利润额`, `202111利润率`, `202111退款金额`, `202111订单数`, `202112销售额`, `202112利润额`, `202112利润率`, `202112退款金额`, `202112订单数`, `202201销售额`, `202201利润额`, `202201利润率`, `202201退款金额`, `202201订单数`, `202202销售额`, `202202利润额`, `202202利润率`, `202202退款金额`, `202202订单数`, `202203销售额`, `202203利润额`, `202203利润率`, `202203退款金额`, `202203订单数`, `202204销售额`, `202204利润额`, `202204利润率`, `202204退款金额`, `202204订单数`, `202205销售额`, `202205利润额`, `202205利润率`, `202205退款金额`, `202205订单数`, `202206销售额`, `202206利润额`, `202206利润率`, `202206退款金额`, `202206订单数`, `202207销售额`, `202207利润额`, `202207利润率`, `202207退款金额`, `202207订单数`, `202208销售额`, `202208利润额`, `202208利润率`, `202208退款金额`, `202208订单数`, `202209销售额`, `202209利润额`, `202209利润率`, `202209退款金额`, `202209订单数`, `202210销售额`, `202210利润额`, `202210利润率`, `202210退款金额`, `202210订单数` from

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目,'>',od.五级类目) as '三级类目',count(distinct SKU) 'SKU数',

round(sum(od.`2年业绩`),2)'2年销售额',round(sum(od.`2年利润额`),2) '2年利润额',round(sum(od.`2年利润额`)/sum(od.`2年业绩`),4) '2年利润率' ,round(sum(od.`2年退款金额`),2)'2年退款金额',sum(od.`2年订单数`) '2年订单数',

round(sum(od.`2021年业绩`),2)'2021年销售额',round(sum(od.`2021年利润额`),2) '2021年利润额',round(sum(od.`2021年利润额`)/sum(od.`2021年业绩`),4) '2021年利润率' ,round(sum(od.`2021年退款金额`),2)'2021年退款金额',sum(od.`2021年订单数`) '2021年订单数',

round(sum(od.`2022年业绩`),2)'2022年销售额',round(sum(od.`2022年利润额`),2) '2022年利润额',round(sum(od.`2022年利润额`)/sum(od.`2022年业绩`),4) '2022年利润率' ,round(sum(od.`2022年退款金额`),2)'2022年退款金额',sum(od.`2022年订单数`) '2022年订单数',

round(sum(od.`202101业绩`),2)'202101销售额',round(sum(od.`202101利润额`),2) '202101利润额',round(sum(od.`202101利润额`)/sum(od.`202101业绩`),4) '202101利润率' ,round(sum(od.`202101退款金额`),2)'202101退款金额',sum(od.`202101订单`) '202101订单数',

round(sum(od.`202102业绩`),2)'202102销售额',round(sum(od.`202102利润额`),2) '202102利润额',round(sum(od.`202102利润额`)/sum(od.`202102业绩`),4) '202102利润率' , round(sum(od.`202102退款金额`),2)'202102退款金额',sum(od.`202102订单`) '202102订单数',

round(sum(od.`202103业绩`),2)'202103销售额',round(sum(od.`202103利润额`),2) '202103利润额',round(sum(od.`202103利润额`)/sum(od.`202103业绩`),4) '202103利润率' ,round(sum(od.`202103退款金额`),2)'202103退款金额',sum(od.`202103订单`) '202103订单数',

round(sum(od.`202104业绩`),2)'202104销售额',round(sum(od.`202104利润额`),2) '202104利润额',round(sum(od.`202104利润额`)/sum(od.`202104业绩`),4) '202104利润率' ,round(sum(od.`202104退款金额`),2)'202104退款金额',sum(od.`202104订单`) '202104订单数',

round(sum(od.`202105业绩`),2)'202105销售额',round(sum(od.`202105利润额`),2) '202105利润额',round(sum(od.`202105利润额`)/sum(od.`202105业绩`),4) '202105利润率' ,round(sum(od.`202105退款金额`),2)'202105退款金额',sum(od.`202105订单`) '202105订单数',

round(sum(od.`202106业绩`),2)'202106销售额',round(sum(od.`202106利润额`),2) '202106利润额',round(sum(od.`202106利润额`)/sum(od.`202106业绩`),4) '202106利润率' ,round(sum(od.`202106退款金额`),2)'202106退款金额',sum(od.`202106订单`) '202106订单数',

round(sum(od.`202107业绩`),2)'202107销售额',round(sum(od.`202107利润额`),2) '202107利润额',round(sum(od.`202107利润额`)/sum(od.`202107业绩`),4) '202107利润率' ,round(sum(od.`202107退款金额`),2)'202107退款金额',sum(od.`202107订单`) '202107订单数',

round(sum(od.`202108业绩`),2)'202108销售额',round(sum(od.`202108利润额`),2) '202108利润额',round(sum(od.`202108利润额`)/sum(od.`202108业绩`),4) '202108利润率' ,round(sum(od.`202108退款金额`),2)'202108退款金额',sum(od.`202108订单`) '202108订单数',

round(sum(od.`202109业绩`),2)'202109销售额',round(sum(od.`202109利润额`),2) '202109利润额',round(sum(od.`202109利润额`)/sum(od.`202109业绩`),4) '202109利润率' ,round(sum(od.`202109退款金额`),2)'202109退款金额',sum(od.`202109订单`) '202109订单数',

round(sum(od.`202110业绩`),2)'202110销售额',round(sum(od.`202110利润额`),2) '202110利润额',round(sum(od.`202110利润额`)/sum(od.`202110业绩`),4) '202110利润率' ,round(sum(od.`202110退款金额`),2)'202110退款金额',sum(od.`202110订单`) '202110订单数',

round(sum(od.`202111业绩`),2)'202111销售额',round(sum(od.`202111利润额`),2) '202111利润额',round(sum(od.`202111利润额`)/sum(od.`202111业绩`),4) '202111利润率' ,round(sum(od.`202111退款金额`),2)'202111退款金额',sum(od.`202111订单`) '202111订单数',

round(sum(od.`202112业绩`),2)'202112销售额',round(sum(od.`202112利润额`),2) '202112利润额',round(sum(od.`202112利润额`)/sum(od.`202112业绩`),4) '202112利润率' ,round(sum(od.`202112退款金额`),2)'202112退款金额',sum(od.`202112订单`) '202112订单数',

round(sum(od.`202201业绩`),2)'202201销售额',round(sum(od.`202201利润额`),2) '202201利润额',round(sum(od.`202201利润额`)/sum(od.`202201业绩`),4) '202201利润率' ,round(sum(od.`202201退款金额`),2)'202201退款金额',sum(od.`202201订单`) '202201订单数',

round(sum(od.`202202业绩`),2)'202202销售额',round(sum(od.`202202利润额`),2) '202202利润额',round(sum(od.`202202利润额`)/sum(od.`202202业绩`),4) '202202利润率' ,round(sum(od.`202202退款金额`),2)'202202退款金额',sum(od.`202202订单`) '202202订单数',

round(sum(od.`202203业绩`),2)'202203销售额',round(sum(od.`202203利润额`),2) '202203利润额',round(sum(od.`202203利润额`)/sum(od.`202203业绩`),4) '202203利润率' ,round(sum(od.`202203退款金额`),2)'202203退款金额',sum(od.`202203订单`) '202203订单数',

round(sum(od.`202204业绩`),2)'202204销售额',round(sum(od.`202204利润额`),2) '202204利润额',round(sum(od.`202204利润额`)/sum(od.`202204业绩`),4) '202204利润率' ,round(sum(od.`202204退款金额`),2)'202204退款金额',sum(od.`202204订单`) '202204订单数',

round(sum(od.`202205业绩`),2)'202205销售额',round(sum(od.`202205利润额`),2) '202205利润额',round(sum(od.`202205利润额`)/sum(od.`202205业绩`),4) '202205利润率' ,round(sum(od.`202205退款金额`),2)'202205退款金额',sum(od.`202205订单`) '202205订单数',

round(sum(od.`202206业绩`),2)'202206销售额',round(sum(od.`202206利润额`),2) '202206利润额',round(sum(od.`202206利润额`)/sum(od.`202206业绩`),4) '202206利润率' ,round(sum(od.`202206退款金额`),2)'202206退款金额',sum(od.`202206订单`) '202206订单数',

round(sum(od.`202207业绩`),2)'202207销售额',round(sum(od.`202207利润额`),2) '202207利润额',round(sum(od.`202207利润额`)/sum(od.`202207业绩`),4) '202207利润率' ,round(sum(od.`202207退款金额`),2)'202207退款金额',sum(od.`202207订单`) '202207订单数',

round(sum(od.`202208业绩`),2)'202208销售额',round(sum(od.`202208利润额`),2) '202208利润额',round(sum(od.`202208利润额`)/sum(od.`202208业绩`),4) '202208利润率' ,round(sum(od.`202208退款金额`),2)'202208退款金额',sum(od.`202208订单`) '202208订单数',

round(sum(od.`202209业绩`),2)'202209销售额',round(sum(od.`202209利润额`),2) '202209利润额',round(sum(od.`202209利润额`)/sum(od.`202209业绩`),4) '202209利润率' ,round(sum(od.`202209退款金额`),2)'202209退款金额',sum(od.`202209订单`) '202209订单数',

round(sum(od.`202210业绩`),2)'202210销售额',round(sum(od.`202210利润额`),2) '202210利润额',round(sum(od.`202210利润额`)/sum(od.`202210业绩`),4) '202210利润率' ,round(sum(od.`202210退款金额`),2)'202210退款金额',sum(od.`202210订单`) '202210订单数' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`一级类目`,split_part(pc.CategoryPathByChineseName,'>',2)`二级类目`,split_part(pc.CategoryPathByChineseName,'>',3)`三级类目`,split_part(pc.CategoryPathByChineseName,'>',4)`四级类目`,split_part(pc.CategoryPathByChineseName,'>',5)`五级类目`,

`2年业绩`, `2021年业绩`,`2022年业绩`,`202101业绩` ,`202102业绩`,`202103业绩`,`202104业绩`,`202105业绩`,`202106业绩`,`202107业绩`,`202108业绩`,`202109业绩`,`202110业绩`,`202111业绩`,`202112业绩`,`202201业绩`,`202202业绩`,`202203业绩`,`202204业绩`,`202205业绩`,`202206业绩`,`202207业绩`,`202208业绩`,`202209业绩`,`202210业绩`,

`2年利润额`, `2021年利润额`,`2022年利润额`,`202101利润额` ,`202102利润额`,`202103利润额`,`202104利润额`,`202105利润额`,`202106利润额`,`202107利润额`,`202108利润额`,`202109利润额`,`202110利润额`,`202111利润额`,`202112利润额`,`202201利润额`,`202202利润额`,`202203利润额`,`202204利润额`,`202205利润额`,`202206利润额`,`202207利润额`,`202208利润额`,`202209利润额`,`202210利润额`,

`2年退款金额`, `2021年退款金额`,`2022年退款金额`,`202101退款金额` ,`202102退款金额`,`202103退款金额`,`202104退款金额`,`202105退款金额`,`202106退款金额`,`202107退款金额`,`202108退款金额`,`202109退款金额`,`202110退款金额`,`202111退款金额`,`202112退款金额`,`202201退款金额`,`202202退款金额`,`202203退款金额`,`202204退款金额`,`202205退款金额`,`202206退款金额`,`202207退款金额`,`202208退款金额`,`202209退款金额`,`202210退款金额`,

`2年订单数`, `2021年订单数`,`2022年订单数`,`202101订单` ,`202102订单`,`202103订单`,`202104订单`,`202105订单`,`202106订单`,`202107订单`,`202108订单`,`202109订单`,`202110订单`,`202111订单`,`202112订单`,`202201订单`,`202202订单`,`202203订单`,`202204订单`,`202205订单`,`202206订单`,`202207订单`,`202208订单`,`202209订单`,`202210订单`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2年业绩' ,round(sum(GrossProfit)/6.5,1) '2年利润额',round(sum(RefundPrice)/6.5,1) '2年退款金额',count(distinct(ordernumber)) '2年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021年业绩' ,round(sum(GrossProfit)/6.5,1) '2021年利润额',round(sum(RefundPrice)/6.5,1) '2021年退款金额',count(distinct(ordernumber)) '2021年订单数'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022年业绩' ,round(sum(GrossProfit)/6.5,1) '2022年利润额',round(sum(RefundPrice)/6.5,1) '2022年退款金额',count(distinct(ordernumber)) '2022年订单数'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101业绩' ,round(sum(GrossProfit)/6.5,1) '202101利润额',round(sum(RefundPrice)/6.5,1) '202101退款金额',count(distinct(ordernumber)) '202101订单'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102业绩' ,round(sum(GrossProfit)/6.5,1) '202102利润额',round(sum(RefundPrice)/6.5,1) '202102退款金额',count(distinct(ordernumber)) '202102订单'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103业绩' ,round(sum(GrossProfit)/6.5,1) '202103利润额',round(sum(RefundPrice)/6.5,1) '202103退款金额',count(distinct(ordernumber)) '202103订单'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104业绩' ,round(sum(GrossProfit)/6.5,1) '202104利润额',round(sum(RefundPrice)/6.5,1) '202104退款金额',count(distinct(ordernumber)) '202104订单'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105业绩' ,round(sum(GrossProfit)/6.5,1) '202105利润额',round(sum(RefundPrice)/6.5,1) '202105退款金额',count(distinct(ordernumber)) '202105订单'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106业绩' ,round(sum(GrossProfit)/6.5,1) '202106利润额',round(sum(RefundPrice)/6.5,1) '202106退款金额',count(distinct(ordernumber)) '202106订单'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107业绩' ,round(sum(GrossProfit)/6.5,1) '202107利润额',round(sum(RefundPrice)/6.5,1) '202107退款金额',count(distinct(ordernumber)) '202107订单'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108业绩' ,round(sum(GrossProfit)/6.5,1) '202108利润额',round(sum(RefundPrice)/6.5,1) '202108退款金额',count(distinct(ordernumber)) '202108订单'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109业绩' ,round(sum(GrossProfit)/6.5,1) '202109利润额',round(sum(RefundPrice)/6.5,1) '202109退款金额',count(distinct(ordernumber)) '202109订单'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110业绩' ,round(sum(GrossProfit)/6.5,1) '202110利润额',round(sum(RefundPrice)/6.5,1) '202110退款金额',count(distinct(ordernumber)) '202110订单'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111业绩' ,round(sum(GrossProfit)/6.5,1) '202111利润额',round(sum(RefundPrice)/6.5,1) '202111退款金额',count(distinct(ordernumber)) '202111订单'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112业绩' ,round(sum(GrossProfit)/6.5,1) '202112利润额',round(sum(RefundPrice)/6.5,1) '202112退款金额',count(distinct(ordernumber)) '202112订单'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201业绩' ,round(sum(GrossProfit)/6.5,1) '202201利润额',round(sum(RefundPrice)/6.5,1) '202201退款金额',count(distinct(ordernumber)) '202201订单' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202业绩' ,round(sum(GrossProfit)/6.5,1) '202202利润额',round(sum(RefundPrice)/6.5,1) '202202退款金额',count(distinct(ordernumber)) '202202订单'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203业绩' ,round(sum(GrossProfit)/6.5,1) '202203利润额',round(sum(RefundPrice)/6.5,1) '202203退款金额',count(distinct(ordernumber)) '202203订单'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204业绩' ,round(sum(GrossProfit)/6.5,1) '202204利润额',round(sum(RefundPrice)/6.5,1) '202204退款金额',count(distinct(ordernumber)) '202204订单'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205业绩' ,round(sum(GrossProfit)/6.5,1) '202205利润额',round(sum(RefundPrice)/6.5,1) '202205退款金额',count(distinct(ordernumber)) '202205订单'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206业绩' ,round(sum(GrossProfit)/6.5,1) '202206利润额',round(sum(RefundPrice)/6.5,1) '202206退款金额',count(distinct(ordernumber)) '202206订单'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207业绩' ,round(sum(GrossProfit)/6.5,1) '202207利润额',round(sum(RefundPrice)/6.5,1) '202207退款金额',count(distinct(ordernumber)) '202207订单'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208业绩' ,round(sum(GrossProfit)/6.5,1) '202208利润额',round(sum(RefundPrice)/6.5,1) '202208退款金额',count(distinct(ordernumber)) '202208订单'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209业绩' ,round(sum(GrossProfit)/6.5,1) '202209利润额',round(sum(RefundPrice)/6.5,1) '202209退款金额',count(distinct(ordernumber)) '202209订单'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210业绩' ,round(sum(GrossProfit)/6.5,1) '202210利润额',round(sum(RefundPrice)/6.5,1) '202210退款金额',count(distinct(ordernumber)) '202210订单'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目,'>',od.五级类目)) a9

left join

(select concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目,'>',od.五级类目) '三级类目',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2年出单月份',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021年出单月份',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022年出单月份' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`一级类目`,split_part(CategoryPathByChineseName,'>',2)`二级类目`,split_part(CategoryPathByChineseName,'>',3)`三级类目`,split_part(CategoryPathByChineseName,'>',4)`四级类目`,split_part(CategoryPathByChineseName,'>',5)`五级类目`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.一级类目,'>',od.二级类目,'>',od.三级类目,'>',od.四级类目,'>',od.五级类目)) a7

on a9.三级类目=a7.三级类目

order by `2年销售额` desc;











