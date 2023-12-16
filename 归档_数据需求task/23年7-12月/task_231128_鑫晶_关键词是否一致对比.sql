-- ������
-- �ؼ��� ��Ҫ�ж�һ�£��༭д�Ĺؼ��ʺ�ʵ�����۲��õĹؼ����Ƿ�һ�£����ȿ�TOP1�������ӵĹؼ���һ����
-- ���� ��������ñ༭�Ա������۵ı��������д�ı���Ĳ����
with
prod as ( select id, spu ,sku ,boxsku,ProductName,DevelopUserName,Editor,Artist,DevelopLastAuditTime
from wt_products where DevelopLastAuditTime >='2023-09-01' and DevelopLastAuditTime < '2023-10-01' and ProjectTeam='��ٻ�')

,word_pp as (
select epp.spu ,epp.sku ,epp.BoxSKU ,epp.ProductName ,epp.DevelopUserName ,eppcw.KeyWords,DevelopLastAuditTime,Editor,Artist
,trim(split(KeyWords,',')[1]) as KeyWords1
,trim(split(KeyWords,',')[2]) as KeyWords2
,trim(split(KeyWords,',')[3]) as KeyWords3
,trim(split(KeyWords,',')[4]) as KeyWords4
,trim(split(KeyWords,',')[5]) as KeyWords5
,lower(substring( replace(ProductTitle,'"',''),2,length(replace(ProductTitle,'"',''))-2)) ProductTitle
from erp_product_product_copy_writings eppcw
join prod epp on epp.id = eppcw.ProductId and LanguageChineseName ='Ӣ��')

,od as ( -- boxsku ��'US|UK|CA'����������һ������
select * from (
select * ,row_number() over (partition by boxsku order by salecount desc ) sort from (
select BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName ,sum(SaleCount) SaleCount
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
    and ms.Department = '��ٻ�' and ms.site regexp 'US|UK|CA' and PayTime >= '2023-09-01' and PayTime < '2023-11-01' and IsDeleted=0 and TransactionType='����'
group by BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName ) t1 ) t2
where sort = 1 )

,word_lst as (
select od.boxsku ,od.asin as ����top1Asin ,site ,SellUserName ,case when ec.GenericKeywords regexp ',' then '�ж��ŷָ����ɷָ�' end �Ƿ�ɷִ� ,ec.GenericKeywords
,trim(split(GenericKeywords,',')[1]) as GenericKeywords1
,trim(split(GenericKeywords,',')[2]) as GenericKeywords2
,trim(split(GenericKeywords,',')[3]) as GenericKeywords3
,trim(split(GenericKeywords,',')[4]) as GenericKeywords4
,trim(split(GenericKeywords,',')[5]) as GenericKeywords5
,lower(eaal.Name) lsttitle
from od
join wt_listing wl on od.shopcode=wl.ShopCode and od.SellerSku=wl.SellerSKU and od.asin = wl.asin and wl.IsDeleted=0 and MarketType regexp 'US|UK|CA'
join erp_amazon_amazon_listing_copywritings ec on wl.id =ec.id
left join erp_amazon_amazon_listing eaal on wl.id = eaal.id
)

,merge as (
select spu ,sku ,t1.BoxSku ,ProductName ,DevelopUserName ������Ա ,date(DevelopLastAuditTime) �������� ,Editor �༭,Artist ����
,KeyWords ��Ʒ�ؼ�����
,lower(KeyWords1) ��Ʒ�ؼ���1
,lower(KeyWords2) ��Ʒ�ؼ���2
,lower(KeyWords3) ��Ʒ�ؼ���3
,lower(KeyWords4) ��Ʒ�ؼ���4
,lower(KeyWords5) ��Ʒ�ؼ���5
,����top1Asin ,site ,SellUserName ��ѡҵ��Ա  ,�Ƿ�ɷִ� as ���ӹؼ����Ƿ�ɷִ�,GenericKeywords ���ӹؼ�����
,lower(GenericKeywords1) ���ӹؼ���1
,lower(GenericKeywords2) ���ӹؼ���2
,lower(GenericKeywords3) ���ӹؼ���3
,lower(GenericKeywords4) ���ӹؼ���4
,lower(GenericKeywords5) ���ӹؼ���5
,ProductTitle ��Ʒ����
,lsttitle ���ӱ���
from word_pp t1
left join word_lst t2 on t1.BoxSku= t2.BoxSku )

,word_pp_explode as (
select boxsku ,lower(KeyWords1) as word from word_pp
union all select boxsku ,lower(KeyWords2) from word_pp
union all select boxsku ,lower(KeyWords3) from word_pp
union all select boxsku ,lower(KeyWords4) from word_pp
union all select boxsku ,lower(KeyWords5) from word_pp
order by BoxSku )

,word_lst_explode as (
select boxsku ,lower(GenericKeywords1)  as word  from word_lst where �Ƿ�ɷִ� = '�ж��ŷָ����ɷָ�'
union all select boxsku ,lower(GenericKeywords2) from word_lst where �Ƿ�ɷִ� = '�ж��ŷָ����ɷָ�'
union all select boxsku ,lower(GenericKeywords3) from word_lst where �Ƿ�ɷִ� = '�ж��ŷָ����ɷָ�'
union all select boxsku ,lower(GenericKeywords4) from word_lst where �Ƿ�ɷִ� = '�ж��ŷָ����ɷָ�'
union all select boxsku ,lower(GenericKeywords5) from word_lst where �Ƿ�ɷִ� = '�ж��ŷָ����ɷָ�'
order by BoxSku )

,word_is_same as (
select t1.BoxSku ,count(t2.BoxSku) �༭�ؼ��ʲ�����
from word_pp_explode t1
left join word_lst_explode t2 on t1.BoxSku=t2.BoxSku and t1.word = t2.word
group by t1.BoxSku  )


select t1.* ,�༭�ؼ��ʲ����� ,case when �༭�ؼ��ʲ����� >=4 then '����4����ͬ' end �ؼ���һ�����ж�
,case when ��Ʒ���� = ���ӱ��� then '�����ַ�����ȫһ��' end ����һ���ж�
from merge t1 left join word_is_same t2 on t1.BoxSku=t2.BoxSku;