-- ���� ȱ�ٳµĶ�����������Ϊ��ӦSKU�������ڵ��¿��ǵ���ɾ������ԭ������߼��ھ�û�м��㵱��ɾ�����ӵļ�¼

-- �ۺϵ�������ƷSKU
with
t_orde as (  -- ÿ�ܳ�����ϸ
select dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,Product_SPU as spu
    ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode
from import_data.wt_orderdetails wo
left join dim_date dd on date ( paytime ) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
    and OrderStatus != '����'
-- where BoxSku = 4957826
)

,t_list as ( -- 23���ڿ�������
select a.*
    ,dd.week_num_in_year pub_week
    ,dd.week_begin_date as pub_week_begin_date
from (
select wl.BoxSku ,wl.SKU ,MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,wl.ASIN
    ,MONTH( MinPublicationDate) pub_month
	,year( MinPublicationDate) pub_year
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
from wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}'
	-- and wl.IsDeleted = 0
	and ms.Department = '��ٻ�'
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
    and BoxSku = 4957826
) a
left join dim_date dd on date(a.MinPublicationDate) = dd.full_date
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,epp.boxsku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join erp_product_products epp  on eppaea.sku = epp.sku and epp.IsDeleted = 0 and epp.IsMatrix = 0
group by eppaea.sku ,epp.boxsku
)

,t_sale_sku as (  -- ÿ�ܳ���SKU
select o.dep2 ,o.NodePathName ,o.BoxSku , o.spu
	,sum(salecount) `����SKU����`
	,round( sum((TotalGross)/ExchangeUSD),2)  `���۶�`
	,round( sum((TotalProfit)/ExchangeUSD),2)  `�����`
	,count(distinct PlatOrderNumber)  `������`
	,count(distinct concat(o.shopcode,o.sellersku))  `����������`
	,count(distinct o.boxsku)  `����sku��`
from t_orde o join t_list l on l.shopcode = o.shopcode and l.sellersku = o.sellersku and l.asin = o.asin
group by o.dep2 ,o.NodePathName ,o.BoxSku, o.spu
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

,res as (
select
	replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,t_sale_sku.dep2 `�Ŷ�`
	,t_sale_sku.NodePathName  `С��`
	,t_sale_sku.BoxSku
    ,t_sale_sku.spu
	,`����SKU����`
	,`���۶�`
	,round(`���۶�`/ `����������`,1) `�������ӵ���`
	,round(`���۶�`/ `����sku��`,1) `����sku����`
	,`�����` ,`������`
	,wp.ProductName
	,wp.Cat1
	,wp.Cat2
	,wp.Cat3
	,wp.Cat4
	,wp.Cat5
	,t_elem.ele_name `Ԫ��`
	,date(wp.DevelopLastAuditTime) `����ʱ��`
	,wp.DevelopUserName `������Ա`
    ,prod_seller.seller_list `SPU��Ӧ������Ա`
from t_sale_sku
left join import_data.wt_products wp on t_sale_sku.boxsku = wp.BoxSku
left join t_elem on t_sale_sku.boxsku =t_elem.boxsku
left join prod_seller on t_sale_sku.spu =prod_seller.spu
order by `�Ŷ�` , `С��`
)

select * from res
-- select sum(���۶�) from res

select a.* ,b.MinPublicationDate
from ( select BoxSku ,asin ,site  from import_data.wt_orderdetails where boxsku = '4957826' and PayTime >= '2023-09-01' ) a
left join ( select asin ,MarketType as site ,MinPublicationDate
            from wt_listing  wl join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.department = '��ٻ�'
            and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
            group by asin ,MarketType ,MinPublicationDate ) b
on a.asin = b.asin and a.site = b.site