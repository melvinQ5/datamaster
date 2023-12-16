select t1.Department,t1.team,税后销售额, expend,round(税后销售额-ifnull(退款金额,0),2) '销售额',round(税后销售额+expend-ifnull(退款金额,0)-广告花费,2) '利润额',
       round(广告花费/(税后销售额-ifnull(退款金额,0)),4) '广告花费占比',round(ifnull(退款金额,0)/税后销售额,4) '退款率',
       出单市场数,ifnull(退款金额,0), 新刊登链接数,round(新链接出单数/新刊登链接数,4) '新链接动销率',新刊登链接广告点击率,新刊登链接广告转化率,round(新刊登链接访客销量/新刊登链接访客数,4) '新链接访客转化率',在线链接数,出单链接数,round(出单链接数/在线链接数,4) '链接动销率',广告ACOST,
       round(广告销售额/(税后销售额-ifnull(退款金额,0)),4) '广告业绩占比',广告点击率,广告转化率,访客数, 访客销量,round(访客销量/访客数,4) '访客转化率',
       round((访客数-广告点击数)/访客数,4) '自然流量占比',养号市场总数量,出单市场数,当月出单数大于3单的市场数量,广告花费 from
(with orderdetails as(select TotalGross,TotalProfit,PlatOrderNumber,s.AccountCode,ord.Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,ord.PublicationDate,pp.Spu,s.Department,s.NodePathName,s.Market from import_data.wt_orderdetails ord   /*订单表（订单数据）*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join tmh_pm_code s
                   on ord.shopcode=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   left join TMH_ASIN tm
                   on tm.Asin=ord.Asin
                   and tm.Site=ord.Site
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0
                   and Name is null)
                select department,ifnull(NodePathName,'TMH') team,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '税后销售额',
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'作废' and TotalGross>0 then PlatOrderNumber end) '订单数',
                count(distinct case when TransactionType<>'作废'then AccountCode end) '出单市场数',
                count(distinct case when TransactionType<>'作废'then concat(Asin,right(shopcode,2)) end) '出单链接数',
                count(distinct case when TransactionType<>'作废'and PublicationDate>='${StartDay}' and PublicationDate<'${EndDay}' then concat(Asin,right(shopcode,2)) end) '新链接出单数'
                from orderdetails
                group by grouping sets((department),(department,NodePathName))) t1
/*退款数据*/
left join (select department,ifnull(NodePathName,'TMH') team,sum(RefundUSDPrice) '退款金额',sum(case when RefundReason1='采购原因' then  RefundUSDPrice end) '采购原因退款金额',
         sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '非客户原因退款金额'  from import_data.daily_RefundOrders rf
           inner join tmh_pm_code s
           on rf.OrderSource=s.Code /*部门维度*/
           and s.Department='特卖汇'
           inner join (select PlatOrderNumber
                      from wt_orderdetails od
                      inner join tmh_pm_code s
                      on od.shopcode=s.Code
                      left join TMH_ASIN ta
                      on od.Site=ta.Site
                      and od.Asin=ta.Asin
                      where TransactionType='付款'
                      and Name is null
                      group by PlatOrderNumber) t1
           on rf.PlatOrderNumber=t1.PlatOrderNumber
           and RefundStatus='已退款'
           and RefundDate>='${StartDay}'/*时间维度*/
           and RefundDate<'${EndDay}'
           group by grouping sets((department),(department,NodePathName))) t2
on t1.Department=t2.Department
and t1.team=t2.team
/*广告数据*/
left join (select department,ifnull(NodePathName,'TMH') team,
        round(sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Clicks end )/sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Exposure end ),4) '新刊登链接广告点击率',
        round(sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then TotalSale7DayUnit end )/sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Clicks end ),4) '新刊登链接广告转化率',
        round(sum(Clicks)/sum(Exposure),4) '广告点击率',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '广告转化率',
        round(sum(Spend)/sum(TotalSale7Day),4) '广告ACOST',sum(TotalSale7Day) '广告销售额',sum(Clicks) '广告点击数',sum(Spend) '广告花费'

    from erp_amazon_amazon_listing al
     inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and s.Department='特卖汇'
    inner join AdServing_Amazon aa
    on al.ShopCode=aa.ShopCode
    and al.SellerSKU=aa.SellerSKU
    left join TMH_ASIN ta
    on aa.Asin=ta.Asin
    and right(aa.ShopCode,2)=ta.Site
    where CreatedTime>='${StartDay}'
    and CreatedTime<'${EndDay}'
    and ta.Name is null
    group by  grouping sets((department),(department,NodePathName))) t3
on t1.Department=t3.Department
and t1.team=t3.team
/*访客数据*/
left join (select department,ifnull(NodePathName,'TMH') team,
    round(sum(TotalCount*FeaturedOfferPercent/100)) '访客数',sum(OrderedCount) '访客销量' ,
    round(sum( case when  al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then TotalCount*FeaturedOfferPercent/100 end)) '新刊登链接访客数',
    sum(case when  al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then OrderedCount  end) '新刊登链接访客销量'
    from erp_amazon_amazon_listing al
    inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and s.Department='特卖汇'
    inner join ListingManage lm
    on al.ShopCode=lm.ShopCode
    and al.ASIN=lm.ChildAsin
    left join TMH_ASIN ta
    on lm.ChildAsin=ta.Asin
    and lm.StoreSite=ta.Site
    where lm.Monday='${StartDay}'
    and ReportType='周报'
    and ta.Name is null
    group by grouping sets((department),(department,NodePathName))    ) t4
on t1.Department=t4.Department
and t1.team=t4.team
/*风险控制*/
left join (select '特卖汇' department, 'TMH' as  team,t1.养号市场总数量,t2.当月出单数大于3单的市场数量  from (select '特卖汇' as team1,count (distinct AccountCode) '养号市场总数量' from tmh_pm_code
                                where Department='特卖汇'
                                ) t1
        inner join (select  '特卖汇' as team2,count(distinct s.AccountCode) '当月出单数大于3单的市场数量'   from import_data.wt_orderdetails ord   /*订单表（订单数据）*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join tmh_pm_code s
                   on ord.shopcode=s.Code/*部门维度*/
                   and s.Department='特卖汇'
                   where PayTime>='${StartDay}'/*时间范围*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0
                   and OrderStatus<>'作废'
                   group by s.AccountCode
                   having count(PlatOrderNumber)>=3) t2
                   on t1.team1=t2.team2 ) t5
on t1.Department=t5.Department
and t1.team=t5.team
/*链接数据*/
left join (select department,ifnull(NodePathName,'TMH') team,count(distinct case when PublicationDate>='${StartDay}' and PublicationDate<'${EndDay}' then concat(Asin,right(shopcode,2)) end) '新刊登链接数' ,
       count(distinct concat(Asin,right(shopcode,2))) '在线链接数' from erp_amazon_amazon_listing al
    inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and Department='特卖汇'
    and ShopStatus='正常'
    where ListingStatus=1
    group by grouping sets((department),(department,NodePathName))) t6
on t1.Department=t6.Department
and t1.team=t6.team
order by t1.team