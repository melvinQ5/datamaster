/*特卖汇小组指标*/
/*特卖汇小组对应销售人员*/
SELECT u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组');
-- 注意TOPASIN的时间

/*销售数据*/
with sale as(
                   with orderdetails as(select TotalGross,CreationTime,TotalProfit,left(user.NodePathName,3) 'dep',right(user.NodePathName,7) as team,Name,PlatOrderNumber,ord.Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,s.* from import_data.wt_orderdetails ord   /*订单表（订单数据）*/
                   inner join (select eg.Asin,eg.Site,eg.CreationTime,s.NodePathName,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT d.NodePathName,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                on ap.AssignUserName=s.Name) as user
                                on ord.Asin=user.Asin
                                and ord.Site=user.Site
                   inner join mysql_store s
                   on ord.shopcode=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0)
                select team,ifnull(Name,'小组汇总') as 'name',税后销售额, expend, 订单数 from
                (select team,Name,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '税后销售额' ,
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'作废' and TotalGross>0 then PlatOrderNumber end) '订单数'
                from orderdetails
                group by grouping sets ((team),(team,Name))
                order by team,Name) a

/*TOPASIN*/
),top1 as
      (select a.team, a.Name, TOP1链接贡献业绩,b.TOP1ASIN购物车赢得率 from
        (select t3.team,ifnull(Name,'小组汇总') as Name, TOP1链接贡献业绩 from(
            select team,name, round(sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD),2)  'TOP1链接贡献业绩'  from ods_orderdetails od
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
            inner join mysql_store s
            on od.ShopIrobotId=s.Code/*部门维度*/
            and s.Department='特卖汇'
            where IsDeleted=0
            and TransactionType='付款'
            and OrderStatus<>'作废'
            and PayTime>='${StartDay}'
            and PayTime<'${EndDay}'
            group by grouping sets ((team),(team,Name))) t3
        ) a
    left join (select c1.team, c1.Name, ASIN访客数,round(c2.店铺访客数/c1.ASIN访客数,4) 'TOP1ASIN购物车赢得率' from
(
        select c.team, ifnull(Name,'小组汇总')Name, ASIN访客数 from
(select team,Name,sum(t4.TotalCount2) 'ASIN访客数' from
(select team,Name,max(TotalCount) TotalCount2  from ListingManage lm
       inner join  (select t2.Asin, t2.Site, team, Name from
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
        on lm.ChildAsin=t3.ASIN
        and lm.StoreSite=t3.Site
        inner join mysql_store s
        on lm.shopcode=s.Code/*部门维度*/
        and s.Department='特卖汇'
        where ReportType='周报'
        and Monday='${StartDay}'
        group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite,team,Name) t4
group by grouping sets( (team),(team,Name))
) c) c1
        left join
       (select t4.team, ifnull(Name,'小组汇总') as 'name',店铺访客数 from
               (select team,name,round(sum(TotalCount*FeaturedOfferPercent/100),2) '店铺访客数' from ListingManage ls
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
                    and t1.Site=t2.Site) t1
                on ls.ChildAsin=t1.ASIN
                and right(ls.shopcode,2)=t1.Site
                inner join mysql_store s
                on ls.ShopCode=s.Code
                and s.Department='特卖汇'
                where ReportType='周报'
                and Monday='${StartDay}'
                group by grouping sets ((team),(team,Name))) t4
                ) c2
                on c1.team=c2.team
                and c1.Name=c2.name
)b
on a.Name=b.Name
and a.team=b.team
/*新ASIN销售数据*/

),tmp as ( select b.team, ifnull(Name,'小组汇总') as name, 所有ASIN贡献业绩, 出单ASIN数, 新ASIN贡献业绩, 出单新ASIN数  from
                   (select  team,name,sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD) '所有ASIN贡献业绩',
                   count(distinct concat(user.Asin,right(ShopIrobotId,2))) '出单ASIN数',
                   sum(case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then  (TotalGross+TaxGross-RefundAmount)/ExchangeUSD  end ) '新ASIN贡献业绩',/*跟随状态(8:待上架,9:已上架,10:下架)*/
                   count(distinct case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then concat(user.Asin,right(ShopIrobotId,2)) end) '出单新ASIN数' from import_data.ods_orderdetails ord   /*订单表（订单数据）*/
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
                   inner join  mysql_store s
                   on ord.ShopIrobotId=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and TransactionType<>'退款'
                   and OrderStatus<>'作废'   /*剔除作废订单、未减去退款税前销售额*/
                   and ord.IsDeleted=0
                   group by grouping sets ((team),(team,Name))) b

