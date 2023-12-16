-- ������
select distinct  shopcode ,Department from wt_orderdetails where IsDeleted = 0
-- ���̱�
select distinct Code,Department from mysql_store


-- ����+����SKUά�� ��������
select a.Week ,��_����_����SKU�� ,��_����_����SKU�� ,��_����_����SKU�� - ��_����_����SKU�� as ����������
    ,��_��滨�� ,��_��滨�� ,round(��_��滨��  - ��_��滨��) as ���Ѳ�
    ,��_�ع� ,��_�ع� ,round(��_�ع�  - ��_�ع�) as �ع��

from  (
select week
     ,count(distinct concat(ShopCode,SellerSku))  ��_����_����SKU��
     ,round(sum(AdSpend),2) ��_��滨��
     ,round(sum(AdExposure),2) ��_�ع�
     ,round(sum(AdClicks),2) ��_���
from wt_adserving_amazon_weekly where year = 2023 and week >= 24 group by week order by week
) a
left join (
select weekofyear(GenerateDate) as week
     ,count(distinct concat(ShopCode,SellerSku))  ��_����_����SKU��
    ,round(sum(AdSpend),2) ��_��滨��
    ,round(sum(AdExposure),2) ��_�ع�
    ,round(sum(AdClicks),2) ��_���
from wt_adserving_amazon_daily wa
where GenerateDate >= '2023-06-26' group by week order by week
) b
on a.Week = b.week
order by a.Week
