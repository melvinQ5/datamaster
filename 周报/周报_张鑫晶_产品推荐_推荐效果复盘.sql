
with 
push_sku as (
select BoxSku ,SPU AS push_rule
from import_data.JinqinSku js where Monday = '2023-03-03' and Spu REGEXP '��Ʒ�Ƽ�'
)

, t_orde as (  -- �Ƽ���ָ�����ڵĳ�����ϸ
select WEEKOFYEAR( paytime) pay_week ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin ,wo.BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join push_sku on wo.BoxSku = push_sku.BoxSku
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
) 

,t_list as ( -- 23���ڿ�������
select wl.BoxSku ,SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	, WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl 
join push_sku on wl.BoxSku = push_sku.BoxSku
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
	and wl.IsDeleted = 0 and ms.Department = '��ٻ�' 
where PublicationDate >= '${StartDay}' and PublicationDate <'${NextStartDay}' and length(SKU) > 0 
)

, t_sale_src as ( -- ��1 ������ϸ ÿ��������ÿ������
select case when tmp.pub_week is null and TransactionType != '����' then '֮ǰ��ȿ���' else tmp.pub_week end pub_week
	,tmp.PublicationDate
	,t_orde.pay_week
	,t_orde.sellersku ,t_orde.shopcode,t_orde.asin
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,salecount ,paytime
	,ExchangeUSD,TransactionType ,RefundAmount,AdvertisingCosts,PurchaseCosts
	,dep2 ,SellUserName ,boxsku 
from t_orde
left join ( select shopcode ,sellersku ,asin , pub_week,PublicationDate from t_list group by shopcode , sellersku ,asin ,pub_week,PublicationDate ) tmp 
	on t_orde.shopcode = tmp.shopcode and t_orde.sellersku = tmp.sellersku and t_orde.asin =tmp.asin 
)

, t_sale_stat as ( -- ��1 ��������
select 
	boxsku 
	,sum(salecount) `����SKU����`
	,round( sum((TotalGross)/ExchangeUSD),2)  `���۶�`
	,round( sum((TotalProfit)/ExchangeUSD),2)  `�����`
	,round( (sum((TotalProfit)/ExchangeUSD))/sum((TotalGross)/ExchangeUSD) ,3) `ë����`
	,count(distinct concat(shopcode,SellerSku,Asin)) `����������`
	,count(distinct BoxSku)  `����SKU��`
-- 	,avg(`��������`) `ƽ����������`
from t_sale_src
group by boxsku 
)
-- select * from t_sale_stat


, t_list_stat as ( -- ��1 ���Ǽ���
select dep2
	, case when SellUserName is null then '�ϼ�' else SellUserName end SellUserName
	, case when pub_week is null then '�ϼ�' else pub_week end  pub_week
	,count(distinct BoxSku)  `�ϼ�SKU��`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `�ϼ�������`
from t_list
group by grouping sets ((dep2,pub_week),(dep2 ,SellUserName,pub_week) )
)


, t_merge as (    
select t_sale_stat.* ,t_list_stat.`�ϼ�SKU��` ,t_list_stat.`�ϼ�������`
from t_sale_stat 
left join t_list_stat on t_sale_stat.dep2 = t_list_stat.dep2 and t_sale_stat.SellUserName = t_list_stat.SellUserName
and t_sale_stat.pub_week = t_list_stat.pub_week 
)

-- ���� ����-��Ա-���¿��Ƕ���ͳ��
select
	dep2 `�Ŷ�`
	,SellUserName `��Ա`
	,pub_week `������`
	,pay_week `������`
	,`���۶�`
	,`�����`
	,`ë����`
	,`����������`
	,`�ϼ�������`
	,round(`����������`/`�ϼ�������`,4) `���ӳ�����`
	,`����SKU��`
	,`�ϼ�SKU��`
	,round(`����SKU��`/`�ϼ�SKU��`,4) `SKU������`
	,`ƽ��SKU������`
-- 	,`��������` -- ����ʱ�� - �Ƽ�ʱ�䣿 
from t_merge 
where `���۶�` >0 -- �ų�һЩ����������  
order by dep2 , SellUserName ,pub_week ,pay_week 
