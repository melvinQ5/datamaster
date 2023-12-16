-- ���㹫˾�������۶� �ж�Ԫ��ҵ��ռ��

with 
t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.spu ,group_concat(eppea.Name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.spu
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku ,TotalGross ,ExchangeUSD ,salecount ,PayTime ,nodepathname 
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
where wo.IsDeleted = 0 
	and OrderStatus !='����' and TransactionType = '����' -- S1���۶�
	and ms.Department  = '��ٻ�'
)

,t_od_stat as (
select  
	sku 
	,round(sum(salecount),2) as KBH�ۼ�����
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
	,round(sum(case when left(paytime,7)='2023-04' then salecount end ),2) as KBH����2304
	,round(sum(case when left(paytime,7)='2023-05' then salecount end ),2) as KBH����2305
	,round(sum(case when left(paytime,7)='2023-06' then salecount end ),2) as KBH����2306
	,round(sum(case when left(paytime,7)='2023-07' then salecount end ),2) as KBH����2307
	,round(sum(case when left(paytime,7)='2023-08' then salecount end ),2) as KBH����2308
	,round(sum(case when left(paytime,7)='2023-09' then salecount end ),2) as KBH����2309
	,round(sum(case when left(paytime,7)='2023-10' then salecount end ),2) as KBH����2310
	,round(sum(case when left(paytime,7)='2023-11' then salecount end ),2) as KBH����2311
	,round(sum(case when left(paytime,7)='2023-12' then salecount end ),2) as KBH����2312
	
	,round(sum(TotalGross/ExchangeUSD),2) as KBH�ۼ����۶�
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
	,round(sum(case when left(paytime,7)='2023-04' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2304
	,round(sum(case when left(paytime,7)='2023-05' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2305
	,round(sum(case when left(paytime,7)='2023-06' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2306
	,round(sum(case when left(paytime,7)='2023-07' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2307
	,round(sum(case when left(paytime,7)='2023-08' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2308
	,round(sum(case when left(paytime,7)='2023-09' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2309
	,round(sum(case when left(paytime,7)='2023-10' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2310
	,round(sum(case when left(paytime,7)='2023-11' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2311
	,round(sum(case when left(paytime,7)='2023-12' then TotalGross/ExchangeUSD end ),2) as KBH���۶�2312
	
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��η�-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_��_���۶�22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '���Ԫ-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_Ԫ_���۶�22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��1��' then TotalGross/ExchangeUSD end ),2) as Ȫ1���۶�22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��2��' then TotalGross/ExchangeUSD end ),2) as Ȫ2���۶�22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��3��' then TotalGross/ExchangeUSD end ),2) as Ȫ3���۶�22��3��10��	
-- 
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��η�-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_��_���۶�2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '���Ԫ-�ɶ�������' then TotalGross/ExchangeUSD end ),2) as ��_Ԫ_���۶�2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��1��' then TotalGross/ExchangeUSD end ),2) as Ȫ1���۶�2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��2��' then TotalGross/ExchangeUSD end ),2) as Ȫ2���۶�2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��3��' then TotalGross/ExchangeUSD end ),2) as Ȫ3���۶�2303����
-- 	
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��η�-�ɶ�������' then salecount end ),2) as ��_��_����22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '���Ԫ-�ɶ�������' then salecount end ),2) as ��_Ԫ_����22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��1��' then salecount end ),2) as Ȫ1����22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��2��' then salecount end ),2) as Ȫ2����22��3��10��
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '��Ӫ��-Ȫ��3��' then salecount end ),2) as Ȫ3����22��3��10��	
-- 
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��η�-�ɶ�������' then salecount end ),2) as ��_��_����2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '���Ԫ-�ɶ�������' then salecount end ),2) as ��_Ԫ_����2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��1��' then salecount end ),2) as Ȫ1����2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��2��' then salecount end ),2) as Ȫ2����2303����
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '��Ӫ��-Ȫ��3��' then salecount end ),2) as Ȫ3����2303����

from od
group by sku 
)


select ele.sku  
-- 	,wp.CreationTime `���ʱ��`
	,date(date_add(wp.DevelopLastAuditTime , interval - 8 hour))   `��������`
	,year(date_add(wp.DevelopLastAuditTime , interval - 8 hour))   `�������`
	,wp.ProductName 
	,CASE WHEN ele_name regexp '�ļ�' THEN '�ļ�' end `��������`
	,CASE WHEN date_add(wp.DevelopLastAuditTime , interval - 8 hour) 
		>=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)  THEN '��Ʒ' else '��Ʒ'
	end `����Ʒ`
	,ele_name `Ԫ������`
	,wp.cat1
	,wp.cat2
	,wp.cat3
	,wp.cat4
	,wp.cat5
	,case when wp.ProductStatus =  0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
		end as  `��Ʒ״̬`
	,wp.TortType `��Ȩ״̬`
-- 	,��_��_���۶�22��3��10��
-- 	,��_Ԫ_���۶�22��3��10��
-- 	,Ȫ1���۶�22��3��10��
-- 	,Ȫ2���۶�22��3��10��
-- 	,Ȫ3���۶�22��3��10��	
-- 
-- 	,��_��_���۶�2303����
-- 	,��_Ԫ_���۶�2303����
-- 	,Ȫ1���۶�2303����
-- 	,Ȫ2���۶�2303����
-- 	,Ȫ3���۶�2303����
-- 	
-- 	,��_��_����22��3��10��
-- 	,��_Ԫ_����22��3��10��
-- 	,Ȫ1����22��3��10��
-- 	,Ȫ2����22��3��10��
-- 	,Ȫ3����22��3��10��	
-- 
-- 	,��_��_����2303����
-- 	,��_Ԫ_����2303����
-- 	,Ȫ1����2303����
-- 	,Ȫ2����2303����
-- 	,Ȫ3����2303����
	
	,KBH�ۼ�����
	,KBH�ۼ����۶� 
	
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
	,KBH����2304
	,KBH����2305
	,KBH����2306
	,KBH����2307
	,KBH����2308
	,KBH����2309
	,KBH����2310
	,KBH����2311
	,KBH����2312

	
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
	,KBH���۶�2304
	,KBH���۶�2305
	,KBH���۶�2306
	,KBH���۶�2307
	,KBH���۶�2308
	,KBH���۶�2309
	,KBH���۶�2310
	,KBH���۶�2311
	,KBH���۶�2312

	
from (
	select wp.sku,wp.spu  from wt_products wp
	join t_od_stat ta on ta.sku = wp.sku and wp.IsDeleted = 0 
	where KBH�ۼ����� >= 5 and date_add(DevelopLastAuditTime , interval - 8 hour) < '2023-01-01'
	union all 
	select sku,spu from wt_products wp
	where date_add(DevelopLastAuditTime , interval - 8 hour) >= '2023-01-01' and wp.IsDeleted = 0 
	) ele
left join t_od_stat ta on ele.sku =ta.sku 
left join t_elem on ele.spu =t_elem.spu
left join wt_products wp  on ele.sku =wp.sku  and wp.IsDeleted = 0 
-- left join erp_product_product_suppliers epps on epps.ProductId = wp.id
