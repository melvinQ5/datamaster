-- ��ٻ�
with
-- ��Part1 ���ݼ�����
dep as ( 
SELECT  sku as Code , BoxSku as Department
FROM JinqinSku js 
where js.Monday ='2023-02-08'
-- where js.BoxSku ='������'
)


, od as ( -- ������
select dep.Department, TotalGross, TotalProfit
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
left join dep on ms.Code = dep.code
where SettlementTime < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
)

select Department, sum(TotalGross)/6.7995 SaleAmount, sum(TotalProfit)/6.7995 ProfitAmount
from od 
group by Department 


, pt as ( -- product_type ��Ʒ�� (��Ʒ���ص㡢����) group by product_type
select Spu,  ProjectTeam ,DevelopLastAuditTime
from import_data.erp_product_products epp 
where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
	and IsMatrix = 1
)

, pt_wt as (
select Spu ,FirstOrderTimeCost , DevelopLastAuditTime, CreationTime ,FirstShangjiaTime 
from import_data.wt_products wp 
where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
)


-- , lw as ( -- local_warehouse ���زֱ�
-- )
-- , po as ( -- PurchaseOrder �ɹ���
-- )
-- , pd as ( -- PackageDetail������ 
-- )
-- ��Part2 ��һָ�꡿

-- , sales as ( -- ���۶�����  
select Department, sum(TotalGross)/6.7995 SaleAmount, sum(TotalProfit)/6.7995 ProfitAmount
from od 
group by Department 
)

, prod_spu as (  -- ��Ʒ����SPU��
select count(distinct Spu) new_spu_cnt
from pt 
-- where ProjectTeam in ('{dep1}')
)

, prod_sale_rate as ( -- ��ƷSPU N�춯���� 
select round(tmp.ord14_sku_cnt/prod_spu.new_spu_cnt,3) d14_rate ,round(tmp.ord30_sku_cnt/prod_spu.new_spu_cnt,3) d30_rate
from (
	select count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 14 then spu end) ord14_sku_cnt
	, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 30 then spu end) ord30_sku_cnt
from pt_wt) tmp,prod_spu
)

-- , prod_sale_amount as ( -- ��Ʒ30�쵥��
-- )

-- , ad_meric as ( -- ��Ʒ������ʡ�ת���� ��Ʒ����  ����ʱ����2023���Ʒ
-- select 
-- from 
-- )

-- , prod_time_cost ( -- ƽ����Ʒ��������  
-- select avg(timestampdiff(DAY,CreationTime,FirstShangjiaTime))
-- from import_data.wt_products wp 
-- where CreationTime  < '${NextFirstDay}' and CreationTime >= date_add('${NextFirstDay}',interval -3 month)
-- and FirstShangjiaTime  < '${NextFirstDay}' and FirstShangjiaTime >= date_add('${NextFirstDay}',interval -1 month)

-- �������״ο���  -- todo ���·ֲ����
-- select timestampdiff(DAY,CreationTime,FirstShangjiaTime)
-- from import_data.wt_products wp 
-- where FirstShangjiaTime  < '${NextFirstDay}' and FirstShangjiaTime >= date_add('${NextFirstDay}',interval -1 month)
)


, weight_ontime ( -- ׼ʱ������ 
select 1-A_cnt/B_cnt `2�������ճٷ���` 
from 
(select count(distinct dod.PlatOrderNumber) as A_cnt  
from 
  (select 
    case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
    end as latest_WeightTime ,paytime ,DAYOFWEEK(OrderCountry_paytime)
    ,PlatOrderNumber
  from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime
    from import_data.daily_OrderDetails  od
    join ( -- ֻ������״̬�Ƕ���Ķ�������
      select DISTINCT ShopCode 
      from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
      join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
      where AmazonShopHealthStatus != 4 
      and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
      ) tmp on tmp.shopcode = od.ShopIrobotId
    left join
      (SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area  
      FROM import_data.JinqinSku where monday='2023-12-20' ) js on js.code=right(od.ShopIrobotId ,2) 
    where PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
      and TransactionType ='����' and totalgross > 1  
    ) tmp
  )dod
left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber  
where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
) A
,(SELECT count(distinct PlatOrderNumber) B_cnt
from import_data.daily_OrderDetails dod 
join ( -- ֻ������״̬�Ƕ���Ķ�������
  select DISTINCT ShopCode 
  from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
  join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
  where AmazonShopHealthStatus != 4 
  and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
  ) tmp on tmp.shopcode = dod.ShopIrobotId
where 
  PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
  and TransactionType ='����' and totalgross > 1
) B  -- ����ʱ����������������ǰ��7�죬 ��������ʱ��
)

, delivery_ontime as ( -- ׼ʱ��Ͷ��
-- ׼ʱ������
-- OrderCountΪnull�����ʹ�� ����/����=��ĸ
-- ׼ʱ�����ʲ������� count=0 rate=0, �����ȫ�����,�൱��ֻ��¼�˲�׼ʱ���ⲿ�ֵĽ����ʣ�
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- ׼ʱ������
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- ״̬�쳣���̱���
from (
select
	count( distinct case when OnTimeDeliveryStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- ����+Σ�գ��������ƶ���
	,count( distinct case when OnTimeDeliveryStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when OnTimeDeliveryStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OnTimeDeliveryStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=9 and eaaspcd.Count>0 then tmp.ShopCode  end) as OnTimeDelivery_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OnTimeDeliveryStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)



, po_product as ( -- `�ɹ���Ʒ���`

)


, po_Freight as ( -- `�ɹ��˷�`
)


, delivery_purchase_amount as ( -- `���������ɹ����usd`
)





, metric_set as (
select lw.category, lw.department, lw.ReportType, lw.static_date, lw.product_tupe
  ,lw.`�ڲֲ�Ʒ���`, lw.`�ڲ�sku����`, lw.`�ڲ�sku��`, pp.`�ɹ���Ʒ���`, pf.`�ɹ��˷�`, dpa.`���������ɹ����usd`
  ,lssr.`�����ڲ�SKU������`
from local_w lw
left join po_product pp
  on lw.category=pp.category and lw.department=pp.department 
  and lw.ReportType=pp.ReportType and lw.static_date=pp.static_date and lw.product_tupe=pp.product_tupe
left join more  -- ����ı�
)

-- -- ����3���� ���ϼ���ָ�꡿
select category, department, ReportType, static_date, product_tupe
  round((`�ڲֲ�Ʒ���`+`�ɹ���Ʒ���`+`�ɹ��˷�`)/usdratio) as `���ؿ����`
  , round((`�ڲֲ�Ʒ���`+`�ɹ���Ʒ���`+`�ɹ��˷�`)/usdratio/`���������ɹ����usd`*7)  as `���زֿ����ת����`
from metric_set m