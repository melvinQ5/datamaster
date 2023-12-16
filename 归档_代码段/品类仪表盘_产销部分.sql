select
	t.category,
	t.department,
	t.ReportType,
	t.周次,
	t.product_tupe,
	round(a2.当周销售额-ifnull(a3.退款总额, 0), 2) '销售额' ,
	round(a2.当周利润额-ifnull(a5.广告花费, 0)-ifnull(a3.退款总额, 0), 2) '利润额',
	round(((当周利润额-ifnull(广告花费, 0)-ifnull(退款总额, 0))/(当周销售额-ifnull(退款总额, 0)))* 100, 2) as '利润率',
	订单数,
	round((当周销售额-ifnull(退款总额, 0))/ 订单数, 2) '客单价',
	当周销售额,
	当周利润额,
	当周利润率,
	退款总额,
	round((退款总额 /(ifnull(退款总额, 0)+(当周销售额-ifnull(退款总额, 0))))* 100, 2) as '退款率',
	发货退款金额,
	round((发货退款金额 /(ifnull(退款总额, 0)+(当周销售额-ifnull(退款总额, 0))))* 100, 2) as '已发货退款率',
	无理由退款金额,
	round((无理由退款金额 /(ifnull(退款总额, 0)+(当周销售额-ifnull(退款总额, 0))))* 100, 2) as '无理由退款率',
	总SPU数,
	在线SPU数,
	新增SPU数,
	转为重点产品SPU数,
	转为重点产品贡献销售额,
	当周出单SPU数,
	`4周出单SPU数`,
	round((当周销售额-ifnull(退款总额, 0))/ 当周出单SPU数, 2) '总-单SPU贡献业绩',
	round(目前在线链接数 / 在线SPU数, 2) '平均SPU在线链接数',
	round((当周出单SPU数 / 在线SPU数)* 100, 2) 'SPU当周动销率',
	round((`4周出单SPU数` / 在线SPU数)* 100, 2) 'SPU4周动销率',
	总SKU数,
	在线SKU数,
	新增SKU数,
	当周出单SKU数,
	`4周出单SKU数`,
	round((当周销售额-ifnull(退款总额, 0))/ 当周出单SKU数, 2) '总-单SKU贡献业绩',
	round(目前在线链接数 / 在线SKU数, 2) '平均SKU在线链接数',
	round((当周出单SPU数 / 在线SKU数)* 100, 2) 'SKU当周动销率',
	round((`4周出单SPU数` / 在线SKU数)* 100, 2) 'SKU4周动销率',
	目前在线链接数,
	当周刊登在线链接数,
	当周出单链接数,
	`4周出单链接数`,
	round((当周出单链接数 / 目前在线链接数)* 100, 2) '链接当周动销率',
	round((`4周出单链接数` / 目前在线链接数)* 100, 2) '链接4周动销率',
	访客数,
	访客销量,
	被访问链接数,
	访客转化率,
	曝光量,
	点击量,
	广告点击率,
	广告订单量,
	广告转化率,
	广告销售额,
	广告花费,
	round((广告花费 /(当周销售额-ifnull(退款总额, 0)))* 100, 2) '广告花费率',
	round((广告销售额 /(当周销售额-ifnull(退款总额, 0)))* 100, 2) '广告业绩占比',
	广告Acost,
	广告cpc,
	有曝光的广告投放,
	有出单的广告投放,
	ifnull(访客数, 0)-ifnull(点击量, 0) as '自然流量访客数',
	ifnull(访客销量, 0)-ifnull(广告订单量, 0) as '自然流量访客销量',
	round(((ifnull(访客销量, 0)-ifnull(广告订单量, 0))/(ifnull(访客数, 0)-ifnull(点击量, 0)))* 100, 2) '自然流量访客转化率'
from
	(
	select
		'家居生活' as category,
		concat(Department, '-', NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'家居生活' as category,
		Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'PM' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		concat(Department, '-', NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'家居生活' as category,
		Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'PM' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		concat(Department, '-', NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'其他产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'家居生活' as category,
		Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'其他产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'PM' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'其他产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'其他产品' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		concat(Department, '-', NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'家居生活' as category,
		Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'PM' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
union
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	group by
		Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
	with ca as (
	select
		go.SKU,
		go.SPU,
		go.BoxSKU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		ListingStatus,
		ShopStatus,
		ShopCode,
		SellerSKU,
		PublicationDate
	FROM
		erp_amazon_amazon_listing al /*实际为销售小组在线SPU数*/
	inner join life_category as go
on
		go.SKU = al.SKU
		and al.SKU <> ''
		and go.ProductStatus <> 2
		and go.DevelopLastAuditTime<'2022-12-26'
	inner join mysql_store s
on
		s.code = al.ShopCode
		and al.PublicationDate < '2022-12-26'
		and s.Department in ('销售一部', '销售二部', '销售三部', '销售四部'))
/*新品*/
	/*所有部门小组新品在线数据*/
	select
		'家居生活' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		count(distinct case when 1 = 1 then SPU end) '总SPU数',
		count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SPU end)'在线SPU数',
		count(distinct case when 1 = 1 then SKU end) '总SKU数',
		count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SKU end)'在线SKU数',
		count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
		count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
	from
		ca
	where
		ca.Department in ('销售一部', '销售二部', '销售三部')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*各部门新品在线数据*/
			select
				'家居生活' as category,
				ca.Department,
				'周报' as ReportType,
				weekofyear('2022-12-26') as '周次',
				'新品' as product_tupe,
				count(distinct case when 1 = 1 then SPU end) '总SPU数',
				count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SPU end)'在线SPU数',
				count(distinct case when 1 = 1 then SKU end) '总SKU数',
				count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SKU end)'在线SKU数',
				count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
				count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
					and ca.Department in ('销售一部', '销售二部', '销售三部')
				group by
					ca.Department
			union
				select
					'家居生活' as category,
					'销售四部' as Department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'新品' as product_tupe,
					count(distinct case when 1 = 1 then SPU end) '总SPU数',
					count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SPU end)'在线SPU数',
					count(distinct case when 1 = 1 then SKU end) '总SKU数',
					count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SKU end)'在线SKU数',
					count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
					count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department = '销售四部'
				union
/*PM部门新品在线数据*/
					select
						'家居生活' as category,
						'PM' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'新品' as product_tupe,
						count(distinct case when 1 = 1 then SPU end) '总SPU数',
						count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SPU end)'在线SPU数',
						count(distinct case when 1 = 1 then SKU end) '总SKU数',
						count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SKU end)'在线SKU数',
						count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
						count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
							and Department in ('销售二部', '销售三部')
					union
/*所有部门新品在线数据*/
						select
							'家居生活' as category,
							'所有部门' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'新品' as product_tupe,
							count(distinct case when 1 = 1 then SPU end) '总SPU数',
							count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SPU end)'在线SPU数',
							count(distinct case when 1 = 1 then SKU end) '总SKU数',
							count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then SKU end)'在线SKU数',
							count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
							count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
						from
							ca
						where
							DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
								and DevelopLastAuditTime<'2022-12-26'
						union
/*重点产品*/
							/*各部门小组重点产品在线数据*/
							select
								'家居生活' as category,
								concat(ca.Department, '-', ca.NodePathName) as department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'重点产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('销售一部', '销售二部', '销售三部')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*各部门重点产品在线数据*/
							select
								'家居生活' as category,
								ca.Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'重点产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('销售一部', '销售二部', '销售三部')
							group by
								ca.Department
						union
							select
								'家居生活' as category,
								'销售四部' as Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'重点产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department = '销售四部'
						union
/*PM部门重点产品在线数据*/
							select
								'家居生活' as category,
								'PM' as Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'重点产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('销售二部', '销售三部')
						union
/*所有部门重点产品在线数据*/
							select
								'家居生活' as category,
								'所有部门' as Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'重点产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
						union
/*其他产品*/
							/*所有部门小组其他产品在线数据*/
							select
								'家居生活' as category,
								concat(ca.Department, '-', ca.NodePathName) as department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'其他产品' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
								count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
								count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
									and ca.Department in ('销售一部', '销售二部', '销售三部')
								group by
									concat(ca.Department, '-', ca.NodePathName)
							union
/*各部门其他产品在线数据*/
								select
									'家居生活' as category,
									ca.Department,
									'周报' as ReportType,
									weekofyear('2022-12-26') as '周次',
									'其他产品' as product_tupe,
									count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
									count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
									count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
									count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
									count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
									count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and ca.Department in ('销售一部', '销售二部', '销售三部')
									group by
										ca.Department
								union
									select
										'家居生活' as category,
										'销售四部' as Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'其他产品' as product_tupe,
										count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
										count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
										count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
										count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
										count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
										count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
											and ca.Department = '销售四部'
									union
