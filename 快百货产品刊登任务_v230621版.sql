
/*
 ����������־��
 */
CREATE TABLE IF NOT EXISTS
dep_kbh_listing_assignment_log (
`PushDate` date NOT NULL comment "��������",
`SPU` varchar(32)  NOT NULL COMMENT "SPU",
`SKU` varchar(32) NOT NULL COMMENT "SKU",
`SellUserName` varchar(32) NOT NULL COMMENT "�Ƽ���ѡҵ��Ա",
`push_shop` varchar(32) NOT NULL COMMENT "�Ƽ����ǵ���",
`DevelopLastAuditTime` datetime REPLACE_IF_NOT_NULL null comment "����ʱ��",
`ProductName` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ����",
`PushType` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "��������",
`isFirstTime` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ�״ζ��η�����Ա",
`SpuPackNumb` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "SPU������",
`Cat1` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "һ����Ŀ",
`Cat2` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "������Ŀ",
`IsDeleted` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "�����Ƿ�ɾ��",
`Updatetime` datetime REPLACE_IF_NOT_NULL null comment "���ݸ���ʱ��"
) ENGINE=OLAP
AGGREGATE KEY(PushDate,SPU,SKU,SellUserName,push_shop)
COMMENT "��ٻ���Ʒ���Ƿ�����־��"
DISTRIBUTED BY HASH(PushDate,SKU,SellUserName) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);
-- һ��SPU�Ƹ�A �ƴ��ˣ���Ҫ��Ϊ�Ƹ�B������һ��ɾ���ֶ�
-- һ��SKU��ͬһ����Ҫͬʱ�Ƹ������ˣ�SellUserName ��Ϊkey

ALTER TABLE dep_kbh_listing_assignment_log MODIFY COLUMN `ProductName` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ����";
ALTER TABLE dep_kbh_listing_assignment_log MODIFY COLUMN `Cat2` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "������Ŀ";

ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `SpuPackNumb` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "SPU������" after PushType;
ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `Cat2` varchar(128)  REPLACE_IF_NOT_NULL NULL COMMENT "������Ŀ" after SpuPackNumb;
ALTER TABLE dep_kbh_listing_assignment_log ADD COLUMN `isFirstTime` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ�״ζ��η�����Ա" after PushType;

TRUNCATE table  dep_kbh_listing_assignment_log  ���ʩ��

-- ��������ѯ
select * from dep_kbh_listing_assignment_log order by PushType

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

/*
��Ŀ�����Ż�
ÿ���˷�һ��һ����Ŀ��������3��������Ŀ
 */




-- ������Ʒ�ؿ�������
insert into dep_kbh_listing_assignment_log (PushDate,SPU,SKU,SellUserName,push_shop,DevelopLastAuditTime,ProductName,PushType,isFirstTime,SpuPackNumb,Cat1,Cat2,IsDeleted,Updatetime)

with pre_grouped_products AS ( -- ��Ʒ�ؿ��������
select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1 , cat2
from ( -- ��7�շ�ͣ����Ʒ��Ϣ
    select SPU,SKU ,date_add(DevelopLastAuditTime,interval -8 hour) DevelopLastAuditTime,ProductName
        ,split(CategoryPathByChineseName, '>')[1] as cat1
        ,split(CategoryPathByChineseName, '>')[2] as cat2
    from erp_product_products epp -- ʹ��ʵʱ��,�������������
    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
    where ismatrix = 0 and productstatus != 2 and projectteam = '��ٻ�' and DevelopLastAuditTime is not null
        and date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 7 day)
        and date_add(DevelopLastAuditTime,interval -8 hour) < concat(current_date(),' 10:30:00')
       --  and date_add(DevelopLastAuditTime,interval -8 hour) < concat(current_date(),' 23:30:00')
    ) epp
left join ( -- ���������� �����ܳ���δ�����ɹ�)
    select distinct sku from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code
    and ms.shopstatus = '����' and eaal.listingstatus = 1 and ms.NodePathName regexp '�ɶ�'
    ) eaal
    on epp.sku = eaal.sku
left join ( select distinct sku from dep_kbh_listing_assignment_log
    where  PushDate >= date_add(current_date(),interval - 7 day  ) -- ��7�������־
    ) dkla on epp.sku = dkla.sku
where eaal.sku is null
    and dkla.sku is null
)

