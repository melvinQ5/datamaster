with
perf as (
select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
,itemtype
, case when itemtype=40 then '�����ַ�֪ʶ��Ȩ'
when itemtype=41 then '֪ʶ��ȨͶ��'
when itemtype=42 then '��Ʒ��ʵ�����Ͷ��'
when itemtype=43 then '��Ʒ״�����Ͷ��'
when itemtype=44 then 'ʳƷ����Ʒ��ȫ����'
when itemtype=45 then '�ϼ�����Υ��'
when itemtype=46 then 'Υ��������Ʒ����'
when itemtype=47 then 'Υ�������Ʒ��������'
when itemtype=48 then '����Υ������'
when itemtype=49 then 'Υ�����߾���'
when itemtype=50 then '��Ʒ��ȫ���Ͷ��'
end itemtype_name
,MetricsType,count ,list.ahrscore
from erp_amazon_amazon_shop_performance_checkv2_detail detail
left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms  on list.shopcode=ms.Code  and ms.Department='��ٻ�'
where MetricsType=10 and date(detail.CreationTime)='${NextStartDay}' -- v2�����ʱ����ͳ���յ��賿
and itemtype in ('40','41','42','45','46','48','49')
)

,t1 as (
select shopcode
     ,sum(count) ���̵�Υ���¼����
     ,case when sum(count) >= 5 then '��5��' end ����Υ��������
     ,sum(case when itemtype  in ('40','41','42','46')  then count end ) ��Ʒԭ��Υ���¼��
from perf group by shopcode
)

,t2 as ( -- 0��200�ֵ���������
select distinct ShopCode
from erp_amazon_amazon_shop_performance_check ahr
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
      from import_data.mysql_store where department regexp '��')  ms  on ahr.shopcode=ms.Code  and ms.Department='��ٻ�'
where date(CreationTime)='${NextStartDay}' and ms.shopstatus = '����' and ahrscore<200 )

,merge as (
select
    date('${NextStartDay}') ���ݸ�������
    ,case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ����
    ,NodePathName ����С��
    ,SellUserName ��ѡҵ��Ա
    ,ms.Code ���̼���
    ,ms.CompanyCode �˺ż���
    ,ms.Site վ��
    ,���̵�Υ���¼����
    ,����Υ��������
    ,��Ʒԭ��Υ���¼��
    ,ShopStatus ����״̬
    ,case when t2.ShopCode is not null and ShopStatus='����' then '���'  end 0��200�ֵ���������
from mysql_store ms
left join t1 on ms.Code=t1.ShopCode
left join t2 on ms.Code=t2.ShopCode
where ms.Department='��ٻ�'
)

select * from merge order by ���̵�Υ���¼���� desc