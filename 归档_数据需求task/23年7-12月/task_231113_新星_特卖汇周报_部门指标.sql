/*特卖汇*/
with sheet as (
                   with sale as(
                   with orderdetails as(select TotalGross,TotalProfit,PlatOrderNumber,Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,pp.Spu,s.* from import_data.wt_orderdetails ord   /*订单表（订单数据）*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join mysql_store s
                   on ord.shopcode=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0)
                select  '特卖汇' as department,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '税后销售额' ,
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'作废' and TotalGross>0 then PlatOrderNumber end) '订单数',
                round(sum(case when TransactionType<>'其他' then (TotalGross-RefundAmount)/ExchangeUSD end),2) '总ASIN贡献业绩',
                count(distinct case when TransactionType<>'其他' then concat(Asin,Site) end ) '出单总ASIN数' from orderdetails)
/*订单数据源*/
,ods as(select '特卖汇' as department,count(DISTINCT CASE when PayTime>='${StartDay}'
           and PayTime<'${EndDay}'  and  OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end) '作废订单数'
           ,round(count(distinct case when  PayTime>=date_add('${EndDay}',interval -27 day) and PayTime<date_add('${EndDay}',interval -20 day) and OrderStatus <> '作废' then PlatOrderNumber  end )/7,0) '7天前日均订单数'
           ,round(count(DISTINCT CASE when PayTime>='${StartDay}'
           and PayTime<'${EndDay}' and  OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`  from import_data.ods_orderdetails as ods   /*订单表（订单数据）*/
           left join wt_products pp
           on ods.BoxSku=pp.BoxSku
           inner join mysql_store s
           on ods.ShopIrobotId=s.Code/*部门维度*/
           and s.Department='特卖汇'
           and ods.IsDeleted=0)

/*退款数据*/
,ref as (select '特卖汇' as department,sum(RefundUSDPrice) '退款金额',sum(case when RefundReason1='采购原因' then  RefundUSDPrice end) '采购原因退款金额',
         sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '非客户原因退款金额'  from import_data.daily_RefundOrders rf
           inner join mysql_store s
           on rf.OrderSource=s.Code /*部门维度*/
           and s.Department='特卖汇'
           and RefundStatus='已退款'
           and RefundDate>='${StartDay}'/*时间维度*/
           and RefundDate<'${EndDay}')

/*访客数据*/
,visitor as (select t1.department,t1.ASIN访客数,访客数, 访客销量, round(访客数/t1.ASIN访客数,4) '购物车赢得率' from
(select '特卖汇' as department,sum(a.maxtotal) 'ASIN访客数' from
(select lm.ChildAsin,lm.StoreSite,max(TotalCount) 'maxtotal' from import_data.ListingManage lm
          inner join mysql_store s
          on lm.ShopCode=s.Code /*部门维度*/
          and s.Department='特卖汇'
          and ReportType='周报' /*时间维度*/
          and Monday='${StartDay}'
          inner join(select t1.ASIN,t1.code from
                    (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                    inner join  mysql_store s
                    on al.ShopCode=s.Code
                    where Department='特卖汇'
                    and ShopStatus='正常'
                    and ListingStatus=1
                    group by ASIN,right(ShopCode,2)) as t1
                    inner join
                    (select Asin,Site from import_data.erp_gather_gather_asin
                    where IsDeleted=0
                    group by Asin, Site) t2
                    on t1.ASIN=t2.Asin
                    and t1.code=t2.Site) t4
          on lm.ChildAsin=t4.ASIN
          and right(lm.ShopCode,2)=t4.code
          group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite) a) t1
left join

(select '特卖汇' as department,round(sum(TotalCount*FeaturedOfferPercent/100),0) '访客数',sum(OrderedCount) '访客销量' from import_data.ListingManage lm
          inner join mysql_store s
          on lm.ShopCode=s.Code /*部门维度*/
          and s.Department='特卖汇'
          and ReportType='周报' /*时间维度*/
          and Monday='${StartDay}'
          inner join(select t1.ASIN,t1.code from
                    (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                    inner join mysql_store s
                    on al.ShopCode=s.Code
                    where Department='特卖汇'
                    and ShopStatus='正常'
                    and ListingStatus=1
                    group by ASIN,right(ShopCode,2)) as t1
                    inner join
                    (select Asin,Site from import_data.erp_gather_gather_asin
                    where IsDeleted=0
                    group by Asin, Site) t2
                    on t1.ASIN=t2.Asin
                    and t1.code=t2.Site) t4
          on lm.ChildAsin=t4.ASIN
          and right(lm.ShopCode,2)=t4.code) t2
on t1.department=t2.department
/*邮件数*/
) ,em as (select '特卖汇' as department,round(count(*)/datediff('${EndDay}','${StartDay}'),1) '日均邮件数' from daily_Email em
            inner join mysql_store s
            on em.Src=s.Code
            and s.Department='特卖汇'
            where ReplyTime>='${StartDay}'
            and ReplyTime<'${EndDay}'
/*审核产品*/
),tort as(select '特卖汇' as department,count(*) '审核总SKU数',
       count(case when GatherProductStatus>=7 then id end ) '审核通过SKU数',
       round((count(*)-count(case when GatherProductStatus>=7 then id end ))/count(*),4) '审核通过率'  from erp_gather_gather_amazon_products
       where left(TortAuditTime,10)>='${StartDay}'
       and left(TortAuditTime,10)<'${EndDay}')

          select  '特卖汇' as department,税后销售额, expend as '总支出',退款金额,round(税后销售额-退款金额,2) '销售额', round(税后销售额+expend-退款金额) '利润额',
          round((税后销售额+expend-退款金额)/(税后销售额-退款金额),4) '利润率',visitor.访客数,visitor.访客销量,visitor.ASIN访客数,visitor.购物车赢得率,
          采购原因退款金额,round(采购原因退款金额/税后销售额,4) '采购原因退款率', 非客户原因退款金额,round(非客户原因退款金额/税后销售额,4) '非客户原因退款率',
          订单数,ods.作废订单数,ods.作废订单率,`7天前日均订单数`,日均邮件数,审核总SKU数, 审核通过SKU数, 审核通过率  from sale
          left join ref
          on sale.department=ref.department
          left join visitor
          on sale.department=visitor.department
          left join ods
          on sale.department=ods.department
          left join em
          on sale.department=em.department
          left join tort
          on sale.department=tort.department

/*TOPASIN*/
),top1 as
    ( select a.department, TOP1链接贡献业绩,b.TOP1ASIN购物车赢得率 from
        (select '特卖汇' as department, round(sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD),2)  'TOP1链接贡献业绩'  from ods_orderdetails od
            inner join
                    (select t2.Asin, t2.Site, team, Name from
                    (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1
                    inner join (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*找出更改负责人*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                        on ap.AssignUserName=s.Name) as t2
                    on t1.Asin=t2.Asin
                    and t1.Site=t2.Site) t3
            on right(od.ShopIrobotId,2)=t3.Site
            and od.Asin=t3.Asin
            inner join  mysql_store s
            on od.ShopIrobotId=s.Code
            and s.Department='特卖汇'
            where IsDeleted=0
            and TransactionType='付款'
            and OrderStatus<>'作废'
            and PayTime>='${StartDay}'
            and PayTime<'${EndDay}'
            ) a
    left join (select '特卖汇' as department,round(t2.店铺访客数/t1.totalcount,4) 'TOP1asin购物车赢得率' from
            (select '特卖汇' as department,sum(TotalCount2) 'totalcount' from
            (select StoreSite site, childasin asin, max(TotalCount) TotalCount2  from ListingManage lm
            inner join (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1  /*注意修改 TOPASIN在TOPASIN表中*/
            on lm.ChildAsin=t1.ASIN
            and lm.StoreSite=t1.Site
            inner join mysql_store s
            on lm.ShopCode=s.Code
            and s.Department='特卖汇'
            where ReportType='周报'
            and Monday='${StartDay}'
            group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite) a
             ) t1
            left join
            (select '特卖汇' as department,round(sum(TotalCount*FeaturedOfferPercent/100),1) '店铺访客数' from ListingManage lm
            inner join (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1
            on lm.ChildAsin=t1.ASIN
            and lm.StoreSite=t1.Site
            inner join mysql_store s
            on lm.ShopCode=s.Code
            and s.Department='特卖汇'
            where ReportType='周报'
            and Monday='${StartDay}') t2
            on t1.department=t2.department
                ) b
                on a.department=b.department)
/*链接数据*/
,ls as (select t1.department, 新ASIN贡献业绩, 新出单ASIN数,总ASIN贡献业绩,出单总ASIN数,新上架ASIN数, 总在线ASIN数,总删除ASIN数,t4.提报ASIN数 from
            (select  '特卖汇' as department,sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD) '总ASIN贡献业绩',
                   count(distinct concat(user.Asin,right(ShopIrobotId,2))) '出单总ASIN数',
                   sum(case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then  (TotalGross+TaxGross-RefundAmount)/ExchangeUSD  end ) '新ASIN贡献业绩',/*跟随状态(8:待上架,9:已上架,10:下架)*/
                   count(distinct case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then concat(user.Asin,right(ShopIrobotId,2)) end) '新出单ASIN数' from import_data.ods_orderdetails ord   /*订单表（订单数据）*/
                   inner join (select eg.Asin,eg.Site,eg.CreationTime,eg.FollowUpStatus,eg.FirArrivalTime,left(s.NodePathName,3) as dep,right(s.NodePathName,7) as team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id  /*找出更改负责人*/
                                inner join (
                                SELECT d.NodePathName,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                on ap.AssignUserName=s.Name) as user
                                on ord.Asin=user.Asin
                                and right(ord.ShopIrobotId,2)=user.Site
                   inner join mysql_store s
                   on ord.ShopIrobotId=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and TransactionType<>'退款'
                   and OrderStatus<>'作废'   /*剔除作废订单、未减去退款税前销售额*/
                   and ord.IsDeleted=0
                   ) t1
            left join  (select '特卖汇' as team1,
                         count(distinct concat(t1.ASIN,t1.code)) '总在线ASIN数'    from
                        (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                        inner join mysql_store s
                        on al.ShopCode=s.Code
                        where Department='特卖汇'
                        and ShopStatus='正常'
                        and ListingStatus=1
                        group by ASIN,right(ShopCode,2)) as t1
                        inner join
                        (select Asin,Site,CreationTime,FollowUpStatus,FirArrivalTime from import_data.erp_gather_gather_asin
                        where IsDeleted=0) t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site) t3
                on t1.department=t3.team1
                left join  (select '特卖汇' as team1,
                         count(distinct concat(t1.ASIN,t1.code)) '总删除ASIN数'    from
                        (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing_delete al
                        inner join mysql_store s
                        on al.ShopCode=s.Code
                        where Department='特卖汇'
                        group by ASIN,right(ShopCode,2)) as t1
                        inner join
                        (select Asin,Site,CreationTime,FollowUpStatus,FirArrivalTime from import_data.erp_gather_gather_asin
                        where IsDeleted=0
                        and FirArrivalTime>='${StartDay}'
                        and FirArrivalTime<'${EndDay}') t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site) t5
                on t1.department=t5.team1
                left join (select '特卖汇' as team3,count(case when FollowUpStatus=9 then concat(Asin,Site) end) '新上架ASIN数'
                       from import_data.erp_gather_gather_asin
                        where FirArrivalTime>='${StartDay}'
                        and FirArrivalTime<'${EndDay}') s
                        on t1.department=s.team3
                left join (select '特卖汇' as team2,count(distinct concat(Asin,Site)) '提报ASIN数'  from import_data.erp_gather_gather_asin
                        where CreationTime>='${StartDay}'
                        and CreationTime<'${EndDay}') t4
                        on t1.department=t4.team2

/*交付*/
/*准时发货率*/
),deliver as (select c1.department, 准时发货率,c2.准时妥投率,采购产品金额, 采购运费, 采购单数, 日均采购单数,
              c4.采购3天到货率,c5.平均采购收货天数,`2天生包率`, 订单5天发货率, 订单7天发货率,c7.`24小时发货率`,c8.`24小时收货率`
              ,本地仓库存资金占用, 库存周转天数, 发货订单采购金额, 在仓sku件数, 在仓sku数, 在途产品采购金额, 在途产品采购运费, 在仓产品金额,`10天未发订单数`, 库存产品动销率,
              ODR超标店铺数, VTR超标店铺数, LSR超标店铺数, CR超标店铺数,n5.staff_count       from
              (select tb.department,round(A_cnt/B_cnt,4) `准时发货率`
            from
                ( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, B_cnt
                FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
                    from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
                    where PayTime < date_add('${EndDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
                      and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0
                     group by grouping sets ((),(department))
                    ) tmp3 -- 付款时间推至4天 留够发货时间
                ) tb
            LEFT JOIN
            ( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, A_cnt
                FROM (
                    select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
                    from (
                        select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
                            end as latest_WeightTime -- 处理工作日
                            ,paytime ,DAYOFWEEK(OrderCountry_paytime)
                            ,PlatOrderNumber ,department
                        from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
                            ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department
                            from import_data.ods_orderdetails od
                            join  mysql_store s
                            on od.ShopIrobotId =s.Code  and s.Department='特卖汇' and isdeleted = 0
                            left join
                                (SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js
                                on js.code=right(od.ShopIrobotId ,2)
                            where od.IsDeleted =0 and PayTime < date_add('${EndDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
                                and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0
                            ) tmp
                        ) dod
                    left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber
                    where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
                    group by grouping sets ((),(department))
                    ) tmp2
              ) ta
              ON ta.department =tb.department
            ) c1


-- 准时交货/妥投率
left join (
select CASE WHEN department IS NULL THEN '公司' ELSE department END AS department
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `准时妥投率`
from (
	SELECT department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	 	join mysql_store s
        on eaaspc.ShopCode =s.Code and s.Department='特卖汇'
		where AmazonShopHealthStatus != 4
			and left(CreationTime,10) = left(DATE_ADD('${EndDay}', interval -1 day),10) -- 每天凌晨0点后跑数
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 30 -- 统计期
	group by grouping sets ((),(department))
) tmp2
) c2
on c1.department=c2.department
-- 物流三天上网率（轨迹表按发货时间 貌似只跑到0128）
left join
-- 采购单数 采购金额 采购运费
(
select case when department IS NULL THEN '公司' ELSE department END AS department
	,round(sum(Price - DiscountedPrice)) `采购产品金额` , round(sum(SkuFreight)) `采购运费`	,count(distinct OrderNumber) `采购单数`
	,round(count(distinct OrderNumber)/datediff('${EndDay}','${StartDay}')) `日均采购单数`
from wt_purchaseorder wp
join (select BoxSku , projectteam as department  from import_data.wt_products where IsDeleted = 0 ) wp2
	on wp.BoxSku =wp2.BoxSku
where ordertime  <  '${EndDay}'  and ordertime >= '${StartDay}' and WarehouseName = '东莞仓'
group by grouping sets ((),(department))
)
c3
on c1.department=c3.department

-- 采购5天到货率
left join (
select
	case when department IS NULL THEN '公司' ELSE department END AS department
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购3天到货率`
from ( -- 采购宽表
	select
		OrderNumber,department
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
		end as in5days_rev_numb -- 满足5天到货的下单号
		, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
	from import_data.wt_purchaseorder wp
	inner join (select BoxSku ,ProjectTeam as department from erp_product_products
	            where IsMatrix=0) pp
	on wp.BoxSku=pp.BoxSku

	where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${EndDay}',interval -5 day)  -- 多获取10天数据，以便计算各种指标
		and WarehouseName = '东莞仓'
	) tmp
group by grouping sets ((),(department))
)
c4
on c1.department=c4.department

left join
-- 采购平均到货天数
(
select case when department IS NULL THEN '公司' ELSE department END AS department
	, sum(rev_days)/count(DISTINCT OrderNumber) `平均采购收货天数`
from (
	select OrderNumber ,department ,rev_days
	from (
		select
			dpo.OrderNumber ,department
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
				when scantime is null and instockquantity > 0 and CompleteTime is not null
				then timestampdiff(second, ordertime, CompleteTime)/86400  -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
				end as rev_days
		from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev  pr on dpo.OrderNumber = pr.OrderNumber
		left join (select BoxSku ,ProjectTeam as department from wt_products
			      ) tmp on dpo.BoxSku = tmp.BoxSku
		where CompleteTime < '${EndDay}' and CompleteTime >= '${StartDay}' and WarehouseName = '东莞仓'
		) po_pre
	where rev_days is not null
	group by department ,OrderNumber ,rev_days
	) tmp
group by grouping sets ((department))
)
c5
on c1.department=c5.department

left join
-- 两天生包率 订单5天发货率 订单7天发货率
(
select department
	, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from ( SELECT department
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from
		( select PlatOrderNumber, OrderNumber, BoxSku , PayTime ,s.department
		from import_data.ods_orderdetails oo
		join mysql_store s
        on oo.ShopIrobotId = s.Code and oo.IsDeleted = 0 and s.Department='特卖汇'
		where PayTime >= date_add('${StartDay}',INTERVAL -10 DAY) and PayTime < '${EndDay}'
			and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  -- 起始时间再往前预留10天的数据，便于兼顾多指标计算
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber AND od_pre.boxsku =pd.boxsku
	group by department
	) tmp1
union
select NodePathName
	, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from ( SELECT NodePathName
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from
		( select PlatOrderNumber, OrderNumber, BoxSku , PayTime ,s.NodePathName
		from import_data.ods_orderdetails oo
		join mysql_store s
        on oo.ShopIrobotId = s.Code and oo.IsDeleted = 0 and s.Department='特卖汇'
		where PayTime >= date_add('${StartDay}',INTERVAL -10 DAY) and PayTime < '${EndDay}'
			and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  -- 起始时间再往前预留10天的数据，便于兼顾多指标计算
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber AND od_pre.boxsku =pd.boxsku
	group by NodePathName
	) tmp1
)
c6
on c1.department=c6.Department
left join
-- 24小时发货率
(
select
	case when department is null THEN '公司' ELSE department END AS department
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from import_data.daily_PackageDetail dpd
join import_data.ods_orderdetails dod
	on dpd.OrderNumber = dod.OrderNumber
		and dpd.CreatedTime < '${EndDay}'
		and dpd.CreatedTime >= '${StartDay}'
        and dod.IsDeleted=0
join mysql_store s
on s.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1) and s.Department='特卖汇'
group by grouping sets ((),(department))
)
c7
on c1.department=c7.department
left join
-- 24小时收货率
(
select
	case when department is null THEN '公司' ELSE department END AS department
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `24小时收货率`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join (select BoxSku ,ProjectTeam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where date_add(scantime, 1) < '${EndDay}'  and date_add(scantime, 1) >= '${StartDay}'
	 and b.WarehouseName = '东莞仓'
group by grouping sets ((),(department))
)
c8
on c1.department=c8.department
left join
-- 库存资金占用(两个参数)
(
select a.department
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`),0) `本地仓库存资金占用`
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${EndDay}','${StartDay}'),1) `库存周转天数`
	,`发货订单采购金额`
	,`在仓sku件数`,`在仓sku数`
	,`在途产品采购金额`, `在途产品采购运费` , `在仓产品金额`
from
(
select case when department is null THEN '公司' ELSE department END AS department
	, sum(Price - DiscountedPrice) `在途产品采购金额` , ifnull(sum(SkuFreight),0) `在途产品采购运费`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp
	join (select BoxSku ,ProjectTeam  department from wt_products
		     ) tmp on wp.BoxSku = tmp.BoxSku
	where ordertime < '${EndDay}'
		and isOnWay = '是' and WarehouseName = '东莞仓'
	) tmp
group by grouping sets ((),(department))
) a

left join (
	SELECT case when department is null THEN '公司' ELSE department END AS department
		,sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数`
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join (select BoxSku ,ProjectTeam  department from wt_products) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '东莞仓' and TotalInventory > 0 and CreatedTime = date_add('${EndDay}',-1)
		)  tmp
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (
	select case when department is null THEN '公司' ELSE department END AS department
		, round(sum(pc)) `发货订单采购金额`
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0
				and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0
		where pd.weighttime < '${EndDay}' and pd.weighttime >= '${StartDay}'
		) a
	group by grouping sets ((),(department))
) c on a.department = c.department
)
n1
on c1.department=n1.department
left join
-- 10天未发货订单数
( -- 10天未发货订单比 =  统计T-10~T-20未发货订单数÷统计T-10~T-20日均付款订单数
select  Department, count(distinct PlatOrderNumber ) `10天未发订单数`
from daily_WeightOrders wo
join mysql_store s
on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =s.Code and s.Department='特卖汇'
where CreateDate = '${EndDay}'
and PayTime>=date_add('${EndDay}',interval -20 day)
and PayTime<date_add('${EndDay}',interval -10 day)
and OrderStatus<>'作废'
group by Department)
n2
on c1.department=n2.Department

/*库存产品动销率*/
left join
(select a.department , round(`出单sku数`/`库存产品SKU数`,4) as `库存产品动销率`
from (
	select s.department, count(distinct boxsku) `出单sku数`
	from wt_orderdetails wo
	join mysql_store s
    on wo.ShopCode =s.Code and wo.IsDeleted = 0 and s.Department='特卖汇'
	where IsDeleted = 0 and PayTime < '${EndDay}' and PayTime >= '${StartDay}'
	group by s.department
	) a
left join (
	select department , count(distinct tmp.BoxSku ) `库存产品SKU数`
	from (
		select BoxSku -- 本期在仓sku
		from import_data.daily_WarehouseInventory dwi
		where CreatedTime = DATE_ADD('${EndDay}', -1)
		group by BoxSku
		union
		select BoxSku -- 上期在仓sku
		from import_data.daily_WarehouseInventory dwi
		where CreatedTime = DATE_ADD('${StartDay}', -1)
		group by BoxSku
		union
		select BoxSku -- 期间采购sku
		from wt_purchaseorder wp
		where ordertime  <  '${EndDay}'  and ordertime >= '${StartDay}' and WarehouseName = '东莞仓'
		) tmp
	join (select BoxSku , ProjectTeam as department  from import_data.wt_products where IsDeleted = 0 ) wp2
		on tmp.BoxSku =wp2.BoxSku
	group by department
	) b
	on a.department =b.department
where a.department in ('特卖汇'))
n3
on c1.department=n3.Department
left join
(select t1.team  as  department,ODR超标店铺数,t2.LSR超标店铺数,t3.CR超标店铺数,t4.VTR超标店铺数 from

(
-- ord
select
	'特卖汇'  as `team`
    ,count( distinct  case when round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)>0.009 then ShopCode end) 'ODR超标店铺数'
from (
select
     ShopCode,
	 sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
	,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,OrderDefectRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常'  and ms.Department = '特卖汇'
	where AmazonShopHealthStatus != 4
	and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- 每天凌晨0点后跑数
	) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 1 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
    and DateType = 60 -- 统计期
    group by ShopCode
) tmp2
) t1

left join
(
select '特卖汇' team
	,count(distinct case when LateShipment_ord_cnt/monitor_ord_cnt>=0.03 then ShopCode end ) 'LSR超标店铺数'
from (
select
    ShopCode
	,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- 迟发订单数
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '特卖汇'
	where AmazonShopHealthStatus != 4
    and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- 每天凌晨0点后跑数
    ) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
    and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
    and DateType = 7 -- 统计期
    group by ShopCode
) tmp2
) t2
on t1.team=t2.team
left join
(
-- 取消率
select '特卖汇' team1
     ,count(distinct case when OrderCancel_ord_cnt/monitor_ord_cnt>=0.02 then ShopCode end ) 'CR超标店铺数'
from (
select
     ShopCode
	,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- 取消订单数
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '特卖汇'
	where AmazonShopHealthStatus != 4
	and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- 每天凌晨0点后跑数
	) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType =7 -- 统计期
    group by ShopCode
) tmp2
) t3
on t1.team=t3.team1
left join
(
-- 有效追踪率
-- 当MetricsType = 3（追踪指标数据）的时候，OrderCount为null，因此使用 分子/比率=分母
select '特卖汇' as team1
	,count(distinct  case when ValidTracking_ord_cnt/monitor_ord_cnt <=0.96 then  ShopCode end) 'VTR超标店铺数'   -- 有效追踪率
from (
select
    ShopCode
	,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- 有效追踪订单数
	,round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0) as monitor_ord_cnt -- 统计订单数
	,sum(case when ItemType=8 then eaaspcd.Count  end)/round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0)
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '特卖汇'
	where AmazonShopHealthStatus != 4
    and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- 每天凌晨0点后跑数
	) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
    and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
    and DateType = 7 -- 统计期
    group by ShopCode
) tmp2
) t4
on t1.team=t4.team1) n4
on c1.department=n4.Department
left JOIN
(select '特卖汇' as dep,count(*) `staff_count` from dim_staff
where department='特卖汇'
and staff_name not regexp '刘一|刘二|刘一一|冉丽君|赵静|杨雁君测试权限' )n5
on c1.department=n5.dep
where c1.department='特卖汇')


