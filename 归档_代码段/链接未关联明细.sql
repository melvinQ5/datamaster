select  NodePathName '销售团队'
     ,ShopCode '店铺简码'
     ,SellerSKU '渠道SKU'
     ,ASIN
     ,PublicationDate '刊登时间'
     ,case when ListingStatus=1 then '在线'
      when ListingStatus=3 then '下架' end  '链接状态'
     ,ShopStatus '店铺状态' from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and s.Department='快百货'
where ListingStatus<>'4'
and SKU=''
group by NodePathName,ShopCode,SellerSKU,ASIN,PublicationDate,ListingStatus,ShopStatus
order by NodePathName desc;