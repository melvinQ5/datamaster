-- ����
-- ��ȡ���ӱ��Ӧ�Ĳ�Ʒid
select Id ,ProductId ,CreationTime ,LastModificationTime ,ListingStatus from erp_amazon_amazon_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';
-- ��ProductId ȥ��Ʒ����Ӧ��¼���Ҳ�����¼
select id from erp_product_products
where id = '39fce444-f877-0994-ae01-4dcf25a21788';


-- ����ǰҵ����ʹ���˺ŷ�Χ���ܹ��� 24w �����ӱ�id����ProductId��erp_product_products���Ҳ���
--
with res as (select eaal.Id as ���ӱ�id
                  , ProductId  ���ӱ��Ʒid
                  , epp2.sku   ��ǰsku
                  , epp2.id    ��ǰsku��Ʒid
                  , epp3.spu   ��ǰspu
                  , epp3.id    ��ǰspu��Ʒid
-- select count(eaal.id )
             from erp_amazon_amazon_listing eaal
                      join mysql_store ms on eaal.ShopCode = ms.Code -- ������Ŀǰҵ�������õ��˺�
                      left join erp_product_products epp1 on eaal.ProductId = epp1.id
                      left join erp_product_products epp2 on eaal.sku = epp2.sku and epp2.IsMatrix = 0
                      left join erp_product_products epp3 on eaal.spu = epp3.spu and epp3.IsMatrix = 1
             where length(eaal.ProductId) > 0 -- �����в�Ʒid��
               and epp1.id is null            -- ���в�Ʒ���Ҳ���sku
             order by epp3.spu desc)

select distinct ��ǰspu from res
