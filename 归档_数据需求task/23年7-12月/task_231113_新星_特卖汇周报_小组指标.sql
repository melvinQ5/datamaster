/*������С��ָ��*/
/*������С���Ӧ������Ա*/
SELECT u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��');
-- ע��TOPASIN��ʱ��

/*��������*/
with sale as(
                   with orderdetails as(select TotalGross,CreationTime,TotalProfit,left(user.NodePathName,3) 'dep',right(user.NodePathName,7) as team,Name,PlatOrderNumber,ord.Asin,shopcode,TotalExpend,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,s.* from import_data.wt_orderdetails ord   /*�������������ݣ�*/
                   inner join (select eg.Asin,eg.Site,eg.CreationTime,s.NodePathName,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT d.NodePathName,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                on ap.AssignUserName=s.Name) as user
                                on ord.Asin=user.Asin
                                and ord.Site=user.Site
                   inner join mysql_store s
                   on ord.shopcode=s.Code/*����ά��*/
                   and s.Department='������'
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and ord.IsDeleted=0)
                select team,ifnull(Name,'С�����') as 'name',˰�����۶�, expend, ������ from
                (select team,Name,round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) '˰�����۶�' ,
                round(sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then AdvertisingCosts/ExchangeUSD end),0)),2) 'expend',
                count(distinct case when TransactionType<>'����' and TotalGross>0 then PlatOrderNumber end) '������'
                from orderdetails
                group by grouping sets ((team),(team,Name))
                order by team,Name) a

