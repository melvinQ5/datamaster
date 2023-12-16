-- 问题
-- 获取链接表对应的产品id
select Id ,ProductId ,CreationTime ,LastModificationTime ,ListingStatus from erp_amazon_amazon_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';
-- 拿ProductId 去产品表查对应记录，找不到记录
select id from erp_product_products
where id = '39fce444-f877-0994-ae01-4dcf25a21788';


-- 按当前业务部门使用账号范围，总共有 24w 条链接表id，其ProductId在erp_product_products中找不到
--
with res as (select eaal.Id as 链接表id
                  , ProductId  链接表产品id
                  , epp2.sku   当前sku
                  , epp2.id    当前sku产品id
                  , epp3.spu   当前spu
                  , epp3.id    当前spu产品id
-- select count(eaal.id )
             from erp_amazon_amazon_listing eaal
                      join mysql_store ms on eaal.ShopCode = ms.Code -- 仅考虑目前业务部门在用的账号
                      left join erp_product_products epp1 on eaal.ProductId = epp1.id
                      left join erp_product_products epp2 on eaal.sku = epp2.sku and epp2.IsMatrix = 0
                      left join erp_product_products epp3 on eaal.spu = epp3.spu and epp3.IsMatrix = 1
             where length(eaal.ProductId) > 0 -- 处理有产品id的
               and epp1.id is null            -- 现有产品表找不到sku
             order by epp3.spu desc)

select distinct 当前spu from res
