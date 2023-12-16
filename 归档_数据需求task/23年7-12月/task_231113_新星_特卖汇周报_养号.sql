select t1.Department,t1.team,˰�����۶�, expend,round(˰�����۶�-ifnull(�˿���,0),2) '���۶�',round(˰�����۶�+expend-ifnull(�˿���,0)-��滨��,2) '�����',
       round(��滨��/(˰�����۶�-ifnull(�˿���,0)),4) '��滨��ռ��',round(ifnull(�˿���,0)/˰�����۶�,4) '�˿���',
       �����г���,ifnull(�˿���,0), �¿���������,round(�����ӳ�����/�¿���������,4) '�����Ӷ�����',�¿������ӹ������,�¿������ӹ��ת����,round(�¿������ӷÿ�����/�¿������ӷÿ���,4) '�����ӷÿ�ת����',����������,����������,round(����������/����������,4) '���Ӷ�����',���ACOST,
       round(������۶�/(˰�����۶�-ifnull(�˿���,0)),4) '���ҵ��ռ��',�������,���ת����,�ÿ���, �ÿ�����,round(�ÿ�����/�ÿ���,4) '�ÿ�ת����',
       round((�ÿ���-�������)/�ÿ���,4) '��Ȼ����ռ��',�����г�������,�����г���,���³���������3�����г�����,��滨�� from
(with orderdetails as(select TotalGross,TotalProfit,PlatOrderNumber,s.AccountCode,ord.Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,ord.PublicationDate,pp.Spu,s.Department,s.NodePathName,s.Market from import_data.wt_orderdetails ord   /*�������������ݣ�*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join tmh_pm_code s
                   on ord.shopcode=s.Code/*����ά��*/
                   and s.Department='������'
                   left join TMH_ASIN tm
                   on tm.Asin=ord.Asin
                   and tm.Site=ord.Site
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0
                   and Name is null)
                select department,ifnull(NodePathName,'TMH') team,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '˰�����۶�',
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'����' and TotalGross>0 then PlatOrderNumber end) '������',
                count(distinct case when TransactionType<>'����'then AccountCode end) '�����г���',
                count(distinct case when TransactionType<>'����'then concat(Asin,right(shopcode,2)) end) '����������',
                count(distinct case when TransactionType<>'����'and PublicationDate>='${StartDay}' and PublicationDate<'${EndDay}' then concat(Asin,right(shopcode,2)) end) '�����ӳ�����'
                from orderdetails
                group by grouping sets((department),(department,NodePathName))) t1
/*�˿�����*/
left join (select department,ifnull(NodePathName,'TMH') team,sum(RefundUSDPrice) '�˿���',sum(case when RefundReason1='�ɹ�ԭ��' then  RefundUSDPrice end) '�ɹ�ԭ���˿���',
         sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '�ǿͻ�ԭ���˿���'  from import_data.daily_RefundOrders rf
           inner join tmh_pm_code s
           on rf.OrderSource=s.Code /*����ά��*/
           and s.Department='������'
           inner join (select PlatOrderNumber
                      from wt_orderdetails od
                      inner join tmh_pm_code s
                      on od.shopcode=s.Code
                      left join TMH_ASIN ta
                      on od.Site=ta.Site
                      and od.Asin=ta.Asin
                      where TransactionType='����'
                      and Name is null
                      group by PlatOrderNumber) t1
           on rf.PlatOrderNumber=t1.PlatOrderNumber
           and RefundStatus='���˿�'
           and RefundDate>='${StartDay}'/*ʱ��ά��*/
           and RefundDate<'${EndDay}'
           group by grouping sets((department),(department,NodePathName))) t2
on t1.Department=t2.Department
and t1.team=t2.team
/*�������*/
left join (select department,ifnull(NodePathName,'TMH') team,
        round(sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Clicks end )/sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Exposure end ),4) '�¿������ӹ������',
        round(sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then TotalSale7DayUnit end )/sum(case when al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then Clicks end ),4) '�¿������ӹ��ת����',
        round(sum(Clicks)/sum(Exposure),4) '�������',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '���ת����',
        round(sum(Spend)/sum(TotalSale7Day),4) '���ACOST',sum(TotalSale7Day) '������۶�',sum(Clicks) '�������',sum(Spend) '��滨��'

    from erp_amazon_amazon_listing al
     inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and s.Department='������'
    inner join AdServing_Amazon aa
    on al.ShopCode=aa.ShopCode
    and al.SellerSKU=aa.SellerSKU
    left join TMH_ASIN ta
    on aa.Asin=ta.Asin
    and right(aa.ShopCode,2)=ta.Site
    where CreatedTime>='${StartDay}'
    and CreatedTime<'${EndDay}'
    and ta.Name is null
    group by  grouping sets((department),(department,NodePathName))) t3
on t1.Department=t3.Department
and t1.team=t3.team
/*�ÿ�����*/
left join (select department,ifnull(NodePathName,'TMH') team,
    round(sum(TotalCount*FeaturedOfferPercent/100)) '�ÿ���',sum(OrderedCount) '�ÿ�����' ,
    round(sum( case when  al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then TotalCount*FeaturedOfferPercent/100 end)) '�¿������ӷÿ���',
    sum(case when  al.PublicationDate>='${StartDay}' and al.PublicationDate<'${EndDay}' then OrderedCount  end) '�¿������ӷÿ�����'
    from erp_amazon_amazon_listing al
    inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and s.Department='������'
    inner join ListingManage lm
    on al.ShopCode=lm.ShopCode
    and al.ASIN=lm.ChildAsin
    left join TMH_ASIN ta
    on lm.ChildAsin=ta.Asin
    and lm.StoreSite=ta.Site
    where lm.Monday='${StartDay}'
    and ReportType='�ܱ�'
    and ta.Name is null
    group by grouping sets((department),(department,NodePathName))    ) t4
on t1.Department=t4.Department
and t1.team=t4.team
/*���տ���*/
left join (select '������' department, 'TMH' as  team,t1.�����г�������,t2.���³���������3�����г�����  from (select '������' as team1,count (distinct AccountCode) '�����г�������' from tmh_pm_code
                                where Department='������'
                                ) t1
        inner join (select  '������' as team2,count(distinct s.AccountCode) '���³���������3�����г�����'   from import_data.wt_orderdetails ord   /*�������������ݣ�*/
                   left join wt_products pp
                   on ord.BoxSku=pp.BoxSku
                   inner join tmh_pm_code s
                   on ord.shopcode=s.Code/*����ά��*/
                   and s.Department='������'
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0
                   and OrderStatus<>'����'
                   group by s.AccountCode
                   having count(PlatOrderNumber)>=3) t2
                   on t1.team1=t2.team2 ) t5
on t1.Department=t5.Department
and t1.team=t5.team
/*��������*/
left join (select department,ifnull(NodePathName,'TMH') team,count(distinct case when PublicationDate>='${StartDay}' and PublicationDate<'${EndDay}' then concat(Asin,right(shopcode,2)) end) '�¿���������' ,
       count(distinct concat(Asin,right(shopcode,2))) '����������' from erp_amazon_amazon_listing al
    inner join tmh_pm_code s
    on al.ShopCode=s.Code
    and al.SKU<>''
    and Department='������'
    and ShopStatus='����'
    where ListingStatus=1
    group by grouping sets((department),(department,NodePathName))) t6
on t1.Department=t6.Department
and t1.team=t6.team
order by t1.team