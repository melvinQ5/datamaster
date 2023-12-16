/*
 创建分配日志表
 */



/*
 新品必刊 数据实现方案：
01 必刊新品SPU打包
取新品必刊spu数，按单日最大工作量(可配)获得spu分包数(13个spu,即1个包)，即【产品分配编号】，按spu包的类目占比标记spu包的主类目
02人员每日预编号
按spu分包数，及人员当前排队号，生成【人员分配编号】
03产品分到人
【产品分配编号】=【人员分配编号】
04人到推荐店铺
计算到号人员主类目下近三月店铺业绩top1，作为推荐店铺。
 */

-- 通过SKU终审范围区分是否7天前终审

-- 生成新品必刊登任务
-- insert into dep_kbh_listing_assignment_log (SPU,SKU,DevelopLastAuditTime,ProductName,SellUserName,push_shopcode,logtime,push_type,wttime)

with grouped_products AS ( -- 新品必刊待分配表
    SELECT *
    	,ROW_NUMBER() OVER (ORDER BY spu) as 自然序号 
        ,ROW_NUMBER() OVER (ORDER BY spu) % spu_pack_cnt + 1  as grouped_num -- 给每个SPU贴上所属SPU包编号
    FROM (
    	select * ,CEILING (count(spu) over()/30) as spu_pack_cnt -- 按单日最大工作量(30为后期可配)打包
    	from (
	    	select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
	    	from ( -- 近7日非停产产品信息
		        select SPU,SKU ,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime,ProductName 
		        	,split(CategoryPathByChineseName, '>')[1] as cat1 
		        from erp_product_products epp -- 使用实时表,避免宽表调度延误
		        left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
		        where ismatrix = 0 and productstatus != 2 and projectteam = '快百货'
		        	and date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 7 day)
		        	and date_add(DevelopLastAuditTime,interval -8 hour) < date_add(current_date(),interval - 1 day)
		        ) epp 
	        left join ( -- 无在线链接 （可能出现未关联成功)
	        	select distinct sku from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code 
	        	and ms.shopstatus = '正常' and eaal.listingstatus = 1 ) eaal
	            on epp.sku = eaal.sku
	        where eaal.sku is null 
-- 	        limit 0,40
	        ) t1 
        ) t2 
    order by grouped_num asc 
)

,mark_main_cat as ( -- 给每个SPU包标记主类目
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

,numbered_persons as ( -- 人员每日预编号
 SELECT np.*, t.spu_pack_cnt
    ,if(spu_pack_cnt>1,CEILING(ori_number/spu_pack_cnt),CEILING(ori_number/(spu_pack_cnt+1))) pre_assign_num 
    -- 1个包分配两个人，2个包分配给4个人
    -- 待办 从昨日分配后的下一个员工标记为第1, 
  FROM (select distinct c4 as SellUserName ,c3 as team 
  		,c2+0 as ori_number
--   		,c2+0 - yesterday_number as queue_number -- 当日队列号
  	from manual_table mt  where c1='快百货产品刊登_新品刊登账号0530' -- 基础人员排序线下表格中维护
--   	left join (select max(ori_number) yesterday_number as from dep_kbh_listing_assignment_log 
--   		where date = (select max(logtime) from dep_kbh_listing_assignment_log ) 
--   		) -- 从昨日分配后的下一个员工标记为第1
	) np 
  join (select distinct spu_pack_cnt from grouped_products) t on 1=1 -- 将当日spu分包数传入
  order by pre_assign_num 
)
-- select * from numbered_persons 

,spu2person as ( -- 产品分到人
select gp.* ,mmc.main_pack_cat1  ,np.*
from grouped_products gp 
left join mark_main_cat mmc on gp.grouped_num = mmc.grouped_num 
join numbered_persons np on gp.grouped_num = np.pre_assign_num 
order by grouped_num ,spu
)
-- select * from spu2person 


-- 计算到号人员主类目下近三月店铺业绩top1作为推荐店铺
,mark_top_shop as (
select * 
from ( -- 每个首选业务员 x 每个主类目 x 每个店铺的销售额排名
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
		join mysql_store ms on ta.shopcode =ms.Code and ms.ShopStatus = '正常'  -- 保留正常店铺
		join manual_table mt on mt.c1='快百货产品刊登_新品刊登账号0530' and ms.AccountCode = mt.memo --  范围在美丽给定店铺范围内，脚本读取最新文件写入
	) tb 
where cal = 1 
)
-- select * from mark_top_shop 

select 
	s.SPU ,s.SKU ,s.DevelopLastAuditTime ,s.ProductName ,s.SellUserName ,m.shopcode as push_shopcode  ,'${NextStartDay}' ,'新品必刊',now()
from spu2person s
left join mark_top_shop m on s.main_pack_cat1 = m.cat1 and s.sellusername = m.seller;


