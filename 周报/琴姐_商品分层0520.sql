with torttype as 
(select pp.sku,GROUP_CONCAT(
case torttype
when 1 then '版权侵权'
when 2 then '商标侵权'
when 3 then '专利侵权'
when 4 then '违禁品'
when 5 then '不侵权'
when 6 then '律所侵权'
end )torttype_name

FROM import_data.erp_product_product_tort_types pt
join import_data.erp_product_products pp on pp.id=pt.ProductId
where pp.sku is not null and pp.ismatrix=0 and  pp.IsDeleted=0
group by pp.sku
)


,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products epp on eppaea.sku = epp.sku 
where epp.ProjectTeam ='快百货' and epp.IsMatrix=0 and epp.IsDeleted=0
group by eppaea.sku 
)


,pp as ( -- 按照sku维度统计一些产品相关属性
select a.SKU ,a.SPU ,a.boxsku,ProjectTeam,date(a.DevelopLastAuditTime)AuditTime,a.productname,ele_name,torttype_name,
case productstatus
when 0 then '正常'
when 2 then '停产'
when 3 then '停售'
when 4 then '暂时缺货'
when 5 then '清仓'
end productstatus
from import_data.erp_product_products a
left join torttype b on a.sku=b.sku
left join t_elem c on c.sku=a.sku
where IsMatrix = 0 and IsDeleted = 0 
-- and ProjectTeam ='快百货' 
group by a.SKU ,a.SPU ,a.boxsku,ProjectTeam,a.DevelopLastAuditTime,a.productname,ele_name,torttype_name,productstatus
)


, t_od as ( -- 统计近30天动销的链接asin+site，去掉shopfee
select wo.asin,ms.site,boxsku, round(sum((totalgross-feegross)/ExchangeUSD),2) sales,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,date(min(paytime)) mintime, datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))saledays,count(distinct date(PayTime))solddays,round(sum((totalgross-feegross)/ExchangeUSD)/( datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))),2) `日均销量`,row_number() over(order by count(distinct platordernumber) desc ) as ordersort,row_number() over(order by  round(sum((totalgross-feegross)/ExchangeUSD),2)  desc ) as salessort

from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 
where wo.IsDeleted = 0 and PayTime >=date(date_add(CURRENT_DATE(),INTERVAL -32 day)) and PayTime<date(date_add(CURRENT_DATE(),INTERVAL -2 day))   
and boxsku!='shopfee' and asin <>'' and boxsku <>''
group by ms.site,wo.asin,boxsku
order by sales desc
)



,t_odsku as ( -- 按照sku聚合业绩数据
select boxsku, round(sum(sales),2) sales,round(sum(profit),2)profit,sum(orders)orders,round(sum(freightfee),2) freightfee,date(min(mintime)) mintime,datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(mintime)))saledays,max(solddays)solddays,round(sum(orders)/max(solddays),2) `日均销量`,round(sum(case when site='UK' then sales end),2) as uksale,round(sum(case when site='DE' then sales end),2) as desale,round(sum(case when site='FR' then sales end),2) as frsale,round(sum(case when site='US' then sales end),2) as ussale
from t_od
group by boxsku
)


,addetail as ( -- 统计近30天动销的链接的sku的广告数据
select al.sku,pp.boxsku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales  
from AdServing_Amazon ads 
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
left join mysql_store ms on ms.code=ads.shopcode
left join pp on pp.sku=al.sku
where createdtime>= date(date_add(CURRENT_DATE(),INTERVAL -32 day)) and createdtime<= date(date_add(CURRENT_DATE(),INTERVAL -2 day)) 
and al.sku<>''  
group by  al.sku,pp.boxsku having pp.boxsku is not null
order by sum(spend) desc
)


