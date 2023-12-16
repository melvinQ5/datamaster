/*����=���ҳ�����ʱ����3�¼��Ժ����Ʒ-SPUά��*/
with testspu as
(
select [
'5358173'
]arr
)

,testspulist as(
select *
from (select unnest as testspu,'��Сģ��' mark
	from testspu ,unnest(arr)
	) tmp
)

-- select * from testspulist
--

,epp as (
select pp.sku,pp.boxsku,pp.spu,date(spu.AuditTime)AuditTime,DATE_FORMAT(spu.AuditTime,'%Y-%m-01') developmon
,year(spu.AuditTime) developyear
,split_part(pc.CategoryPathByChineseName,'>',1) category1 , CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2) ) category2 ,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3) ) category3 ,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4) ) category4,CONCAT(split_part(pc.CategoryPathByChineseName,'>',1) ,'>',split_part(pc.CategoryPathByChineseName,'>',2),'>',split_part(pc.CategoryPathByChineseName,'>',3),'>',split_part(pc.CategoryPathByChineseName,'>',4),'>',split_part(pc.CategoryPathByChineseName,'>',5) ) category5,IFNULL(fes.newele_name,'����')ele_name,case pp.productstatus
when 0 then '����'
when 2 then 'ͣ��'
when 3 then 'ͣ��'
when 4 then '��ʱȱ��'
when 5 then '���'
end productstatus,
(case when test.mark='��Сģ��' then test.mark else '���Կ�Ʒ' end ) as producttype
from erp_product_products pp
join (select spu,min(DevelopLastAuditTime)AuditTime from erp_product_products where ProjectTeam='��ٻ�'
and isdeleted=0  group by spu  ) spu on spu.spu=pp.spu
 left join ( -- Ԫ��ӳ�����С������ SKU+NAME
select sku,ele_name,(case when  ele_name like '%����%' then '����'  when  ele_name like '%�ļ�%' then '�ļ�' when  ele_name like '%����%' then '�����'when  ele_name like '%��ի%' then '��ի��' when  ele_name like '%ʥ����%' then 'ʥ����'  when  ele_name like '%ʥ��%' then 'ʥ��'  when  ele_name like '%��ʥ%' then '��ʥ' when  ele_name like '%�ж�%' then '�ж�' else '����'  end) newele_name  from
(
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products epp on eppaea.sku = epp.sku
where
epp.ProjectTeam ='��ٻ�' and
epp.IsMatrix=0 and epp.IsDeleted=0
group by eppaea.sku
) a
) fes on fes.sku=pp.sku
join testspulist test on test.testspu=pp.spu
left join (
select pp.sku,concat(pc.CategoryPathByChineseName,'>>>>>') CategoryPathByChineseName from erp_product_products pp
join import_data.erp_product_product_category pc on pc.id=pp.ProductCategoryId) pc on pc.sku=pp.sku
where pp.ismatrix=0
and pp.ProjectTeam='��ٻ�'
and pp.isdeleted=0
and pp.DevelopLastAuditTime<'2023-12-11' and pp.DevelopLastAuditTime>='2023-11-20'
and (pp.ProductStopTime >='2023-11-27' or pp.ProductStopTime is null)
)



-- select * from epp

,asin as (
select asin,site,sku,PublicationDate,���ӿ����·� from (
select asin,site,sku,PublicationDate,���ӿ����·�,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort from(
select  ASIN, site,sku,PublicationDate,TIMESTAMPDIFF(month,(case when PublicationDate>='2023-11-27'then PublicationDate else  '2023-11-27'end),'2023-12-11')+1 ���ӿ����·� from (
select ASIN,MarketType site,sku,PublicationDate,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort  from erp_amazon_amazon_listing al
join mysql_store s on s.code =al.shopcode and s.Department='��ٻ�'
where al.sku<>''
)a where sort=1
union
select  ASIN, site,sku,PublicationDate,TIMESTAMPDIFF(month,(case when PublicationDate>='2023-11-27'then PublicationDate else'2023-11-27' end),LastModificationTime)+1 ���ӿ����·� from (
select ASIN,MarketType site,sku,PublicationDate,LastModificationTime,row_number() over(PARTITION by concat(asin,site) order by PublicationDate desc) sort from erp_amazon_amazon_listing_delete al
join mysql_store s on s.code =al.shopcode and s.Department='��ٻ�'
and LastModificationTime>='2023-11-27' and LastModificationTime<'2023-12-11'
where al.sku <>''
)b where sort=1
)c
)d where sort=1
)


