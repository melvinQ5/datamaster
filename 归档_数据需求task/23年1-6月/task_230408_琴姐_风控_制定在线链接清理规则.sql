/*
�������������� ���
��˾�ܼƣ�300��
�����ܼƣ�70��
ɾ����׼��δ����������ʱ���Զ����ɾ����ɾ��300/70��
�ٱ���22-23�����������
��UK/DE/FR/ES/IT/US/CA/MX ��վ��7����AU/SE/NL/PL/JP��վ��5��
�۽�8���зÿ�>��60�����е��>��60�����ع�>����ʱ�������ھ�

step1 �ƶ��������
step2 �������� ����ÿ���ó���һ��������������һ��SKU���в�����
*/

with 
t_prod as ( -- ɸѡ��Ʒ
select sku ,Festival
from wt_products wp 
where IsDeleted = 0  
	and ProjectTeam = '��ٻ�' 
	and Festival is not null -- ����Ʒ
	and date_add(DevelopLastAuditTime , interval -8 hour) < '2023-01-01'
	and ProductStatus != 2 
-- 	and sku = 1059049.03
)

,t_vist as ( 
select ShopCode ,ChildAsin ,round(sum(TotalCount*FeaturedOfferPercent/100),1) `��8�ܷÿ���`
from import_data.ListingManage lm 
where Monday >= '2023-02-06' and Monday <= '2023-03-27' and ReportType = '�ܱ�'
group by ShopCode ,ChildAsin 
)

,t_list as ( -- ȷ����ɾ�����ӷ�Χ
select wl.BoxSku ,wl.SKU ,to_date(PublicationDate) `����ʱ��` ,wl.ShopCode ,wl.SellerSKU ,ASIN 
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName `��ѡҵ��Ա` ,ms.Site 
	,ms.AccountCode 
	,wp.Festival `���ڽ���`
	,`��8�ܷÿ���`
from wt_listing wl -- ��Ϊ��������䵽����sku,���Բ���Ҫʹ��erp��
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod wp on wl.sku = wp.Sku -- ɸѡĿ����Ʒ
left join t_vist lm on lm.ShopCode = wl.shopcode and lm.ChildAsin = wl.ASIN  
where 
	wl.IsDeleted = 0 and wl.ListingStatus = 1
	and ms.Department = '��ٻ�'
	and ms.ShopStatus = '����'
	and PublicationDate < '2023-01-01'
)

,t_orde as (  
select 
	SellerSku,Asin,Product_Sku as sku 
	,OrderNumber ,PlatOrderNumber ,SaleCount
	,paytime ,OrderStatus 
	,PublicationDate 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2022-01-01'and paytime <'2023-04-11'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
)

,t_orde_list as ( -- ��������
select ROW_NUMBER()over(partition by NodePathName ,sku order by `2201-230410����` desc ) `2201-230410��������`
	,t.*
from (
	select NodePathName ,sku ,shopcode ,sellersku ,PublicationDate
		, sum( case when paytime >= '2022-01-01'and paytime <'2023-04-11' then salecount end ) `2201-230410����`
	from t_orde 
	where sku is not null 
	group by NodePathName ,sku ,shopcode ,sellersku ,PublicationDate HAVING sum(salecount) > 0  
	) t 
)

-- ��ʼ��ע
,res_list_1 as ( -- ��ǳ�������
select
	count(mark1) over(partition by NodePathName ,sku ) `mark1�ѱ�ע������` -- Ϊ����һ������ͬ�˺����ӣ�70-�ѱ����
	,tc.*
from (
	select 
		case when `2201-230410����` > 0 and `2201-230410��������` <=70  then '����_��������' end as mark1 
		,tb.`2201-230410����` 
		,ta.*
	from t_list ta left join t_orde_list tb 
		on ta.sellersku = tb.sellersku and ta.shopcode = tb.shopcode 
	-- where accountcode = 'QB-NA' -- һ�������˺�
	) tc 
)
	
,res_list_2 as (  -- ��� ��һ������������ͬ�˺���������
select 
	case when tc.`����ʱ������` <= 70 - `mark1�ѱ�ע������` then '����_ͬ�˺�����' end as mark2
	,`����ʱ������`
	, `mark1�ѱ�ע������`
	,res_list_1.*
from res_list_1 
left join ( -- ������ʱ�併�򣬲����㰴��һ���ѱ����
	select 
		ta.sellersku ,ta.shopcode  
		,ROW_NUMBER() over(partition by NodePathName ,sku order by `����ʱ��` desc ) `����ʱ������`
	from res_list_1 ta 
	join ( -- ɸѡ��һ��δ��Ǳ����� ͬ�˺�����
		select AccountCode from res_list_1 where mark1 = '����_��������' group by AccountCode 
		) tb on ta.AccountCode = tb.AccountCode
	where ta.mark1 is null -- ѡ��ͬ�˺� �һ�û��ע����������
	) tc 
	on res_list_1.sellersku = tc.sellersku and res_list_1.shopcode = tc.shopcode
)


