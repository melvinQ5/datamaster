-- �����ȼۡ��汾�ȼ�
(
-- ά�ȣ�ά������
-- ͳ���ڣ���ʷ����
-- ָ�꣺����ָ�꼰��ÿ��ָ�����������������
-- ƽ��ʱЧ����׼ʱЧ�Աȡ��ܰ���������Ͷ�ʡ���׼��Ͷ�ʡ��쳣�����������۳ɱ�CNY

-- ָ�꣺�˿���(�˿�ԭ��Ϊ������ԭ����˿���/�ѷ����������)������
select B.TransportType ,a/b `����ԭ���˿���` 
from (SELECT TransportType ,sum(TotalGross/ExchangeUSD ) b
	from import_data.OrderDetails dod  
	where TransactionType ='����' and OrderStatus <> '����' and OrderTotalPrice > 0 and shiptime >'2000-01-01' 
	group by TransportType
	) B 
left join 
	(select TransportType ,sum(ro.RefundUSDPrice) a 
	FROM import_data.daily_RefundOrders ro
	where  RefundReason1 = '����ԭ��' and ShipDate>'2000-01-01' 
	group by TransportType 
	) A on B.TransportType = A.TransportType

-- select RefundReason1 , RefundReason2 ,count(1)
-- from import_data.RefundOrders ro 
-- group by RefundReason1 , RefundReason2 
	
-- ����ָ��
select TransportId ,TransportType 
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- ƽ��ʱЧ
		,count(PackageNumber) TotalPackageCount -- ������
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- ��Ͷ������
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- ��׼ʱЧ����Ͷ������
		,sum(PackageFeight) TotalPackageFeight -- ���˷�
		,sum(PackageTotalWeight) TotalPackageTotalWeight -- ������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
group by TransportId ,TransportType

-- �쳣�������쳣׷�ٱ�ֻ�ſ����쳣�Ͳ�ѯ�����İ���
select TransportId ,TransportType ,count(PackageNumber) ExceptionPackageCnt -- �쳣������
from import_data.erp_logistic_logistic_exception_trackings ellet 
join import_data.erp_logstic_logistics_tracking ellt on ellet.Id  = ellt.LogisticTrackingId 
group by TransportId ,TransportType

-- ����ָ��
-- ��׼ʱЧ�Ա� = ��׼ʱЧ-ƽ��ʱЧ  StandardMaxTime - avg_deliver_cost
-- ��Ͷ��=��Ͷ������/�ܰ�����
-- ��׼��Ͷ��=��׼ʱЧ����Ͷ������/�ܰ�����
-- ���۳ɱ�CNY=�������˷�/����������
-- ��ָ���������� row_number()
)

-- ����̨
(

-- ָ�꿨1 �ܰ����� ƽ����Ͷ�� ��׼��Ͷ��
select TransportId ,TransportType 
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- ƽ��ʱЧ
		,count(PackageNumber) TotalPackageCount -- ������
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- ��Ͷ������
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- ��׼ʱЧ����Ͷ������
		,sum(PackageFeight) TotalPackageFeight -- ���˷�
		,sum(PackageTotalWeight) TotalPackageWeight -- ������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
group by TransportId ,TransportType


-- ָ�꿨2 ���쳣���� �쳣������
select 
	count(ellet.PackageNumber) ExceptionPackageCnt -- �쳣������
	,round(count(ellet.PackageNumber)/count(ellt.PackageNumber),2) -- �쳣������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistic_exception_trackings ellet on ellet.Id  = ellt.LogisticTrackingId 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'

-- ָ�꿨3 ƽ��ʱЧ
-- ָ�꿨4 ���˷Ѷ� �˷Ѷ�ռ��������
-- ָ�꿨5 ƽ�������ʣ�����������/�ܰ��������� ��׼�����ʣ�24Сʱ������ռ�ȣ�


-- ͼ��1 �����쳣�� ���쳣�������������� ǰ11����
select 
	ExceptionType
	,count(ellet.PackageNumber) ExceptionPackageCnt -- �쳣������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistic_exception_trackings ellet on ellet.Id  = ellt.LogisticTrackingId 
group by ExceptionType
order by ExceptionPackageCnt desc 
limit 11 



-- ͼ��2 �����ֲ���� ��ͬ����״̬�İ���ռ�ȺͰ�����
select TrackingStatus ,count(PackageNumber) StatusPackageCnt
from import_data.erp_logstic_logistics_tracking ellt 
group by TrackingStatus 


-- ͼ��3 ƽ������ʱЧ����һ�ܣ�
select round(sum(OnLineHour)/count(PackageNumber),1) AvgOnlineHour
from import_data.erp_logstic_logistics_tracking ellt 
where OnlineTime  >= CURRENT_DATE()-7 

-- ͼ��4 ������Ͷ�� 
select MerchantId, MerchantName ,TransportId ,TransportType
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- ƽ��ʱЧ
		,count(PackageNumber) TotalPackageCount -- ������
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- ��Ͷ������
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- ��׼ʱЧ����Ͷ������
		,sum(PackageFeight) TotalPackageFeight -- ���˷�
		,sum(PackageTotalWeight) TotalPackageTotalWeight -- ������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
group by MerchantId, MerchantName ,TransportId ,TransportType

)

