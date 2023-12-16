
with t_list as ( -- �̻�����
select wl.shopcode ,wl.sellersku ,sku ,spu ,nodepathname ,SellUserName  ,site ,m.c4 as activate_week ,MinPublicationDate
from manual_table m
join import_data.wt_listing wl on m.handlename ='��ٻ��̻�����' and handletime = '2023-09-19' and wl.IsDeleted = 0 and m.c2 =wl.shopcode and m.c3=wl.sellersku
join import_data.mysql_store ms on wl.shopcode=ms.Code and department = '��ٻ�'
)




,t_orde_week_stat as ( -- �����ۼƶ���
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum(FeeGross/ExchangeUSD ),2 ) FeeGross_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType != '����' -- δ����������Ϊ����
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select ta.shopcode  ,ta.sellersku ,week_num_in_year as ad_stat_week
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
		from t_list ta -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
        left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU
        join dim_date on dim_date.full_date = asa.CreatedTime
        group by ta.shopcode  ,ta.sellersku  ,ad_stat_week
	) tmp
)


,prod as (
select wp.spu ,wp.sku,boxsku ,DevelopLastAuditTime ,prod_level
from wt_products wp
join (select distinct sku from t_list ) l on wp.sku = l.sku
LEFT JOIN ( SELECT distinct spu ,prod_level from dep_kbh_product_level where FirstDay =  date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -1 week) ) dk
    on wp.spu =dk.spu
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)

,prod_seller as (
select sku ,group_concat(SellUserName) seller_list
from (
    select sku, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0
    group by sku, eaapis.SellUserName
    ) tmp
group by sku
)

,t_merage as (
select t1.shopcode ,t1.sellersku
    ,t1.activate_week �̻���
	,key_week ��Ȼ��
    ,pay_week ������
    ,case when nodepathname regexp '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ���۲���
    ,nodepathname as ����С��
    ,SellUserName as ��ѡҵ��Ա
    ,site as ����
    ,t6.SKU
    ,t6.boxsku
    ,t6.SPU
    ,prod_level ������Ʒ�ֲ�
    ,DevelopLastAuditTime ��Ʒ����ʱ��
    ,ele Ԫ��
    ,seller_list sku���۸�����
    ,DATE(MinPublicationDate) �����ϼ�ʱ��
    ,TotalGross_weekly `���۶�`
    ,round(TotalProfit_weekly - ifnull(ad_Spend,0),2) `�۹�������`
    ,salecount_weekly `����`
    ,FeeGross_weekly `�˷�����`
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

from ( select lm.* , week_num_in_year as key_week
	from t_list lm
	join ( select distinct week_num_in_year
	       from dim_date dd
	        join (select max(activate_week) max_activate_week  from t_list ) lmax -- ��ȡ����̻��ܴ�
	        join (select min(activate_week) min_activate_week  from t_list ) lmax -- ��ȡ����̻��ܴ�
	       where year= year('${NextStartDay}') and week_num_in_year <= max_activate_week + 4 and week_num_in_year >= min_activate_week ) dd
	) t1
left join t_orde_week_stat t2 on t1.shopcode = t2.shopcode and t1.sellersku = t2.sellersku and t1.key_week = t2.pay_week and t2.pay_week <= t1.activate_week +4
left join t_ad_stat t3 on t1.shopcode = t3.shopcode and t1.sellersku = t3.sellersku and t1.key_week = t3.ad_stat_week and t3.ad_stat_week <= t1.activate_week +4
left join prod_seller t4 on t1.sku =t4.sku
left join t_elem t5 on t1.sku =t5.sku
left join prod t6 on t1.sku =t6.sku
)

select * from t_merage where ������ is null and �̻��� = ��Ȼ��
union all
select * from t_merage where ������ is not null

-- select * from t_merage order by ShopCode ,SellerSKU ,������