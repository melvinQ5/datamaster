
-- ������1 ͳ�ƽ�14����֣� start_stat_days=14 end_stat_days=7
-- ������2 ͳ�ƽ�30����֣� start_stat_days=30 end_stat_days=7



with topsku as (
select pp.spu ,pp.sku ,pp.productname ,pp.boxsku ,mt.prod_level as push_type
from erp_product_products pp
join dep_kbh_product_level mt on pp.spu= mt.spu
where FirstDay = date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval - 1 week ) and Department='��ٻ�'
-- where MarkDate = '${NextStartDay}' and Department='��ٻ�'  -- ����д��,��Ϊÿ��һ�������ܱ��±��������ݣ���markdate������һ
and IsMatrix=0 and pp.IsDeleted=0 and mt.isdeleted=0
)

,listtype as ( -- 0710��ʼ�й����ӱ�ǣ�д�����±�ǩ
 select distinct asin , site ,list_level as listtype ,old_list_level as OldListLevel from dep_kbh_listing_level
where isdeleted=0 and  FirstDay = ( select max(firstday) from dep_kbh_listing_level where isdeleted=0 )
)

,listype_history as (
select asin ,site ,group_concat(list_level) list_level
from dep_kbh_listing_level where isdeleted=0 and  Department regexp '${team}' and list_level regexp 'S|A'  group by  asin ,site
)

,torttype as (
select pp.sku,pp.boxsku,date(min(pt.CreationTime))`tortdate`,GROUP_CONCAT(
case torttype
when 1 then '��Ȩ��Ȩ'
when 2 then '�̱���Ȩ'
when 3 then 'ר����Ȩ'
when 4 then 'Υ��Ʒ'
when 5 then '����Ȩ'
when 6 then '������Ȩ'
end) torttype_name
FROM import_data.erp_product_product_tort_types pt
join import_data.erp_product_products pp on pp.id=pt.ProductId
where pp.sku is not null and pp.ismatrix=0 and  pp.IsDeleted=0
group by pp.sku,pp.boxsku
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products epp on eppaea.sku = epp.sku
where epp.ProjectTeam ='��ٻ�' and epp.IsMatrix=0 and epp.IsDeleted=0
group by eppaea.sku
)

,epp as ( -- sku
select a.SKU ,a.SPU ,date(a.DevelopLastAuditTime)AuditTime,a.productname,ele_name,torttype_name,
case productstatus
when 0 then '����'
when 2 then 'ͣ��'
when 3 then 'ͣ��'
when 4 then '��ʱȱ��'
when 5 then '���'
end productstatus
from import_data.erp_product_products a
left join torttype b on a.sku=b.sku
left join t_elem c on c.sku=a.sku
where IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='��ٻ�'
group by a.SKU ,a.SPU ,a.DevelopLastAuditTime,a.productname,ele_name,torttype_name,productstatus
)

,t_list as ( -- ���¿����������� ����������Ʒ��
select wl.id,wl.SPU ,wl.SKU  ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin,price
	,AccountCode  ,ms.Site
	,ms.SellUserName  ,ms.NodePathName
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where wl.IsDeleted = 0
	and ms.Department = '��ٻ�'
	and ms.NodePathName regexp '${team}'
	and wl.ListingStatus =1 and ms.shopstatus = '����' and sku<>''
)

,addetail as ( -- 14��30����
select al.markettype,al.shopcode,al.sellersku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales  from AdServing_Amazon ads
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL  -1 day))
group by  al.markettype,al.shopcode,al.sellersku
)

, t_od as ( -- 14��30�충��
select wo.shopcode,wo.sellersku,round(sum((totalgross-feegross)/ExchangeUSD),2) sales,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount/ExchangeUSD),2)refund,count(distinct date(PayTime))solddays
from wt_orderdetails wo
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�'
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1  day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -1 day))   and asin<>''
group by  wo.shopcode,wo.sellersku
)

,onlinead as (
select distinct tb.ListingId ,b.code shopcode,sku sellersku
from import_data.erp_amazon_amazon_ad_products tb
join erp_user_user_platform_account_sites b on b.id=tb.shopid
-- where sku = 'QK-NBFR-1014-JW-100' and code = 'NB-FR'
)

, lastt_od as ( -- ������  asin+sitem��ϸ
select wo.shopcode,wo.sellersku,round(sum((totalgross-feegross)/ExchangeUSD),2) lastsales,round(sum((totalprofit-feegross)/ExchangeUSD),2) lastprofit,count(distinct platordernumber) lastorders,round(sum(feegross/ExchangeUSD),2) lastfreightfee,round(sum(-RefundAmount/ExchangeUSD),2)lastrefund,count(distinct date(PayTime))lastsolddays
from wt_orderdetails wo
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='��ٻ�'
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL  -'${start_stat_days}'-7-1 day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -7-1 day))   and asin<>''
group by  wo.shopcode,wo.sellersku
)