select * from res_list_2

-- �鿴����Ŀǰ��ÿ���Ŷӣ�ÿ��sku�ѱ��������� �� ������������
, t_stat as (
select 
	 NodePathName ,sku 
	,count(COALESCE(mark1,mark2))  `mark1_2�ѱ�עuk������` 
	,count(1) `����������`
from res_list_2
group by NodePathName ,sku 
)

-- ����Ŀǰ���ѱ����˳������ӡ��������ӵ�ͬ�˺����ӡ�����Ѿ�����70�����Ӳ��ܣ����ڲ���70�������ӣ�����60���е����ȡ
-- ��վ�㲻����7��Ҳ�벻��

, t_stat_list as ( -- �ҳ�����70�������ӵ� sku+�Ŷӣ�Ȼ��ɸ���ܱ��л�û�б�ע�����ӣ������ǵ������ʱ������ȡ
select NodePathName ,sku  from t_stat where  `mark1_2�ѱ�עuk������`  < 70  
)


select 
from res_list_2 ta 
join t_stat_list tb on ta.nodepathname = tb.nodepathname  and ta.sku = tb.sku  
where 

-- select 
-- from res_list_2
-- where COALESCE(mark1,mark2) is null 



-- select * from t_stat

-- ,t_UK as ( 
-- case when tc.`����ʱ������` <= 70 - `mark1_2�ѱ�ע������` then '����_ͬ�˺�����' end as mark2
-- )

-- ,t_ad_stat as ( 
-- select asa.ShopCode ,asa.SellerSKU , sum(asa.Clicks) `��60��������` , sum(asa.Exposure) `��60�����ع���`
-- from t_list
-- join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
-- where CreatedTime >= date_add('2023-04-07',interval -60 day) and CreatedTime < '2023-04-07'
-- group by asa.ShopCode ,asa.SellerSKU
-- )

-- ,t_tmp as (
-- SELECT 
-- 	case 
-- 		when site in ("UK","DE","FR","ES","IT","US","CA","MX") then 7 - `����_��վ��mark1_2�ѱ�ע��`  
-- 		when site in ("AU","SE","NL","PL","JP") then 5 - `����_��վ��mark1_2�ѱ�ע��` 
-- 	end as `��վ��Ӧ���䱣����` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `��8�ܷÿ���` desc ) `��8�ܷÿ�������` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `��60��������` desc ) `��60������������` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `��60�����ع���` desc ) `��60�����ع�������` 
-- 	, ta.*
-- from (
-- 	select 
-- 		count(COALESCE(mark1,mark2)) over(partition by nodepathname , sku ,site ) `����_��վ��mark1_2�ѱ�ע��` 
-- 		,res_list_2.*
-- 		,`��60��������`
-- 		,`��60�����ع���`
-- 	from res_list_2 
-- 	left join t_ad_stat on res_list_2.ShopCode = t_ad_stat.ShopCode and res_list_2.SellerSKU = t_ad_stat.SellerSKU  
-- 	) ta  
-- )
-- 
-- ,res_list_3 as (
-- select 
-- 	case when ��վ��Ӧ���䱣���� > 0 and `��8�ܷÿ�������`<��վ��Ӧ���䱣���� and COALESCE(mark1,mark2) is null 
-- 		then '����_��8�ܷÿ�' end as mark3
-- 	,t_tmp.*
-- from t_tmp
-- )



-- �鿴����Ŀǰ��ÿ���Ŷӣ�ÿ���˺��ѱ����� 
-- select 
-- 	 NodePathName ,AccountCode
-- 	,count(COALESCE(mark1,mark2))  `mark1_2�ѱ�עuk������` 
-- from res_list_2
-- group by NodePathName ,AccountCode 


