
/*
-- ÿ�ܶ� ���ܶ������õ�����һ�ܹ�����ݣ�
���Ӿ�Ӫ��ǩ���ͣ�
��Ʒ1 '��14��3��+'
��Ʒ2 '���˷ѿ͵�20usd�ҽ�14��2��+'
ȫƷ '��30���վ�0.5��'
��Ʒ1 ������4��������ڳ�������ͳ�����ڣ�����1-7�� �� ��8-14�����ܶԱȣ�
��Ʒ2 ���ܳ���5�����ϣ�ͬʱ��������������1.5�����ϣ���ͳ�����ڣ�����1-7�� �� ��8-14�����ܶԱȣ�
*/

-- �������ɱ��������ݣ������ɴ˱�ǩ������
-- 'team' �滻�� 'Ȫ��'

with
t_prod as ( -- ��Ʒ:3�º�����
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' 
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�' and Status = 10
)
-- select * from epp  '`DevelopLastAuditTime`' 

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU
	,wo.Product_Sku  as SKU
    ,case when date_add(Product_DevelopLastAuditTime , interval - 8 hour) >= '2023-07-01'
        then '��Ʒ' else '��Ʒ' end as isnewpp
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
where
	PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -30 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType = '����' -- δ����������Ϊ����
	and NodePathName regexp '${team}'
)
-- select * from t_orde 
-- ----------���Ӵ��ǩ
,t_orde_stat as ( -- ���ӱ�ǩ����������
select shopcode  ,sellersku ,isnewpp
	,count(distinct case when timestampdiff(SECOND,paytime, subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) )/86400  <= 14 then PlatOrderNumber end) orders_in14d
	,count(distinct case when timestampdiff(SECOND,paytime, subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) )/86400  <= 30 then PlatOrderNumber end) orders_in30d
    ,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -14 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver20usd = 1 then PlatOrderNumber end ) orders_over_20usd -- ���˷ѳ�20���𶩵���
from t_orde
group by shopcode  ,sellersku ,isnewpp
)
-- select * from t_orde_stat

,list_mark as (
	select shopcode  ,sellersku ,GROUP_CONCAT(list_type) list_type
	from (

        select shopcode  ,sellersku
        ,case when orders_in30d/30 >5 then 'ȫ_��30���վ���5��' 
        	when orders_in30d/30 >= 3 then 'ȫ_��30���վ�3-5��'
        	when orders_in30d/30 >= 1 then 'ȫ_��30���վ�1-3��'
        	else 'ȫ_��30���վ�0.5-1��'
        end as list_type
		from t_orde_stat where orders_in30d/30 >= 0.5
        union
		select shopcode  ,sellersku  ,'��_��14��3��+' list_type
		from t_orde_stat where orders_in14d >= 3 and isnewpp = '��Ʒ' -- 14���ڳ�3��
		union
		select shopcode  ,sellersku  ,'��_���˷ѿ͵�20usd�ҽ�14��2��+' list_type
		from t_orde_stat where orders_over_20usd > 0 and  orders_in14d >= 2 and isnewpp = '��Ʒ'
		union
		select shopcode  ,sellersku  ,'��_��7���4�����' list_type
		from t_orde_stat where isnewpp = '��Ʒ' and order_days_in1_7 >= 4
		union
		select shopcode  ,sellersku  ,'��_��7���ۼ�5���һ���ǰ7�쵥����1.5��' list_type
		from t_orde_stat where isnewpp = '��Ʒ' and orders_in1_7 >= 5 and orders_in1_7 / orders_in8_14 >=1.5



		) tb
	group by shopcode  ,sellersku
)

-- ----------���㶩������
,t_orde_week_stat as ( -- �����ۼƶ���
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_weekly
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -7*10 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType = '����' -- δ����������Ϊ����
	and NodePathName regexp '${team}'
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

-- ----------���������

,t_list as (
select wl.SPU ,wl.SKU ,BoxSku ,MinPublicationDate ,MarketType ,wl.SellerSKU ,wl.ShopCode ,asin
	,DevelopLastAuditTime ,ProductName ,DevelopUserName
	,case when TortType is null then 'δ���' else TortType end TortType 
	,Festival ,ProductStatus
	,AccountCode  ,ms.Site
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�'
left join ( -- Ԫ��ӳ�����С������ SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on wl.sku =t_elem .sku
left join (
	select sku ,ProductName ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		from import_data.wt_products wp where IsDeleted =0 
	) ta on wl.sku =ta.sku 
join (select shopcode,sellersku from erp_amazon_amazon_listing  group by shopcode,sellersku ) undeleted on wl.ShopCode =undeleted.ShopCode and wl.sellersku = undeleted.sellersku
where NodePathName regexp '${team}'

)

,t_ad as ( -- �Ż����Ӷ�Ӧ�������
select asa.AdActivityName ,campaignBudget ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure ,asa.Spend
	,ROAS ,Acost as ACOS 
	, ta.ShopCode ,ta.SellerSKU 
	, asa.CreatedTime ,asa.Asin  
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
	, list_type
from list_mark ta -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU 
	and asa.CreatedTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -7*10 DAY) and  asa.CreatedTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
left join dim_date on dim_date.full_date = asa.CreatedTime
)

-- select * from t_ad WHERE ASIN = 'B01FRWGI0G' LIMIT 10 ;

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,list_type
		-- �ع���
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(Spend),2) as ad_Spend
		-- ������۶�
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,list_type
	) tmp
)
-- select * from t_ad_stat

