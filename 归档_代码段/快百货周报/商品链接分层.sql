-- ��ձ�
-- truncate table import_data.ads_ag_staff_kbh_report_weekly;
team ���ַ������Ȳ��� ����Ҫɾ���ؽ�
 insert into import_data.ads_ag_staff_kbh_report_weekly (`FirstDay`, `AnalysisType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
 SpuCnt ,SpuStopCnt ,SpuSaleCntIn30d ,SpuUnitSaleIn30d ,SpuSaleRateIn30d 
 ,TopSaleSpuCnt,TopSaleSpuCntIn30dDev ,HotSaleSpuCnt,HotSaleSpuCntIn30dDev
 ,TopSaleSpuAmount ,HotSaleSpuAmount ,TopSaleSpuValue ,HotSaleSpuValue ,TopSaleSpuValueIn30dDev ,HotSaleSpuValueIn30dDev
 ,TopSaleSpuRate ,HotSaleSpuRate,TopHotStopSpuRate
 ,NewSpuCntIn90dDev ,SaleSpuCntIn90dDev ,FirstSaleSpuCnt ,NewDevSpuCnt ,NewAddSpuCnt ,SaleAmountIn30dDev  ,StopSkuRateIn30dDev)
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��ٻ�' as dep 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)

,t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select 
	Code 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' 
		when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�'  else department 
		end as department
	,NodePathName
	,CompanyCode 
	,department as department_old
	,Site
	,case when AccountCode in ('MP-EU','NY-EU','B209-EU','SH-EU','MQ-EU','PX-EU','B209-NA','MR-EU','MR-AU','PP-EU','PK-EU','UH-NA','UL-NA','UI-NA','ST-EU','SW-EU','QJ-EU') 
		then '�ݼ���' else ShopStatus end as ShopStatus
from import_data.mysql_store
)

,t_erp_sku as (
select case when ProjectTeam is null then '��˾' else ProjectTeam end as dep
	,count(distinct SKU) `��Ʒ��SKU��`
	,count(distinct SPU) `��Ʒ��SPU��`
from import_data.erp_product_products epp 
where IsDeleted = 0 and ProductStatus != 2 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))
)

,t_erp_stop_sku as ( 
select '��ٻ�'  as dep
	,count(distinct SPU) as ̭��SPU�� --  SpuStopCnt 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null
	and date_add(ProductStopTime, INTERVAL - 8 hour) >= '${StartDay}'
	and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}'
)

,t_erp_stop_in30d_sku as ( 
select '��ٻ�'  as dep
	,count(distinct SPU) as ��30��̭��SPU�� 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null
	and date_add(ProductStopTime, INTERVAL - 8 hour) >= date_add('${NextStartDay}',interval - 30 day )
	and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}'
) 


,t_orde_in30d as ( -- ��30�충��
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,feegross
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts 
	,wo.shopcode ,wo.asin ,wo.boxsku ,PayTime 
	,wo.Product_SPU as spu 
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
	and TransactionType <> '����'  and asin <>'' -- ÿ�»��м�ʮ���ϰ�����������û��ASIN
	and ms.department regexp '��' 
)

,od_list_in30d as ( -- site,asin,spu,boxsku �ۺ�
select asin,site,spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- ���˿���˷�
	,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit_no_freight
	,count(distinct platordernumber) orders
	,round(sum(feegross/ExchangeUSD),2) freightfee
	,round(sum(-RefundAmount),2) refund
	,date(min(paytime)) pay_min_time
	,datediff(date_add(CURRENT_DATE(),INTERVAL -2 day)
	,date(min(paytime))) saledays
	,count(distinct date(PayTime))solddays,round(sum((totalgross-feegross)/ExchangeUSD)/( datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))),2) `�վ�����`
	,row_number() over(order by count(distinct platordernumber) desc ) as ordersort,row_number() over(order by  round(sum((totalgross-feegross)/ExchangeUSD),2)  desc ) as salessort
from t_orde_in30d 
group by site,asin,spu,boxsku
)
-- select * from od_list_in30d 

-- ��Ʒ�ֲ�
,prod_mark as ( -- spu�ۺ�
select t.spu
	, case when sales >=1500 then '����' when sales>=500 and sales<1500 then'����' end as prod_level
	, sales 
	, s.ProductStatus
from (
	select spu ,sum(sales_no_freight) sales 
	from od_list_in30d group by spu 
	) t 
left join ( select spu , ProductStatus from import_data.erp_product_products epp 
	where IsDeleted = 0 and ismatrix = 1 and DevelopLastAuditTime is not null 
	) s on t.spu = s.spu
)
-- select * from prod_mark

,t_new_prod as ( -- �����ٻ��ܱ���Ʒ������ʱ���ڽ�90���SPU������2023-03-01
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, epp.ProductStatus 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-03-01'  
	and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= date_add('${NextStartDay}',interval - 90 day) 
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='��ٻ�' 
)

,t_new_prod_stat as ( -- ��90�쿪����Ʒ��
select '��ٻ�' as dep 
,count(spu) ��90������SPU��
,count(case when ProductStatus = 2 then spu end ) ��90��������ͣ��SPU��
,count(case when date_add(DevelopLastAuditTime, INTERVAL - 8 hour) >= '${StartDay}' 
	and date_add(DevelopLastAuditTime, INTERVAL - 8 hour) >= '${NextStartDay}'  then spu end ) ����SPU�� -- ͳ��������
from t_new_prod
)

,t_add_prod_stat as ( -- �����Ʒ��
select '��ٻ�' as dep 
	,count(spu) ���SPU��
from import_data.erp_product_products epp
where date_add(epp.CreationTime , INTERVAL - 8 hour) >= '${StartDay}' 
	and date_add(epp.CreationTime, INTERVAL - 8 hour) >= '${NextStartDay}'
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='��ٻ�' 
)

,t_orde as ( -- ͳ���ڶ���
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,feegross
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts ,wo.shopcode ,wo.Asin 
	,wo.Product_SPU as spu 
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
)

,t_new_prod_od_stat as ( -- ��Ʒ����
select '��ٻ�' as dep 
,count(distinct a.spu) ��Ʒ����SPU�� 
,round(sum((totalgross-feegross)/ExchangeUSD),2) ��Ʒ�����˷����۶�
from t_orde a  join t_new_prod b on a.spu =b.spu 
)

,t_min_pay_spu as ( -- �׵�SPU 
select '��ٻ�' as dep , count(1) �׵�SPU��
from (
	select  product_spu as spu  ,min(PayTime) as min_pay_time 
	from wt_orderdetails  wo
	where IsDeleted = 0 and orderstatus != '����' and department = '��ٻ�'
	group by product_spu 
	) a 
where min_pay_time >='${StartDay}' and min_pay_time<'${NextStartDay}'	
)


,t_prod_mark_stat as ( -- ����SPU�б�Ǳ����� 
select '��ٻ�' as dep
	,count(case when prod_level = '����' then 1 end ) ��30������SPU��
	,count(case when prod_level = '����' then 1 end ) ��30�챬��SPU��
	,sum(case when prod_level = '����' then sales end ) ��30�챬��SPU���۶�
	,sum(case when prod_level = '����' then sales end ) ��30������SPU���۶�
	,count(case when prod_level regexp '����|����' and a.ProductStatus = 2 then 1 end ) ������ͣ��SPU��
	,count(case when prod_level regexp '����|����'  then 1 end ) ������SPU��
	
	,count(case when prod_level = '����' and b.spu is not null then 1 end ) ��Ʒ����SPU��
	,count(case when prod_level = '����' and b.spu is not null then 1 end ) ��Ʒ����SPU��
	,sum(case when prod_level = '����' and b.spu is not null then sales end ) ��Ʒ����SPU���۶�
	,sum(case when prod_level = '����' and b.spu is not null then sales end ) ��Ʒ����SPU���۶�
from prod_mark a 
left join t_new_prod b on a.spu =b.spu 
)
-- select * from t_prod_mark_stat

,t_od_stat as (
select '��ٻ�' as dep
	,count(distinct spu) ��30�춯��SPU��
	,sum(sales_no_freight) �����˷����۶�
from od_list_in30d
)
-- select * from t_od_stat

-- ���ӷֲ�
,list_mark as ( -- site,asin �ۺ�
select site ,asin ,sales
	,case when list_orders >=15 THEN 'S' when list_orders >=5 THEN 'A' END as list_level
from (
	select site ,asin ,sum (orders) list_orders ,sum(sales_no_freight) sales
	from od_list_in30d group by site ,asin 
	) t 
-- left join ( select site ,asin , ListingStatus  -- site ,asin ���ж�������״̬
-- 	from erp_amazon_amazon_listing eaal join t_mysql_store ms 
-- 	on eaal.ShopCode = ms.Code  and ms.ShopStatus = '����' group by 
-- 	) s on t.site = s.site and t.asin = s.asin    '`'ProductStatus' `' 
) 

,t_list_mark_stat as ( 
select '��ٻ�' as dep
	,count(case when list_level = 'S' then 1 end ) S��������
	,count(case when list_level = 'A' then 1 end ) A��������
	,sum(case when list_level = 'S' then sales end ) S���������۶�
	,sum(case when list_level = 'A' then sales end ) A���������۶�
from list_mark
)
-- select * from t_list_mark_stat

,t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department 
	,CompanyCode
from erp_amazon_amazon_listing eaal 
join t_mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department regexp '��ٻ�' 
	and ShopStatus='����'
	and listingstatus = 1  
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
)

,t_large_shop as (
select '��ٻ�' dep , count(case when ��ٻ������˺���>6 then sku end ) ���ߵ��̳���SKU��
from (
	SELECT sku  ,count(distinct CompanyCode ) ��ٻ������˺���
	from t_list 
	group by sku
	) t 
)

,t_merge as (
select 
	'${StartDay}' ,concat(t_key.dep,'x�ܱ�') ,t_key.dep ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 
	-- ��Ʒ��Ӫ
	,��Ʒ��SPU�� -- SpuCnt
	,̭��SPU�� -- SpuStopCnt
	,��30�춯��SPU�� -- SpuSaleCntIn30d
	,round(�����˷����۶�/��30�춯��SPU��,2) as ƽ������SPU���� -- SpuUnitSaleIn30d
	,round(��30�춯��SPU��/(��Ʒ��SPU��+��30��̭��SPU��),2) as SPU�⶯���� -- SpuSaleRateIn30d
	,��30�챬��SPU�� -- TopSaleSpuCnt
	,��Ʒ����SPU�� -- TopSaleSpuCntIn30dDev
	,��30������SPU�� -- HotSaleSpuCnt
	,��Ʒ����SPU�� -- HotSaleSpuCntIn30dDev
	,��30�챬��SPU���۶� -- TopSaleSpuAmount
	,��30������SPU���۶� -- HotSaleSpuAmount
	,round(��30�챬��SPU���۶�/��30�챬��SPU��,2) as ����SPU���� -- TopSaleSpuValue
	,round(��30������SPU���۶�/��30������SPU��,2) as ����SPU���� -- HotSaleSpuValue
	,round(��Ʒ����SPU���۶�/��Ʒ����SPU��,2) as ��Ʒ����SPU���� -- TopSaleSpuValueIn30dDev
	,round(��Ʒ����SPU���۶�/��Ʒ����SPU��,2) as ��Ʒ����SPU���� -- HotSaleSpuValueIn30dDev
	,round(��30�챬��SPU���۶�/�����˷����۶�,2) as ����SPU���۶�ռ�� -- TopSaleSpuRate
	,round(��30������SPU���۶�/�����˷����۶�,2) as ����SPU���۶�ռ�� -- HotSaleSpuRate
	,round(������ͣ��SPU��/������SPU��,2) as ������SPṶ���� -- TopHotStopSpuRate
	
	-- ��Ʒ����-��Ʒ 
	,��90������SPU��  -- NewSpuCntIn90dDev
	,��Ʒ����SPU�� -- SaleSpuCntIn90dDev
	,�׵�SPU�� -- FirstSaleSpuCnt
	,����SPU�� -- NewDevSpuCnt
	,���SPU�� -- NewAddSpuCnt
	,��Ʒ�����˷����۶� -- SaleAmountIn30dDev
	,round(��90��������ͣ��SPU��/��90������SPU��,2) as ��Ʒͣ��SKUռ�� -- StopSkuRateIn30dDev
	
-- --	,���ߵ��̳���SKU��
-- --	-- ���ӷֲ�
-- --	,S��������
-- --	,A��������
-- --	,S���������۶�
-- --	,round(S���������۶�/S��������,2) as S�����ӵ���
-- --	,round(A���������۶�/A��������,2) as A�����ӵ���
-- --	,round(S���������۶�/�����˷����۶�,2) as S��ҵ��ռ��
-- --	,round(A���������۶�/�����˷����۶�,2) as A��ҵ��ռ��
	
	
from t_key
left join t_prod_mark_stat on t_key.dep = t_prod_mark_stat.dep
left join t_od_stat on t_key.dep = t_od_stat.dep
left join t_list_mark_stat on t_key.dep = t_list_mark_stat.dep
left join t_erp_sku on t_key.dep = t_erp_sku.dep
left join t_erp_stop_sku on t_key.dep = t_erp_stop_sku.dep
left join t_erp_stop_in30d_sku on t_key.dep = t_erp_stop_in30d_sku.dep
left join t_large_shop on t_key.dep = t_large_shop.dep
left join t_add_prod_stat on t_key.dep = t_add_prod_stat.dep
left join t_new_prod_stat on t_key.dep = t_new_prod_stat.dep
left join t_new_prod_od_stat on t_key.dep = t_new_prod_od_stat.dep
left join t_min_pay_spu on t_key.dep = t_min_pay_spu.dep
) 

select *from t_merge 




