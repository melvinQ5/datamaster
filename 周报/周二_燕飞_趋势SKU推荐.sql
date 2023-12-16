
/*
-- ÿ�ܶ� ���ܶ������õ�����һ�ܹ�����ݣ�
UK,DE 2��վ�㵥վ��Ķ������ﵽ���±�׼��SKU��
1����7��4�����ϳ���
2����7���ۼ�5���һ���ǰ7�쵥����1.5��
3����14��͵���8������

�ֶ�Ҫ���֣�SPU��SKU������SKU��վ�㣨����SKU�Ǵ��ĸ�վ��Ķ��������ģ�
�����������۶����Ȫ�ݿ�������
��Ȫ�ݿ����˺ţ��˺����ֵ�����PQ-EU���������������ɣ�
��Ȫ�ݿ���������Ա��Ԫ�ر�ǩ������ʱ�䣬��ȡ�ܱ�
*/

-- NextStartDay ȡ��һ���Ա��7��ǰ7��Ӧ��Ȼ��

with
t_prod as ( -- ��Ʒ:7�º�����
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
    ,case when date_add(Product_DevelopLastAuditTime , interval - 8 hour) >=  '2023-07-01'
        then '��Ʒ' else '��Ʒ' end as isnewpp
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,ms.site
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 8 then 1 else 0 end as isOver8usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
where
	PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -14 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType = '����' -- δ����������Ϊ����
     and ms.nodepathname regexp 'Ȫ��'
)

-- ---------- ��Ʒ���ǩ
,t_orde_stat as ( -- ��Ʒ���ǩ����������
select SKU ,site
	,count( distinct case when timestampdiff(SECOND,paytime,subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1))/86400  <= 14 then PlatOrderNumber end) orders_in14d
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver8usd = 1 then PlatOrderNumber end ) orders_over_8usd -- ���˷ѳ�8���𶩵���
from t_orde
where site regexp 'DE|UK'
group by SKU ,site
)
-- select * from t_orde_stat

,pre_prod_mark as (
select SKU ,site  ,'��7���4������ҿ͵���8' prod_type
from t_orde_stat where  order_days_in1_7 >= 4 and  orders_over_8usd >= 0
union
select SKU ,site  ,'��7���ۼ�5���ҽ�ǰ7���1.5���ҿ͵���8' prod_type
from t_orde_stat where  orders_in1_7 >= 5 and orders_in1_7 / orders_in8_14 >=1.5 and  orders_over_8usd >= 0
)

,prod_mark as (
select a.sku  ,prod_type ,type_source_site
from (select distinct sku from  pre_prod_mark ) a
left join (
	select SKU ,GROUP_CONCAT(prod_type) prod_type
	from (select distinct  SKU ,prod_type from pre_prod_mark) tmp group by SKU ) b on a.sku = b.sku
left join (
	select SKU ,GROUP_CONCAT(source) type_source_site
	from (select distinct  SKU ,concat(site ,prod_type) as source  from pre_prod_mark) tmp group by SKU ) c on a.sku = c.sku
)
-- select * from prod_mark

-- ----------���㶩������
,t_orde_week_stat as ( -- �����ۼƶ��� ��������վ�㣩
select SKU
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then PlatOrderNumber end ) as total_orders_in1_7
	,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then PlatOrderNumber end ) as total_orders_in8_14

    ,sum(  case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then salecount end ) as total_salecount_in1_7
	,sum(  case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then salecount end ) as total_salecount_in8_14

    ,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then TotalGross/ExchangeUSD end ),2) as TotalGross_in1_7
	,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then TotalGross/ExchangeUSD end ),2) as TotalGross_in8_14

    ,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then TotalProfit/ExchangeUSD end ),2) as TotalProfit_in1_7
	,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then TotalProfit/ExchangeUSD end ),2) as TotalProfit_in8_14
from t_orde
where PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1), INTERVAL -14 DAY) and PayTime < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by SKU
)
-- select * from t_orde_week_stat