/*PM部门其他产品在线数据*/
										select
											'家居生活' as category,
											'PM' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'其他产品' as product_tupe,
											count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
											count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
											count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
											count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
											count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
											count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
										from
											ca
										where
											ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
												and ca.BoxSKU not in (
												select
													BoxSKU
												from
													lead_product)
												and ca.Department in ('销售二部', '销售三部')
										union
/*所有部门其他产品在线数据*/
											select
												'家居生活' as category,
												'所有部门' as Department,
												'周报' as ReportType,
												weekofyear('2022-12-26') as '周次',
												'其他产品' as product_tupe,
												count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
												count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
												count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
												count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
												count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
												count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
											from
												ca
											where
												ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
													and ca.BoxSKU not in (
													select
														BoxSKU
													from
														lead_product)
											union
/*所有产品*/
												/*各部门小组所有产品在线数据*/
												select
													'家居生活' as category,
													concat(ca.Department, '-', ca.NodePathName) as department,
													'周报' as ReportType,
													weekofyear('2022-12-26') as '周次',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
													count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
												from
													ca
												where
													Department in ('销售一部', '销售二部', '销售三部')
												group by
													concat(ca.Department, '-', ca.NodePathName)
											union
/*各部门所有产品在线数据*/
												select
													'家居生活' as category,
													ca.Department,
													'周报' as ReportType,
													weekofyear('2022-12-26') as '周次',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
													count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
												from
													ca
												where
													Department in ('销售一部', '销售二部', '销售三部')
												group by
													ca.Department
											union
												select
													'家居生活' as category,
													'销售四部' as Department,
													'周报' as ReportType,
													weekofyear('2022-12-26') as '周次',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
													count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
												from
													ca
												where
													Department = '销售四部'
											union
/*PM部门所有产品在线数据*/
												select
													'家居生活' as category,
													'PM' as Department,
													'周报' as ReportType,
													weekofyear('2022-12-26') as '周次',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
													count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
												from
													ca
												where
													Department in ('销售二部', '销售三部')
											union
/*所有部门所有产品在线数据*/
												select
													'家居生活' as category,
													'所有部门' as Department,
													'周报' as ReportType,
													weekofyear('2022-12-26') as '周次',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '总SPU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SPU end)'在线SPU数',
													count(distinct case when 1 = 1 then ca.SKU end) '总SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then ca.SKU end)'在线SKU数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' then concat(ShopCode, '-', SellerSKU) end)'目前在线链接数',
													count(distinct case when ListingStatus = 1 and ShopStatus = '正常' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'当周刊登在线链接数'
												from
													ca
) as a1
on
	t.department = a1.department
	and t.product_tupe = a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
	with ca as (
	select
		go.BoxSku,
		go.SPU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		PayTime,
		TaxGross,
		TotalGross,
		TotalProfit,
		TaxRatio,
		RefundAmount,
		ExchangeUSD,
		TransactionType,
		OrderStatus,
		OrderTotalPrice,
		od.SellerSku,
		od.ShopIrobotId,
		PlatOrderNumber
	from
		import_data.OrderDetails od
	inner join life_category as go
on
		go.BoxSKU = od.BoxSku
	join import_data.mysql_store s
on
		s.code = od.ShopIrobotId
		and s.Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	left join import_data.Basedata b
on
		b.ReportType = '周报'
			and b.FirstDay = date_add('2022-12-26', interval -7 day)
				and b.DepSite = s.Site
			where
				PayTime >= date_add('2022-12-26', interval -28 day)
					and PayTime <'2022-12-26'
					and od.OrderNumber not in
(
					select
						OrderNumber
					from
						(
						SELECT
							OrderNumber,
							GROUP_CONCAT(TransactionType) alltype
						FROM
							import_data.OrderDetails
						where
							ShipmentStatus = '未发货'
							and OrderStatus = '作废'
							and PayTime >= date_add('2022-12-26', interval -28 day)
								and PayTime < '2022-12-26'
							group by
								OrderNumber) a
					where
						alltype = '付款')
)

/*所有部门小组新品*/
	select
		'家居生活' as category,
		concat(ca.Department, '-', ca.NodePathName) as department ,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
		round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 
      then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
		round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
		round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
	from
		ca
	where
		DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
			and DevelopLastAuditTime<'2022-12-26'
			and ca.Department in ('销售一部', '销售二部', '销售三部')/*所有销售部门小组新品*/
		group by
			concat(ca.Department, '-', ca.NodePathName)
	union
/*各部门新品出单数及销售数据*/
		select
			'家居生活' as category,
			ca.Department,
			'周报' as ReportType,
			weekofyear('2022-12-26') as '周次',
			'新品' as product_tupe,
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
			round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
			round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
			round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
		from
			ca
		where
			DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26' /*所有销售部门新品*/
			group by
				ca.Department
		union
/*PM部门新品出单数据及销售数据*/
			select
				'家居生活' as category,
				'PM' as department,
				'周报' as ReportType,
				weekofyear('2022-12-26') as '周次',
				'新品' as product_tupe,
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
				round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
				round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
				round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
					and ca.Department in ('销售二部', '销售三部')
			union
/*所有部门新品出单数据及销售数据*/
				select
					'家居生活' as category,
					'所有部门' as department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'新品' as product_tupe,
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
					round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
					round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
					round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
				union
/*重点产品数据*/
					/*重点产品各小组数据*/
					select
						'家居生活' as category,
						concat(ca.Department, '-', ca.NodePathName) as department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'重点产品' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
						and ca.Department in ('销售一部', '销售二部', '销售三部')/*所有销售部门小组新品*/
					group by
						concat(ca.Department, '-', ca.NodePathName)
				union
/*所有部门各部门重点产品数据*/
					select
						'家居生活' as category,
						ca.Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'重点产品' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
					group by
						ca.Department
				union
/*PM部门重点产品出单及销售数据*/
					select
						'家居生活' as category,
						'PM' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'重点产品' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
						and Department in ('销售二部', '销售三部')
				union
					select
						'家居生活' as category,
						'所有部门' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'重点产品' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
				union
/*其他产品-除新品及重点产品外其他产品*/
					/*所有部门小组其他产品*/
					select
						'家居生活' as category,
						concat(ca.Department, '-', ca.NodePathName) as department ,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'其他产品' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
					from
						ca
					where
						ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
							and ca.BoxSKU not in (
							select
								BoxSKU
							from
								lead_product)
							and ca.Department in ('销售一部', '销售二部', '销售三部')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*各部门其他产品出单及销售数据*/
						select
							'家居生活' as category,
							ca.Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'其他产品' as product_tupe,
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
							round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
							round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
							round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
							group by
								ca.Department
						union
/*PM部门其他产品出单及销售数据*/
							select
								'家居生活' as category,
								'PM' as Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'其他产品' as product_tupe,
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
								round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
								round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
								round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
									and Department in ('销售二部', '销售三部')
							union
/*PM部门其他产品出单及销售数据*/
								select
									'家居生活' as category,
									'所有部门' as Department,
									'周报' as ReportType,
									weekofyear('2022-12-26') as '周次',
									'其他产品' as product_tupe,
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
									round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
									round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
									round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
								union
/*所有产品*/
									/*所有部门小组出单及销售数据*/
									select
										'家居生活' as category,
										concat(ca.Department, '-', ca.NodePathName) as department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
									from
										ca
									where
										ca.Department in ('销售一部', '销售二部', '销售三部')
									group by
										concat(ca.Department, '-', ca.NodePathName)
								union
/*各部门所有产品出单及销售数据*/
									select
										'家居生活' as category,
										ca.Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
									from
										ca
									group by
										ca.Department
								union
/*PM部门出单及销售数据*/
									select
										'家居生活' as category,
										'PM' as Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
									from
										ca
									where
										ca.Department in ('销售三部', '销售二部')
								union
/*所有部门所有产品订单及销售数据*/
									select
										'家居生活' as category,
										'所有部门' as Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber end ) '订单数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '当周出单链接数',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4周出单链接数',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'当周销售额',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'当周利润额',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '当周利润率'
									from
										ca) as a2
