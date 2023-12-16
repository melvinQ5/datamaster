-- 1
select department
    ,b_deliv ������
     ,round(a_deliv_in7d/b_deliv,4) `����7�췢����`
	,round(a_deliv_in5d/b_deliv,4) `����5�췢����`
from
	(select ifnull(department,'�ϼ�') department
	    , count(distinct od_pre.OrderNumber ) b_deliv -- 7�췢���ʷ�ĸ
		, count(distinct case when timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
        , count(distinct case when  timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
        and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	from
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join mysql_store  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����' and ms.Department regexp '��ٻ�|������'
		where PayTime <  date_add('${NextStartDay}',interval -7 day)  and PayTime >= '${StartDay}' -- ��7��ĸ����������
		) od_pre
	left join import_data.daily_PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	group by grouping sets ((),(department))
	) tmp1;


-- ������Ͷ��
with a as (
select
    v2.OnTimeDeliveryCount ׼ʱ������������
    ,t0.OnTimeDeliveryRate  ׼ʱ������
    ,ifnull( ceil(OnTimeDeliveryCount / OnTimeDeliveryRate*100) ,0 ) ƽ̨ͳ�ƶ�����
    ,t0.ShopCode
    ,ms.Department
from import_data.erp_amazon_amazon_shop_performance_checkv2_detail v2
join erp_amazon_amazon_shop_performance_check t0 on v2.AmazonShopPerformanceCheckId = t0.id
    and date(t0.CreationTime) = '2023-10-02'
	and ReportType = 48 and v2.ItemType = 24 and v2.DateType = 30 and v2.MetricsType = 20
join  mysql_store  ms on t0.shopcode=ms.Code  and ms.Department regexp '��ٻ�|������'
order by t0.ShopCode
)

select Department,
    sum(׼ʱ������������) ׼ʱ������������_��30��,
    sum(ƽ̨ͳ�ƶ�����) ƽ̨ͳ�ƶ�����_��30��,
    round( sum(׼ʱ������������) / sum(ƽ̨ͳ�ƶ�����) ,4 ) ׼ʱ������
from a group by Department;