/*������*/
with sheet as (
                   with sale as(
                   with orderdetails as(select TotalGross,TotalProfit,PlatOrderNumber,Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,pp.Spu,s.* from import_data.wt_orderdetails ord   /*�������������ݣ�*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join mysql_store s
                   on ord.shopcode=s.Code/*����ά��*/
                   and s.Department='������'
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0)
                select  '������' as department,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '˰�����۶�' ,
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'����' and TotalGross>0 then PlatOrderNumber end) '������',
                round(sum(case when TransactionType<>'����' then (TotalGross-RefundAmount)/ExchangeUSD end),2) '��ASIN����ҵ��',
                count(distinct case when TransactionType<>'����' then concat(Asin,Site) end ) '������ASIN��' from orderdetails)
/*��������Դ*/
,ods as(select '������' as department,count(DISTINCT CASE when PayTime>='${StartDay}'
           and PayTime<'${EndDay}'  and  OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end) '���϶�����'
           ,round(count(distinct case when  PayTime>=date_add('${EndDay}',interval -27 day) and PayTime<date_add('${EndDay}',interval -20 day) and OrderStatus <> '����' then PlatOrderNumber  end )/7,0) '7��ǰ�վ�������'
           ,round(count(DISTINCT CASE when PayTime>='${StartDay}'
           and PayTime<'${EndDay}' and  OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`  from import_data.ods_orderdetails as ods   /*�������������ݣ�*/
           left join wt_products pp
           on ods.BoxSku=pp.BoxSku
           inner join mysql_store s
           on ods.ShopIrobotId=s.Code/*����ά��*/
           and s.Department='������'
           and ods.IsDeleted=0)

/*�˿�����*/
,ref as (select '������' as department,sum(RefundUSDPrice) '�˿���',sum(case when RefundReason1='�ɹ�ԭ��' then  RefundUSDPrice end) '�ɹ�ԭ���˿���',
         sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '�ǿͻ�ԭ���˿���'  from import_data.daily_RefundOrders rf
           inner join mysql_store s
           on rf.OrderSource=s.Code /*����ά��*/
           and s.Department='������'
           and RefundStatus='���˿�'
           and RefundDate>='${StartDay}'/*ʱ��ά��*/
           and RefundDate<'${EndDay}')

/*�ÿ�����*/
,visitor as (select t1.department,t1.ASIN�ÿ���,�ÿ���, �ÿ�����, round(�ÿ���/t1.ASIN�ÿ���,4) '���ﳵӮ����' from
(select '������' as department,sum(a.maxtotal) 'ASIN�ÿ���' from
(select lm.ChildAsin,lm.StoreSite,max(TotalCount) 'maxtotal' from import_data.ListingManage lm
          inner join mysql_store s
          on lm.ShopCode=s.Code /*����ά��*/
          and s.Department='������'
          and ReportType='�ܱ�' /*ʱ��ά��*/
          and Monday='${StartDay}'
          inner join(select t1.ASIN,t1.code from
                    (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                    inner join  mysql_store s
                    on al.ShopCode=s.Code
                    where Department='������'
                    and ShopStatus='����'
                    and ListingStatus=1
                    group by ASIN,right(ShopCode,2)) as t1
                    inner join
                    (select Asin,Site from import_data.erp_gather_gather_asin
                    where IsDeleted=0
                    group by Asin, Site) t2
                    on t1.ASIN=t2.Asin
                    and t1.code=t2.Site) t4
          on lm.ChildAsin=t4.ASIN
          and right(lm.ShopCode,2)=t4.code
          group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite) a) t1
left join

(select '������' as department,round(sum(TotalCount*FeaturedOfferPercent/100),0) '�ÿ���',sum(OrderedCount) '�ÿ�����' from import_data.ListingManage lm
          inner join mysql_store s
          on lm.ShopCode=s.Code /*����ά��*/
          and s.Department='������'
          and ReportType='�ܱ�' /*ʱ��ά��*/
          and Monday='${StartDay}'
          inner join(select t1.ASIN,t1.code from
                    (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                    inner join mysql_store s
                    on al.ShopCode=s.Code
                    where Department='������'
                    and ShopStatus='����'
                    and ListingStatus=1
                    group by ASIN,right(ShopCode,2)) as t1
                    inner join
                    (select Asin,Site from import_data.erp_gather_gather_asin
                    where IsDeleted=0
                    group by Asin, Site) t2
                    on t1.ASIN=t2.Asin
                    and t1.code=t2.Site) t4
          on lm.ChildAsin=t4.ASIN
          and right(lm.ShopCode,2)=t4.code) t2
on t1.department=t2.department
/*�ʼ���*/
) ,em as (select '������' as department,round(count(*)/datediff('${EndDay}','${StartDay}'),1) '�վ��ʼ���' from daily_Email em
            inner join mysql_store s
            on em.Src=s.Code
            and s.Department='������'
            where ReplyTime>='${StartDay}'
            and ReplyTime<'${EndDay}'
/*��˲�Ʒ*/
),tort as(select '������' as department,count(*) '�����SKU��',
       count(case when GatherProductStatus>=7 then id end ) '���ͨ��SKU��',
       round((count(*)-count(case when GatherProductStatus>=7 then id end ))/count(*),4) '���ͨ����'  from erp_gather_gather_amazon_products
       where left(TortAuditTime,10)>='${StartDay}'
       and left(TortAuditTime,10)<'${EndDay}')

          select  '������' as department,˰�����۶�, expend as '��֧��',�˿���,round(˰�����۶�-�˿���,2) '���۶�', round(˰�����۶�+expend-�˿���) '�����',
          round((˰�����۶�+expend-�˿���)/(˰�����۶�-�˿���),4) '������',visitor.�ÿ���,visitor.�ÿ�����,visitor.ASIN�ÿ���,visitor.���ﳵӮ����,
          �ɹ�ԭ���˿���,round(�ɹ�ԭ���˿���/˰�����۶�,4) '�ɹ�ԭ���˿���', �ǿͻ�ԭ���˿���,round(�ǿͻ�ԭ���˿���/˰�����۶�,4) '�ǿͻ�ԭ���˿���',
          ������,ods.���϶�����,ods.���϶�����,`7��ǰ�վ�������`,�վ��ʼ���,�����SKU��, ���ͨ��SKU��, ���ͨ����  from sale
          left join ref
          on sale.department=ref.department
          left join visitor
          on sale.department=visitor.department
          left join ods
          on sale.department=ods.department
          left join em
          on sale.department=em.department
          left join tort
          on sale.department=tort.department

/*TOPASIN*/
),top1 as
    ( select a.department, TOP1���ӹ���ҵ��,b.TOP1ASIN���ﳵӮ���� from
        (select '������' as department, round(sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD),2)  'TOP1���ӹ���ҵ��'  from ods_orderdetails od
            inner join
                    (select t2.Asin, t2.Site, team, Name from
                    (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1
                    inner join (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*�ҳ����ĸ�����*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                        on ap.AssignUserName=s.Name) as t2
                    on t1.Asin=t2.Asin
                    and t1.Site=t2.Site) t3
            on right(od.ShopIrobotId,2)=t3.Site
            and od.Asin=t3.Asin
            inner join  mysql_store s
            on od.ShopIrobotId=s.Code
            and s.Department='������'
            where IsDeleted=0
            and TransactionType='����'
            and OrderStatus<>'����'
            and PayTime>='${StartDay}'
            and PayTime<'${EndDay}'
            ) a
    left join (select '������' as department,round(t2.���̷ÿ���/t1.totalcount,4) 'TOP1asin���ﳵӮ����' from
            (select '������' as department,sum(TotalCount2) 'totalcount' from
            (select StoreSite site, childasin asin, max(TotalCount) TotalCount2  from ListingManage lm
            inner join (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1  /*ע���޸� TOPASIN��TOPASIN����*/
            on lm.ChildAsin=t1.ASIN
            and lm.StoreSite=t1.Site
            inner join mysql_store s
            on lm.ShopCode=s.Code
            and s.Department='������'
            where ReportType='�ܱ�'
            and Monday='${StartDay}'
            group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite) a
             ) t1
            left join
            (select '������' as department,round(sum(TotalCount*FeaturedOfferPercent/100),1) '���̷ÿ���' from ListingManage lm
            inner join (select Asin,Site from TMH_ASIN
                    where ASINKeyLevel='S') t1
            on lm.ChildAsin=t1.ASIN
            and lm.StoreSite=t1.Site
            inner join mysql_store s
            on lm.ShopCode=s.Code
            and s.Department='������'
            where ReportType='�ܱ�'
            and Monday='${StartDay}') t2
            on t1.department=t2.department
                ) b
                on a.department=b.department)
/*��������*/
,ls as (select t1.department, ��ASIN����ҵ��, �³���ASIN��,��ASIN����ҵ��,������ASIN��,���ϼ�ASIN��, ������ASIN��,��ɾ��ASIN��,t4.�ᱨASIN�� from
            (select  '������' as department,sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD) '��ASIN����ҵ��',
                   count(distinct concat(user.Asin,right(ShopIrobotId,2))) '������ASIN��',
                   sum(case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then  (TotalGross+TaxGross-RefundAmount)/ExchangeUSD  end ) '��ASIN����ҵ��',/*����״̬(8:���ϼ�,9:���ϼ�,10:�¼�)*/
                   count(distinct case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then concat(user.Asin,right(ShopIrobotId,2)) end) '�³���ASIN��' from import_data.ods_orderdetails ord   /*�������������ݣ�*/
                   inner join (select eg.Asin,eg.Site,eg.CreationTime,eg.FollowUpStatus,eg.FirArrivalTime,left(s.NodePathName,3) as dep,right(s.NodePathName,7) as team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id  /*�ҳ����ĸ�����*/
                                inner join (
                                SELECT d.NodePathName,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                on ap.AssignUserName=s.Name) as user
                                on ord.Asin=user.Asin
                                and right(ord.ShopIrobotId,2)=user.Site
                   inner join mysql_store s
                   on ord.ShopIrobotId=s.Code/*����ά��*/
                   and s.Department='������'
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and TransactionType<>'�˿�'
                   and OrderStatus<>'����'   /*�޳����϶�����δ��ȥ�˿�˰ǰ���۶�*/
                   and ord.IsDeleted=0
                   ) t1
            left join  (select '������' as team1,
                         count(distinct concat(t1.ASIN,t1.code)) '������ASIN��'    from
                        (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing al
                        inner join mysql_store s
                        on al.ShopCode=s.Code
                        where Department='������'
                        and ShopStatus='����'
                        and ListingStatus=1
                        group by ASIN,right(ShopCode,2)) as t1
                        inner join
                        (select Asin,Site,CreationTime,FollowUpStatus,FirArrivalTime from import_data.erp_gather_gather_asin
                        where IsDeleted=0) t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site) t3
                on t1.department=t3.team1
                left join  (select '������' as team1,
                         count(distinct concat(t1.ASIN,t1.code)) '��ɾ��ASIN��'    from
                        (select ASIN,right(ShopCode,2) code from erp_amazon_amazon_listing_delete al
                        inner join mysql_store s
                        on al.ShopCode=s.Code
                        where Department='������'
                        group by ASIN,right(ShopCode,2)) as t1
                        inner join
                        (select Asin,Site,CreationTime,FollowUpStatus,FirArrivalTime from import_data.erp_gather_gather_asin
                        where IsDeleted=0
                        and FirArrivalTime>='${StartDay}'
                        and FirArrivalTime<'${EndDay}') t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site) t5
                on t1.department=t5.team1
                left join (select '������' as team3,count(case when FollowUpStatus=9 then concat(Asin,Site) end) '���ϼ�ASIN��'
                       from import_data.erp_gather_gather_asin
                        where FirArrivalTime>='${StartDay}'
                        and FirArrivalTime<'${EndDay}') s
                        on t1.department=s.team3
                left join (select '������' as team2,count(distinct concat(Asin,Site)) '�ᱨASIN��'  from import_data.erp_gather_gather_asin
                        where CreationTime>='${StartDay}'
                        and CreationTime<'${EndDay}') t4
                        on t1.department=t4.team2

/*����*/
/*׼ʱ������*/
),deliver as (select c1.department, ׼ʱ������,c2.׼ʱ��Ͷ��,�ɹ���Ʒ���, �ɹ��˷�, �ɹ�����, �վ��ɹ�����,
              c4.�ɹ�3�쵽����,c5.ƽ���ɹ��ջ�����,`2��������`, ����5�췢����, ����7�췢����,c7.`24Сʱ������`,c8.`24Сʱ�ջ���`
              ,���زֿ���ʽ�ռ��, �����ת����, ���������ɹ����, �ڲ�sku����, �ڲ�sku��, ��;��Ʒ�ɹ����, ��;��Ʒ�ɹ��˷�, �ڲֲ�Ʒ���,`10��δ��������`, ����Ʒ������,
              ODR���������, VTR���������, LSR���������, CR���������,n5.staff_count       from
              (select tb.department,round(A_cnt/B_cnt,4) `׼ʱ������`
            from
                ( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt
                FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
                    from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
                    where PayTime < date_add('${EndDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
                      and TransactionType ='����' and orderstatus != '����' and totalgross > 0
                     group by grouping sets ((),(department))
                    ) tmp3 -- ����ʱ������4�� ��������ʱ��
                ) tb
            LEFT JOIN
            ( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, A_cnt
                FROM (
                    select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
                    from (
                        select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
                              when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
                            end as latest_WeightTime -- ��������
                            ,paytime ,DAYOFWEEK(OrderCountry_paytime)
                            ,PlatOrderNumber ,department
                        from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
                            ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department
                            from import_data.ods_orderdetails od
                            join  mysql_store s
                            on od.ShopIrobotId =s.Code  and s.Department='������' and isdeleted = 0
                            left join
                                (SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js
                                on js.code=right(od.ShopIrobotId ,2)
                            where od.IsDeleted =0 and PayTime < date_add('${EndDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
                                and TransactionType ='����' and orderstatus != '����' and totalgross > 0
                            ) tmp
                        ) dod
                    left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber
                    where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
                    group by grouping sets ((),(department))
                    ) tmp2
              ) ta
              ON ta.department =tb.department
            ) c1


-- ׼ʱ����/��Ͷ��
left join (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ��Ͷ��`
from (
	SELECT department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	 	join mysql_store s
        on eaaspc.ShopCode =s.Code and s.Department='������'
		where AmazonShopHealthStatus != 4
			and left(CreationTime,10) = left(DATE_ADD('${EndDay}', interval -1 day),10) -- ÿ���賿0�������
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by grouping sets ((),(department))
) tmp2
) c2
on c1.department=c2.department
-- �������������ʣ��켣������ʱ�� ò��ֻ�ܵ�0128��
left join
-- �ɹ����� �ɹ���� �ɹ��˷�
(
select case when department IS NULL THEN '��˾' ELSE department END AS department
	,round(sum(Price - DiscountedPrice)) `�ɹ���Ʒ���` , round(sum(SkuFreight)) `�ɹ��˷�`	,count(distinct OrderNumber) `�ɹ�����`
	,round(count(distinct OrderNumber)/datediff('${EndDay}','${StartDay}')) `�վ��ɹ�����`
from wt_purchaseorder wp
join (select BoxSku , projectteam as department  from import_data.wt_products where IsDeleted = 0 ) wp2
	on wp.BoxSku =wp2.BoxSku
where ordertime  <  '${EndDay}'  and ordertime >= '${StartDay}' and WarehouseName = '��ݸ��'
group by grouping sets ((),(department))
)
c3
on c1.department=c3.department

-- �ɹ�5�쵽����
left join (
select
	case when department IS NULL THEN '��˾' ELSE department END AS department
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�3�쵽����`
from ( -- �ɹ����
	select
		OrderNumber,department
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
		end as in5days_rev_numb -- ����5�쵽�����µ���
		, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
	from import_data.wt_purchaseorder wp
	inner join (select BoxSku ,ProjectTeam as department from erp_product_products
	            where IsMatrix=0) pp
	on wp.BoxSku=pp.BoxSku

	where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${EndDay}',interval -5 day)  -- ���ȡ10�����ݣ��Ա�������ָ��
		and WarehouseName = '��ݸ��'
	) tmp
group by grouping sets ((),(department))
)
c4
on c1.department=c4.department

left join
-- �ɹ�ƽ����������
(
select case when department IS NULL THEN '��˾' ELSE department END AS department
	, sum(rev_days)/count(DISTINCT OrderNumber) `ƽ���ɹ��ջ�����`
from (
	select OrderNumber ,department ,rev_days
	from (
		select
			dpo.OrderNumber ,department
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
				when scantime is null and instockquantity > 0 and CompleteTime is not null
				then timestampdiff(second, ordertime, CompleteTime)/86400  -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
				end as rev_days
		from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev  pr on dpo.OrderNumber = pr.OrderNumber
		left join (select BoxSku ,ProjectTeam as department from wt_products
			      ) tmp on dpo.BoxSku = tmp.BoxSku
		where CompleteTime < '${EndDay}' and CompleteTime >= '${StartDay}' and WarehouseName = '��ݸ��'
		) po_pre
	where rev_days is not null
	group by department ,OrderNumber ,rev_days
	) tmp
group by grouping sets ((department))
)
c5
on c1.department=c5.department

left join
-- ���������� ����5�췢���� ����7�췢����
(
select department
	, round(a_gen_in2d/b_gen_in2d,4) `2��������`
	, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`
	, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from ( SELECT department
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from
		( select PlatOrderNumber, OrderNumber, BoxSku , PayTime ,s.department
		from import_data.ods_orderdetails oo
		join mysql_store s
        on oo.ShopIrobotId = s.Code and oo.IsDeleted = 0 and s.Department='������'
		where PayTime >= date_add('${StartDay}',INTERVAL -10 DAY) and PayTime < '${EndDay}'
			and TransactionType ='����' and orderstatus != '����' and totalgross > 0  -- ��ʼʱ������ǰԤ��10������ݣ����ڼ�˶�ָ�����
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber AND od_pre.boxsku =pd.boxsku
	group by department
	) tmp1
union
select NodePathName
	, round(a_gen_in2d/b_gen_in2d,4) `2��������`
	, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`
	, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from ( SELECT NodePathName
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= '${StartDay}' and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= '${StartDay}' and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from
		( select PlatOrderNumber, OrderNumber, BoxSku , PayTime ,s.NodePathName
		from import_data.ods_orderdetails oo
		join mysql_store s
        on oo.ShopIrobotId = s.Code and oo.IsDeleted = 0 and s.Department='������'
		where PayTime >= date_add('${StartDay}',INTERVAL -10 DAY) and PayTime < '${EndDay}'
			and TransactionType ='����' and orderstatus != '����' and totalgross > 0  -- ��ʼʱ������ǰԤ��10������ݣ����ڼ�˶�ָ�����
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber AND od_pre.boxsku =pd.boxsku
	group by NodePathName
	) tmp1
)
c6
on c1.department=c6.Department
left join
-- 24Сʱ������
(
select
	case when department is null THEN '��˾' ELSE department END AS department
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from import_data.daily_PackageDetail dpd
join import_data.ods_orderdetails dod
	on dpd.OrderNumber = dod.OrderNumber
		and dpd.CreatedTime < '${EndDay}'
		and dpd.CreatedTime >= '${StartDay}'
        and dod.IsDeleted=0
join mysql_store s
on s.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1) and s.Department='������'
group by grouping sets ((),(department))
)
c7
on c1.department=c7.department
left join
-- 24Сʱ�ջ���
(
select
	case when department is null THEN '��˾' ELSE department END AS department
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `24Сʱ�ջ���`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join (select BoxSku ,ProjectTeam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where date_add(scantime, 1) < '${EndDay}'  and date_add(scantime, 1) >= '${StartDay}'
	 and b.WarehouseName = '��ݸ��'
group by grouping sets ((),(department))
)
c8
on c1.department=c8.department
left join
-- ����ʽ�ռ��(��������)
(
select a.department
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`),0) `���زֿ���ʽ�ռ��`
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${EndDay}','${StartDay}'),1) `�����ת����`
	,`���������ɹ����`
	,`�ڲ�sku����`,`�ڲ�sku��`
	,`��;��Ʒ�ɹ����`, `��;��Ʒ�ɹ��˷�` , `�ڲֲ�Ʒ���`
from
(
select case when department is null THEN '��˾' ELSE department END AS department
	, sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����` , ifnull(sum(SkuFreight),0) `��;��Ʒ�ɹ��˷�`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp
	join (select BoxSku ,ProjectTeam  department from wt_products
		     ) tmp on wp.BoxSku = tmp.BoxSku
	where ordertime < '${EndDay}'
		and isOnWay = '��' and WarehouseName = '��ݸ��'
	) tmp
group by grouping sets ((),(department))
) a

left join (
	SELECT case when department is null THEN '��˾' ELSE department END AS department
		,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��`
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join (select BoxSku ,ProjectTeam  department from wt_products) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '��ݸ��' and TotalInventory > 0 and CreatedTime = date_add('${EndDay}',-1)
		)  tmp
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (
	select case when department is null THEN '��˾' ELSE department END AS department
		, round(sum(pc)) `���������ɹ����`
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0
				and TransactionType ='����' and orderstatus != '����' and totalgross > 0
		where pd.weighttime < '${EndDay}' and pd.weighttime >= '${StartDay}'
		) a
	group by grouping sets ((),(department))
) c on a.department = c.department
)
n1
on c1.department=n1.department
left join
-- 10��δ����������
( -- 10��δ���������� =  ͳ��T-10~T-20δ������������ͳ��T-10~T-20�վ��������
select  Department, count(distinct PlatOrderNumber ) `10��δ��������`
from daily_WeightOrders wo
join mysql_store s
on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =s.Code and s.Department='������'
where CreateDate = '${EndDay}'
and PayTime>=date_add('${EndDay}',interval -20 day)
and PayTime<date_add('${EndDay}',interval -10 day)
and OrderStatus<>'����'
group by Department)
n2
on c1.department=n2.Department

