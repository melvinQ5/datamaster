
with lst as (
select  dkll .*
from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023
--  and dkll.FirstDay = '2023-07-10'
  and dkll.FirstDay = '2023-07-17'
	-- and dkll.Department = '��ٻ��ɶ�'
)

-- select * from lst where asin ='B0BMF1WF74'

, od_list_in30d as ( -- site,asin,spu,boxsku �ۺ�
select wo.site,asin,boxsku,shopcode,SellerSku,SellUserName,NodePathName,dep2
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('2023-07-24', INTERVAL -30 DAY) and PayTime<'2023-07-24' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'
group by wo.site,asin,boxsku,shopcode,SellerSku,SellUserName,NodePathName,dep2
)

/*
, od as ( -- site,asin,spu,boxsku �ۺ�
select * from (
select ROW_NUMBER () over ( partition by site,asin, spu order by orders desc ) as sort ,ta.*
from (
	select wo.site,asin, Product_SPU as spu ,ms.Code ,ms.SellUserName  ,count(distinct PlatOrderNumber) orders -- ������
	from import_data.wt_orderdetails wo
	join mysql_store ms on wo.shopcode=ms.Code
	where PayTime >='2023-01-01' and PayTime< '2023-07-01' and wo.IsDeleted=0
		and TransactionType <> '����'  and asin <>'' and ms.department regexp '��' and  NodePathName regexp '�ɶ�'
	group by wo.site,asin, spu ,ms.Code ,ms.SellUserName
	) ta
) tb
where tb.sort = 1
)
*/


, res as (
select
    date(date_add (date_add(lst.FirstDay,interval 1 week) ,interval -30 day )) as ��30�쿪ʼ����
    ,date(date_add (date_add(lst.FirstDay,interval 1 week) ,interval -1 day )) as ��30���������
     -- , week as ����
     , Department as �Ŷ�
     , case when list_level = 'ɢ��' then '����' else list_level end as list_level
     , lst.site
     , oli.shopcode
     , lst.asin
     , oli.sellersku  as ����SKU
     , oli.SellUserName
     , oli.NodePathName
    --  , case when wl.asin is not null then '����' else 'δ����' end as ����״̬
     , sales_no_freight as ��30�첻���˷����۶�
     , sales_in30d ��30�����۶�
     , profit_in30d ��30�������
     , list_orders ��30�충����
     , prod_level
     , oli.BoxSku
     , lst.spu
     , wp.sku
     , lst.ProductStatus as ��Ʒ״̬
     , lst.isnew as ����Ʒ״̬
     , lst.ele_name as Ԫ��
     , wp.ProductName
     , date(wp.DevelopLastAuditTime) ����ʱ��
     -- ,od.code �ϰ������ӵ���top1���̼���, od.SellUserName ��ѡҵ��Ա
from lst
join od_list_in30d oli on lst.asin = oli.asin and lst.site = oli.site
left join wt_products wp on oli.BoxSku = wp.BoxSku
    /*
left join
    (select asin ,wl.shopcode ,wl.sellersku from wt_listing wl join mysql_store ms
        on  wl.ShopCode =ms.Code and ms.ShopStatus='����' and wl.ListingStatus= 1 group by asin ,wl.shopcode ,wl.sellersku ) wl
      on oli.asin = wl.asin and oli.shopcode =wl.shopcode and oli.sellersku =wl.sellersku

     */
)

-- select count(1) from res where list_level regexp 'S|A'

select count(1) from res where list_level regexp 'S|A'
-- where ����SKU = 'IQBJQG-UK-230526-176'
--  select ����״̬ ,count(1) from res group by ����״̬

/*
select distinct wo.sellersku ,wo.BoxSku ,wo.shopcode
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >=date_add('2023-07-24', INTERVAL -30 DAY) and PayTime<'2023-07-24' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'
    and asin = 'B0C8CJXVR7'