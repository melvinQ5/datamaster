
select sum(AdSpend) from wt_adserving_amazon_daily  waad join mysql_store ms on ms.code = waad.ShopCode join wt_listing wl on wl.ShopCode =waad.ShopCode and ms.Department='快百货'
and wl.SellerSKU = waad.SellerSku and wl.IsDeleted=0 where  GenerateDate >= '2023-10-23' and GenerateDate <'2023-10-30' and ms.ShopStatus='正常'

select sum(spend) from   AdServing_Amazon waad  join mysql_store ms on ms.code = waad.ShopCode join wt_listing wl on wl.ShopCode =waad.ShopCode and ms.Department='快百货'
and wl.SellerSKU = waad.SellerSku and wl.IsDeleted=0 where  CreatedTime >= '2023-10-23' and CreatedTime <'2023-10-30' and ms.ShopStatus='正常'


-- 上周（1023-1029）快百货当前账号的广告花费1.54w美元
select sum(AdSpend) from wt_adserving_amazon_daily  waad
join mysql_store ms on ms.code = waad.ShopCode and ms.Department='快百货'
 where  GenerateDate >= '2023-10-23' and GenerateDate <'2023-10-30'


select waad.SellerSku ,wl.SellerSKU
from wt_adserving_amazon_daily waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '快百货' and  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'
left join ( select distinct wl.ShopCode ,wl.SellerSKU  ,wl.sku  from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '快百货'
    ) wl on waad.ShopCode = wl.ShopCode and  waad.SellerSKU = wl.SellerSKU
where wl.SellerSKU is null

-- 链接表查不到 ，广告表中有
select * from wt_listing where SellerSKU='NTQK1685TP24TK10R-02'; -- 没有
select * from erp_amazon_amazon_listing where SellerSKU='NTQK1685TP24TK10R-02'; -- 有
select * from erp_amazon_amazon_listing_delete where SellerSKU='NTQK1685TP24TK10R-02'; -- 没有
select * from wt_adserving_amazon_daily where SellerSKU='NTQK1685TP24TK10R-02';  -- 有


