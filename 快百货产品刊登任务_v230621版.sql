
/*
 创建分配日志表
 */
CREATE TABLE IF NOT EXISTS
dep_kbh_listing_assignment_log (
`PushDate` date NOT NULL comment "分配日期",
`SPU` varchar(32)  NOT NULL COMMENT "SPU",
`SKU` varchar(32) NOT NULL COMMENT "SKU",
`SellUserName` varchar(32) NOT NULL COMMENT "推荐首选业务员",
`push_shop` varchar(32) NOT NULL COMMENT "推荐刊登店铺",
`DevelopLastAuditTime` datetime REPLACE_IF_NOT_NULL null comment "终审时间",
`ProductName` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "产品名称",
`PushType` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "分配类型",
`isFirstTime` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "新品首次二次分配人员",
`SpuPackNumb` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "SPU打包编号",
`Cat1` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "一级类目",
`Cat2` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "二级类目",
`IsDeleted` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "数据是否删除",
`Updatetime` datetime REPLACE_IF_NOT_NULL null comment "数据更新时间"
) ENGINE=OLAP
AGGREGATE KEY(PushDate,SPU,SKU,SellUserName,push_shop)
COMMENT "快百货产品刊登分配日志表"
DISTRIBUTED BY HASH(PushDate,SKU,SellUserName) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);
-- 一个SPU推给A 推错了，需要改为推给B：增加一个删除字段
-- 一个SKU在同一天需要同时推给两个人：SellUserName 设为key

ALTER TABLE dep_kbh_listing_assignment_log MODIFY COLUMN `ProductName` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "产品名称";
ALTER TABLE dep_kbh_listing_assignment_log MODIFY COLUMN `Cat2` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "二级类目";

ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `SpuPackNumb` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "SPU打包编号" after PushType;
ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `Cat2` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "二级类目" after SpuPackNumb;
ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `isFirstTime` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "新品首次二次分配人员" after PushType;

TRUNCATE table  dep_kbh_listing_assignment_log  打断施法

-- 分配结果查询
select * from dep_kbh_listing_assignment_log order by PushType

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

/*
类目集中优化
每个人分一个一级类目，不超过3个二级类目
 */




-- 生成新品必刊登任务
insert into dep_kbh_listing_assignment_log (PushDate,SPU,SKU,SellUserName,push_shop,DevelopLastAuditTime,ProductName,PushType,isFirstTime,SpuPackNumb,Cat1,Cat2,IsDeleted,Updatetime)

with pre_grouped_products AS ( -- 新品必刊待分配表
select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1 , cat2
from ( -- 近7日非停产产品信息
    select SPU,SKU ,date_add(DevelopLastAuditTime,interval -8 hour) DevelopLastAuditTime,ProductName
        ,split(CategoryPathByChineseName, '>')[1] as cat1
        ,split(CategoryPathByChineseName, '>')[2] as cat2
    from erp_product_products epp -- 使用实时表,避免宽表调度延误
    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
    where ismatrix = 0 and productstatus != 2 and projectteam = '快百货' and DevelopLastAuditTime is not null
        and date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 7 day)
        and date_add(DevelopLastAuditTime,interval -8 hour) < concat(current_date(),' 10:30:00')
       --  and date_add(DevelopLastAuditTime,interval -8 hour) < concat(current_date(),' 23:30:00')
    ) epp
left join ( -- 无在线链接 （可能出现未关联成功)
    select distinct sku from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code
    and ms.shopstatus = '正常' and eaal.listingstatus = 1 and ms.NodePathName regexp '成都'
    ) eaal
    on epp.sku = eaal.sku
left join ( select distinct sku from dep_kbh_listing_assignment_log
    where  PushDate >= date_add(current_date(),interval - 7 day  ) -- 近7天分配日志
    ) dkla on epp.sku = dkla.sku
where eaal.sku is null
    and dkla.sku is null
)

, spu_pack as ( -- 按类目排序作为优先级打包
select *
    , case when grouped_num_1 > max(分几个包) over() then grouped_num_1-1 else grouped_num_1 end grouped_num
from (
    SELECT *
         , max(spu_priority) over() div 分几个包 as 每个包SPU数
        , (spu_priority-1) div ( max(spu_priority) over() div 分几个包 ) + 1 as grouped_num_1
    from (
        select *
            ,case
                when  max(spu_priority) over() <= 30 then 1
                when  max(spu_priority) over() <= 60 then 2
                when  max(spu_priority) over() <= 90 then 3
                when  max(spu_priority) over() < 120 then 4
                when  max(spu_priority) over() < 150 then 5
                when  max(spu_priority) over() < 180 then 6
                when  max(spu_priority) over() < 210 then 7
                end as 分几个包
        FROM (  select  *, ROW_NUMBER() over ( order by cat1,cat2,spu ) spu_priority
              from (select distinct spu ,cat1,cat2  from pre_grouped_products ) t  ) a
    ) b
) c
)
-- select * from spu_pack