, sitecal as ( -- 近30天数据聚合
select t_odsku.boxsku boxsku1,pp.SKU ,SPU ,ProjectTeam,AuditTime,productname,ele_name,torttype_name,productstatus,row_number() over(order by sum(sales)desc ) as salesort,row_number() over(order by sum(orders)desc ) as ordersort,round(sum(sales),2) sales,round(sum(profit),2)profit
,sum(orders)orders,round(sum(freightfee),2)freightfee
,max(solddays)`销售天数`,round(sum(orders)/max(solddays),2) `日均销量`,
sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(adorders) adorders,sum(adsales) adsales,round(sum(clicks)/sum(exposure),4) ctr,round(sum(adorders)/sum(clicks),4) cvr,round(sum(spend)/sum(clicks),4) cpc, round(sum(SPEND)/sum(adsales),4) acost, round(sum(adsales)/sum(spend),2) ROI,
round(sum(uksale) ,2)as uksale,round(sum(desale),2) as desale,round(sum(frsale),2) as frsale,round(sum(ussale),2) as ussale
from t_odsku
left join pp on pp.boxsku=t_odsku.boxsku
left join addetail on addetail.boxsku=t_odsku.boxsku
group by t_odsku.boxsku,pp.SKU ,SPU ,AuditTime,productname,ele_name,torttype_name,productstatus,ProjectTeam
order by  sales desc
)



, lastmontht_od as ( -- 统计上个月动销的链接asin+site
select wo.asin,ms.site,boxsku, round(sum((totalgross-feegross)/ExchangeUSD),2) sales,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit,round( sum((totalprofit-feegross))/sum((totalgross-feegross)),4) profitrate,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2) refund,date(min(paytime)) mintime, datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))saledays,count(distinct date(PayTime))solddays,round(sum((totalgross-feegross)/ExchangeUSD)/( datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))),2) `日均单数`,row_number() over(order by count(distinct platordernumber) desc ) as ordersort,row_number() over(order by  round(sum((totalgross-feegross)/ExchangeUSD),2)  desc ) as salessort
from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 

where wo.IsDeleted = 0 and PayTime >=date(date_add(CURRENT_DATE(),INTERVAL -62 day)) and PayTime<date(date_add(CURRENT_DATE(),INTERVAL -32 day))
and boxsku!='shopfee' and asin <>'' and boxsku <>''
group by ms.site,wo.asin,boxsku
order by sales desc
)

,last_odsku as(
select boxsku, round(sum(sales),2) sales,round(sum(profit),2)profit,sum(orders)orders,round(sum(freightfee),2) freightfee,date(min(mintime)) mintime,datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(mintime)))saledays,max(solddays)solddays,round(sum(orders)/max(solddays),2) `日均销量`,round(sum(case when site='UK' then sales end),2) as uksale,round(sum(case when site='DE' then sales end),2) as desale,round(sum(case when site='FR' then sales end),2) as frsale,round(sum(case when site='US' then sales end),2) as ussale
from lastmontht_od
group by boxsku
)


,lastaddetail as ( -- 统计上个月的链接的sku的广告数据
select al.sku,pp.boxsku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales  from AdServing_Amazon ads 
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
left join mysql_store ms on ms.code=ads.shopcode
left join pp on pp.sku=al.sku
where createdtime>= date(date_add(CURRENT_DATE(),INTERVAL -62 day)) and createdtime<= date(date_add(CURRENT_DATE(),INTERVAL -32 day)) 
and al.sku<>''
group by  al.sku,pp.boxsku having pp.boxsku is not null
)


, lastmonthsitecal as ( -- 近30天数据聚合
select last_odsku.boxsku,pp.SKU ,SPU ,AuditTime,productname,ele_name,torttype_name,productstatus,round(sum(sales),2) lastsales,round(sum(profit),2)lastprofit
,sum(orders)lastorders,round(sum(freightfee),2) lastfreightfee,date(min(mintime)) mintime,
datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(mintime)))saledays,max(solddays)lastsolddays,round(sum(orders)/max(solddays),2) `上个30天日均销量`,
round(sum(uksale),2) as lastuksale,round(sum(desale),2) as lastdesale,round(sum(frsale),2) as lastfrsale,round(sum(ussale),2) as lastussale,
sum(exposure)lastexposure,sum(clicks)lastclicks,sum(spend) lastspend,sum(adorders) lastadorders,sum(adsales) lastadsales,round(sum(clicks)/sum(exposure),4) lastctr,round(sum(adorders)/sum(clicks),4) lastcvr,round(sum(spend)/sum(clicks),4) lastcpc, round(sum(SPEND)/sum(adsales),4) lastacost, round(sum(adsales)/sum(spend),2) lastROI,row_number() over(order by sum(sales)desc ) as lastsalesort,row_number() over(order by sum(orders)desc ) as lastordersort

from last_odsku
join pp on pp.boxsku=last_odsku.boxsku
left join lastaddetail on lastaddetail.boxsku=last_odsku.boxsku
group by last_odsku.boxsku,pp.SKU ,SPU ,AuditTime,productname,ele_name,torttype_name,productstatus
order by lastsales desc
)

