-- ����6���������ң�2021-2023 asin+վ�㣩δ�����������ӣ�ȫ��ɾ��
-- ����������ɾ���߼����£�

-- theDate ��������(����������)

with 
t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select  
	case when NodePathName regexp 'Ȫ��' then '��ٻ�����' 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department 
		end as department
	,department as department_old
	,code ,ShopStatus ,NodePathName ,AccountCode
-- 	,*
from import_data.mysql_store
)

,t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,publicationdate ,department 
from erp_amazon_amazon_listing eaal 
join t_mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department_old ='��ٻ�' 
	and ShopStatus='����'
	and listingstatus= 1   
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
	and publicationdate <= date_add('${theDate}',interval - 6 month )  -- ָ�����ڼ���ǰ
)

, t_od as ( -- ������  86w ��������
select Asin , Site ,count(*) ord_cnt 
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2021-01-01'  and TransactionType='����' 
group by Asin , Site 
)

, t_od2 as ( -- ������ ����ASIN�ۺ�Ŀ���Ǳ���������г�ͬ��������
select Asin ,count(*) ord_cnt2 
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2021-01-01'  and TransactionType='����' 
group by Asin having ord_cnt2>5
)

, t_od3 as ( -- ������ ����ASIN�ۺ�Ŀ���Ǳ���������г�ͬ��������2019����
select Asin ,count(*) ord_cnt3  
from wt_orderdetails wo 
-- join erp_product_products pp on pp.boxsku=wo.boxsku 
where wo.IsDeleted = 0 and PayTime >= '2019-01-01'  and TransactionType='����' 
group by Asin having ord_cnt3>10 
)
-- select count(1) from t_od 

,t_mark as ( -- ���ɾ������ 
select  'ɾ��' as mark ,t_list.* 
from t_list 
left join t_od on t_list.site = t_od.site and t_list.asin = t_od.asin 
where t_od.ord_cnt is null 
)

,t_mark2 as ( -- ���ɾ�����ӣ��ų������г�asin��5�������� 
select t_mark.* ,t_od2.ord_cnt2 
from t_mark 
left join t_od2 on t_mark.asin = t_od2.asin 
where t_od2.ord_cnt2 is null 
order by t_od2.ord_cnt2 desc 
)

,t_mark3 as ( -- ���ɾ�����ӣ��ų���2019����г�asin��5��������
select t_mark2.* ,t_od3.ord_cnt3
from t_mark2
left join t_od3 on t_mark2.asin = t_od3.asin
where t_od3.ord_cnt3 is null
order by t_od3.ord_cnt3 desc
)

-- ͳ�ƴ�ɾ��������
select department `����`
	, 'վ��ϼ� 'site 
	,count(distinct Asin , Site) `ʣ���ɾ��������������`
	,concat(left(date_add('${theDate}',interval - 6 month ),10),'����ǰ') `����ʱ�䷶Χ������6�������ϣ�`
from t_mark3 
group by department  
union all 
select department `����`
	,site 
	,count(distinct Asin , Site) `ʣ���ɾ��������������`
	,concat(left(date_add('${theDate}',interval - 6 month ),10),'����ǰ') `����ʱ�䷶Χ������6�������ϣ�`
from t_mark3 
group by department ,site 