on
	t.department = a2.department
	and a1.product_tupe = a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
	with ca as (
	select
		go.BoxSKU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		RefundUSDPrice,
		ShipDate,
		RefundReason2
	from
		RefundOrders ro
	inner join OrderDetails od
on
		ro.PlatOrderNumber = od.PlatOrderNumber
		and od.TransactionType = '付款'
	inner join life_category as go
on
		go.BoxSKU = od.BoxSku
	inner join mysql_store s
on
		s.Code = ro.OrderSource
		and s.Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	where
		RefundDate >= date_add('2022-12-26', interval -7 day)
			and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
	/*各部门小组新品退款数据*/
	select
		'家居生活' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		sum(ca.RefundUSDPrice) '退款总额',
		/*PM部门新品退款数据*/
		sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
		sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
	from
		ca
	where
		Department in ('销售一部', '销售二部', '销售三部')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*各部门新品退款数据*/
			select
				'家居生活' as category,
				ca.Department,
				'周报' as ReportType,
				weekofyear('2022-12-26') as '周次',
				'新品' as product_tupe,
				sum(ca.RefundUSDPrice) '退款总额',
				/*PM部门新品退款数据*/
				sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
				sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM部门新品退款数据*/
				select
					'家居生活' as category,
					'PM' as Department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'新品' as product_tupe,
					sum(ca.RefundUSDPrice) '退款总额',
					/*PM部门新品退款数据*/
					sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
					sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and Department in ('销售二部', '销售三部')
				union
/*所有部门新品退款数据*/
					select
						'家居生活' as category,
						'所有部门' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'新品' as product_tupe,
						sum(ca.RefundUSDPrice) '退款总额',
						/*PM部门新品退款数据*/
						sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
						sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*重点产品*/
						/*所有部门小组重点产品退款数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(ca.RefundUSDPrice) '退款总额',
							/*所有部门重点产品退款数据*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
							and Department in ('销售一部', '销售二部', '销售三部')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*各部门重点产品退款数据*/
						select
							'家居生活' as category,
							ca.Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(ca.RefundUSDPrice) '退款总额',
							/*所有部门重点产品退款数据*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
						group by
							ca.Department
					union
/*PM部门重点产品退款数据*/
						select
							'家居生活' as category,
							'PM' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(ca.RefundUSDPrice) '退款总额',
							/*所有部门重点产品退款数据*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
							and Department in ('销售二部', '销售三部')
					union
/*所有部门重点产品退款数据*/
						select
							'家居生活' as category,
							'所有部门' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(ca.RefundUSDPrice) '退款总额',
							/*所有部门重点产品退款数据*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
					union
/*其他产品*/
						/*所有部门小组其他产品退款数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'其他产品' as product_tupe,
							sum(ca.RefundUSDPrice) '退款总额',
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('销售一部', '销售二部', '销售三部')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*各部门其他产品退款数据*/
							select
								'家居生活' as category,
								ca.Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'其他产品' as product_tupe,
								sum(ca.RefundUSDPrice) '退款总额',
								sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
								sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM部门其他产品退款数据*/
								select
									'家居生活' as category,
									'PM' as department,
									'周报' as ReportType,
									weekofyear('2022-12-26') as '周次',
									'其他产品' as product_tupe,
									sum(ca.RefundUSDPrice) '退款总额',
									sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
									sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and Department in ('销售二部', '销售三部')
								union
/*所有部门其他产品退款数据*/
									select
										'家居生活' as category,
										'所有部门' as department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'其他产品' as product_tupe,
										sum(ca.RefundUSDPrice) '退款总额',
										sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
										sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*所有产品*/
										/*各部门小组所有产品退款数据*/
										select
											'家居生活' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '退款总额',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
										from
											ca
										where
											Department in ('销售一部', '销售二部', '销售三部')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*各部门所有产品退款数据*/
										select
											'家居生活' as category,
											ca.Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '退款总额',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
										from
											ca
										group by
											ca.Department
									union
/*PM部门所有产品退款数据*/
										select
											'家居生活' as category,
											'PM' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '退款总额',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
										from
											ca
										where
											Department in ('销售二部', '销售三部')
									union
/*所有部门所有产品退款数据*/
										select
											'家居生活' as category,
											'所有部门' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '退款总额',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额'
										from
											ca
) as a3
on
	t.department = a3.department
	and a1.product_tupe = a3.product_tupe
left join
(
/*访客数据*/
	with ca as (
	select
		Department,
		NodePathName,
		go.SKU,
		go.BoxSKU,
		go.DevelopLastAuditTime,
		TotalCount,
		FeaturedOfferPercent,
		OrderedCount,
		ChildAsin,
		aa.ShopCode
	from
		erp_amazon_amazon_listing as al
	inner join life_category as go
on
		al.Sku = go.SKU
	inner join ListingManage aa
on
		aa.ChildAsin = al.ASIN
		and aa.ShopCode = al.ShopCode
		and aa.ReportType = '周报'
	inner join mysql_store s
on
		s.code = al.shopcode
		and s.Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	where
		aa.Monday = date_add('2022-12-26', interval -7 day)
			and aa.TotalCount * aa.FeaturedOfferPercent / 100>0
)
/*访客数、访客销量及访客转化率*/
	/*所有部门小组新品访客数据*/
	select
		'家居生活' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
		sum(OrderedCount) '访客销量',
		round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
		count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
	from
		ca
	where
		ca.Department in ('销售一部', '销售二部', '销售三部')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*各部门新品访客数据*/
			select
				'家居生活' as category,
				ca.Department,
				'周报' as ReportType,
				weekofyear('2022-12-26') as '周次',
				'新品' as product_tupe,
				round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
				sum(OrderedCount) '访客销量',
				round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
				count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM部门新品访客数据*/
				select
					'家居生活' as category,
					'PM' as Department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'新品' as product_tupe,
					round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
					sum(OrderedCount) '访客销量',
					round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
					count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department in ('销售二部', '销售三部')
				union
/*所有部门新品访客数据*/
					select
						'家居生活' as category,
						'所有部门' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'新品' as product_tupe,
						round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
						sum(OrderedCount) '访客销量',
						round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
						count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*重点产品*/
						/*各部门小组重点产品访客数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
							sum(OrderedCount) '访客销量',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('销售一部', '销售二部', '销售三部')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*各部门重点产品访客数据*/
						select
							'家居生活' as category,
							ca.Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
							sum(OrderedCount) '访客销量',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						group by
							ca.Department
					union
/*PM部门重点产品访客数据*/
						select
							'家居生活' as category,
							'PM' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
							sum(OrderedCount) '访客销量',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('销售二部', '销售三部')
					union
/*所有部门重点产品访客数据*/
						select
							'家居生活' as category,
							'所有部门' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
							sum(OrderedCount) '访客销量',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
					union
/*其他产品*/
						/*各部门小组其他产品访客数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'其他产品' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
							sum(OrderedCount) '访客销量',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('销售一部', '销售二部', '销售三部')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*各部门其他产品访客数据*/
							select
								'家居生活' as category,
								ca.Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'其他产品' as product_tupe,
								round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
								sum(OrderedCount) '访客销量',
								round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
								count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM部门其他产品访客数据*/
								select
									'家居生活' as category,
									'PM' as Department,
									'周报' as ReportType,
									weekofyear('2022-12-26') as '周次',
									'其他产品' as product_tupe,
									round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
									sum(OrderedCount) '访客销量',
									round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
									count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and ca.Department in ('销售二部', '销售三部')
								union
/*所有部门其他产品访客数据*/
									select
										'家居生活' as category,
										'所有部门' as Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'其他产品' as product_tupe,
										round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
										sum(OrderedCount) '访客销量',
										round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
										count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*所有产品*/
										/*所有部门小组所有产品访客数据*/
										select
											'家居生活' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
											sum(OrderedCount) '访客销量',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
										from
											ca
										where
											Department in ('销售一部', '销售二部', '销售三部')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*各部门所有产品访客数据*/
										select
											'家居生活' as category,
											ca.Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
											sum(OrderedCount) '访客销量',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
										from
											ca
										group by
											ca.Department
									union
/*PM部门所有产品访客数据*/
										select
											'家居生活' as category,
											'PM' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
											sum(OrderedCount) '访客销量',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
										from
											ca
										where
											ca.Department in ('销售二部', '销售三部')
									union
/*所有部门所有产品访客数据*/
										select
											'家居生活' as category,
											'所有部门' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数',
											sum(OrderedCount) '访客销量',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '访客转化率',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'被访问链接数'
										from
											ca) as a4
on
	t.department = a4.department
	and a1.product_tupe = a4.product_tupe