-- ���ƿ���_�����ֲ�
(
-- ָ�꿨1 ƽ������
select 
	sum(PackageTotalWeight) TotalPackageTotalWeight -- ������
	,count(PackageNumber) TotalPackageCount -- ������
	,sum(PackageTotalWeight)/count(PackageNumber) avgPackageWeight  -- ƽ������
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'

-- ͼ��1 �������� x �������� �İ����� 
select TransportId ,TransportType  ,WeightBins ,WeightDate ,count(1)  `����������`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case when PackageTotalWeight <=10 then '10g����'
				when PackageTotalWeight >10 and PackageTotalWeight <=30 then '11-30g'
				when PackageTotalWeight >31 and PackageTotalWeight <=50 then '31-50g'
				when PackageTotalWeight >51 and PackageTotalWeight <=100 then '51-100g'
				when PackageTotalWeight >101 and PackageTotalWeight <=200 then '101-200g'
				when PackageTotalWeight >201 and PackageTotalWeight <=500 then '201-500g'
				when PackageTotalWeight >501 and PackageTotalWeight <=1000 then '501-1000g'
				when PackageTotalWeight >1000  then '1000g����'
			end WeightBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,WeightBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

)

-- ���ƿ���_���Ʒֲ�
(
-- ά�� Ŀ�ĵع��� x �������� �������� x �������� ���������� x �������� 
-- ָ�� ����������ƽ�������أ����������쳣���������쳣�����ʣ���Ͷ�ʣ���׼��Ͷ�ʣ������ʣ�
-- ָ�� 24Сʱ��׼�����ʣ����˷Ѷƽ���˷ѵ��ۣ���������������ƽ�����������������ʣ��˿���

)


-- ���ƿ���_����ȫ��ʱЧ���ڵ�ʱЧ��������������;�У������ȡ������;�У��ɹ�ǩ�գ�
(
-- ά��
-- ָ��
select TransportId ,TransportType  ,TimeBins ,WeightDate ,count(1)  `����������`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case 
				when DeliverHour > 0 and DeliverHour <= 5*24 then '0-5��'
				when DeliverHour > 5*24 and DeliverHour <= 10*24 then '6-10��'
				when DeliverHour > 10*24 and DeliverHour <= 15*24 then '11-15��'
				when DeliverHour > 15*24 and DeliverHour <= 20*24 then '16-20��'
				when DeliverHour > 20*24 and DeliverHour <= 25*24 then '21-25��'
				when DeliverHour > 25*24 and DeliverHour <= 30*24 then '26-30��'
				when DeliverHour > 30*24  then '30������'
			end TimeBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,TimeBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

-- ��ʼ�ڵ�ѡ������;�С��������ڵ�ѡ������;�С�  ������ʱЧָ��= ����;��ʱ��-
-- չʾ���1����
	
)


-- ���ƿ���_�����˷ѣ��˷ѷ����䣩
(

select TransportId ,TransportType  ,TimeBins ,WeightDate ,count(1)  `����������`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case 
				when PackageFeight > 0 and PackageFeight <= 5 then '0-5'
				when PackageFeight > 5 and PackageFeight <= 20 then '5-20'
				when PackageFeight > 20 and PackageFeight <= 50 then '20-50'
				when PackageFeight > 50 and PackageFeight <= 100 then '50-100'
				when PackageFeight > 100 and PackageFeight <= 200 then '100-200'
				when PackageFeight > 200 and PackageFeight <= 500 then '200-500'
				when PackageFeight > 500  then '500����'
			end TimeBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking ellt 
		join import_data.wt_orderdetails wo on ellt.PlatOrderNumber = d 
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,TimeBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

)


-- ����ʱЧ����  
-- ��erp_amazon_amazon_logistics_tracking ��һ����ʱ����ʽϵͳ���ߺ�ᱻ�滻Ϊ erp_logstic_logistics_tracking��
select to_date(WeightTime) `��������`, LogisticName `������`, wp.TransportType `��������`,wp.WarehouseName `�����ֿ�` 
	,count(distinct wp.PackageNumber ) `��������`
	,sum(PackageTotalWeight) `����������g` 
	,round(sum(PackageFeight),2) `�������˷�CNY`
	,count(distinct case when wp.OnlineHour < 24 then wp.PackageNumber end) `24Сʱ������������`
	,count(distinct case when wp.OnlineHour >= 24 and wp.OnlineHour < 48 then wp.PackageNumber end) `48Сʱ������������`
	,count(distinct case when wp.OnlineHour >= 48 and wp.OnlineHour < 72 then wp.PackageNumber end) `72Сʱ������������`
	,count(distinct case when wp.OnlineHour > 72 then wp.PackageNumber end) `��72Сʱ��������`
	,count(distinct case when wp.OnlineHour is null then wp.PackageNumber end) `δ����������`
from import_data.wt_packagedetail wp 
join import_data.erp_amazon_amazon_logistics_tracking eaalt on wp.PackageNumber  = eaalt.PackageNumber -- ʹ��Ŀǰ���ܵ�17track����
group by LogisticName , wp.TransportType ,wp.WarehouseName, to_date(WeightTime)