,list as
(
select epp.*,asin,site,PublicationDate,���ӿ����·�,case when ele_name='����' then '������' else '����' end ���� from epp
left join asin on asin.sku=epp.sku
-- where ele_name='����'
)
-- select * from list

,kandeng as(
select spu,count(distinct concat(asin,site))lists,round(avg(ifnull(���ӿ����·�,0)),4) ���ӿ����·� from list
group by spu
)


,ta as
(
select [
'40',
'41',
'42',
'43',
'44',
'45',
'46',
'47',
'48',
'49',
'50',
'51',
'52',
'53',
'54'
]arr
)

,tb as(
select *
from (select unnest as wee
	from ta ,unnest(arr)
	) tmp
)

,total as(/*����ȫ��������ƥ��*/
select * from tb
cross join list
)


,ad as(
select a.sku1 sku, spu,year,week,asin,site,sum(AdExposure)AdExposure,sum(adclicks)adclicks,round(sum(adspend),2)adspend,round(sum(adsales),2)adsales ,round(sum(adsaleunits),2)adorders from (
select ad.*,list.sku sku1 ,list.spu,right(ad.shopcode,2)site from wt_adserving_amazon_weekly ad
join list  on list.asin=ad.asin and list.site=right(ad.shopcode,2)
where Year='2023' and week=weekofyear('2023-12-11')
)a
group by a.sku1,year,week,asin,site,spu
)
,baoguang as(
select spu,count( distinct case when AdExposure>0 then concat(asin,site) end) �ع������� from(
select spu,asin,site,sum(AdExposure)AdExposure from ad
group by spu,asin,site
)adspu
group by spu
)


,ods as(
select (WEEKOFYEAR(paytime)+1)wee,od.asin,od.site
,round(sum(TotalGross/ExchangeUSD),2)sales
,round(sum(TotalProfit/ExchangeUSD),2)profit
,round(sum(refundamount/ExchangeUSD),2)refund
,round(sum(promotionaldiscounts/ExchangeUSD),2) promotionaldiscounts
,round(sum(feegross/ExchangeUSD),2) �˷�����
,round(sum(PromotionalDiscounts/ExchangeUSD),2) Ӫ���ۿ�
,round(sum(OtherExpend/ExchangeUSD),2) ƽ̨����֧��
,round(sum(TradeCommissions/ExchangeUSD),2) ƽ̨Ӷ��
,round(sum(AdvertisingCosts/ExchangeUSD),2) ���ǲ��
,round(sum(PurchaseCosts/ExchangeUSD),2) �ɹ��ɱ�
,round(sum(localfreight/ExchangeUSD),2) �����ɱ�
,count(distinct PlatOrderNumber) orders
,sum(salecount) ����
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='��ٻ�'
and  product_spu not regexp '5358176|5358173'
and paytime>='2023-11-27' and paytime<'2023-12-11'
and orderstatus<>'����'
group by wee,od.asin,od.site
order by wee asc
)



-- select weekofyear('2023-08-03')+1

,ods1 as(
select list.spu,count( distinct DATE_FORMAT(od.paytime,'%Y-%m-01'))salesmon,count (distinct weekofyear(od.paytime))salewee
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='��ٻ�'
and paytime>='2023-11-27' and paytime<'2023-12-11'
group by list.spu
)

