-- Ԫ�� x �������� x �����
with
ele as ( -- �ļ�
select eppaea.sku ,Name as ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,Name
)



select
    '2023' �����
    ,week+1 �����
    ,ele_name  Ԫ��
    ,dev_month ��������
    ,round( sum(AdSales) ,2) ������۶�
    ,sum(AdExposure) ����ع���
    ,sum(AdClicks) �������
    ,sum(AdSaleUnits) �������
    ,round( sum(AdSpend) ,2)  ��滨��
    ,round( sum(AdSkuSale7DayUSD)) ���SKU���۶�
from wt_adserving_amazon_weekly waaw
join ( -- Ԫ��Ʒ����
    select wl.id , left(wp.DevelopLastAuditTime,7) dev_month , ele_name
    from wt_listing wl
    join mysql_store ms on wl.ShopCode = ms.Code and ms.Department='��ٻ�'
    join  ele on wl.sku = ele.sku -- Ԫ�ز�Ʒ��Ӧ������
    left join wt_products wp on wl.sku = wp.sku
    ) wl  on wl.Id = waaw.ListingId
where waaw.Year =2023
group by week ,ele_name,dev_month
order by week ,ele_name,dev_month ;


-- վ�� x �����
select
    '2023' �����
    ,week+1 �����
    ,right(ShopCode,2) վ��
    ,round( sum(AdSales) ,2) ������۶�
    ,sum(AdExposure) ����ع���
    ,sum(AdClicks) �������
    ,sum(AdSaleUnits) �������
    ,round( sum(AdSpend) ,2)  ��滨��
    ,round( sum(AdSkuSale7DayUSD)) ���SKU���۶�
from wt_adserving_amazon_weekly waaw
where waaw.Year =2023
group by week ,right(ShopCode,2)
order by week ,right(ShopCode,2) ;
