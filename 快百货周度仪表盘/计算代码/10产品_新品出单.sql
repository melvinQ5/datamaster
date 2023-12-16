insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,SaleSpuCntIn90dDev ,SaleAmountIn90dDev ,SaleSpuCntIn90dDev_ele )
select '${StartDay}' ,'${ReportType}',ifnull(ms.dep2,'快百货'),'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) 新品出单SPU数
    ,round(sum(TotalGross/ExchangeUSD),2) 新品销售额
    ,count(distinct tag.spu ) 新品出单SPU数_主题
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
join ( select distinct spu from view_kbp_new_products ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '快'
group by grouping sets ((),(ms.dep2));



--  成都商品组开发产品的新品销售额 出单数
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SaleSpuCntIn90dDev_DevbySelf ,SaleAmountIn90dDev_DevbySelf )
select '${StartDay}' ,'${ReportType}','快百货一部','合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) 新品出单SPU数_本部门开发
    ,round(sum(TotalGross/ExchangeUSD),2) 新品销售额_本部门开发
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
join(select distinct spu from wt_products wp
    join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' and level2_name ='快百货一部'
        ) ds on wp.DevelopUserName = ds.staff_name
--     where date_add(DevelopLastAuditTime , interval - 8 hour) >=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)
    where date_add(DevelopLastAuditTime , interval - 8 hour)  >= '2023-07-01'
        and ProjectTeam = '快百货'
    ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '快';


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,SaleSpuCntIn90dDev ,SaleAmountIn90dDev ,SaleSpuCntIn90dDev_ele )
select '${StartDay}' ,'${ReportType}',nodepathname ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) 新品出单SPU数
    ,round(sum(TotalGross/ExchangeUSD),2) 新品销售额
    ,count(distinct tag.spu ) 新品出单SPU数_主题
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
join(select distinct spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >= '2023-07-01'
    and ProjectTeam = '快百货'
    ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' -- 每月会有几十到上百条订单数据没有ASIN
	and ms.department regexp '快'
group by nodepathname;
