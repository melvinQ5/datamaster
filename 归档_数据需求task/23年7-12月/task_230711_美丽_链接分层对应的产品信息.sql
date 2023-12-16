
with lst as (
select  dkll .*
from dep_kbh_listing_level dkll 
where year(dkll.FirstDay)= 2023 and right(dkll.FirstDay,3) = '-01' 
	and dkll.Department = '��ٻ��ɶ�' 
) 

, od as  ( -- site,asin,spu,boxsku �ۺ�
select * from (
select ROW_NUMBER () over ( partition by site,asin, spu order by orders desc ) as sort ,ta.*
from (
	select wo.site,asin, Product_SPU as spu ,ms.Code ,ms.SellUserName  ,count(distinct PlatOrderNumber) orders -- ������
	from import_data.wt_orderdetails wo
	join mysql_store ms on wo.shopcode=ms.Code 
	where PayTime >='2023-01-01' and PayTime< '2023-07-01' and wo.IsDeleted=0
		and TransactionType <> '����'  and asin <>'' and ms.department regexp '��' and  NodePathName regexp '�ɶ�'
	group by wo.site,asin, spu ,ms.Code ,ms.SellUserName  
	) ta
) tb 
where tb.sort = 1 
)

, res as (
select lst.* ,wp.sku ,wp.ProductName ,date(wp.DevelopLastAuditTime) ����ʱ�� ,od.code �ϰ������ӵ���top1���̼���, od.SellUserName ��ѡҵ��Ա
from lst 
left join wt_products wp on lst.spu = wp.spu 
left join od on od.asin = lst.asin and od.site =lst.site and od.spu =lst.spu 
)

-- select count(1) from res 
select * from res 
	