/*����Ʒ������*/
left join
(select a.department , round(`����sku��`/`����ƷSKU��`,4) as `����Ʒ������`
from (
	select s.department, count(distinct boxsku) `����sku��`
	from wt_orderdetails wo
	join mysql_store s
    on wo.ShopCode =s.Code and wo.IsDeleted = 0 and s.Department='������'
	where IsDeleted = 0 and PayTime < '${EndDay}' and PayTime >= '${StartDay}'
	group by s.department
	) a
left join (
	select department , count(distinct tmp.BoxSku ) `����ƷSKU��`
	from (
		select BoxSku -- �����ڲ�sku
		from import_data.daily_WarehouseInventory dwi
		where CreatedTime = DATE_ADD('${EndDay}', -1)
		group by BoxSku
		union
		select BoxSku -- �����ڲ�sku
		from import_data.daily_WarehouseInventory dwi
		where CreatedTime = DATE_ADD('${StartDay}', -1)
		group by BoxSku
		union
		select BoxSku -- �ڼ�ɹ�sku
		from wt_purchaseorder wp
		where ordertime  <  '${EndDay}'  and ordertime >= '${StartDay}' and WarehouseName = '��ݸ��'
		) tmp
	join (select BoxSku , ProjectTeam as department  from import_data.wt_products where IsDeleted = 0 ) wp2
		on tmp.BoxSku =wp2.BoxSku
	group by department
	) b
	on a.department =b.department
where a.department in ('������'))
n3
on c1.department=n3.Department
left join
(select t1.team  as  department,ODR���������,t2.LSR���������,t3.CR���������,t4.VTR��������� from

(
-- ord
select
	'������'  as `team`
    ,count( distinct  case when round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)>0.009 then ShopCode end) 'ODR���������'
from (
select
     ShopCode,
	 sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
	,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,OrderDefectRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����'  and ms.Department = '������'
	where AmazonShopHealthStatus != 4
	and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- ÿ���賿0�������
	) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 1 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
    and DateType = 60 -- ͳ����
    group by ShopCode
) tmp2
) t1

left join
(
select '������' team
	,count(distinct case when LateShipment_ord_cnt/monitor_ord_cnt>=0.03 then ShopCode end ) 'LSR���������'
from (
select
    ShopCode
	,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- �ٷ�������
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '������'
	where AmazonShopHealthStatus != 4
    and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- ÿ���賿0�������
    ) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
    and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
    and DateType = 7 -- ͳ����
    group by ShopCode
) tmp2
) t2
on t1.team=t2.team
left join
(
-- ȡ����
select '������' team1
     ,count(distinct case when OrderCancel_ord_cnt/monitor_ord_cnt>=0.02 then ShopCode end ) 'CR���������'
from (
select
     ShopCode
	,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- ȡ��������
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '������'
	where AmazonShopHealthStatus != 4
	and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- ÿ���賿0�������
	) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType =7 -- ͳ����
    group by ShopCode
) tmp2
) t3
on t1.team=t3.team1
left join
(
-- ��Ч׷����
-- ��MetricsType = 3��׷��ָ�����ݣ���ʱ��OrderCountΪnull�����ʹ�� ����/����=��ĸ
select '������' as team1
	,count(distinct  case when ValidTracking_ord_cnt/monitor_ord_cnt <=0.96 then  ShopCode end) 'VTR���������'   -- ��Ч׷����
from (
select
    ShopCode
	,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- ��Ч׷�ٶ�����
	,round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0) as monitor_ord_cnt -- ͳ�ƶ�����
	,sum(case when ItemType=8 then eaaspcd.Count  end)/round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0)
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '������'
	where AmazonShopHealthStatus != 4
    and CreationTime >=DATE_ADD('${EndDay}', interval -1 day) and CreationTime < '${EndDay}' -- ÿ���賿0�������
	) tmp
    on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
    and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
    and DateType = 7 -- ͳ����
    group by ShopCode
) tmp2
) t4
on t1.team=t4.team1) n4
on c1.department=n4.Department
left JOIN
(select '������' as dep,count(*) `staff_count` from dim_staff
where department='������'
and staff_name not regexp '��һ|����|��һһ|Ƚ����|�Ծ�|���������Ȩ��' )n5
on c1.department=n5.dep
where c1.department='������')


select staff_count,'�ܶ�',sheet.department, ˰�����۶�, ��֧��, ���۶�, �����, ������,�˿���,round(�˿���/˰�����۶�,4) '�˿���', �ɹ�ԭ���˿���, �ɹ�ԭ���˿���, �ǿͻ�ԭ���˿���,
       �ǿͻ�ԭ���˿���, ������, ���϶�����, ���϶�����, ��ASIN����ҵ��, ������ASIN��,TOP1���ӹ���ҵ��, TOP1ASIN���ﳵӮ����,round(TOP1���ӹ���ҵ��/��ASIN����ҵ��,4) 'TOP1ASINҵ��ռ��',
       ��ASIN����ҵ��, �³���ASIN��, round(��ASIN����ҵ��/�³���ASIN��,2) '��ASIN����',round(�³���ASIN��/�ᱨASIN��,4) '��ASIN��Ч��',round(�³���ASIN��/���ϼ�ASIN��,4) '��ASIN��Ч��', ���ϼ�ASIN��,
       round(���ϼ�ASIN��/�ᱨASIN��,4) '��ASIN�ϼ���',�ᱨASIN��,round(��ASIN����ҵ��-��ASIN����ҵ��,2) '��ASIN����ҵ��',round((��ASIN����ҵ��-��ASIN����ҵ��)/��ASIN����ҵ��,4) '��ASIN����ҵ��%',
       round((������ASIN��-�³���ASIN��)/(������ASIN��-���ϼ�ASIN��),4) '��ASIN������',������ASIN��,round(������ASIN��/(������ASIN��+��ɾ��ASIN��),4) '��ASIN������',�ÿ���,�ÿ�����,
       round(�ÿ�����/�ÿ���,4) '�ÿ�ת����',���ﳵӮ����,������,���϶�����,���϶�����,׼ʱ������, ׼ʱ��Ͷ��,'-' as '����3��������',�ɹ�����,�ɹ�ԭ���˿���,�ɹ�ԭ���˿���,�ɹ���Ʒ��� as '�ɹ����',
       �վ��ɹ�����,�ɹ�3�쵽����,ƽ���ɹ��ջ�����,`2��������`,'-' as '24Сʱ�����' ,`24Сʱ�ջ���`,'-' as '24Сʱ�ϼ���', `24Сʱ������`,����5�췢����, `10��δ��������`,�վ��ʼ���
       ,�����ת����,���زֿ���ʽ�ռ��,����Ʒ������, ODR���������, VTR���������, LSR���������, CR���������,'0'as 'AHR���������', round(10��δ��������/`7��ǰ�վ�������`,4) '10��ǰδ����������',
        sheet.�����SKU��,sheet.���ͨ��SKU��,sheet.���ͨ����
from sheet
left join top1
on sheet.department=top1.department
left join ls
on sheet.department=ls.department
left join deliver
on sheet.department=deliver.Department;