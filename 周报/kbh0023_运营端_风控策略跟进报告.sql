with
perf as (
select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
,itemtype
, case when itemtype=40 then '涉嫌侵犯知识产权'
when itemtype=41 then '知识产权投诉'
when itemtype=42 then '商品真实性买家投诉'
when itemtype=43 then '商品状况买家投诉'
when itemtype=44 then '食品和商品安全问题'
when itemtype=45 then '上架政策违规'
when itemtype=46 then '违反受限商品政策'
when itemtype=47 then '违反买家商品评论政策'
when itemtype=48 then '其他违反政策'
when itemtype=49 then '违反政策警告'
when itemtype=50 then '商品安全买家投诉'
end itemtype_name
,MetricsType,count ,list.ahrscore
from erp_amazon_amazon_shop_performance_checkv2_detail detail
left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms  on list.shopcode=ms.Code  and ms.Department='快百货'
where MetricsType=10 and date(detail.CreationTime)='${NextStartDay}' -- v2表落库时间是统计日的凌晨
and itemtype in ('40','41','42','45','46','48','49')
)

,t1 as (
select shopcode
     ,sum(count) 店铺的违规记录总数
     ,case when sum(count) >= 5 then '超5条' end 单店违规数超标
     ,sum(case when itemtype  in ('40','41','42','46')  then count end ) 商品原因违规记录数
from perf group by shopcode
)

,t2 as ( -- 0至200分的正常店铺
select distinct ShopCode
from erp_amazon_amazon_shop_performance_check ahr
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
      from import_data.mysql_store where department regexp '快')  ms  on ahr.shopcode=ms.Code  and ms.Department='快百货'
where date(CreationTime)='${NextStartDay}' and ms.shopstatus = '正常' and ahrscore<200 )

,merge as (
select
    date('${NextStartDay}') 数据更新日期
    ,case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域
    ,NodePathName 销售小组
    ,SellUserName 首选业务员
    ,ms.Code 店铺简码
    ,ms.CompanyCode 账号简码
    ,ms.Site 站点
    ,店铺的违规记录总数
    ,单店违规数超标
    ,商品原因违规记录数
    ,ShopStatus 店铺状态
    ,case when t2.ShopCode is not null and ShopStatus='正常' then '达标'  end 0至200分的正常店铺
from mysql_store ms
left join t1 on ms.Code=t1.ShopCode
left join t2 on ms.Code=t2.ShopCode
where ms.Department='快百货'
)

select * from merge order by 店铺的违规记录总数 desc