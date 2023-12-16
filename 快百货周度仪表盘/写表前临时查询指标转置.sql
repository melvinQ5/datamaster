with
t0 as (
select  round(count(distinct case when order_cnt >= 1 then part.spu end )/count(distinct entire.Spu),4) `终审14天1单SPU动销率`
from ( -- 开发SPU
	select wp.Spu
	from import_data.wt_products wp
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU
	) entire
left join ( -- 出单SKU
	select Product_SPU as spu ,count( distinct PlatOrderNumber) order_cnt
	from (
        select wo.*
        from import_data.wt_orderdetails wo
        join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU
	) part on entire.Spu = part.spu
)

,t1 as (
select  round(count(distinct case when order_cnt >= 3 then part.spu end )/count(distinct entire.Spu),4) `终审30天3单SPU动销率`
	, round(count(distinct case when order_cnt >= 6 then part.spu end )/count(distinct entire.Spu),4) `终审30天6单SPU动销率`
from ( -- 开发SPU
	select wp.Spu
	from import_data.wt_products wp
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU
	) entire
left join ( -- 出单SKU
	select Product_SPU as spu ,count( distinct PlatOrderNumber) order_cnt
	from (
        select wo.*
        from import_data.wt_orderdetails wo
        join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
            and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU
	) part on entire.Spu = part.spu
)


, t2 as  (
select count( distinct spu ) `终审距今超2年SPU数`
from import_data.wt_products wp
where  ProjectTeam = '快百货' and wp.ProductStatus != 2 and IsDeleted = 0 and date_add( DevelopLastAuditTime,interval -8 hour ) < date_add('${NextStartDay}',interval -2 year)
)


, t3 as (
select
    round(count( distinct  case when prod_level regexp '旺款' and list_level regexp 'S|A' then concat(asin,site) end ) / count(distinct case when prod_level regexp '旺款' then spu end ) ,2) `旺款平均SA链接数`
    , round(count( distinct case when prod_level regexp '爆款' and list_level regexp 'S|A' then concat(asin,site) end ) / count(distinct case when prod_level regexp '爆款' then spu end ) ,2) `爆款平均SA链接数`
from dep_kbh_listing_level where prod_level regexp '爆款|旺款' and FirstDay = '${StartDay}'
)

, t4 as (
select
    round(count(distinct wp.sku ) / count(distinct wp.spu ) ,2) `爆旺款子体比`
    , round(count(distinct case when prod_level regexp '爆款' then wp.sku end ) / count(distinct  case when prod_level regexp '爆款'  then wp.spu end ) ,2) `爆款子体比`
    , round(count(distinct case when prod_level regexp '旺款' then wp.sku end ) / count(distinct  case when prod_level regexp '旺款'  then wp.spu end ) ,2) `旺款子体比`
from import_data.dep_kbh_product_level dkpl
join wt_products wp on dkpl.spu = wp.spu
      where Department = '快百货'  and prod_level regexp '爆款|旺款'
        and FirstDay = '${StartDay}'
)

,t5 as (
select
    round(近30天动销SPU数 / 产品库SPU数 ,4 ) as 产品库SPU近30天动销率
    , round(近30天销售额 / 产品库SPU数 ,2 ) as 产品库SPU单产
from (	select count( distinct wp.spu ) `产品库SPU数`
from import_data.wt_products wp
where  ProjectTeam = '快百货' and wp.ProductStatus != 2 and IsDeleted = 0 and DevelopLastAuditTime is not null
    ) a
join (
select
    count(distinct Product_SPU) 近30天动销SPU数
    ,round(sum((totalgross)/ExchangeUSD),4)  近30天销售额
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州|商品组' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '其他'  and asin <>''  and ms.department regexp '快'
) b on 1=1
)

,t6 as (
select
    本周爆旺款数 - 上周爆旺款数 as 爆旺款SPU数环比
from (
select count(distinct spu )  `本周爆旺款数`
from import_data.dep_kbh_product_level dkpl
      where Department = '快百货'  and prod_level regexp '爆款|旺款'
        and FirstDay = '${StartDay}'
    ) a
join (
select count(distinct spu )  `上周爆旺款数`
from import_data.dep_kbh_product_level dkpl
      where Department = '快百货'  and prod_level regexp '爆款|旺款'
        and FirstDay =  date_add( '${StartDay}' ,interval -1 week )
) b on 1=1
)

,t7 as (
select
    round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  爆旺款留存率
    ,count(distinct  w1.spu)  爆旺款留存数
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -7 day )) and prod_level regexp '旺款|爆款' and Department='快百货' group by spu ) w0
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay =  '${StartDay}'  and prod_level regexp '旺款|爆款' and Department='快百货' group by spu ) w1
    on w0.SPU = w1.SPU
)

,t8 as (
select count(distinct  a.spu) 老品爆旺款新增数
from (
select spu
from import_data.dep_kbh_product_level dkpl where Department = '快百货' and prod_level regexp '爆款|旺款'
        and FirstDay = '${StartDay}' and isnew= '老品'
    ) a
left  join (
select spu
from import_data.dep_kbh_product_level dkpl where Department = '快百货'  and prod_level regexp '爆款|旺款'
        and FirstDay =  date_add( '${StartDay}' ,interval -1 week )
) b on a.spu =b.spu
where b.spu is null
)




