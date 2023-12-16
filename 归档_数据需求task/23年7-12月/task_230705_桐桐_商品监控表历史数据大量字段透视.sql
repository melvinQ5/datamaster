-- 需求背景：桐桐基于ERP图表 产品分析表的导出了历史数据，现在大量列字段透视，excel带不动

-- python 透视
-- df_1 = pd.pivot_table(df,index=[u'BoxSku'],columns=[u'week'],values=[u'最高日销量',u'销售天数',u'利润额',u'销量',u'销售额',],aggfunc=[np.sum],fill_value=0,margins=1)

-- SQL查询
select 
	year ,week ,BoxSku
	,sum(销量) 销量
	,sum(销售额) 销售额
	,sum(利润额) 利润额
	,sum(weekly_order_days) 销售天数
	,max(销量) 最高日销量
from (
select  year `year`
       ,week_num_in_year `week`
       ,date(PayTime) pay_date
       ,od.BoxSku
       ,sum(SaleCount) '销量'
       ,round(sum(TotalGross/ExchangeUSD),4) '销售额'
       ,round(sum(TotalProfit/ExchangeUSD),4) '利润额'
       ,count(distinct date(PayTime)) `weekly_order_days`
from wt_orderdetails od
inner join dim_date da
on date(od.PayTime)=da.full_date
inner join mysql_store s
on od.shopcode=s.Code
where od.PayTime>='2023-01-01'
and od.PayTime<'${EndDay}'
and s.Department = '快百货'
and od.BoxSku<>''
and IsDeleted=0
and OrderStatus<>'作废'
and TransactionType<>'其他'   -- 交易类型不为其他
group by year,week_num_in_year ,date(PayTime) ,od.BoxSku
order by year,week_num_in_year desc
) tmp  
where boxsku = 1000722 and week = 21
group by year ,week ,BoxSku
order by year ,week ,BoxSku