,asincount as(
select b.boxsku,SellUserName,NodePathName,Slist,lastSlists from
(
select pp.boxsku,count(distinct concat(t_od.asin,t_od.site))Slist ,GROUP_CONCAT(SellUserName)SellUserName,GROUP_CONCAT(NodePathName) NodePathName from t_od 
join import_data.wt_listing wl on t_od.asin=wl.asin and t_od.site=wl.MarketType
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join pp on pp.boxsku=t_od.boxsku
where wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and wl.sku<>'' and wl.asin<>''
  and orders>=15
group by pp.boxsku
)b
left join(
select boxsku,count(distinct concat(asin,site)) lastSlists from lastmontht_od 
where orders>=15
group by boxsku) a on a.boxsku=b.boxsku
)

,alistcount as(
select b.boxsku,SellUserName,NodePathName,alist,lastalists from
(
select pp.boxsku,count(distinct concat(t_od.asin,t_od.site))alist ,GROUP_CONCAT(SellUserName)SellUserName,GROUP_CONCAT(NodePathName) NodePathName from t_od 
join import_data.wt_listing wl on t_od.asin=wl.asin and t_od.site=wl.MarketType
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join pp on pp.boxsku=t_od.boxsku
where wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and wl.sku<>'' and wl.asin<>''
  and orders>=5 and orders<15
group by pp.boxsku
)b
left join(
select boxsku,count(distinct concat(asin,site)) lastalists from lastmontht_od 
where orders>=5 and orders<15
group by boxsku) a on a.boxsku=b.boxsku
)

,onlinelist as(
select pp.BoxSku ,count(distinct concat(asin,site)) listings
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join pp on pp.sku=wl.sku
where wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and wl.sku<>'' and wl.asin<>''
	group by pp.BoxSku)
-- 
-- -- 
-- 
,sku as(
select distinct a.boxsku,spu spu1 from (
select boxsku from t_odsku where sales is not null
union all 
select boxsku from last_odsku where sales is not null
)a
left join pp on pp.boxsku=a.boxsku
)
-- 
,skuresult as(
select sku.boxsku,sku.spu1,a.*
, if(spend is null,round(profit/sales,4),round((profit-spend)/sales,4) )profitrate,if(spend is null,profit,round(profit-spend,2))`扣广告利润额(不含运费)`,if(spend is null,round(profit+freightfee,2),round((profit-spend+freightfee),2))`扣广告含运费利润额`,round(uksale/sales,4) uksalerate,round(desale/sales,4)desalerate,round(frsale/sales,4)frsalerate,round(ussale/sales,4)uksalerate
,listings,Slist,alist,c.SellUserName,c.NodePathName
,lastSlists,lastsalesort,lastordersort,lastsales,lastprofit
,if(lastspend is null,round(lastprofit/lastsales,4),round((lastprofit-lastspend)/lastsales,4)) lastprofitrate,lastorders,lastfreightfee,lastsolddays
,`上个30天日均销量`,lastuksale,lastdesale,lastfrsale,lastussale,lastexposure,lastclicks,lastspend,lastadorders,lastadsales,lastctr,lastcvr,lastcpc,lastacost,lastROI 
from sku 
left join sitecal a on a.boxsku1=sku.boxsku
left join lastmonthsitecal b on sku.boxsku=b.boxsku
left join asincount c on c.boxsku=sku.boxsku
left join alistcount f on f.boxsku=sku.boxsku
left join onlinelist d on d.boxsku=sku.boxsku
order by salesort 
)



-- 
,spuresult as(
select skuresult.spu1 spu,count(distinct case when skuresult.productstatus<>'停产'and orders>0 then  skuresult.boxsku end) `出单且正常SKU数`,row_number() over(order by sum(sales)desc ) as salesort,row_number() over(order by sum(orders)desc ) as ordersort,round(sum(sales),2)sales,round(sum(profit),2)profit,sum(orders)orders,round(sum(freightfee),2)freightfee,round(sum(`扣广告利润额(不含运费)`),2)`扣广告利润额(不含运费)`
,round(sum(`扣广告含运费利润额`),2) `扣广告含运费利润额`
,round(sum(`扣广告利润额(不含运费)`)/sum(sales),2)`挂单利润率`
,max(`销售天数`)`销售天数`,round(sum(orders)/max(`销售天数`),2)`日均单数`,sum(exposure)exposure,sum(clicks)clicks,sum(spend)spend,sum(adorders) adorders,sum(adsales) adsales,round(sum(clicks)/sum(exposure),4) ctr,round(sum(adorders)/sum(clicks),4) cvr,round(sum(spend)/sum(clicks),4) cpc, round(sum(SPEND)/sum(adsales),4) acost, round(sum(adsales)/sum(spend),2) ROI,
round(sum(uksale),2)uksale,round(sum(desale),2)desale,round(sum(frsale),2)frsale,round(sum(ussale),2)ussale,round(sum(uksale)/sum(sales),2)uksalerate,round(sum(desale)/sum(sales),2)desalerate,round(sum(frsale)/sum(sales),2)frsalerate,round(sum(ussale)/sum(sales),2)ussalerate,
sum(listings)listings,sum(Slist)Slist,GROUP_CONCAT(SellUserName)SellUserName,GROUP_CONCAT(NodePathName)NodePathName,sum(alist)alist,sum(lastSlists)lastSlists,row_number() over(order by sum(lastsales)desc ) as lastsalesort,row_number() over(order by sum(lastorders)desc ) as lastordersort,round(sum(lastsales),2) lastsales,round(sum(lastprofit),2)lastprofit,sum(lastorders)lastorders,round(sum(lastfreightfee),2) lastfreightfee,max(lastsolddays)`上个30天销售天数`,round(sum(lastorders)/max(lastsolddays),2)`上个30天日均单量`,round(sum(lastuksale),2) as lastuksale,round(sum(lastdesale),2) as lastdesale,round(sum(lastfrsale),2) as lastfrsale,round(sum(lastussale),2) as lastussale,sum(lastexposure)lastexposure,sum(lastclicks)lastclicks,sum(lastspend) lastspend,sum(lastadorders) lastadorders,sum(lastadsales) lastadsales,round(sum(lastclicks)/sum(lastexposure),4) lastctr,round(sum(lastadorders)/sum(lastclicks),4) lastcvr,round(sum(lastspend)/sum(lastclicks),4) lastcpc, round(sum(lastSPEND)/sum(lastadsales),4) lastacost, round(sum(lastadsales)/sum(lastspend),2) lastROI

from skuresult 
where skuresult.spu1<>'' 
group by skuresult.spu1

)


,lastresult as 
(
select (case when sales >=1500 then '爆款' when sales>=500 and sales<1500 then'旺款' end) as PLevel,(case when lastsales >=1500 then'爆款'  when lastsales>=500 and lastsales<1500 then'旺款' end) as lastPLevel ,spuresult.*
from spuresult
)




-- 
,asinmerge as
(
select distinct asin,site from (
select asin,site from t_od where sales is not null
union all 
select asin,site from lastmontht_od where sales is not null
)a
)


,LL as(
select wl.spu,PLevel,
(case when sum(orders)>=15 THEN 'S' when sum(orders)>=5 and sum(orders)<15 THEN 'A' END) LLevel,
t_od.asin,t_od.site,t_od.boxsku,round(sum(sales),2) sales,round(sum(profit),2)profit,sum(orders)orders,max(solddays)solddays,ROUND(sum(orders)/max(solddays),2)`日均单量`,ordersort,salessort,count(distinct concat(shopcode,sellersku)) `在线链接数`,
GROUP_CONCAT(SellUserName)SellUserName,GROUP_CONCAT(nodepathname)nodepathname
from asinmerge a
left join t_od on a.asin=t_od.asin and a.site=t_od.site
left join import_data.wt_listing wl on a.asin=wl.asin and a.site=wl.MarketType
join
(select spu,PLevel from lastresult
where PLevel is not null )a on a.spu=wl.spu
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and sku<>'' 
and t_od.orders>=1 and t_od.asin<>''
group by wl.spu,PLevel, t_od.asin,t_od.site,t_od.boxsku,ordersort,salessort having LLevel is not null
)

select wl.SKU ,PublicationDate ,SellerSKU ,ShopCode ,price
	,AccountCode  ,ms.Site ,ms.SellUserName ,ms.NodePathName,LL.*
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
left join LL on LL.asin=wl.asin and LL.site=wl.markettype 
where wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and ms.NodePathName in ('快次方-成都销售组','快次元-成都销售组')
	and wl.ListingStatus =1 and ms.shopstatus = '正常' and sku<>'' 
	and LLevel is not null