,lastaddetail as (
select al.markettype,al.shopcode,al.sellersku,sum(exposure)lastexposure,sum(clicks)lastclicks,sum(spend) lastspend,sum(AdSkuSaleCount7Day) lastadorders,sum(AdSkuSale7Day) lastadsales  from AdServing_Amazon ads
left join import_data.wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-7-1  day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL -7-1 day))
group by  al.markettype,al.shopcode,al.sellersku
)

,prod_1 as ( -- ����
select  distinct spu ,prod_level as mark_1 from dep_kbh_product_level
where isdeleted=0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,prod_2 as (  -- w-1��
select  distinct spu ,prod_level as mark_2 from dep_kbh_product_level
where isdeleted=0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,prod_3 as ( -- w-2��
select  distinct spu ,prod_level as mark_3 from dep_kbh_product_level
where isdeleted=0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)



,res as (
select
    concat('�������ӽ�','${start_stat_days}','�����') type
     ,date('${NextStartDay}')`����ˢ������`
     ,listtype ���ӷֲ�
     ,OldListLevel ǰ3�����ӱ�ǩ
     ,topsku.push_type ��Ʒ�ֲ�
     ,concat(ifnull(mark_1,'��'),'-',ifnull(mark_2,'��'),'-',ifnull(mark_3,'��'))  ǰ������Ʒ�ֲ�
     ,a.SPU ,a.SKU ,a.BoxSku
     ,f.AuditTime ��������
     ,f.productname ��Ʒ����
     ,f.ele_name Ԫ��
     ,f.torttype_name ��Ȩ����
     ,f.productstatus ��Ʒ״̬
     ,date(MinPublicationDate) �״ο���ʱ��
     ,a.MarketType վ��
     ,a.SellerSKU
     ,a.ShopCode
     ,a.asin
     ,price
     ,AccountCode
     ,SellUserName ��ѡҵ��Ա
     ,NodePathName ������
     ,case when d.sellersku is not null then '�������'
        else '��δƥ�䵽�������'
    end as ���״̬
     ,round(sales+freightfee,2) ���۶�
     ,round(profit+freightfee,2) �����
     ,round(profit/sales,4) �ҵ�������_�����˷�
     ,orders ������
     ,freightfee �˷�����
     ,refund �˿���
     ,round((profit-ifnull(spend,0)+freightfee),2) �۹�������
     ,round((profit-ifnull(spend,0)+freightfee) /(sales+freightfee),4) �۹��������
     ,solddays ��������
     ,exposure �ع���
     ,clicks �����
     ,spend ��滨��
     ,adorders �������
     ,adsales ����Ʒ���۶�
     ,round(clicks/exposure,4) ctr
     ,round(adorders/clicks,4) cvr
     ,round(spend/clicks,4) cpc
     ,round(SPEND/adsales,4) acost
     ,round(adsales/spend,2) ROI
     -- ,round(adsales*profit/sales-spend,2) adprofit
        ,round(lastfreightfee+lastsales,2) ���۶�_����
     ,round(lastfreightfee+lastprofit,2) �����_����
     ,lastorders ������_����
     ,lastfreightfee �˷�����_����
     ,lastexposure �ع���_����
     ,lastclicks �����_����
     ,lastspend ��滨��_����
     ,lastadorders �������_����
     ,lastadsales ����Ʒ���۶�_����
     ,lastsolddays ��������_����
    ,case when listype_history.asin is not null then '��' else '' end as �Ƿ���������ǹ�SA

from t_list a -- ��������
join topsku on topsku.sku=a.sku -- ɸѡ������Ʒ�ֲ�Ĳ�Ʒ
left join listtype on listtype.asin=a.asin and listtype.site=a.site
left join listype_history on listype_history.asin=a.asin and listype_history.site=a.site
left join t_od b on b.shopcode=a.shopcode and b.sellersku=a.sellersku
left join addetail c on c.shopcode=a.shopcode and c.sellersku= a.sellersku
left join onlinead d on a.shopcode =d.shopcode and a.sellersku=d.sellersku
left join epp f on f.sku=a.sku
left join lastt_od g on g.shopcode=a.shopcode and g.sellersku=a.sellersku
left join lastaddetail i on i.shopcode=a.shopcode and i.sellersku= a.sellersku
left join prod_1 on a.spu = prod_1.spu
left join prod_2 on a.spu = prod_2.spu
left join prod_3 on a.spu = prod_3.spu
where  NodePathName regexp '${team}'
order by sales desc
)

select * from res

