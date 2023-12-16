1 ���� WITH �ṹ�� UNION ���ܷ�����ʱ���ڣ�ֻ�ܷ������ղ�ѯ�����
2 ָ�����ڵ��µĵ�һ��   DATE_ADD('${StartDay}',interval -day('${StartDay}')+1 day)
3 ȡ�Ӵ� SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopCode

-- �ָ�
split(CategoryPathByChineseName,'>')[1] as categ1
-- ��Ʒ״̬
,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
		    
		,case when ProductStatus = 0 then '����'
		when ProductStatus = 2 then 'ͣ��'
		when ProductStatus = 3 then 'ͣ��'
		when ProductStatus = 4 then '��ʱȱ��'
		when ProductStatus = 5 then '���'
		end as ProductStatusName

-- �˿�ԭ��ö��
SELECT RefundReason1 ,RefundReason2 ,count(1)
FROM import_data.daily_RefundOrders ro
group by RefundReason1 ,RefundReason2 

SELECT RefundReason1 ,count(1)
FROM import_data.daily_RefundOrders ro
group by RefundReason1 

-- ��������
where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 

-- �������۶��Ҫ�޵�δ�������������� ��ֻ��һ�������¼�ģ���Ϊ�����ⲿ�ֻ����˿������
OrderNumber not in 
			(
			select OrderNumber from (
			SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
			where
			ShipmentStatus = 'δ����' and OrderStatus = '����'
			and PayTime >=date_add('${next_frist_day}',interval -7 day) and PayTime < '${next_frist_day}'
			group by OrderNumber) a
			where alltype = '����')


, map_categ as ( -- �¾�һ����Ŀƥ���ϵ
select
     eppc.categ1 as categ_old
     , nsm.BoxSku as categ_new
     , epp.BoxSKU
from
     (
     select
          split(CategoryPathByChineseName,'>')[1] as categ1
          , Id
     from import_data.erp_product_product_category
     where IsDeleted = 0
     ) eppc
join import_data.erp_product_products epp on eppc.Id =  epp.ProductCategoryId 
left join new_sku_map nsm on eppc.categ1 = nsm.Sku
groupby eppc.categ1 , categ_new , epp.BoxSKU
)
