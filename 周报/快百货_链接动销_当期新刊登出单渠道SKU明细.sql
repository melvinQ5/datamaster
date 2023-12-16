-- �ۺϵ���������
with 
t_orde as (  -- ÿ�ܳ�����ϸ
select
	dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,product_spu as spu ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	,ms.Code as shopcode
from import_data.wt_orderdetails wo
left join dim_date dd on date(paytime) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0 and OrderStatus != '����'
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


,t_list_sale_stat as ( -- ��������ͳ��
select
    o.BoxSku `����boxsku`
    ,spu
	,o.shopcode
	,o.sellersku `����sku`
	,concat(o.shopcode,o.sellersku) `����Ψһ��`
	,o.ASIN
	,RIGHT(o.shopcode,2) `վ��`
	,pub_week `������`
    ,pub_week_begin_date `������һ`
	,MinPublicationDate `����ʱ��`
	,o.dep2 `�Ŷ�`
	,o.SellUserName `������Ա`
	,round( sum(TotalGross/ExchangeUSD) ,2) `���۶�`
	,round( sum(TotalProfit/ExchangeUSD) ,2) `�����`
	,sum(salecount) `����`
from t_orde o join t_list l on l.shopcode = o.shopcode and l.sellersku = o.sellersku and l.asin = o.asin
group by o.BoxSku,spu,o.shopcode,o.sellersku,o.ASIN,RIGHT(o.shopcode,2),pub_week,pub_week_begin_date,MinPublicationDate,o.dep2,o.SellUserName
)

,t_list_min_pay_time as (
select wo.shopcode, wo.sellersku, date(min(paytime)) as min_pay_time
from t_list_sale_stat t 
join wt_orderdetails  wo on t.shopcode = wo.shopcode and t.`����sku` = wo.sellersku	
where isdeleted = 0 and orderstatus != '����'
group by wo.shopcode, wo.sellersku
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,t_res as (
select 
	replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,t_list_sale_stat.*
	,t_weeks.`������ͳ��`
	,wp.ProjectTeam `ERP��sku�����Ŷ�`
	,wp.Cat1 `��Ŀһ��`
	,wp.ProductName `��Ʒ����`
	,wp.Logistics_Attr `��������`
	,wp.LastPurchasePrice `���²ɹ���`
	,case when LastPurchasePrice < 5 then '5Ԫ����' 
		when LastPurchasePrice >=5 and LastPurchasePrice <= 20 then '[5-20]Ԫ'
		when LastPurchasePrice >20 and LastPurchasePrice <= 40 then '(20-40]Ԫ'
		when LastPurchasePrice >40 then '40Ԫ����'end as `�ɹ�������`
	,to_date(wp.DevelopLastAuditTime) `����ʱ��`
	,wp.DevelopUserName `������Ա`
	,min_pay_time `�״γ���ʱ��`
    ,prod_seller.seller_list `SPU��Ӧ������Ա`
from t_list_sale_stat
left join import_data.wt_products wp on t_list_sale_stat.`����boxsku` = wp.BoxSku and wp.ProjectTeam = '��ٻ�'
left join prod_seller on t_list_sale_stat.spu = prod_seller.spu
left join t_list_min_pay_time ta on t_list_sale_stat.shopcode = ta.shopcode	and t_list_sale_stat.`����sku` = ta.sellersku
left join 
	( -- ���ӳ����ܾۺ��ı� 
	select shopcode ,sellersku 
		,group_concat(pay_week_cn) `������ͳ��`
	from (
		select o.shopcode,o.sellersku, concat(pay_week,'��') as pay_week_cn
		from t_orde o join t_list l on l.shopcode = o.shopcode and l.sellersku = o.sellersku group by o.shopcode,o.sellersku,pay_week
		) tmp 
	group by shopcode,sellersku
	) t_weeks
	on t_list_sale_stat.shopcode = t_weeks.shopcode	and t_list_sale_stat.`����sku` = t_weeks.sellersku	
)


-- select sum(���۶�) from t_res
select * from t_res
-- where `����sku` ='KKSXF231101I7AYVUS'