/*ϸ����Ŀ-���в���*/

select a9.������Ŀ,a9.SKU��, a7.`2������·�`,`2�����۶�`, `2�������`, `2��������`, `2���˿���`, `2�궩����`, a7.`2021������·�`,`2021�����۶�`, `2021�������`, `2021��������`, `2021���˿���`, `2021�궩����`,a7.`2022������·�` ,`2022�����۶�`, `2022�������`, `2022��������`, `2022���˿���`, `2022�궩����`, `202101���۶�`, `202101�����`, `202101������`, `202101�˿���`, `202101������`, `202102���۶�`, `202102�����`, `202102������`, `202102�˿���`, `202102������`, `202103���۶�`, `202103�����`, `202103������`, `202103�˿���`, `202103������`, `202104���۶�`, `202104�����`, `202104������`, `202104�˿���`, `202104������`, `202105���۶�`, `202105�����`, `202105������`, `202105�˿���`, `202105������`, `202106���۶�`, `202106�����`, `202106������`, `202106�˿���`, `202106������`, `202107���۶�`, `202107�����`, `202107������`, `202107�˿���`, `202107������`, `202108���۶�`, `202108�����`, `202108������`, `202108�˿���`, `202108������`, `202109���۶�`, `202109�����`, `202109������`, `202109�˿���`, `202109������`, `202110���۶�`, `202110�����`, `202110������`, `202110�˿���`, `202110������`, `202111���۶�`, `202111�����`, `202111������`, `202111�˿���`, `202111������`, `202112���۶�`, `202112�����`, `202112������`, `202112�˿���`, `202112������`, `202201���۶�`, `202201�����`, `202201������`, `202201�˿���`, `202201������`, `202202���۶�`, `202202�����`, `202202������`, `202202�˿���`, `202202������`, `202203���۶�`, `202203�����`, `202203������`, `202203�˿���`, `202203������`, `202204���۶�`, `202204�����`, `202204������`, `202204�˿���`, `202204������`, `202205���۶�`, `202205�����`, `202205������`, `202205�˿���`, `202205������`, `202206���۶�`, `202206�����`, `202206������`, `202206�˿���`, `202206������`, `202207���۶�`, `202207�����`, `202207������`, `202207�˿���`, `202207������`, `202208���۶�`, `202208�����`, `202208������`, `202208�˿���`, `202208������`, `202209���۶�`, `202209�����`, `202209������`, `202209�˿���`, `202209������`, `202210���۶�`, `202210�����`, `202210������`, `202210�˿���`, `202210������` from