-- select BoxSKU  
-- 	,count(distinct concat(shopcode,SellerSku) ) `����������` 
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��1` 
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(shopcode,SellerSku) end ) `����������_��2` 
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(shopcode,SellerSku) end ) `����������_Ȫ1` 
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(shopcode,SellerSku) end ) `����������_Ȫ2` 
-- 	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(shopcode,SellerSku) end ) `����������_Ȫ3` 
-- from res_list_2
-- where length(COALESCE(mark1,mark2)) >0
-- group by BoxSKU  
-- order by `����������`  desc 


-- ,t_site_sort_pre as (
-- select ['UK-1','DE-2','FR-3','ES-4','IT-5','US-6','CA-7','MX-8','AU-9','SE-10','NL-11','PL-12','JP-13'] arr 
-- )
-- 
-- ,t_site_sort as (
-- select split(arr,'-')[1] site ,split(arr,'-')[2] sort
-- from (select unnest as arr 
-- 	from t_site_sort_pre ,unnest(arr)
-- 	) tmp 
-- )




-- , t_list_stat as (
-- select BoxSKU  
-- 	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `��ٻ�����������` 
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1` 
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2` 
-- 	,count(distinct case when NodePathName ='��η�-Ȫ��������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2`
-- 	
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1_UK` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��������' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1_UK` 
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2_UK` 
-- 	,count(distinct case when NodePathName ='��η�-Ȫ��������' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2_UK` 
-- from t_list
-- group by BoxSKU  
-- )


-- 
-- ,t_od_stat as (
-- select shopcode , SellerSKU ,count(distinct PlatOrderNumber ) `22-23�궩����`
-- from t_orde where OrderStatus != '����' and TotalGross > 0 
-- group by shopcode , SellerSKU
-- )
-- 
-- ,t_sale_stat as (
-- select BoxSKU   
-- 	,count(distinct concat(shopcode,sellersku) ) `����������` 
-- 	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��1` 
-- 	,count(distinct case when NodePathName ='���Ԫ-Ȫ��������' then  concat(shopcode,sellersku) end ) `����������_Ȫ1` 
-- 	,count(distinct case when NodePathName ='��η�-�ɶ�������' then  concat(shopcode,sellersku) end ) `����������_��2` 
-- 	,count(distinct case when NodePathName ='��η�-Ȫ��������' then  concat(shopcode,sellersku) end ) `����������_Ȫ2` 
-- from t_orde
-- group by BoxSKU  
-- )

-- ��1 ��ϸ
-- select t_list_stat.* ,t_sale_stat.*
-- -- select count(1)
-- from t_list_stat  
-- left join t_sale_stat on t_sale_stat.boxsku =t_list_stat.boxsku 

-- ��2 ͳ��
-- select 
-- 	count( case when ����������_��1 > 70 then boxsku end) `���Ԫ�ɶ�-����SKU��` 
-- 	,sum( case when ����������_��1 > 70 then  ����������_��1 - 70 end ) `���Ԫ�ɶ�-����������` 
-- 	,count( case when ����������_��2 > 70 then boxsku end) `��η��ɶ�-����SKU��` 
-- 	,sum( case when ����������_��2 > 70 then  ����������_��2 - 70 end ) `��η��ɶ�-����������` 
-- 	,count( case when ����������_Ȫ1 > 70 then boxsku end) `���ԪȪ��-����SKU��` 
-- 	,sum( case when ����������_Ȫ1 > 70 then  ����������_Ȫ1 - 70 end ) `���ԪȪ��-����������` 
-- 	,count( case when ����������_Ȫ2 > 70 then boxsku end) `��η�Ȫ��-����SKU��` 
-- 	,sum( case when ����������_Ȫ2 > 70 then  ����������_Ȫ2 - 70 end ) `��η�Ȫ��-����������` 
-- from t_list_stat  

-- ��3 ÿ����һ��SKU
-- select '���Ԫ-�ɶ�������' `�Ŷ�` ,t_list.* ,`22-23�궩����`  ,`��60��������` ,`��60�����ع���`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3539201 and NodePathName ='���Ԫ-�ɶ�������'
-- union all 
-- select '��η�-�ɶ�������' `�Ŷ�` ,t_list.* ,`22-23�궩����` ,`��60��������` ,`��60�����ع���`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3717359 and NodePathName ='��η�-�ɶ�������'
-- union all 
-- select '���Ԫ-Ȫ��������' `�Ŷ�` ,t_list.* ,`22-23�궩����`  ,`��60��������` ,`��60�����ع���`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3529944 and NodePathName ='���Ԫ-Ȫ��������'
-- union all 
-- select '��η�-Ȫ��������' `�Ŷ�` ,t_list.* ,`22-23�궩����`  ,`��60��������` ,`��60�����ع���`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 4297256 and NodePathName ='��η�-Ȫ��������'