/*特卖汇ASIN库*/
),ls as( select t1.team, ifnull(Name,'小组汇总') as 'Name', 提报ASIN数, 上架ASIN数,创建ASIN数,`3天内上架ASIN数` from
                                (select team,name,
                                count(distinct case when eg.CreationTime>='${StartDay}' and eg.CreationTime<'${EndDay}'  then concat(eg.Asin,eg.Site) end) '提报ASIN数',
                                count(distinct case when FollowUpStatus=9 and FirArrivalTime>='${StartDay}'  and FirArrivalTime<'${EndDay}' then concat(eg.Asin,eg.Site) end) '上架ASIN数',
                                count(distinct case when eg.CreationTime>=date_add('${StartDay}',interval -3 day) and eg.CreationTime<date_add('${EndDay}',interval -3 day) then concat(eg.Asin,eg.Site) end) '创建ASIN数',
                                sum(case when eg.CreationTime>=date_add('${StartDay}',interval -3 day) and eg.CreationTime<date_add('${EndDay}',interval -3 day) and FollowUpStatus=9
                                and  timestampdiff(second,eg.CreationTime,FirArrivalTime)<86400*3 then 1 end) '3天内上架ASIN数' /*3天内上架ASIN数*/
                                from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap  /*注意是否删除*/
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                on ap.AssignUserName=s.Name
                                group by grouping sets ((team),(team,Name))) t1

/*特卖汇总在线ASIN*/
),tm as( select  team, ifnull(Name,'小组汇总') as 'name', 总在线ASIN数, `总ASIN数量(渠道SKU)` from
                         (select team,name,
                         count(distinct concat(t1.ASIN,t1.code)) '总在线ASIN数' ,
                         count(distinct SellerSKU) '总ASIN数量(渠道SKU)' from
                        (select ASIN,right(ShopCode,2) code,SellerSKU from erp_amazon_amazon_listing al
                        inner join  mysql_store s
                        on al.ShopCode=s.Code
                        and s.Department='特卖汇'
                        and ListingStatus=1) as t1
                        inner join
                        (select eg.Asin,eg.Site,eg.CreationTime,s.dep,s.team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                on ap.AssignUserName=s.Name) t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site
                        group by grouping sets ((team),(team,Name))) t2
/*退款数据*/
),ref as (select t2.team, ifnull(Name,'小组汇总') as 'name', 退款金额,非客户原因退款金额 from
             (select team,name,sum(RefundUSDPrice) '退款金额',sum(case when RefundReason1='采购原因' then  RefundUSDPrice end) '采购原因退款金额',
            sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '非客户原因退款金额'  from import_data.daily_RefundOrders rf
           inner join (select OrderNumber,team,Name from ods_orderdetails od
                      inner join (select eg.Asin,eg.Site,s.dep,s.team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap  /*小组对应ASIN数据*/
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s /*小组对应小组成员*/
                                on ap.AssignUserName=s.Name) user
                        on od.Asin=user.Asin     /*使用INNER JOIN时确保其中一张表都是唯一的*/
                        and right(od.ShopIrobotId,2)=user.Site
                        and od.IsDeleted=0
                        and TransactionType='付款' /*交易类型为付款，未删除*/
                        inner join mysql_store s
                        on od.ShopIrobotId=s.Code
                        and s.Department='特卖汇'
                        group by OrderNumber,team,Name) as t1
           on rf.OrderNumber=t1.OrderNumber
           where RefundStatus='已退款'
           and RefundDate>='${StartDay}'/*时间维度*/
           and RefundDate<'${EndDay}'
           group by grouping sets ((team),(team,name))) t2
/*访客数据*/
),visitor as (select c1.team, c1.Name, ASIN访客数,round(c2.访客数/c1.ASIN访客数,4) '购物车赢得率',c2.访客数,c2.访客销量 from
(
        select c.team, ifnull(Name,'小组汇总')Name, ASIN访客数 from
(select team,Name,sum(t4.TotalCount2) 'ASIN访客数' from
(select team,Name,max(TotalCount) TotalCount2  from ListingManage lm
       inner join
    (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*找出更改负责人*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                        on ap.AssignUserName=s.Name) as t2
        on lm.ChildAsin=t2.ASIN
        and lm.StoreSite=t2.Site
        inner join mysql_store s
        on lm.ShopCode=s.Code
        and s.Department='特卖汇'
        where ReportType='周报'
        and Monday='${StartDay}'
        group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite,team,Name) t4
group by grouping sets( (team),(team,Name))
) c) c1
        left join
       (select t4.team, ifnull(Name,'小组汇总') as 'name',访客数,访客销量 from
               (select team,name,round(sum(TotalCount*FeaturedOfferPercent/100),2) '访客数',sum(OrderedCount) '访客销量'  from ListingManage ls
                inner join
                (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*找出更改负责人*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) s
                                        on ap.AssignUserName=s.Name) as t2
                on ls.ChildAsin=t2.ASIN
                and ls.StoreSite=t2.Site
                inner join mysql_store s
                on ls.ShopCode=s.Code
                and s.Department='特卖汇'
                where ReportType='周报'
                and Monday='${StartDay}'
                group by grouping sets ((team),(team,Name))) t4
                ) c2
                on c1.team=c2.team
                and c1.Name=c2.name                                                                                                  )

