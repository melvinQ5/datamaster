with 
ta as (
select memo as boxsku ,c2 as `��ע` from manual_table mt 
)

,t_list as ( -- ��������
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl -- ��Ϊ��������䵽����sku,���Բ���Ҫʹ��erp��
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `��ٻ�����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='���Ԫ-Ȫ��������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��η�-Ȫ��������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2` 
from t_list
group by BoxSKU  
)

,t_orde as (  -- ÿ�ܳ�����ϸ
select 
	OrderNumber ,PlatOrderNumber ,wo.Market	
	,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime ,OrderStatus 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
-- 	and paytime >= '2023-02-01'
	and paytime >= '2022-04-09'and paytime < '2023-04-09'
	and ms.Department = '��ٻ�' and OrderStatus != '����'
	and wo.IsDeleted=0
)

,t_od_stat as (
select boxsku , sum(salecount) `��һ������`
from t_orde where OrderStatus != '����' and TotalGross > 0 
group by boxsku 
)

,t_stock as (
select BoxSku ,sum(TotalInventory) `0408���`
from daily_WarehouseInventory dwi 
where CreatedTime = '2023-04-08'
group by BoxSku 
)


select ta.*
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as `0408��Ʒ״̬��ѯ`
	,tb.* 
	, `��һ������`
	, `0408���`
from ta 
left join t_list_stat tb on ta.boxsku = tb.boxsku 
left join erp_product_products wp on ta.boxsku = wp.BoxSKU 
left join t_od_stat  on ta.boxsku = t_od_stat.BoxSKU 
left join t_stock  on ta.boxsku = t_stock.BoxSKU 
order by `��ٻ�����������` desc 