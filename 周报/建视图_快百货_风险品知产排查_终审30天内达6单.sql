-- Ӧ���ڲ�Ʒ�������ģ�飬�������嵥��ɸѡÿ�������Ŀ�ٻ�����30���6����Ʒ�嵥��(��Щ��ƷƷ�����մﵽ����30����6����)

-- CREATE
ALTER VIEW dep_kbp_product_checklist_view AS
with
orders as ( -- ���г�������Ʒ
select * from (
	select tmp.*
 		, timestampdiff(SECOND, DevelopLastAuditTime ,PayTime)/86400 as ord_days_since_dev
	from (
		select od.PlatOrderNumber
			, od.PayTime , ms.Department ,ms.NodePathName
			,  epp.SPU, epp.SKU, epp.BoxSku, od.shopcode as ShopIrobotId, od.SellerSku
		    ,wp.DevelopLastAuditTime
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='��ٻ�'
		join view_kbp_new_products epp on od.BoxSku =epp.BoxSKU
		left join wt_products wp on wp.sku = od.product_sku and wp.ProjectTeam='��ٻ�'
		) tmp
	) tmp2
)

,over6 as ( -- ����30���6���嵥
select spu
    ,count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end) ����30�충����
from orders od
group by spu  having count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end)  >=6
)

select distinct spu ,'��������30���6��SPU' PushRule ,pay_date as SixthPayDate
from
( select
    dense_rank() over (partition by sku order by date(PayTime)) pay_date_sort
    ,date(PayTime) pay_date
    ,a.spu
from orders a join over6 b on a.spu = b.spu ) t
where pay_date_sort = 6
  and pay_date = date_add(current_date(),interval -1 day)
  -- and pay_date >= date_add(current_date(),interval -17 day) --�����ʷ����


