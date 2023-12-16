-- 应用于产品二次审查模块，添加审查清单，筛选每日新增的快百货终审30天达6单产品清单，(哪些新品品是昨日达到终审30天内6单的)

-- CREATE
ALTER VIEW dep_kbp_product_checklist_view AS
with
orders as ( -- 所有出单的新品
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
			and ms.Department ='快百货'
		join view_kbp_new_products epp on od.BoxSku =epp.BoxSKU
		left join wt_products wp on wp.sku = od.product_sku and wp.ProjectTeam='快百货'
		) tmp
	) tmp2
)

,over6 as ( -- 终审30天达6单清单
select spu
    ,count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end) 终审30天订单数
from orders od
group by spu  having count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end)  >=6
)

select distinct spu ,'昨日终审30天达6单SPU' PushRule ,pay_date as SixthPayDate
from
( select
    dense_rank() over (partition by sku order by date(PayTime)) pay_date_sort
    ,date(PayTime) pay_date
    ,a.spu
from orders a join over6 b on a.spu = b.spu ) t
where pay_date_sort = 6
  and pay_date = date_add(current_date(),interval -1 day)
  -- and pay_date >= date_add(current_date(),interval -17 day) --检查历史数据


