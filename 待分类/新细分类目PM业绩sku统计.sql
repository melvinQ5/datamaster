/*PMҵ��*/
select  pp.sku, pp.boxsku, pp.ProductName`��Ʒ������`,pp.CreationTime`����ʱ��`,pp.DevelopLastAuditTime`��������ʱ��`,pp.ChangeReasons`ͣ��ԭ��`,wp.TortType`��Ȩ����`,wp.Festival`���ڽ���`,

    pc.CategoryPathByChineseName,concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2)) '������Ŀ',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3)) '������Ŀ',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4)) '�ļ���Ŀ',

    concat(split_part(pc.CategoryPathByChineseName,'>',1),'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4),'>',split_part(pc.CategoryPathByChineseName,'>',5)) '�弶��Ŀ',

	wp.NewCategory `����Ŀ`,pp.IsDeleted`�Ƿ�ɾ��`,pp.ProductStatus`��Ʒ״̬`,wp.IsImportant `�Ƿ��ص�`,

`2����ҵ��`,`2�������`,`2���˿�`,`2���ܶ���`,`21������·�`,`21����ҵ��`,`21�������`,`21���˿�`,`21���ܶ���`,`22������·�`,`22����ҵ��`,`22�������`,

`22���˿�`,`22���ܶ���`,`202101ҵ��`,`202101�����`,`202101���˿���`,`202101����`,`202102ҵ��`,`202102�����`,`202102���˿���`,`202102����`,

`202103ҵ��`,`202103�����`,`202103���˿���`,`202103����`,`202104ҵ��`,`202104�����`,`202104���˿���`,`202104����`,`202105ҵ��`,`202105�����`,`202105���˿���`,`202105����`,

`202106ҵ��`,`202106�����`,`202106���˿���`,`202106����`,`202107ҵ��`,`202107�����`,`202107���˿���`,`202107����`,`202108ҵ��`,`202108�����`,`202108���˿���`,`202108����`,

`202109ҵ��`,`202109�����`,`202109���˿���`,`202109����`,`202110ҵ��`,`202110�����`,`202110���˿���`,`202110����`,`202111ҵ��`,`202111�����`,`202111���˿���`,`202111����`,

`202112ҵ��`,`202112�����`,`202112���˿���`,`202112����`,`202201ҵ��`,`202201�����`,`202201���˿���`,`202201����`,`202202ҵ��`,`202202�����`,`202202���˿���`,`202202����`,

`202203ҵ��`,`202203�����`,`202203���˿���`,`202203����`,`202204ҵ��`,`202204�����`,`202204���˿���`,`202204����`,`202205ҵ��`,`202205�����`,`202205���˿���`,`202205����`,

`202206ҵ��`,`202206�����`,`202206���˿���`,`202206����`,`202207ҵ��`,`202207�����`,`202207���˿���`,`202207����`,`202208ҵ��`,`202208�����`,`202208���˿���`,`202208����`,

`202209ҵ��`,`202209�����`,`202209���˿���`,`202209����`,`202210ҵ��`,`202210�����`,`202210���˿���`,`202210����`

from import_data.erp_product_products pp
left join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId
left join (select distinct Sku, NewCategory, TortType, Festival,IsImportant from import_data.wt_products) wp on pp.SKU = wp.Sku

left join (
SELECT boxsku, round(sum(income)/6.5,0) '2����ҵ��'

	, count(distinct left(PayTime,7)) '�����·�'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-11-01' then GrossProfit end)/6.5, 0 ) '2�������'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-11-01' then RefundPrice end)/6.5, 0 ) '2���˿�'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-11-01' then PlatOrderNumber end ) '2���ܶ���'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-01-01' then left(PayTime,7) end ) '21������·�'

	, round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then income end)/6.5, 0 ) '21����ҵ��'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then GrossProfit end)/6.5, 0 ) '21�������'

    , round( sum(case when paytime >= '2021-01-01' and paytime < '2022-01-01' then RefundPrice end)/6.5, 0 ) '21���˿�'

	, count(distinct case when paytime >= '2021-01-01' and paytime < '2022-01-01' then PlatOrderNumber end ) '21���ܶ���'

	, count(distinct case when paytime >= '2022-01-01' and paytime < '2022-11-01' then left(PayTime,7) end) '22������·�'

	, round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then income end)/6.5, 0 ) '22����ҵ��'

    , round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then GrossProfit end)/6.5, 0 ) '22�������'

    , round( sum(case when paytime >= '2022-01-01' and paytime < '2022-11-01' then RefundPrice end)/6.5, 0 ) '22���˿�'

	, count(distinct case when paytime >= '2022-01-01' and paytime < '2022-11-01' then PlatOrderNumber end ) '22���ܶ���'

from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) tmp1 on tmp1.BoxSKU = pp.boxsku


