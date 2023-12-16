

with t as (select eaal.SPU,
                  eaal.SKU,
                  CompanyCode,
                  Site,
                  ShopCode,
                  SellUserName,
                  NodePathName,
                  dep2,
                  '在线' 链接状态,
                  '正常' 店铺状态
           from wt_listing eaal
                    join (select case when NodePathName regexp '成都' then '快百货一部' else '快百货二部' end as dep2, *
                          from import_data.mysql_store
                          where department regexp '快') ms on eaal.ShopCode = ms.Code and ms.Department = '快百货'
               and ListingStatus = 1 and ShopStatus = '正常' and eaal.IsDeleted = 0
                    left join wt_products wp on eaal.sku = wp.sku and wp.ProductStatus != 2 and wp.IsDeleted = 0
           GROUP BY eaal.SPU, eaal.SKU, CompanyCode, Site, ShopCode, SellUserName, NodePathName, dep2
           order by eaal.SKU, ShopCode)

select * from t
         -- where sku =5053444.01