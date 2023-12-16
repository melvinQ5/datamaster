

with
ta as (
select [
] arr
)

,tb as (
select distinct arr 
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)
-- select * from tb


,od as (
select sellersku ,shopcode
     ,count (distinct PlatOrderNumber) as `22��8��12�¶�����`
     ,round (sum(TotalGross/ExchangeUSD),2) as `22��8��12�����۶�`
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.code and ms.department = '��ٻ�'
join tb on tb.arr = wo.product_spu and wo.IsDeleted = 0 and orderstatus != '����' 
-- and paytime >= date_add('${NextStartDay}',interval - 1 year)
and paytime >= '2022-08-01' and PayTime  < '2023-01-01'
group by sellersku ,shopcode
)
-- select * from od 


select * from (
select 
	concat(wl.sku,wl.sellersku,ms.code) id
	,wl.sku
    ,wl.spu ,wp.boxsku
     ,wp.DevelopLastAuditTime
     ,wp.productname
     ,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
     ,ms.code ,ms.NodePathName ,ms.SellUserName ,ms.accountcode ,wl.sellersku
     ,wl.price
	,case when ms.shopstatus = '����' and wl.listingstatus = 1  then '����' else 'δ���߻�����쳣' end ����״̬
	,ifnull(`22��8��12�¶�����`,0) 22��8��12�¶�����
	,ifnull(22��8��12�����۶�,0) 22��8��12�����۶�
from wt_listing wl
join tb on tb.arr = wl.spu and wl.isdeleted = 0 
join wt_products wp on wp.sku =wl.sku and projectteam = '��ٻ�' and ProductStatus !=2 and wp.IsDeleted  = 0 
join mysql_store ms on wl.shopcode = ms.code and department = '��ٻ�'
join erp_amazon_amazon_listing eaal on wl.id = eaal.id 
left join od on od.sellersku = wl.SellerSKU and od.shopcode = wl.ShopCode
) t
order by id 