select t1.team, name, 税后销售额, 总支出, 销售额, 利润额, 利润率, 退款金额, 退款率, 非客户原因退款金额, 非客户原因退款率, TOP1链接贡献业绩, 所有ASIN贡献业绩, TOP1ASIN购物车赢得率, TOP1ASIN贡献业绩占比, `3天内上架ASIN数`, 创建ASIN数, 新ASIN3天上架率, 新ASIN贡献业绩, 出单新ASIN数, 上架ASIN数, 提报ASIN数, 新ASIN单产, 新ASIN有效率, 新ASIN动销率, 新ASIN上架率, 老ASIN贡献业绩, `老ASIN贡献业绩%`, 出单老ASIN数, 老ASIN数, 老ASIN动销率, 总在线ASIN数, 总ASIN动销率, 访客数, 访客销量, 访客转化率, 购物车赢得率 from (
(select tt.team
  , case when tt.team regexp 'TMH销售1组' then '0.1'
         when tt.team regexp 'TMH销售2组' then '0.2'
         when tt.team regexp 'TMH销售3组' then '0.3' end 'sort'
  , tt.name,税后销售额, expend as '总支出',round(税后销售额-ifnull(退款金额,0),2) '销售额',round(税后销售额+expend-ifnull(退款金额,0),2) '利润额',
  round((税后销售额+expend-ifnull(退款金额,0))/(税后销售额-ifnull(退款金额,0)),4) '利润率',退款金额,round(退款金额/税后销售额,4) '退款率',非客户原因退款金额,
  round(非客户原因退款金额/税后销售额,4) '非客户原因退款率',TOP1链接贡献业绩,所有ASIN贡献业绩, TOP1ASIN购物车赢得率,round(TOP1链接贡献业绩/所有ASIN贡献业绩,4) 'TOP1ASIN贡献业绩占比',
  3天内上架ASIN数,创建ASIN数,round(`3天内上架ASIN数`/创建ASIN数,4) '新ASIN3天上架率',新ASIN贡献业绩,出单新ASIN数,上架ASIN数,提报ASIN数,round(新ASIN贡献业绩/出单新ASIN数,2) '新ASIN单产',
  round(出单新ASIN数/提报ASIN数,4) '新ASIN有效率',round(出单新ASIN数/上架ASIN数,4) '新ASIN动销率',round(上架ASIN数/提报ASIN数,4) '新ASIN上架率',
  round(所有ASIN贡献业绩-新ASIN贡献业绩) '老ASIN贡献业绩',round((所有ASIN贡献业绩-新ASIN贡献业绩)/所有ASIN贡献业绩,4) '老ASIN贡献业绩%',
  出单ASIN数-出单新ASIN数 as '出单老ASIN数',总在线ASIN数-上架ASIN数 as '老ASIN数',round((出单ASIN数-出单新ASIN数)/(总在线ASIN数-上架ASIN数),4) '老ASIN动销率',总在线ASIN数,round(出单ASIN数/总在线ASIN数,4)  '总ASIN动销率',
  visitor.访客数,visitor.访客销量,round(访客销量/访客数,4) '访客转化率',visitor.购物车赢得率 from
(select 'TMH销售1组' as team,'小组汇总'as name
union
select 'TMH销售2组' as team,'小组汇总'as name
union
select 'TMH销售3组' as team,'小组汇总'as name
union
SELECT right(d.NodePathName,7) team,u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) as tt
left join sale
on tt.team=sale.team
and tt.name=sale.name
left join top1
on tt.team=top1.team
and tt.name=top1.name
left join tmp
on tt.team=tmp.team
and tt.name=tmp.name
left join ls
on tt.team=ls.team
and tt.name=ls.name
left join tm
on tt.team=tm.team
and tt.name=tm.name
left join ref
on tt.team=ref.team
and tt.name=ref.name
left join visitor
on tt.team=visitor.team
and tt.name=visitor.name
where tt.name='小组汇总'
)

union all

(select tt.team
  ,case when tt.team regexp 'TMH销售1组' then '1'
         when tt.team regexp 'TMH销售2组' then '2'
         when tt.team regexp 'TMH销售3组' then '3' end 'sort'
  , tt.name,税后销售额, expend as '总支出',round(税后销售额-ifnull(退款金额,0),2) '销售额',round(税后销售额+expend-ifnull(退款金额,0),2) '利润额',
  round((税后销售额+expend-ifnull(退款金额,0))/(税后销售额-ifnull(退款金额,0)),4) '利润率',退款金额,round(退款金额/税后销售额,4) '退款率',非客户原因退款金额,
  round(非客户原因退款金额/税后销售额,4) '非客户原因退款率',TOP1链接贡献业绩,所有ASIN贡献业绩, TOP1ASIN购物车赢得率,round(TOP1链接贡献业绩/所有ASIN贡献业绩,4) 'TOP1ASIN贡献业绩占比',
  3天内上架ASIN数,创建ASIN数,round(`3天内上架ASIN数`/创建ASIN数,4) '新ASIN3天上架率',新ASIN贡献业绩,出单新ASIN数,上架ASIN数,提报ASIN数,round(新ASIN贡献业绩/出单新ASIN数,2) '新ASIN单产',
  round(出单新ASIN数/提报ASIN数,4) '新ASIN有效率',round(出单新ASIN数/上架ASIN数,4) '新ASIN动销率',round(上架ASIN数/提报ASIN数,4) '新ASIN上架率',
  round(所有ASIN贡献业绩-新ASIN贡献业绩) '老ASIN贡献业绩',round((所有ASIN贡献业绩-新ASIN贡献业绩)/所有ASIN贡献业绩,4) '老ASIN贡献业绩%',
  出单ASIN数-出单新ASIN数 as '出单老ASIN数',总在线ASIN数-上架ASIN数 as '老ASIN数',round((出单ASIN数-出单新ASIN数)/(总在线ASIN数-上架ASIN数),4) '老ASIN动销率',总在线ASIN数,round(出单ASIN数/总在线ASIN数,4)  '总ASIN动销率',
  visitor.访客数,visitor.访客销量,round(访客销量/访客数,4) '访客转化率',visitor.购物车赢得率 from
(select 'TMH销售1组' as team,'小组汇总'as name
union
select 'TMH销售2组' as team,'小组汇总'as name
union
select 'TMH销售3组' as team,'小组汇总'as name
union
SELECT right(d.NodePathName,7) team,u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('特卖汇>TMH销售1组','特卖汇>TMH销售2组','特卖汇>TMH销售3组')) as tt
left join sale
on tt.team=sale.team
and tt.name=sale.name
left join top1
on tt.team=top1.team
and tt.name=top1.name
left join tmp
on tt.team=tmp.team
and tt.name=tmp.name
left join ls
on tt.team=ls.team
and tt.name=ls.name
left join tm
on tt.team=tm.team
and tt.name=tm.name
left join ref
on tt.team=ref.team
and tt.name=ref.name
left join visitor
on tt.team=visitor.team
and tt.name=visitor.name
where tt.name<>'小组汇总'
)) t1
where t1.name<>'杨雁君测试权限'
order by t1.sort;




