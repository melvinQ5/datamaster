-- �̳��㣺HAMGD-VD HAMGD-VK  HAMBS-QV

with 

-- ��˾ ����ģ��
select round(sum(TotalGross/ExchangeUSD),2) as `���۶�usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `�����usd`  
	,count(distinct OrderNumber) `������`
	,sum(SaleCount) `������Ʒ����` 
from wt_orderdetails wo
join import_data.wt_store ws on wo.shopcode = ws.Code 
and SettlementTime >= '${StartDay}' and SettlementTime  < '${EndDay}'  
and IsDeleted = 0 and ws.Department in ('������','��ٻ�','MRO������','�̳���')


-- ���� ����ģ��
select ws.Department, round(sum(TotalGross/ExchangeUSD),2) as `���۶�usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `�����usd` 
	,round(sum(TotalGross/ExchangeUSD)/sum(TotalProfit/ExchangeUSD),2) `������`
	,count(distinct OrderNumber) `������`
	,sum(SaleCount) `������Ʒ����` 
from wt_orderdetails wo
join import_data.wt_store ws on wo.shopcode = ws.Code 
and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
and IsDeleted = 0 and ws.Department in ('������','��ٻ�','MRO������')
group by ws.Department 

-- �̳��� ���۶� �����˺�+1���˺�
select 
from 



-- ����+��Ʒ���۶� 
select * from JinqinSku js where monday = '2023-02-11'

-- ��ٻ� ��Ʒ����SPU��
, t_kbh_new_spu as (
	select  count(distinct Spu) `��Ʒ����SPU��`
	from 
	( 
	select Spu, epp.BoxSKU ,ProjectTeam ,DevelopLastAuditTime
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${EndDay}' and DevelopLastAuditTime >= '${StartDay}'
		and IsMatrix = 1 and ProjectTeam='��ٻ�'
	) pt
)

-- ������ ���򿪷�SPU��
, t_tmh_reverse_spu as (
	select  count(distinct SKU) `��Ʒ����SKU��`
	from 
	( 
	select Spu, epp.SKU, epp.BoxSKU ,ProjectTeam ,DevelopLastAuditTime
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${EndDay}' and DevelopLastAuditTime >= '${StartDay}'
		and ProjectTeam='������' 
		and skusource=2
	) pt
)



-- ��ƷN�춯���� 14 ��1-15������  30
select round(tmp.ord14_sku_cnt/prod_spu.new_spu_cnt,3) d14_rate 
	,round(tmp.ord30_sku_cnt/prod_spu.new_spu_cnt,3) d30_rate
from (
	select count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 14 then spu end) ord14_sku_cnt
	, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 30 then spu end) ord30_sku_cnt
	from import_data.wt_products where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
	) tmp
,( 
	select count(distinct Spu) new_spu_cnt
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
		and IsMatrix = 1
	) prod_spu;
	
-- ��Ʒ30�쵥��

-- ��Ʒ������ʡ�ת���� ��Ʒ����  ����ʱ����2023���Ʒ
select  
		round((sum(AdClicks)/ sum(AdExposure)), 4) '�������',
		round((sum(AdSaleUnits)/ sum(AdClicks)), 4) '���ת����'
from import_data.wt_adserving_amazon_daily aa
join ( select eaal.id
-- 	,eaal.SellerSKU ,eaal.ShopCode ,eaal.ASIN 
	from erp_amazon_amazon_listing  eaal
	join erp_product_products epp on eaal.SKU =epp.SKU and DevelopLastAuditTime >= '2023-01-01'
	) al
	on aa.ListingId  = al.id 
where GenerateDate >= '2023-01-01' and GenerateDate <= '2023-01-31'