(select concat(od.һ����Ŀ,'>',od.������Ŀ) as '������Ŀ',count(distinct SKU) 'SKU��',

round(sum(od.`2��ҵ��`),2)'2�����۶�',round(sum(od.`2�������`),2) '2�������',round(sum(od.`2�������`)/sum(od.`2��ҵ��`),4) '2��������' ,round(sum(od.`2���˿���`),2)'2���˿���',sum(od.`2�궩����`) '2�궩����',

round(sum(od.`2021��ҵ��`),2)'2021�����۶�',round(sum(od.`2021�������`),2) '2021�������',round(sum(od.`2021�������`)/sum(od.`2021��ҵ��`),4) '2021��������' ,round(sum(od.`2021���˿���`),2)'2021���˿���',sum(od.`2021�궩����`) '2021�궩����',

round(sum(od.`2022��ҵ��`),2)'2022�����۶�',round(sum(od.`2022�������`),2) '2022�������',round(sum(od.`2022�������`)/sum(od.`2022��ҵ��`),4) '2022��������' ,round(sum(od.`2022���˿���`),2)'2022���˿���',sum(od.`2022�궩����`) '2022�궩����',

round(sum(od.`202101ҵ��`),2)'202101���۶�',round(sum(od.`202101�����`),2) '202101�����',round(sum(od.`202101�����`)/sum(od.`202101ҵ��`),4) '202101������' ,round(sum(od.`202101�˿���`),2)'202101�˿���',sum(od.`202101����`) '202101������',

round(sum(od.`202102ҵ��`),2)'202102���۶�',round(sum(od.`202102�����`),2) '202102�����',round(sum(od.`202102�����`)/sum(od.`202102ҵ��`),4) '202102������' , round(sum(od.`202102�˿���`),2)'202102�˿���',sum(od.`202102����`) '202102������',

round(sum(od.`202103ҵ��`),2)'202103���۶�',round(sum(od.`202103�����`),2) '202103�����',round(sum(od.`202103�����`)/sum(od.`202103ҵ��`),4) '202103������' ,round(sum(od.`202103�˿���`),2)'202103�˿���',sum(od.`202103����`) '202103������',

round(sum(od.`202104ҵ��`),2)'202104���۶�',round(sum(od.`202104�����`),2) '202104�����',round(sum(od.`202104�����`)/sum(od.`202104ҵ��`),4) '202104������' ,round(sum(od.`202104�˿���`),2)'202104�˿���',sum(od.`202104����`) '202104������',

round(sum(od.`202105ҵ��`),2)'202105���۶�',round(sum(od.`202105�����`),2) '202105�����',round(sum(od.`202105�����`)/sum(od.`202105ҵ��`),4) '202105������' ,round(sum(od.`202105�˿���`),2)'202105�˿���',sum(od.`202105����`) '202105������',

round(sum(od.`202106ҵ��`),2)'202106���۶�',round(sum(od.`202106�����`),2) '202106�����',round(sum(od.`202106�����`)/sum(od.`202106ҵ��`),4) '202106������' ,round(sum(od.`202106�˿���`),2)'202106�˿���',sum(od.`202106����`) '202106������',

round(sum(od.`202107ҵ��`),2)'202107���۶�',round(sum(od.`202107�����`),2) '202107�����',round(sum(od.`202107�����`)/sum(od.`202107ҵ��`),4) '202107������' ,round(sum(od.`202107�˿���`),2)'202107�˿���',sum(od.`202107����`) '202107������',

round(sum(od.`202108ҵ��`),2)'202108���۶�',round(sum(od.`202108�����`),2) '202108�����',round(sum(od.`202108�����`)/sum(od.`202108ҵ��`),4) '202108������' ,round(sum(od.`202108�˿���`),2)'202108�˿���',sum(od.`202108����`) '202108������',

round(sum(od.`202109ҵ��`),2)'202109���۶�',round(sum(od.`202109�����`),2) '202109�����',round(sum(od.`202109�����`)/sum(od.`202109ҵ��`),4) '202109������' ,round(sum(od.`202109�˿���`),2)'202109�˿���',sum(od.`202109����`) '202109������',

round(sum(od.`202110ҵ��`),2)'202110���۶�',round(sum(od.`202110�����`),2) '202110�����',round(sum(od.`202110�����`)/sum(od.`202110ҵ��`),4) '202110������' ,round(sum(od.`202110�˿���`),2)'202110�˿���',sum(od.`202110����`) '202110������',

round(sum(od.`202111ҵ��`),2)'202111���۶�',round(sum(od.`202111�����`),2) '202111�����',round(sum(od.`202111�����`)/sum(od.`202111ҵ��`),4) '202111������' ,round(sum(od.`202111�˿���`),2)'202111�˿���',sum(od.`202111����`) '202111������',

round(sum(od.`202112ҵ��`),2)'202112���۶�',round(sum(od.`202112�����`),2) '202112�����',round(sum(od.`202112�����`)/sum(od.`202112ҵ��`),4) '202112������' ,round(sum(od.`202112�˿���`),2)'202112�˿���',sum(od.`202112����`) '202112������',

round(sum(od.`202201ҵ��`),2)'202201���۶�',round(sum(od.`202201�����`),2) '202201�����',round(sum(od.`202201�����`)/sum(od.`202201ҵ��`),4) '202201������' ,round(sum(od.`202201�˿���`),2)'202201�˿���',sum(od.`202201����`) '202201������',

round(sum(od.`202202ҵ��`),2)'202202���۶�',round(sum(od.`202202�����`),2) '202202�����',round(sum(od.`202202�����`)/sum(od.`202202ҵ��`),4) '202202������' ,round(sum(od.`202202�˿���`),2)'202202�˿���',sum(od.`202202����`) '202202������',

round(sum(od.`202203ҵ��`),2)'202203���۶�',round(sum(od.`202203�����`),2) '202203�����',round(sum(od.`202203�����`)/sum(od.`202203ҵ��`),4) '202203������' ,round(sum(od.`202203�˿���`),2)'202203�˿���',sum(od.`202203����`) '202203������',

round(sum(od.`202204ҵ��`),2)'202204���۶�',round(sum(od.`202204�����`),2) '202204�����',round(sum(od.`202204�����`)/sum(od.`202204ҵ��`),4) '202204������' ,round(sum(od.`202204�˿���`),2)'202204�˿���',sum(od.`202204����`) '202204������',

round(sum(od.`202205ҵ��`),2)'202205���۶�',round(sum(od.`202205�����`),2) '202205�����',round(sum(od.`202205�����`)/sum(od.`202205ҵ��`),4) '202205������' ,round(sum(od.`202205�˿���`),2)'202205�˿���',sum(od.`202205����`) '202205������',

round(sum(od.`202206ҵ��`),2)'202206���۶�',round(sum(od.`202206�����`),2) '202206�����',round(sum(od.`202206�����`)/sum(od.`202206ҵ��`),4) '202206������' ,round(sum(od.`202206�˿���`),2)'202206�˿���',sum(od.`202206����`) '202206������',

round(sum(od.`202207ҵ��`),2)'202207���۶�',round(sum(od.`202207�����`),2) '202207�����',round(sum(od.`202207�����`)/sum(od.`202207ҵ��`),4) '202207������' ,round(sum(od.`202207�˿���`),2)'202207�˿���',sum(od.`202207����`) '202207������',

round(sum(od.`202208ҵ��`),2)'202208���۶�',round(sum(od.`202208�����`),2) '202208�����',round(sum(od.`202208�����`)/sum(od.`202208ҵ��`),4) '202208������' ,round(sum(od.`202208�˿���`),2)'202208�˿���',sum(od.`202208����`) '202208������',

round(sum(od.`202209ҵ��`),2)'202209���۶�',round(sum(od.`202209�����`),2) '202209�����',round(sum(od.`202209�����`)/sum(od.`202209ҵ��`),4) '202209������' ,round(sum(od.`202209�˿���`),2)'202209�˿���',sum(od.`202209����`) '202209������',

round(sum(od.`202210ҵ��`),2)'202210���۶�',round(sum(od.`202210�����`),2) '202210�����',round(sum(od.`202210�����`)/sum(od.`202210ҵ��`),4) '202210������' ,round(sum(od.`202210�˿���`),2)'202210�˿���',sum(od.`202210����`) '202210������' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(pc.CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(pc.CategoryPathByChineseName,'>',5)`�弶��Ŀ`,

`2��ҵ��`, `2021��ҵ��`,`2022��ҵ��`,`202101ҵ��` ,`202102ҵ��`,`202103ҵ��`,`202104ҵ��`,`202105ҵ��`,`202106ҵ��`,`202107ҵ��`,`202108ҵ��`,`202109ҵ��`,`202110ҵ��`,`202111ҵ��`,`202112ҵ��`,`202201ҵ��`,`202202ҵ��`,`202203ҵ��`,`202204ҵ��`,`202205ҵ��`,`202206ҵ��`,`202207ҵ��`,`202208ҵ��`,`202209ҵ��`,`202210ҵ��`,

`2�������`, `2021�������`,`2022�������`,`202101�����` ,`202102�����`,`202103�����`,`202104�����`,`202105�����`,`202106�����`,`202107�����`,`202108�����`,`202109�����`,`202110�����`,`202111�����`,`202112�����`,`202201�����`,`202202�����`,`202203�����`,`202204�����`,`202205�����`,`202206�����`,`202207�����`,`202208�����`,`202209�����`,`202210�����`,

`2���˿���`, `2021���˿���`,`2022���˿���`,`202101�˿���` ,`202102�˿���`,`202103�˿���`,`202104�˿���`,`202105�˿���`,`202106�˿���`,`202107�˿���`,`202108�˿���`,`202109�˿���`,`202110�˿���`,`202111�˿���`,`202112�˿���`,`202201�˿���`,`202202�˿���`,`202203�˿���`,`202204�˿���`,`202205�˿���`,`202206�˿���`,`202207�˿���`,`202208�˿���`,`202209�˿���`,`202210�˿���`,

`2�궩����`, `2021�궩����`,`2022�궩����`,`202101����` ,`202102����`,`202103����`,`202104����`,`202105����`,`202106����`,`202107����`,`202108����`,`202109����`,`202110����`,`202111����`,`202112����`,`202201����`,`202202����`,`202203����`,`202204����`,`202205����`,`202206����`,`202207����`,`202208����`,`202209����`,`202210����`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2�������',round(sum(RefundPrice)/6.5,1) '2���˿���',count(distinct(ordernumber)) '2�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2021�������',round(sum(RefundPrice)/6.5,1) '2021���˿���',count(distinct(ordernumber)) '2021�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2022�������',round(sum(RefundPrice)/6.5,1) '2022���˿���',count(distinct(ordernumber)) '2022�궩����'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101ҵ��' ,round(sum(GrossProfit)/6.5,1) '202101�����',round(sum(RefundPrice)/6.5,1) '202101�˿���',count(distinct(ordernumber)) '202101����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102ҵ��' ,round(sum(GrossProfit)/6.5,1) '202102�����',round(sum(RefundPrice)/6.5,1) '202102�˿���',count(distinct(ordernumber)) '202102����'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103ҵ��' ,round(sum(GrossProfit)/6.5,1) '202103�����',round(sum(RefundPrice)/6.5,1) '202103�˿���',count(distinct(ordernumber)) '202103����'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104ҵ��' ,round(sum(GrossProfit)/6.5,1) '202104�����',round(sum(RefundPrice)/6.5,1) '202104�˿���',count(distinct(ordernumber)) '202104����'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105ҵ��' ,round(sum(GrossProfit)/6.5,1) '202105�����',round(sum(RefundPrice)/6.5,1) '202105�˿���',count(distinct(ordernumber)) '202105����'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106ҵ��' ,round(sum(GrossProfit)/6.5,1) '202106�����',round(sum(RefundPrice)/6.5,1) '202106�˿���',count(distinct(ordernumber)) '202106����'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107ҵ��' ,round(sum(GrossProfit)/6.5,1) '202107�����',round(sum(RefundPrice)/6.5,1) '202107�˿���',count(distinct(ordernumber)) '202107����'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108ҵ��' ,round(sum(GrossProfit)/6.5,1) '202108�����',round(sum(RefundPrice)/6.5,1) '202108�˿���',count(distinct(ordernumber)) '202108����'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109ҵ��' ,round(sum(GrossProfit)/6.5,1) '202109�����',round(sum(RefundPrice)/6.5,1) '202109�˿���',count(distinct(ordernumber)) '202109����'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110ҵ��' ,round(sum(GrossProfit)/6.5,1) '202110�����',round(sum(RefundPrice)/6.5,1) '202110�˿���',count(distinct(ordernumber)) '202110����'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111ҵ��' ,round(sum(GrossProfit)/6.5,1) '202111�����',round(sum(RefundPrice)/6.5,1) '202111�˿���',count(distinct(ordernumber)) '202111����'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112ҵ��' ,round(sum(GrossProfit)/6.5,1) '202112�����',round(sum(RefundPrice)/6.5,1) '202112�˿���',count(distinct(ordernumber)) '202112����'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201ҵ��' ,round(sum(GrossProfit)/6.5,1) '202201�����',round(sum(RefundPrice)/6.5,1) '202201�˿���',count(distinct(ordernumber)) '202201����' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202ҵ��' ,round(sum(GrossProfit)/6.5,1) '202202�����',round(sum(RefundPrice)/6.5,1) '202202�˿���',count(distinct(ordernumber)) '202202����'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203ҵ��' ,round(sum(GrossProfit)/6.5,1) '202203�����',round(sum(RefundPrice)/6.5,1) '202203�˿���',count(distinct(ordernumber)) '202203����'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204ҵ��' ,round(sum(GrossProfit)/6.5,1) '202204�����',round(sum(RefundPrice)/6.5,1) '202204�˿���',count(distinct(ordernumber)) '202204����'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205ҵ��' ,round(sum(GrossProfit)/6.5,1) '202205�����',round(sum(RefundPrice)/6.5,1) '202205�˿���',count(distinct(ordernumber)) '202205����'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206ҵ��' ,round(sum(GrossProfit)/6.5,1) '202206�����',round(sum(RefundPrice)/6.5,1) '202206�˿���',count(distinct(ordernumber)) '202206����'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207ҵ��' ,round(sum(GrossProfit)/6.5,1) '202207�����',round(sum(RefundPrice)/6.5,1) '202207�˿���',count(distinct(ordernumber)) '202207����'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208ҵ��' ,round(sum(GrossProfit)/6.5,1) '202208�����',round(sum(RefundPrice)/6.5,1) '202208�˿���',count(distinct(ordernumber)) '202208����'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209ҵ��' ,round(sum(GrossProfit)/6.5,1) '202209�����',round(sum(RefundPrice)/6.5,1) '202209�˿���',count(distinct(ordernumber)) '202209����'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210ҵ��' ,round(sum(GrossProfit)/6.5,1) '202210�����',round(sum(RefundPrice)/6.5,1) '202210�˿���',count(distinct(ordernumber)) '202210����'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.һ����Ŀ,'>',od.������Ŀ)) a9

left join

(select concat(od.һ����Ŀ,'>',od.������Ŀ) '������Ŀ',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2������·�',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021������·�',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022������·�' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(CategoryPathByChineseName,'>',5)`�弶��Ŀ`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.һ����Ŀ,'>',od.������Ŀ)) a7

on a9.������Ŀ=a7.������Ŀ

order by `2�����۶�` desc;





/*������Ŀ*/

/*ϸ����Ŀ-���в���*/

select a9.������Ŀ,a9.SKU��, a7.`2������·�`,`2�����۶�`, `2�������`, `2��������`, `2���˿���`, `2�궩����`, a7.`2021������·�`,`2021�����۶�`, `2021�������`, `2021��������`, `2021���˿���`, `2021�궩����`,a7.`2022������·�` ,`2022�����۶�`, `2022�������`, `2022��������`, `2022���˿���`, `2022�궩����`, `202101���۶�`, `202101�����`, `202101������`, `202101�˿���`, `202101������`, `202102���۶�`, `202102�����`, `202102������`, `202102�˿���`, `202102������`, `202103���۶�`, `202103�����`, `202103������`, `202103�˿���`, `202103������`, `202104���۶�`, `202104�����`, `202104������`, `202104�˿���`, `202104������`, `202105���۶�`, `202105�����`, `202105������`, `202105�˿���`, `202105������`, `202106���۶�`, `202106�����`, `202106������`, `202106�˿���`, `202106������`, `202107���۶�`, `202107�����`, `202107������`, `202107�˿���`, `202107������`, `202108���۶�`, `202108�����`, `202108������`, `202108�˿���`, `202108������`, `202109���۶�`, `202109�����`, `202109������`, `202109�˿���`, `202109������`, `202110���۶�`, `202110�����`, `202110������`, `202110�˿���`, `202110������`, `202111���۶�`, `202111�����`, `202111������`, `202111�˿���`, `202111������`, `202112���۶�`, `202112�����`, `202112������`, `202112�˿���`, `202112������`, `202201���۶�`, `202201�����`, `202201������`, `202201�˿���`, `202201������`, `202202���۶�`, `202202�����`, `202202������`, `202202�˿���`, `202202������`, `202203���۶�`, `202203�����`, `202203������`, `202203�˿���`, `202203������`, `202204���۶�`, `202204�����`, `202204������`, `202204�˿���`, `202204������`, `202205���۶�`, `202205�����`, `202205������`, `202205�˿���`, `202205������`, `202206���۶�`, `202206�����`, `202206������`, `202206�˿���`, `202206������`, `202207���۶�`, `202207�����`, `202207������`, `202207�˿���`, `202207������`, `202208���۶�`, `202208�����`, `202208������`, `202208�˿���`, `202208������`, `202209���۶�`, `202209�����`, `202209������`, `202209�˿���`, `202209������`, `202210���۶�`, `202210�����`, `202210������`, `202210�˿���`, `202210������` from

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ) as '������Ŀ',count(distinct SKU) 'SKU��',

