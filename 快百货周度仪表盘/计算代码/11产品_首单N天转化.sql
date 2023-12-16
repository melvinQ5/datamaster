
-- ͳ�������״γ�����SPU�����㵥��=ÿ��SPU30�����ۼƳ��������� �� ����SPU��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `�׵�30��SPU����`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
join  ( -- ͳ������ǰ��30�������״γ�����SPU,Ϊ�˸���30��
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '����'  and OrderStatus <> '����'
GROUP BY grouping sets ((),(dep2));




-- ͳ�������״γ�����SPU��ֻ�������ſ����Ĳ�Ʒ����
-- �ɶ�����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd_DevbySelf )
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `�׵�30��SPU����_�ɶ�����`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
join  ( -- ͳ������ǰ��30�������״γ�����SPU,Ϊ�˸���30��
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
join  ( -- ֻ�������ſ�����Ʒ�ĳ���
    select distinct staff_name, level2_name from import_data.dim_staff  where level2_name='��ٻ�һ��' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
    ) ds_cd on wo.Product_DevelopUserName = ds_cd.staff_name
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '����'  and OrderStatus <> '����';
-- Ȫ�ݿ���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuValueIn30dSinceFirstOrd_DevbySelf )
select '${StartDay}' ,'${ReportType}' ,'��ٻ�����' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.product_spu),2) `�׵�30��SPU����_�ɶ�����`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
join  ( -- ͳ������ǰ��30�������״γ�����SPU,Ϊ�˸���30��
    select product_spu from import_data.wt_orderdetails wo
    where DepSpuMinPayTime >= date_add( '${StartDay}',interval -30 day)  and DepSpuMinPayTime <  date_add( '${NextStartDay}',interval -30 day)
    group by product_spu
    ) tb on wo.product_spu = tb.product_spu
join  ( -- ֻ�������ſ�����Ʒ�ĳ���
    select distinct staff_name, level2_name from import_data.dim_staff  where level2_name='��ٻ�����' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
    ) ds_cd on wo.Product_DevelopUserName = ds_cd.staff_name
where timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 <= 30 and timestampdiff(SECOND,DepSpuMinPayTime,PayTime)/86400 > 0
     and wo.IsDeleted=0 and TransactionType = '����'  and OrderStatus <> '����';



-- �׵�SPU��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	FirstSaleSpuCnt )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.product_spu) `�׵�SPU��`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where DepSpuMinPayTime >='${StartDay}' and DepSpuMinPayTime < '${NextStartDay}'
GROUP BY grouping sets ((),(dep2));

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	FirstSaleSpuCnt )
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.product_spu) `�׵�SPU��`
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where DepSpuMinPayTime >='${StartDay}' and DepSpuMinPayTime < '${NextStartDay}'
GROUP BY NodePathName;
