select dpd.`��������` ,`daily_PackageDetail����`,`wt_packagedetail����`, `PackageDetail����`
	, `daily_PackageDetail����` - `wt_packagedetail����` as `�ո�-������`
	, `PackageDetail����` - `daily_PackageDetail����` as `�¸�-�ո�����`
from (
	select to_date(WeightTime) `��������`, count(1) `daily_PackageDetail����`
	from import_data.daily_PackageDetail   
	group by to_date(WeightTime) 
	order by to_date(WeightTime) desc 
	) dpd 
left join ( 
	select to_date(WeightTime) `��������`, count(1) `wt_packagedetail����`
	from import_data.wt_packagedetail wp 
	group by to_date(WeightTime)
	order by to_date(WeightTime) desc 
	) wt on dpd.`��������` = wt.`��������`
left join ( 
	select to_date(WeightTime) `��������`, count(1) `PackageDetail����`
	from import_data.PackageDetail pd   
	group by to_date(WeightTime)
	order by to_date(WeightTime) desc 
	) pd on dpd.`��������` = pd.`��������`
order by dpd.`��������` desc 

select dpd.PackageNumber 
from import_data.daily_PackageDetail dpd 
-- left join import_data.wt_packagedetail wp on dpd.PackageNumber = wp.PackageNumber
where to_date(dpd.WeightTime) = '2022-10-27' 
-- and wp.PackageNumber is null 

select dpd.PackageNumber from 
(
select distinct PackageNumber 
from import_data.daily_PackageDetail  
where to_date(WeightTime) = '2022-10-27'
) dpd
left join
(
select distinct PackageNumber 
from import_data.wt_packagedetail   
where to_date(WeightTime) = '2022-10-27'
) wp
on dpd.PackageNumber =wp.PackageNumber
where wp.PackageNumber is null 



select dpd.`��������` ,`daily_PackageDetail����` - `wt_packagedetail����` as `�ո�-������`
    ,`daily_PackageDetail����`,`wt_packagedetail����`
from (
	select to_date(CreatedTime) `��������`, count(1) `daily_PackageDetail����`
	from import_data.daily_PackageDetail   
	group by to_date(CreatedTime) 
	order by to_date(CreatedTime) desc 
	) dpd 
left join ( 
	select to_date(CreatedTime) `��������`, count(1) `wt_packagedetail����`
	from import_data.wt_packagedetail wp 
	group by to_date(CreatedTime)
	order by to_date(CreatedTime) desc 
	) wt on dpd.`��������` = wt.`��������`
where  dpd.`��������` > '2022-10-15' and  dpd.`��������` < '2022-11-03'
order by dpd.`��������` desc 


select to_date(CreatedTime),count(1)
	from import_data.wt_packagedetail dpd
	where PackageTotalWeight IS NULL
    group by to_date(CreatedTime)
    order by to_date(CreatedTime) desc  
   
    
select 
	 to_date( dorisimporttime)  , count(1)
from (
	select PackageNumber 
	from import_data.wt_packagedetail dpd
	where PackageTotalWeight IS NULL
	group by PackageNumber 
	) tmp 
join 
	(select PackageNumber,dorisimporttime from import_data.daily_PackageDetail group by PackageNumber,dorisimporttime) dpd2 
on tmp.PackageNumber = dpd2.PackageNumber 
group by to_date( dorisimporttime) 


-- ��ֵ���
select 
	count(PayTime)/count(*)
from import_data.wt_packagedetail wp

-- ���ݴ�С
select count(*)
from import_data.wt_packagedetail wp

-- �в������
with res as (
select 
	case when rows_cnt/preceding_avg_cnt < 0.4 then '�����쳣' end as row_test
	,*
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(CreatedTime) stat_date, count(1) rows_cnt
		from import_data.wt_packagedetail wp 
		group by to_date(CreatedTime)
		) wt 
	) tmp 
order by stat_date desc 
) 

select * from res where row_test = '�����쳣'

-- ��֤����������ȱʧ���
with 
pd as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(CreatedTime) stat_date, count(1) rows_cnt
		from import_data.daily_PackageDetail 
		group by to_date(CreatedTime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, ro as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(RefundDate) stat_date, count(1) rows_cnt
		from import_data.daily_RefundOrders wp 
		group by to_date(RefundDate)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, po as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(ordertime) stat_date, count(1) rows_cnt
		from import_data.daily_PurchaseOrder dpo  
		group by to_date(ordertime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, pr as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(Scantime) stat_date, count(1) rows_cnt
		from import_data.daily_PurchaseRev dpr   
		group by to_date(ScanTime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, isc as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(CompleteTime) stat_date, count(1) rows_cnt
		from import_data.daily_InStockCheck disc    
		group by to_date(CompleteTime)
		) wt 
	) tmp 
order by stat_date desc 
)

, wi as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(CreatedTime) stat_date, count(1) rows_cnt
		from import_data.daily_WarehouseInventory dwi     
		group by to_date(CreatedTime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, em as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(Replytime) stat_date, count(1) rows_cnt
		from import_data.daily_Email de   
		group by to_date(Replytime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, od as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(paytime) stat_date, count(1) rows_cnt
		from import_data.daily_OrderDetails dod    
		group by to_date(paytime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, sf as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(deliverytime) stat_date, count(1) rows_cnt
		from import_data.daily_ShopFee dsf     
		group by to_date(deliverytime)
		) wt 
	) tmp 
-- order by stat_date desc 
)

, hd as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(GenerateDate) stat_date, count(1) rows_cnt
		from import_data.daily_HeadwayDelivery dhd     
		group by to_date(GenerateDate) 
		) wt 
	) tmp 
-- order by stat_date desc 
)

, ab as (
select 
	* ,round(rows_cnt/preceding_avg_cnt,2) row_test
from (
	select *,CEILING(avg(rows_cnt) over(order by stat_date rows between 7 preceding and current row)) preceding_avg_cnt
	from ( 
		select to_date(GenerateDate) stat_date, count(1) rows_cnt
		from import_data.daily_ABroadWarehouse daw      
		group by to_date(GenerateDate) 
		) wt 
	) tmp 
-- order by stat_date desc 
)

select po.stat_date ,po.row_test as po_t ,pd.row_test as pd_t ,ro.row_test as ro_t
	,em.row_test as em_t ,pr.row_test as pr_t ,isc.row_test as isc_t ,wi.row_test as wi_t
	,sf.row_test as sf_t ,ab.row_test as ab_t
from od 
left join po on od.stat_date =po.stat_date
left join pd on od.stat_date =pd.stat_date
left join ro on od.stat_date =ro.stat_date
left join em on od.stat_date =em.stat_date
left join pr on od.stat_date =pr.stat_date
left join isc on od.stat_date =isc.stat_date
left join wi on od.stat_date =wi.stat_date
left join sf on od.stat_date =sf.stat_date
left join hd on od.stat_date =hd.stat_date
left join ab on od.stat_date =ab.stat_date
order by stat_date desc 





-- ���̽������Ƿ�׷�ӳɹ�
select eaaspc.stat_date ,`���̽��������¼��` ,`��ϸ���¼��`
from (
	select to_date(CreationTime) stat_date
		,count(1) `���̽��������¼��`
	from import_data.erp_amazon_amazon_shop_performance_check_sync  
	group by to_date(CreationTime)
	) eaaspc
left join (
	select to_date(CreationTime) stat_date
		,count(1) `��ϸ���¼��`
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync  
	group by to_date(CreationTime)
	) eaaspcds 
	on eaaspc.stat_date = eaaspcds.stat_date
order by eaaspc.stat_date desc 