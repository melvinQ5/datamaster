
-- 原代码
with
ac as (
select AccountCode ,Code, min(creationtime)over (partition by AccountCode) as creationtime
from import_data.erp_user_user_platform_account_sites
)

, od1 as (
select AccountCode , count(1) `月度统计订单数`
from
	(
	select s.AccountCode , wo.PlatOrderNumber
	from import_data.wt_orderdetails wo
	inner join import_data.mysql_store s on wo.shopcode=s.Code/*部门维度*/
	where SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}'
		and wo.IsDeleted=0 and wo.TransactionType = '付款' and wo.orderstatus <> '作废' and  totalgross>0
	group by s.AccountCode , wo.PlatOrderNumber
	) tmp
group by AccountCode
)

, od2 as (
select AccountCode , count(1) `账号录入30天内出单数`
from
	(
	select s.AccountCode , wo.PlatOrderNumber
	from import_data.wt_orderdetails wo
	inner join import_data.mysql_store s on wo.shopcode=s.Code/*部门维度*/
	left join ac on wo.shopcode = ac.Code
	where timestampdiff(second, creationtime, SettlementTime)/86400  <= 30
		and wo.IsDeleted=0 and wo.TransactionType = '付款' and wo.orderstatus <> '作废' and  totalgross>0
	group by s.AccountCode , wo.PlatOrderNumber
	) tmp
group by AccountCode
)

, listing as (
select ws.AccountCode , count(1) `在线链接数`
from import_data.erp_amazon_amazon_listing  wl
inner join ac on wl.shopcode=ac.Code/*部门维度*/
join wt_store ws on wl.shopcode = ws.code
and ListingStatus =1  and ws.ShopStatus ='正常'
group by ws.AccountCode
)


select
	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `结算时间范围`
	,to_date(CURRENT_DATE()) `统计日期`
	,ms.AccountCode
	, `正常店铺数` ,`异常店铺数` ,`弃用店铺数` ,`休假中店铺数`  ,`关闭店铺数`
	,`在线链接数` ,`月度统计订单数` ,to_date(tmp.creationtime) `账号录入ERP日期` ,`账号录入30天内出单数`
from
	(select AccountCode
		, count( case when ShopStatus='正常' then code end ) `正常店铺数`
		, count( case when ShopStatus='异常' then code end ) `异常店铺数`
		, count( case when ShopStatus='弃用' then code end ) `弃用店铺数`
		, count( case when ShopStatus='休假中' then code end ) `休假中店铺数`
		, count( case when ShopStatus='关闭' then code end ) `关闭店铺数`
	from  import_data.mysql_store
	group by AccountCode
	) ms
left join (select AccountCode,creationtime from ac group by AccountCode,creationtime) tmp
	on ms.AccountCode = tmp.AccountCode
left join od1 on ms.AccountCode = od1.AccountCode
left join od2 on ms.AccountCode = od2.AccountCode
left join listing on ms.AccountCode = listing.AccountCode ;


-- 核查

select AccountCode ,code ,ShopStatus ,NodePathName,SellUserName
     ,count( distinct  wl.SellerSKU  ) as 刊登过链接数
    ,count( distinct case when eaal.ListingStatus=1 then eaal.SellerSKU end ) as 当前在线链接数
from mysql_store ms
left join import_data.wt_listing  wl on ms.Code = wl.ShopCode
left join import_data.erp_amazon_amazon_listing  eaal on ms.Code = eaal.ShopCode
where  AccountCode regexp 'ZU-NA|ZI-EU|ZI-NA|YH-EN'
group by AccountCode ,code ,ShopStatus ,NodePathName,SellUserName