,ods2 as(select spu,sum(listsalemon)listsalemon,count(distinct(concat(asin,site))) salelist,(sum(listsalemon)/count(distinct(concat(asin,site))) ) ƽ�����������·� from(
select list.asin,list.site,list.spu,count( distinct DATE_FORMAT(od.paytime,'%Y-%m-01'))listsalemon,count (distinct weekofyear(od.paytime))listsalewee
from  wt_orderdetails od
join list on list.asin=od.asin and list.site=od.site
where od.isdeleted=0
and department='��ٻ�'
and paytime>='2023-11-27' and paytime<'2023-12-11'
group by list.asin,list.site,list.spu
)a
group by spu
)
-- select * from ods2

,huizong as(
select
total.producttype,
total.wee,
total.sku,
total.boxsku,
total.spu,
total.AuditTime,
developmon,
developyear,
category1,
category2,
category3,
category4,
category5,
ele_name,
����,
productstatus,
total.asin,
total.site,
total.PublicationDate,
sales,
profit,
refund,
promotionaldiscounts,
�˷�����,
Ӫ���ۿ�,
ƽ̨����֧��,
ƽ̨Ӷ��,
���ǲ��,
�ɹ��ɱ�,
�����ɱ�,
orders,
����,
AdExposure,
adclicks,
adspend,
adsales,
adorders
from total
left join ad on ad.asin=total.asin and ad.site=total.site and ad.week=total.wee
left join ods on ods.asin=total.asin and ods.site=total.site and ods.wee=total.wee
)

-- select * from  wt_orderdetails od
-- where TransactionType='����' Limit 10
--
-- select * from  huizong
--
,spulist as(
select spu,����,producttype prodtype,sum(orders) orders
,sum(����) ����
,round(sum(sales),2)sales
,round(sum(profit),2)profit
,round(sum(ifnull(profit,0))-sum(ifnull(adspend,0)),2)profitnew
,round(sum(refund),2)refund
,round(sum(promotionaldiscounts),2) promotional
,round(sum(�˷�����),2) �˷�����
,round(sum(Ӫ���ۿ�),2) Ӫ���ۿ�
,round(sum(ƽ̨����֧��),2) ƽ̨����֧��
,round(sum(ƽ̨Ӷ��),2) ƽ̨Ӷ��
,round(sum(�ɹ��ɱ�),2) �ɹ��ɱ�
,round(sum(�����ɱ�),2) �����ɱ�
,sum(AdExposure)AdExposure
,sum(adclicks)adclicks
,round(sum(adspend),2)adspend
,round(sum(adsales),2)adsales
,round(sum(adorders),2)adorders
,round((sum(ifnull(profit,0))-sum(ifnull(adspend,0)))/sum(sales),4) ������
,round(sum(adspend)/sum(sales),4) ��滨����
,round(sum(refund)/sum(sales-refund),4) �˿���
,round(sum(�˷�����)/sum(sales),4) �˷�������
,round(sum(Ӫ���ۿ�)/sum(sales),4) Ӫ���ۿ���
,round(sum(ƽ̨����֧��)/sum(sales),4) ƽ̨����֧����
,round(sum(ƽ̨Ӷ��)/sum(sales),4) ƽ̨Ӷ����
,round(sum(�ɹ��ɱ�)/sum(sales),4) �ɹ��ɱ���
,round(sum(�����ɱ�)/sum(sales),4) �����ɱ���
,round(sum(adsales)/sum(sales),4) ���ҵ��ռ��
,round(sum(adclicks)/sum(AdExposure),4) CTR
,round(sum(adorders)/sum(adclicks),4) CVR
,round(sum(adspend)/sum(adclicks),4) CPC
from huizong
group by spu,����,producttype
)

-- select * from spulist