, spu_pack as ( -- ����Ŀ������Ϊ���ȼ����
select *
    , case when grouped_num_1 > max(�ּ�����) over() then grouped_num_1-1 else grouped_num_1 end grouped_num
from (
    SELECT *
         , max(spu_priority) over() div �ּ����� as ÿ����SPU��
        , (spu_priority-1) div ( max(spu_priority) over() div �ּ����� ) + 1 as grouped_num_1
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
                end as �ּ�����
        FROM (  select  *, ROW_NUMBER() over ( order by cat1,cat2,spu ) spu_priority
              from (select distinct spu ,cat1,cat2  from pre_grouped_products ) t  ) a
    ) b
) c
)
-- select * from spu_pack

, grouped_products AS ( -- ��Ʒ�ؿ��������
select pgp.* ,grouped_num
from pre_grouped_products pgp
left join spu_pack b on pgp.SPU =b.SPU
)
-- select * from grouped_products

,mark_main_cat as ( -- ��ÿ��SPU���������Ŀ ,����ѡ������Ŀ��ҵ�����ĵ�����Ϊ�Ƽ�����
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

,last_time_log as ( -- �ϴ���Ա������
    select distinct c4 as SellUserName, c3 as team
      , c2+0 as ori_number_old, dklal.sellusername log_name
    from manual_table mt
    left join ( select distinct sellusername from dep_kbh_listing_assignment_log
    where pushtype = '��Ʒ�ؿ�' and PushDate = (select max(PushDate) from dep_kbh_listing_assignment_log )
    ) dklal on mt.c4 = dklal.sellusername
    where c1='��ٻ���Ʒ����_��Ʒ�����˺�0530'
    order by ori_number_old
)

,numbered_persons as ( -- ��Աÿ��Ԥ���
 SELECT *
    ,CEILING(sort/2) pre_assign_num
    , case when mod(ROW_NUMBER () over (order by sort), 2) = 1 then '��Ʒ�״η���' else '��Ʒ���η���' end isFirstTime
    -- 1�������������ˣ�2���������4����
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
    -- �ڶ��� �ֶ�����������־��������Ա��������  -- С��60��SPU��ֻ�����������
    select * , row_number() over (order by ori_number_old ) as sort from last_time_log mt
    join ( select distinct sellusername  from dep_kbh_listing_assignment_log
        where pushtype = '��Ʒ�ؿ�' and SellUserName regexp 'ʯ���|����ң'
        ) dklal  on mt.sellusername = dklal. sellusername
    where c1='��ٻ���Ʒ����_��Ʒ�����˺�0530'
    */
	 ) tmp 
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
	'${NextStartDay}' ,s.SPU ,s.SKU  ,s.SellUserName  ,m.shopcode as push_shopcode ,s.DevelopLastAuditTime ,s.ProductName  ,'��Ʒ�ؿ�' ,isFirstTime
	,grouped_num ,s.cat1, s.cat2 ,0 ,now()
from spu2person s
left join mark_top_shop m on s.main_pack_cat1 = m.cat1 and s.sellusername = m.seller;








-- ������Ʒ�ؿ�������־��
select dklal.SPU ,dklal.SKU  ,epp.boxsku  ,dklal.ProductName ,wp.CategoryPathByChineseName , wp.PackageWeight ,wp.Logistics_Attr 
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as  `��Ʒ״̬`
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
left join ( -- Ԫ��ӳ�����С������ SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on dklal.sku =t_elem .sku
where  PushType = '��Ʒ�ؿ�'
ORDER BY PushDate DESC ,SpuPackNumb ASC ,SPU


/*
 ��Ʒ�ؿ� ����ʵ�ַ����� ��SPU�ֵ��˺���
һ��һ����Ŀ�֣����ȷֹ������ > ����
�˺���Ŀѡ��ʽ ��3��1���������۶
1����Ӧ�˺ŵ��Ĵ���Ŀ֮һҵ��/���˺���ҵ��=���˺���Ŀҵ��ռ��
2��ȡ������������˺���Ŀҵ��ռ�ȡ�ǰ6���˺ţ�����ʱ��9���˺ţ����ְ���10���˺ţ�ʣ�¼Ҿ�����


 1 ÿ���˺ŵ��Ĵ���Ŀ��ҵ��



 */
-- ������Ʒ�ؿ�����


-- insert into dep_kbh_listing_assignment_log (PushDate, SPU, SKU, SellUserName, push_shop, DevelopLastAuditTime, ProductName, PushType, SpuPackNumb, Cat1 ,Cat2, IsDeleted, Updatetime)
with
pre_grouped_products AS ( -- 01 ������Ʒ�ؿ���
select * from (
	select epp.spu,epp.sku,DevelopLastAuditTime ,epp.ProductName , cat1
		,case
		    when DevelopLastAuditTime < '2023-04-01' and kbh_cd_online_code > 0  and kbh_cd_online_code < 3 and kbh_online_code < 6 then 1
			when DevelopLastAuditTime >= '2023-04-01'   and kbh_cd_online_code < 3 then 1  -- 23��4���������Ʒ���ɶ���3�ף����ɷ���
			else 0 end as unlimit
        ,case when  date_add(DevelopLastAuditTime,interval -8 hour) >= date_add(current_date(),interval - 30 day) then '��30������' end as '��30��������'
	    ,case when saleIn30d_over_500_sku is not null then '��30��ɶ������˷����۶����500usd' end as '�ɶ���������'
	    ,ele_name  as '�����Ʒ���'
	    ,kbh_online_code as '��ٻ������˺�����'
	    ,kbh_cd_online_code  as '��ٻ��ɶ������˺�����'
	    ,kbh_qz_online_code  as '��ٻ�Ȫ�������˺�����'
	from ( -- 7��ǰ�����ͣ����Ʒ��Ϣ
	    select SPU,SKU
	    	,date(date_add(DevelopLastAuditTime,interval -8 hour)) DevelopLastAuditTime
	    	,ProductName
	    	,split(CategoryPathByChineseName, '>')[1] as cat1
	    	,pruc
	    from erp_product_products epp -- ʹ��ʵʱ��,�������������
	    left join erp_product_product_category ppc on ppc.id = epp.ProductCategoryId
	    where ismatrix = 0 and productstatus != 2  and projectteam = '��ٻ�'
	    	and date_add(DevelopLastAuditTime,interval -8 hour) < date_add(current_date(),interval - 7 day)
	    ) epp
	left join (select spu from erp_product_products where ismatrix = 0 and status != 10 group by spu ) unfinished on epp.spu = unfinished.spu-- ���д���δ������ɵ�SPU
	join (select sku ,LastPurchasePrice from import_data.wt_products
	    where LastPurchasePrice >= 5 -- �ɹ��ۣ�5 �ݲ�����
	    and cat1 regexp 'A3' -- ֻ��A3��Ŀ
	) t on t.sku = epp.sku
	left join ( -- �����˺���
		select sku ,count(distinct ms.CompanyCode) kbh_online_code
		     ,count(distinct case when nodepathname regexp '�ɶ�' then ms.CompanyCode end) kbh_cd_online_code
		     ,count(distinct case when nodepathname regexp 'Ȫ��' then ms.CompanyCode end) kbh_qz_online_code
		from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.code and department ='��ٻ�' and ms.shopstatus = '����' and eaal.listingstatus = 1
		group by sku
		) eaal on epp.sku = eaal.sku
	join ( -- ��3���г���
		select product_sku as sku
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code where isdeleted = 0 and paytime > date_add(current_date(),interval - 3 month) and ms.department regexp '��'
		group by product_sku
		) wo on epp.sku = wo.sku
	left join ( -- 23����ǰ��������23��δ������spu
		select wp.spu
		from wt_products wp
		left join import_data.wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code
		where wp.isdeleted = 0 and paytime > '2023-01-01' and ms.department regexp '��' and wp.DevelopLastAuditTime < '2023-01-01' and wo.isdeleted =
		group by wp.spu having count( distinct platordernumber ) = 0
		) old_prod_nosale_in23 on epp.spu = old_prod_nosale_in23.spu
	left join ( -- ��30�� �Ҳ����˷���������۶����500����
		select product_sku as saleIn30d_over_500_sku
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode=ms.Code
		where isdeleted = 0 and paytime > date_add( current_date(),interval - 30 day )
	        and TransactionType <> '����'  and asin <>''  and wo.boxsku<>'' and ms.department regexp '��'  and  NodePathName regexp '�ɶ�'
		group by product_sku having sum((TotalGross-FeeGross)/ExchangeUSD) >= 500
		) wo30  on epp.sku = wo30.saleIn30d_over_500_sku
	left join ( select spu ,group_concat(Name) ele_name-- ����
	    from ( select spu ,eppea.Name
            from import_data.erp_product_product_associated_element_attributes eppaea
            left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
            where eppea.name = '�ļ�' group by spu ,eppea.Name ) t group by spu
        ) tag on epp.spu = tag.spu
/*
	left join (select distinct sku from dep_kbh_listing_assignment_log
		where PushDate >= date_add(current_date(),interval - 7 day) -- ��7�������־
		) dkla on epp.sku = dkla.sku
	where dkla.sku is null -- ��1��δ���俯��

 */
	) tmp
where unlimit = 1 and unfinished.spu is not null
    and old_prod_nosale_in23.spu is null  -- 23����ǰ��������23��δ������SPU������
)

-- ���SPU���Ƿ������ڿ����е���
select
from erp_product_products join (select distinct spu from pre_grouped_products )

,black_lists as ( -- �����һ��ɸѡ�Ĳ�Ʒ�ҳ�Ŀǰ���ߣ�SKU�������˺ż���Ӧҵ��Ա���������в����ٳ��ִ����ϵ sku+CompanyCode, sku+seller
select eaal.SKU ,CompanyCode ,SellUserName
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.shopcode = ms.code and ms.shopstatus = '����' and eaal.listingstatus = 1
join pre_grouped_products pgp on eaal.sku = pgp.sku
group by eaal.SKU ,CompanyCode ,SellUserName
)

,white_lists_1 as (  -- ������01 ����м�¼�õ��ɿ��ǵ��̼�¼�����޳����к�������¼��SKU�����ߵ��̼���Ӧҵ��Ա��
select tc.*
from (
	select pgp.* , tb.CompanyCode ,tb.SellUserName , tb.explode_sales_in3m
	from pre_grouped_products pgp
	join (  -- ����ͬһ����Ŀ�£���ͬshopcode�ļ�¼����ͳ����Ŀx����ά���µĽ�3�����۶�
		select cat1 ,CompanyCode ,SellUserName ,round(sum(totalgross/exchangeusd)) explode_sales_in3m
		from wt_orderdetails wo
		join mysql_store ms on wo.shopcode = ms.Code and ms.ShopStatus = '����' and ms.department = '��ٻ�' and nodepathname regexp '�ɶ�'
		join (select distinct sku ,cat1 from pre_grouped_products ) wp on wp.sku =wo.Product_Sku
		where paytime >= date_add('${NextStartDay}',interval - 3 month) and PayTime < '${NextStartDay}' and wo.isdeleted = 0
			and ms.SellUserName is not null
		group by cat1 ,CompanyCode ,SellUserName
		) tb on pgp.cat1 = tb.cat1
	) tc
left join black_lists bl1 on tc.sku = bl1.sku and tc.CompanyCode = bl1.CompanyCode
left join black_lists bl2 on tc.sku = bl2.sku and tc.SellUserName = bl2.SellUserName
where bl1.sku is null -- �޳��������е� SKU+���̹�ϵ
	and bl2.sku is null -- �޳��������е� SKU+������Ա��ϵ
)
-- select * from white_lists_1
-- select count(distinct sku) from white_lists_1

,white_lists_2 as ( -- ������02 ����������,����ÿ��SKU������Ŀ�µ�top10�˺�
select *
from ( -- sku������Ŀ�µĵ���ҵ������
    select *, ROW_NUMBER() over ( partition by cat1,sku order by explode_sales_in3m desc ) top_companycode_sort
    from white_lists_1) ta
where top_companycode_sort <= 10
)
-- select * from white_lists_2;

,white_lists_3 AS ( --  ������03��������Ŀ���е�����
-- �ڰ���������ҵ��TOP10����ʱ���൱���Ѿ��Ե���ҵ�����ȼ����˴���
    select wl.*, cat2, DENSE_RANK() over ( order by cat2 ) spu_priority
    from white_lists_2 wl
    left join ( -- ���Ӷ�����Ŀ�����������з���ͬһ��
       select distinct spu ,cat2 from wt_products ) te on wl.spu = te.spu
order by spu_priority ,spu
)

select spu ,sku ,cat1 `����һ����Ŀ` ,`��ٻ������˺�����` ,`��ٻ��ɶ������˺�����` ,`��ٻ�Ȫ�������˺�����` , CompanyCode `�ɿ����˺�` , SellUserName `�ɿ�����ѡҵ����Ա` ,explode_sales_in3m `����Ŀx�˺�xҵ��Ա��3�����۶�`
    ,DevelopLastAuditTime `��Ʒ��������`
    ,left(DevelopLastAuditTime,7) `��Ʒ�����·�`
    ,��30�������� ,�ɶ��������� ,�����Ʒ��� ,cat2 `������Ŀ`
from white_lists_3 order by  `��Ʒ��������`;



-- ��spu���� ��һ˳λԱ�������а�����������Ŀ���е�ǰ���£�ȡtop30��SPU
select  '${NextStartDay}' , spu ,sku ,SellUserName ,CompanyCode as push_shop ,DevelopLastAuditTime ,ProductName
	, '��Ʒ�ؿ�',grouped_num ,cat1 ,cat2 ,0 ,now()
from (select dense_rank() over (order by concat(spu_priority, spu) ) grouped_num, *
      from white_lists_3
      where SellUserName = '�����'
        and CompanyCode = 'RN'
     ) t
where grouped_num <= 30;

-- ��code���� 
select  '${NextStartDay}' , spu ,sku ,SellUserName ,CompanyCode as push_shop ,DevelopLastAuditTime ,ProductName
	        , '��Ʒ�ؿ�',grouped_num ,cat1,cat2 ,0  ,now()
from (select dense_rank() over (order by concat(spu_priority, spu) ) grouped_num, *
  from white_lists_3
  where SellUserName = '${person}'
    and CompanyCode in ('${CompanyCode_1}','${CompanyCode_2}') 
) t









-- ,numbered_persons as ( -- ȷ��������Ҫ���������ҵ��Ա��Ԥ���
-- 	select  ms.*  ,ROW_NUMBER () over (order by ms.sellusername) pre_assign_num -- 1��SPU�ָ�ͬһ����
-- 	from( select distinct sellusername from mysql_store ms where department= '��ٻ�' and NodePathName regexp '�ɶ�' and shopstatus = '����') ms
-- 	-- ����ֱ�Ӵӵ��̱�ȡ Ҫ�Ӱ�����ȡ 
-- 	left join ( -- �޳���һ���衰��Ʒ�ؿ��������ѷ�����Ա
--         select distinct SellUserName from dep_kbh_listing_assignment_log
--         where PushDate = (select max(PushDate) from dep_kbh_listing_assignment_log ) -- ����Ʒ�ؿ�����ִ�к�ִ��
--         ) dkla on ms.SellUserName = dkla.sellusername
--     where dkla.SellUserName is null
-- )
-- -- select * from numbered_persons;
-- 
-- ,grouped_products_1 AS ( --  ��Ʒ�ؿ��������01��������spu�������ȼ����� ��Ŀ����
-- -- �ڰ���������ҵ��TOP10����ʱ���൱���Ѿ��Ե���ҵ�����ȼ����˴���
-- select spu ,sku ,DevelopLastAuditTime ,ProductName ,cat1 , cat2 ,SellUserName  ,spu_priority
-- from (
--     select wl.*
--          , cat2
--          , DENSE_RANK() over ( order by cat2 ) spu_priority
--     from white_lists_2 wl
--     left join ( -- ���Ӷ�����Ŀ�����������з���ͬһ��
--        select distinct spu ,cat2 from wt_products ) te on wl.spu = te.spu
--     ) ta
-- group by spu ,sku ,DevelopLastAuditTime ,ProductName ,cat1 , cat2 ,spu_priority
-- order by spu_priority ,spu
-- )
-- -- select * from grouped_products_1;
-- 
-- 
-- -- �����SPU����Ų���ֱ�ӷ���30��
-- ,grouped_products_2 AS ( -- ��Ʒ�ؿ��������02�� ��SPU������,���ڡ�SPU����š��롰�˱�š�һһ��Ӧ
-- select  *,(spu_priority-1) div 30 + 1  as grouped_num
-- from  grouped_products_1
-- )
-- select * from grouped_products_2;
-- 
-- ,spu2person as ( -- ��Ʒ�ֵ��� ,������12�˲�����Ʒ�ؿ�����,��˴ӿ��ǰ��������ҵ� 12*30��spu
-- select gp.*  ,np.*
-- from grouped_products_2 gp
-- join numbered_persons np on gp.grouped_num = np.pre_assign_num
-- order by grouped_num ,spu
-- )
-- -- select * from spu2person order by grouped_num ,sku;
-- 
-- ,person2shop_1 as ( -- ���ڿɿ����б�, �����Ƽ������嵥����ҵ��Ա���SPU��Ӧ�ü����ϵ��ĸ�����
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
-- select  spu ,sku ,DevelopLastAuditTime ,ProductName,SellUserName ,push_shop ,'${NextStartDay}' ,'��Ʒ�ؿ�',now()  from person2shop_2 order by grouped_num ,sku;
-- 
-- select * from dep_kbh_listing_assignment_log dklal 