round(sum(od.`2��ҵ��`),2)'2�����۶�',round(sum(od.`2�������`),2) '2�������',round(sum(od.`2�������`)/sum(od.`2��ҵ��`),4) '2��������' ,round(sum(od.`2���˿���`),2)'2���˿���',sum(od.`2�궩����`) '2�궩����',

round(sum(od.`2021��ҵ��`),2)'2021�����۶�',round(sum(od.`2021�������`),2) '2021�������',round(sum(od.`2021�������`)/sum(od.`2021��ҵ��`),4) '2021��������' ,round(sum(od.`2021���˿���`),2)'2021���˿���',sum(od.`2021�궩����`) '2021�궩����',

round(sum(od.`2022��ҵ��`),2)'2022�����۶�',round(sum(od.`2022�������`),2) '2022�������',round(sum(od.`2022�������`)/sum(od.`2022��ҵ��`),4) '2022��������' ,round(sum(od.`2022���˿���`),2)'2022���˿���',sum(od.`2022�궩����`) '2022�궩����',

round(sum(od.`202101ҵ��`),2)'202101���۶�',round(sum(od.`202101�����`),2) '202101�����',round(sum(od.`202101�����`)/sum(od.`202101ҵ��`),4) '202101������' ,round(sum(od.`202101�˿���`),2)'202101�˿���',sum(od.`202101����`) '202101������',

round(sum(od.`202102ҵ��`),2)'202102���۶�',round(sum(od.`202102�����`),2) '202102�����',round(sum(od.`202102�����`)/sum(od.`202102ҵ��`),4) '202102������' , round(sum(od.`202102�˿���`),2)'202102�˿���',sum(od.`202102����`) '202102������',

round(sum(od.`202103ҵ��`),2)'202103���۶�',round(sum(od.`202103�����`),2) '202103�����',round(sum(od.`202103�����`)/sum(od.`202103ҵ��`),4) '202103������' ,round(sum(od.`202103�˿���`),2)'202103�˿���',sum(od.`202103����`) '202103������',

round(sum(od.`202104ҵ��`),2)'202104���۶�',round(sum(od.`202104�����`),2) '202104�����',round(sum(od.`202104�����`)/sum(od.`202104ҵ��`),4) '202104������' ,round(sum(od.`202104�˿���`),2)'202104�˿���',sum(od.`202104����`) '202104������',

round(sum(od.`202105ҵ��`),2)'202105���۶�',round(sum(od.`202105�����`),2) '202105�����',round(sum(od.`202105�����`)/sum(od.`202105ҵ��`),4) '202105������' ,round(sum(od.`202105�˿���`),2)'202105�˿���',sum(od.`202105����`) '202105������',

round(sum(od.`202106ҵ��`),2)'202106���۶�',round(sum(od.`202106�����`),2) '202106�����',round(sum(od.`202106�����`)/sum(od.`202106ҵ��`),4) '202106������' ,round(sum(od.`202106�˿���`),2)'202106�˿���',sum(od.`202106����`) '202106������',

round(sum(od.`202107ҵ��`),2)'202107���۶�',round(sum(od.`202107�����`),2) '202107�����',round(sum(od.`202107�����`)/sum(od.`202107ҵ��`),4) '202107������' ,round(sum(od.`202107�˿���`),2)'202107�˿���',sum(od.`202107����`) '202107������',

round(sum(od.`202108ҵ��`),2)'202108���۶�',round(sum(od.`202108�����`),2) '202108�����',round(sum(od.`202108�����`)/sum(od.`202108ҵ��`),4) '202108������' ,round(sum(od.`202108�˿���`),2)'202108�˿���',sum(od.`202108����`) '202108������',

round(sum(od.`202109ҵ��`),2)'202109���۶�',round(sum(od.`202109�����`),2) '202109�����',round(sum(od.`202109�����`)/sum(od.`202109ҵ��`),4) '202109������' ,round(sum(od.`202109�˿���`),2)'202109�˿���',sum(od.`202109����`) '202109������',

round(sum(od.`202110ҵ��`),2)'202110���۶�',round(sum(od.`202110�����`),2) '202110�����',round(sum(od.`202110�����`)/sum(od.`202110ҵ��`),4) '202110������' ,round(sum(od.`202110�˿���`),2)'202110�˿���',sum(od.`202110����`) '202110������',

round(sum(od.`202111ҵ��`),2)'202111���۶�',round(sum(od.`202111�����`),2) '202111�����',round(sum(od.`202111�����`)/sum(od.`202111ҵ��`),4) '202111������' ,round(sum(od.`202111�˿���`),2)'202111�˿���',sum(od.`202111����`) '202111������',

round(sum(od.`202112ҵ��`),2)'202112���۶�',round(sum(od.`202112�����`),2) '202112�����',round(sum(od.`202112�����`)/sum(od.`202112ҵ��`),4) '202112������' ,round(sum(od.`202112�˿���`),2)'202112�˿���',sum(od.`202112����`) '202112������',

round(sum(od.`202201ҵ��`),2)'202201���۶�',round(sum(od.`202201�����`),2) '202201�����',round(sum(od.`202201�����`)/sum(od.`202201ҵ��`),4) '202201������' ,round(sum(od.`202201�˿���`),2)'202201�˿���',sum(od.`202201����`) '202201������',

round(sum(od.`202202ҵ��`),2)'202202���۶�',round(sum(od.`202202�����`),2) '202202�����',round(sum(od.`202202�����`)/sum(od.`202202ҵ��`),4) '202202������' ,round(sum(od.`202202�˿���`),2)'202202�˿���',sum(od.`202202����`) '202202������',

round(sum(od.`202203ҵ��`),2)'202203���۶�',round(sum(od.`202203�����`),2) '202203�����',round(sum(od.`202203�����`)/sum(od.`202203ҵ��`),4) '202203������' ,round(sum(od.`202203�˿���`),2)'202203�˿���',sum(od.`202203����`) '202203������',

round(sum(od.`202204ҵ��`),2)'202204���۶�',round(sum(od.`202204�����`),2) '202204�����',round(sum(od.`202204�����`)/sum(od.`202204ҵ��`),4) '202204������' ,round(sum(od.`202204�˿���`),2)'202204�˿���',sum(od.`202204����`) '202204������',

round(sum(od.`202205ҵ��`),2)'202205���۶�',round(sum(od.`202205�����`),2) '202205�����',round(sum(od.`202205�����`)/sum(od.`202205ҵ��`),4) '202205������' ,round(sum(od.`202205�˿���`),2)'202205�˿���',sum(od.`202205����`) '202205������',

round(sum(od.`202206ҵ��`),2)'202206���۶�',round(sum(od.`202206�����`),2) '202206�����',round(sum(od.`202206�����`)/sum(od.`202206ҵ��`),4) '202206������' ,round(sum(od.`202206�˿���`),2)'202206�˿���',sum(od.`202206����`) '202206������',

round(sum(od.`202207ҵ��`),2)'202207���۶�',round(sum(od.`202207�����`),2) '202207�����',round(sum(od.`202207�����`)/sum(od.`202207ҵ��`),4) '202207������' ,round(sum(od.`202207�˿���`),2)'202207�˿���',sum(od.`202207����`) '202207������',

round(sum(od.`202208ҵ��`),2)'202208���۶�',round(sum(od.`202208�����`),2) '202208�����',round(sum(od.`202208�����`)/sum(od.`202208ҵ��`),4) '202208������' ,round(sum(od.`202208�˿���`),2)'202208�˿���',sum(od.`202208����`) '202208������',

round(sum(od.`202209ҵ��`),2)'202209���۶�',round(sum(od.`202209�����`),2) '202209�����',round(sum(od.`202209�����`)/sum(od.`202209ҵ��`),4) '202209������' ,round(sum(od.`202209�˿���`),2)'202209�˿���',sum(od.`202209����`) '202209������',

