   -- ͳ���� �Ŷ�  ָ������ ָ��ֵ ���� ��ĸ
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'  ,count(1) as ָ��ֵ ,0 as ���ʷ���  ,0 as ���ʷ�ĸ
from (select ShopCode ,SellerSKU ,ASIN,dep2
	from erp_amazon_amazon_listing eaal
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on eaal.shopcode=ms.Code
	 and ListingStatus = 1 and ms.ShopStatus = '����'
	group by shopcode,SellerSku,Asin ,dep2
	) tmp1
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
	,count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin)) `����������`
    ,0 ,0
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
    and isdeleted = 0 and TransactionType !='����' and OrderStatus <> '����'
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'���Ӷ�����' as ָ��  ,ifnull(a.dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
	,round(����������/����������,4) ,���������� ,����������
from (select ifnull(dep2,'��ٻ�') dep2 ,count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin)) `����������`
	from wt_orderdetails wo
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
		    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
	where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
	    and isdeleted = 0 and TransactionType !='����' and OrderStatus <> '����'
	group by grouping sets ((),(dep2))
	) a
join
	(select ifnull(dep2,'��ٻ�') as dep2 ,count(1) as ����������
	from (select ShopCode ,SellerSKU ,ASIN,dep2
		from erp_amazon_amazon_listing eaal
		join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
		    from import_data.mysql_store where department regexp '��')  ms on eaal.shopcode=ms.Code
		 and ListingStatus = 1 and ms.ShopStatus = '����'
		group by shopcode,SellerSku,Asin ,dep2
		) tmp1
	group by grouping sets ((),(dep2))
	) b
on a.dep2 = b.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'�������ӵ���' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
	,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , round(sum(totalgross/ExchangeUSD),2)
    , count(distinct concat(wo.shopcode,wo.SellerSku,wo.Asin))
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
    and isdeleted = 0 and TransactionType !='����' and OrderStatus <> '����'
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'�¿���������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
	,count(1) `�¿���������` ,0 ,0
from (select dep2,shopcode,SellerSku,Asin
      from import_data.wt_listing  eaal
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on eaal.shopcode=ms.Code
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}'
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0
	group by dep2,shopcode,SellerSku,Asin
	) tmp1
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��30�쿯��������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct shopcode,SellerSku,Asin ) `��30�쿯��������`
     ,0 ,0
