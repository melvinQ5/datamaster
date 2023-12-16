-- ÈûºÐÇþµÀ×Ö·û´®×ªÎª µêÆÌcode(È¥Ç°×º)
select BoxSku ,shopcode
	, SUBSTR(shopcode,instr(shopcode,'-')+1)
	from import_data.daily_WeightOrders dwo 
	where PayTime >= '2023-01-01' and PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 