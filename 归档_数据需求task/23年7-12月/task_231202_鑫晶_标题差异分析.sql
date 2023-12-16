with
ta as (
select [
'5308167.01',
'5309514.01',
'5319293.02',
'5309537.01',
'5309593.01',
'5322519.01',
'5313285.01',
'5317998.01',
'5323233.01',
'5331227.01',
'5328913.01',
'5312426.02',
'5321459.01',
'5319391.02',
'5323305.02',
'5306564.01',
'5321467.01',
'5328965.01',
'5319344.01',
'5310360.01'
] arr
)

,tb as (
select *
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)

,prod as (
select id, spu ,sku ,boxsku,ProductName,DevelopUserName,Editor,Artist,DevelopLastAuditTime
from wt_products wp
join tb on wp.sku = tb.arr
where  ProjectTeam='��ٻ�' )

,word_pp as (
select epp.spu ,epp.sku ,epp.BoxSKU ,epp.ProductName ,epp.DevelopUserName ,eppcw.KeyWords,DevelopLastAuditTime,Editor,Artist
,trim(split(KeyWords,',')[1]) as KeyWords1
,trim(split(KeyWords,',')[2]) as KeyWords2
,trim(split(KeyWords,',')[3]) as KeyWords3
,trim(split(KeyWords,',')[4]) as KeyWords4
,trim(split(KeyWords,',')[5]) as KeyWords5
,lower(substring( replace(ProductTitle,'"',''),2,length(replace(ProductTitle,'"',''))-2)) ProductTitle
from erp_product_product_copy_writings eppcw
join prod epp on epp.id = eppcw.ProductId and LanguageChineseName ='Ӣ��' )

,od as ( -- boxsku ��'US|UK|CA'����������һ������
select * from (
    select * ,row_number() over (partition by boxsku,site order by sales desc ) sort
    from (
    select BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName ,round(sum(totalgross/ExchangeUSD),2) sales
    from import_data.wt_orderdetails wo
    join import_data.mysql_store ms on wo.shopcode=ms.Code
        and ms.Department = '��ٻ�' and ms.site regexp 'US|UK' and PayTime >= '2023-09-01' and PayTime < '2023-11-01' and IsDeleted=0 and TransactionType='����'
    group by BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName
    ) t1
) t2
where sort = 1 )

,t0 as (
select t.* ,od.asin ,shopcode ,sellersku ,SellUserName ,sales
from
( select * from prod,(select 'US' as site ) t1
union all select * from prod,(select 'UK' as site ) t2 ) t
left join od on t.boxsku = od.boxsku and t.site = od.site )

,word_lst as (
select od.boxsku ,od.asin as ���۶�top1Asin ,site ,SellUserName ,case when ec.GenericKeywords regexp ',' then '�ж��ŷָ����ɷָ�' end �Ƿ�ɷִ� ,ec.GenericKeywords
,trim(split(GenericKeywords,',')[1]) as GenericKeywords1
,trim(split(GenericKeywords,',')[2]) as GenericKeywords2
,trim(split(GenericKeywords,',')[3]) as GenericKeywords3
,trim(split(GenericKeywords,',')[4]) as GenericKeywords4
,trim(split(GenericKeywords,',')[5]) as GenericKeywords5
,lower(eaal.Name) lsttitle
from od
join wt_listing wl on od.shopcode=wl.ShopCode and od.SellerSku=wl.SellerSKU and od.asin = wl.asin and wl.IsDeleted=0 and MarketType regexp 'US|UK'
join erp_amazon_amazon_listing_copywritings ec on wl.id =ec.id
left join erp_amazon_amazon_listing eaal on wl.id = eaal.id
)

,ad as (
select prod.sku, waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits ,waad.AdSpend ,waad.AdSales
	, timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 as ad_days -- ���
    ,right(shopcode,2) AS site
from prod
join import_data.wt_adserving_amazon_daily waad on waad.sku = prod.sku
and waad.GenerateDate >= '2023-09-01' and waad.GenerateDate < '2023-11-01' and right(shopcode,2) regexp 'US|UK'  )


,ad_stat as (
select   sku ,site
-- �ع���
, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_Exposure
-- �����
, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_Clicks
-- ����
, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_saleunits
-- ����
, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSpend end) ,2 ) as ad60_spend
from ad  group by  sku ,site
)

,merge as (
select t0.spu ,t0.sku ,t0.boxsku  ,t0.site ,t0.ProductName ,t0.Editor �༭
,KeyWords ��Ʒ�ؼ�����
,GenericKeywords ���ӹؼ�����
,ProductTitle ��Ʒ����
,lsttitle ���ӱ���
,���۶�top1Asin ,t0.SellUserName
,sales ���۶�S2
,ad14_Exposure ����14���ع���
,ad14_Clicks ����14������
,round(ad14_saleunits / ad14_Clicks ,4)  ����14����ת����
,ad60_spend ����60���滨��
from t0
left join word_pp t1 on t1.BoxSku= t0.BoxSku
left join word_lst t2 on t0.BoxSku= t2.BoxSku and  t0.site =t2.site
left join ad_stat t3 on t0.sku= t3.sku and  t0.site =t3.site )


select * from merge order by boxsku ,site