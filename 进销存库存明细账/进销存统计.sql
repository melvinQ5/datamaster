
-- ���ڿ������߼������ڿ����+���ڹ�����-����������=���ڿ����

with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���' )

,ori_stat as ( -- ��ʼ������
select
    c1 as boxsku ,c2 as ������Ʒ����
    , case when c2 regexp '-1' then '����û�' else '��˼�Բ�' end ������Դ
    ,if(length(c21)=0,0,c21) - if(length(c20)=0,0,c20) - if(length(c19)=0,0,c19)- if(length(c18)=0,0,c18)- if(length(c17)=0,0,c17)  as  ���ڽ�����
    ,c5 ���ڲɹ���; 
    ,c6 ���ڿ��_��ݸ���� ,c7 ���ڿ��_��Ʒ�� ,c8 ���ڿ��_��ݸ�� 
    ,c9 ������;_�Ȳ� ,c10 ������;_������ ,c11 ������;_�ʲ�С�� ,c12 ������;_FBA 
    ,c13 ������_�Ȳ� ,c14 ������_������ ,c15 ������_�ʲ�С�� ,c16 ������_FBA 
	,c17 ������_�Ȳ� ,c18 ������_������ ,c19 ������_FBA ,c20 ������_��ݸ��
	,c21 ȫ��������
from manual_table where handlename in ( 'ȫ���̿��-5��','ȫ���̿��' ) and handletime = '2023-06-27'  
and c1 != 'boxsku' and c3 != '����̭'
order by memo
) 
-- select * from ori_stat ;

-- select * 
-- from manual_table where handlename in ( 'ȫ���̿��-5��','ȫ���̿��' ) and handletime = '2023-06-27' and c1 regexp '817' 

, od_stat as ( -- ���۳���
-- �жϹȲֵ�����û����޿�棬�����ȼ���
select boxsku 
	,case 
		when boxsku = 4346663 then  '��˼�Բ�'  -- -1����Բ��Ѿ���̭
		when from_place_detail regexp '�Ȳ�' and from_place_detail not regexp '��˼' then '����û�' else '��˼�Բ�' 
	end  as ������Դ
    ,ifnull( sum( case when from_place = '�Ȳ�' then start_quantity end ) ,0) ������_�Ȳ�
    ,ifnull( sum( case when from_place = '������' then start_quantity end ) ,0) ������_������
    ,ifnull( sum( case when from_place = 'FBA' then start_quantity end ) ,0) ������_FBA
    ,ifnull( sum( case when from_place = '��ݸ��' then start_quantity end ) ,0) ������_��ݸ��
    ,ifnull( sum(  start_quantity  ) ,0) ������_�ϼ�
from dep_purchase_sales_inventory_log
where event_type = '���۳���' and start_time >= '${StartDay}' and start_time < '${NextStartDay}' 
group by boxsku ,������Դ  
)
-- select * from od_stat where  boxsku = 4346663

, purc_stat as (
select BoxSku ,'��˼�Բ�' as ������Դ
 ,ifnull ( sum( case when start_time >= '${StartDay}' and start_time < '${NextStartDay}' then start_quantity end ) ,0 ) ���ڲɹ���
 ,ifnull ( sum( start_quantity - case when ifnull(end_time,'2999-12-31') >= '${NextStartDay}' then 0 else end_quantity end) ,0)  �ɹ���;��
from dep_purchase_sales_inventory_log where event_type = '�ɹ����' 
group by BoxSku
)
-- select * from purc_stat

, hd_stat as ( -- ͷ�̷���
select BoxSku ,purchase_source 
    ,ifnull( sum( case when reach_place = '�Ȳ�' then start_quantity - end_quantity  end ) ,0) ������;_�Ȳ�
    ,ifnull( sum( case when reach_place = '�ʲ�С��' then start_quantity - ifnull(end_quantity,0)  end ) ,0) ������;_�ʲ�С��
    ,ifnull( sum( case when reach_place = 'FBA' then start_quantity - end_quantity  end ) ,0) ������;_FBA
    ,ifnull( sum( case when reach_place = '������' then start_quantity - end_quantity  end ) ,0) ������;_������
from dep_purchase_sales_inventory_log where event_type = 'ͷ�̷���' and start_time >= '${StartDay}' and  start_time <  '${NextStartDay}'
group by BoxSku ,purchase_source
)
-- select * from hd_stat where  boxsku = 3547351

-- select * 
-- from dep_purchase_sales_inventory_log where event_type = 'ͷ�̷���'  and boxsku = 3547351
-- and start_time >= '${StartDay}' and  start_time <  '${NextStartDay}'



, lw_stat as ( -- ���ڲֿ��
select BoxSku ,'��˼�Բ�' ������Դ
    ,ifnull( sum( case when WarehouseName='��ݸ��' then TotalInventory end ) ,0) as ���ڿ��_��ݸ��
    ,ifnull( sum( case when WarehouseName='��ݸ-�����' then TotalInventory end ) ,0) as ���ڿ��_��ݸ�����
    ,ifnull( sum( case when WarehouseName='����-��Ʒ��' then TotalInventory end ) ,0) as ���ڿ��_��Ʒ��
from daily_WarehouseInventory where CreatedTime = '${NextStartDay}'  group by BoxSku
)

, fba_stat as ( -- FBA�ֿ�棬����Դ�� ���� Amazon Listing����-FBA����
select dfb.boxsku ,'��˼�Բ�' ������Դ
     ,ifnull( sum(CurrentInventory) ,0) ������_FBA
from import_data.daily_FBAInventory_Box dfb
-- join prod on dfb.boxsku = prod.boxsku
where GenerateDate = '2023-06-30'  and BoxSku =4332500
group by dfb.boxsku
)



