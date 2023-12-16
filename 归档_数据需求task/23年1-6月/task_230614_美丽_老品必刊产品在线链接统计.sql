-- ��1
select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
    ,kbh_online_code as '��ٻ������˺�����'
    ,kbh_cd_online_code  as '��ٻ��ɶ������˺�����'
    ,kbh_qz_online_code  as '��ٻ�Ȫ�������˺�����'
from ( -- 7��ǰ�����ͣ����Ʒ��Ϣ
    select SPU,SKU
    	,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime
    	,ProductName
    	,split(CategoryPathByChineseName, '>')[1] as cat1
    from erp_product_products epp -- ʹ��ʵʱ��,�������������
    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
    where ismatrix = 0 and productstatus != 2  and projectteam = '��ٻ�'
    ) epp
left join ( -- �����˺���
	select sku ,count(distinct ms.CompanyCode) kbh_online_code
	     ,count(distinct case when nodepathname regexp '�ɶ�' then ms.CompanyCode end) kbh_cd_online_code
	     ,count(distinct case when nodepathname regexp 'Ȫ��' then ms.CompanyCode end) kbh_qz_online_code
	from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='��ٻ�' and ms.shopstatus = '����' and eaal.listingstatus = 1
	group by sku
	) eaal on epp.sku = eaal.sku


select distinct  CompanyCode
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='��ٻ�' and ms.shopstatus = '����' and eaal.listingstatus = 1
and sku = 1024599.01
-- and Code = 'CN'

-- ��2
select cat1 ,CompanyCode ,round(sum(totalgross/exchangeusd)) 3��1���������۶�
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.ShopStatus = '����' and ms.department = '��ٻ�' and nodepathname regexp '�ɶ�'
join ( select distinct sku ,split(CategoryPathByChineseName, '>')[1] as cat1  from erp_product_products epp  
	left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
	where ismatrix = 0 and productstatus != 2 and projectteam = '��ٻ�'  
	) wp on wp.sku =wo.Product_Sku
where paytime >= '2023-03-01' and wo.isdeleted = 0
group by cat1 ,CompanyCode 

