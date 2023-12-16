-- 产品宽表 关联库存表，反映当前是否有库存
select wp.BoxSku ,wp.ProductName  , dwi.AverageUnitPrice , dwi.TotalInventory 
from wt_products wp join 
(select * from import_data.daily_WarehouseInventory  where to_date(CreatedTime) = CURRENT_DATE()-1 ) dwi  on wp.BoxSku = dwi.BoxSku 
order by dwi.TotalInventory desc

/*  
对比报告
指标有数据量、起始更新时间、
*/

-- daily表 库存sku数变化
select to_date(CreatedTime) ,count(1) cnt
from import_data.daily_WarehouseInventory dwi 
group by to_date(CreatedTime)
order by to_date(CreatedTime) desc 

-- sku变化对比 daily表每天存储一个版本; 周月度仓库表每周每月存储一个版本
select WEEKOFYEAR(CreatedTime) ,count(distinct BoxSku) cnt
from import_data.daily_WarehouseInventory dwi 
group by WEEKOFYEAR(CreatedTime)
order by WEEKOFYEAR(CreatedTime) desc 

SELECT '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as `周次`,'所有产品' as product_tupe
	, sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`, count(*) `在仓sku数` FROM import_data.WarehouseInventory wi  
where WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报'


-- 包裹表检查
select count(1) from import_data.PackageDetail pd -- 1205858
select count(1) from import_data.daily_PackageDetail pd -- 62458 从11月4日数据开始稳定

-- 表行数
select weekly.gen_date, `日更表行数` , `周更表行数` from 
(select to_date(CreatedTime) gen_date, count(1) `日更表行数` from import_data.daily_PackageDetail group by to_date(CreatedTime) ) daily
left join 
(select to_date(CreatedTime) gen_date, count(1) `周更表行数`from import_data.PackageDetail group by to_date(CreatedTime)  ) weekly
on daily.gen_date = weekly.gen_date
where weekly.gen_date is not null 
order by gen_date desc

-- 字段检查与增补

