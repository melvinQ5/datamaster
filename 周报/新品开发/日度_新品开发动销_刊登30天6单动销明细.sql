with
 orders as (
select * from (
	select tmp.*
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- ��������ʱ��������翯��ʱ���������,�����տ���ʱ��Ϊ���󣬱��⿯�Ƕ�����С������������
	from (
		select od.PlatOrderNumber
			, od.PayTime , ms.Department ,ms.NodePathName
			,  epp.SPU, epp.SKU, epp.BoxSku, od.shopcode as ShopIrobotId, od.SellerSku
			, wl.min_pubtime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		    ,SaleCount
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�' and PayTime >= '2023-01-01'
		join view_kbp_new_products epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl join mysql_store ms on wl.ShopCode = ms.Code group by BoxSku )  wl on  wl.BoxSku = od.boxsku
		) tmp
	) tmp2
)


,od_stat as (
select sku
    ,count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) ����30�충����
    ,count(distinct  PlatOrderNumber ) �ۼƶ�����
    ,sum(salecount ) �ۼ�����
    ,round( sum(AfterTax_TotalGross) ) �ۼ����۶�
from orders od
group by sku  having count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end)  >=6
)

select
    spu
    ,os.sku
    ,BoxSku
    ,ProductName ��Ʒ����
    ,DevelopLastAuditUserName ������Ա
    ,date(DevelopLastAuditTime) ��������
    ,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ��Ʒ״̬
    ,����30�충����
    ,�ۼƶ����� ,�ۼ����� ,�ۼ����۶�
from od_stat os
left join wt_products wp on wp.sku = os.sku and wp.ProjectTeam = '��ٻ�'
order by �������� desc