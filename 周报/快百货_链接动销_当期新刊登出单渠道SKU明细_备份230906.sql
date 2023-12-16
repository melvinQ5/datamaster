-- 聚合到出单链接
with 
t_orde as (  -- 每周出单明细
select
	dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,product_spu as spu ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	,ms.Code as shopcode
from import_data.wt_orderdetails wo
left join dim_date dd on date(paytime) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
) 

,t_list as ( -- 23年内刊登链接
select distinct a.*
    ,dd.week_num_in_year pub_week
    ,dd.week_begin_date as pub_week_begin_date
from (
select wl.BoxSku ,wl.SKU ,MinPublicationDate_new as MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,wl.ASIN
    ,MONTH( MinPublicationDate_new) pub_month
	,year( MinPublicationDate_new) pub_year
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
from wt_listing wl
left join
    ( select asin, MarketType ,min(PublicationDate) as MinPublicationDate_new
    from wt_listing wl join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.department = '快百货' group by asin ,MarketType ) t1
    on wl.asin = t1.ASIN and wl.MarketType =t1.MarketType
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where
	MinPublicationDate_new>= '${StartDay}' and MinPublicationDate_new <'${NextStartDay}'
	-- and wl.IsDeleted = 0
	and ms.Department = '快百货'
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
) a
left join dim_date dd on date(a.MinPublicationDate) = dd.full_date
)

,t_list_sale_details as ( -- 表1 每条链接在每周的出单情况
select 
	t_list.dep2 ,t_list.SellUserName ,t_list.sellersku ,t_list.asin ,t_list.shopcode 
	,t_list.pub_week
    ,pub_week_begin_date
    ,t_list.MinPublicationDate
	,od.boxsku,od.spu ,od.pay_week ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
LEFT join (
	select boxsku ,spu,sellersku ,shopcode ,pay_week
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku,spu ,sellersku ,shopcode ,pay_week
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku
where pay_week is not null -- 保留有出单的记录
-- 	and t_list.SellerSku ='5OH230410XURPQYDCA'
)

,t_list_sale_stat as ( 
select BoxSku `出单boxsku`
    ,spu
	,shopcode
	,sellersku `渠道sku`
	,concat(shopcode,sellersku) `链接唯一码`
	,ASIN
	,RIGHT(shopcode,2) `站点`
	,pub_week `刊登周`
    ,pub_week_begin_date `当周周一`
	,MinPublicationDate `刊登时间`
	,dep2 `团队`
	,SellUserName `销售人员`
	,sum(TotalGross) `销售额`
	,sum(TotalProfit) `利润额`
	,sum(salecount) `销量`
from t_list_sale_details
group by BoxSku,spu,shopcode,sellersku,ASIN,RIGHT(shopcode,2),pub_week,pub_week_begin_date,MinPublicationDate,dep2,SellUserName
)

,t_list_min_pay_time as (
select wo.shopcode, wo.sellersku, to_date(min(paytime)) as min_pay_time 
from t_list_sale_stat t 
join wt_orderdetails  wo on t.shopcode = wo.shopcode and t.`渠道sku` = wo.sellersku	
where isdeleted = 0 and orderstatus != '作废'
group by wo.shopcode, wo.sellersku
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,t_resu as (
select 
	replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `付款时间范围`
	,t_list_sale_stat.*
	,t_weeks.`出单周统计`
	,wp.ProjectTeam `ERP库sku归属团队`
	,wp.Cat1 `类目一级`
	,wp.ProductName `产品名称`
	,wp.Logistics_Attr `物流属性`
	,wp.LastPurchasePrice `最新采购价`
	,case when LastPurchasePrice < 5 then '5元以下' 
		when LastPurchasePrice >=5 and LastPurchasePrice <= 20 then '[5-20]元'
		when LastPurchasePrice >20 and LastPurchasePrice <= 40 then '(20-40]元'
		when LastPurchasePrice >40 then '40元以上'end as `采购价区间`
	,to_date(wp.DevelopLastAuditTime) `终审时间`
	,wp.DevelopUserName `开发人员`
	,min_pay_time `首次出单时间`
    ,prod_seller.seller_list `SPU对应销售人员`
from t_list_sale_stat
left join import_data.wt_products wp on t_list_sale_stat.`出单boxsku` = wp.BoxSku and wp.ProjectTeam = '快百货'
left join prod_seller on t_list_sale_stat.spu = prod_seller.spu
left join t_list_min_pay_time ta on t_list_sale_stat.shopcode = ta.shopcode	and t_list_sale_stat.`渠道sku` = ta.sellersku
left join 
	( -- 增加出单周聚合文本 
	select shopcode ,sellersku 
		,group_concat(pay_week_cn) `出单周统计`
	from (
		select shopcode,sellersku, concat(pay_week,'周') as pay_week_cn 
		from t_list_sale_details group by shopcode,sellersku,pay_week
		) tmp 
	group by shopcode,sellersku
	) t_weeks
	on t_list_sale_stat.shopcode = t_weeks.shopcode	and t_list_sale_stat.`渠道sku` = t_weeks.sellersku	
)

select * from t_resu 
-- where `渠道sku` ='3XTO230403ZKFLYDUS-02'