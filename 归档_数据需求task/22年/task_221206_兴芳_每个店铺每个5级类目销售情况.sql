-- 1份是店铺维度（分析每个店铺的类目数据），包含字段
-- “来源渠道  类目（大于等于5级按5级来，小于5级就是有到哪一级就提哪一级的数据）  SKU数  出单SKU数  链接总数  出单链接数  SKU动销率  链接动销率  业绩  毛利  利润率  单量  出单月份  退款”
--  两份数据都需要2022年，销售二部和销售三部的账号及相关链接数据


select a1.AccountCode `店铺_市场`, a1.NodePathNameFull `销售小组`, a1.categ_5 `类目(最多按5级统计)`,出单的SKU数,a3.在线SKU数, round(出单的SKU数/a3.在线SKU数,2) `SKU动销率`
	, 出单的链接数,a3.在线链接数, round(出单的链接数/a3.在线链接数,2) `链接动销率` , round(业绩,2)`业绩`, round(毛利,2)`毛利`, 利润率, 单量, 退款,a2.出单月份 
from
	(select s.AccountCode,s.NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5,
	count(distinct od.BoxSku ) '出单的SKU数',
	count(distinct concat(SellerSku,ShopIrobotId)) '出单的链接数',
	sum(InCome)/7.218 '业绩',sum(GrossProfit)/7.218 '毛利',
	round(sum(GrossProfit)/sum(InCome),4) '利润率',count(distinct PlatOrderNumber) '单量',sum(RefundPrice) '退款' 
	from import_data.OrderProfitSettle od
	inner join wt_products pp
	on od.BoxSku=pp.BoxSku
	inner join mysql_store s
	on od.ShopIrobotId=s.Code
	and s.Department in ('销售二部','销售三部')
	where PayTime>='2022-01-01'
	and PayTime<'2022-12-01'
	and od.OrderNumber not in
		(
		select OrderNumber from (
		SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
		where
		ShipmentStatus = '未发货' and OrderStatus = '作废'
		and PayTime >= '2022-01-01' and PayTime <'2022-12-01'
		group by OrderNumber
		) a
		where alltype = '付款'
		)
	group by s.AccountCode
		,s.NodePathNameFull
		,concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) 
	) a1

left join 
(
	select t.AccountCode,t.NodePathNameFull,categ_5,group_concat(concat(t.出单月份,'')) `出单月份` 
	from
		(select a.AccountCode,a.NodePathNameFull,a.出单月份, categ_5
		from
			(select s.AccountCode,s.NodePathNameFull
				,concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5
				, month(PayTime) '出单月份'
			from OrderProfitSettle od
			inner join wt_products pp
			on od.BoxSku=pp.BoxSku
			inner join mysql_store s
			on od.ShopIrobotId=s.Code
			and s.Department in ('销售二部','销售三部')
			where PayTime>='2022-01-01'
			and PayTime<'2022-12-01'
			and od.OrderNumber not in
				(
				select OrderNumber from (
				SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
				where
				ShipmentStatus = '未发货' and OrderStatus = '作废'
				and PayTime >= '2022-01-01' and PayTime <'2022-12-01'
				group by OrderNumber
				) a
			where alltype = '付款'
			)) a
		group by a.AccountCode ,a.NodePathNameFull ,categ_5 ,a.出单月份
		order by a.AccountCode ,a.NodePathNameFull ,categ_5 ,a.出单月份 
		) t
	group by t.AccountCode,t.NodePathNameFull,categ_5
) a2
on a1.AccountCode=a2.AccountCode and a1.categ_5 =a2.categ_5 and a1.NodePathNameFull=a2.NodePathNameFull

left join
(
/*SKU数、链接总数*/
select AccountCode,NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5,
	count(distinct al.SKU) '在线SKU数',count(distinct concat(SellerSku,ShopCode)) '在线链接数' 
from wt_products pp
inner join erp_amazon_amazon_listing al
on pp.Sku=al.SKU and al.ListingStatus = 1
and al.SKU<>''
inner join mysql_store s
on al.ShopCode=s.Code and s.ShopStatus ='正常'
and Department in ('销售二部','销售三部')
group by AccountCode,NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) 
) a3
on a1.AccountCode=a3.AccountCode and a1.categ_5 =a3.categ_5 and a1.NodePathNameFull=a3.NodePathNameFull