, grouped_products AS ( -- 新品必刊待分配表
select pgp.* ,grouped_num
from pre_grouped_products pgp
left join spu_pack b on pgp.SPU =b.SPU
)
-- select * from grouped_products

,mark_main_cat as ( -- 给每个SPU包标记主类目 ,用于选择主类目下业绩最大的店铺作为推荐店铺
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

,last_time_log as ( -- 上次人员分配结果
    select distinct c4 as SellUserName, c3 as team
      , c2+0 as ori_number_old, dklal.sellusername log_name
    from manual_table mt
    left join ( select distinct sellusername from dep_kbh_listing_assignment_log
    where pushtype = '新品必刊' and PushDate = (select max(PushDate) from dep_kbh_listing_assignment_log )
    ) dklal on mt.c4 = dklal.sellusername
    where c1='快百货产品刊登_新品刊登账号0530'
    order by ori_number_old
)

,numbered_persons as ( -- 人员每日预编号
 SELECT *
    ,CEILING(sort/2) pre_assign_num
    , case when mod(ROW_NUMBER () over (order by sort), 2) = 1 then '新品首次分配' else '新品二次分配' end isFirstTime
    -- 1个包分配两个人，2个包分配给4个人
  FROM (
  	select * , row_number() over () as sort
    from ( select *
        from last_time_log join (select max(ori_number_old) last_numb from last_time_log where log_name is not null) t on 1 = 1
        where last_numb < ori_number_old
        union all select *, 0 from last_time_log
        union all select *, 0 from last_time_log
        union all select *, 0 from last_time_log
    ) tmp
     /*
    -- 第二版 手动跟进分配日志及昨日人员调整名单  -- 小于60个SPU都只分配给两个人
    select * , row_number() over (order by ori_number_old ) as sort from last_time_log mt
    join ( select distinct sellusername  from dep_kbh_listing_assignment_log
        where pushtype = '新品必刊' and SellUserName regexp '石金凤|吴欣遥'
        ) dklal  on mt.sellusername = dklal. sellusername
    where c1='快百货产品刊登_新品刊登账号0530'
    */
	 ) tmp 
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
	'${NextStartDay}' ,s.SPU ,s.SKU  ,s.SellUserName  ,m.shopcode as push_shopcode ,s.DevelopLastAuditTime ,s.ProductName  ,'新品必刊' ,isFirstTime
	,grouped_num ,s.cat1, s.cat2 ,0 ,now()
from spu2person s
left join mark_top_shop m on s.main_pack_cat1 = m.cat1 and s.sellusername = m.seller;








-- 推送新品必刊分配日志表
select dklal.SPU ,dklal.SKU  ,epp.boxsku  ,dklal.ProductName ,wp.CategoryPathByChineseName , wp.PackageWeight ,wp.Logistics_Attr 
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as  `产品状态`
	,banneds_info 
	,wp.DevelopUserName 
	,wp.LastPurchasePrice ,wp.FirstImageUrl ,dklal.DevelopLastAuditTime  ,ele_name ,wp.Festival 
	,dklal.SellUserName
	,dklal.isFirstTime
	,dklal.PushDate 
from dep_kbh_listing_assignment_log dklal 
left join wt_products wp on wp.Sku  = dklal.sku 
left join erp_product_products epp on epp.Sku  = dklal.sku and IsMatrix = 0 
left join (select sku ,GROUP_CONCAT(plat_site,'  |  ') banneds_info
	from (
	select sku , concat( PlatformCode ,': ', GROUP_CONCAT(ChannelSiteCode) ) plat_site 
	from (
	SELECT id,sku from erp_product_products where IsMatrix = 0 
	) epp 
	join import_data.erp_product_product_banneds eppb on epp.id = eppb.ProductId 
	group by sku , PlatformCode 
	) t
	group by sku ) banneds on dklal .sku = banneds .sku 
left join ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on dklal.sku =t_elem .sku
where  PushType = '新品必刊'
ORDER BY PushDate DESC ,SpuPackNumb ASC ,SPU


/*
 老品必刊 数据实现方案： 将SPU分到账号上
一个一个类目分，优先分工具配件 > 健康
账号类目选择公式 （3月1日至今销售额）
1）对应账号的四大类目之一业绩/该账号总业绩=本账号类目业绩占比
2）取工具配件”本账号类目业绩占比“前6个账号；健康时尚9个账号；娱乐爱好10个账号；剩下家居生活


 1 每个账号的四大类目的业绩



 */
-- 生成老品必刊任务


-- insert into dep_kbh_listing_assignment_log (PushDate, SPU, SKU, SellUserName, push_shop, DevelopLastAuditTime, ProductName, PushType, SpuPackNumb, Cat1 ,Cat2, IsDeleted, Updatetime)
with
pre_grouped_products AS ( -- 01 计算老品必刊池
select * from (
	select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
		,case
		    when DevelopLastAuditTime < '2023-04-01' and kbh_cd_online_code > 0  and kbh_cd_online_code < 3 and kbh_online_code < 6 then 1
			when DevelopLastAuditTime >= '2023-04-01'   and kbh_cd_online_code < 3 then 1  -- 23年4月起终审产品，成都＜3套，均可分配
			else 0 end as unlimit
        ,case when  date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 30 day) then '近30天终审' end as '近30天终审标记'
	    ,case when saleIn30d_over_500_sku is not null then '近30天成都不含运费销售额大于500usd' end as '成都爆旺款标记'
	    ,ele_name  as '主题产品标记'
	    ,kbh_online_code as '快百货在线账号套数'
	    ,kbh_cd_online_code  as '快百货成都在线账号套数'
	    ,kbh_qz_online_code  as '快百货泉州在线账号套数'
	from ( -- 7日前终审非停产产品信息
	    select SPU,SKU
	    	,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime
	    	,ProductName
	    	,split(CategoryPathByChineseName, '>')[1] as cat1
	    	,pruc
	    from erp_product_products epp -- 使用实时表,避免宽表调度延误
	    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
	    where ismatrix = 0 and productstatus != 2  and projectteam = '快百货'
	    	and date_add(DevelopLastAuditTime,interval -8 hour) < date_add(current_date(),interval - 7 day)
	    ) epp
	left join (select spu from erp_product_products where ismatrix = 0 and status != 10 group by spu ) unfinished on epp.spu = unfinished.spu-- 所有存在未终审完成的SPU
	join (select sku ,LastPurchasePrice from import_data.wt_products
	    where LastPurchasePrice >= 5 -- 采购价＜5 暂不分配
	    and cat1 regexp 'A3' -- 只分A3类目
	) t on t.sku = epp.sku
	left join ( -- 在线账号数
		select sku ,count(distinct ms.CompanyCode) kbh_online_code
		     ,count(distinct case when nodepathname regexp '成都' then ms.CompanyCode end) kbh_cd_online_code
		     ,count(distinct case when nodepathname regexp '泉州' then ms.CompanyCode end) kbh_qz_online_code
		from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='快百货' and ms.shopstatus = '正常' and eaal.listingstatus = 1
		group by sku
		) eaal on epp.sku = eaal.sku
	join ( -- 近3月有出单
		select product_sku as sku
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code where isdeleted = 0 and paytime > date_add(current_date(),interval - 3 month) and ms.department regexp '快'
		group by product_sku
		) wo on epp.sku = wo.sku
	left join ( -- 23年以前开发，且23年未出单的spu
		select wp.spu
		from wt_products wp
		left join import_data.wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code
		where wp.isdeleted = 0 and paytime > '2023-01-01' and ms.department regexp '快' and wp.DevelopLastAuditTime < '2023-01-01' and wo.isdeleted =
		group by wp.spu having count( distinct platordernumber ) = 0
		) old_prod_nosale_in23 on epp.spu = old_prod_nosale_in23.spu
	left join ( -- 近30天 且不含运费收入的销售额大于500美金
		select product_sku as saleIn30d_over_500_sku
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code
		where isdeleted = 0 and paytime > date_add( current_date(),interval - 30 day )
	        and TransactionType <> '其他'  and asin <>''  and wo.boxsku<>'' and ms.department regexp '快'  and  NodePathName regexp '成都'
		group by product_sku having sum((TotalGross-FeeGross)/ExchangeUSD) >= 500
		) wo30  on epp.sku = wo30.saleIn30d_over_500_sku
	left join ( select spu ,group_concat(Name) ele_name-- 主题
	    from ( select spu ,eppea.Name
            from import_data.erp_product_product_associated_element_attributes eppaea
            left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
            where eppea.name = '夏季' group by spu ,eppea.Name ) t group by spu
        ) tag on epp.spu = tag.spu
/*
	left join (select distinct sku from dep_kbh_listing_assignment_log
		where PushDate >= date_add(current_date(),interval - 7 day) -- 近7天分配日志
		) dkla on epp.sku = dkla.sku
	where dkla.sku is null -- 近1周未分配刊登

 */
	) tmp
where unlimit = 1 and unfinished.spu is not null
    and old_prod_nosale_in23.spu is null  -- 23年以前开发，且23年未出单的SPU不分配
)

-- 检查SPU下是否有正在开发中的子
select
from erp_product_products join (select distinct spu from pre_grouped_products )

,black_lists as ( -- 针对上一步筛选的产品找出目前在线，SKU已在线账号及对应业务员。白名单中不能再出现此类关系 sku+CompanyCode, sku+seller
select eaal.SKU ,CompanyCode ,SellUserName
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.shopcode = ms.code and ms.shopstatus = '正常' and eaal.listingstatus = 1
join pre_grouped_products pgp on eaal.sku = pgp.sku
group by eaal.SKU ,CompanyCode ,SellUserName
)

,white_lists_1 as (  -- 白名单01 拆分行记录得到可刊登店铺记录，并剔除其中黑名单记录（SKU已在线店铺及对应业务员）
select tc.*
from (
	select pgp.* , tb.CompanyCode ,tb.SellUserName , tb.explode_sales_in3m
	from pre_grouped_products pgp
	join (  -- 增加同一个类目下，不同shopcode的记录，并统计类目x店铺维度下的近3月销售额
		select cat1 ,CompanyCode ,SellUserName ,round(sum(totalgross/exchangeusd)) explode_sales_in3m
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode = ms.Code and ms.ShopStatus = '正常' and ms.department = '快百货' and nodepathname regexp '成都'
		join (select distinct sku ,cat1 from pre_grouped_products ) wp on wp.sku =wo.Product_Sku
		where paytime >= date_add('${NextStartDay}',interval - 3 month) and PayTime < '${NextStartDay}' and wo.isdeleted = 0
			and ms.SellUserName is not null
		group by cat1 ,CompanyCode ,SellUserName
		) tb on pgp.cat1 = tb.cat1
	) tc
left join black_lists bl1 on tc.sku = bl1.sku and tc.CompanyCode = bl1.CompanyCode
left join black_lists bl2 on tc.sku = bl2.sku and tc.SellUserName = bl2.SellUserName
where bl1.sku is null -- 剔除黑名单中的 SKU+店铺关系
	and bl2.sku is null -- 剔除黑名单中的 SKU+销售人员关系
)
-- select * from white_lists_1
-- select count(distinct sku) from white_lists_1

,white_lists_2 as ( -- 白名单02 缩减白名单,保留每个SKU所属类目下的top10账号
select *
from ( -- sku所属类目下的店铺业绩排序
    select *, ROW_NUMBER() over ( partition by cat1,sku order by explode_sales_in3m desc ) top_companycode_sort
    from white_lists_1) ta
where top_companycode_sort <= 10
)
-- select * from white_lists_2;

,white_lists_3 AS ( --  白名单03：增加类目集中的排序
-- 在白名单保留业绩TOP10店铺时，相当于已经对店铺业绩优先级做了处理
    select wl.*, cat2, DENSE_RANK() over ( order by cat2 ) spu_priority
    from white_lists_2 wl
    left join ( -- 增加二级类目，用于排序集中分配同一人
       select distinct spu ,cat2 from wt_products ) te on wl.spu = te.spu
order by spu_priority ,spu
)

select spu ,sku ,cat1 `所属一级类目` ,`快百货在线账号套数` ,`快百货成都在线账号套数` ,`快百货泉州在线账号套数` , CompanyCode `可刊登账号` , SellUserName `可刊登首选业务人员` ,explode_sales_in3m `该类目x账号x业务员近3月销售额`
    ,DevelopLastAuditTime `产品终审日期`
    ,left(DevelopLastAuditTime,7) `产品终审月份`
    ,近30天终审标记 ,成都爆旺款标记 ,主题产品标记 ,cat2 `二级类目`
from white_lists_3 order by  `产品终审日期`;



-- 按spu分配 第一顺位员工的所有白名单，在类目集中的前提下，取top30的SPU
select  '${NextStartDay}' , spu ,sku ,SellUserName ,CompanyCode as push_shop ,DevelopLastAuditTime ,ProductName
	, '老品必刊',grouped_num ,cat1 ,cat2 ,0 ,now()
from (select dense_rank() over (order by concat(spu_priority, spu) ) grouped_num, *
      from white_lists_3
      where SellUserName = '冯佳仪'
        and CompanyCode = 'RN'
     ) t
where grouped_num <= 30;

-- 按code分配 
select  '${NextStartDay}' , spu ,sku ,SellUserName ,CompanyCode as push_shop ,DevelopLastAuditTime ,ProductName
	        , '老品必刊',grouped_num ,cat1,cat2 ,0  ,now()
from (select dense_rank() over (order by concat(spu_priority, spu) ) grouped_num, *
  from white_lists_3
  where SellUserName = '${person}'
    and CompanyCode in ('${CompanyCode_1}','${CompanyCode_2}') 
) t









-- ,numbered_persons as ( -- 确定当日需要分配任务的业务员，预编号
-- 	select  ms.*  ,ROW_NUMBER () over (order by ms.sellusername) pre_assign_num -- 1个SPU分给同一个人
-- 	from( select distinct sellusername from mysql_store ms where department= '快百货' and NodePathName regexp '成都' and shopstatus = '正常') ms
-- 	-- 不能直接从店铺表取 要从白名单取 
-- 	left join ( -- 剔除上一步骤“新品必刊”任务已分配人员
--         select distinct SellUserName from dep_kbh_listing_assignment_log
--         where PushDate = (select max(PushDate) from dep_kbh_listing_assignment_log ) -- 在新品必刊任务执行后执行
--         ) dkla on ms.SellUserName = dkla.sellusername
--     where dkla.SellUserName is null
-- )
-- -- select * from numbered_persons;
-- 
-- ,grouped_products_1 AS ( --  老品必刊待分配表01：待分配spu的排优先级依据 类目集中
-- -- 在白名单保留业绩TOP10店铺时，相当于已经对店铺业绩优先级做了处理
-- select spu ,sku ,DevelopLastAuditTime ,ProductName ,cat1 , cat2 ,SellUserName  ,spu_priority
-- from (
--     select wl.*
--          , cat2
--          , DENSE_RANK() over ( order by cat2 ) spu_priority
--     from white_lists_2 wl
--     left join ( -- 增加二级类目，用于排序集中分配同一人
--        select distinct spu ,cat2 from wt_products ) te on wl.spu = te.spu
--     ) ta
-- group by spu ,sku ,DevelopLastAuditTime ,ProductName ,cat1 , cat2 ,spu_priority
-- order by spu_priority ,spu
-- )
-- -- select * from grouped_products_1;
-- 
-- 
-- -- 这里给SPU包编号不是直接分配30个
-- ,grouped_products_2 AS ( -- 老品必刊待分配表02： 给SPU打包编号,用于“SPU包编号”与“人编号”一一对应
-- select  *,(spu_priority-1) div 30 + 1  as grouped_num
-- from  grouped_products_1
-- )
-- select * from grouped_products_2;
-- 
-- ,spu2person as ( -- 产品分到人 ,今日有12人参与老品必刊分配,因此从刊登白名单中找到 12*30个spu
-- select gp.*  ,np.*
-- from grouped_products_2 gp
-- join numbered_persons np on gp.grouped_num = np.pre_assign_num
-- order by grouped_num ,spu
-- )
-- -- select * from spu2person order by grouped_num ,sku;
-- 
-- ,person2shop_1 as ( -- 基于可刊登列表, 生成推荐店铺清单，即业务员获得SPU后，应该集中上到哪个店铺
--     select SellUserName ,shopcode as push_shop ,whlit_lists_records ,whlit_lists_records_sort
--     from (select *, ROW_NUMBER() over (partition by SellUserName order by whlit_lists_records desc ) whlit_lists_records_sort
--           from (select ms.SellUserName, shopcode, count(distinct spu) whlit_lists_records
--                 from white_lists_2 wl
--                 left join mysql_store ms on  wl.shopcode = ms.Code
--                 group by SellUserName, shopcode
--                 ) ta
--           ) tb
--     where whlit_lists_records_sort = 1
-- )
-- select * from person2shop_1;
-- 
-- ,person2shop_2 as (
--     select s.*, p.push_shop
--     from spu2person s left join person2shop_1 p on s.SellUserName = p.SellUserName
-- )
-- 
-- select  spu ,sku ,DevelopLastAuditTime ,ProductName,SellUserName ,push_shop ,'${NextStartDay}' ,'老品必刊',now()  from person2shop_2 order by grouped_num ,sku;
-- 
-- select * from dep_kbh_listing_assignment_log dklal 