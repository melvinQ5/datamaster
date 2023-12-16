select CompanyCode, al.spu ,s.dep2  from wt_products pp
inner join erp_amazon_amazon_listing al
on pp.Sku=al.SKU
and al.SKU<>''
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快') s
on al.ShopCode=s.Code
and s.Department='快百货'
where DevelopLastAuditTime>='2023-06-01'
and DevelopLastAuditTime<'2023-08-01'
and ShopStatus='正常'
and ListingStatus=1
group by  CompanyCode, al.spu ,s.dep2