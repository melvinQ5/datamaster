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
 * 
 * ��֤��������SKU�����棬�����ʱ�����ص����� ��ΪA 
 * ERP���ӿ��������ΪB���Ա�AB����
 * 
 * ��������SKU�����޳���ҡ��޳����ƣ��޳���������sku������������˲��ǡ�zhongxiang"�ҷ�BE/NLվ��)
 * 
 * ������ʱ�����ض�����������code����ɸѡ��ٻ�
 * 
 * �ڳ�����ϸ�и�ÿ������ƥ�俯��ʱ��
 * 
 * ERP���ӿ⣬������code����ɸѡ��ٻ�
 * ҵ�������޳���� =��ͨ��sellersku���޳�BJ  not regexp '-BJ-|-BJ|BJ-' 
 * ҵ������SQL����Դʹ�õ���ERPlisting�������������������
 * ҵ������ʹ������sku���ʱ�� =��ʹ��listing����ʱ��
 * ����SKU
 * 
 * 1������-��Ա��������-������
2��������Ʒ����SKU���ܣ��ο��ܳ���SKU��
3��������Ʒ��������SKU��ϸ���ο���SKU����������
 * 
 */

-- ERP���ӿ⣬��Ҫ�޳�����˲�����Ӫ��Ա���ֵģ�2�¸����˴�����SKU

with 
t_orde as (  -- ÿ�ܳ�����ϸ
select 
	dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName  
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName 
	,ms.Code as shopcode 
from import_data.wt_orderdetails wo
left join dim_date dd on date(paytime) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
-- 	and paytime >= '2023-02-01' and paytime <'2023-03-01'
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
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
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
-- select count(1) from wt_listing  week_begin_date

, t_list_stat as ( -- ��1 ���Ǽ���
select 
	case when NodePathName is not null and SellUserName is not null and pub_week_begin_date is null then 'С��x��Ա'
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is null then 'С��'
		when NodePathName is null and SellUserName is null and pub_week_begin_date is null then '�Ŷ�'
		when NodePathName is not null and SellUserName is not null and pub_week_begin_date is not null then '�Ŷ�xС��x��Աx������'
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is not null then '�Ŷ�xС��x������'
		when NodePathName is null and SellUserName is null and pub_week_begin_date is not null then '�Ŷ�x������'
		end as `����ά��`
	,case when dep2 is null then '�ϼ�' else dep2 end as dep2
	,case when NodePathName is null then '�ϼ�' else NodePathName end as NodePathName
	,case when SellUserName is null then '�ϼ�' else SellUserName end as SellUserName
	,case when pub_week_begin_date is null then '�ϼ�' else pub_week_begin_date end as pub_week_begin_date
	,concat(ifnull(dep2,''),ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(pub_week_begin_date,'')) tbcode
	,count(distinct BoxSku)  `����SKU��`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `����������`
from t_list
group by grouping sets(
	(dep2 ,NodePathName ,SellUserName)
	,(dep2 ,NodePathName)
	,(dep2)
	,(dep2 ,NodePathName ,SellUserName,pub_week_begin_date)
	,(dep2 ,NodePathName,pub_week_begin_date)
	,(dep2 ,pub_week_begin_date)
	)
)
-- select * from t_list_stat 

, t_list_sale_details as ( -- ��1 ÿ��������ÿ�ܵĳ������
select 
	t_list.dep2 ,t_list.NodePathName ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,t_list.pub_week_begin_date 
	,od.boxsku ,od.pay_week ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
join (
	select boxsku ,sellersku ,shopcode ,pay_week
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku ,sellersku ,shopcode ,pay_week
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku and t_list.sellersku = od.sellersku 
)
-- select sum(TotalGross) `���۶�` from t_list_sale_details	

,t_list_sale_stat as (
select 
	case when NodePathName is not null and SellUserName is not null and pub_week_begin_date is null then 'С��x��Ա' 
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is null then 'С��' 
		when NodePathName is null and SellUserName is null and pub_week_begin_date is null then '�Ŷ�' 
		when NodePathName is not null and SellUserName is not null and pub_week_begin_date is not null then '�Ŷ�xС��x��Աx������' 
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is not null then '�Ŷ�xС��x������' 
		when NodePathName is null and SellUserName is null and pub_week_begin_date is not null then '�Ŷ�x������' 
		end as `����ά��`
	,case when dep2 is null then '�ϼ�' else dep2 end as dep2
	,case when NodePathName is null then '�ϼ�' else NodePathName end as NodePathName
	,case when SellUserName is null then '�ϼ�' else SellUserName end as SellUserName
	,case when pub_week_begin_date is null then '�ϼ�' else pub_week_begin_date end as pub_week_begin_date
	,concat(ifnull(dep2,''),ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(pub_week_begin_date,'')) tbcode 
	,sum(salecount) `����`  
	,sum(TotalGross) `���۶�` 
	,sum(TotalProfit) `�����` 
	,count(distinct concat(shopcode,sellersku)) `����������`
	,count(distinct boxsku) `����sku��`
from t_list_sale_details
group by grouping sets(
	(dep2 ,NodePathName ,SellUserName)
	,(dep2 ,NodePathName)
	,(dep2)
	,(dep2 ,NodePathName ,SellUserName,pub_week_begin_date)
	,(dep2 ,NodePathName,pub_week_begin_date)
	,(dep2 ,pub_week_begin_date)
	)
)

, t_merge as (    
select 
	t_list_stat.`����ά��` 
	,t_list_stat.dep2 
	,t_list_stat.NodePathName 
	,t_list_stat.SellUserName  
	,t_list_stat.pub_week_begin_date  
	,dd.week_num_in_year pub_week 
	,t_list_stat.`����SKU��`  
	,t_list_stat.`����������`  
	,t_list_sale_stat.`����` 
	,t_list_sale_stat.`���۶�` 
	,t_list_sale_stat.`�����` 
	,t_list_sale_stat.`����������` 
	,t_list_sale_stat.`����sku��` 
from t_list_stat 
left join t_list_sale_stat on t_list_sale_stat.tbcode = t_list_stat.tbcode 
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date) dd on t_list_stat.pub_week_begin_date = dd.week_begin_date
)

-- select * from t_merge



-- ���� ����-��Ա-���¿��Ƕ���ͳ�� week_begin_date

select
	replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,`����ά��` 
	,dep2 `�Ŷ�`
	,NodePathName `С��`
	,t_merge.SellUserName `��Ա`
	,pub_week `������`
	,pub_week_begin_date `������һ`
	,`����`
	,`���۶�`
	,`�����`
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
order by `����ά��`