, ab_stat as (   -- ����ֿ�ֿ��, ����Դ������ �ִ�������ֱ���
select boxsku 
	,case when Warehouse regexp '�Ȳ�' and Warehouse not regexp '��˼' then '����û�' else '��˼�Բ�' end  as ������Դ
    ,ifnull( sum( case when Warehouse_cat='�Ȳ�' then CurrentInventory end ) ,0) ������_�Ȳ�
    ,ifnull( sum( case when Warehouse_cat='������' then CurrentInventory end ) ,0) ������_������
    ,ifnull( sum( case when Warehouse_cat='���' then CurrentInventory end ) ,0) ������_���
    ,ifnull( sum( case when Warehouse_cat='�ʲ�С��' then CurrentInventory end ) ,0) ������_�ʲ�С��
from (
    select Warehouse
    ,case when Warehouse regexp 'FBA' THEN 'FBA'
             when Warehouse regexp '�Ȳ�' THEN '�Ȳ�'
             when Warehouse regexp '������' THEN '������'
             when Warehouse regexp '���' THEN '���'
             when Warehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
             else Warehouse
             end as Warehouse_cat
    , da.BoxSku, CurrentInventory, TransportingCount
    from import_data.daily_ABroadWarehouse da
--     join prod on da.boxsku = prod.boxsku
    where GenerateDate = '${NextStartDay}'  
    and ProductAddTime is not null -- ��λ����
    ) t
--   where boxsku = 4456462
group by boxsku ,������Դ
)
-- select * from ab_stat 


, add_new_sku as ( -- ���������ɹ��µ���ƷSKU 
select ta.boxsku ,ta.boxsku as ������Ʒ���� ,'��˼�Բ�' ������Դ from purc_stat ta  
left join ( select distinct boxsku from ori_stat ) tb on ta.boxsku = tb.boxsku 
where tb.boxsku is null 
) 

, res as ( -- ��� ��ȥ ���۳��� ,��� ������Դ��-1�ľ����������
select '${NextStartDay}' ��������
	,prod.ProductName
   ,a.boxsku 
   ,ifnull(ost.������Ʒ���� ,a.boxsku  ) ������Ʒ����
   ,ost.������Դ  -- �����²ɹ�
   ,ifnull(ost.���ڽ�����,0)  + ifnull(ps.���ڲɹ���,0) - ifnull(������_�ϼ�,0) as ���ڽ�����_�ۼ���
   ,ifnull(ps.�ɹ���;��,0)  + ifnull(ls.���ڿ��_��ݸ��,0) + ifnull(ls.���ڿ��_��ݸ�����,0) + ifnull(ls.���ڿ��_��Ʒ��,0) + ifnull(hs.������;_�Ȳ�,0) 
   + ifnull(hs.������;_�ʲ�С��,0) + ifnull(hs.������;_������,0)  +  ifnull(hs.������;_FBA,0)
   + ifnull(ast.������_�Ȳ�,0) + ifnull(fs.������_FBA,0) + ifnull(ast.������_�ʲ�С��,0) + ifnull(ast.������_������,0)
   as ���ڽ�����_��ϸ�ӷ�-- ���ڽ��� = �ɹ�
   ,'|�ۼ�������|' as �ָ���
   ,ost.���ڽ�����
   ,ifnull(ps.���ڲɹ���,0) ���ڲɹ���
   ,os.������_�ϼ�
   ,'|��ϸ�ӷ�����|' as �ָ���
   ,ps.�ɹ���;�� 
	,ls.���ڿ��_��ݸ�����
	,ls.���ڿ��_��Ʒ��
	,ls.���ڿ��_��ݸ��
	,hs.������;_�Ȳ�
	,hs.������;_�ʲ�С��
	,hs.������;_FBA
-- 	,hs.������;_������
	
	,ast.������_�Ȳ�
	,ast.������_������
	,ast.������_�ʲ�С��
	,fs.������_FBA
	
,os.������_�Ȳ�
,os.������_������
,os.������_FBA 
,os.������_��ݸ��
   

from (
	select  boxsku , ������Ʒ���� , ������Դ from ori_stat 
	union all select boxsku , ������Ʒ���� , ������Դ from add_new_sku 
	) a 
left join prod on a.boxsku = prod.boxsku 
left join ori_stat ost on  a.������Ʒ���� = ost.������Ʒ����
left join od_stat os on  a.boxsku = os.boxsku and a.������Դ = os.������Դ
left join purc_stat ps on  a.boxsku = ps.boxsku and a.������Դ = ps.������Դ
left join hd_stat hs on  a.boxsku = hs.boxsku and a.������Դ = hs.purchase_source
left join lw_stat ls on  a.boxsku = ls.boxsku and a.������Դ = ls.������Դ
left join fba_stat fs on  a.boxsku = fs.boxsku and a.������Դ = fs.������Դ
left join ab_stat ast on  a.boxsku = ast.boxsku and a.������Դ = ast.������Դ
)

-- select * from res order by boxsku 
-- select * from res where ������Ʒ���� not regexp '-'

-- �˶�����

select * from res where BoxSku = 4346663 
-- and ������Ʒ����= '3547350-1' -- 


-- �˶Խ��
-- select * from res where BoxSku = 3547351  -- ��������, ���۳�������Դ����һ�� ��Ʒ�ַ���
-- select * from daily_WarehouseInventory where  BoxSku=4375396  and CreatedTime = '2023-05-20'




