-- �Ŷ�����
-- ʹ�ÿ����� ÿ����һ��洢
with 
ords as (
select * 
from (
SELECT
	wo.Department, wo.shopcode
	,DATE_FORMAT(wl.PublicationDate,"%Y%m") as pub_month
	,DATE_FORMAT(wo.SettlementTime ,"%Y%m") as set_month
	,wo.OrderNumber ,wo.SellerSku ,wo.BoxSku
   	,sum(wo.TotalGross/ExchangeRMB) as TotalGross_g 
   	,sum(wo.TotalProfit/ExchangeRMB) as TotalProfit_g 
from import_data.wt_orderdetails wo
join import_data.wt_listing wl on wo.SellerSku =wl.SellerSKU and wo.shopcode = wl.ShopCode and wl.SellerSKU not regexp '-BJ-|-BJ|BJ-' 
where wo.SettlementTime >= '2022-04-01' and wl.PublicationDate >= '2022-04-01'
group by wo.Department, wo.shopcode
	,DATE_FORMAT(wl.PublicationDate,"%Y%m")
	,DATE_FORMAT(wo.SettlementTime ,"%Y%m")
	,wo.OrderNumber ,wo.SellerSku ,wo.BoxSku) tmp 
where pub_month <= set_month
)



, order_res as ( -- ��������
select Department ,pub_month ,set_month 
	,sum(TotalGross_g) as sales
    ,sum(TotalProfit_g) as profit
    ,count(distinct OrderNumber) as ord_cnt -- ������
   	,count(distinct BoxSku) as ord_sku_cnt -- ����sku��
   	,count(distinct concat(SellerSku,shopcode)) as ord_listing_cnt -- ����������
from ords 
group by Department,pub_month ,set_month 
)

, list_res as ( -- �ϼ�����
select ws.Department 
	, DATE_FORMAT(wl.PublicationDate,"%Y%m") pub_month
	, count(distinct Id) as pub_listing_cnt
	, count(distinct Sku) as pub_sku_cnt
from import_data.wt_listing wl 
join import_data.wt_store ws on wl.ShopCode = ws.Code
where wl.PublicationDate >= '2022-04-01'
group by ws.Department ,StoreOperateMode
	, DATE_FORMAT(wl.PublicationDate,"%Y%m") 
)
	

SELECT
    CASE
        WHEN or1.Department = '����һ��' THEN 'GM-����1��'
        WHEN or1.Department = '���۶���' THEN 'PM-����2��'
        WHEN or1.Department = '��������' THEN 'PM-����3��'
    END AS `���۲���`
    ,CASE
        WHEN or1.Department = '����һ��' THEN 'GM'
        WHEN or1.Department IN ('���۶���', '��������') THEN 'PM'
    END AS `ģʽ`
    ,or1.pub_month `�ϼ��·�`
    ,or1.set_month `�����·�`
    ,or1.sales `�������۶�`
    ,or1.profit `���������`
    ,round(or1.profit/or1.sales,4) `������` -- ������
	,or1.ord_cnt `���¶�����` -- ������
	,round(or1.sales/or1.ord_cnt,1) `�͵���` -- �͵���
   	,or1.ord_sku_cnt `����sku��`
   	,lr.pub_sku_cnt `����sku��`
   	,round(or1.ord_sku_cnt/lr.pub_sku_cnt,4) `SKU������`
   	,or1.ord_listing_cnt `����������`
   	,lr.pub_listing_cnt `����������`
   	,round(or1.ord_listing_cnt/lr.pub_listing_cnt,4)  `���ӳ�����`
   	,round(lr.pub_listing_cnt/lr.pub_sku_cnt,4)  `ƽ��SKU������`
FROM
    order_res or1
LEFT join list_res lr ON or1.Department = lr.Department AND or1.pub_month = lr.pub_month

