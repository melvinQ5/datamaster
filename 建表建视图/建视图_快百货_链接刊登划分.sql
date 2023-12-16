-- 链接刊登分层定义：
-- 1 高潜新刊登：该链接SPU属于10月1日之后推送的潜力款，且该链接的最早刊登时间 “晚于等于”该SPU的首次推荐时间
-- 2 高潜老链接：该链接SPU属于10月1日之后推送的潜力款，且该链接的最早刊登时间 “早于”该SPU的首次推荐时间
-- 3 非高潜新品链接：该链接SPU不属于10月1日之后推送的潜力款，且该SPU为当月及前两月终审产品
-- 4 其他链接：总统计链接中，非123类链接

alter view view_kbh_lst_pub_tag as
select shopcode ,SellerSKU  ,site ,boxsku ,sku ,spu, lst_pub_tag ,min( MinPublicationDate ) MinPublicationDate_bysellersku
from (
    select   shopcode ,SellerSKU ,asin ,site ,wl.boxsku ,wl.sku ,wl.spu ,MinPublicationDate
            ,case -- todo 这里wt_listing表的MinPublicationDate字段调度需要检查下，是否整表的最早刊登时间,而非未删除链接的最早刊登时间
                when d.ispotenial = '高潜品' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) >= 0 and SellerSku not regexp 'bJ|Bj|bj|BJ' then '高潜新刊登'
                when d.ispotenial = '高潜品' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) < 0  then '高潜老链接'
                when d.ispotenial = '非高潜品' and d.isnew = '新品' and SellerSku not regexp 'bJ|Bj|bj|BJ' then '非高潜新品链接'
                else '其他链接' -- 搬家链接均算到其他链接中
            end lst_pub_tag
    from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
    left join dep_kbh_product_test d on wl.sku = d.sku
    ) t
group by  shopcode ,SellerSKU  ,site ,boxsku ,sku ,spu, lst_pub_tag;

-- 已考虑删除链接，找到所有对应关系
create view view_kbh_lst_pub_tag_by_asinsite as
select asin ,site ,boxsku ,sku ,spu, lst_pub_tag ,min( MinPublicationDate ) MinPublicationDate_bysellersku
from (
    select   shopcode ,SellerSKU ,asin ,site ,wl.boxsku ,wl.sku ,wl.spu ,MinPublicationDate
            ,case -- todo 这里wt_listing表的MinPublicationDate字段调度需要检查下，是否整表的最早刊登时间,而非未删除链接的最早刊登时间
                when d.ispotenial = '高潜品' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) >= 0 and SellerSku not regexp 'bJ|Bj|bj|BJ' then '高潜新刊登'
                when d.ispotenial = '高潜品' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) < 0  then '高潜老链接'
                when d.ispotenial = '非高潜品' and d.isnew = '新品' and SellerSku not regexp 'bJ|Bj|bj|BJ' then '非高潜新品链接'
                else '其他链接' -- 搬家链接均算到其他链接中
            end lst_pub_tag
    from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
    left join dep_kbh_product_test d on wl.sku = d.sku
    ) t
group by  asin ,site,boxsku ,sku ,spu, lst_pub_tag;

