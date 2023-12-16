-- ��Ʒ��� ����������ӳ��ǰ�Ƿ��п��
select wp.BoxSku ,wp.ProductName  , dwi.AverageUnitPrice , dwi.TotalInventory 
from wt_products wp join 
(select * from import_data.daily_WarehouseInventory  where to_date(CreatedTime) = CURRENT_DATE()-1 ) dwi  on wp.BoxSku = dwi.BoxSku 
order by dwi.TotalInventory desc

/*  
�Աȱ���
ָ��������������ʼ����ʱ�䡢
*/

-- daily�� ���sku���仯
select to_date(CreatedTime) ,count(1) cnt
from import_data.daily_WarehouseInventory dwi 
group by to_date(CreatedTime)
order by to_date(CreatedTime) desc 

-- sku�仯�Ա� daily��ÿ��洢һ���汾; ���¶Ȳֿ��ÿ��ÿ�´洢һ���汾
select WEEKOFYEAR(CreatedTime) ,count(distinct BoxSku) cnt
from import_data.daily_WarehouseInventory dwi 
group by WEEKOFYEAR(CreatedTime)
order by WEEKOFYEAR(CreatedTime) desc 

SELECT '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as `�ܴ�`,'���в�Ʒ' as product_tupe
	, sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`, count(*) `�ڲ�sku��` FROM import_data.WarehouseInventory wi  
where WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�'


-- ��������
select count(1) from import_data.PackageDetail pd -- 1205858
select count(1) from import_data.daily_PackageDetail pd -- 62458 ��11��4�����ݿ�ʼ�ȶ�

-- ������
select weekly.gen_date, `�ո�������` , `�ܸ�������` from 
(select to_date(CreatedTime) gen_date, count(1) `�ո�������` from import_data.daily_PackageDetail group by to_date(CreatedTime) ) daily
left join 
(select to_date(CreatedTime) gen_date, count(1) `�ܸ�������`from import_data.PackageDetail group by to_date(CreatedTime)  ) weekly
on daily.gen_date = weekly.gen_date
where weekly.gen_date is not null 
order by gen_date desc

-- �ֶμ��������

