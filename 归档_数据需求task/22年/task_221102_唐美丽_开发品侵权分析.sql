/*
Ŀ�ģ�
	1 ��Ҫ������ά���Ǳ�Ƶ�ά�ȣ�����Щ�����Ĳ�Ʒ �յ�������Ͷ�߱Ƚ϶�
	2 �ܽ��Ƶ����Ȩ���ͣ���������Ʒ��Ա�������ڵ����߹涨��ѧϰ����
ָ�꣺Ͷ����
ά�ȣ�
	����
���������������Ƽ�أ�
��Щ�����յ�����Ȩ֪ͨ���

��Ʒ/
Ͷ�߹��򣬴���Աά�ȣ�ÿ��������Ա�յ�Ͷ������

����Դ��import_data.erp_amazon_amazon_cross_tort_feed_back eaactfb 
*/

select 
	case when TortSource=1 then 'ҵ��֪ͨ' when TortSource=2 then '�˻�״��' end as `��Դ`
	, case when TortType=0 then 'Υ��֪ͨ' when TortType=1 then '�����ַ�֪ʶ��Ȩ'
	when TortType=2 then '֪ʶ��ȨͶ��' when TortType=3 then '����ȨΥ��֪ͨ' end as `��Ȩ����`
	, Reason as `ԭ��`
	, case when HandlingOpinion= 1 then '����Ȩ' when HandlingOpinion= 0 then 'δ����'
		else '���Ŵ���' end `������` -- 	0:δ����,1:����Ȩ,3:�޸���Ȩ,4:���۴���,5:�����޸�,6:�༭�޸�,7:��Ʒ����
	, DATE_FORMAT(to_date(eaactfb.SubmitTime),'%Y/%m/%d') `����`
	, PlatformAccountSiteCode as `���̼���`
	, Site as `վ��`
	, IrobotName as `��������`
	, eaactfb.WhatImpacted
	, ASIN 
	, eaactfb.TakeAction as `��ȡ����`
	, epp.BoxSKU 
	, eaactfb.Sku 
	, epp.ProductName as `��Ʒ������`
	, eppc.CategoryPathByChineseName as `��Ʒ����`
	, case when epp.SkuSource=1 then '����' when epp.SkuSource=2 then '����' 
		when epp.SkuSource=3 then '�ɼ�' end  `sku��Դ`
	, epps.`�����`
	, epp.CreationTime `���ʱ��`
	, epp.DevelopUserName `������Ա`
	, epp.DevelopLastAuditTime `��������ʱ��`	
	, epps.`��Ȩ������`
	, epps.`��Ȩ����ʱ��`
	, epps.`��Ȩ������`
	, epps.`��Ȩ����ʱ��`
from import_data.erp_amazon_amazon_cross_tort_feed_back eaactfb 
left join import_data.erp_product_products epp 
	on eaactfb.ProductId = epp.Id and epp.BoxSKU is not null 
left join import_data.erp_product_product_category eppc on eppc.Id =  epp.ProductCategoryId
left join 
	(select ProductId
		, max (case when DevelopStage = 10 then AuditTime end) `���ʱ��`
		, max(case when DevelopStage = 10 then HandleUserName end)  `�����`
		, max (case when DevelopStage = 20 then AuditTime end) `��Ȩ����ʱ��`
		, max(case when DevelopStage = 20 then AuditUserName end) `��Ȩ������` 
		, max(case when DevelopStage = 60 then AuditTime end) `��Ȩ����ʱ��`
		, max(case when DevelopStage = 60 then AuditUserName end) `��Ȩ������`
	from import_data.erp_product_product_statuses group by ProductId
	) epps on epps.ProductId = eaactfb.ProductId