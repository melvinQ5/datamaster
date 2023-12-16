/*
 ����������־��
 */



/*
 ��Ʒ�ؿ� ����ʵ�ַ�����
01 �ؿ���ƷSPU���
ȡ��Ʒ�ؿ�spu�����������������(����)���spu�ְ���(13��spu,��1����)��������Ʒ�����š�����spu������Ŀռ�ȱ��spu��������Ŀ
02��Աÿ��Ԥ���
��spu�ְ���������Ա��ǰ�ŶӺţ����ɡ���Ա�����š�
03��Ʒ�ֵ���
����Ʒ�����š�=����Ա�����š�
04�˵��Ƽ�����
���㵽����Ա����Ŀ�½����µ���ҵ��top1����Ϊ�Ƽ����̡�
 */

-- ͨ��SKU����Χ�����Ƿ�7��ǰ����

-- ������Ʒ�ؿ�������
-- insert into dep_kbh_listing_assignment_log (SPU,SKU,DevelopLastAuditTime,ProductName,SellUserName,push_shopcode,logtime,push_type,wttime)

with grouped_products AS ( -- ��Ʒ�ؿ��������
    SELECT *
    	,ROW_NUMBER() OVER (ORDER BY spu) as ��Ȼ��� 
        ,ROW_NUMBER() OVER (ORDER BY spu) % spu_pack_cnt + 1  as grouped_num -- ��ÿ��SPU��������SPU�����
    FROM (
    	select * ,CEILING (count(spu) over()/30) as spu_pack_cnt -- �������������(30Ϊ���ڿ���)���
    	from (
	    	select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
	    	from ( -- ��7�շ�ͣ����Ʒ��Ϣ
		        select SPU,SKU ,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime,ProductName 
		        	,split(CategoryPathByChineseName, '>')[1] as cat1 
		        from erp_product_products epp -- ʹ��ʵʱ��,�������������
		        left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
		        where ismatrix = 0 and productstatus != 2 and projectteam = '��ٻ�'
		        	and date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 7 day)
		        	and date_add(DevelopLastAuditTime,interval -8 hour) < date_add(current_date(),interval - 1 day)
		        ) epp 
	        left join ( -- ���������� �����ܳ���δ�����ɹ�)
	        	select distinct sku from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code 
	        	and ms.shopstatus = '����' and eaal.listingstatus = 1 ) eaal
	            on epp.sku = eaal.sku
	        where eaal.sku is null 
-- 	        limit 0,40
	        ) t1 
        ) t2 
    order by grouped_num asc 
)

,mark_main_cat as ( -- ��ÿ��SPU���������Ŀ
select distinct  grouped_num , cat1 as main_pack_cat1
from (
	select ROW_NUMBER ()over(partition by grouped_num order by cat_cnt desc ) cal ,*
		from (
		select grouped_num , cat1 ,count(1) cat_cnt
		from  grouped_products group by grouped_num , cat1
		) ta  
	) tb
where cal = 1
)
-- select * from mark_main_cat 

,numbered_persons as ( -- ��Աÿ��Ԥ���
 SELECT np.*, t.spu_pack_cnt
    ,if(spu_pack_cnt>1,CEILING(ori_number/spu_pack_cnt),CEILING(ori_number/(spu_pack_cnt+1))) pre_assign_num 
    -- 1�������������ˣ�2���������4����
    -- ���� �����շ�������һ��Ա�����Ϊ��1, 
  FROM (select distinct c4 as SellUserName ,c3 as team 
  		,c2+0 as ori_number
--   		,c2+0 - yesterday_number as queue_number -- ���ն��к�
  	from manual_table mt  where c1='��ٻ���Ʒ����_��Ʒ�����˺�0530' -- ������Ա�������±����ά��
--   	left join (select max(ori_number) yesterday_number as from dep_kbh_listing_assignment_log 
--   		where date = (select max(logtime) from dep_kbh_listing_assignment_log ) 
--   		) -- �����շ�������һ��Ա�����Ϊ��1
	) np 
  join (select distinct spu_pack_cnt from grouped_products) t on 1=1 -- ������spu�ְ�������
  order by pre_assign_num 
)
-- select * from numbered_persons 

,spu2person as ( -- ��Ʒ�ֵ���
select gp.* ,mmc.main_pack_cat1  ,np.*
from grouped_products gp 
left join mark_main_cat mmc on gp.grouped_num = mmc.grouped_num 
join numbered_persons np on gp.grouped_num = np.pre_assign_num 
order by grouped_num ,spu
)
-- select * from spu2person 


-- ���㵽����Ա����Ŀ�½����µ���ҵ��top1��Ϊ�Ƽ�����
,mark_top_shop as (
select * 
from ( -- ÿ����ѡҵ��Ա x ÿ������Ŀ x ÿ�����̵����۶�����
	select ROW_NUMBER () over( partition by cat1 ,seller order by totalgross desc ) cal ,ta.*
	from ( 
		select cat1 ,Seller ,shopcode ,round(sum(totalgross/exchangeusd)) totalgross
		from wt_orderdetails wo 
		join (select distinct spu ,cat1  from wt_products ) wp on wp.spu =wo.Product_SPU 
			and paytime >= date_add('${NextStartDay}',interval - 3 month) and PayTime < '${NextStartDay}'
			and wo.isdeleted = 0 
		group by cat1 ,Seller ,shopcode 
		) ta 
		join (select distinct main_pack_cat1 ,SellUserName from spu2person ) tb on ta.cat1 =tb.main_pack_cat1 and ta.seller = tb.sellusername
		join mysql_store ms on ta.shopcode =ms.Code and ms.ShopStatus = '����'  -- ������������
		join manual_table mt on mt.c1='��ٻ���Ʒ����_��Ʒ�����˺�0530' and ms.AccountCode = mt.memo --  ��Χ�������������̷�Χ�ڣ��ű���ȡ�����ļ�д��
	) tb 
where cal = 1 
)
-- select * from mark_top_shop 

select 
	s.SPU ,s.SKU ,s.DevelopLastAuditTime ,s.ProductName ,s.SellUserName ,m.shopcode as push_shopcode  ,'${NextStartDay}' ,'��Ʒ�ؿ�',now()
from spu2person s
left join mark_top_shop m on s.main_pack_cat1 = m.cat1 and s.sellusername = m.seller;