round(sum(od.`202210ҵ��`),2)'202210���۶�',round(sum(od.`202210�����`),2) '202210�����',round(sum(od.`202210�����`)/sum(od.`202210ҵ��`),4) '202210������' ,round(sum(od.`202210�˿���`),2)'202210�˿���',sum(od.`202210����`) '202210������' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(pc.CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(pc.CategoryPathByChineseName,'>',5)`�弶��Ŀ`,

`2��ҵ��`, `2021��ҵ��`,`2022��ҵ��`,`202101ҵ��` ,`202102ҵ��`,`202103ҵ��`,`202104ҵ��`,`202105ҵ��`,`202106ҵ��`,`202107ҵ��`,`202108ҵ��`,`202109ҵ��`,`202110ҵ��`,`202111ҵ��`,`202112ҵ��`,`202201ҵ��`,`202202ҵ��`,`202203ҵ��`,`202204ҵ��`,`202205ҵ��`,`202206ҵ��`,`202207ҵ��`,`202208ҵ��`,`202209ҵ��`,`202210ҵ��`,

`2�������`, `2021�������`,`2022�������`,`202101�����` ,`202102�����`,`202103�����`,`202104�����`,`202105�����`,`202106�����`,`202107�����`,`202108�����`,`202109�����`,`202110�����`,`202111�����`,`202112�����`,`202201�����`,`202202�����`,`202203�����`,`202204�����`,`202205�����`,`202206�����`,`202207�����`,`202208�����`,`202209�����`,`202210�����`,

`2���˿���`, `2021���˿���`,`2022���˿���`,`202101�˿���` ,`202102�˿���`,`202103�˿���`,`202104�˿���`,`202105�˿���`,`202106�˿���`,`202107�˿���`,`202108�˿���`,`202109�˿���`,`202110�˿���`,`202111�˿���`,`202112�˿���`,`202201�˿���`,`202202�˿���`,`202203�˿���`,`202204�˿���`,`202205�˿���`,`202206�˿���`,`202207�˿���`,`202208�˿���`,`202209�˿���`,`202210�˿���`,

`2�궩����`, `2021�궩����`,`2022�궩����`,`202101����` ,`202102����`,`202103����`,`202104����`,`202105����`,`202106����`,`202107����`,`202108����`,`202109����`,`202110����`,`202111����`,`202112����`,`202201����`,`202202����`,`202203����`,`202204����`,`202205����`,`202206����`,`202207����`,`202208����`,`202209����`,`202210����`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2�������',round(sum(RefundPrice)/6.5,1) '2���˿���',count(distinct(ordernumber)) '2�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2021�������',round(sum(RefundPrice)/6.5,1) '2021���˿���',count(distinct(ordernumber)) '2021�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2022�������',round(sum(RefundPrice)/6.5,1) '2022���˿���',count(distinct(ordernumber)) '2022�궩����'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101ҵ��' ,round(sum(GrossProfit)/6.5,1) '202101�����',round(sum(RefundPrice)/6.5,1) '202101�˿���',count(distinct(ordernumber)) '202101����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102ҵ��' ,round(sum(GrossProfit)/6.5,1) '202102�����',round(sum(RefundPrice)/6.5,1) '202102�˿���',count(distinct(ordernumber)) '202102����'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103ҵ��' ,round(sum(GrossProfit)/6.5,1) '202103�����',round(sum(RefundPrice)/6.5,1) '202103�˿���',count(distinct(ordernumber)) '202103����'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104ҵ��' ,round(sum(GrossProfit)/6.5,1) '202104�����',round(sum(RefundPrice)/6.5,1) '202104�˿���',count(distinct(ordernumber)) '202104����'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105ҵ��' ,round(sum(GrossProfit)/6.5,1) '202105�����',round(sum(RefundPrice)/6.5,1) '202105�˿���',count(distinct(ordernumber)) '202105����'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106ҵ��' ,round(sum(GrossProfit)/6.5,1) '202106�����',round(sum(RefundPrice)/6.5,1) '202106�˿���',count(distinct(ordernumber)) '202106����'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107ҵ��' ,round(sum(GrossProfit)/6.5,1) '202107�����',round(sum(RefundPrice)/6.5,1) '202107�˿���',count(distinct(ordernumber)) '202107����'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108ҵ��' ,round(sum(GrossProfit)/6.5,1) '202108�����',round(sum(RefundPrice)/6.5,1) '202108�˿���',count(distinct(ordernumber)) '202108����'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109ҵ��' ,round(sum(GrossProfit)/6.5,1) '202109�����',round(sum(RefundPrice)/6.5,1) '202109�˿���',count(distinct(ordernumber)) '202109����'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110ҵ��' ,round(sum(GrossProfit)/6.5,1) '202110�����',round(sum(RefundPrice)/6.5,1) '202110�˿���',count(distinct(ordernumber)) '202110����'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111ҵ��' ,round(sum(GrossProfit)/6.5,1) '202111�����',round(sum(RefundPrice)/6.5,1) '202111�˿���',count(distinct(ordernumber)) '202111����'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112ҵ��' ,round(sum(GrossProfit)/6.5,1) '202112�����',round(sum(RefundPrice)/6.5,1) '202112�˿���',count(distinct(ordernumber)) '202112����'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201ҵ��' ,round(sum(GrossProfit)/6.5,1) '202201�����',round(sum(RefundPrice)/6.5,1) '202201�˿���',count(distinct(ordernumber)) '202201����' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202ҵ��' ,round(sum(GrossProfit)/6.5,1) '202202�����',round(sum(RefundPrice)/6.5,1) '202202�˿���',count(distinct(ordernumber)) '202202����'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203ҵ��' ,round(sum(GrossProfit)/6.5,1) '202203�����',round(sum(RefundPrice)/6.5,1) '202203�˿���',count(distinct(ordernumber)) '202203����'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204ҵ��' ,round(sum(GrossProfit)/6.5,1) '202204�����',round(sum(RefundPrice)/6.5,1) '202204�˿���',count(distinct(ordernumber)) '202204����'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205ҵ��' ,round(sum(GrossProfit)/6.5,1) '202205�����',round(sum(RefundPrice)/6.5,1) '202205�˿���',count(distinct(ordernumber)) '202205����'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206ҵ��' ,round(sum(GrossProfit)/6.5,1) '202206�����',round(sum(RefundPrice)/6.5,1) '202206�˿���',count(distinct(ordernumber)) '202206����'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207ҵ��' ,round(sum(GrossProfit)/6.5,1) '202207�����',round(sum(RefundPrice)/6.5,1) '202207�˿���',count(distinct(ordernumber)) '202207����'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208ҵ��' ,round(sum(GrossProfit)/6.5,1) '202208�����',round(sum(RefundPrice)/6.5,1) '202208�˿���',count(distinct(ordernumber)) '202208����'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209ҵ��' ,round(sum(GrossProfit)/6.5,1) '202209�����',round(sum(RefundPrice)/6.5,1) '202209�˿���',count(distinct(ordernumber)) '202209����'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210ҵ��' ,round(sum(GrossProfit)/6.5,1) '202210�����',round(sum(RefundPrice)/6.5,1) '202210�˿���',count(distinct(ordernumber)) '202210����'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ)) a9

left join

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ) '������Ŀ',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2������·�',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021������·�',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022������·�' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(CategoryPathByChineseName,'>',5)`�弶��Ŀ`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ)) a7

on a9.������Ŀ=a7.������Ŀ

order by `2�����۶�` desc;





/*�ļ���Ŀ*/

/*ϸ����Ŀ-���в���*/

select a9.������Ŀ,a9.SKU��, a7.`2������·�`,`2�����۶�`, `2�������`, `2��������`, `2���˿���`, `2�궩����`, a7.`2021������·�`,`2021�����۶�`, `2021�������`, `2021��������`, `2021���˿���`, `2021�궩����`,a7.`2022������·�` ,`2022�����۶�`, `2022�������`, `2022��������`, `2022���˿���`, `2022�궩����`, `202101���۶�`, `202101�����`, `202101������`, `202101�˿���`, `202101������`, `202102���۶�`, `202102�����`, `202102������`, `202102�˿���`, `202102������`, `202103���۶�`, `202103�����`, `202103������`, `202103�˿���`, `202103������`, `202104���۶�`, `202104�����`, `202104������`, `202104�˿���`, `202104������`, `202105���۶�`, `202105�����`, `202105������`, `202105�˿���`, `202105������`, `202106���۶�`, `202106�����`, `202106������`, `202106�˿���`, `202106������`, `202107���۶�`, `202107�����`, `202107������`, `202107�˿���`, `202107������`, `202108���۶�`, `202108�����`, `202108������`, `202108�˿���`, `202108������`, `202109���۶�`, `202109�����`, `202109������`, `202109�˿���`, `202109������`, `202110���۶�`, `202110�����`, `202110������`, `202110�˿���`, `202110������`, `202111���۶�`, `202111�����`, `202111������`, `202111�˿���`, `202111������`, `202112���۶�`, `202112�����`, `202112������`, `202112�˿���`, `202112������`, `202201���۶�`, `202201�����`, `202201������`, `202201�˿���`, `202201������`, `202202���۶�`, `202202�����`, `202202������`, `202202�˿���`, `202202������`, `202203���۶�`, `202203�����`, `202203������`, `202203�˿���`, `202203������`, `202204���۶�`, `202204�����`, `202204������`, `202204�˿���`, `202204������`, `202205���۶�`, `202205�����`, `202205������`, `202205�˿���`, `202205������`, `202206���۶�`, `202206�����`, `202206������`, `202206�˿���`, `202206������`, `202207���۶�`, `202207�����`, `202207������`, `202207�˿���`, `202207������`, `202208���۶�`, `202208�����`, `202208������`, `202208�˿���`, `202208������`, `202209���۶�`, `202209�����`, `202209������`, `202209�˿���`, `202209������`, `202210���۶�`, `202210�����`, `202210������`, `202210�˿���`, `202210������` from

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ) as '������Ŀ',count(distinct SKU) 'SKU��',

