-- 5������Ĳ�Ʒ��


select
    FirstDay
     , date(date_add( DevelopLastAuditTime,interval -8 hour )) ����ʱ��
from dep_kbh_product_level dkpl
join ( select distinct spu ,DevelopLastAuditTime from erp_product_products where ismatrix = 1 and date_add( DevelopLastAuditTime,interval -8 hour ) >= '2023-05-01'
    and date_add( DevelopLastAuditTime,interval -8 hour ) < '2023-06-01' ) epp
    on dkpl.spu = epp.spu and dkpl.prod_level regexp '��|��'