, t_ad_name as ( -- �������
select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	, GROUP_CONCAT(AdActivityName) AdActivityName
from ( select shopcode  ,sellersku  ,ad_week_begin_date ,ad_stat_week,AdActivityName from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,AdActivityName ) tb
group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
)
-- select * from t_ad_name 



,t_merage as (
select
	date( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ) `�������ͳ�ƽ�������`
    ,lst_key.list_type `��Ӫ�Ż���ǩ`
    ,lst_key.shopcode `���̼���`
	,lst_key.sellersku `����sku`
     ,case when t_list.SellerSKU is null then '������ɾ��' else '' end as �����Ƿ�ɾ��
    ,t_list.site `վ��`
    ,t_list.asin
	,t_list.AccountCode `�˺�`
	,t_list.NodePathName `�����Ŷ�`
	,t_list.SellUserName `��ѡҵ��Ա`
    ,orders_in30d `��30�충����`
	,orders_in14d `��14�충����`
	,orders_in1_7 `��7�충����`
	
	,week_num_in_year `��Ȼ�ܴ�`
 	,pay_week `����ͳ����`
	,TotalGross_weekly `���������۶�`
	,TotalProfit_weekly - ifnull(ad_Spend,0) `�����������`
	,orders_weekly `�����ܶ�����`
	,salecount_weekly `������sku����`
	
	,t_ad_stat.ad_stat_week `���ͳ����`
-- 	,t_ad_stat.ad_week_begin_date `��浱����һ`
	,AdActivityName `���ܹ��`
	,ad_sku_Exposure `���ܹ���ع���`
	,ad_Spend `���ܹ�滨��`
	,ad_TotalSale7Day `���ܹ�����۶�`
	,ad_sku_TotalSale7DayUnit `���ܹ������`
	,ad_sku_Clicks `���ܹ������` 
	,click_rate `���ܹ������`
	,adsale_rate `���ܹ��ת����`
	,ROAS `����ROAS`
	,ACOS `����ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `����CPC`
	
	,t_list.spu
	,dkpl.prod_level `������`
    ,date(date_add(dkpl.FirstDay,interval 1 week)) `����������`
	,t_list.sku 
	,t_list.boxsku 
	,ProductName 
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name `Ԫ��` 
	,t_list.DevelopLastAuditTime `��Ʒ����ʱ��`
	,left(t_list.DevelopLastAuditTime,7) `��Ʒ�����·�`
	,DevelopUserName `������Ա`
from 
	( select lm.* , week_num_in_year
	from list_mark lm 
	join ( select distinct week_num_in_year from dim_date 
		where full_date >= date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -30 DAY) and full_date <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ) dd 
	order by shopcode  ,sellersku ,week_num_in_year
	) lst_key 
left join t_ad_stat on  t_ad_stat.ShopCode = lst_key.ShopCode and t_ad_stat.SellerSKU = lst_key.SellerSKU and lst_key.week_num_in_year = t_ad_stat.ad_stat_week 
left join t_ad_name on  lst_key.ShopCode = t_ad_name.ShopCode and lst_key.SellerSKU = t_ad_name.SellerSKU and lst_key.week_num_in_year = t_ad_name.ad_stat_week
left join t_list on  t_list.ShopCode = lst_key.ShopCode and t_list.SellerSKU = lst_key.SellerSKU 
left join t_prod on t_list.sku = t_prod.sku 
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU 
left join t_orde_week_stat on  lst_key.ShopCode = t_orde_week_stat.ShopCode and lst_key.SellerSKU = t_orde_week_stat.SellerSKU 
	and lst_key.week_num_in_year = t_orde_week_stat.pay_week
left join ( select spu ,prod_level,FirstDay from dep_kbh_product_level where department = '��ٻ�' and FirstDay = (select max(firstday) from dep_kbh_product_level) ) dkpl
	on t_list.spu = dkpl.spu
)

-- select list_type ,count(DISTINCT shopcode  ,sellersku ) from t_ad_stat group by list_type   '`lst_key`.`ad_stat_week`' 
select * from t_merage 
order by `����sku` ,`���ͳ����`