round(sum(od.`2��ҵ��`),2)'2�����۶�',round(sum(od.`2�������`),2) '2�������',round(sum(od.`2�������`)/sum(od.`2��ҵ��`),4) '2��������' ,round(sum(od.`2���˿���`),2)'2���˿���',sum(od.`2�궩����`) '2�궩����',

round(sum(od.`2021��ҵ��`),2)'2021�����۶�',round(sum(od.`2021�������`),2) '2021�������',round(sum(od.`2021�������`)/sum(od.`2021��ҵ��`),4) '2021��������' ,round(sum(od.`2021���˿���`),2)'2021���˿���',sum(od.`2021�궩����`) '2021�궩����',

round(sum(od.`2022��ҵ��`),2)'2022�����۶�',round(sum(od.`2022�������`),2) '2022�������',round(sum(od.`2022�������`)/sum(od.`2022��ҵ��`),4) '2022��������' ,round(sum(od.`2022���˿���`),2)'2022���˿���',sum(od.`2022�궩����`) '2022�궩����',

round(sum(od.`202101ҵ��`),2)'202101���۶�',round(sum(od.`202101�����`),2) '202101�����',round(sum(od.`202101�����`)/sum(od.`202101ҵ��`),4) '202101������' ,round(sum(od.`202101�˿���`),2)'202101�˿���',sum(od.`202101����`) '202101������',

round(sum(od.`202102ҵ��`),2)'202102���۶�',round(sum(od.`202102�����`),2) '202102�����',round(sum(od.`202102�����`)/sum(od.`202102ҵ��`),4) '202102������' , round(sum(od.`202102�˿���`),2)'202102�˿���',sum(od.`202102����`) '202102������',

round(sum(od.`202103ҵ��`),2)'202103���۶�',round(sum(od.`202103�����`),2) '202103�����',round(sum(od.`202103�����`)/sum(od.`202103ҵ��`),4) '202103������' ,round(sum(od.`202103�˿���`),2)'202103�˿���',sum(od.`202103����`) '202103������',

round(sum(od.`202104ҵ��`),2)'202104���۶�',round(sum(od.`202104�����`),2) '202104�����',round(sum(od.`202104�����`)/sum(od.`202104ҵ��`),4) '202104������' ,round(sum(od.`202104�˿���`),2)'202104�˿���',sum(od.`202104����`) '202104������',

round(sum(od.`202105ҵ��`),2)'202105���۶�',round(sum(od.`202105�����`),2) '202105�����',round(sum(od.`202105�����`)/sum(od.`202105ҵ��`),4) '202105������' ,round(sum(od.`202105�˿���`),2)'202105�˿���',sum(od.`202105����`) '202105������',

round(sum(od.`202106ҵ��`),2)'202106���۶�',round(sum(od.`202106�����`),2) '202106�����',round(sum(od.`202106�����`)/sum(od.`202106ҵ��`),4) '202106������' ,round(sum(od.`202106�˿���`),2)'202106�˿���',sum(od.`202106����`) '202106������',

round(sum(od.`202107ҵ��`),2)'202107���۶�',round(sum(od.`202107�����`),2) '202107�����',round(sum(od.`202107�����`)/sum(od.`202107ҵ��`),4) '202107������' ,round(sum(od.`202107�˿���`),2)'202107�˿���',sum(od.`202107����`) '202107������',

round(sum(od.`202108ҵ��`),2)'202108���۶�',round(sum(od.`202108�����`),2) '202108�����',round(sum(od.`202108�����`)/sum(od.`202108ҵ��`),4) '202108������' ,round(sum(od.`202108�˿���`),2)'202108�˿���',sum(od.`202108����`) '202108������',

round(sum(od.`202109ҵ��`),2)'202109���۶�',round(sum(od.`202109�����`),2) '202109�����',round(sum(od.`202109�����`)/sum(od.`202109ҵ��`),4) '202109������' ,round(sum(od.`202109�˿���`),2)'202109�˿���',sum(od.`202109����`) '202109������',

round(sum(od.`202110ҵ��`),2)'202110���۶�',round(sum(od.`202110�����`),2) '202110�����',round(sum(od.`202110�����`)/sum(od.`202110ҵ��`),4) '202110������' ,round(sum(od.`202110�˿���`),2)'202110�˿���',sum(od.`202110����`) '202110������',

round(sum(od.`202111ҵ��`),2)'202111���۶�',round(sum(od.`202111�����`),2) '202111�����',round(sum(od.`202111�����`)/sum(od.`202111ҵ��`),4) '202111������' ,round(sum(od.`202111�˿���`),2)'202111�˿���',sum(od.`202111����`) '202111������',

round(sum(od.`202112ҵ��`),2)'202112���۶�',round(sum(od.`202112�����`),2) '202112�����',round(sum(od.`202112�����`)/sum(od.`202112ҵ��`),4) '202112������' ,round(sum(od.`202112�˿���`),2)'202112�˿���',sum(od.`202112����`) '202112������',

round(sum(od.`202201ҵ��`),2)'202201���۶�',round(sum(od.`202201�����`),2) '202201�����',round(sum(od.`202201�����`)/sum(od.`202201ҵ��`),4) '202201������' ,round(sum(od.`202201�˿���`),2)'202201�˿���',sum(od.`202201����`) '202201������',

round(sum(od.`202202ҵ��`),2)'202202���۶�',round(sum(od.`202202�����`),2) '202202�����',round(sum(od.`202202�����`)/sum(od.`202202ҵ��`),4) '202202������' ,round(sum(od.`202202�˿���`),2)'202202�˿���',sum(od.`202202����`) '202202������',

round(sum(od.`202203ҵ��`),2)'202203���۶�',round(sum(od.`202203�����`),2) '202203�����',round(sum(od.`202203�����`)/sum(od.`202203ҵ��`),4) '202203������' ,round(sum(od.`202203�˿���`),2)'202203�˿���',sum(od.`202203����`) '202203������',

round(sum(od.`202204ҵ��`),2)'202204���۶�',round(sum(od.`202204�����`),2) '202204�����',round(sum(od.`202204�����`)/sum(od.`202204ҵ��`),4) '202204������' ,round(sum(od.`202204�˿���`),2)'202204�˿���',sum(od.`202204����`) '202204������',

round(sum(od.`202205ҵ��`),2)'202205���۶�',round(sum(od.`202205�����`),2) '202205�����',round(sum(od.`202205�����`)/sum(od.`202205ҵ��`),4) '202205������' ,round(sum(od.`202205�˿���`),2)'202205�˿���',sum(od.`202205����`) '202205������',

round(sum(od.`202206ҵ��`),2)'202206���۶�',round(sum(od.`202206�����`),2) '202206�����',round(sum(od.`202206�����`)/sum(od.`202206ҵ��`),4) '202206������' ,round(sum(od.`202206�˿���`),2)'202206�˿���',sum(od.`202206����`) '202206������',

round(sum(od.`202207ҵ��`),2)'202207���۶�',round(sum(od.`202207�����`),2) '202207�����',round(sum(od.`202207�����`)/sum(od.`202207ҵ��`),4) '202207������' ,round(sum(od.`202207�˿���`),2)'202207�˿���',sum(od.`202207����`) '202207������',

round(sum(od.`202208ҵ��`),2)'202208���۶�',round(sum(od.`202208�����`),2) '202208�����',round(sum(od.`202208�����`)/sum(od.`202208ҵ��`),4) '202208������' ,round(sum(od.`202208�˿���`),2)'202208�˿���',sum(od.`202208����`) '202208������',

round(sum(od.`202209ҵ��`),2)'202209���۶�',round(sum(od.`202209�����`),2) '202209�����',round(sum(od.`202209�����`)/sum(od.`202209ҵ��`),4) '202209������' ,round(sum(od.`202209�˿���`),2)'202209�˿���',sum(od.`202209����`) '202209������',