left join
(
with ca as (
	select
		go.SKU,
		go.BoxSKU,
		DevelopLastAuditTime,
		Department,
		NodePathName,
		TotalSale7Day,
		TotalSale7DayUnit,
		Spend,
		Clicks,
		Exposure,
		UnitsOrdered7d,
		aa.SellerSKU,
		aa.ShopCode
	from
		erp_amazon_amazon_listing as al
	inner join life_category as go
on
		al.Sku = go.SKU
	inner join AdServing_Amazon aa
on
		aa.SellerSKU = al.SellerSKU
		and aa.shopcode = al.ShopCode
	inner join mysql_store as s
on
		s.code = aa.Shopcode
		and s.Department in ('销售一部', '销售二部', '销售三部', '销售四部')
	where
		aa.CreatedTime >= date_add('2022-12-26', interval -8 day)
			and aa.CreatedTime < date_add('2022-12-26', interval -1 day)
)
/*新品*/
	/*各部门小组广告数据*/
	select
		'家居生活' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		sum(Exposure) as '曝光量',
		sum(Clicks) '点击量',
		round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
		sum(TotalSale7DayUnit) '广告订单量',
		round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
		sum(TotalSale7Day) '广告销售额',
		sum(Spend) '广告花费',
		round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
		round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
		count (distinct case
			when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
		end ) '有曝光的广告投放',
		count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
	from
		ca
	where
		ca.Department in ('销售一部', '销售二部', '销售三部')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*各部门新品广告数据*/
			select
				'家居生活' as category,
				ca.Department,
				'周报' as ReportType,
				weekofyear('2022-12-26') as '周次',
				'新品' as product_tupe,
				sum(Exposure) as '曝光量',
				sum(Clicks) '点击量',
				round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
				sum(TotalSale7DayUnit) '广告订单量',
				round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
				sum(TotalSale7Day) '广告销售额',
				sum(Spend) '广告花费',
				round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
				round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
				count (distinct case
					when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
				end ) '有曝光的广告投放',
				count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM部门新品广告数据*/
				select
					'家居生活' as category,
					'PM' as Department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'新品' as product_tupe,
					sum(Exposure) as '曝光量',
					sum(Clicks) '点击量',
					round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
					sum(TotalSale7DayUnit) '广告订单量',
					round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
					sum(TotalSale7Day) '广告销售额',
					sum(Spend) '广告花费',
					round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
					round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
					count (distinct case
						when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
					end ) '有曝光的广告投放',
					count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department in ('销售二部', '销售三部')
				union
/*所有部门新品广告数据*/
					select
						'家居生活' as category,
						'所有部门' as Department,
						'周报' as ReportType,
						weekofyear('2022-12-26') as '周次',
						'新品' as product_tupe,
						sum(Exposure) as '曝光量',
						sum(Clicks) '点击量',
						round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
						sum(TotalSale7DayUnit) '广告订单量',
						round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
						sum(TotalSale7Day) '广告销售额',
						sum(Spend) '广告花费',
						round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
						round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
						count (distinct case
							when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
						end ) '有曝光的广告投放',
						count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*重点产品*/
						/*各部门小组重点产品广告数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(Exposure) as '曝光量',
							sum(Clicks) '点击量',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
							sum(TotalSale7DayUnit) '广告订单量',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
							sum(TotalSale7Day) '广告销售额',
							sum(Spend) '广告花费',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '有曝光的广告投放',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						where
							ca.Department in ('销售一部', '销售二部', '销售三部')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*各部门重点产品广告数据*/
						select
							'家居生活' as category,
							ca.Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(Exposure) as '曝光量',
							sum(Clicks) '点击量',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
							sum(TotalSale7DayUnit) '广告订单量',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
							sum(TotalSale7Day) '广告销售额',
							sum(Spend) '广告花费',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '有曝光的广告投放',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						group by
							ca.Department
					union
/*PM部门重点产品广告数据*/
						select
							'家居生活' as category,
							'PM' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(Exposure) as '曝光量',
							sum(Clicks) '点击量',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
							sum(TotalSale7DayUnit) '广告订单量',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
							sum(TotalSale7Day) '广告销售额',
							sum(Spend) '广告花费',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '有曝光的广告投放',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('销售二部', '销售三部')
					union
/*所有部门重点产品广告数据*/
						select
							'家居生活' as category,
							'所有部门' as Department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'重点产品' as product_tupe,
							sum(Exposure) as '曝光量',
							sum(Clicks) '点击量',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
							sum(TotalSale7DayUnit) '广告订单量',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
							sum(TotalSale7Day) '广告销售额',
							sum(Spend) '广告花费',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '有曝光的广告投放',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
					union
/*其他产品*/
						/*各部门小组其他产品广告数据*/
						select
							'家居生活' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'周报' as ReportType,
							weekofyear('2022-12-26') as '周次',
							'其他产品' as product_tupe,
							sum(Exposure) as '曝光量',
							sum(Clicks) '点击量',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
							sum(TotalSale7DayUnit) '广告订单量',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
							sum(TotalSale7Day) '广告销售额',
							sum(Spend) '广告花费',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '有曝光的广告投放',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
							from ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('销售一部', '销售二部', '销售三部')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*各部门其他产品广告数据*/
							select
								'家居生活' as category,
								ca.Department,
								'周报' as ReportType,
								weekofyear('2022-12-26') as '周次',
								'其他产品' as product_tupe,
								sum(Exposure) as '曝光量',
								sum(Clicks) '点击量',
								round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
								sum(TotalSale7DayUnit) '广告订单量',
								round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
								sum(TotalSale7Day) '广告销售额',
								sum(Spend) '广告花费',
								round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
								round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
								count (distinct case
									when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
								end ) '有曝光的广告投放',
								count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
								from ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM部门其他产品广告数据*/
								select
									'家居生活' as category,
									'PM' as Department,
									'周报' as ReportType,
									weekofyear('2022-12-26') as '周次',
									'其他产品' as product_tupe,
									sum(Exposure) as '曝光量',
									sum(Clicks) '点击量',
									round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
									sum(TotalSale7DayUnit) '广告订单量',
									round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
									sum(TotalSale7Day) '广告销售额',
									sum(Spend) '广告花费',
									round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
									round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
									count (distinct case
										when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
									end ) '有曝光的广告投放',
									count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
									from ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and Department in ('销售二部', '销售三部')
								union
/*所有部门其他产品广告数据*/
									select
										'家居生活' as category,
										'所有部门' as Department,
										'周报' as ReportType,
										weekofyear('2022-12-26') as '周次',
										'其他产品' as product_tupe,
										sum(Exposure) as '曝光量',
										sum(Clicks) '点击量',
										round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
										sum(TotalSale7DayUnit) '广告订单量',
										round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
										sum(TotalSale7Day) '广告销售额',
										sum(Spend) '广告花费',
										round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
										round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
										count (distinct case
											when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
										end ) '有曝光的广告投放',
										count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
										from ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*所有产品*/
										/*各部门小组所有产品广告数据*/
										select
											'家居生活' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(Exposure) as '曝光量',
											sum(Clicks) '点击量',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
											sum(TotalSale7DayUnit) '广告订单量',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
											sum(TotalSale7Day) '广告销售额',
											sum(Spend) '广告花费',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '有曝光的广告投放',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
											from ca
										where
											Department in ('销售一部', '销售二部', '销售三部')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*各部门所有产品广告数据*/
										select
											'家居生活' as category,
											ca.Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(Exposure) as '曝光量',
											sum(Clicks) '点击量',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
											sum(TotalSale7DayUnit) '广告订单量',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
											sum(TotalSale7Day) '广告销售额',
											sum(Spend) '广告花费',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '有曝光的广告投放',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
											from ca
										group by
											ca.Department
									union
/*PM部门所有产品广告数据*/
										select
											'家居生活' as category,
											'PM' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(Exposure) as '曝光量',
											sum(Clicks) '点击量',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
											sum(TotalSale7DayUnit) '广告订单量',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
											sum(TotalSale7Day) '广告销售额',
											sum(Spend) '广告花费',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '有曝光的广告投放',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
											from ca
										where
											Department in ('销售二部', '销售三部')
									union
/*所有部门所有产品广告数据*/
										select
											'家居生活' as category,
											'所有部门' as Department,
											'周报' as ReportType,
											weekofyear('2022-12-26') as '周次',
											'-' as product_tupe,
											sum(Exposure) as '曝光量',
											sum(Clicks) '点击量',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '广告点击率',
											sum(TotalSale7DayUnit) '广告订单量',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '广告转化率',
											sum(TotalSale7Day) '广告销售额',
											sum(Spend) '广告花费',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '广告Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '广告cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '有曝光的广告投放',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '有出单的广告投放'
											from ca) as a5
on
	t.department = a5.department
	and a1.product_tupe = a5.product_tupe
left join
(
with ca as(
	select
		lp.SPU,
		lp.BoxSKU,
		lp.DevelopLastAuditTime
	from
		life_category go
	inner join lead_product lp
on
		go.BoxSKU = lp.BoxSKU
		and go.SKU = lp.SKU
	where
		UpdateTime >= date_add('2022-12-26', interval -7 day)
			and UpdateTime<'2022-12-26'
)
/*新品*/
	/*所有部门新品转重点产品*/
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe,
		count(distinct ca.SPU) '转为重点产品SPU数'
	from
		ca
union
/*其他产品转为SPU数*/
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'其他产品' as product_tupe,
		count(distinct ca.SPU) '转为重点产品SPU数'
		from ca
	where
		ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day) ) as a6
