/*ȫ��ҵ��*/

select pp.boxsku, pp.ProductName`��Ʒ������`,wp.TortType`��Ȩ����`,wp.Logistics_Group_Attr,wp.Festival`���ڽ���`
,pp.ProductStatus`��Ʒ״̬`,`21������·�`,`22������·�`,`��30���������`,`12�³�������`,��90���������
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -30 day),'%Y/%m/%d') `��30��ͳ�ƿ�ʼ����`
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -90 day),'%Y/%m/%d') `��90��ͳ�ƿ�ʼ����`
,DATE_FORMAT(DATE_ADD( CURRENT_DATE(),interval -1 day),'%Y/%m/%d') `ͳ�ƽ�ֹ����`
from import_data.erp_product_products pp
left join (select distinct Sku,Logistics_Group_Attr,TortType, Festival  
from import_data.wt_products) wp on pp.SKU = wp.Sku


left join (
SELECT boxsku, count(distinct( left(PayTime,7) )) '21������·�'from import_data.OrderProfitSettle op 
where paytime >= '2021-01-01' and paytime < '2022-01-01' and OrderStatus<>'����' and TransactionType='����'
group by BoxSku
) a10 on a10.BoxSKU = pp.boxsku


left join (
SELECT boxsku, count(distinct( left(PayTime,7) )) '22������·�'from import_data.OrderProfitSettle op 
where paytime >= '2022-01-01' and paytime < '2022-12-01' and OrderStatus<>'����' and TransactionType='����'
group by BoxSku

) a11 on a11.BoxSKU = pp.boxsku



left join 
/*��30���������*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '��30���������' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime >= DATE_ADD( CURRENT_DATE(),interval -30 day) 
-- '2022-11-12'
and BoxDataTime < CURRENT_DATE() 
-- '2022-12-14'
group by BoxSKU) sd
on pp.BoxSku=sd.BoxSKU

left join
/*12�³�������*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '12�³�������' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime>='2022-12-01'
and BoxDataTime < CURRENT_DATE() 
group by BoxSKU) sd1
on pp.BoxSku=sd1.BoxSKU

left join 
/*��90���������*/
(select BoxSKU,count(distinct left(BoxDataTime,10)) '��90���������' from erp_amazon_amazon_order_source_sku_dayreport od
where BoxDataTime>=DATE_ADD( CURRENT_DATE(),interval -90 day)
and BoxDataTime<CURRENT_DATE() 
group by BoxSKU) sd2
on pp.BoxSku=sd2.BoxSKU

where pp.IsMatrix=0 and pp.boxsku is not null and pp.IsDeleted=0 and ProductStatus<>2 