,t_list as (
select eaal.SPU ,eaal.SKU ,BoxSku  ,MarketType ,SellerSKU ,ShopCode ,asin
	,DevelopUserName ,ProductStatus
	,ms.Site ,ms.SellUserName  ,ms.NodePathName ,ms.CompanyCode ,ms.Accountcode
from import_data.erp_amazon_amazon_listing eaal
join prod_mark on eaal.sku = prod_mark.sku
join import_data.mysql_store ms on eaal.ShopCode = ms.Code and ms.shopstatus = '����' and eaal.listingstatus = 1
    and ms.Department = '��ٻ�' and ms.nodepathname regexp 'Ȫ��' and eaal.IsDeleted = 0
)

,t_list_stat as (
select a.sku ,online_Co_cnt ,online_shop_name_concated ,online_seller_concated
from (select sku ,count( distinct CompanyCode ) online_Co_cnt from t_list group by sku ) a
left join ( select sku ,group_concat(Accountcode ) online_shop_name_concated  from ( select distinct sku ,Accountcode from t_list ) t group by sku ) b on a.sku = b.sku
left join ( select sku ,group_concat(SellUserName ) online_seller_concated  from ( select distinct sku ,SellUserName from t_list ) t group by sku ) c on a.sku = c.sku
)

, t_ad_stat as (
select sku
    ,sum( case when  CreatedTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and CreatedTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then Spend end ) as ad_spend_in1_7
    ,sum( case when  CreatedTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and CreatedTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then Spend end ) as ad_spend_in8_14
from (select distinct shopcode ,sellersku ,sku from t_orde ) ta
left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU
group by sku
)
-- select * from t_ad_stat

,t_merage as (
select
	prod_mark.prod_type `����SKU��ǩ`
    ,prod_mark.type_source_site `��ǩ��Դվ��`
    ,prod_mark.sku
    ,wp.spu
    ,wp.boxsku
    ,date(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)) `����ͳ������`

    ,round( ifnull(TotalGross_in1_7,0) + ifnull(TotalGross_in8_14,0) ,2) `��14�������۶�`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) + TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0) ),2)  `14���������`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) + TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0) ) / (ifnull(TotalGross_in1_7,0) + ifnull(TotalGross_in8_14,0) ) ,4 )  `��14��������`
    ,ifnull(total_orders_in1_7,0) + ifnull(total_orders_in8_14,0) `��14���ܶ�����`



    ,TotalGross_in1_7 `��7�������۶�`
    ,round(TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0),2) `��7���������`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) )/ TotalGross_in1_7 ,4 )  `��7��������`
    ,total_orders_in1_7 `��7���ܶ�����`
    ,total_salecount_in1_7 `��7��������`

    ,TotalGross_in8_14 `ǰ7�������۶�`
    ,round(TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0),2) `ǰ7���������`
    ,round( (TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0))/ TotalGross_in8_14 ,4 )  `ǰ7��������`
    ,total_orders_in8_14 `ǰ7���ܶ�����`
    ,total_salecount_in8_14 `ǰ7��������`
     
    ,online_Co_cnt `Ȫ�������˺�����`
    ,online_shop_name_concated `Ȫ�������˺�վ��`
    ,online_seller_concated `��ѡҵ��Ա`
	,ProductName 
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as  `��Ʒ״̬`
	,ele_name `Ԫ��`
	,dkpl.prod_level `������`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  `��Ʒ����ʱ��`
	,left(DevelopLastAuditTime,7) `��Ʒ�����·�`
	,DevelopUserName `������Ա`
from prod_mark
left join import_data.wt_products wp on prod_mark.sku =wp.sku and wp.IsDeleted = 0
left join t_list_stat on t_list_stat.sku = prod_mark.SKU
left join t_ad_stat on t_ad_stat.sku = prod_mark.SKU
left join t_orde_week_stat on  t_orde_week_stat.sku = prod_mark.SKU
left join ( -- Ԫ��ӳ�����С������ SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on prod_mark.sku =t_elem .sku
left join ( select spu ,prod_level,FirstDay from dep_kbh_product_level where department = '��ٻ�' and FirstDay = (select max(firstday) from dep_kbh_product_level) ) dkpl
	on wp.spu = dkpl.spu
)

-- select list_type ,count(DISTINCT shopcode  ,sellersku ) from t_ad_stat group by list_type   '`prod_key`.`ad_stat_week`' 
select * from t_merage