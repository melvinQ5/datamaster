-- ���ӿ��Ƿֲ㶨�壺
-- 1 ��Ǳ�¿��ǣ�������SPU����10��1��֮�����͵�Ǳ����Ҹ����ӵ����翯��ʱ�� �����ڵ��ڡ���SPU���״��Ƽ�ʱ��
-- 2 ��Ǳ�����ӣ�������SPU����10��1��֮�����͵�Ǳ����Ҹ����ӵ����翯��ʱ�� �����ڡ���SPU���״��Ƽ�ʱ��
-- 3 �Ǹ�Ǳ��Ʒ���ӣ�������SPU������10��1��֮�����͵�Ǳ����Ҹ�SPUΪ���¼�ǰ���������Ʒ
-- 4 �������ӣ���ͳ�������У���123������

alter view view_kbh_lst_pub_tag as
select shopcode ,SellerSKU  ,site ,boxsku ,sku ,spu, lst_pub_tag ,min( MinPublicationDate ) MinPublicationDate_bysellersku
from (
    select   shopcode ,SellerSKU ,asin ,site ,wl.boxsku ,wl.sku ,wl.spu ,MinPublicationDate
            ,case -- todo ����wt_listing���MinPublicationDate�ֶε�����Ҫ����£��Ƿ���������翯��ʱ��,����δɾ�����ӵ����翯��ʱ��
                when d.ispotenial = '��ǱƷ' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) >= 0 and SellerSku not regexp 'bJ|Bj|bj|BJ' then '��Ǳ�¿���'
                when d.ispotenial = '��ǱƷ' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) < 0  then '��Ǳ������'
                when d.ispotenial = '�Ǹ�ǱƷ' and d.isnew = '��Ʒ' and SellerSku not regexp 'bJ|Bj|bj|BJ' then '�Ǹ�Ǳ��Ʒ����'
                else '��������' -- ������Ӿ��㵽����������
            end lst_pub_tag
    from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '��ٻ�'
    left join dep_kbh_product_test d on wl.sku = d.sku
    ) t
group by  shopcode ,SellerSKU  ,site ,boxsku ,sku ,spu, lst_pub_tag;

-- �ѿ���ɾ�����ӣ��ҵ����ж�Ӧ��ϵ
create view view_kbh_lst_pub_tag_by_asinsite as
select asin ,site ,boxsku ,sku ,spu, lst_pub_tag ,min( MinPublicationDate ) MinPublicationDate_bysellersku
from (
    select   shopcode ,SellerSKU ,asin ,site ,wl.boxsku ,wl.sku ,wl.spu ,MinPublicationDate
            ,case -- todo ����wt_listing���MinPublicationDate�ֶε�����Ҫ����£��Ƿ���������翯��ʱ��,����δɾ�����ӵ����翯��ʱ��
                when d.ispotenial = '��ǱƷ' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) >= 0 and SellerSku not regexp 'bJ|Bj|bj|BJ' then '��Ǳ�¿���'
                when d.ispotenial = '��ǱƷ' and timestampdiff(SECOND,min_pushdate,MinPublicationDate) < 0  then '��Ǳ������'
                when d.ispotenial = '�Ǹ�ǱƷ' and d.isnew = '��Ʒ' and SellerSku not regexp 'bJ|Bj|bj|BJ' then '�Ǹ�Ǳ��Ʒ����'
                else '��������' -- ������Ӿ��㵽����������
            end lst_pub_tag
    from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '��ٻ�'
    left join dep_kbh_product_test d on wl.sku = d.sku
    ) t
group by  asin ,site,boxsku ,sku ,spu, lst_pub_tag;

