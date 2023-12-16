/*PM业绩*/
select  pp.sku, pp.boxsku, pp.ProductName`产品中文名`,pp.CreationTime`创建时间`,pp.DevelopLastAuditTime`开发终审时间`,pp.ChangeReasons`停产原因`,wp.TortType`侵权类型`,wp.Festival`季节节日`,

    pc.CategoryPathByChineseName,concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2)) '二级类目',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3)) '三级类目',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4)) '四级类目',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4),'>',split_part(pc.CategoryPathByChineseName,'>',5)) '五级类目',

	wp.NewCategory `新类目`,pp.IsDeleted`是否删除`,pp.ProductStatus`产品状态`,wp.IsImportant `是否重点`,

`2年总业绩`,`2年利润额`,`2年退款`,`2年总订单`,`21年出单月份`,`21年总业绩`,`21年利润额`,`21年退款`,`21年总订单`,`22年出单月份`,`22年总业绩`,`22年利润额`,

`22年退款`,`22年总订单`,`202101业绩`,`202101利润额`,`202101年退款金额`,`202101订单`,`202102业绩`,`202102利润额`,`202102年退款金额`,`202102订单`,

`202103业绩`,`202103利润额`,`202103年退款金额`,`202103订单`,`202104业绩`,`202104利润额`,`202104年退款金额`,`202104订单`,`202105业绩`,`202105利润额`,`202105年退款金额`,`202105订单`,

`202106业绩`,`202106利润额`,`202106年退款金额`,`202106订单`,`202107业绩`,`202107利润额`,`202107年退款金额`,`202107订单`,`202108业绩`,`202108利润额`,`202108年退款金额`,`202108订单`,

`202109业绩`,`202109利润额`,`202109年退款金额`,`202109订单`,`202110业绩`,`202110利润额`,`202110年退款金额`,`202110订单`,`202111业绩`,`202111利润额`,`202111年退款金额`,`202111订单`,

`202112业绩`,`202112利润额`,`202112年退款金额`,`202112订单`,`202201业绩`,`202201利润额`,`202201年退款金额`,`202201订单`,`202202业绩`,`202202利润额`,`202202年退款金额`,`202202订单`,

`202203业绩`,`202203利润额`,`202203年退款金额`,`202203订单`,`202204业绩`,`202204利润额`,`202204年退款金额`,`202204订单`,`202205业绩`,`202205利润额`,`202205年退款金额`,`202205订单`,

`202206业绩`,`202206利润额`,`202206年退款金额`,`202206订单`,`202207业绩`,`202207利润额`,`202207年退款金额`,`202207订单`,`202208业绩`,`202208利润额`,`202208年退款金额`,`202208订单`,

`202209业绩`,`202209利润额`,`202209年退款金额`,`202209订单`,`202210业绩`,`202210利润额`,`202210年退款金额`,`202210订单`

from import_data.erp_product_products pp
left join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId
left join (select distinct Sku, NewCategory, TortType, Festival,IsImportant from import_data.wt_products) wp on pp.SKU = wp.Sku

left join (
SELECT boxsku, round(sum(income)/6.5,0) '2年总业绩'

	, count(distinct left(PayTime,7)) '出单月份'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-11-01' then GrossProfit end)/6.5, 0 ) '2年利润额'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-11-01' then RefundPrice end)/6.5, 0 ) '2年退款'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-11-01' then PlatOrderNumber end ) '2年总订单'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-01-01' then left(PayTime,7) end ) '21年出单月份'

	, round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then income end)/6.5, 0 ) '21年总业绩'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then GrossProfit end)/6.5, 0 ) '21年利润额'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then RefundPrice end)/6.5, 0 ) '21年退款'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-01-01' then PlatOrderNumber end ) '21年总订单'

	, count(distinct case when paytime >= '2022-01-01' and paytime < '2022-11-01' then left(PayTime,7) end) '22年出单月份'

	, round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then income end)/6.5, 0 ) '22年总业绩'

    , round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then GrossProfit end)/6.5, 0 ) '22年利润额'

    , round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then RefundPrice end)/6.5, 0 ) '22年退款'

	, count(distinct case when paytime >= '2022-01-01' and paytime < '2022-11-01' then PlatOrderNumber end ) '22年总订单'

from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) tmp1 on tmp1.BoxSKU = pp.boxsku


