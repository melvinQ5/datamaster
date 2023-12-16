

--  ��ʥ��
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
with a as (
select
    round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
    ,round( sum( case when concat(vknp.sku,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_new_theme -- ��Ʒ �� ����
    ,round( sum( case when concat(level.spu,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_level_theme -- �����ֲ� �� ����
    ,round( sum( case when tag.spu is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_theme -- ����
    ,count(distinct case when tag.spu is not null then product_spu end ) as od_spu_theme -- ����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '��ʥ��'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '��|��' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '����'
)
,b as (
select
    abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
    ,abs(round(sum( case when  concat(vknp.sku,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_new_theme
    ,abs(round(sum( case when  concat(level.spu,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_level_theme
    ,abs(round(sum( case when tag.spu is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_theme
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=wo.shopcode and ms.department='��ٻ�'
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '��ʥ��'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '��|��' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where wo.IsDeleted = 0 and TransactionType = '�˿�' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)
,c as (select count(distinct wp.spu) spu_total_theme
    from wt_products wp
    join ( select eppaea.spu
        from import_data.erp_product_product_associated_element_attributes eppaea
        left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
        where eppea.name =  '��ʥ��'
        group by spu ) tag
    on wp.spu = tag.spu where wp.ProductStatus !=2 )

select '${StartDay}' as ���ڵ�һ�� ,'���⵱�����۶�_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,round(gross_include_refunds_theme - ifnull(refunds_theme,0),2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- ����������Ʒҵ�� �� ��������ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���⵱����Ʒҵ��ռ��_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round( ( gross_include_refunds_new_theme - ifnull(refunds_new_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- �������ⱬ����ҵ�� �� ��������ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���ⱬ�������۶�ռ��_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round( ( gross_include_refunds_level_theme - ifnull(refunds_level_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- ��������ҵ�� �� ���ܿ�ٻ���ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���⵱�����۶�ռ��_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round(  (gross_include_refunds_theme - ifnull(refunds_theme,0))  / (gross_include_refunds - ifnull(refunds,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all
select '${StartDay}' as ���ڵ�һ�� ,'���⵱�ܳ���SPU��_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,od_spu_theme ,0 ,0 ,'�ܱ�' type
from  a,b,c
union all
select '${StartDay}' as ���ڵ�һ�� ,'���⵱��SPU������_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,round( od_spu_theme / spu_total_theme ,4)  ,0 ,0 ,'�ܱ�' type
from  a,b,c;



-- ���⵱�ܹ��ͳ��
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'���⵱���ع���_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,sum(Exposure) Exposure  ,0 ,0 ,'�ܱ�' type
from wt_listing wl
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on wl.shopcode=ms.Code
join ( select eppaea.spu
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name =  '��ʥ��'
    group by spu ) tag on wl.spu = tag.spu
join AdServing_Amazon ad  on wl.ShopCode=ad.ShopCode and wl.SellerSKU=ad.SellerSKU and wl.ASIN = ad.Asin
where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day);


-- SPU��

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��_����_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
     ,0 ,0 ,'�ܱ�' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '��ʥ��'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��_����_��ʥ��' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
     ,0 ,0 ,'�ܱ�' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  '��ʥ��'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

-- -------------------------------------


--  ʥ����
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
with a as (
select
    round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
    ,round( sum( case when concat(vknp.sku,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_new_theme -- ��Ʒ �� ����
    ,round( sum( case when concat(level.spu,tag.spu) is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_level_theme -- �����ֲ� �� ����
    ,round( sum( case when tag.spu is not null then (TotalGross - RefundAmount )/ExchangeUSD end ),2) as gross_include_refunds_theme -- ����
    ,count(distinct case when tag.spu is not null then product_spu end ) as od_spu_theme -- ����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  'ʥ����'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '��|��' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '����'
)
,b as (
select
    abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
    ,abs(round(sum( case when  concat(vknp.sku,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_new_theme
    ,abs(round(sum( case when  concat(level.spu,tag.spu)  is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_level_theme
    ,abs(round(sum( case when tag.spu is not null then (RefundAmount)/ExchangeUSD end ),2)) refunds_theme
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=wo.shopcode and ms.department='��ٻ�'
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  'ʥ����'
	group by spu ) tag on wo.Product_SPU = tag.spu
left join ( select distinct spu from dep_kbh_product_level where prod_level regexp '��|��' and FirstDay >= '${StartDay}' and FirstDay < '${NextStartDay}' ) level on wo.Product_SPU = level.spu
left join view_kbp_new_products vknp on vknp.sku = wo.Product_Sku
where wo.IsDeleted = 0 and TransactionType = '�˿�' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)
,c as (select count(distinct wp.spu) spu_total_theme
    from wt_products wp
    join ( select eppaea.spu
        from import_data.erp_product_product_associated_element_attributes eppaea
        left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
        where eppea.name =  'ʥ����'
        group by spu ) tag
    on wp.spu = tag.spu where wp.ProductStatus !=2 )

select '${StartDay}' as ���ڵ�һ�� ,'���⵱�����۶�_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,round(gross_include_refunds_theme - ifnull(refunds_theme,0),2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- ����������Ʒҵ�� �� ��������ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���⵱����Ʒҵ��ռ��_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round( ( gross_include_refunds_new_theme - ifnull(refunds_new_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- �������ⱬ����ҵ�� �� ��������ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���ⱬ�������۶�ռ��_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round( ( gross_include_refunds_level_theme - ifnull(refunds_level_theme,0) )  / (gross_include_refunds_theme - ifnull(refunds_theme,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all -- ��������ҵ�� �� ���ܿ�ٻ���ҵ��
select '${StartDay}' as ���ڵ�һ�� ,'���⵱�����۶�ռ��_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,round(  (gross_include_refunds_theme - ifnull(refunds_theme,0))  / (gross_include_refunds - ifnull(refunds,0))  ,2) ָ��ֵ ,0 ,0 ,'�ܱ�' type
from a,b,c
union all
select '${StartDay}' as ���ڵ�һ�� ,'���⵱�ܳ���SPU��_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,od_spu_theme ,0 ,0 ,'�ܱ�' type
from  a,b,c
union all
select '${StartDay}' as ���ڵ�һ�� ,'���⵱��SPU������_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,round( od_spu_theme / spu_total_theme ,4)  ,0 ,0 ,'�ܱ�' type
from  a,b,c;



-- ���⵱�ܹ��ͳ��
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'���⵱���ع���_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���' ,sum(Exposure) Exposure  ,0 ,0 ,'�ܱ�' type
from wt_listing wl
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on wl.shopcode=ms.Code
join ( select eppaea.spu
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name =  'ʥ����'
    group by spu ) tag on wl.spu = tag.spu
join AdServing_Amazon ad  on wl.ShopCode=ad.ShopCode and wl.SellerSKU=ad.SellerSKU and wl.ASIN = ad.Asin
where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day);


-- SPU��

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��_����_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
     ,0 ,0 ,'�ܱ�' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  'ʥ����'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����SPU��_����_ʥ����' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
     ,0 ,0 ,'�ܱ�' type
from import_data.dep_kbh_product_level akpl
join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name =  'ʥ����'
	group by spu ) tag on akpl.spu = tag.spu
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}';