/*TOPASIN*/
),top1 as
      (select a.team, a.Name, TOP1���ӹ���ҵ��,b.TOP1ASIN���ﳵӮ���� from
        (select t3.team,ifnull(Name,'С�����') as Name, TOP1���ӹ���ҵ�� from(
            select team,name, round(sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD),2)  'TOP1���ӹ���ҵ��'  from ods_orderdetails od
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
            inner join mysql_store s
            on od.ShopIrobotId=s.Code/*����ά��*/
            and s.Department='������'
            where IsDeleted=0
            and TransactionType='����'
            and OrderStatus<>'����'
            and PayTime>='${StartDay}'
            and PayTime<'${EndDay}'
            group by grouping sets ((team),(team,Name))) t3
        ) a
    left join (select c1.team, c1.Name, ASIN�ÿ���,round(c2.���̷ÿ���/c1.ASIN�ÿ���,4) 'TOP1ASIN���ﳵӮ����' from
(
        select c.team, ifnull(Name,'С�����')Name, ASIN�ÿ��� from
(select team,Name,sum(t4.TotalCount2) 'ASIN�ÿ���' from
(select team,Name,max(TotalCount) TotalCount2  from ListingManage lm
       inner join  (select t2.Asin, t2.Site, team, Name from
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
        on lm.ChildAsin=t3.ASIN
        and lm.StoreSite=t3.Site
        inner join mysql_store s
        on lm.shopcode=s.Code/*����ά��*/
        and s.Department='������'
        where ReportType='�ܱ�'
        and Monday='${StartDay}'
        group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite,team,Name) t4
group by grouping sets( (team),(team,Name))
) c) c1
        left join
       (select t4.team, ifnull(Name,'С�����') as 'name',���̷ÿ��� from
               (select team,name,round(sum(TotalCount*FeaturedOfferPercent/100),2) '���̷ÿ���' from ListingManage ls
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
                    and t1.Site=t2.Site) t1
                on ls.ChildAsin=t1.ASIN
                and right(ls.shopcode,2)=t1.Site
                inner join mysql_store s
                on ls.ShopCode=s.Code
                and s.Department='������'
                where ReportType='�ܱ�'
                and Monday='${StartDay}'
                group by grouping sets ((team),(team,Name))) t4
                ) c2
                on c1.team=c2.team
                and c1.Name=c2.name
)b
on a.Name=b.Name
and a.team=b.team
/*��ASIN��������*/

),tmp as ( select b.team, ifnull(Name,'С�����') as name, ����ASIN����ҵ��, ����ASIN��, ��ASIN����ҵ��, ������ASIN��  from
                   (select  team,name,sum((TotalGross+TaxGross-RefundAmount)/ExchangeUSD) '����ASIN����ҵ��',
                   count(distinct concat(user.Asin,right(ShopIrobotId,2))) '����ASIN��',
                   sum(case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then  (TotalGross+TaxGross-RefundAmount)/ExchangeUSD  end ) '��ASIN����ҵ��',/*����״̬(8:���ϼ�,9:���ϼ�,10:�¼�)*/
                   count(distinct case when FollowUpStatus=9 and FirArrivalTime>=date_add('${StartDay}',interval -day('${StartDay}')+1 day) then concat(user.Asin,right(ShopIrobotId,2)) end) '������ASIN��' from import_data.ods_orderdetails ord   /*�������������ݣ�*/
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
                   inner join  mysql_store s
                   on ord.ShopIrobotId=s.Code/*����ά��*/
                   and s.Department='������'
                   where PayTime>='${StartDay}'/*ʱ�䷶Χ*/
                   and PayTime<'${EndDay}'
                   and TransactionType<>'�˿�'
                   and OrderStatus<>'����'   /*�޳����϶�����δ��ȥ�˿�˰ǰ���۶�*/
                   and ord.IsDeleted=0
                   group by grouping sets ((team),(team,Name))) b

/*������ASIN��*/
),ls as( select t1.team, ifnull(Name,'С�����') as 'Name', �ᱨASIN��, �ϼ�ASIN��,����ASIN��,`3�����ϼ�ASIN��` from
                                (select team,name,
                                count(distinct case when eg.CreationTime>='${StartDay}' and eg.CreationTime<'${EndDay}'  then concat(eg.Asin,eg.Site) end) '�ᱨASIN��',
                                count(distinct case when FollowUpStatus=9 and FirArrivalTime>='${StartDay}'  and FirArrivalTime<'${EndDay}' then concat(eg.Asin,eg.Site) end) '�ϼ�ASIN��',
                                count(distinct case when eg.CreationTime>=date_add('${StartDay}',interval -3 day) and eg.CreationTime<date_add('${EndDay}',interval -3 day) then concat(eg.Asin,eg.Site) end) '����ASIN��',
                                sum(case when eg.CreationTime>=date_add('${StartDay}',interval -3 day) and eg.CreationTime<date_add('${EndDay}',interval -3 day) and FollowUpStatus=9
                                and  timestampdiff(second,eg.CreationTime,FirArrivalTime)<86400*3 then 1 end) '3�����ϼ�ASIN��' /*3�����ϼ�ASIN��*/
                                from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap  /*ע���Ƿ�ɾ��*/
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                on ap.AssignUserName=s.Name
                                group by grouping sets ((team),(team,Name))) t1

/*������������ASIN*/
),tm as( select  team, ifnull(Name,'С�����') as 'name', ������ASIN��, `��ASIN����(����SKU)` from
                         (select team,name,
                         count(distinct concat(t1.ASIN,t1.code)) '������ASIN��' ,
                         count(distinct SellerSKU) '��ASIN����(����SKU)' from
                        (select ASIN,right(ShopCode,2) code,SellerSKU from erp_amazon_amazon_listing al
                        inner join  mysql_store s
                        on al.ShopCode=s.Code
                        and s.Department='������'
                        and ListingStatus=1) as t1
                        inner join
                        (select eg.Asin,eg.Site,eg.CreationTime,s.dep,s.team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                on ap.AssignUserName=s.Name) t2
                        on t1.ASIN=t2.Asin
                        and t1.code=t2.Site
                        group by grouping sets ((team),(team,Name))) t2
/*�˿�����*/
),ref as (select t2.team, ifnull(Name,'С�����') as 'name', �˿���,�ǿͻ�ԭ���˿��� from
             (select team,name,sum(RefundUSDPrice) '�˿���',sum(case when RefundReason1='�ɹ�ԭ��' then  RefundUSDPrice end) '�ɹ�ԭ���˿���',
            sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01')  then  RefundUSDPrice end) '�ǿͻ�ԭ���˿���'  from import_data.daily_RefundOrders rf
           inner join (select OrderNumber,team,Name from ods_orderdetails od
                      inner join (select eg.Asin,eg.Site,s.dep,s.team,s.Name from erp_gather_gather_asin eg
                                inner join erp_gather_gather_amazon_products ap  /*С���ӦASIN����*/
                                on eg.GatherProductId =ap.Id
                                inner join (SELECT left(d.NodePathName,3) as dep,right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                inner join erp_user_user_departments  d on  u.departmentId = d.id
                                where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s /*С���ӦС���Ա*/
                                on ap.AssignUserName=s.Name) user
                        on od.Asin=user.Asin     /*ʹ��INNER JOINʱȷ������һ�ű���Ψһ��*/
                        and right(od.ShopIrobotId,2)=user.Site
                        and od.IsDeleted=0
                        and TransactionType='����' /*��������Ϊ���δɾ��*/
                        inner join mysql_store s
                        on od.ShopIrobotId=s.Code
                        and s.Department='������'
                        group by OrderNumber,team,Name) as t1
           on rf.OrderNumber=t1.OrderNumber
           where RefundStatus='���˿�'
           and RefundDate>='${StartDay}'/*ʱ��ά��*/
           and RefundDate<'${EndDay}'
           group by grouping sets ((team),(team,name))) t2
/*�ÿ�����*/
),visitor as (select c1.team, c1.Name, ASIN�ÿ���,round(c2.�ÿ���/c1.ASIN�ÿ���,4) '���ﳵӮ����',c2.�ÿ���,c2.�ÿ����� from
(
        select c.team, ifnull(Name,'С�����')Name, ASIN�ÿ��� from
(select team,Name,sum(t4.TotalCount2) 'ASIN�ÿ���' from
(select team,Name,max(TotalCount) TotalCount2  from ListingManage lm
       inner join
    (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*�ҳ����ĸ�����*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                        on ap.AssignUserName=s.Name) as t2
        on lm.ChildAsin=t2.ASIN
        and lm.StoreSite=t2.Site
        inner join mysql_store s
        on lm.ShopCode=s.Code
        and s.Department='������'
        where ReportType='�ܱ�'
        and Monday='${StartDay}'
        group by lm.ParentAsin,lm.ChildAsin,lm.StoreSite,team,Name) t4
group by grouping sets( (team),(team,Name))
) c) c1
        left join
       (select t4.team, ifnull(Name,'С�����') as 'name',�ÿ���,�ÿ����� from
               (select team,name,round(sum(TotalCount*FeaturedOfferPercent/100),2) '�ÿ���',sum(OrderedCount) '�ÿ�����'  from ListingManage ls
                inner join
                (select eg.Asin,eg.Site,s.team,Name from erp_gather_gather_asin eg
                                        inner join erp_gather_gather_amazon_products ap
                                        on eg.GatherProductId =ap.Id  /*�ҳ����ĸ�����*/
                                        inner join (
                                        SELECT right(d.NodePathName,7) as team,u.Name FROM erp_user_abpusers u
                                        inner join erp_user_user_departments  d on  u.departmentId = d.id
                                        where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) s
                                        on ap.AssignUserName=s.Name) as t2
                on ls.ChildAsin=t2.ASIN
                and ls.StoreSite=t2.Site
                inner join mysql_store s
                on ls.ShopCode=s.Code
                and s.Department='������'
                where ReportType='�ܱ�'
                and Monday='${StartDay}'
                group by grouping sets ((team),(team,Name))) t4
                ) c2
                on c1.team=c2.team
                and c1.Name=c2.name                                                                                                  )

select t1.team, name, ˰�����۶�, ��֧��, ���۶�, �����, ������, �˿���, �˿���, �ǿͻ�ԭ���˿���, �ǿͻ�ԭ���˿���, TOP1���ӹ���ҵ��, ����ASIN����ҵ��, TOP1ASIN���ﳵӮ����, TOP1ASIN����ҵ��ռ��, `3�����ϼ�ASIN��`, ����ASIN��, ��ASIN3���ϼ���, ��ASIN����ҵ��, ������ASIN��, �ϼ�ASIN��, �ᱨASIN��, ��ASIN����, ��ASIN��Ч��, ��ASIN������, ��ASIN�ϼ���, ��ASIN����ҵ��, `��ASIN����ҵ��%`, ������ASIN��, ��ASIN��, ��ASIN������, ������ASIN��, ��ASIN������, �ÿ���, �ÿ�����, �ÿ�ת����, ���ﳵӮ���� from (
(select tt.team
  , case when tt.team regexp 'TMH����1��' then '0.1'
         when tt.team regexp 'TMH����2��' then '0.2'
         when tt.team regexp 'TMH����3��' then '0.3' end 'sort'
  , tt.name,˰�����۶�, expend as '��֧��',round(˰�����۶�-ifnull(�˿���,0),2) '���۶�',round(˰�����۶�+expend-ifnull(�˿���,0),2) '�����',
  round((˰�����۶�+expend-ifnull(�˿���,0))/(˰�����۶�-ifnull(�˿���,0)),4) '������',�˿���,round(�˿���/˰�����۶�,4) '�˿���',�ǿͻ�ԭ���˿���,
  round(�ǿͻ�ԭ���˿���/˰�����۶�,4) '�ǿͻ�ԭ���˿���',TOP1���ӹ���ҵ��,����ASIN����ҵ��, TOP1ASIN���ﳵӮ����,round(TOP1���ӹ���ҵ��/����ASIN����ҵ��,4) 'TOP1ASIN����ҵ��ռ��',
  3�����ϼ�ASIN��,����ASIN��,round(`3�����ϼ�ASIN��`/����ASIN��,4) '��ASIN3���ϼ���',��ASIN����ҵ��,������ASIN��,�ϼ�ASIN��,�ᱨASIN��,round(��ASIN����ҵ��/������ASIN��,2) '��ASIN����',
  round(������ASIN��/�ᱨASIN��,4) '��ASIN��Ч��',round(������ASIN��/�ϼ�ASIN��,4) '��ASIN������',round(�ϼ�ASIN��/�ᱨASIN��,4) '��ASIN�ϼ���',
  round(����ASIN����ҵ��-��ASIN����ҵ��) '��ASIN����ҵ��',round((����ASIN����ҵ��-��ASIN����ҵ��)/����ASIN����ҵ��,4) '��ASIN����ҵ��%',
  ����ASIN��-������ASIN�� as '������ASIN��',������ASIN��-�ϼ�ASIN�� as '��ASIN��',round((����ASIN��-������ASIN��)/(������ASIN��-�ϼ�ASIN��),4) '��ASIN������',������ASIN��,round(����ASIN��/������ASIN��,4)  '��ASIN������',
  visitor.�ÿ���,visitor.�ÿ�����,round(�ÿ�����/�ÿ���,4) '�ÿ�ת����',visitor.���ﳵӮ���� from
(select 'TMH����1��' as team,'С�����'as name
union
select 'TMH����2��' as team,'С�����'as name
union
select 'TMH����3��' as team,'С�����'as name
union
SELECT right(d.NodePathName,7) team,u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) as tt
left join sale
on tt.team=sale.team
and tt.name=sale.name
left join top1
on tt.team=top1.team
and tt.name=top1.name
left join tmp
on tt.team=tmp.team
and tt.name=tmp.name
left join ls
on tt.team=ls.team
and tt.name=ls.name
left join tm
on tt.team=tm.team
and tt.name=tm.name
left join ref
on tt.team=ref.team
and tt.name=ref.name
left join visitor
on tt.team=visitor.team
and tt.name=visitor.name
where tt.name='С�����'
)

union all

(select tt.team
  ,case when tt.team regexp 'TMH����1��' then '1'
         when tt.team regexp 'TMH����2��' then '2'
         when tt.team regexp 'TMH����3��' then '3' end 'sort'
  , tt.name,˰�����۶�, expend as '��֧��',round(˰�����۶�-ifnull(�˿���,0),2) '���۶�',round(˰�����۶�+expend-ifnull(�˿���,0),2) '�����',
  round((˰�����۶�+expend-ifnull(�˿���,0))/(˰�����۶�-ifnull(�˿���,0)),4) '������',�˿���,round(�˿���/˰�����۶�,4) '�˿���',�ǿͻ�ԭ���˿���,
  round(�ǿͻ�ԭ���˿���/˰�����۶�,4) '�ǿͻ�ԭ���˿���',TOP1���ӹ���ҵ��,����ASIN����ҵ��, TOP1ASIN���ﳵӮ����,round(TOP1���ӹ���ҵ��/����ASIN����ҵ��,4) 'TOP1ASIN����ҵ��ռ��',
  3�����ϼ�ASIN��,����ASIN��,round(`3�����ϼ�ASIN��`/����ASIN��,4) '��ASIN3���ϼ���',��ASIN����ҵ��,������ASIN��,�ϼ�ASIN��,�ᱨASIN��,round(��ASIN����ҵ��/������ASIN��,2) '��ASIN����',
  round(������ASIN��/�ᱨASIN��,4) '��ASIN��Ч��',round(������ASIN��/�ϼ�ASIN��,4) '��ASIN������',round(�ϼ�ASIN��/�ᱨASIN��,4) '��ASIN�ϼ���',
  round(����ASIN����ҵ��-��ASIN����ҵ��) '��ASIN����ҵ��',round((����ASIN����ҵ��-��ASIN����ҵ��)/����ASIN����ҵ��,4) '��ASIN����ҵ��%',
  ����ASIN��-������ASIN�� as '������ASIN��',������ASIN��-�ϼ�ASIN�� as '��ASIN��',round((����ASIN��-������ASIN��)/(������ASIN��-�ϼ�ASIN��),4) '��ASIN������',������ASIN��,round(����ASIN��/������ASIN��,4)  '��ASIN������',
  visitor.�ÿ���,visitor.�ÿ�����,round(�ÿ�����/�ÿ���,4) '�ÿ�ת����',visitor.���ﳵӮ���� from
(select 'TMH����1��' as team,'С�����'as name
union
select 'TMH����2��' as team,'С�����'as name
union
select 'TMH����3��' as team,'С�����'as name
union
SELECT right(d.NodePathName,7) team,u.Name FROM erp_user_abpusers u
inner join erp_user_user_departments  d on  u.departmentId = d.id
where d.nodePathName in ('������>TMH����1��','������>TMH����2��','������>TMH����3��')) as tt
left join sale
on tt.team=sale.team
and tt.name=sale.name
left join top1
on tt.team=top1.team
and tt.name=top1.name
left join tmp
on tt.team=tmp.team
and tt.name=tmp.name
left join ls
on tt.team=ls.team
and tt.name=ls.name
left join tm
on tt.team=tm.team
and tt.name=tm.name
left join ref
on tt.team=ref.team
and tt.name=ref.name
left join visitor
on tt.team=visitor.team
and tt.name=visitor.name
where tt.name<>'С�����'
)) t1
where t1.name<>'���������Ȩ��'
order by t1.sort;




