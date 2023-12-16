/*
��æ��һ����2���£���Ӧ�̳�������ÿ�ҹ�Ӧ�̵Ĳɹ�SKU�������ɹ����������۶ȡǰ500�������Կ�
Ŀ�ģ���ͷ����Ӧ�̽�����Ʒ����
*/
-- import_data.Supplier_management source

WITH sup as ( -- ÿ��������Ӧ�̵Ĳɹ����������
SELECT
    `SupplierName`
    , `BoxSku` 
    , sum(`Price`) + sum(`Freight`) - sum(`DiscountedPrice`) AS sup_money -- `�ɹ����`
FROM
    import_data.PurchaseOrder pu
WHERE
    `WarehouseName` = '��ݸ��'
    AND
    (
        ( `ReportType` = '�±�' and Monday = '2022-09-01' and OrderTime > '2022-08-10') -- 0810-0831
		or( `ReportType` = '�±�' and Monday = '2022-10-01' ) -- 0901-0930        
        or( `ReportType` = '�ܱ�'  and Monday = '2022-10-03'and OrderTime > '2022-10-01') -- 1001-1010
    ) 
    AND ((`IsComplete` = '��')
        OR ((`IsComplete` = '��')
            AND (`InstockTime` != 0.0)))
GROUP BY
    `SupplierName`
    , `BoxSku`
)

, orders as ( -- ÿ��SKU��Ӧ���۶�
select 
	ops.BoxSku , sum(InCome) as income_full_site
from  import_data.OrderProfitSettle ops 
join 
	(select BoxSku from sup group by BoxSku) tmp
	on ops.BoxSku = tmp.BoxSku
where  ops.PayTime BETWEEN  '2022-08-10'and'2022-10-10'
group by ops.BoxSku 
)

, skus as ( -- ��ȡ��Ӧ��sku��
select SupplierName , count(distinct BoxSku) boxsku_cnt from sup group by SupplierName
)

, sup2 as ( -- 
select 
	sup.*
	, sum(orders.income_full_site) over ( partition by sup.SupplierName ) as income_full_site_total
	, skus.boxsku_cnt
	, sum(sup_money) over ( partition by sup.SupplierName ) as sup_money_total
from sup  
left join orders on orders.BoxSku = sup.BoxSku
left join skus on sup.SupplierName = skus.SupplierName
order by SupplierName
)

, ratio as ( -- ��ʷ����
	select
		usdratio -- ����
	from
		import_data.Basedata
	where
		firstday = '2022-09-01' -- 'StartDay'
		and reporttype = '�±�'
	limit 1
) 


select
	SupplierName as "�ɹ���Ӧ��"
	, boxsku_cnt as "��Ӧ�̲ɹ�SKU��"
	, sup_money_total as "��Ӧ�̲ɹ����usd"
	, BoxSku 
	, sup_money as "��sku�ɹ����usd"
	, �ɹ�sku������
	, �ɹ��������
-- 	, round(income_full_site_total/usdratio) as "��Ӧskuȫվ��2�����۶�"
	, ��skuȫվ���۶�Թ�Ӧ������
from 
	(
	select
	     *
	     , dense_rank() over( order by boxsku_cnt desc ) as "�ɹ�sku������"
	     , dense_rank() over( order by sup_money_total desc ) as "�ɹ��������"
	     , dense_rank() over( order by income_full_site_total desc ) as "��skuȫվ���۶�Թ�Ӧ������"
	from sup2
	) tmp , ratio
where �ɹ�������� < 501
order by �ɹ��������

