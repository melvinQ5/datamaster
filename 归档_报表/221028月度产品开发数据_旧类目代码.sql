-- ԰�ֹ������ÿ���¿�����SKU��
/*
1.���տ�������ʱ�������´ε�ͳ��
2.����week of year�����Ǽ�����´���1�������˹�
*/
select'����'`������Ա`,'����'`��Ʒ��Ŀ`,month(DevelopLastAuditTime) `�����´�`, count(*) `ÿ������ͨ��SKU��` from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-02'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `�����´�`
order by `�����´�`
union all

select'��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`, month(DevelopLastAuditTime) `�����´�`, count(pp.sku) `ÿ������ͨ��SKU��` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `�����´�`
order by `�����´�`

union all

select'����1688'`������Ա`,'���'`��Ʒ��Ŀ`, month(DevelopLastAuditTime) `�����´�`, count(*) `ÿ������ͨ��SKU��` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0  and pp.skusource=1
and month(DevelopLastAuditTime)='${cnt_month}'

group by `�����´�`
order by `�����´�`

union all

select'��÷'`������Ա`,'���'`��Ʒ��Ŀ`, month(DevelopLastAuditTime) `�����´�`, count(*) `ÿ������ͨ��SKU��` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `�����´�`
order by `�����´�`
union all

select'����ϼ'`������Ա`,'���'`��Ʒ��Ŀ`, month(DevelopLastAuditTime) `�����´�`, count(*) `ÿ������ͨ��SKU��` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `�����´�`
order by `�����´�`

union all

select'�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`, month(DevelopLastAuditTime) `�����´�`, count(*) `ÿ������ͨ��SKU��` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
and month(DevelopLastAuditTime)='${cnt_month}'
group by `�����´�`
order by `�����´�`;




-- =======================================================================================================================================================================
-- ͳ��԰�ֹ������ÿ�µĳ���SKU�Ŀ����´�
/* 
1.SKU��Χ=԰�ֹ��ߵ�SKU
2.������Χ������2����3���Ķ�������������ϣ����۶����O��
3.���տ�������ʱ�������´ε�ͳ��
4.����week of year�����Ǽ�����´���1�������˹�

ʹ�÷����޸� ������ͳ���´ε�ֵ month(od.PayTime) =��
*/


select '����'`������Ա`,'����'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '����1688'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`


union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '��÷'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '����ϼ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select '�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`
order by `�����´�`
union all

select '����'`������Ա`,'����'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '����1688'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`


union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '��÷'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '����ϼ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select '�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`,`���۲���`
order by `�����´�`;






-- ͳ�Ʋ�ͬ�´ο�����SKU��ÿ�µ�����������
/*
1.�޸�EndDayΪ���µ�ÿ��һ
2.����=����+��������
*/

select'����'`������Ա`, '����'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select'��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`, month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select'����1688'`������Ա`, '���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select'��÷'`������Ա`,'���'`��Ʒ��Ŀ`, '�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '����ϼ' `������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select'�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.sku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`
order by `�����´�`


union all

select'����'`������Ա`, '����'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select'��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`, month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select'����1688'`������Ա`, '���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select'��÷'`������Ա`,'���'`��Ʒ��Ŀ`, s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '����ϼ' `������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select'�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(al.Id)`����������`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('���۶���', '��������') and s.ShopStatus='����'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.sku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`,`���۲���`
order by `�����´�`;




-- =======================================================================================================================================================================
-- ͳ��԰�ֹ������ÿ�µĳ���SKU�Ŀ����´�--�ۼƼ���
/* 
1.SKU��Χ=԰�ֹ��ߵ�SKU
2.������Χ������2����3���Ķ�������������ϣ����۶����O��
3.���տ�������ʱ�������´ε�ͳ��
4.����week of year�����Ǽ�����´���1�������˹�

ʹ�÷����޸� ������ͳ���´ε�ֵ month(od.PayTime) =��
*/


select '����'`������Ա`,'����'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '����1688'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`


union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '��÷'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all
select '����ϼ'`������Ա`,'���'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`
order by `�����´�`

union all

select '�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,'�ܼ�'`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`
order by `�����´�`
union all

select '����'`������Ա`,'����'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ�������','A7�ҾӺͻ�԰>A7԰����Ʒ>A7԰�ֹ���>��ݻ������')
and pp.DevelopUserName='����'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '����1688'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`


union all

select '��ٻ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��ٻ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '��÷'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='��÷'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all
select '����ϼ'`������Ա`,'���'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='����ϼ'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `�����´�`,`���۲���`
order by `�����´�`

union all

select '�µ���'`������Ա`, 'GMתPM'`��Ʒ��Ŀ`,s.Department`���۲���`,month(pp.DevelopLastAuditTime) `�����´�`, count(distinct(od.BoxSku)) `�¶ȳ���SKU��` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `�¶����۶�USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `�¶������USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `�¶�������` , count(distinct(od.PlatOrderNumber))`������`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`����������`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('���۶���', '��������')
left join import_data.Basedata b on b.ReportType = '�±�' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('��÷','����ϼ''����1688','����')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `�����´�`,`���۲���`
order by `�����´�`;








