/*
 * ÿ�ܿ������Ӷ�������
 * ά�ȣ����� x ��Ա x ������ �� ������
 * ָ�꣺�����������Ӷ���ָ��
 *
 * �ο�ҵ��EXCEL������ʹ�ô�����ƽ̨����Դ����
 * ҵ������߼����£�
 * sheet�������󱨱�
 * 		����sheet�������󱨱� (������ʱ������2��)
 * 		���ӹ����ֶ� concat(�����˺�,����SKU)
 * sheet����SKU
 * 		��������\�Զ��屨��\����sku���������ʱ������2�£�
 * 		���ӹ����ֶ� concat(�����˺�,����SKU)
 * 		����ά���ֶ� ����listing�����ڱ�ʶ�Ƿ����
 * 		����ָ���ֶ� SUMIF(�������󱨱�!$E:$E,$E1,�������󱨱�!Y:Y) as ������
 * 		���ݶ������󱨱�����ݼ���ÿ�����ӵ�ָ��
 * ����������ĸ��Ե�ά�Ⱦۺ�ָ��
 *
 * ERP���ӿ⣬������code����ɸѡ��ٻ�
 * ҵ�������޳���� =��ͨ��sellersku���޳�BJ  not regexp '-BJ-|-BJ|BJ-'
 * ҵ������SQL����Դʹ�õ���ERPlisting�������������������
 * ҵ������ʹ������sku���ʱ�� =��ʹ��listing����ʱ��
 * ����SKU
 */


with 
t_orde as (  -- ÿ�ܳ�����ϸ
select 
	WEEKOFYEAR( paytime) pay_week 
	,MONTH( paytime)  pay_month
	,year(paytime) pay_year
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName 
	,ms.Code as shopcode 
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
-- 	and paytime >= '2022-01-01' and paytime <'2023-04-01'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
) 


,t_list as ( -- 23���ڿ�������
select distinct a.*
    ,dd.week_num_in_year pub_week
    ,dd.week_begin_date as pub_week_begin_date
from (
select wl.BoxSku ,wl.SKU ,MinPublicationDate_new as MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,wl.ASIN
    ,MONTH( MinPublicationDate_new) pub_month
	,year( MinPublicationDate_new) pub_year
	,ms.department ,case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2  ,ms.NodePathName
--	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
    ,Publisher as SellUserName
from wt_listing wl
left join
    ( select asin, MarketType ,min(PublicationDate) as MinPublicationDate_new
    from wt_listing wl join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.department = '��ٻ�' group by asin ,MarketType ) t1
    on wl.asin = t1.ASIN and wl.MarketType =t1.MarketType
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where
	MinPublicationDate_new>= '${StartDay}' and MinPublicationDate_new <'${NextStartDay}'
	-- and wl.IsDeleted = 0
	and ms.Department = '��ٻ�'
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
) a
left join dim_date dd on date(a.MinPublicationDate) = dd.full_date
)

-- select count(1) from t_list

, t_list_stat as ( -- ��1 ���Ǽ���
select 
	dep2 , SellUserName  ,NodePathName ,pub_year ,pub_month
	,count(distinct BoxSku)  `����SKU��`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `����������`
from t_list
group by dep2 ,SellUserName ,NodePathName ,pub_year ,pub_month
)

, t_list_sale_details as ( -- ��1 ÿ��������ÿ�ܵĳ������
select 
	t_list.dep2 ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,pub_year ,pub_month 
	,od.boxsku  ,pay_year ,pay_month ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
join (
	select boxsku ,sellersku ,shopcode  ,pay_year ,pay_month
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku ,sellersku ,shopcode ,pay_year ,pay_month
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku
)
-- select sum(TotalGross) `���۶�` from t_list_sale_details	
	
,t_list_sale_stat as (
select dep2  , SellUserName  ,pay_year ,pay_month  ,pub_year ,pub_month 
	,sum(salecount) `����`  
	,sum(TotalGross) `���۶�` 
	,sum(TotalProfit) `�����` 
	,count(distinct concat(shopcode,sellersku)) `����������`
	,count(distinct boxsku) `����sku��`
from t_list_sale_details
group by dep2 ,SellUserName ,pay_year ,pay_month  ,pub_year ,pub_month 
)

, t_merge as (    
select 
	t_list_stat.dep2 
	,t_list_stat.NodePathName
	,t_list_stat.SellUserName
	,pay_year ,pay_month
	,t_list_stat.pub_year ,t_list_stat.pub_month 
	,t_list_stat.`����SKU��`  
	,t_list_stat.`����������`  
	,t_list_sale_stat.`����` 
	,t_list_sale_stat.`���۶�` 
	,t_list_sale_stat.`�����` 
	,t_list_sale_stat.`����������` 
	,t_list_sale_stat.`����sku��` 
from t_list_stat 
left join t_list_sale_stat 
on t_list_sale_stat.dep2 = t_list_stat.dep2 and t_list_sale_stat.SellUserName = t_list_stat.SellUserName
and t_list_sale_stat.pub_year = t_list_stat.pub_year 
and t_list_sale_stat.pub_month = t_list_stat.pub_month 
)
-- select * from t_merge

-- ���� ����-��Ա-���¿��Ƕ���ͳ��
select

	dep2 `�Ŷ�`
    ,case when length(t_merge.SellUserName) = 0 then '��������Դ�޿����˼�¼' else t_merge.SellUserName end as `���ӿ�����Ա`
	,t_merge.NodePathName `���̵�ǰС��`
	,pay_year `������`
	,pay_month  `������`
	,pub_year `������`
	,pub_month `������`
	,`����`
	,round(`���۶�`,2) ���۶�
	,round(`�����`,2) �����
	,concat(round(`�����`/`���۶�`*100,2),'%') `ë����`
	,`����������`
	,`����������`
	,concat(round(`����������`/`����������`*100,2),'%') `���ӳ�����`
	,`����SKU��`
	,`����SKU��`
	,concat(round(`����SKU��`/`����SKU��`*100,2),'%') `SKU������`
	,round(`���۶�`/ `����������`,1) `�������ӵ���` 
	,round(`���۶�`/ `����sku��`,1) `����sku����` 
from t_merge
where !(pay_year = pub_year and pay_month < pub_month) 
order by dep2 ,NodePathName , t_merge.SellUserName ,pay_year ,pay_month  ,pub_year ,pub_month 

-- 


