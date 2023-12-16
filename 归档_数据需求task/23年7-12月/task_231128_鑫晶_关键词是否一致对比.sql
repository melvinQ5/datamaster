-- 背景：
-- 关键词 想要判断一下，编辑写的关键词和实际销售采用的关键词是否一致，优先看TOP1销售链接的关键词一致性
-- 标题 更多的是让编辑对比下销售的标题和他们写的标题的差异点
with
prod as ( select id, spu ,sku ,boxsku,ProductName,DevelopUserName,Editor,Artist,DevelopLastAuditTime
from wt_products where DevelopLastAuditTime >='2023-09-01' and DevelopLastAuditTime < '2023-10-01' and ProjectTeam='快百货')

,word_pp as (
select epp.spu ,epp.sku ,epp.BoxSKU ,epp.ProductName ,epp.DevelopUserName ,eppcw.KeyWords,DevelopLastAuditTime,Editor,Artist
,trim(split(KeyWords,',')[1]) as KeyWords1
,trim(split(KeyWords,',')[2]) as KeyWords2
,trim(split(KeyWords,',')[3]) as KeyWords3
,trim(split(KeyWords,',')[4]) as KeyWords4
,trim(split(KeyWords,',')[5]) as KeyWords5
,lower(substring( replace(ProductTitle,'"',''),2,length(replace(ProductTitle,'"',''))-2)) ProductTitle
from erp_product_product_copy_writings eppcw
join prod epp on epp.id = eppcw.ProductId and LanguageChineseName ='英语')

,od as ( -- boxsku 在'US|UK|CA'中销售最大的一条链接
select * from (
select * ,row_number() over (partition by boxsku order by salecount desc ) sort from (
select BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName ,sum(SaleCount) SaleCount
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
    and ms.Department = '快百货' and ms.site regexp 'US|UK|CA' and PayTime >= '2023-09-01' and PayTime < '2023-11-01' and IsDeleted=0 and TransactionType='付款'
group by BoxSku ,asin ,shopcode,SellerSku ,ms.site ,SellUserName ) t1 ) t2
where sort = 1 )

,word_lst as (
select od.boxsku ,od.asin as 销量top1Asin ,site ,SellUserName ,case when ec.GenericKeywords regexp ',' then '有逗号分隔，可分割' end 是否可分词 ,ec.GenericKeywords
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
select spu ,sku ,t1.BoxSku ,ProductName ,DevelopUserName 开发人员 ,date(DevelopLastAuditTime) 终审日期 ,Editor 编辑,Artist 美工
,KeyWords 产品关键词组
,lower(KeyWords1) 产品关键词1
,lower(KeyWords2) 产品关键词2
,lower(KeyWords3) 产品关键词3
,lower(KeyWords4) 产品关键词4
,lower(KeyWords5) 产品关键词5
,销量top1Asin ,site ,SellUserName 首选业务员  ,是否可分词 as 链接关键词是否可分词,GenericKeywords 链接关键词组
,lower(GenericKeywords1) 链接关键词1
,lower(GenericKeywords2) 链接关键词2
,lower(GenericKeywords3) 链接关键词3
,lower(GenericKeywords4) 链接关键词4
,lower(GenericKeywords5) 链接关键词5
,ProductTitle 产品标题
,lsttitle 链接标题
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
select boxsku ,lower(GenericKeywords1)  as word  from word_lst where 是否可分词 = '有逗号分隔，可分割'
union all select boxsku ,lower(GenericKeywords2) from word_lst where 是否可分词 = '有逗号分隔，可分割'
union all select boxsku ,lower(GenericKeywords3) from word_lst where 是否可分词 = '有逗号分隔，可分割'
union all select boxsku ,lower(GenericKeywords4) from word_lst where 是否可分词 = '有逗号分隔，可分割'
union all select boxsku ,lower(GenericKeywords5) from word_lst where 是否可分词 = '有逗号分隔，可分割'
order by BoxSku )

,word_is_same as (
select t1.BoxSku ,count(t2.BoxSku) 编辑关键词采用数
from word_pp_explode t1
left join word_lst_explode t2 on t1.BoxSku=t2.BoxSku and t1.word = t2.word
group by t1.BoxSku  )


select t1.* ,编辑关键词采用数 ,case when 编辑关键词采用数 >=4 then '至少4个相同' end 关键词一致性判断
,case when 产品标题 = 链接标题 then '标题字符串完全一致' end 标题一致判断
from merge t1 left join word_is_same t2 on t1.BoxSku=t2.BoxSku;