left join (

SELECT boxsku, round(sum(income)/6.5,0) '202101ҵ��' ,round(sum(GrossProfit)/6.5,0) '202101�����',round(sum(RefundPrice)/6.5,0) '202101���˿���',count(distinct(ordernumber)) '202101����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202102ҵ��' ,round(sum(GrossProfit)/6.5,0) '202102�����',round(sum(RefundPrice)/6.5,0) '202102���˿���',count(distinct(ordernumber)) '202102����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202103ҵ��' ,round(sum(GrossProfit)/6.5,0) '202103�����',round(sum(RefundPrice)/6.5,0) '202103���˿���',count(distinct(ordernumber)) '202103����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202104ҵ��' ,round(sum(GrossProfit)/6.5,0) '202104�����',round(sum(RefundPrice)/6.5,0) '202104���˿���',count(distinct(ordernumber)) '202104����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202105ҵ��' ,round(sum(GrossProfit)/6.5,0) '202105�����',round(sum(RefundPrice)/6.5,0) '202105���˿���',count(distinct(ordernumber)) '202105����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202106ҵ��' ,round(sum(GrossProfit)/6.5,0) '202106�����',round(sum(RefundPrice)/6.5,0) '202106���˿���',count(distinct(ordernumber)) '202106����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202107ҵ��' ,round(sum(GrossProfit)/6.5,0) '202107�����',round(sum(RefundPrice)/6.5,0) '202107���˿���',count(distinct(ordernumber)) '202107����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202108ҵ��' ,round(sum(GrossProfit)/6.5,0) '202108�����',round(sum(RefundPrice)/6.5,0) '202108���˿���',count(distinct(ordernumber)) '202108����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202109ҵ��' ,round(sum(GrossProfit)/6.5,0) '202109�����',round(sum(RefundPrice)/6.5,0) '202109���˿���',count(distinct(ordernumber)) '202109����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202110ҵ��' ,round(sum(GrossProfit)/6.5,0) '202110�����',round(sum(RefundPrice)/6.5,0) '202110���˿���',count(distinct(ordernumber)) '202110����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202111ҵ��' ,round(sum(GrossProfit)/6.5,0) '202111�����',round(sum(RefundPrice)/6.5,0) '202111���˿���',count(distinct(ordernumber)) '202111����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202112ҵ��' ,round(sum(GrossProfit)/6.5,0) '202112�����',round(sum(RefundPrice)/6.5,0) '202112���˿���',count(distinct(ordernumber)) '202112����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202201ҵ��' ,round(sum(GrossProfit)/6.5,0) '202201�����',round(sum(RefundPrice)/6.5,0) '202201���˿���',count(distinct(ordernumber)) '202201����' from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202202ҵ��' ,round(sum(GrossProfit)/6.5,0) '202202�����',round(sum(RefundPrice)/6.5,0) '202202���˿���',count(distinct(ordernumber)) '202202����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202203ҵ��' ,round(sum(GrossProfit)/6.5,0) '202203�����',round(sum(RefundPrice)/6.5,0) '202203���˿���',count(distinct(ordernumber)) '202203����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202204ҵ��' ,round(sum(GrossProfit)/6.5,0) '202204�����',round(sum(RefundPrice)/6.5,0) '202204���˿���',count(distinct(ordernumber)) '202204����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202205ҵ��' ,round(sum(GrossProfit)/6.5,0) '202205�����',round(sum(RefundPrice)/6.5,0) '202205���˿���',count(distinct(ordernumber)) '202205����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,0) '202206ҵ��' ,round(sum(GrossProfit)/6.5,0) '202206�����',round(sum(RefundPrice)/6.5,0) '202206���˿���',count(distinct(ordernumber)) '202206����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202207ҵ��' ,round(sum(GrossProfit)/6.5,0) '202207�����',round(sum(RefundPrice)/6.5,0) '202207���˿���',count(distinct(ordernumber)) '202207����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202208ҵ��' ,round(sum(GrossProfit)/6.5,0) '202208�����',round(sum(RefundPrice)/6.5,0) '202208���˿���',count(distinct(ordernumber)) '202208����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202209ҵ��' ,round(sum(GrossProfit)/6.5,0) '202209�����',round(sum(RefundPrice)/6.5,0) '202209���˿���',count(distinct(ordernumber)) '202209����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,0) '202210ҵ��' ,round(sum(GrossProfit)/6.5,0) '202210�����',round(sum(RefundPrice)/6.5,0) '202210���˿���',count(distinct(ordernumber)) '202210����'from import_data.OrderProfitSettle

join import_data.mysql_store ms on OrderProfitSettle.ShopIrobotId = ms.Code and ms.Department in ('���۶���','��������')

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null

order by 2����ҵ�� desc;



-- left join

-- (

-- 	SELECT a8.sku,a8.boxsku,GROUP_CONCAT(a8.torttype_name) alltype from

-- 	(

-- 	select *,

-- 	case torttype

-- 	when 1 then '��Ȩ��Ȩ'

-- 	when 2 then '�̱���Ȩ'

-- 	when 3 then 'ר����Ȩ'

-- 	when 4 then 'Υ��Ʒ'

-- 	when 5 then '����Ȩ'

-- 	when 6 then '������Ȩ'

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

-- select pp.sku,GROUP_CONCAT(psf.name) `����`

-- from import_data.erp_product_products pp

-- join (select distinct(ProductId), SeasonsAndFestivalsId from import_data.erp_product_product_associated_seasons_and_festivals) asf on asf.ProductId = pp.id

-- join import_data.erp_product_product_seasons_and_festivals psf on psf.id = asf.SeasonsAndFestivalsId

-- group by pp.sku

-- ) psftotal on psftotal.sku=pp.sku
-- left join
-- (select boxsku,spu'����Ŀ'from import_data.JinqinSku new1) a9 on a9.boxsku=pp.boxsku 