left join (

SELECT boxsku, round(sum(income)/6.5,0) '202101业绩' ,round(sum(GrossProfit)/6.5,0) '202101利润额',round(sum(RefundPrice)/6.5,0) '202101年退款金额',count(distinct(ordernumber)) '202101订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202102业绩' ,round(sum(GrossProfit)/6.5,0) '202102利润额',round(sum(RefundPrice)/6.5,0) '202102年退款金额',count(distinct(ordernumber)) '202102订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202103业绩' ,round(sum(GrossProfit)/6.5,0) '202103利润额',round(sum(RefundPrice)/6.5,0) '202103年退款金额',count(distinct(ordernumber)) '202103订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202104业绩' ,round(sum(GrossProfit)/6.5,0) '202104利润额',round(sum(RefundPrice)/6.5,0) '202104年退款金额',count(distinct(ordernumber)) '202104订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202105业绩' ,round(sum(GrossProfit)/6.5,0) '202105利润额',round(sum(RefundPrice)/6.5,0) '202105年退款金额',count(distinct(ordernumber)) '202105订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202106业绩' ,round(sum(GrossProfit)/6.5,0) '202106利润额',round(sum(RefundPrice)/6.5,0) '202106年退款金额',count(distinct(ordernumber)) '202106订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202107业绩' ,round(sum(GrossProfit)/6.5,0) '202107利润额',round(sum(RefundPrice)/6.5,0) '202107年退款金额',count(distinct(ordernumber)) '202107订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202108业绩' ,round(sum(GrossProfit)/6.5,0) '202108利润额',round(sum(RefundPrice)/6.5,0) '202108年退款金额',count(distinct(ordernumber)) '202108订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202109业绩' ,round(sum(GrossProfit)/6.5,0) '202109利润额',round(sum(RefundPrice)/6.5,0) '202109年退款金额',count(distinct(ordernumber)) '202109订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202110业绩' ,round(sum(GrossProfit)/6.5,0) '202110利润额',round(sum(RefundPrice)/6.5,0) '202110年退款金额',count(distinct(ordernumber)) '202110订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202111业绩' ,round(sum(GrossProfit)/6.5,0) '202111利润额',round(sum(RefundPrice)/6.5,0) '202111年退款金额',count(distinct(ordernumber)) '202111订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202112业绩' ,round(sum(GrossProfit)/6.5,0) '202112利润额',round(sum(RefundPrice)/6.5,0) '202112年退款金额',count(distinct(ordernumber)) '202112订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202201业绩' ,round(sum(GrossProfit)/6.5,0) '202201利润额',round(sum(RefundPrice)/6.5,0) '202201年退款金额',count(distinct(ordernumber)) '202201订单' from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202202业绩' ,round(sum(GrossProfit)/6.5,0) '202202利润额',round(sum(RefundPrice)/6.5,0) '202202年退款金额',count(distinct(ordernumber)) '202202订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202203业绩' ,round(sum(GrossProfit)/6.5,0) '202203利润额',round(sum(RefundPrice)/6.5,0) '202203年退款金额',count(distinct(ordernumber)) '202203订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202204业绩' ,round(sum(GrossProfit)/6.5,0) '202204利润额',round(sum(RefundPrice)/6.5,0) '202204年退款金额',count(distinct(ordernumber)) '202204订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202205业绩' ,round(sum(GrossProfit)/6.5,0) '202205利润额',round(sum(RefundPrice)/6.5,0) '202205年退款金额',count(distinct(ordernumber)) '202205订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202206业绩' ,round(sum(GrossProfit)/6.5,0) '202206利润额',round(sum(RefundPrice)/6.5,0) '202206年退款金额',count(distinct(ordernumber)) '202206订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202207业绩' ,round(sum(GrossProfit)/6.5,0) '202207利润额',round(sum(RefundPrice)/6.5,0) '202207年退款金额',count(distinct(ordernumber)) '202207订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202208业绩' ,round(sum(GrossProfit)/6.5,0) '202208利润额',round(sum(RefundPrice)/6.5,0) '202208年退款金额',count(distinct(ordernumber)) '202208订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202209业绩' ,round(sum(GrossProfit)/6.5,0) '202209利润额',round(sum(RefundPrice)/6.5,0) '202209年退款金额',count(distinct(ordernumber)) '202209订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202210业绩' ,round(sum(GrossProfit)/6.5,0) '202210利润额',round(sum(RefundPrice)/6.5,0) '202210年退款金额',count(distinct(ordernumber)) '202210订单'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('销售二部','销售三部')

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null

order by 2年总业绩 desc;



-- left join

-- (

-- 	SELECT a8.sku,a8.boxsku,GROUP_CONCAT(a8.torttype_name) alltype from

-- 	(

-- 	select *,

-- 	case torttype

-- 	when 1 then '版权侵权'

-- 	when 2 then '商标侵权'

-- 	when 3 then '专利侵权'

-- 	when 4 then '违禁品'

-- 	when 5 then '不侵权'

-- 	when 6 then '律所侵权'

-- 	end torttype_name

--

-- 	FROM import_data.erp_product_product_tort_types pt

-- 	join import_data.erp_product_products pp on pp.id=pt.ProductId

-- 	where pp.sku is not null

-- 	)a8

--

-- 	group by a8.sku,a8.boxsku

-- )property on property.boxsku=pp.boxsku



-- left join

-- (

-- select pp.sku,GROUP_CONCAT(psf.name) `季节`

-- from import_data.erp_product_products pp

-- join (select distinct(ProductId), SeasonsAndFestivalsId from import_data.erp_product_product_associated_seasons_and_festivals) asf on asf.ProductId = pp.id

-- join import_data.erp_product_product_seasons_and_festivals psf on psf.id = asf.SeasonsAndFestivalsId

-- group by pp.sku

-- ) psftotal on psftotal.sku=pp.sku
-- left join
-- (select boxsku,spu'新类目'from import_data.JinqinSku new1) a9 on a9.boxsku=pp.boxsku 