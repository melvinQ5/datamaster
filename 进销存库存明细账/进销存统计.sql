
-- 本期库存计算逻辑：上期库存量+本期购入量-本期销售量=本期库存量

with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇' )

,ori_stat as ( -- 初始化数据
select
    c1 as boxsku ,c2 as 进货产品编码
    , case when c2 regexp '-1' then '领科拿货' else '奈思自采' end 进货来源
    ,if(length(c21)=0,0,c21) - if(length(c20)=0,0,c20) - if(length(c19)=0,0,c19)- if(length(c18)=0,0,c18)- if(length(c17)=0,0,c17)  as  上期结余数
    ,c5 上期采购在途 
    ,c6 国内库存_东莞备库 ,c7 国内库存_样品仓 ,c8 国内库存_东莞仓 
    ,c9 海外在途_谷仓 ,c10 海外在途_出口易 ,c11 海外在途_邮差小马 ,c12 海外在途_FBA 
    ,c13 海外库存_谷仓 ,c14 海外库存_出口易 ,c15 海外库存_邮差小马 ,c16 海外库存_FBA 
	,c17 已销售_谷仓 ,c18 已销售_出口易 ,c19 已销售_FBA ,c20 已销售_东莞仓
	,c21 全流程数据
from manual_table where handlename in ( '全流程库存-5月','全流程库存' ) and handletime = '2023-06-27'  
and c1 != 'boxsku' and c3 != '已淘汰'
order by memo
) 
-- select * from ori_stat ;

-- select * 
-- from manual_table where handlename in ( '全流程库存-5月','全流程库存' ) and handletime = '2023-06-27' and c1 regexp '817' 

, od_stat as ( -- 销售出库
-- 判断谷仓的领科拿货有无库存，有则先减出
select boxsku 
	,case 
		when boxsku = 4346663 then  '奈思自采'  -- -1领科自采已经淘汰
		when from_place_detail regexp '谷仓' and from_place_detail not regexp '奈思' then '领科拿货' else '奈思自采' 
	end  as 进货来源
    ,ifnull( sum( case when from_place = '谷仓' then start_quantity end ) ,0) 已销售_谷仓
    ,ifnull( sum( case when from_place = '出口易' then start_quantity end ) ,0) 已销售_出口易
    ,ifnull( sum( case when from_place = 'FBA' then start_quantity end ) ,0) 已销售_FBA
    ,ifnull( sum( case when from_place = '东莞仓' then start_quantity end ) ,0) 已销售_东莞仓
    ,ifnull( sum(  start_quantity  ) ,0) 已销售_合计
from dep_purchase_sales_inventory_log
where event_type = '销售出库' and start_time >= '${StartDay}' and start_time < '${NextStartDay}' 
group by boxsku ,进货来源  
)
-- select * from od_stat where  boxsku = 4346663

, purc_stat as (
select BoxSku ,'奈思自采' as 进货来源
 ,ifnull ( sum( case when start_time >= '${StartDay}' and start_time < '${NextStartDay}' then start_quantity end ) ,0 ) 本期采购数
 ,ifnull ( sum( start_quantity - case when ifnull(end_time,'2999-12-31') >= '${NextStartDay}' then 0 else end_quantity end) ,0)  采购在途数
from dep_purchase_sales_inventory_log where event_type = '采购入库' 
group by BoxSku
)
-- select * from purc_stat

, hd_stat as ( -- 头程发货
select BoxSku ,purchase_source 
    ,ifnull( sum( case when reach_place = '谷仓' then start_quantity - end_quantity  end ) ,0) 海外在途_谷仓
    ,ifnull( sum( case when reach_place = '邮差小马' then start_quantity - ifnull(end_quantity,0)  end ) ,0) 海外在途_邮差小马
    ,ifnull( sum( case when reach_place = 'FBA' then start_quantity - end_quantity  end ) ,0) 海外在途_FBA
    ,ifnull( sum( case when reach_place = '出口易' then start_quantity - end_quantity  end ) ,0) 海外在途_出口易
from dep_purchase_sales_inventory_log where event_type = '头程发货' and start_time >= '${StartDay}' and  start_time <  '${NextStartDay}'
group by BoxSku ,purchase_source
)
-- select * from hd_stat where  boxsku = 3547351

-- select * 
-- from dep_purchase_sales_inventory_log where event_type = '头程发货'  and boxsku = 3547351
-- and start_time >= '${StartDay}' and  start_time <  '${NextStartDay}'



, lw_stat as ( -- 国内仓库存
select BoxSku ,'奈思自采' 进货来源
    ,ifnull( sum( case when WarehouseName='东莞仓' then TotalInventory end ) ,0) as 国内库存_东莞仓
    ,ifnull( sum( case when WarehouseName='东莞-备库仓' then TotalInventory end ) ,0) as 国内库存_东莞备库仓
    ,ifnull( sum( case when WarehouseName='深圳-样品仓' then TotalInventory end ) ,0) as 国内库存_样品仓
from daily_WarehouseInventory where CreatedTime = '${NextStartDay}'  group by BoxSku
)

, fba_stat as ( -- FBA仓库存，数据源： 塞盒 Amazon Listing管理-FBA链接
select dfb.boxsku ,'奈思自采' 进货来源
     ,ifnull( sum(CurrentInventory) ,0) 海外库存_FBA
from import_data.daily_FBAInventory_Box dfb
-- join prod on dfb.boxsku = prod.boxsku
where GenerateDate = '2023-06-30'  and BoxSku =4332500
group by dfb.boxsku
)