,t9 as (
select round(a_gen_in2d/b_gen_in2d,4) `爆旺款2天生包率`
	,round(a_deliv_in5d/b_deliv_in5d,4) `爆旺款订单5天发货率`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	from
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款'
		join ( select spu from import_data.dep_kbh_product_level  where Department = '快百货'  and prod_level regexp '爆款|旺款' group by spu ) dkpl on dkpl.SPU = wo.Product_SPU
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1
)

,t10 as (
select  count(distinct PlatOrderNumber ) `爆旺款10天未发货订单数`
from import_data.daily_WeightOrders wo
join ( select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	 from import_data.mysql_store where department regexp '快')  ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1)=ms.Code and OrderStatus <> '作废'
join ( select  dkpl.spu ,boxsku  from import_data.dep_kbh_product_level dkpl join wt_products wp on dkpl.spu = wp.spu
      where Department = '快百货'  and prod_level regexp '爆款|旺款' group by dkpl.spu ,boxsku  ) dkpl on dkpl.BoxSku = wo.boxsku
where wo.CreateDate = '${NextStartDay}' and PayTime < date_add('${NextStartDay}',interval -10 day)
)

,t11 as (
select
    ifnull(round(B.RefundUSDPrice / (`TopSaleSpuAmount` + `HotSaleSpuAmount`), 4), 0) as 爆旺款退款率
from ads_ag_kbh_report_weekly A
join (
	select '快百货' as department
	     , round( abs(sum(RefundAmount/ExchangeUSD)) / sum(sales_in30d) ,4)  RefundUSDPrice
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
    join ( select  dkpl.spu ,boxsku ,sales_in30d from import_data.dep_kbh_product_level dkpl join wt_products wp on dkpl.spu = wp.spu
      where  FirstDay= '${StartDay}' and Department = '快百货'  and prod_level regexp '爆款|旺款' group by dkpl.spu ,boxsku,sales_in30d  ) dkpl on dkpl.BoxSku = wo.boxsku
    where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
        and TransactionType = '退款'  and asin <>''  and ms.department regexp '快'
	) B on A.Team = B.Department and A.FirstDay =  '${StartDay}'
)

,t12 as (
select count(distinct dw.BoxSku) 库龄超180天SKU数
    ,round(sum(InventoryAgeAmount270 + InventoryAgeAmount365 + InventoryAgeAmountOver)/10000) as 库龄超180天库存金额 -- 万人民币
from daily_WarehouseInventory dw
join wt_products w on dw.BoxSku = w.BoxSku and w.ProjectTeam='快百货' and dw.CreatedTime = date_add( '${NextStartDay}' , interval -1 day )
    and (InventoryAge270 + InventoryAge365 + InventoryAgeOver) > 0
)

,t13 as (
select count(distinct spu ) 当月终审SPU数
from wt_products where date_add( DevelopLastAuditTime,interval -8 hour ) >= '2023-07-01' and date_add( DevelopLastAuditTime,interval -8 hour )  < '${NextStartDay}' and ProjectTeam='快百货'
)


,t15 as (  -- 月度计算指标
select
    ifnull(round(B.SA_monthly_sales / A.TotalGross, 4), 0) as SA链接本期销售额占比_MTD
from ads_ag_kbh_report_weekly A
join (
	select '快百货' as department , abs(round(sum((TotalGross)/ExchangeUSD),4))  SA_monthly_sales
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp '泉州|商品组' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
    join ( select  asin , site  from import_data.dep_kbh_listing_level dkpl
      where  list_level regexp 'S|A' group by asin , site ) dkpl on dkpl.asin = wo.asin and dkpl.site = wo.site
    where PayTime >= '2023-07-01' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
        and TransactionType <> '其他'  and wo.asin <>''  and ms.department regexp '快'
	) B on A.Team = B.Department and A.FirstDay =  '${StartDay}' and ReportType='月报'
)



,t16 as (
select round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	,round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	from
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1
)




select '快百货' as 团队 ,终审14天1单SPU动销率 ,终审30天3单SPU动销率 , 终审30天6单SPU动销率 , 终审距今超2年SPU数 , 旺款平均SA链接数 , 爆款平均SA链接数
       , 爆旺款子体比 ,爆款子体比 ,旺款子体比 , 产品库SPU近30天动销率 ,产品库SPU单产  ,爆旺款SPU数环比 ,爆旺款留存率 ,爆旺款留存数 ,老品爆旺款新增数
        ,爆旺款2天生包率 ,爆旺款订单5天发货率 ,订单5天发货率 ,爆旺款10天未发货订单数 ,爆旺款退款率 ,库龄超180天SKU数 ,库龄超180天库存金额 ,当月终审SPU数
     -- ,SA链接本期销售额占比_MTD
from t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10 ,t11 ,t12 ,t13,t16