on
	t.department = a6.Department
	and a1.product_tupe = a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
	with ca as(
	select
		lp.SPU,
		lp.BoxSKU,
		lp.DevelopLastAuditTime
	from
		life_category go
	inner join lead_product lp
on
		go.BoxSKU = lp.BoxSKU
		and go.SKU = lp.SKU
	where
		UpdateTime >= date_add('2022-12-26', interval -7 day)
			and UpdateTime<'2022-12-26'
)
/*新品*/
	/*所有部门新品转重点产品*/
	select
		'家居生活' as category,
		'所有部门' as Department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'重点产品' as product_tupe,
		round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
), 2) '转为重点产品贡献销售额'
	from
		ca
	inner join OrderDetails od
on
		ca.BoxSKU = od.BoxSku
		and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
			and DevelopLastAuditTime<'2022-12-26'
		join import_data.mysql_store s
on
			s.code = od.ShopIrobotId
		left join import_data.Basedata b
on
			b.ReportType = '周报'
			and b.FirstDay = date_add('2022-12-26', interval -7 day)
				and b.DepSite = s.Site
			where
				PayTime >= date_add('2022-12-26', interval -7 day)
					and PayTime <'2022-12-26'
					and od.OrderNumber not in
(
					select
						OrderNumber
					from
						(
						SELECT
							OrderNumber,
							GROUP_CONCAT(TransactionType) alltype
						FROM
							import_data.OrderDetails
						where
							ShipmentStatus = '未发货'
							and OrderStatus = '作废'
							and PayTime >= date_add('2022-12-26', interval -7 day)
								and PayTime < '2022-12-26'
							group by
								OrderNumber) a
					where
						alltype = '付款')
			union
/*其他产品转为SPU贡献业绩*/
				select
					'家居生活' as category,
					'所有部门' as Department,
					'周报' as ReportType,
					weekofyear('2022-12-26') as '周次',
					'其他产品' as product_tupe,
					round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
), 2) '转为重点产品贡献销售额'
				from
					ca
				inner join OrderDetails od
on
					ca.BoxSKU = od.BoxSku
					and DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
				join import_data.mysql_store s
on
					s.code = od.ShopIrobotId
				left join import_data.Basedata b
on
					b.ReportType = '周报'
						and b.FirstDay = date_add('2022-12-26', interval -7 day)
							and b.DepSite = s.Site
						where
							PayTime >= date_add('2022-12-26', interval -7 day)
								and PayTime <'2022-12-26'
								and od.OrderNumber not in
(
								select
									OrderNumber
								from
									(
									SELECT
										OrderNumber,
										GROUP_CONCAT(TransactionType) alltype
									FROM
										import_data.OrderDetails
									where
										ShipmentStatus = '未发货'
										and OrderStatus = '作废'
										and PayTime >= date_add('2022-12-26', interval -7 day)
											and PayTime < '2022-12-26'
										group by
											OrderNumber) a
								where
									alltype = '付款')) as a7
on
	t.department = a7.Department
	and a1.product_tupe = a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
	/*新品*/
	/*各部门小组新品新增SPU数*/
	select
		'家居生活' as category,
		'所有部门' as department,
		'周报' as ReportType,
		weekofyear('2022-12-26') as '周次',
		'新品' as product_tupe,
		count(distinct SPU) '新增SPU数',
		count(distinct sku) '新增SKU数'
	from
		life_category
	where
		DevelopLastAuditTime >= date_add('2022-12-26', interval -7 day )
			and DevelopLastAuditTime<'2022-12-26'
	union
		select
			'家居生活' as category,
			'PM' as department,
			'周报' as ReportType,
			weekofyear('2022-12-26') as '周次',
			'新品' as product_tupe,
			count(distinct SPU) '新增SPU数',
			count(distinct sku) '新增SKU数'
		from
			life_category
		where
			DevelopLastAuditTime >= date_add('2022-12-26', interval -7 day )
				and DevelopLastAuditTime<'2022-12-26') as a8
on
	t.department = a8.department
	and a1.product_tupe = a8.product_tupe
order by
	t.department ,
	t.product_tupe desc;


