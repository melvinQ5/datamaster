
select sum(AdSpend) from wt_adserving_amazon_daily  waad join mysql_store ms on ms.code = waad.ShopCode join wt_listing wl on wl.ShopCode =waad.ShopCode and ms.Department='��ٻ�'
and wl.SellerSKU = waad.SellerSku and wl.IsDeleted=0 where  GenerateDate >= '2023-10-23' and GenerateDate <'2023-10-30' and ms.ShopStatus='����'

select sum(spend) from   AdServing_Amazon waad  join mysql_store ms on ms.code = waad.ShopCode join wt_listing wl on wl.ShopCode =waad.ShopCode and ms.Department='��ٻ�'
and wl.SellerSKU = waad.SellerSku and wl.IsDeleted=0 where  CreatedTime >= '2023-10-23' and CreatedTime <'2023-10-30' and ms.ShopStatus='����'


-- ���ܣ�1023-1029����ٻ���ǰ�˺ŵĹ�滨��1.54w��Ԫ
select sum(AdSpend) from wt_adserving_amazon_daily  waad
join mysql_store ms on ms.code = waad.ShopCode and ms.Department='��ٻ�'
 where  GenerateDate >= '2023-10-23' and GenerateDate <'2023-10-30'


select waad.SellerSku ,wl.SellerSKU
from wt_adserving_amazon_daily waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '��ٻ�' and  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'
left join ( select distinct wl.ShopCode ,wl.SellerSKU  ,wl.sku  from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '��ٻ�'
    ) wl on waad.ShopCode = wl.ShopCode and  waad.SellerSKU = wl.SellerSKU
where wl.SellerSKU is null

-- ���ӱ�鲻�� ����������
select * from wt_listing where SellerSKU='NTQK1685TP24TK10R-02'; -- û��
select * from erp_amazon_amazon_listing where SellerSKU='NTQK1685TP24TK10R-02'; -- ��
select * from erp_amazon_amazon_listing_delete where SellerSKU='NTQK1685TP24TK10R-02'; -- û��
select * from wt_adserving_amazon_daily where SellerSKU='NTQK1685TP24TK10R-02';  -- ��


