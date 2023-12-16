select  NodePathName '�����Ŷ�'
     ,ShopCode '���̼���'
     ,SellerSKU '����SKU'
     ,ASIN
     ,PublicationDate '����ʱ��'
     ,case when ListingStatus=1 then '����'
      when ListingStatus=3 then '�¼�' end  '����״̬'
     ,ShopStatus '����״̬' from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and s.Department='��ٻ�'
where ListingStatus<>'4'
and SKU=''
group by NodePathName,ShopCode,SellerSKU,ASIN,PublicationDate,ListingStatus,ShopStatus
order by NodePathName desc;