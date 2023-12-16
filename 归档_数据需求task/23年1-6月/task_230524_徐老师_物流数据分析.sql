/*
ָ�꣺ ���������������� �� �˷� ���������۶� 
ά�ȣ�
1. �ռ����ң�1���� -> �����̣�2����
2. ������ ��1����-> �ռ����ң�2����
3. �����̣�1����-> �������� ��2����
4. ����Σ�0-50 / 50-100 / 100-200 / 200-500 / 500����
5. ������ ��1���� - > ����� ��2����
6. �ռ����ң�1���� -> ����Σ�2����
ע��㣺
1 һ�ʶ�����Ӧ������������ܴ������۶����
2 ������ʽcode ��Ӧ�����������ƴ������켣���ȡ����ñ��м򻯵�����������
*/
-- 1.

-- 1
select ReceiverCountryCnName �ռ����� ,ifnull(MerchantName,'���Һϼ�')  ������
	,count(distinct wp.PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������')
    ) wp -- ȥ������Ϊ���¼���������������˷�
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����' group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber -- ��ѡ����������ʱ�޷�Ԥ֪���˿�������۶���˿�
 group by grouping sets ((ReceiverCountryCnName),(ReceiverCountryCnName,MerchantName));

-- 2
select MerchantName ������ ,ifnull(ReceiverCountryCnName,'�����̺ϼ�') �ռ�����
	,count(distinct wp.PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������')
    ) wp -- ȥ������Ϊ���¼���������������˷�
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����' group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
group by grouping sets ((MerchantName),(ReceiverCountryCnName,MerchantName));


select MerchantName ������ ,ifnull(TransportType,'�����̺ϼ�') ��������
	,count(distinct wp.PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName,TransportType
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������'),TransportType
    ) wp -- ȥ������Ϊ���¼���������������˷�
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����'  group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
group by grouping sets ((MerchantName),(TransportType,MerchantName));


select gram_bins ��������
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������'),TransportType
        ) wp -- ȥ������Ϊ���¼���������������˷�
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by gram_bins;


select MerchantName ������ ,ifnull(gram_bins,'�����̺ϼ�') ��������
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������'),TransportType
        ) wp -- ȥ������Ϊ���¼���������������˷�
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by grouping sets ((MerchantName),(gram_bins,MerchantName));

-- �ռ����� ��������
select ReceiverCountryCnName �ռ����� ,ifnull(gram_bins,'���Һϼ�') ��������
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross ,ReceiverCountryCnName
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'׷�ٱ�������') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'׷�ٱ�������'),TransportType
        ) wp -- ȥ������Ϊ���¼���������������˷�
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='����' and TransactionType= '����' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by grouping sets ((ReceiverCountryCnName),(gram_bins,ReceiverCountryCnName));



/*


select RecipientCountryCnName �ռ����� ,ifnull(tmp.MerchantName,'���Һϼ�')  ������
	,count(distinct lt.PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
	,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from import_data.erp_logistic_logistics_tracking lt
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 group by PlatOrderNumber
	) wo on lt.PlatOrderNumber = wo.PlatOrderNumber
left join (select MerchantName , TransportType
    from import_data.erp_logistic_logistics_tracking
    group by MerchantName , TransportType) tmp
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01' and RegisterTime != '2001-01-01 08:00:00'
group by grouping sets ((RecipientCountryCnName),(RecipientCountryCnName,tmp.MerchantName))
order by RecipientCountryCnName desc ,������ desc;




select MerchantName ������ ,ifnull(RecipientCountryCnName,'�����̺ϼ�') �ռ�����
	,count(distinct lt.PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
    ,round(sum(TotalGross)) ���۶�CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) �����˷�ռ��
from erp_logistic_logistics_tracking lt
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 group by PlatOrderNumber
	) wo on lt.PlatOrderNumber = wo.PlatOrderNumber
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
group by grouping sets ((MerchantName),(RecipientCountryCnName,MerchantName))
order by MerchantName desc ,������ desc;


select MerchantName ������ ,ifnull(TransportType,'�����̺ϼ�') ��������
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
from erp_logistic_logistics_tracking lt
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
group by grouping sets ((MerchantName),(TransportType,MerchantName))
order by MerchantName desc ,������ desc;


select gram_bins ��������
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
from (
	select 
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g' 
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight
	from erp_logistic_logistics_tracking lt
	where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
	) tb 
group by gram_bins
order by ������ desc;


select MerchantName ������ ,ifnull(gram_bins,'�����̺ϼ�') ��������  
	,count(distinct PlatOrderNumber) ������
	,sum(PackageTotalWeight) ��������
	,round(sum(PackageFeight)) �˷�CNY
from (
	select 
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g' 
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight
	from erp_logistic_logistics_tracking lt
	where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
	) tb 
group by grouping sets ((MerchantName),(gram_bins,MerchantName))
order by MerchantName desc , ������ desc;

*/
