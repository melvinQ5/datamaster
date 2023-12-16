/*
 * ��Ʒ�����ֶ���ת��
 */
with t as (
select * from import_data.JinqinSku js where Monday = '2023-02-17'
)

, t_unnest as (
select sku 
	,case when Festival regexp 'ĸ�׽�|����|¶Ӫ|����|�߶���|԰��|ʥ����|�ж���|��ʥ��|���籭|��ѧ��|����������|������|���׽�|��ͯ��|��ҵ��|2022�꿪ի��|Ү��������|�����|ʥ������˽�|��ɫ���˽�|��˹�ֽ�|���˽�|�����ɶ�|����|��ի��|Ľ���ơ�ƽ�|������|�۷��|�񻶽ڣ�us��|����˹�񻶽�|�Ա��ʾ' 
	then Festival else null end as split -- ɸѡ����Ԫ�صļ���
	,spu ,Festival,ProjectTeam ,BoxSku ,CategoryPathByChineseName  ,ProductName 
,Festival 
from import_data.wt_products 
where  Festival is not null and IsDeleted = 0 
)

, od as ( 
select wo.boxsku , round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) `���۶�`  
from wt_orderdetails wo 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' and Department = '��ٻ�'
group by wo.BoxSku 
)

select t_unnest.* , od.`���۶�` 
from t_unnest 
left join od on t_unnest.boxsku = od.boxsku
where split is not null 

-- select sku ,spu ,Festival,ProjectTeam ,BoxSku ,CategoryPathByChineseName  ,ProductName 
-- from import_data.wt_products
-- where Festival is not null and IsDeleted = 0 