select t.category, t.department, t.ReportType, t.周次, t.product_tupe,round(a2.当周销售额-ifnull(a3.退款总额,0),2) '销售额' ,
round(a2.当周利润额-ifnull(a5.广告花费,0)-ifnull(a3.退款总额,0),2) '利润额',round(((当周利润额-ifnull(广告花费,0)-ifnull(退款总额,0))/(当周销售额-ifnull(退款总额,0)))*100,2) as '利润率',
订单数,round((当周销售额-ifnull(退款总额,0))/订单数,2) '客单价',当周销售额,当周利润额,当周利润率,
退款总额,round((退款总额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '退款率',
发货退款金额,round((发货退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '已发货退款率',
无理由退款金额,round((无理由退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '无理由退款率',
总SPU数,在线SPU数,新增SPU数,转为重点产品SPU数,转为重点产品贡献销售额,当周出单SPU数,`4周出单SPU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SPU数,2) '总-单SPU贡献业绩',
round(目前在线链接数/在线SPU数,2) '平均SPU在线链接数',
round((当周出单SPU数/在线SPU数)*100,2) 'SPU当周动销率',
round((`4周出单SPU数`/在线SPU数)*100,2) 'SPU4周动销率',
总SKU数,在线SKU数,新增SKU数,当周出单SKU数,`4周出单SKU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SKU数,2) '总-单SKU贡献业绩',
round(目前在线链接数/在线SKU数,2) '平均SKU在线链接数',
round((当周出单SPU数/在线SKU数)*100,2) 'SKU当周动销率',
round((`4周出单SPU数`/在线SKU数)*100,2) 'SKU4周动销率',
目前在线链接数,当周刊登在线链接数,当周出单链接数,`4周出单链接数`,round((当周出单链接数/目前在线链接数)*100,2) '链接当周动销率',
round((`4周出单链接数`/目前在线链接数)*100,2) '链接4周动销率',
访客数,访客销量,被访问链接数,访客转化率,
曝光量, 点击量, 广告点击率, 广告订单量, 广告转化率, 广告销售额, 广告花费, round((广告花费/(当周销售额-ifnull(退款总额,0)))*100,2) '广告花费率',
round((广告销售额/(当周销售额-ifnull(退款总额,0)))*100,2) '广告业绩占比',广告Acost, 广告cpc, 有曝光的广告投放, 有出单的广告投放,
ifnull(访客数,0)-ifnull(点击量,0) as '自然流量访客数',ifnull(访客销量,0)-ifnull(广告订单量,0) as '自然流量访客销量',
round(((ifnull(访客销量,0)-ifnull(广告订单量,0))/(ifnull(访客数,0)-ifnull(点击量,0)))*100,2) '自然流量访客转化率'
from
(select '工具配件' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '工具配件' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '工具配件' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '工具配件' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '工具配件' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*实际为销售小组在线SPU数*/
inner join tool_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('销售一部','销售二部','销售三部','销售四部'))
/*新品*/
/*所有部门小组新品在线数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where ca.Department  in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品在线数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '工具配件' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='销售四部'

union
/*PM部门新品在线数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('销售二部','销售三部')
union
/*所有部门新品在线数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品在线数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品在线数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '工具配件' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='销售四部'

union
/*PM部门重点产品在线数据*/
select '工具配件' as category,'PM' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品在线数据*/
select '工具配件' as category,'所有部门' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*其他产品*/
/*所有部门小组其他产品在线数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品在线数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '工具配件' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='销售四部'
union
/*PM部门其他产品在线数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品在线数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品在线数据*/
select '工具配件' as category, concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品在线数据*/
select '工具配件' as category, ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '工具配件' as category, '销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department='销售四部'
union
/*PM部门所有产品在线数据*/
select '工具配件' as category, 'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品在线数据*/
select '工具配件' as category, '所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join tool_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')
)

/*所有部门小组新品*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '工具配件' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '工具配件' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='付款'
inner join tool_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
/*各部门小组新品退款数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品退款数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品退款数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('销售二部','销售三部')
union
/*所有部门新品退款数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*所有部门小组重点产品退款数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品退款数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品退款数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品退款数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*其他产品*/
/*所有部门小组其他产品退款数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品退款数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品退款数据*/
select '工具配件' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品退款数据*/
select '工具配件' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品退款数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品退款数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
group by ca.Department
union
/*PM部门所有产品退款数据*/
select '工具配件' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品退款数据*/
select '工具配件' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*访客数据*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join tool_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '周报'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*访客数、访客销量及访客转化率*/
/*所有部门小组新品访客数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品访客数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品访客数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品访客数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品访客数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品访客数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品访客数据*/
select '工具配件' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品访客数据*/
select '工具配件' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品访客数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品访客数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品访客数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品访客数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组所有产品访客数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品访客数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
group by ca.Department
union
/*PM部门所有产品访客数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售二部','销售三部')
union
/*所有部门所有产品访客数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join tool_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*新品*/
/*各部门小组广告数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品广告数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品广告数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品广告数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品广告数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品广告数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品广告数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品广告数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品广告数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品广告数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品广告数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品广告数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品广告数据*/
select '工具配件' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品广告数据*/
select '工具配件' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
group by ca.Department
union
/*PM部门所有产品广告数据*/
select '工具配件' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品广告数据*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from tool_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '工具配件' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数' from ca
union
/*其他产品转为SPU数*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from tool_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '工具配件' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')

union
/*其他产品转为SPU贡献业绩*/
select '工具配件' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
/*新品*/
/*各部门小组新品新增SPU数*/
select '工具配件' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from tool_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '工具配件' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from tool_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;

select t.category, t.department, t.ReportType, t.周次, t.product_tupe,round(a2.当周销售额-ifnull(a3.退款总额,0),2) '销售额' ,
round(a2.当周利润额-ifnull(a5.广告花费,0)-ifnull(a3.退款总额,0),2) '利润额',round(((当周利润额-ifnull(广告花费,0)-ifnull(退款总额,0))/(当周销售额-ifnull(退款总额,0)))*100,2) as '利润率',
订单数,round((当周销售额-ifnull(退款总额,0))/订单数,2) '客单价',当周销售额,当周利润额,当周利润率,
退款总额,round((退款总额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '退款率',
发货退款金额,round((发货退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '已发货退款率',
无理由退款金额,round((无理由退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '无理由退款率',
总SPU数,在线SPU数,新增SPU数,转为重点产品SPU数,转为重点产品贡献销售额,当周出单SPU数,`4周出单SPU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SPU数,2) '总-单SPU贡献业绩',
round(目前在线链接数/在线SPU数,2) '平均SPU在线链接数',
round((当周出单SPU数/在线SPU数)*100,2) 'SPU当周动销率',
round((`4周出单SPU数`/在线SPU数)*100,2) 'SPU4周动销率',
总SKU数,在线SKU数,新增SKU数,当周出单SKU数,`4周出单SKU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SKU数,2) '总-单SKU贡献业绩',
round(目前在线链接数/在线SKU数,2) '平均SKU在线链接数',
round((当周出单SPU数/在线SKU数)*100,2) 'SKU当周动销率',
round((`4周出单SPU数`/在线SKU数)*100,2) 'SKU4周动销率',
目前在线链接数,当周刊登在线链接数,当周出单链接数,`4周出单链接数`,round((当周出单链接数/目前在线链接数)*100,2) '链接当周动销率',
round((`4周出单链接数`/目前在线链接数)*100,2) '链接4周动销率',
访客数,访客销量,被访问链接数,访客转化率,
曝光量, 点击量, 广告点击率, 广告订单量, 广告转化率, 广告销售额, 广告花费, round((广告花费/(当周销售额-ifnull(退款总额,0)))*100,2) '广告花费率',
round((广告销售额/(当周销售额-ifnull(退款总额,0)))*100,2) '广告业绩占比',广告Acost, 广告cpc, 有曝光的广告投放, 有出单的广告投放,
ifnull(访客数,0)-ifnull(点击量,0) as '自然流量访客数',ifnull(访客销量,0)-ifnull(广告订单量,0) as '自然流量访客销量',
round(((ifnull(访客销量,0)-ifnull(广告订单量,0))/(ifnull(访客数,0)-ifnull(点击量,0)))*100,2) '自然流量访客转化率'
from
(select '娱乐爱好' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '娱乐爱好' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '娱乐爱好' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '娱乐爱好' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '娱乐爱好' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*实际为销售小组在线SPU数*/
inner join like_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('销售一部','销售二部','销售三部','销售四部'))
/*新品*/
/*所有部门小组新品在线数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where ca.Department  in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品在线数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '娱乐爱好' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='销售四部'

union
/*PM部门新品在线数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('销售二部','销售三部')
union
/*所有部门新品在线数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品在线数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品在线数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '娱乐爱好' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='销售四部'

union
/*PM部门重点产品在线数据*/
select '娱乐爱好' as category,'PM' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品在线数据*/
select '娱乐爱好' as category,'所有部门' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*其他产品*/
/*所有部门小组其他产品在线数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品在线数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '娱乐爱好' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='销售四部'
union
/*PM部门其他产品在线数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品在线数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品在线数据*/
select '娱乐爱好' as category, concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品在线数据*/
select '娱乐爱好' as category, ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '娱乐爱好' as category, '销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department='销售四部'
union
/*PM部门所有产品在线数据*/
select '娱乐爱好' as category, 'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品在线数据*/
select '娱乐爱好' as category, '所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join like_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')
)

/*所有部门小组新品*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '娱乐爱好' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '娱乐爱好' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='付款'
inner join like_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
/*各部门小组新品退款数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品退款数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品退款数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('销售二部','销售三部')
union
/*所有部门新品退款数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*所有部门小组重点产品退款数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品退款数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品退款数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品退款数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*其他产品*/
/*所有部门小组其他产品退款数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品退款数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品退款数据*/
select '娱乐爱好' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品退款数据*/
select '娱乐爱好' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品退款数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品退款数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
group by ca.Department
union
/*PM部门所有产品退款数据*/
select '娱乐爱好' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品退款数据*/
select '娱乐爱好' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*访客数据*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join like_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '周报'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*访客数、访客销量及访客转化率*/
/*所有部门小组新品访客数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品访客数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品访客数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品访客数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品访客数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品访客数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品访客数据*/
select '娱乐爱好' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品访客数据*/
select '娱乐爱好' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品访客数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品访客数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品访客数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品访客数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组所有产品访客数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品访客数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
group by ca.Department
union
/*PM部门所有产品访客数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售二部','销售三部')
union
/*所有部门所有产品访客数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join like_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*新品*/
/*各部门小组广告数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品广告数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品广告数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品广告数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品广告数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品广告数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品广告数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品广告数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品广告数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品广告数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品广告数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品广告数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品广告数据*/
select '娱乐爱好' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品广告数据*/
select '娱乐爱好' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
group by ca.Department
union
/*PM部门所有产品广告数据*/
select '娱乐爱好' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品广告数据*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from like_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '娱乐爱好' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数' from ca
union
/*其他产品转为SPU数*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from like_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '娱乐爱好' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')

union
/*其他产品转为SPU贡献业绩*/
select '娱乐爱好' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
/*新品*/
/*各部门小组新品新增SPU数*/
select '娱乐爱好' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from like_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '娱乐爱好' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from like_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;


select t.category, t.department, t.ReportType, t.周次, t.product_tupe,round(a2.当周销售额-ifnull(a3.退款总额,0),2) '销售额' ,
round(a2.当周利润额-ifnull(a5.广告花费,0)-ifnull(a3.退款总额,0),2) '利润额',round(((当周利润额-ifnull(广告花费,0)-ifnull(退款总额,0))/(当周销售额-ifnull(退款总额,0)))*100,2) as '利润率',
订单数,round((当周销售额-ifnull(退款总额,0))/订单数,2) '客单价',当周销售额,当周利润额,当周利润率,
退款总额,round((退款总额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '退款率',
发货退款金额,round((发货退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '已发货退款率',
无理由退款金额,round((无理由退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '无理由退款率',
总SPU数,在线SPU数,新增SPU数,转为重点产品SPU数,转为重点产品贡献销售额,当周出单SPU数,`4周出单SPU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SPU数,2) '总-单SPU贡献业绩',
round(目前在线链接数/在线SPU数,2) '平均SPU在线链接数',
round((当周出单SPU数/在线SPU数)*100,2) 'SPU当周动销率',
round((`4周出单SPU数`/在线SPU数)*100,2) 'SPU4周动销率',
总SKU数,在线SKU数,新增SKU数,当周出单SKU数,`4周出单SKU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SKU数,2) '总-单SKU贡献业绩',
round(目前在线链接数/在线SKU数,2) '平均SKU在线链接数',
round((当周出单SPU数/在线SKU数)*100,2) 'SKU当周动销率',
round((`4周出单SPU数`/在线SKU数)*100,2) 'SKU4周动销率',
目前在线链接数,当周刊登在线链接数,当周出单链接数,`4周出单链接数`,round((当周出单链接数/目前在线链接数)*100,2) '链接当周动销率',
round((`4周出单链接数`/目前在线链接数)*100,2) '链接4周动销率',
访客数,访客销量,被访问链接数,访客转化率,
曝光量, 点击量, 广告点击率, 广告订单量, 广告转化率, 广告销售额, 广告花费, round((广告花费/(当周销售额-ifnull(退款总额,0)))*100,2) '广告花费率',
round((广告销售额/(当周销售额-ifnull(退款总额,0)))*100,2) '广告业绩占比',广告Acost, 广告cpc, 有曝光的广告投放, 有出单的广告投放,
ifnull(访客数,0)-ifnull(点击量,0) as '自然流量访客数',ifnull(访客销量,0)-ifnull(广告订单量,0) as '自然流量访客销量',
round(((ifnull(访客销量,0)-ifnull(广告订单量,0))/(ifnull(访客数,0)-ifnull(点击量,0)))*100,2) '自然流量访客转化率'
from
(select '健康时尚' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '健康时尚' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '健康时尚' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '健康时尚' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '健康时尚' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*实际为销售小组在线SPU数*/
inner join healthy_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('销售一部','销售二部','销售三部','销售四部'))
/*新品*/
/*所有部门小组新品在线数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where ca.Department  in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品在线数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '健康时尚' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='销售四部'

union
/*PM部门新品在线数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('销售二部','销售三部')
union
/*所有部门新品在线数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品在线数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品在线数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '健康时尚' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='销售四部'

union
/*PM部门重点产品在线数据*/
select '健康时尚' as category,'PM' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品在线数据*/
select '健康时尚' as category,'所有部门' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*其他产品*/
/*所有部门小组其他产品在线数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品在线数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '健康时尚' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='销售四部'
union
/*PM部门其他产品在线数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品在线数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品在线数据*/
select '健康时尚' as category, concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品在线数据*/
select '健康时尚' as category, ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '健康时尚' as category, '销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department='销售四部'
union
/*PM部门所有产品在线数据*/
select '健康时尚' as category, 'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品在线数据*/
select '健康时尚' as category, '所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join healthy_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')
)

/*所有部门小组新品*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '健康时尚' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '健康时尚' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='付款'
inner join healthy_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
/*各部门小组新品退款数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品退款数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品退款数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('销售二部','销售三部')
union
/*所有部门新品退款数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*所有部门小组重点产品退款数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品退款数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品退款数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品退款数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*其他产品*/
/*所有部门小组其他产品退款数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品退款数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品退款数据*/
select '健康时尚' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品退款数据*/
select '健康时尚' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品退款数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品退款数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
group by ca.Department
union
/*PM部门所有产品退款数据*/
select '健康时尚' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品退款数据*/
select '健康时尚' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*访客数据*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join healthy_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '周报'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*访客数、访客销量及访客转化率*/
/*所有部门小组新品访客数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品访客数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品访客数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品访客数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品访客数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品访客数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品访客数据*/
select '健康时尚' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品访客数据*/
select '健康时尚' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品访客数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品访客数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品访客数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品访客数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组所有产品访客数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品访客数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
group by ca.Department
union
/*PM部门所有产品访客数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售二部','销售三部')
union
/*所有部门所有产品访客数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join healthy_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*新品*/
/*各部门小组广告数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品广告数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品广告数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品广告数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品广告数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品广告数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品广告数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品广告数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品广告数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品广告数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品广告数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品广告数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品广告数据*/
select '健康时尚' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品广告数据*/
select '健康时尚' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
group by ca.Department
union
/*PM部门所有产品广告数据*/
select '健康时尚' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品广告数据*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from healthy_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '健康时尚' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数' from ca
union
/*其他产品转为SPU数*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from healthy_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '健康时尚' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')

union
/*其他产品转为SPU贡献业绩*/
select '健康时尚' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
/*新品*/
/*各部门小组新品新增SPU数*/
select '健康时尚' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from healthy_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '健康时尚' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from healthy_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;



select t.category, t.department, t.ReportType, t.周次, t.product_tupe,round(a2.当周销售额-ifnull(a3.退款总额,0),2) '销售额' ,
round(a2.当周利润额-ifnull(a5.广告花费,0)-ifnull(a3.退款总额,0),2) '利润额',round(((当周利润额-ifnull(广告花费,0)-ifnull(退款总额,0))/(当周销售额-ifnull(退款总额,0)))*100,2) as '利润率',
订单数,round((当周销售额-ifnull(退款总额,0))/订单数,2) '客单价',当周销售额,当周利润额,当周利润率,
退款总额,round((退款总额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '退款率',
发货退款金额,round((发货退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '已发货退款率',
无理由退款金额,round((无理由退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '无理由退款率',
总SPU数,在线SPU数,新增SPU数,转为重点产品SPU数,转为重点产品贡献销售额,当周出单SPU数,`4周出单SPU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SPU数,2) '总-单SPU贡献业绩',
round(目前在线链接数/在线SPU数,2) '平均SPU在线链接数',
round((当周出单SPU数/在线SPU数)*100,2) 'SPU当周动销率',
round((`4周出单SPU数`/在线SPU数)*100,2) 'SPU4周动销率',
总SKU数,在线SKU数,新增SKU数,当周出单SKU数,`4周出单SKU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SKU数,2) '总-单SKU贡献业绩',
round(目前在线链接数/在线SKU数,2) '平均SKU在线链接数',
round((当周出单SPU数/在线SKU数)*100,2) 'SKU当周动销率',
round((`4周出单SPU数`/在线SKU数)*100,2) 'SKU4周动销率',
目前在线链接数,当周刊登在线链接数,当周出单链接数,`4周出单链接数`,round((当周出单链接数/目前在线链接数)*100,2) '链接当周动销率',
round((`4周出单链接数`/目前在线链接数)*100,2) '链接4周动销率',
访客数,访客销量,被访问链接数,访客转化率,
曝光量, 点击量, 广告点击率, 广告订单量, 广告转化率, 广告销售额, 广告花费, round((广告花费/(当周销售额-ifnull(退款总额,0)))*100,2) '广告花费率',
round((广告销售额/(当周销售额-ifnull(退款总额,0)))*100,2) '广告业绩占比',广告Acost, 广告cpc, 有曝光的广告投放, 有出单的广告投放,
ifnull(访客数,0)-ifnull(点击量,0) as '自然流量访客数',ifnull(访客销量,0)-ifnull(广告订单量,0) as '自然流量访客销量',
round(((ifnull(访客销量,0)-ifnull(广告订单量,0))/(ifnull(访客数,0)-ifnull(点击量,0)))*100,2) '自然流量访客转化率'
from
(select '其他类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '其他类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '其他类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '其他类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '其他类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*实际为销售小组在线SPU数*/
inner join other_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('销售一部','销售二部','销售三部','销售四部'))
/*新品*/
/*所有部门小组新品在线数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where ca.Department  in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品在线数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '其他类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='销售四部'

union
/*PM部门新品在线数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('销售二部','销售三部')
union
/*所有部门新品在线数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品在线数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品在线数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '其他类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='销售四部'

union
/*PM部门重点产品在线数据*/
select '其他类目' as category,'PM' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品在线数据*/
select '其他类目' as category,'所有部门' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*其他产品*/
/*所有部门小组其他产品在线数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品在线数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '其他类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='销售四部'
union
/*PM部门其他产品在线数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品在线数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品在线数据*/
select '其他类目' as category, concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品在线数据*/
select '其他类目' as category, ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '其他类目' as category, '销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department='销售四部'
union
/*PM部门所有产品在线数据*/
select '其他类目' as category, 'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品在线数据*/
select '其他类目' as category, '所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join other_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')
)

/*所有部门小组新品*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '其他类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '其他类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='付款'
inner join other_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
/*各部门小组新品退款数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品退款数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品退款数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('销售二部','销售三部')
union
/*所有部门新品退款数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*所有部门小组重点产品退款数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品退款数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品退款数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品退款数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*其他产品*/
/*所有部门小组其他产品退款数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品退款数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品退款数据*/
select '其他类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品退款数据*/
select '其他类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品退款数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品退款数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
group by ca.Department
union
/*PM部门所有产品退款数据*/
select '其他类目' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品退款数据*/
select '其他类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*访客数据*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join other_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '周报'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*访客数、访客销量及访客转化率*/
/*所有部门小组新品访客数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品访客数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品访客数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品访客数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品访客数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品访客数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品访客数据*/
select '其他类目' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品访客数据*/
select '其他类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品访客数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品访客数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品访客数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品访客数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组所有产品访客数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品访客数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
group by ca.Department
union
/*PM部门所有产品访客数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售二部','销售三部')
union
/*所有部门所有产品访客数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join other_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*新品*/
/*各部门小组广告数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品广告数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品广告数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品广告数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品广告数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品广告数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品广告数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品广告数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品广告数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品广告数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品广告数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品广告数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品广告数据*/
select '其他类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品广告数据*/
select '其他类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
group by ca.Department
union
/*PM部门所有产品广告数据*/
select '其他类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品广告数据*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from other_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '其他类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数' from ca
union
/*其他产品转为SPU数*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from other_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '其他类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')

union
/*其他产品转为SPU贡献业绩*/
select '其他类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
/*新品*/
/*各部门小组新品新增SPU数*/
select '其他类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from other_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '其他类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from other_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;



select t.category, t.department, t.ReportType, t.周次, t.product_tupe,round(a2.当周销售额-ifnull(a3.退款总额,0),2) '销售额' ,
round(a2.当周利润额-ifnull(a5.广告花费,0)-ifnull(a3.退款总额,0),2) '利润额',round(((当周利润额-ifnull(广告花费,0)-ifnull(退款总额,0))/(当周销售额-ifnull(退款总额,0)))*100,2) as '利润率',
订单数,round((当周销售额-ifnull(退款总额,0))/订单数,2) '客单价',当周销售额,当周利润额,当周利润率,
退款总额,round((退款总额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '退款率',
发货退款金额,round((发货退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '已发货退款率',
无理由退款金额,round((无理由退款金额/(ifnull(退款总额,0)+(当周销售额-ifnull(退款总额,0))))*100,2) as '无理由退款率',
总SPU数,在线SPU数,新增SPU数,转为重点产品SPU数,转为重点产品贡献销售额,当周出单SPU数,`4周出单SPU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SPU数,2) '总-单SPU贡献业绩',
round(目前在线链接数/在线SPU数,2) '平均SPU在线链接数',
round((当周出单SPU数/在线SPU数)*100,2) 'SPU当周动销率',
round((`4周出单SPU数`/在线SPU数)*100,2) 'SPU4周动销率',
总SKU数,在线SKU数,新增SKU数,当周出单SKU数,`4周出单SKU数`,
round((当周销售额-ifnull(退款总额,0))/当周出单SKU数,2) '总-单SKU贡献业绩',
round(目前在线链接数/在线SKU数,2) '平均SKU在线链接数',
round((当周出单SPU数/在线SKU数)*100,2) 'SKU当周动销率',
round((`4周出单SPU数`/在线SKU数)*100,2) 'SKU4周动销率',
目前在线链接数,当周刊登在线链接数,当周出单链接数,`4周出单链接数`,round((当周出单链接数/目前在线链接数)*100,2) '链接当周动销率',
round((`4周出单链接数`/目前在线链接数)*100,2) '链接4周动销率',
访客数,访客销量,被访问链接数,访客转化率,
曝光量, 点击量, 广告点击率, 广告订单量, 广告转化率, 广告销售额, 广告花费, round((广告花费/(当周销售额-ifnull(退款总额,0)))*100,2) '广告花费率',
round((广告销售额/(当周销售额-ifnull(退款总额,0)))*100,2) '广告业绩占比',广告Acost, 广告cpc, 有曝光的广告投放, 有出单的广告投放,
ifnull(访客数,0)-ifnull(点击量,0) as '自然流量访客数',ifnull(访客销量,0)-ifnull(广告订单量,0) as '自然流量访客销量',
round(((ifnull(访客销量,0)-ifnull(广告订单量,0))/(ifnull(访客数,0)-ifnull(点击量,0)))*100,2) '自然流量访客转化率'
from
(select '所有类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '所有类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '所有类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '所有类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,concat(Department,'-',NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部')
group by concat(Department,'-',NodePathName)
union
select '所有类目' as category,Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe
from mysql_store
where Department  in ('销售一部','销售二部','销售三部','销售四部')
group by Department
) t
left join
(
/*目前在线SPU-SKU数-目前累计SPU-SKU数*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*实际为销售小组在线SPU数*/
inner join proall_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('销售一部','销售二部','销售三部','销售四部'))
/*新品*/
/*所有部门小组新品在线数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where ca.Department  in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品在线数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '所有类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='销售四部'

union
/*PM部门新品在线数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('销售二部','销售三部')
union
/*所有部门新品在线数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when 1=1 then SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SPU end)'在线SPU数',
count(distinct case when 1=1 then SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品在线数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品在线数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '所有类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='销售四部'

union
/*PM部门重点产品在线数据*/
select '所有类目' as category,'PM' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品在线数据*/
select '所有类目' as category,'所有部门' as  Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*其他产品*/
/*所有部门小组其他产品在线数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品在线数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '所有类目' as category,'销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='销售四部'
union
/*PM部门其他产品在线数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品在线数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品在线数据*/
select '所有类目' as category, concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品在线数据*/
select '所有类目' as category, ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in  ('销售一部','销售二部','销售三部')
group by ca.Department
union
select '所有类目' as category, '销售四部' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department='销售四部'
union
/*PM部门所有产品在线数据*/
select '所有类目' as category, 'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品在线数据*/
select '所有类目' as category, '所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '总SPU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SPU end)'在线SPU数',
count(distinct case when 1=1 then ca.SKU end) '总SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then ca.SKU end)'在线SKU数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'then concat(ShopCode,'-',SellerSKU) end)'目前在线链接数',
count(distinct  case when ListingStatus=1 and ShopStatus='正常'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'当周刊登在线链接数' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join proall_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')
)

/*所有部门小组新品*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '所有类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '所有类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*退款数据(目前数据源存在问题 1、订单表中存在组合SKU，但是退款表中只有一笔订单 2、一笔订单存在两次退款)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='付款'
inner join proall_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*各部门退款数据*/
/*各部门小组新品退款数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品退款数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品退款数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('销售二部','销售三部')
union
/*所有部门新品退款数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*PM部门新品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*所有部门小组重点产品退款数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品退款数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品退款数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
/*所有部门重点产品退款数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',/*所有部门重点产品退款数据*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*其他产品*/
/*所有部门小组其他产品退款数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品退款数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品退款数据*/
select '所有类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品退款数据*/
select '所有类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品退款数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品退款数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
group by ca.Department
union
/*PM部门所有产品退款数据*/
select '所有类目' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品退款数据*/
select '所有类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(ca.RefundUSDPrice) '退款总额',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '发货退款金额',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('客户个人原因', '无理由取消订单') then ca.RefundUSDPrice end) '无理由退款金额' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*访客数据*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join proall_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '周报'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*访客数、访客销量及访客转化率*/
/*所有部门小组新品访客数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品访客数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品访客数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品访客数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品访客数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品访客数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品访客数据*/
select '所有类目' as category,'PM'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品访客数据*/
select '所有类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品访客数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品访客数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品访客数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售二部','销售三部')
union
/*所有部门其他产品访客数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组所有产品访客数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品访客数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
group by ca.Department
union
/*PM部门所有产品访客数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca
where ca.Department in ('销售二部','销售三部')
union
/*所有部门所有产品访客数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '访客数', sum(OrderedCount) '访客销量',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '访客转化率',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'被访问链接数' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join proall_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*新品*/
/*各部门小组广告数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品广告数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM部门新品广告数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品广告数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*重点产品*/
/*各部门小组重点产品广告数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门重点产品广告数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM部门重点产品广告数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('销售二部','销售三部')
union
/*所有部门重点产品广告数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*其他产品*/
/*各部门小组其他产品广告数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品广告数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品广告数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*所有部门其他产品广告数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*各部门小组所有产品广告数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品广告数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
group by ca.Department
union
/*PM部门所有产品广告数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca
where Department in ('销售二部','销售三部')
union
/*所有部门所有产品广告数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','-' as product_tupe,
sum(Exposure) as '曝光量',sum(Clicks) '点击量',round((sum(Clicks)/sum(Exposure))*100,2)  '广告点击率',sum(TotalSale7DayUnit) '广告订单量',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '广告转化率',sum(TotalSale7Day) '广告销售额',sum(Spend) '广告花费',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '广告Acost',round((sum(Spend)/sum(Clicks)),3) '广告cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有曝光的广告投放',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '有出单的广告投放'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from proall_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '所有类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数' from ca
union
/*其他产品转为SPU数*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
count(distinct ca.SPU) '转为重点产品SPU数'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*转为重点产品贡献业绩*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from proall_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*新品*/
/*所有部门新品转重点产品*/
select '所有类目' as category,'所有部门'as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','重点产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')

union
/*其他产品转为SPU贡献业绩*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','其他产品' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) '转为重点产品贡献销售额' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = '未发货' and OrderStatus = '作废'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '付款')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*当周新增SPU-SKU数*/
/*新品*/
/*各部门小组新品新增SPU数*/
select '所有类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from proall_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '所有类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-12-26') as '周次','新品' as product_tupe,
count(distinct SPU) '新增SPU数',count(distinct sku) '新增SKU数' from proall_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;