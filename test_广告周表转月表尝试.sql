
,t_ad as ( -- �ܹ���ת�¹��� # todo ������ͼ �ܹ���ת�¹���
select *,case when pre_ad_days < 0 then 0.1 else pre_ad_days end ad_days -- ���ڹ��ʱ�������״ο���ʱ�䣬��������ϴ
from (
select asa.ShopCode ,asa.Asin  ,asa.SellerSKU ,asa.year ,asa.week
    , AdExposure ,AdClicks ,AdSaleUnits
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as pre_ad_days -- ���Ǻ�14����
from tmp_lst t_list
join import_data.wt_adserving_amazon_weekly asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU and t_list.asin = asa.asin
left join ( --
    select week_num_in_year ,week_begin_date ,week_end_date
                ,case when month(week_begin_date) !=  month(week_end_date) then '������' end isacross
            from dim_date
    )  dd on asa.Week = dd.week_num_in_year and dd.year = 2023 and dd.full_date < '2023-10-01'
where asa.gen >= '${StartDay}' and  asa.CreatedTime < '${NextStartDay}'
) t1
)