round(sum(od.`202210ҵ��`),2)'202210���۶�',round(sum(od.`202210�����`),2) '202210�����',round(sum(od.`202210�����`)/sum(od.`202210ҵ��`),4) '202210������' ,round(sum(od.`202210�˿���`),2)'202210�˿���',sum(od.`202210����`) '202210������' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(pc.CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(pc.CategoryPathByChineseName,'>',5)`�弶��Ŀ`,

`2��ҵ��`, `2021��ҵ��`,`2022��ҵ��`,`202101ҵ��` ,`202102ҵ��`,`202103ҵ��`,`202104ҵ��`,`202105ҵ��`,`202106ҵ��`,`202107ҵ��`,`202108ҵ��`,`202109ҵ��`,`202110ҵ��`,`202111ҵ��`,`202112ҵ��`,`202201ҵ��`,`202202ҵ��`,`202203ҵ��`,`202204ҵ��`,`202205ҵ��`,`202206ҵ��`,`202207ҵ��`,`202208ҵ��`,`202209ҵ��`,`202210ҵ��`,

`2�������`, `2021�������`,`2022�������`,`202101�����` ,`202102�����`,`202103�����`,`202104�����`,`202105�����`,`202106�����`,`202107�����`,`202108�����`,`202109�����`,`202110�����`,`202111�����`,`202112�����`,`202201�����`,`202202�����`,`202203�����`,`202204�����`,`202205�����`,`202206�����`,`202207�����`,`202208�����`,`202209�����`,`202210�����`,

`2���˿���`, `2021���˿���`,`2022���˿���`,`202101�˿���` ,`202102�˿���`,`202103�˿���`,`202104�˿���`,`202105�˿���`,`202106�˿���`,`202107�˿���`,`202108�˿���`,`202109�˿���`,`202110�˿���`,`202111�˿���`,`202112�˿���`,`202201�˿���`,`202202�˿���`,`202203�˿���`,`202204�˿���`,`202205�˿���`,`202206�˿���`,`202207�˿���`,`202208�˿���`,`202209�˿���`,`202210�˿���`,

`2�궩����`, `2021�궩����`,`2022�궩����`,`202101����` ,`202102����`,`202103����`,`202104����`,`202105����`,`202106����`,`202107����`,`202108����`,`202109����`,`202110����`,`202111����`,`202112����`,`202201����`,`202202����`,`202203����`,`202204����`,`202205����`,`202206����`,`202207����`,`202208����`,`202209����`,`202210����`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2�������',round(sum(RefundPrice)/6.5,1) '2���˿���',count(distinct(ordernumber)) '2�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2021�������',round(sum(RefundPrice)/6.5,1) '2021���˿���',count(distinct(ordernumber)) '2021�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2022�������',round(sum(RefundPrice)/6.5,1) '2022���˿���',count(distinct(ordernumber)) '2022�궩����'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101ҵ��' ,round(sum(GrossProfit)/6.5,1) '202101�����',round(sum(RefundPrice)/6.5,1) '202101�˿���',count(distinct(ordernumber)) '202101����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102ҵ��' ,round(sum(GrossProfit)/6.5,1) '202102�����',round(sum(RefundPrice)/6.5,1) '202102�˿���',count(distinct(ordernumber)) '202102����'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103ҵ��' ,round(sum(GrossProfit)/6.5,1) '202103�����',round(sum(RefundPrice)/6.5,1) '202103�˿���',count(distinct(ordernumber)) '202103����'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104ҵ��' ,round(sum(GrossProfit)/6.5,1) '202104�����',round(sum(RefundPrice)/6.5,1) '202104�˿���',count(distinct(ordernumber)) '202104����'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105ҵ��' ,round(sum(GrossProfit)/6.5,1) '202105�����',round(sum(RefundPrice)/6.5,1) '202105�˿���',count(distinct(ordernumber)) '202105����'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106ҵ��' ,round(sum(GrossProfit)/6.5,1) '202106�����',round(sum(RefundPrice)/6.5,1) '202106�˿���',count(distinct(ordernumber)) '202106����'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107ҵ��' ,round(sum(GrossProfit)/6.5,1) '202107�����',round(sum(RefundPrice)/6.5,1) '202107�˿���',count(distinct(ordernumber)) '202107����'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108ҵ��' ,round(sum(GrossProfit)/6.5,1) '202108�����',round(sum(RefundPrice)/6.5,1) '202108�˿���',count(distinct(ordernumber)) '202108����'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109ҵ��' ,round(sum(GrossProfit)/6.5,1) '202109�����',round(sum(RefundPrice)/6.5,1) '202109�˿���',count(distinct(ordernumber)) '202109����'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110ҵ��' ,round(sum(GrossProfit)/6.5,1) '202110�����',round(sum(RefundPrice)/6.5,1) '202110�˿���',count(distinct(ordernumber)) '202110����'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111ҵ��' ,round(sum(GrossProfit)/6.5,1) '202111�����',round(sum(RefundPrice)/6.5,1) '202111�˿���',count(distinct(ordernumber)) '202111����'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112ҵ��' ,round(sum(GrossProfit)/6.5,1) '202112�����',round(sum(RefundPrice)/6.5,1) '202112�˿���',count(distinct(ordernumber)) '202112����'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201ҵ��' ,round(sum(GrossProfit)/6.5,1) '202201�����',round(sum(RefundPrice)/6.5,1) '202201�˿���',count(distinct(ordernumber)) '202201����' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202ҵ��' ,round(sum(GrossProfit)/6.5,1) '202202�����',round(sum(RefundPrice)/6.5,1) '202202�˿���',count(distinct(ordernumber)) '202202����'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203ҵ��' ,round(sum(GrossProfit)/6.5,1) '202203�����',round(sum(RefundPrice)/6.5,1) '202203�˿���',count(distinct(ordernumber)) '202203����'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204ҵ��' ,round(sum(GrossProfit)/6.5,1) '202204�����',round(sum(RefundPrice)/6.5,1) '202204�˿���',count(distinct(ordernumber)) '202204����'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205ҵ��' ,round(sum(GrossProfit)/6.5,1) '202205�����',round(sum(RefundPrice)/6.5,1) '202205�˿���',count(distinct(ordernumber)) '202205����'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206ҵ��' ,round(sum(GrossProfit)/6.5,1) '202206�����',round(sum(RefundPrice)/6.5,1) '202206�˿���',count(distinct(ordernumber)) '202206����'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207ҵ��' ,round(sum(GrossProfit)/6.5,1) '202207�����',round(sum(RefundPrice)/6.5,1) '202207�˿���',count(distinct(ordernumber)) '202207����'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208ҵ��' ,round(sum(GrossProfit)/6.5,1) '202208�����',round(sum(RefundPrice)/6.5,1) '202208�˿���',count(distinct(ordernumber)) '202208����'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209ҵ��' ,round(sum(GrossProfit)/6.5,1) '202209�����',round(sum(RefundPrice)/6.5,1) '202209�˿���',count(distinct(ordernumber)) '202209����'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210ҵ��' ,round(sum(GrossProfit)/6.5,1) '202210�����',round(sum(RefundPrice)/6.5,1) '202210�˿���',count(distinct(ordernumber)) '202210����'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ)) a9

left join

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ) '������Ŀ',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2������·�',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021������·�',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022������·�' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(CategoryPathByChineseName,'>',5)`�弶��Ŀ`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ)) a7

on a9.������Ŀ=a7.������Ŀ

order by `2�����۶�` desc;





/*�弶��Ŀ*/

/*ϸ����Ŀ-���в���*/

select a9.������Ŀ,a9.SKU��, a7.`2������·�`,`2�����۶�`, `2�������`, `2��������`, `2���˿���`, `2�궩����`, a7.`2021������·�`,`2021�����۶�`, `2021�������`, `2021��������`, `2021���˿���`, `2021�궩����`,a7.`2022������·�` ,`2022�����۶�`, `2022�������`, `2022��������`, `2022���˿���`, `2022�궩����`, `202101���۶�`, `202101�����`, `202101������`, `202101�˿���`, `202101������`, `202102���۶�`, `202102�����`, `202102������`, `202102�˿���`, `202102������`, `202103���۶�`, `202103�����`, `202103������`, `202103�˿���`, `202103������`, `202104���۶�`, `202104�����`, `202104������`, `202104�˿���`, `202104������`, `202105���۶�`, `202105�����`, `202105������`, `202105�˿���`, `202105������`, `202106���۶�`, `202106�����`, `202106������`, `202106�˿���`, `202106������`, `202107���۶�`, `202107�����`, `202107������`, `202107�˿���`, `202107������`, `202108���۶�`, `202108�����`, `202108������`, `202108�˿���`, `202108������`, `202109���۶�`, `202109�����`, `202109������`, `202109�˿���`, `202109������`, `202110���۶�`, `202110�����`, `202110������`, `202110�˿���`, `202110������`, `202111���۶�`, `202111�����`, `202111������`, `202111�˿���`, `202111������`, `202112���۶�`, `202112�����`, `202112������`, `202112�˿���`, `202112������`, `202201���۶�`, `202201�����`, `202201������`, `202201�˿���`, `202201������`, `202202���۶�`, `202202�����`, `202202������`, `202202�˿���`, `202202������`, `202203���۶�`, `202203�����`, `202203������`, `202203�˿���`, `202203������`, `202204���۶�`, `202204�����`, `202204������`, `202204�˿���`, `202204������`, `202205���۶�`, `202205�����`, `202205������`, `202205�˿���`, `202205������`, `202206���۶�`, `202206�����`, `202206������`, `202206�˿���`, `202206������`, `202207���۶�`, `202207�����`, `202207������`, `202207�˿���`, `202207������`, `202208���۶�`, `202208�����`, `202208������`, `202208�˿���`, `202208������`, `202209���۶�`, `202209�����`, `202209������`, `202209�˿���`, `202209������`, `202210���۶�`, `202210�����`, `202210������`, `202210�˿���`, `202210������` from

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ,'>',od.�弶��Ŀ) as '������Ŀ',count(distinct SKU) 'SKU��',

round(sum(od.`2��ҵ��`),2)'2�����۶�',round(sum(od.`2�������`),2) '2�������',round(sum(od.`2�������`)/sum(od.`2��ҵ��`),4) '2��������' ,round(sum(od.`2���˿���`),2)'2���˿���',sum(od.`2�궩����`) '2�궩����',

round(sum(od.`2021��ҵ��`),2)'2021�����۶�',round(sum(od.`2021�������`),2) '2021�������',round(sum(od.`2021�������`)/sum(od.`2021��ҵ��`),4) '2021��������' ,round(sum(od.`2021���˿���`),2)'2021���˿���',sum(od.`2021�궩����`) '2021�궩����',

round(sum(od.`2022��ҵ��`),2)'2022�����۶�',round(sum(od.`2022�������`),2) '2022�������',round(sum(od.`2022�������`)/sum(od.`2022��ҵ��`),4) '2022��������' ,round(sum(od.`2022���˿���`),2)'2022���˿���',sum(od.`2022�궩����`) '2022�궩����',

round(sum(od.`202101ҵ��`),2)'202101���۶�',round(sum(od.`202101�����`),2) '202101�����',round(sum(od.`202101�����`)/sum(od.`202101ҵ��`),4) '202101������' ,round(sum(od.`202101�˿���`),2)'202101�˿���',sum(od.`202101����`) '202101������',

