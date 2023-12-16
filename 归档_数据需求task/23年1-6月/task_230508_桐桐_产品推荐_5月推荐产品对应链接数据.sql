
with t_prod as ( -- ͩͩ�����ֹ����ṩ����
select c2 as sku ,c3 as boxsku
from manual_table mt where c1 = '��Ʒ�Ƽ�ȷ����400��Ʒ230508'
)

-- ����
,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	, accountcode
	, NodePathName 
	, split_part(ms.NodePathNameFull,'>',2) dep2
	, split_part(ms.accountcode,'-',1) �˺ż���
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,case when ListingStatus = 1 and ms.ShopStatus = '����' then '����' else '������' end as ����״̬
	,t_prod.boxsku 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
where 
-- 	MinPublicationDate>= date_add('${NextStartDay}' ,interval - 3 month) and MinPublicationDate <'${NextStartDay}' 
	wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)
-- select count(1) from t_list where ����״̬ = '����'

-- ���
,t_ad as ( -- �����ϸ
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	,t_list.site
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= date_add('${NextStartDay}' ,interval - 3 month) and asa.CreatedTime  <'${NextStartDay}' 
)
 
-- ����  '`wo`.`Product_SPU`' 
-- ���� ���sku������sku���˻��˺�
,tb as ( -- ��ٻ��黹�����600���˺�
select c2 as arr from  manual_table mt where c1 = '��ٻ��˻ز����˺�0427'
)

,rela as (
select *
from 
	(select 
		epp1.sku as ori_sku ,epp1.BoxSKU as ori_boxsku ,epp1.ProjectTeam as ori_team 
		,epp2.sku as new_sku ,epp2.BoxSKU as new_boxsku ,epp2.ProjectTeam as new_team 
	from import_data.erp_product_product_copy_relations eppcr 
	left join import_data.erp_product_products epp1 on eppcr.OrigProdId = epp1.Id and epp1.IsMatrix =0
	left join import_data.erp_product_products epp2 on eppcr.NewProdId = epp2.Id and epp2.IsMatrix =0
	where eppcr.IsDeleted = 0 and epp1.Id is not null -- ȥ��ĸ�帴�ƹ�ϵ�ļ�¼
	) tb
where ori_team <> '��ٻ�' and new_team = '��ٻ�'  -- ���������Ÿ��Ƶ���ٻ���sku
)

-- ���۶�S1 δ��˰δ���˿�
,od_pre as ( -- �����ֶ�����¼����ٻ������˺ų���(����sku����������ƹ�ϵ���ԴSKU) + ��ٻ��˻ز����˺�(����sku����������ƹ�ϵ���ԴSKU) 
select BoxSku, paytime ,SaleCount ,totalgross + TaxGross as totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,wo.shopcode ,wo.SellerSku ,Product_SPU ,Product_Sku
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as targetsku 		
	,case when GroupSkuNumber > 0 then '��ϳ���' else '����ϳ���' end as isgroup_pre 		
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- ��ʱ���� ���ƹ�ϵ
where wo.IsDeleted = 0 and OrderStatus != '����' and ms.Department = '��ٻ�' and TransactionType = '����'
	and PayTime >= date_add('${NextStartDay}' ,interval - 3 month) and PayTime < '${NextStartDay}' 
union 
select BoxSku, paytime ,SaleCount  ,totalgross + TaxGross as totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,wo.shopcode ,wo.SellerSku ,Product_SPU ,Product_Sku
	,case when GroupSkuNumber > 0  then GroupSku else BoxSku end  as targetsku 
	,case when GroupSkuNumber > 0 then '��ϳ���' else '����ϳ���' end as isgroup_pre 	
from import_data.wt_orderdetails wo 
join tb on wo.shopcode = tb.arr -- ��ٻ��黹�����600���˺�
-- join rela on wo.BoxSku = rela.ori_boxsku  -- ��ʱ���� ���ƹ�ϵ
where wo.IsDeleted = 0 and OrderStatus != '����' and TransactionType = '����' 
	and PayTime >= date_add('${NextStartDay}' ,interval - 3 month) and PayTime < '${NextStartDay}' 
)

, boxsku_2_groupsku as ( -- ����������� ����SKUֱ��ͬ����ת��Ϊ���SKU������ɲ鶩���� boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup regexp '��ϳ���' then '��ϳ���' else '����ϳ���' end as isgroup -- ֻҪ���й���ϳ���������Ϊ��ϳ���
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku  ,site  ,ShopCode ,SellerSKU ,Product_SPU ,Product_Sku
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)

,t_orde as (  -- �¿������Ӷ�Ӧ����
select 
	t_list.SellerSKU ,t_list.ShopCode ,t_list.asin ,od.boxsku 
	,PlatOrderNumber ,TotalGross,TotalProfit ,salecount
	,ExchangeUSD
	,Product_SPU as SPU 
	,Product_Sku  as SKU 
	,PayTime
	,t_list.site
	, NodePathName 
	, SellUserName
from od
join t_list on t_list.ShopCode = od.ShopCode and t_list.SellerSKU = od.SellerSKU -- ֻ����ٻ� �¿�����Ʒ���ӵĶ�Ӧ����
)
-- select * from t_orde where boxsku = 2362609 

,t_orde_stat as (
select shopcode  ,sellersku  
	,round(sum( TotalGross/ExchangeUSD ),2) TotalGross
	,round(sum( TotalProfit/ExchangeUSD ),2) TotalProfit
	,round(sum( TotalProfit/TotalGross ),2) ProfitRate
	,round(sum( salecount ),2) salecount
from t_orde 
group by shopcode  ,sellersku  
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�������` 
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/ad_TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/ad_sku_Clicks,4) as `CPC`
from 
	( select shopcode  ,sellersku 
		-- �ع���
		, round(sum( Exposure )) as ad_sku_Exposure
		-- ��滨��
		, round(sum( cost*ExchangeUSD),2) as ad_Spend
		-- ������۶�
		, round(sum( TotalSale7Day ),2) as ad_TotalSale7Day
		-- �������	
		, round(sum( TotalSale7DayUnit ),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum( Clicks )) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)

select 
	t_list.sku
	,ta.boxsku
	,t_list.SellerSKU 
	,t_list.ShopCode 
	,����״̬
	,asin 
	,accountcode 
	,�˺ż���
	,site վ��
	,dep2 ���۲���
	,NodePathName �����Ŷ�
	,SellUserName ��ѡҵ��Ա
	,TotalGross ���۶�_��3��
	,TotalProfit �����_��3��
	,ProfitRate ������_��3��
	,salecount ����_��3��
	,CPC
	,ACOS
	,ad_Spend ��滨��
	,ad_TotalSale7Day ���ҵ��
	,���ת����
	,�������
	,ad_sku_Clicks as �����
	,ad_sku_Exposure as �ع���
	,case when round(ad_TotalSale7Day/TotalGross,2) >1 then 1 else round(ad_TotalSale7Day/TotalGross,2) end  ���ҵ��ռ��
-- 	,round(ad_TotalSale7Day/TotalGross,2)  ���ҵ��ռ��
from t_list
left join (
	select sku ,boxsku ,case when TortType is null then 'δ���' else TortType end TortType ,Festival ,Artist ,Editor 
		,ProductName ,DevelopUserName ,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) as DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		from import_data.wt_products wp
		where IsDeleted =0  and ProjectTeam='��ٻ�'
	) ta on t_list.sku =ta.sku 
left join t_ad_stat on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
where ����״̬ = '����'
order by sku , ���۲��� , �����Ŷ� ,��ѡҵ��Ա