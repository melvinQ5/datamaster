select ActionUserName ,MenuUrl,left(`Sql`,20)  ,count(*) from import_data.erp_gather_gather_bi_burieds
where ActionTime > '2023-11-20'  and EventType=1 group by ActionUserName ,MenuUrl,left(`Sql`,20)



select *
from import_data.erp_gather_gather_bi_burieds where ActionUserName = 'Ö£Ñà·É' order by ActionTime desc



