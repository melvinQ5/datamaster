-- 参数 team = 成都、泉州  NextStartDay = 今天
-- 主键：SPU

with
prod as ( -- 商品运营组推送SPU
select dkplp.spu ,prod_level 商品分层 -- 只推在开始推送和停止推送日期之间 且分层=潜力款的品
    ,group_concat(PushRule) 推送标准 ,group_concat(PushSite) 主推站点 ,max(PushDate)  最新推送日期
    ,产品类目 ,终审日期 ,产品状态
from dep_kbh_product_level_potentail dkplp
join (select spu ,date(DevelopLastAuditTime) 终审日期  -- 只推正常产品
            ,case when ProductStatus = 0 then '正常'
		when ProductStatus = 2 then '停产'
		when ProductStatus = 3 then '停售'
		when ProductStatus = 4 then '暂时缺货'
		when ProductStatus = 5 then '清仓'
		end as 产品状态
          from erp_product_products where IsMatrix=1 and IsDeleted=0 and ProjectTeam='快百货' and ProductStatus = 0 ) epp on dkplp.spu = epp.spu
left join (select spu ,CategoryPathByChineseName 产品类目 from wt_products where ProjectTeam='快百货' and IsDeleted=0 group by spu ,CategoryPathByChineseName ) wp on dkplp.spu = wp.spu
where  '${NextStartDay}' >= dkplp.PushDate
  and  '${NextStartDay}' <= dkplp.StopPushDate
  and prod_level = '潜力款' and isStopPush ='否'
  and PushDate >= '2023-10-01'  and '${NextStartDay}' < StopPushDate -- 推送时间在有效期内
  -- and spu =5115270
group by dkplp.spu ,prod_level ,产品类目 ,终审日期 ,产品状态
)

,prod_seller as ( -- 产品对应区域销售负责人
select prod.spu ,group_concat(SellUserName) 产品销售负责人
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join  ( select distinct case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2, SellUserName
        from import_data.mysql_store where department regexp '快') ms  on eaapis.SellUserName = ms.SellUserName
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    where dep2 = '${team}'
    group by spu  ,eaapis.SellUserName
    ) tmp
join prod on tmp.spu = prod.spu
group by prod.spu
order by prod.spu
)

,online_lists as ( -- 在线账号清单
select eaal.spu  ,CompanyCode  ,SellUserName
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '正常'
join prod on eaal.spu = prod.spu
where dep2 = '${team}'
group by eaal.spu ,CompanyCode ,SellUserName
)

,od_90 as (
select wo.Product_SPU as spu  ,SellUserName
     ,round(sum(totalgross/ExchangeUSD)/30,2) sales_30 -- 按近90天计算平均月销
    , count(distinct  case when PayTime >= date(date_add('${NextStartDay}',INTERVAL -14 day)) and PayTime < '${NextStartDay}'then PlatOrderNumber end)  orders_14d
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  s on s.code=wo.shopcode and s.department='快百货'
join prod on wo.Product_SPU = prod.spu
where wo.IsDeleted = 0 and TransactionType = '付款'
  and dep2 = '${team}'
  and PayTime >= date(date_add('${NextStartDay}',INTERVAL -90 day)) and PayTime < '${NextStartDay}'
group by wo.Product_SPU  ,SellUserName
)

,spu_sort as (
select *
     ,row_number()  over (partition by spu  order by sales_30 desc  ) sort -- 账号x销售人员的业绩排序
     ,dense_rank()  over (partition by spu  order by sales_30_by_seller desc  ) sort_by_seller -- 账号x销售人员的业绩排序
from (
select ol.* ,ifnull(sales_30,0)  sales_30
    ,ifnull( sum(sales_30) over (partition by ol.spu,o9.SellUserName),0) sales_30_by_seller
from online_lists ol
left join od_90 o9 on ol.spu = o9.spu and ol.SellUserName = o9.SellUserName
) t1
order by spu  ,sort
)

,tail_code as (
select spu
     ,group_concat(CompanyCode) 末位账号
     ,group_concat(SellUserName) 末位销售员
     ,group_concat(concat(sales_30,'$')) 末位账号月销
from (
select case when sort >4 then '超4套' else null end  as mark ,*
from spu_sort
) t1
where mark= '超4套'
group by spu
)

,online_comp_stat as ( select spu ,count(distinct CompanyCode) 在线套数 from online_lists group by spu )

,online_lst_stat  as ( -- 在线账号清单
select eaal.spu ,count(distinct concat(SellerSKU,ShopCode)) 在线条数
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '正常'
join prod on eaal.spu = prod.spu
where dep2 = '${team}'
group by eaal.spu
)

,online_staff_stat as (
    select distinct spu -- todo 当排名相同是 用等于符号
      ,concat ( ifnull(name1,''), if(name2 is null,'','>'),ifnull(name2,''),if(name3 is null,'','>'),ifnull(name3,''),if(name4 is null,'','>'),ifnull(name4,''),if(name5 is null,'','>')
      ,ifnull(name5,''), if(name6 is null,'','>'),ifnull(name6,''), if(name7 is null,'','>'),ifnull(name7,''),if(name8 is null,'','>'),ifnull(name8,'') ) 在线销售员排名
    from (
        select  spu
             ,group_concat(name1,'=') name1,group_concat(name2,'=') name2,group_concat(name3,'=') name3,group_concat(name4,'=') name4
             ,group_concat(name5,'=') name5,group_concat(name6,'=') name6,group_concat(name7,'=') name7,group_concat(name8,'=') name8
        from ( select distinct spu,
            case when sort_by_seller = 1 then SellUserName  end name1,
            case when sort_by_seller = 2 then SellUserName  end name2,
            case when sort_by_seller = 3 then SellUserName  end name3,
            case when sort_by_seller = 4 then SellUserName  end name4,
            case when sort_by_seller = 5 then SellUserName  end name5,
            case when sort_by_seller = 6 then SellUserName  end name6,
            case when sort_by_seller = 7 then SellUserName  end name7,
            case when sort_by_seller = 8 then SellUserName  end name8
            from  spu_sort ) a
        group by spu
        ) b
    )

,od_14d_stat as (
select wo.Product_SPU as spu
    , count(distinct PlatOrderNumber )  近14天订单数_快百货
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  s on s.code=wo.shopcode and s.department='快百货'
join prod on wo.Product_SPU = prod.spu
where wo.IsDeleted = 0 and TransactionType = '付款'
  and PayTime >= date(date_add('${NextStartDay}',INTERVAL -14 day)) and PayTime < '${NextStartDay}'
group by wo.Product_SPU
)


select t0.* ,产品销售负责人 ,近14天订单数_快百货 ,ifnull(在线条数,0) 在线条数 ,ifnull(在线套数,0) 在线套数 ,在线销售员排名 ,末位账号 ,末位销售员 ,末位账号月销
from prod t0
left join online_comp_stat t1 on t0.spu = t1.spu
left join online_staff_stat t2 on t0.spu = t2.spu
left join tail_code t3 on t0.spu = t3.spu
left join prod_seller t4 on t0.SPU = t4.spu
left join od_14d_stat t5 on t0.SPU = t5.spu
left join online_lst_stat t6 on t0.SPU = t6.spu
order by 在线套数 desc

