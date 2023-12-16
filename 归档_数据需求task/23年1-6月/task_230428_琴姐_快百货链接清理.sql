/*
 * ����6���������ң�2021-2023 asin+վ�㣩δ�����������ӣ�ȫ��ɾ��
 */


-- , t_test as ( -- ����һ�����ɾ������ ȥƥ�����������±� , 
-- select eaaossm.SiteCode , eaaossm.asin , BoxDataTime ,SalesNum ,BoxSKU,eaaossm.ShopCode 
-- from t_mark
-- join import_data.erp_amazon_amazon_order_source_sku_mouthreport eaaossm  -- ���������±���ͨ�������¶�ͳ�ƶ�����
-- 	on t_mark.site = eaaossm.SiteCode and t_mark.asin = eaaossm.asin
-- where BoxDataTime >= '2021-01-01' 
-- -- group by eaaossm.SiteCode , eaaossm.asin
-- )
-- -- select * from t_test -- ���ۣ���������ƥ��  ������������û�޳����ϵ�


-- ----------------------------------------------

-- ���ٽ㣩���°� ���� ASIN ����5���߼�
with 
t_list as (
select id, sku, sellersku,shopcode,asin,markettype as site,NodePathName,AccountCode ,publicationdate
from erp_amazon_amazon_listing eaal 
join mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department='��ٻ�' 
	and ShopStatus='����'
	and listingstatus=1  
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
	and publicationdate<'2022-03-01'
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


, t_od3 as ( --������ ����ASIN�ۺ�Ŀ���Ǳ���������г�ͬ��������2019����
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
where t_od3.ord_cnt3 is  null 
order by t_od3.ord_cnt3 desc

)



select NodePathName ,count(distinct Asin , Site) `���ɾ��������` from t_mark3
group by grouping sets ((),(NodePathName))

