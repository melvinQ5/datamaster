-- ���㹫˾�������۶� �ж�Ԫ��ҵ��ռ��
-- ������SKU ��2203-2210��2303-2304���¼��ۼ����� ��bySKUά��

with 
ele as ( 
select eppaea.sku 
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '������' 
group by eppaea.sku 
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku ,TotalGross ,ExchangeUSD ,salecount ,PayTime ,nodepathname 
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
join ele on wo.Product_Sku = ele.sku 
where wo.IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' 
	and OrderStatus !='����' and TransactionType = '����'
	and ms.Department  = '��ٻ�'
)

,t_od_stat as (
select  
	sku 
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-11-01' then salecount end ),2) as KBH����22��3��10��
	,round(sum(case when left(paytime,7)='2022-01' then salecount end ),2) as KBH����2201
	,round(sum(case when left(paytime,7)='2022-02' then salecount end ),2) as KBH����2202
	,round(sum(case when left(paytime,7)='2022-03' then salecount end ),2) as KBH����2203
	,round(sum(case when left(paytime,7)='2022-04' then salecount end ),2) as KBH����2204
	,round(sum(case when left(paytime,7)='2022-05' then salecount end ),2) as KBH����2205
	,round(sum(case when left(paytime,7)='2022-06' then salecount end ),2) as KBH����2206
	,round(sum(case when left(paytime,7)='2022-07' then salecount end ),2) as KBH����2207
	,round(sum(case when left(paytime,7)='2022-08' then salecount end ),2) as KBH����2208
	,round(sum(case when left(paytime,7)='2022-09' then salecount end ),2) as KBH����2209
	,round(sum(case when left(paytime,7)='2022-10' then salecount end ),2) as KBH����2210
	,round(sum(case when left(paytime,7)='2022-11' then salecount end ),2) as KBH����2211
	,round(sum(case when left(paytime,7)='2022-12' then salecount end ),2) as KBH����2212
	,round(sum(case when left(paytime,7)='2023-01' then salecount end ),2) as KBH����2301
	,round(sum(case when left(paytime,7)='2023-02' then salecount end ),2) as KBH����2302
	,round(sum(case when left(paytime,7)='2023-03' then salecount end ),2) as KBH����2303
	,round(sum(case when left(paytime,7)='2023-04' then salecount end ),2) as KBH����230401����
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-11-01' then TotalGross/ExchangeUSD end ),2) as KBH���۶�22��3��10��
	,round(sum(case when left(paytime,7)='2022-01' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2201
	,round(sum(case when left(paytime,7)='2022-02' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2202
	,round(sum(case when left(paytime,7)='2022-03' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2203
	,round(sum(case when left(paytime,7)='2022-04' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2204
	,round(sum(case when left(paytime,7)='2022-05' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2205
	,round(sum(case when left(paytime,7)='2022-06' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2206
	,round(sum(case when left(paytime,7)='2022-07' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2207
	,round(sum(case when left(paytime,7)='2022-08' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2208
	,round(sum(case when left(paytime,7)='2022-09' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2209
	,round(sum(case when left(paytime,7)='2022-10' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2210
	,round(sum(case when left(paytime,7)='2022-11' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2211
	,round(sum(case when left(paytime,7)='2022-12' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2212
	,round(sum(case when left(paytime,7)='2023-01' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2301
	,round(sum(case when left(paytime,7)='2023-02' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2302
	,round(sum(case when left(paytime,7)='2023-03' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2303
	,round(sum(case when left(paytime,7)='2023-04' then TotalGross/ExchangeUSD end ),2) as KBH���۶�230401����
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��η�-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_��_���۶�22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '���Ԫ-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_Ԫ_���۶�22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��1��' then TotalGross/ExchangeUSD end ),2) as Ȫ1���۶�22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��2��' then TotalGross/ExchangeUSD end ),2) as Ȫ2���۶�22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��3��' then TotalGross/ExchangeUSD end ),2) as Ȫ3���۶�22��3��10��	

	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��η�-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_��_���۶�2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '���Ԫ-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_Ԫ_���۶�2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��1��' then TotalGross/ExchangeUSD end ),2) as Ȫ1���۶�2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��2��' then TotalGross/ExchangeUSD end ),2) as Ȫ2���۶�2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��3��' then TotalGross/ExchangeUSD end ),2) as Ȫ3���۶�2303����
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��η�-�ɶ�������' then salecount end ),2) as ��_��_����22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '���Ԫ-�ɶ�������' then salecount end ),2) as ��_Ԫ_����22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��1��' then salecount end ),2) as Ȫ1����22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��2��' then salecount end ),2) as Ȫ2����22��3��10��
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��3��' then salecount end ),2) as Ȫ3����22��3��10��	

	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��η�-�ɶ�������' then salecount end ),2) as ��_��_����2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '���Ԫ-�ɶ�������' then salecount end ),2) as ��_Ԫ_����2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��1��' then salecount end ),2) as Ȫ1����2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��2��' then salecount end ),2) as Ȫ2����2303����
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��3��' then salecount end ),2) as Ȫ3����2303����

from od
group by sku 
)

select ele.sku  
	,wp.ProductName
	,wp2.cat1
	,wp2.cat2
	,wp2.cat3
	,wp2.cat4
	,wp2.cat5
	,KBH����22��3��10��
	,case when wp.ProductStatus =  0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
		end as  `��Ʒ״̬`
	,wp2.TortType `��Ȩ״̬`
	,��_��_���۶�22��3��10��
	,��_Ԫ_���۶�22��3��10��
	,Ȫ1���۶�22��3��10��
	,Ȫ2���۶�22��3��10��
	,Ȫ3���۶�22��3��10��	

	,��_��_���۶�2303����
	,��_Ԫ_���۶�2303����
	,Ȫ1���۶�2303����
	,Ȫ2���۶�2303����
	,Ȫ3���۶�2303����
	
	,��_��_����22��3��10��
	,��_Ԫ_����22��3��10��
	,Ȫ1����22��3��10��
	,Ȫ2����22��3��10��
	,Ȫ3����22��3��10��	

	,��_��_����2303����
	,��_Ԫ_����2303����
	,Ȫ1����2303����
	,Ȫ2����2303����
	,Ȫ3����2303����
	
	
	,KBH����2201
	,KBH����2202
	,KBH����2203
	,KBH����2204
	,KBH����2205
	,KBH����2206
	,KBH����2207
	,KBH����2208
	,KBH����2209
	,KBH����2210
	,KBH����2211
	,KBH����2212
	,KBH����2301
	,KBH����2302
	,KBH����2303
	,KBH����230401����
	
	,KBH���۶�2201
	,KBH���۶�2202
	,KBH���۶�2203
	,KBH���۶�2204
	,KBH���۶�2205
	,KBH���۶�2206
	,KBH���۶�2207
	,KBH���۶�2208
	,KBH���۶�2209
	,KBH���۶�2210
	,KBH���۶�2211
	,KBH���۶�2212
	,KBH���۶�2301
	,KBH���۶�2302
	,KBH���۶�2303
	,KBH���۶�230401����

	,wp.CreationTime `���ʱ��`
	,wp.DevelopLastAuditTime  `����ʱ��`
	,SupplierName `��Ӧ��`
	,PurchaseLink `�ɹ�����`
	,PurchasePrice `�ɹ���`
	,NetWeight `����`
	,GrossWeight `ë��`
	,concat(ProductLong,'x',ProductWidth,'x',ProductHeight) `��Ʒ�����`
	,concat(PackageLong,'x',PackageWidth,'x',PackageHeight) `��װ�����`
from ele 
left join t_od_stat ta on ele.sku =ta.sku 
left join erp_product_products wp on ele.sku =wp.sku and IsMatrix = 0 and IsDeleted = 0 
left join wt_products wp2  on ele.sku =wp2.sku  and wp2.IsDeleted = 0 
left join erp_product_product_suppliers epps on epps.ProductId = wp.id
order by KBH����22��3��10�� desc 