from import_data.wt_listing  eaal
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on eaal.shopcode=ms.Code
where MinPublicationDate >= date_add('${NextStartDay}',interval - 30 day)  and MinPublicationDate <'${NextStartDay}'
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����7�����ӵ���' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 7 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����14�����ӵ���' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 14 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����30�����ӵ���' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( sum(totalgross/ExchangeUSD) / count(distinct concat(wo.shopcode,wo.SellerSku)) ,2 )
    , sum(totalgross/ExchangeUSD)
    , count(distinct concat(wo.shopcode,wo.SellerSku))
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
where paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
    and timestampdiff(second,PublicationDate,paytime)/86400 <= 30 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'�������۶�' as ָ��  ,ifnull(a.dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round(gross_include_refunds - ifnull(refunds,0),2) ,0 ,0
from (
    select
        ifnull(ms.dep2,'��ٻ�') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
        ,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
        ,count(distinct shopcode) `����������`
        ,count(distinct concat(shopcode,SellerSku)) `����������`
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'��ٻ�') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='���˿�' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'��ٻ�') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'���������' as ָ��  ,ifnull(a.dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
     ,0 ,0
from (
    select
        ifnull(ms.dep2,'��ٻ�') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
        ,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
        ,count(distinct shopcode) `����������`
        ,count(distinct concat(shopcode,SellerSku)) `����������`
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'��ٻ�') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='���˿�' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'��ٻ�') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,ifnull(a.dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) /
	        (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
     ,0 ,0
from (
    select
        ifnull(ms.dep2,'��ٻ�') dep2
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
        ,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
        ,count(distinct shopcode) `����������`
        ,count(distinct concat(shopcode,SellerSku)) `����������`
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a
left join (
    select ifnull(ms.dep2,'��ٻ�') dep2 ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on rf.OrderSource=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where RefundStatus ='���˿�' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((),(ms.dep2))
) b on  a.dep2 = b.dep2
left join (
    select  ifnull(ms.dep2,'��ٻ�') dep2  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code and ms.CompanyCode regexp 'A07|A08'
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.dep2 = c.dep2;



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'S����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type = '����S' then CONCAT( asin,site) end ) S����������
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'S����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type = '����S' then CONCAT( asin,site) end ) S����������
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'A����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type = '����A' then CONCAT( asin,site) end ) A����������
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'SA����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type regexp '����A|����S' then CONCAT( asin,site) end ) SA����������
    ,0 ,0
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'���϶�����' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `���϶�����`
    ,count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber  end)
    ,count(distinct PlatOrderNumber)
from import_data.wt_orderdetails  wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on wo.shopcode=ms.Code and wo.IsDeleted = 0
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}'
group by grouping sets ((),(ms.dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��SA���ӽ�30�쵥��' as ָ��  ,ifnull(Department,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round(sum(case when list_level not regexp  'S|A' then sales_in30d end) /count(case when list_level not regexp  'S|A' then 1 end),2) as ��SA���ӽ�30�쵥��
    , sum(case when list_level not regexp  'S|A' then sales_in30d end)
    , count(case when list_level not regexp  'S|A' then 1 end)
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
group by grouping sets ((),(Department));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'������SA���ӱ�' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( SA������ /������spu��,2) , SA������ , ������spu��
from (
select count(case when prod_level regexp '����|����' then 1 end) ������spu��
from import_data.dep_kbh_product_level akpl where akpl.FirstDay= '${StartDay}'
)a ,
(
select count(distinct case when list_level regexp 'S|A' then concat(asin,site) end) SA������
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
) b;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'�¶��ۼ��ƹ�������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    , count( distinct CONCAT( asin,site)  )
    ,0 ,0
from (
    select distinct c2 as site , c4 as asin ,c5 as dep2
    from import_data.manual_table  where handletime='2023-07-27' and handlename ='Ǳ�����ӱ�ǩ'
    ) t
group by grouping sets ((),(dep2));




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ��SPU����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( ��30�����۶�/��Ʒ��SPU�� ,0) ,0 ,0
from (
select
    round(sum((totalgross)/ExchangeUSD),2) ��30�����۶�
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '����'  and asin <>''  and ms.department regexp '��'
)a ,
(select count(distinct wp.spu) `��Ʒ��SPU��`
from import_data.wt_products wp
where ProjectTeam = '��ٻ�'
and wp.ProductStatus != 2
and IsDeleted = 0
and DevelopLastAuditTime is not null) b;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'���̵�Υ���¼����' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,sum(records)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2 ,sum(count) records
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
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
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
                from import_data.mysql_store where department regexp '��')  ms  on list.shopcode=ms.Code  and ms.Department='��ٻ�'
            where date(detail.CreationTime)='${NextStartDay}' -- v2�����ʱ����ͳ���յ��賿
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','45','46','48','49')
    group by shopcode,shopstatus,SellUserName ,site ,dep2
    ) a
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'�����̳���5��Υ���¼������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct shopcode)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
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
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
                from import_data.mysql_store where department regexp '��')  ms  on list.shopcode=ms.Code  and ms.Department='��ٻ�'
            where date(detail.CreationTime)='${NextStartDay}' -- v2�����ʱ����ͳ���յ��賿
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','45','46','48','49')
    group by shopcode,shopstatus,SellUserName ,site ,dep2 having sum(count) >=5
    ) a
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'0��200�ֵ�����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct shopcode)   ,0 ,0
from erp_amazon_amazon_shop_performance_check ahr
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
      from import_data.mysql_store where department regexp '��')  ms  on ahr.shopcode=ms.Code  and ms.Department='��ٻ�'
where date(CreationTime)='${NextStartDay}' -- v2�����ʱ����ͳ���յ��賿
and ms.shopstatus = '����'
and ahrscore<200
group by grouping sets ((),(dep2));




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒԭ���Υ���¼��' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,sum(records)   ,0 ,0
from (
    select shopcode,site,shopstatus,SellUserName ,dep2 ,sum(count) records
    from (
            select shopcode,site,SellUserName,ms.shopstatus ,ms.dep2
            ,itemtype itemtypeval
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
            end itemtype
            ,MetricsType,date(detail.CreationTime) date,count,concat(shopcode,date(detail.CreationTime)) val
            from erp_amazon_amazon_shop_performance_checkv2_detail detail
            left join erp_amazon_amazon_shop_performance_check list on list.Id=detail.AmazonShopPerformanceCheckId
            join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
                from import_data.mysql_store where department regexp '��')  ms  on list.shopcode=ms.Code  and ms.Department='��ٻ�'
            where date(detail.CreationTime)='${NextStartDay}' -- v2�����ʱ����ͳ���յ��賿
            ) list
    where  MetricsType=10
    and itemtypeval in ('40','41','42','46')
    group by shopcode,shopstatus,SellUserName ,site ,dep2
    ) a
group by grouping sets ((),(dep2));

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct spu) ,0 ,0
from dep_kbh_product_level_potentail where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = 'Ǳ����';


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ��Դ_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct dkplp.spu) ,0 ,0
from dep_kbh_product_level_potentail dkplp
join (select spu from view_kbp_new_products group by spu) vknp on dkplp.spu = vknp.spu
where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = 'Ǳ����';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ��Դ_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct dkplp.spu) ,0 ,0
from dep_kbh_product_level_potentail dkplp
left join (select spu from view_kbp_new_products group by spu) vknp on dkplp.spu = vknp.spu
where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay  and prod_level = 'Ǳ����' and vknp.spu is null;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ28��ɹ���_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) / count( distinct w0.spu) ,4)  ��Ǳ��Ʒ28��ɹ���_��Ʒ
     , count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) ,count( distinct w0.spu) ,'�ܱ�' as type