,spuhuizong as(
select a.spu,a.developmon,ifnull(a.��Ʒ�����·�,0)��Ʒ�����·�,(case when AuditTime>='2023-01-01' then '��Ʒ' else '��Ʒ' end) prod,����,prodtype,
orders,
����,
sales,
profit,
profitnew,
refund,
promotional,
�˷�����,
Ӫ���ۿ�,
ƽ̨����֧��,
ƽ̨Ӷ��,
�ɹ��ɱ�,
�����ɱ�,
AdExposure,
adclicks,
adspend,
adsales,
adorders,
������,
��滨����,
�˿���,
�˷�������,
Ӫ���ۿ���,
ƽ̨����֧����,
ƽ̨Ӷ����,
�ɹ��ɱ���,
�����ɱ���,
���ҵ��ռ��,
CTR,
CVR,
CPC,
salesmon,
salewee,
lists,
�ع�������,
salelist ����������,
ƽ�����������·�,
���ӿ����·�
from (select spu,min(AuditTime)AuditTime, DATE_FORMAT(min(AuditTime),'%Y-%m-01') developmon,(case when min(AuditTime)<'2023-01-01' then 10 else (TIMESTAMPDIFF(month,DATE_FORMAT(min(AuditTime),'%Y-%m-01'),'2023-12-11')+1) end) ��Ʒ�����·� from epp
-- where ele_name='����'
group by spu )a
left join spulist on spulist.spu=a.spu
left join ods1 on a.spu=ods1.spu
left join kandeng on kandeng.spu=a.spu
left join baoguang on baoguang.spu=a.spu
left join ods2 on a.spu=ods2.spu
)

-- select * from spuhuizong
-- order by profitnew asc
--
select ifnull(prodtype,'����') prodtype,ifnull(����,'����')���� ,round(sum(case when orders>0 then sales end),2) sales,round(sum(case when orders>0 then profitnew end),2) profitnew,count(distinct spu) spu����,count(case when lists>0 then spu end)����SPU��,sum(case when lists>0 then lists end)����������, count(case when orders>0 then spu end) ����SPU��,round(count(case when orders>0 then spu end) /count(distinct spu),6)spu������,round(avg(case when orders>0 then orders end),3) ����ƽ��������
,round(avg(case when orders>0 then ���� end),3) ����ƽ������
,sum(�ع�������)�ع�������
,sum(AdExposure)AdExposure
,sum(adclicks)adclicks
,round(sum(adspend),2)adspend
,round(sum(adsales),2)adsales
,round(sum(adorders),2)adorders
,round(sum(adsales)/sum(sales),4) ���ҵ��ռ��
,round(sum(adclicks)/sum(AdExposure),4) CTR
,round(sum(adorders)/sum(adclicks),4) CVR
,round(sum(adspend)/sum(adclicks),4) CPC
,round(sum(case when orders>0 then sales end)/sum(case when orders>0 then orders end),4)ƽ���͵���
,round(sum(case when orders>0 then sales end)/sum(case when orders>0 then ���� end),4)ƽ��������
,round(sum(case when orders>0 then profitnew end)/sum(case when orders>0 then sales end),6)ƽ��������
,round(avg(��Ʒ�����·�),4)��Ʒ���������
,round(sum(���ӿ����·�*lists)/sum(lists),4)�������������
,sum(����������)����������
,count(distinct case when �ع�������>0 then spu end) �ع�SPU��
,round( avg(case when orders>0 then salesmon end),4) ��Ʒ���������
,round( sum(case when orders>0 then ƽ�����������·�*���������� end),4) ������������
,round(sum(refund),2)refund
,round(sum(promotional),2)promotional
,round(sum(�˷�����),2) �˷�����
,round(sum(Ӫ���ۿ�),2) Ӫ���ۿ�
,round(sum(ƽ̨����֧��),2) ƽ̨����֧��
,round(sum(ƽ̨Ӷ��),2) ƽ̨Ӷ��
,round(sum(�ɹ��ɱ�),2) �ɹ��ɱ�
,round(sum(�����ɱ�),2) �����ɱ�
from spuhuizong
where prod='��Ʒ'
and  spu<>'5355698'
group by grouping sets((),(prodtype,����),(prodtype))
order by prodtype desc,���� asc


-- select * from wt_adserving_amazon_weekly where year='2023' order by week desc limit 10