, ab_stat as (   -- 海外仓库仓库存, 数据源：赛盒 仓储》海外仓备货
select boxsku 
	,case when Warehouse regexp '谷仓' and Warehouse not regexp '奈思' then '领科拿货' else '奈思自采' end  as 进货来源
    ,ifnull( sum( case when Warehouse_cat='谷仓' then CurrentInventory end ) ,0) 海外库存_谷仓
    ,ifnull( sum( case when Warehouse_cat='出口易' then CurrentInventory end ) ,0) 海外库存_出口易
    ,ifnull( sum( case when Warehouse_cat='万德' then CurrentInventory end ) ,0) 海外库存_万德
    ,ifnull( sum( case when Warehouse_cat='邮差小马' then CurrentInventory end ) ,0) 海外库存_邮差小马
from (
    select Warehouse
    ,case when Warehouse regexp 'FBA' THEN 'FBA'
             when Warehouse regexp '谷仓' THEN '谷仓'
             when Warehouse regexp '出口易' THEN '出口易'
             when Warehouse regexp '万德' THEN '万德'
             when Warehouse regexp '邮差小马' THEN '邮差小马'
             else Warehouse
             end as Warehouse_cat
    , da.BoxSku, CurrentInventory, TransportingCount
    from import_data.daily_ABroadWarehouse da
--     join prod on da.boxsku = prod.boxsku
    where GenerateDate = '${NextStartDay}'  
    and ProductAddTime is not null -- 错位数据
    ) t
--   where boxsku = 4456462
group by boxsku ,进货来源
)
-- select * from ab_stat 


, add_new_sku as ( -- 加入新增采购下单产品SKU 
select ta.boxsku ,ta.boxsku as 进货产品编码 ,'奈思自采' 进货来源 from purc_stat ta  
left join ( select distinct boxsku from ori_stat ) tb on ta.boxsku = tb.boxsku 
where tb.boxsku is null 
) 

, res as ( -- 库存 减去 销售出库 ,如果 塞盒来源是-1的就是领科来货
select '${NextStartDay}' 快照日期
	,prod.ProductName
   ,a.boxsku 
   ,ifnull(ost.进货产品编码 ,a.boxsku  ) 进货产品编码
   ,ost.进货来源  -- 区分新采购
   ,ifnull(ost.上期结余数,0)  + ifnull(ps.本期采购数,0) - ifnull(已销售_合计,0) as 本期结余数_扣减法
   ,ifnull(ps.采购在途数,0)  + ifnull(ls.国内库存_东莞仓,0) + ifnull(ls.国内库存_东莞备库仓,0) + ifnull(ls.国内库存_样品仓,0) + ifnull(hs.海外在途_谷仓,0) 
   + ifnull(hs.海外在途_邮差小马,0) + ifnull(hs.海外在途_出口易,0)  +  ifnull(hs.海外在途_FBA,0)
   + ifnull(ast.海外库存_谷仓,0) + ifnull(fs.海外库存_FBA,0) + ifnull(ast.海外库存_邮差小马,0) + ifnull(ast.海外库存_出口易,0)
   as 本期结余数_明细加法-- 本期结余 = 采购
   ,'|扣减法详情|' as 分割线
   ,ost.上期结余数
   ,ifnull(ps.本期采购数,0) 本期采购数
   ,os.已销售_合计
   ,'|明细加法详情|' as 分割线
   ,ps.采购在途数 
	,ls.国内库存_东莞备库仓
	,ls.国内库存_样品仓
	,ls.国内库存_东莞仓
	,hs.海外在途_谷仓
	,hs.海外在途_邮差小马
	,hs.海外在途_FBA
-- 	,hs.海外在途_出口易
	
	,ast.海外库存_谷仓
	,ast.海外库存_出口易
	,ast.海外库存_邮差小马
	,fs.海外库存_FBA
	
,os.已销售_谷仓
,os.已销售_出口易
,os.已销售_FBA 
,os.已销售_东莞仓
   

from (
	select  boxsku , 进货产品编码 , 进货来源 from ori_stat 
	union all select boxsku , 进货产品编码 , 进货来源 from add_new_sku 
	) a 
left join prod on a.boxsku = prod.boxsku 
left join ori_stat ost on  a.进货产品编码 = ost.进货产品编码
left join od_stat os on  a.boxsku = os.boxsku and a.进货来源 = os.进货来源
left join purc_stat ps on  a.boxsku = ps.boxsku and a.进货来源 = ps.进货来源
left join hd_stat hs on  a.boxsku = hs.boxsku and a.进货来源 = hs.purchase_source
left join lw_stat ls on  a.boxsku = ls.boxsku and a.进货来源 = ls.进货来源
left join fba_stat fs on  a.boxsku = fs.boxsku and a.进货来源 = fs.进货来源
left join ab_stat ast on  a.boxsku = ast.boxsku and a.进货来源 = ast.进货来源
)

-- select * from res order by boxsku 
-- select * from res where 进货产品编码 not regexp '-'

-- 核对数据

select * from res where BoxSku = 4346663 
-- and 进货产品编码= '3547350-1' -- 


-- 核对结果
-- select * from res where BoxSku = 3547351  -- 电热汤池, 销售出库数据源，差一个 样品仓发货
-- select * from daily_WarehouseInventory where  BoxSku=4375396  and CreatedTime = '2023-05-20'