from ( select distinct dkpl.spu,StartDay  from  dep_kbh_product_level_potentail dkpl join (select spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    WHERE  StartDay >=  date(date_add('${NextStartDay}',interval -4 week )) and prod_level regexp 'Ǳ����'  ) w0 -- ����Ǳ����
left join ( select distinct spu,FirstDay from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${NextStartDay}',interval -4 week ))  and prod_level regexp '����|����' ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ28��ɹ���_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) / count( distinct w0.spu) ,4)  ��Ǳ��Ʒ28��ɹ���_��Ʒ
     , count(distinct case when timestampdiff(day,StartDay,FirstDay) >= 0 then w1.spu end ) ,count( distinct w0.spu) ,'�ܱ�' as type
from ( select distinct dkpl.spu,StartDay  from  dep_kbh_product_level_potentail dkpl left join (select spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    WHERE  StartDay >=  date(date_add('${NextStartDay}',interval -4 week )) and prod_level regexp 'Ǳ����' and vknp.spu is null ) w0 -- ����Ǳ����
left join ( select distinct spu,FirstDay from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${NextStartDay}',interval -4 week ))  and prod_level regexp '����|����' ) w1
    on w0.SPU = w1.SPU;




insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ����ɹ���' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct dkpl.spu) ,0 ,0
from dep_kbh_product_level dkpl
join ( select spu,min(StartDay) min_StartDay from dep_kbh_product_level_potentail where '${NextStartDay}' >= StartDay  and '${NextStartDay}'  <= EndDay
    and prod_level = 'Ǳ����'group by spu ) t
    on dkpl.spu = t.SPU and dkpl.prod_level regexp '��|��'  and dkpl.FirstDay > t.min_StartDay;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��SPU���߳���6��SPU��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(*) ,0 ,0
from (select spu
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '��ٻ�' and ShopStatus='����' and listingstatus=1
    and sku<>''
group by spu having count(distinct CompanyCode) > 6
) t;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ�⵱����Ȩ��ƷSPU��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct spu ) ,0 ,0
from erp_product_product_tort_infos eppti
join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
join wt_products wp on eppti.Id =wp.id and eppti.TorStatusChangeTime >= '${StartDay}' and  eppti.TorStatusChangeTime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and IsDeleted = 0;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��3������������Ʒ��Ȩ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct spu ) ,0 ,0
from erp_product_product_tort_infos eppti
join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
join wt_products wp on eppti.Id =wp.id and eppti.TorStatusChangeTime >= '${StartDay}' and  eppti.TorStatusChangeTime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and IsDeleted = 0
    and wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}';


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as ���ڵ�һ�� ,'��3����������Ʒ��Ȩ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round(��3��������Ȩ��Ʒ/��3�������Ʒ,4) ,��3��������Ȩ��Ʒ ,��3�������Ʒ
from (select count(distinct spu ) ��3�������Ʒ from wt_products wp where wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}' and ProjectTeam = '��ٻ�') t1
join (select count(distinct spu ) ��3��������Ȩ��Ʒ
    from erp_product_product_tort_infos eppti
    join (select ProductId from erp_product_product_tort_types where TortType in  (1,2,3,6) group by ProductId ) epptt on eppti.Id = epptt.ProductId
    join wt_products wp on eppti.Id =wp.id and wp.ProjectTeam = '��ٻ�' and IsDeleted = 0 and TorStatusChangeTime>= '${StartDay}'
        and wp.DevelopLastAuditTime >= '${StartDay}' and wp.DevelopLastAuditTime < '${NextStartDay}') t2;



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when week_0.prod_level='����' and week_bf1.prod_level != '����' then week_0.spu end )   -- ����������
    ,0 ,0 ,'�ܱ�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when week_0.prod_level='����' and week_bf1.prod_level not regexp  '����|����' then week_0.spu end )
    ,0 ,0 ,'�ܱ�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when week_0.prod_level='����' and week_0.isnew = '��Ʒ' and !(week_bf1.prod_level='����' and week_bf1.isnew = '��Ʒ') then week_0.spu end )   -- ��Ʒ����������
    ,0 ,0 ,'�ܱ�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when week_0.prod_level='����' and week_0.isnew = '��Ʒ' and !(week_bf1.prod_level='����' and week_bf1.isnew = '��Ʒ') then week_0.spu end )   -- ��Ʒ����������
   ,0 ,0 ,'�ܱ�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ������������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'�ܱ�' type
from manual_table where  handletime = '${StartDay}' and memo regexp '��Ʒ����������|��Ʒ����������' and c5 ='�ܱ�';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'���������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    , count(distinct PlatOrderNumber )
     ,0 ,0 ,'�ܱ�' type
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����'
join ( select spu from import_data.dep_kbh_product_level  where Department = '��ٻ�'  and prod_level regexp '����|����' group by spu ) dkpl on dkpl.SPU = wo.Product_SPU
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}';
