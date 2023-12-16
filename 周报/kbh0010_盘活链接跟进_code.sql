
with
t_elem as (  -- һ����Ʒ���Ԫ�� ���ᵼ�¶������������ظ�������׼ȷ����ÿ��Ԫ�ص����۶�
select distinct eppaea.sku ,eppea.Name  ele
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
)

,t_list as ( -- �̻�����
select wl.shopcode ,wl.sellersku ,wl.sku ,spu ,nodepathname ,SellUserName ,m.c4 as activate_week ,MinPublicationDate ,ele ,site
from manual_table m
join import_data.wt_listing wl on m.handlename ='��ٻ��̻�����' and handletime = '2023-09-19' and wl.IsDeleted = 0 and m.c2 =wl.shopcode and m.c3=wl.sellersku
join import_data.mysql_store ms on wl.shopcode=ms.Code and department = '��ٻ�'
left join t_elem on t_elem.sku = wl.sku
)


,t_list_stat as ( -- �̻����ӵ�����SKUͳ��
select m.c2 as ShopCode  ,count(distinct concat(m.c3,m.c2)) sellersku_cnt
from manual_table m  group by ShopCode
)


,t_list_activate_week_stat as (
select ShopCode  ,group_concat(activate_week) activate_week_group
from (
    select  m.c2 as ShopCode  ,m.c4 as activate_week
    from  manual_table m group by  m.c2  , m.c4
    ) t1
group by ShopCode
)

,t_orde_week_stat as ( -- �����ۼƶ���
select wo.shopcode,dim_date.week_num_in_year as pay_week
	,round( sum(salecount),2 ) salecount_weekly
	,round( count(distinct PlatOrderNumber),2 ) orders_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum(FeeGross/ExchangeUSD ),2 ) FeeGross_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
    ,count(distinct concat(wo.sellersku,wo.shopcode)) orders_sellersku_cnt_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_list on wo.SellerSku = t_list.SellerSKU and wo.shopcode = t_list.ShopCode  -- �̻�����
left join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType != '����' -- δ����������Ϊ����
group by wo.shopcode  ,dim_date.week_num_in_year
)

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select ta.shopcode   ,week_num_in_year as ad_stat_week
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
        group by ta.shopcode    ,ad_stat_week
	) tmp
)

,t_merage as (
select t1.shopcode
    ,activate_week_group �̻���
    ,key_week ��Ȼ��
    ,pay_week ������
    ,site as վ��
    ,sellersku_cnt as  ʵ�ʽ���������
    ,orders_sellersku_cnt_weekly ����������
    ,round( orders_sellersku_cnt_weekly / sellersku_cnt ,4 ) �̻���
    ,TotalGross_weekly `���۶�`
    ,round(TotalProfit_weekly - ifnull(ad_Spend,0),2) `�۹�������`
    ,round( (TotalProfit_weekly - ifnull(ad_Spend,0)) / TotalGross_weekly ,4 ) ������
    ,salecount_weekly `����`
    ,round( TotalGross_weekly / orders_weekly ,2 ) ƽ���͵���
    ,case when nodepathname regexp '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ���۲���
    ,nodepathname as ����С��
    ,SellUserName as ��ѡҵ��Ա
from ( select lm.* , week_num_in_year as key_week
	from t_list_stat lm
	join ( select distinct week_num_in_year
	       from dim_date dd
	        join (select max(activate_week) max_activate_week  from t_list ) lmax -- ��ȡ����̻��ܴ�
	        join (select min(activate_week) min_activate_week  from t_list ) lmax -- ��ȡ����̻��ܴ�
	       where year= year('${NextStartDay}') and week_num_in_year <= max_activate_week + 4 and week_num_in_year >= min_activate_week ) dd
	) t1
left join t_orde_week_stat t2 on t1.shopcode = t2.shopcode and t1.key_week = t2.pay_week and t2.pay_week <= t1.key_week +4
join mysql_store ms on t1.shopcode = ms.code and ms.Department='��ٻ�'
-- join t_list t2 on t1.shopcode = t2.shopcode and t1.sellersku = t2.sellersku
left join t_ad_stat t3 on t1.shopcode = t3.shopcode and t1.key_week = t3.ad_stat_week and t3.ad_stat_week <= t1.key_week +4
-- left join t_list_stat t4 on t1.ShopCode =t4.ShopCode  -- ͳ���̻�����SKU��
left join t_list_activate_week_stat t5 on t1.shopcode = t5.shopcode
)



select * from t_merage