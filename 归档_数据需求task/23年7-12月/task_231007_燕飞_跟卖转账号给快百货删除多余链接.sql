-- ����������ҪתһЩ�˺Ÿ����ǡ��������ǵĵ����� ����ڸ����Լ���SKU���ܲ��ܰ�������ȡһ���Ǹ������������ЩSKU�����ڸ����ģ�����Ҫ���ǲ������Ӷ�ɾ��
-- ���Ծ�ֻ��ȡ�������SKU������SKU���˺ż��룬�˺ű��롣�������ҹ�������������֯�ܹ��Ǳ߲�֪��������û
with a as (
select distinct  CompanyCode ,eaal.sku ,ProjectTeam ERP��Ʒ����
     ,SellerSKU  ,asin,site
    ,ShopCode ,Department ���̹������� ,ShopStatus ����״̬
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode = ms.Code
    and ms.CompanyCode in (
        'ZY',
        'ZX',
        'ZU',
        'ZR',
        'ZK',
        'ZI',
        'ZH',
        'ZE',
        'YY',
        'YX',
        'YU',
        'YT',
        'YL',
        'YK',
        'YH',
        'XS',
        'A17'
        )
left join wt_products wp on eaal.sku = wp.sku and wp.IsDeleted=0
where ListingStatus = 1
order by CompanyCode ,eaal.sku
)

-- select count(distinct CompanyCode) from a
-- select count(*) from a
select * from a
