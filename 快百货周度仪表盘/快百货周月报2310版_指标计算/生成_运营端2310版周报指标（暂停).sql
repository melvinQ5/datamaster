
-- ���۶�
insert into ads_kbh_report_metrics ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,FirstDay,
TotalGross
)

with
sku_refund as ( -- ����Ʒ��������ռ�ȷ�̯�����˿�
select rf.PlatOrderNumber ,RefundUSDPrice ,wo.Product_Sku ,wo.SalesGross
    ,RefundUSDPrice * ( wo.SalesGross / sum(SalesGross) over (partition by rf.PlatOrderNumber) ) sku_RefundUSDPrice
from (
select PlatOrderNumber ,sum(RefundUSDPrice) RefundUSDPrice
from daily_RefundOrders a
where RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='���˿�'
group by PlatOrderNumber
) rf
left join wt_orderdetails wo on rf.PlatOrderNumber = wo.PlatOrderNumber and wo.IsDeleted=0 and TransactionType ='����'
-- where rf.PlatOrderNumber = '206-7603264-9688336'
)

,od as ( -- todo wo���еĺܶ� porduct_sku Ϊ��, ��Ϊ�ò�Ʒ�������д��� δͬ����erp ,���� BoxSKU=1786914 ,�ڴ�������Ʒ�����������ʱͳһ�鵽 ��Ʒ�������У��Ա㱣֤������ϵ
select dep2 ,NodePathName
    ,round( TotalGross/ExchangeUSD - ifnull(sku_RefundUSDPrice,0) ,2) TotalGross_usd
    ,case when d.sku is null then '��Ʒ' else isnew end isnew
    ,case when d.sku is null then '������Ʒ' else istheme end istheme
    ,case when d.sku is null then '�Ǹ�ǱƷ' else ispotenial end ispotenial
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join sku_refund sr on wo.PlatOrderNumber=sr.PlatOrderNumber and wo.Product_Sku = sr.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.Department='��ٻ�' and TransactionType = '����'
)

 ,od_stat as (
select ifnull(coalesce(dep2,NodePathName),'��ٻ�') team
        ,istheme ,isnew ,ispotenial
        ,round( sum( TotalGross_usd ),2 ) as TotalGross_usd -- ����������ӻض������˿���
from od
group by grouping sets ((istheme ,isnew ,ispotenial),(istheme ,isnew ,ispotenial,dep2),(istheme ,isnew ,ispotenial,nodepathname))
)


select
    concat(team ,isnew)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'�ܱ�' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew
union all
select
    concat(team ,isnew ,istheme)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'�ܱ�' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew ,istheme
union all
select
    concat(team ,isnew ,ispotenial)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'�ܱ�' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew ,ispotenial
