-- GMתPM  ��ƷGMתPMsku������ԴΪ���� �ҿ�������ʱ��10/31-11/06 �ҷ�ɾ����sku��

select '���в���' as department,count(*) as sku_new_r_count from import_data.erp_product_products
where SkuSource = 2
and DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07' and IsDeleted = 0 and IsMatrix = 0


-- ���򿪷�  PM��Ʒ����sku������ԴΪ���� �ҿ�������ʱ��10/31-11/06 �ҷ�ɾ����sku��

select '���в���' as department,count(*) as sku_new_count from import_data.erp_product_products
where SkuSource = 1
and DevelopLastAuditTime >= '2022-10-01' and DevelopLastAuditTime < '2022-11-01' and IsDeleted = 0 and IsMatrix = 0

-- ���򿪷�SKU��

select '���в���' as department,count(*) as sku_new_rc_count from import_data.erp_product_products
where SkuSource = 2 and DevelopLastAuditTime is null
and CreationTime >= 'StartDay' and CreationTime < 'EndDay' and IsDeleted = 0 and IsMatrix = 0

-- ��Ʒ�����

select '���в���' department, count(*) product_total_sku_count_celebration from import_data.Celi
where ProductStatus <> 2 and  DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07'


-- ԰��sku������
select '���в���' department, count(*) product_total_sku_count_park from import_data.Parts
where ProductStatus <> 2 and  DevelopLastAuditTime >= '2022-10-31' and DevelopLastAuditTime < '2022-11-07'