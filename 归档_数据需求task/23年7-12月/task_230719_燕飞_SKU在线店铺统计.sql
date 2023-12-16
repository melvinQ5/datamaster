

with t as (select eaal.SPU,
                  eaal.SKU,
                  CompanyCode,
                  Site,
                  ShopCode,
                  SellUserName,
                  NodePathName,
                  dep2,
                  '����' ����״̬,
                  '����' ����״̬
           from wt_listing eaal
                    join (select case when NodePathName regexp '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2, *
                          from import_data.mysql_store
                          where department regexp '��') ms on eaal.ShopCode = ms.Code and ms.Department = '��ٻ�'
               and ListingStatus = 1 and ShopStatus = '����' and eaal.IsDeleted = 0
                    left join wt_products wp on eaal.sku = wp.sku and wp.ProductStatus != 2 and wp.IsDeleted = 0
           GROUP BY eaal.SPU, eaal.SKU, CompanyCode, Site, ShopCode, SellUserName, NodePathName, dep2
           order by eaal.SKU, ShopCode)

select * from t
         -- where sku =5053444.01