round(sum(od.`202102ҵ��`),2)'202102���۶�',round(sum(od.`202102�����`),2) '202102�����',round(sum(od.`202102�����`)/sum(od.`202102ҵ��`),4) '202102������' , round(sum(od.`202102�˿���`),2)'202102�˿���',sum(od.`202102����`) '202102������',

round(sum(od.`202103ҵ��`),2)'202103���۶�',round(sum(od.`202103�����`),2) '202103�����',round(sum(od.`202103�����`)/sum(od.`202103ҵ��`),4) '202103������' ,round(sum(od.`202103�˿���`),2)'202103�˿���',sum(od.`202103����`) '202103������',

round(sum(od.`202104ҵ��`),2)'202104���۶�',round(sum(od.`202104�����`),2) '202104�����',round(sum(od.`202104�����`)/sum(od.`202104ҵ��`),4) '202104������' ,round(sum(od.`202104�˿���`),2)'202104�˿���',sum(od.`202104����`) '202104������',

round(sum(od.`202105ҵ��`),2)'202105���۶�',round(sum(od.`202105�����`),2) '202105�����',round(sum(od.`202105�����`)/sum(od.`202105ҵ��`),4) '202105������' ,round(sum(od.`202105�˿���`),2)'202105�˿���',sum(od.`202105����`) '202105������',

round(sum(od.`202106ҵ��`),2)'202106���۶�',round(sum(od.`202106�����`),2) '202106�����',round(sum(od.`202106�����`)/sum(od.`202106ҵ��`),4) '202106������' ,round(sum(od.`202106�˿���`),2)'202106�˿���',sum(od.`202106����`) '202106������',

round(sum(od.`202107ҵ��`),2)'202107���۶�',round(sum(od.`202107�����`),2) '202107�����',round(sum(od.`202107�����`)/sum(od.`202107ҵ��`),4) '202107������' ,round(sum(od.`202107�˿���`),2)'202107�˿���',sum(od.`202107����`) '202107������',

round(sum(od.`202108ҵ��`),2)'202108���۶�',round(sum(od.`202108�����`),2) '202108�����',round(sum(od.`202108�����`)/sum(od.`202108ҵ��`),4) '202108������' ,round(sum(od.`202108�˿���`),2)'202108�˿���',sum(od.`202108����`) '202108������',

round(sum(od.`202109ҵ��`),2)'202109���۶�',round(sum(od.`202109�����`),2) '202109�����',round(sum(od.`202109�����`)/sum(od.`202109ҵ��`),4) '202109������' ,round(sum(od.`202109�˿���`),2)'202109�˿���',sum(od.`202109����`) '202109������',

round(sum(od.`202110ҵ��`),2)'202110���۶�',round(sum(od.`202110�����`),2) '202110�����',round(sum(od.`202110�����`)/sum(od.`202110ҵ��`),4) '202110������' ,round(sum(od.`202110�˿���`),2)'202110�˿���',sum(od.`202110����`) '202110������',

round(sum(od.`202111ҵ��`),2)'202111���۶�',round(sum(od.`202111�����`),2) '202111�����',round(sum(od.`202111�����`)/sum(od.`202111ҵ��`),4) '202111������' ,round(sum(od.`202111�˿���`),2)'202111�˿���',sum(od.`202111����`) '202111������',

round(sum(od.`202112ҵ��`),2)'202112���۶�',round(sum(od.`202112�����`),2) '202112�����',round(sum(od.`202112�����`)/sum(od.`202112ҵ��`),4) '202112������' ,round(sum(od.`202112�˿���`),2)'202112�˿���',sum(od.`202112����`) '202112������',

round(sum(od.`202201ҵ��`),2)'202201���۶�',round(sum(od.`202201�����`),2) '202201�����',round(sum(od.`202201�����`)/sum(od.`202201ҵ��`),4) '202201������' ,round(sum(od.`202201�˿���`),2)'202201�˿���',sum(od.`202201����`) '202201������',

round(sum(od.`202202ҵ��`),2)'202202���۶�',round(sum(od.`202202�����`),2) '202202�����',round(sum(od.`202202�����`)/sum(od.`202202ҵ��`),4) '202202������' ,round(sum(od.`202202�˿���`),2)'202202�˿���',sum(od.`202202����`) '202202������',

round(sum(od.`202203ҵ��`),2)'202203���۶�',round(sum(od.`202203�����`),2) '202203�����',round(sum(od.`202203�����`)/sum(od.`202203ҵ��`),4) '202203������' ,round(sum(od.`202203�˿���`),2)'202203�˿���',sum(od.`202203����`) '202203������',

round(sum(od.`202204ҵ��`),2)'202204���۶�',round(sum(od.`202204�����`),2) '202204�����',round(sum(od.`202204�����`)/sum(od.`202204ҵ��`),4) '202204������' ,round(sum(od.`202204�˿���`),2)'202204�˿���',sum(od.`202204����`) '202204������',

round(sum(od.`202205ҵ��`),2)'202205���۶�',round(sum(od.`202205�����`),2) '202205�����',round(sum(od.`202205�����`)/sum(od.`202205ҵ��`),4) '202205������' ,round(sum(od.`202205�˿���`),2)'202205�˿���',sum(od.`202205����`) '202205������',

round(sum(od.`202206ҵ��`),2)'202206���۶�',round(sum(od.`202206�����`),2) '202206�����',round(sum(od.`202206�����`)/sum(od.`202206ҵ��`),4) '202206������' ,round(sum(od.`202206�˿���`),2)'202206�˿���',sum(od.`202206����`) '202206������',

round(sum(od.`202207ҵ��`),2)'202207���۶�',round(sum(od.`202207�����`),2) '202207�����',round(sum(od.`202207�����`)/sum(od.`202207ҵ��`),4) '202207������' ,round(sum(od.`202207�˿���`),2)'202207�˿���',sum(od.`202207����`) '202207������',

round(sum(od.`202208ҵ��`),2)'202208���۶�',round(sum(od.`202208�����`),2) '202208�����',round(sum(od.`202208�����`)/sum(od.`202208ҵ��`),4) '202208������' ,round(sum(od.`202208�˿���`),2)'202208�˿���',sum(od.`202208����`) '202208������',

round(sum(od.`202209ҵ��`),2)'202209���۶�',round(sum(od.`202209�����`),2) '202209�����',round(sum(od.`202209�����`)/sum(od.`202209ҵ��`),4) '202209������' ,round(sum(od.`202209�˿���`),2)'202209�˿���',sum(od.`202209����`) '202209������',

round(sum(od.`202210ҵ��`),2)'202210���۶�',round(sum(od.`202210�����`),2) '202210�����',round(sum(od.`202210�����`)/sum(od.`202210ҵ��`),4) '202210������' ,round(sum(od.`202210�˿���`),2)'202210�˿���',sum(od.`202210����`) '202210������' from

(

select  pp.sku, pp.boxsku,pc.CategoryPathByChineseName,split_part(pc.CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(pc.CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(pc.CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(pc.CategoryPathByChineseName,'>',5)`�弶��Ŀ`,

`2��ҵ��`, `2021��ҵ��`,`2022��ҵ��`,`202101ҵ��` ,`202102ҵ��`,`202103ҵ��`,`202104ҵ��`,`202105ҵ��`,`202106ҵ��`,`202107ҵ��`,`202108ҵ��`,`202109ҵ��`,`202110ҵ��`,`202111ҵ��`,`202112ҵ��`,`202201ҵ��`,`202202ҵ��`,`202203ҵ��`,`202204ҵ��`,`202205ҵ��`,`202206ҵ��`,`202207ҵ��`,`202208ҵ��`,`202209ҵ��`,`202210ҵ��`,

`2�������`, `2021�������`,`2022�������`,`202101�����` ,`202102�����`,`202103�����`,`202104�����`,`202105�����`,`202106�����`,`202107�����`,`202108�����`,`202109�����`,`202110�����`,`202111�����`,`202112�����`,`202201�����`,`202202�����`,`202203�����`,`202204�����`,`202205�����`,`202206�����`,`202207�����`,`202208�����`,`202209�����`,`202210�����`,

`2���˿���`, `2021���˿���`,`2022���˿���`,`202101�˿���` ,`202102�˿���`,`202103�˿���`,`202104�˿���`,`202105�˿���`,`202106�˿���`,`202107�˿���`,`202108�˿���`,`202109�˿���`,`202110�˿���`,`202111�˿���`,`202112�˿���`,`202201�˿���`,`202202�˿���`,`202203�˿���`,`202204�˿���`,`202205�˿���`,`202206�˿���`,`202207�˿���`,`202208�˿���`,`202209�˿���`,`202210�˿���`,

`2�궩����`, `2021�궩����`,`2022�궩����`,`202101����` ,`202102����`,`202103����`,`202104����`,`202105����`,`202106����`,`202107����`,`202108����`,`202109����`,`202110����`,`202111����`,`202112����`,`202201����`,`202202����`,`202203����`,`202204����`,`202205����`,`202206����`,`202207����`,`202208����`,`202209����`,`202210����`

from import_data.erp_product_products pp

join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId



left join (

SELECT boxsku, round(sum(income)/6.5,1) '2��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2�������',round(sum(RefundPrice)/6.5,1) '2���˿���',count(distinct(ordernumber)) '2�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-11-01'

group by BoxSku

) t on t.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2021��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2021�������',round(sum(RefundPrice)/6.5,1) '2021���˿���',count(distinct(ordernumber)) '2021�궩����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2022-01-01'

group by BoxSku

) t1 on t1.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '2022��ҵ��' ,round(sum(GrossProfit)/6.5,1) '2022�������',round(sum(RefundPrice)/6.5,1) '2022���˿���',count(distinct(ordernumber)) '2022�궩����'from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-11-01'

group by BoxSku

) t2 on t2.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202101ҵ��' ,round(sum(GrossProfit)/6.5,1) '202101�����',round(sum(RefundPrice)/6.5,1) '202101�˿���',count(distinct(ordernumber)) '202101����'from import_data.OrderProfitSettle

where paytime >= '2021-01-01' and paytime < '2021-02-01'

group by BoxSku

) a on a.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202102ҵ��' ,round(sum(GrossProfit)/6.5,1) '202102�����',round(sum(RefundPrice)/6.5,1) '202102�˿���',count(distinct(ordernumber)) '202102����'from import_data.OrderProfitSettle

where paytime >= '2021-02-01' and paytime < '2021-03-01'

group by BoxSku

) b on b.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202103ҵ��' ,round(sum(GrossProfit)/6.5,1) '202103�����',round(sum(RefundPrice)/6.5,1) '202103�˿���',count(distinct(ordernumber)) '202103����'from import_data.OrderProfitSettle

