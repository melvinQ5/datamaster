-- 
/*
 * 业务背景：产品库非快百货SKU且链接对应店铺为快百货店铺的在线链接下架
金根：之前说产品分到逆向，我们没有复制的SKU对应渠道让IT帮忙汇总的，有结果了
美丽：未关联出单增加了吗？
金根：很少看到未关联，主要是想把这部分渠道全删了，降低风险
 * 
 */

with 
epp as ( 
select Sku ,SPU ,ProjectTeam
from import_data.erp_product_products epp 
where 
	ProjectTeam = '特卖汇'
	and IsDeleted =0 and IsMatrix =0 
group by Sku ,SPU ,ProjectTeam
)

, channel as ( 
select PlatformSku as sellersku , Sku ,ShopCode
from import_data.erp_amazon_amazon_channelskus eaac 
where AssociatedStates = 0 
group by PlatformSku, Sku ,ShopCode
)

-- select count(1) from (

select eaal.ShopCode ,NodePathNameFull  `链接店铺对应团队`
	,eaal.SellerSKU ,ASIN  ,PublicationDate `刊登时间` 
	,eaal.BoxSku ,eaal.SKU 
	,epp.ProjectTeam `产品库显示部门`
from 
	( select BoxSku ,SKU ,SPU ,productid ,PublicationDate ,sellersku ,ls.ShopCode ,ms.NodePathNameFull,ASIN
		from erp_amazon_amazon_listing ls
		join import_data.mysql_store ms on ls.ShopCode = ms.Code 
		where ms.department ='快百货'
			and ls.ListingStatus = 1
	) eaal  
join
	( -- 使用 sku 关联
	select epp.sku ,ProjectTeam 
	from epp 
	group by epp.sku ,ProjectTeam 
	) epp
	on eaal.sku  = epp.sku 
	
-- ) tmp

		
		
