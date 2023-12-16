
-- 统计期内首次出单的SPU，计算单产=每个SPU30天内累计出单金额求和 ÷ 出单SPU数
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `首单30天SPU单产`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
join  ( -- 统计周往前推30天那周首次出单的SPU,为了给够30天
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '付款'  and OrderStatus <> '作废'
GROUP BY grouping sets ((),(dep2));




-- 统计期内首次出单的SPU，只看本部门开发的产品出单
-- 成都开发
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd_DevbySelf )
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `首单30天SPU单产_成都开发`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
join  ( -- 统计周往前推30天那周首次出单的SPU,为了给够30天
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
join  ( -- 只看本部门开发产品的出单
    select distinct staff_name, level2_name from import_data.dim_staff  where level2_name='快百货一部' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
    ) ds_cd on wo.Product_DevelopUserName = ds_cd.staff_name
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '付款'  and OrderStatus <> '作废';
-- 泉州开发
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd_DevbySelf )
select '${StartDay}' ,'${ReportType}' ,'快百货二部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `首单30天SPU单产_成都开发`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
join  ( -- 统计周往前推30天那周首次出单的SPU,为了给够30天
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
join  ( -- 只看本部门开发产品的出单
    select distinct staff_name, level2_name from import_data.dim_staff  where level2_name='快百货二部' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
    ) ds_cd on wo.Product_DevelopUserName = ds_cd.staff_name
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '付款'  and OrderStatus <> '作废';



-- 首单SPU数
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	FirstSaleSpuCnt )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.product_spu) `首单SPU数`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where DepSpuMinPayTime >='${StartDay}' and DepSpuMinPayTime < '${NextStartDay}'
GROUP BY grouping sets ((),(dep2));

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	FirstSaleSpuCnt )
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.product_spu) `首单SPU数`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where DepSpuMinPayTime >='${StartDay}' and DepSpuMinPayTime < '${NextStartDay}'
GROUP BY NodePathName;