select staff_count,'周度',sheet.department, 税后销售额, 总支出, 销售额, 利润额, 利润率,退款金额,round(退款金额/税后销售额,4) '退款率', 采购原因退款金额, 采购原因退款率, 非客户原因退款金额,
       非客户原因退款率, 订单数, 作废订单数, 作废订单率, 总ASIN贡献业绩, 出单总ASIN数,TOP1链接贡献业绩, TOP1ASIN购物车赢得率,round(TOP1链接贡献业绩/总ASIN贡献业绩,4) 'TOP1ASIN业绩占比',
       新ASIN贡献业绩, 新出单ASIN数, round(新ASIN贡献业绩/新出单ASIN数,2) '新ASIN单产',round(新出单ASIN数/提报ASIN数,4) '新ASIN有效率',round(新出单ASIN数/新上架ASIN数,4) '新ASIN动效率', 新上架ASIN数,
       round(新上架ASIN数/提报ASIN数,4) '新ASIN上架率',提报ASIN数,round(总ASIN贡献业绩-新ASIN贡献业绩,2) '老ASIN贡献业绩',round((总ASIN贡献业绩-新ASIN贡献业绩)/总ASIN贡献业绩,4) '老ASIN贡献业绩%',
       round((出单总ASIN数-新出单ASIN数)/(总在线ASIN数-新上架ASIN数),4) '老ASIN动销率',总在线ASIN数,round(出单总ASIN数/(总在线ASIN数+总删除ASIN数),4) '总ASIN动销率',访客数,访客销量,
       round(访客销量/访客数,4) '访客转化率',购物车赢得率,订单数,作废订单数,作废订单率,准时发货率, 准时妥投率,'-' as '物流3天上网率',采购单数,采购原因退款金额,采购原因退款率,采购产品金额 as '采购金额',
       日均采购单数,采购3天到货率,平均采购收货天数,`2天生包率`,'-' as '24小时入库率' ,`24小时收货率`,'-' as '24小时上架率', `24小时发货率`,订单5天发货率, `10天未发订单数`,日均邮件数
       ,库存周转天数,本地仓库存资金占用,库存产品动销率, ODR超标店铺数, VTR超标店铺数, LSR超标店铺数, CR超标店铺数,'0'as 'AHR超标店铺数', round(10天未发订单数/`7天前日均订单数`,4) '10天前未发货订单率',
        sheet.审核总SKU数,sheet.审核通过SKU数,sheet.审核通过率
from sheet
left join top1
on sheet.department=top1.department
left join ls
on sheet.department=ls.department
left join deliver
on sheet.department=deliver.Department;