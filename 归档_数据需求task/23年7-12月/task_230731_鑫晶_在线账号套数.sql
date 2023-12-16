select CompanyCode, al.spu ,s.dep2  from wt_products pp
inner join erp_amazon_amazon_listing al
on pp.Sku=al.SKU
and al.SKU<>''
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') s
on al.ShopCode=s.Code
and s.Department='��ٻ�'
where DevelopLastAuditTime>='2023-06-01'
and DevelopLastAuditTime<'2023-08-01'
and ShopStatus='����'
and ListingStatus=1
group by  CompanyCode, al.spu ,s.dep2