where paytime >= '2021-03-01' and paytime < '2021-04-01'

group by BoxSku

) c on c.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202104ҵ��' ,round(sum(GrossProfit)/6.5,1) '202104�����',round(sum(RefundPrice)/6.5,1) '202104�˿���',count(distinct(ordernumber)) '202104����'from import_data.OrderProfitSettle

where paytime >= '2021-04-01' and paytime < '2021-05-01'

group by BoxSku

) d on d.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202105ҵ��' ,round(sum(GrossProfit)/6.5,1) '202105�����',round(sum(RefundPrice)/6.5,1) '202105�˿���',count(distinct(ordernumber)) '202105����'from import_data.OrderProfitSettle

where paytime >= '2021-05-01' and paytime < '2021-06-01'

group by BoxSku

) e on e.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202106ҵ��' ,round(sum(GrossProfit)/6.5,1) '202106�����',round(sum(RefundPrice)/6.5,1) '202106�˿���',count(distinct(ordernumber)) '202106����'from import_data.OrderProfitSettle

where paytime >= '2021-06-01' and paytime < '2021-07-01'

group by BoxSku

) f on f.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202107ҵ��' ,round(sum(GrossProfit)/6.5,1) '202107�����',round(sum(RefundPrice)/6.5,1) '202107�˿���',count(distinct(ordernumber)) '202107����'from import_data.OrderProfitSettle

where paytime >= '2021-07-01' and paytime < '2021-08-01'

group by BoxSku

) g on g.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202108ҵ��' ,round(sum(GrossProfit)/6.5,1) '202108�����',round(sum(RefundPrice)/6.5,1) '202108�˿���',count(distinct(ordernumber)) '202108����'from import_data.OrderProfitSettle

where paytime >= '2021-08-01' and paytime < '2021-09-01'

group by BoxSku

) h on h.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202109ҵ��' ,round(sum(GrossProfit)/6.5,1) '202109�����',round(sum(RefundPrice)/6.5,1) '202109�˿���',count(distinct(ordernumber)) '202109����'from import_data.OrderProfitSettle

where paytime >= '2021-09-01' and paytime < '2021-10-01'

group by BoxSku

) i on i.BoxSKU = pp.boxsku



left join (

SELECT boxsku, round(sum(income)/6.5,1) '202110ҵ��' ,round(sum(GrossProfit)/6.5,1) '202110�����',round(sum(RefundPrice)/6.5,1) '202110�˿���',count(distinct(ordernumber)) '202110����'from import_data.OrderProfitSettle

where paytime >= '2021-10-01' and paytime < '2021-11-01'

group by BoxSku

) j on j.BoxSKU = pp.boxsku

left join (

SELECT boxsku, round(sum(income)/6.5,1) '202111ҵ��' ,round(sum(GrossProfit)/6.5,1) '202111�����',round(sum(RefundPrice)/6.5,1) '202111�˿���',count(distinct(ordernumber)) '202111����'from import_data.OrderProfitSettle

where paytime >= '2021-11-01' and paytime < '2021-12-01'

group by BoxSku

) k on k.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202112ҵ��' ,round(sum(GrossProfit)/6.5,1) '202112�����',round(sum(RefundPrice)/6.5,1) '202112�˿���',count(distinct(ordernumber)) '202112����'from import_data.OrderProfitSettle

where paytime >= '2021-12-01' and paytime < '2022-01-01'

group by BoxSku

) l on l.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202201ҵ��' ,round(sum(GrossProfit)/6.5,1) '202201�����',round(sum(RefundPrice)/6.5,1) '202201�˿���',count(distinct(ordernumber)) '202201����' from import_data.OrderProfitSettle

where paytime >= '2022-01-01' and paytime < '2022-02-01'

group by BoxSku

) m on m.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202202ҵ��' ,round(sum(GrossProfit)/6.5,1) '202202�����',round(sum(RefundPrice)/6.5,1) '202202�˿���',count(distinct(ordernumber)) '202202����'from import_data.OrderProfitSettle

where paytime >= '2022-02-01' and paytime < '2022-03-01'

group by BoxSku

) n on n.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202203ҵ��' ,round(sum(GrossProfit)/6.5,1) '202203�����',round(sum(RefundPrice)/6.5,1) '202203�˿���',count(distinct(ordernumber)) '202203����'from import_data.OrderProfitSettle

where paytime >= '2022-03-01' and paytime < '2022-04-01'

group by BoxSku

) a1 on a1.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202204ҵ��' ,round(sum(GrossProfit)/6.5,1) '202204�����',round(sum(RefundPrice)/6.5,1) '202204�˿���',count(distinct(ordernumber)) '202204����'from import_data.OrderProfitSettle

where paytime >= '2022-04-01' and paytime < '2022-05-01'

group by BoxSku

) a2 on a2.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202205ҵ��' ,round(sum(GrossProfit)/6.5,1) '202205�����',round(sum(RefundPrice)/6.5,1) '202205�˿���',count(distinct(ordernumber)) '202205����'from import_data.OrderProfitSettle

where paytime >= '2022-05-01' and paytime < '2022-06-01'

group by BoxSku

) a3 on a3.BoxSKU = pp.boxsku

left join (

SELECT boxsku,round(sum(income)/6.5,1) '202206ҵ��' ,round(sum(GrossProfit)/6.5,1) '202206�����',round(sum(RefundPrice)/6.5,1) '202206�˿���',count(distinct(ordernumber)) '202206����'from import_data.OrderProfitSettle

where paytime >= '2022-06-01' and paytime < '2022-07-01'

group by BoxSku

) a4 on a4.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202207ҵ��' ,round(sum(GrossProfit)/6.5,1) '202207�����',round(sum(RefundPrice)/6.5,1) '202207�˿���',count(distinct(ordernumber)) '202207����'from import_data.OrderProfitSettle

where paytime >= '2022-07-01' and paytime < '2022-08-01'

group by BoxSku

) a5 on a5.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202208ҵ��' ,round(sum(GrossProfit)/6.5,1) '202208�����',round(sum(RefundPrice)/6.5,1) '202208�˿���',count(distinct(ordernumber)) '202208����'from import_data.OrderProfitSettle

where paytime >= '2022-08-01' and paytime < '2022-09-01'

group by BoxSku

) a6 on a6.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202209ҵ��' ,round(sum(GrossProfit)/6.5,1) '202209�����',round(sum(RefundPrice)/6.5,1) '202209�˿���',count(distinct(ordernumber)) '202209����'from import_data.OrderProfitSettle

where paytime >= '2022-09-01' and paytime < '2022-10-01'

group by BoxSku

) a7 on a7.BoxSKU = pp.boxsku



left join (

SELECT boxsku,round(sum(income)/6.5,1) '202210ҵ��' ,round(sum(GrossProfit)/6.5,1) '202210�����',round(sum(RefundPrice)/6.5,1) '202210�˿���',count(distinct(ordernumber)) '202210����'from import_data.OrderProfitSettle

where paytime >= '2022-10-01' and paytime < '2022-11-01'

group by BoxSku

) a8 on a8.BoxSKU = pp.boxsku

where pp.IsMatrix=0 and pp.boxsku is not null) od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ,'>',od.�弶��Ŀ)) a9

left join

(select concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ,'>',od.�弶��Ŀ) '������Ŀ',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2������·�',

count(distinct case when PayTime>='2021-01-01'and PayTime<'2022-01-01' then left(PayTime,7) end) '2021������·�',

count(distinct case when PayTime>='2022-01-01'and PayTime<'2022-11-01' then left(PayTime,7) end) '2022������·�' from

(select CategoryPathByChineseName,split_part(CategoryPathByChineseName,'>',1)`һ����Ŀ`,split_part(CategoryPathByChineseName,'>',2)`������Ŀ`,split_part(CategoryPathByChineseName,'>',3)`������Ŀ`,split_part(CategoryPathByChineseName,'>',4)`�ļ���Ŀ`,split_part(CategoryPathByChineseName,'>',5)`�弶��Ŀ`,PayTime from OrderProfitSettle od

left join import_data.erp_product_products pp

on od.BoxSku=pp.BoxSKU

and IsMatrix=0

and pp.BoxSKU is not null

join import_data.erp_product_product_category pc

on pc.id=pp.ProductCategoryId

where PayTime>='2021-01-01'

and PayTime<'2022-11-01') od

group by concat(od.һ����Ŀ,'>',od.������Ŀ,'>',od.������Ŀ,'>',od.�ļ���Ŀ,'>',od.�弶��Ŀ)) a7

on a9.������Ŀ=a7.������Ŀ

order by `2�����۶�` desc;











