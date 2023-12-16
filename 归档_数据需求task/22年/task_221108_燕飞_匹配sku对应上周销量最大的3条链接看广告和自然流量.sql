/*
ƥ��sku��Ӧ������������3�����ӣ���Ϣ���֣�
	���۲���/С��/��Ա/�˺�/վ��/����ع���/�������/���ת��/��Ȼ�ÿ�/��Ȼת����
ʹ��listingManage �ҳ�������ߵ�����
*/

with
total_visit as ( -- ÿ��sku������ߵ���������
select * from 
	(select eaal.BoxSku, lm.ShopCode ,StoreSite, ChildAsin as Asin 
		, ms.Department `����` , ms.NodePathName `С��`, ms.SellUserName `��Ա`	
		, OrderedCount ,round(lm.TotalCount * lm.FeaturedOfferPercent / 100)  as total_visit_cnt
		, DENSE_RANK ()over( partition by eaal.BoxSku order by OrderedCount desc ) `��������` -- sale_sort  
	from import_data.ListingManage lm 
	join import_data.erp_amazon_amazon_listing eaal on eaal.ASIN =lm.ChildAsin and eaal.ShopCode = lm.ShopCode
	join (select Spu as `��Ʒ��` , BoxSku from import_data.JinqinSku js where Monday='2022-11-08') tmpsku
		on eaal.BoxSku = tmpsku.BoxSku
	join import_data.mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus ='����'
	where ReportType = '�ܱ�' and lm.Monday = date_add('${next_frist_day}',interval -7 day) 
		and FeaturedOfferPercent > 0 and OrderedCount > 0 
	) tmp
where `��������` <= 3
)

select tv.* , tmp.`����ع���` , tmp.`�������` , tmp.`���ת����`
	, total_visit_cnt-ifnull(`�������`,0) as `��Ȼ�ÿ���`
	, round((OrderedCount-ifnull(`�������`,0))/(total_visit_cnt-ifnull(`�������`,0)),4) `��Ȼת����`
from total_visit tv 
left join (
	select 
		eaal.ShopCode, eaal.ASIN , ifnull(sum(Exposure),0) `����ع���`, round(ifnull(sum(clicks)/sum(Exposure),0),4) `�������`
		, ifnull(sum(clicks),0) `�������` , ifnull(sum(TotalSale7DayUnit),0) `�������`, ifnull(sum(TotalSale7DayUnit)/sum(clicks),0) `���ת����` 
	from import_data.AdServing_Amazon asa 
	join import_data.erp_amazon_amazon_listing eaal 
		on eaal.ShopCode =asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> '' and eaal.SellerSKU not regexp '-BJ-|-BJ|BJ-'
	where asa.CreatedTime>=date_add('${next_frist_day}',interval -8 day) and asa.CreatedTime < date_add('${next_frist_day}',interval -1 day)
	group by eaal.ShopCode, eaal.ASIN
	) tmp on tv.Asin =tmp.Asin and tv.ShopCode = tmp.ShopCode

