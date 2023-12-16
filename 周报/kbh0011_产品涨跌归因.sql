with
od as ( -- 订单统计范围
select wo.*,dd.week_num_in_year
from wt_orderdetails wo
join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '快百货'
left join dim_date dd on date(paytime) = full_date
where PayTime >= '2023-07-31' -- 0731是周一
)

,prod as ( -- 产品范围
select distinct product_spu as spu ,ProductName 产品名称,Logistic_Attr 物流属性 ,CategoryPathByChineseName 系统类目
    ,case when wp.ProductStatus = 0 then '正常'
            when wp.ProductStatus = 2 then '停产'
            when wp.ProductStatus = 3 then '停售'
            when wp.ProductStatus = 4 then '暂时缺货'
            when wp.ProductStatus = 5 then '清仓'
            end as 产品状态
from od left join wt_products wp on od.Product_Sku = wp.sku and wp.ProjectTeam='快百货' and wp.IsDeleted=0
)

,od_total_stat as ( -- 累计统计
select spu ,count(distinct Product_Sku) 出单且正常SKU数
from od
join wt_products wp on od.Product_Sku = wp.sku and wp.ProjectTeam='快百货' and wp.IsDeleted=0 and wp.ProductStatus=0
group by spu
)

, od_week_stat as (
select Product_SPU as spu ,week_num_in_year
     ,round( sum((totalgross-feegross)/ExchangeUSD),2 ) 不含运费销售额
     ,round( sum((TotalProfit-feegross)/ExchangeUSD),2 ) 不含运费利润额
     ,case
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 15 then '15+'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 10 then '10-15'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) > 5 then '5-10'
         when round( sum((totalgross-feegross)/ExchangeUSD) / sum(salecount) ,2 ) >= 0 then '0-5'
     end 价格带
     ,sum(salecount) 销量
     ,min(PayTime) min_paytime
from od
group by spu ,week_num_in_year
)

,refund_in30d_stat as ( -- 近30天统计
select a.spu  ,round( ifnull(refund_amount,0) / totalgross ,2 ) 近30天累计退款率
from (
    select Product_SPU as spu
     ,round( sum((totalgross)/ExchangeUSD),2 ) totalgross
    from wt_orderdetails wo
    join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '快百货'
    left join dim_date dd on date(paytime) = full_date
    where PayTime >= date_add('${NextStartDay}' , INTERVAL -30 DAY)
    group by spu
     ) a
left join (
    select spu
        ,abs(round( sum( RefundUSDPrice ),2 )) refund_amount
    from ( select distinct PlatOrderNumber, RefundUSDPrice ,dim_date.week_num_in_year as refund_week
        from daily_RefundOrders rf
        join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='已退款'  and ms.Department = '快百货'
        join dim_date on dim_date.full_date = date(rf.RefundDate)
        where RefundDate  >= date_add('${NextStartDay}' , INTERVAL -30 DAY) and RefundDate < '${NextStartDay}'
        ) t1
    join (
        select PlatOrderNumber ,Product_SPU as spu   from wt_orderdetails wo
        where IsDeleted=0 and TransactionType='付款' and department = '快百货' group by PlatOrderNumber  ,Product_SPU
        ) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
    group by spu
    ) b
on a.spu = b.spu
)

select
t0.spu
,出单且正常SKU数
,产品名称
,物流属性
,'' 商品尺寸
,系统类目
,'' 产品类型
,'' 类目
,'' 季节
,'' 主题
,'' 外观元素
,'' 功能元素
,'' 工作原理
,'' 材质
,'' 风格
,'' 包装
,'' PCS
,'' 通用名
,'' 使用功能
,'' 使用场景
,'' 使用客群
,'' 年龄段
,'' 导入期
,'' 成长期
,'' 衰退期
,不含运费销售额
,不含运费利润额
,销量
,价格带
,近30天累计退款率
,产品状态
,'' 停产原因
,'' 升降标记
,'' 原因归类
,'' 原因明细
,'' 策略动作
,'' 结果跟进
from prod t0
left join od_total_stat t1 on  t0.spu =t1.Spu
left join ( select * from od_week_stat where week_num_in_year = (select max(week_num_in_year) from od_week_stat)  ) t2 on t0.spu =t2.Spu -- 取最新一周
left join refund_in30d_stat t3 on  t0.spu =t3.Spu




