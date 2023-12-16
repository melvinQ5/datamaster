/*
 * SKUͳ�Ʒ�Χ��ͳ������-sku����ʱ�� <= 30��
 * ����ͳ�Ʒ�Χ����ٻ��������������� ��ͳ������-sku����ʱ�� <= 30��
 * ������Աͳ�Ʒ�Χ��'����ϼ' ,'�����' ,'�ķ�','��ٻ' ,'����' ,'������'
 * �վ�����sku����(�վ�����) = �ܳ���sku���� �� ��ͳ������-sku����ʱ�䣩
 */

with 
wp as ( 
select  BoxSku ,DevelopLastAuditTime ,DevelopUserName ,sku
	, case when DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�') then '���Ԫ'
		when DevelopUserName in ('��ٻ' ,'����' ,'������') then '��η�'
	end as team1
from wt_products wp 
where DevelopLastAuditTime >= DATE_ADD(CURRENT_DATE() ,-90) and DevelopLastAuditTime < CURRENT_DATE()  
	and IsDeleted = 0 and  DevelopUserName in ('����ϼ' ,'�����' ,'�ķ�','��ٻ' ,'����' ,'������')
)


, orders as (
select 
	datediff(CURRENT_DATE()-1 ,DevelopLastAuditTime) test_days -- ����ʱ��
	, PlatOrderNumber ,OrderNumber ,wp.BoxSku
	, paytime ,DevelopLastAuditTime
	, shopcode ,SellerSku,Asin
	, TotalProfit , TotalGross ,RefundAmount ,ExchangeUSD
from import_data.wt_orderdetails wo 
join wp on wo.BoxSku = wp.boxsku
where wo.IsDeleted = 0 and TransactionType ='����' 
	and wo.Department = '��ٻ�'
)


, ord_cnt as ( -- ������
select boxsku 
	,test_days 
	,count(distinct PlatOrderNumber) as ord_cnt 
	,count(distinct concat(shopcode,SellerSku,Asin)) `����������`
	,round(sum((TotalGross + RefundAmount)/ExchangeUSD),2) `���۶�` -- ����ȥ�˵����˿�(����)
	,round(sum((TotalProfit + RefundAmount)/ExchangeUSD),2) `�����` -- ����ȥ�˵����˿�(����)
	,round(sum((TotalGross + RefundAmount)/ExchangeUSD)/sum((TotalProfit + RefundAmount)/ExchangeUSD),4) `������`
from orders group by boxsku ,test_days
)

, listing_cnt as ( 
select wp.BoxSku ,count(distinct concat(ShopCode ,SellerSKU ,ASIN)) `����������` ,min(PublicationDate) `�״ο���ʱ��`
from import_data.erp_amazon_amazon_listing eaal 
join wp on eaal.BoxSku = wp.Boxsku
-- where ListingStatus =1
group by wp.boxsku , ShopCode ,SellerSKU ,ASIN
)

-- select ROW_NUMBER () over (partition by boxsku order by `�վ�����sku����`desc ) as `��������` 
-- 	, tmp.*
-- from (
	select wp.team1 `�Ŷ�` 
		,wp.DevelopUserName `������Ա` 
		,wp.sku ,wp.boxsku
		,to_date(wp.DevelopLastAuditTime) `��������`
		,ord_cnt.`���۶�` ,ord_cnt.`�����` , DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `����ͳ�ƽ�ֹ����`
		,listing_cnt.`�״ο���ʱ��` 
		,round(ord_cnt/test_days , 2) `�վ�����sku����`
	-- 	,listing_cnt. `����������` 
		,ord_cnt.`����������` 
	-- 	,round(`����������`/`����������` , 1) `���Ӷ�����`
	from wp 
	left join ord_cnt on ord_cnt.boxsku = wp.boxsku
	left join listing_cnt on listing_cnt.boxsku = wp.boxsku
	order by `�վ�����sku����` desc 
-- ) tmp 