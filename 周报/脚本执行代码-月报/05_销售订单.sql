
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union select '�̳���' 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)

,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else '��ٻ�����' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '��'
)

,t_elem as ( -- Ԫ��ά��
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products t_prod on eppaea.sku = t_prod.sku and t_prod.ismatrix = 0 and t_prod.IsDeleted =0 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_orde as (
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,FeeGross 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts ,RefundReason2
	,pp.SPU
	,ms.*
	,elem.ele_boxsku
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
left join wt_products pp on wo.BoxSku=pp.BoxSku
left join ( select spu ,BoxSku as ele_boxsku ,DevelopLastAuditTime from t_elem group by spu ,BoxSku ,DevelopLastAuditTime ) elem 
	on wo.BoxSku = elem.ele_boxsku -- ɸѡԪ��Ʒ
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  -- �ܱ�
-- and OrderStatus !='����'
-- where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)



-- ,t_refd as (
-- select rf.RefundUSDPrice,RefundReason1,RefundReason2 ,ShipDate 
-- 	,ms.*
-- from import_data.daily_RefundOrders rf 
-- join t_mysql_store ms
-- 	on rf.OrderSource=ms.Code and RefundStatus ='���˿�'
-- 		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
-- )

,t_refd as (
select abs(RefundAmount/ExchangeUSD) as RefundUSDPrice,RefundReason1,RefundReason2 , ShipTime as ShipDate 
	,ms.*
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=wo.shopcode and ms.department='��ٻ�'
where wo.IsDeleted = 0 and TransactionType = '�˿�' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)

,t_adse as (
select 
	ad.ShopCode ,ad.SellerSKU ,ad.Asin ,ad.Spend as AdSpend 
	,ad.TotalSale7Day as AdSales 
	,ad.AdOtherSale7Day as AdSales_othersku
		,ms.*
from t_mysql_store ms
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >='${StartDay}' and ad.CreatedTime< '${NextStartDay}'
		and ad.ShopCode = ms.Code  
)

,t_new_list as ( -- �¿�������ά��
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.department ,ms.NodePathName
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4  and IsDeleted = 0 
)



-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
,t_sale_stat as ( 
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `˰�����۶�`
	,round( sum(TotalExpend/ExchangeUSD)) `��������֧��`
	,round( sum(ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `��������ͳһ�۳�`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `�������������ܳɱ�`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `�վ�������`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `Ԫ�����۶�`
from t_orde 
group by grouping sets ((),(department))
union
select '��ٻ�' as department
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `˰�����۶�`
	,round( sum(TotalExpend/ExchangeUSD)) `��������֧��`
	,round( sum(ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `��������ͳһ�۳�`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `�������������ܳɱ�`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `�վ�������`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `Ԫ�����۶�`
from t_orde 
where t_orde.department regexp '��' 
union
select NodePathName
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `˰�����۶�`
	,round( sum(TotalExpend/ExchangeUSD)) `��������֧��`
	,round( sum(ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `��������ͳһ�۳�`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `�������������ܳɱ�`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `�վ�������`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `Ԫ�����۶�`
from t_orde where t_orde.department regexp '��' 
group by NodePathName
)

,t_fee_stat as (
select '��ٻ�' as dep 
	,round( sum( FeeGross/ExchangeUSD )) `�˷�����`
from t_orde 
left join ( select ordernumber  from import_data.daily_RefundOrders
	where RefundReason2 = '�Ӽ����ӳ�' group by ordernumber ) t on t_orde.ordernumber = t.ordernumber 
where t_orde.department regexp '��' and t.ordernumber is null 
union 
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,round( sum( FeeGross/ExchangeUSD )) `�˷�����`
from t_orde 
left join ( select ordernumber  from import_data.daily_RefundOrders
	where RefundReason2 = '�Ӽ����ӳ�' group by ordernumber ) t on t_orde.ordernumber = t.ordernumber 
where t_orde.department regexp '��' and t.ordernumber is null 
group by grouping sets ((),(department))
)
	
	
,t_refd_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(RefundUSDPrice) `�˿���`
	,sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01') then RefundUSDPrice end) `�ǿͻ�ԭ���˿���` 
from t_refd group by grouping sets ((),(department))
union
select '��ٻ�' as department
	,sum(RefundUSDPrice) `�˿���`
	,sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01') then RefundUSDPrice end) `�ǿͻ�ԭ���˿���` 
from t_refd where t_refd.department regexp '��' 
union
select NodePathName
	,sum(RefundUSDPrice) `�˿���`
	,sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01') then RefundUSDPrice end) `�ǿͻ�ԭ���˿���` 
from t_refd group by NodePathName
)


,t_adse_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(AdSpend) `�����滨��` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse group by grouping sets ((),(department))
union
select '��ٻ�' as department ,sum(AdSpend) `�����滨��` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse where t_adse.department regexp '��' 
union
select NodePathName,sum(AdSpend) `�����滨��` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse group by NodePathName
)



,t_adse_new_lst as ( -- �¿������ӹ��
select case when t_adse.department IS NULL THEN '��˾' ELSE t_adse.department END AS dep 
	,sum(AdSales) as new_lst_ad_sales
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_adse.department))
union 
select '��ٻ�' as department 
	,sum(AdSales) as new_lst_ad_sales
from t_adse
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '��'  
union 
select t_adse.NodePathName
	,sum(AdSales) as new_lst_ad_sales
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '��' 
group by t_adse.NodePathName
)




-- ���˼���
-- select sum(FrozenAmountUs) `���˽��` -- ʹ��ʵ�۶�����Ԫ�� ��Ϊ���㻵�˵Ľ���ֶ�
-- from import_data.BadDebtRate 
-- where ExceptionNotifyTime >= '2023-04-01' and ExceptionNotifyTime < '2023-05-01' -- 4�»���(���쳣֪ͨʱ��)
-- and `Date` in ( select max(`Date`) Date from BadDebtRate ) -- ʹ�����µ������ݰ汾


-- ,t_ele_sale_over1000_monthly as (
-- select department as dep ,count(1) `������1000����Ԫ������`
-- from (
-- 	select elem.name , ms.department ,round(sum(TotalGross/ExchangeUSD),2) as ele_sales
-- 	from import_data.wt_orderdetails wo 
-- 	join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 and ms.Department ='��ٻ�'
-- 	join ( select name ,BoxSku as ele_boxsku from t_elem group by name ,BoxSku) elem on wo.BoxSku = elem.ele_boxsku -- ɸѡԪ��Ʒ
-- 	where PayTime < '${NextStartDay}' and PayTime >=DATE_ADD('${StartDay}',interval -day('${StartDay}')+1 day) 
-- 	group by elem.name , ms.department
-- 	) tmp2
-- where ele_sales >= 1000 
-- group by department
-- )


-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep 
	,t_sale_stat.`˰�����۶�` 
	,t_sale_stat.`�������������ܳɱ�` ,t_sale_stat.`�վ�������` ,t_sale_stat.`Ԫ�����۶�`  
	,ifnull(t_refd_stat.`�˿���`,0) `�˿���` ,ifnull(t_refd_stat.`�ǿͻ�ԭ���˿���`,0) `�ǿͻ�ԭ���˿���`
	,t_adse_stat.`�����滨��` 
	,t_adse_stat.Adsale ,t_adse_stat.AdSales_othersku ,t_adse_stat.Acost
	,t_adse_new_lst.new_lst_ad_sales
	,`�˷�����` 
-- 	,t_ele_sale_over1000_monthly.`������1000����Ԫ������`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_refd_stat on t_key.dep = t_refd_stat.dep
left join t_sale_stat on t_key.dep = t_sale_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_fee_stat on t_key.dep = t_fee_stat.dep
-- left join t_ele_sale_over1000_monthly on t_key.dep = t_ele_sale_over1000_monthly.dep
)


-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,dep `�Ŷ�` 
	,round(`˰�����۶�`-`�˿���`,2) `���۶�`
	,round(`˰�����۶�`-`�˿���`+(`�������������ܳɱ�`-`�����滨��`),2) `�����`
	,round( (`˰�����۶�`-`�˿���`+(`�������������ܳɱ�`-`�����滨��`))/(`˰�����۶�`-`�˿���`) ,3) `ë����`
	,`˰�����۶�`
	,`�˿���`
	,`�������������ܳɱ�`
	,round(`�վ�������`) `�վ�������`
	,round(`�˿���`/`˰�����۶�`,4) `�˿���`
	,round(`�ǿͻ�ԭ���˿���`/`˰�����۶�`,4) `�ǿͻ�ԭ���˿���`
	,`�ǿͻ�ԭ���˿���`
	,`�����滨��`
	,round(`�����滨��`/Adsale,4) `ACOS`
	,round(Adsale/`�����滨��`,4) `���ROI`
	,round(`�����滨��`/(`˰�����۶�`-`�˿���`),4) `��滨��ռ��`
	,round(Adsale/(`˰�����۶�`-`�˿���`),4) `���ҵ��ռ��`	
	,round(AdSales_othersku/(`˰�����۶�`-`�˿���`),4) `�ǹ���Ʒҵ��ռ��`	
	,round(new_lst_ad_sales/(`˰�����۶�`-`�˿���`),4) `�¿��ǹ��ҵ��ռ��`	
-- 	,`���˽��`
-- 	,`�Ŷ�����`
-- 	,`���۶���Ч`
-- 	,`�������Ч`
	,`Ԫ�����۶�`
	,`�˷�����`
	,round(`�˷�����`/(`˰�����۶�`-`�˿���`),4) `�˷�����ռ��`
	,round(`Ԫ�����۶�`/(`˰�����۶�`-`�˿���`),4) `Ԫ�����۶�ռ��`
-- 	,`������1000����Ԫ������`
from t_merge
order by `�Ŷ�` desc 