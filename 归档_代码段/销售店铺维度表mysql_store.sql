-- 最新代码 0728
insert into mysql_store
select count(1) from (


select s.id platformid,platform ,
       case when platform='eBay' then right(irobotname,10)
            when platform='Wayfair' or platform='Walmart' then left(s.code,2)
            else s.code end 'code'
        ,s.irobotname,if(p.content = '跟帖', 'GM', 'PM') StoreOperateMode,c.LevelName level ,
       s.site,case s.shopstatus when 0 then '准备中' when 1 then '正常' when 2 then '异常' when 3 then '弃用' when 4 then '休假中' when 5 then '关闭' else '未知' end ShopStatus,d.name NodePathName,
       null PlatformTeamName, SellUserName, d.nodepathname NodePathNameFull,
       s.accountcode,
       split(s.accountcode,'-')[1], split(s.accountcode,'-')[2],
       if(array_length(split(d.nodepathname,'>')) = 1, d.nodepathname, split(d.nodepathname,'>')[1]) Department,
       now() SyncTime from erp_user_user_platform_account_sites s
                               left join erp_user_user_channel_account_levels c on s.ChannelAccountLevelId=c.Id
                               left join erp_user_user_departments d on s.DepartmentId=d.Id
                                                                            and IsEnable = 1
                               left join erp_user_user_channel_account_purposes p on p.id = s.ChannelAccountPurposeId
                               left join erp_user_user_shop_sells uss on uss.accountsitesid = s.id  and uss.isfirstsell = 1
where NodePathName regexp '特卖汇|快百货|MRO孵化部|商厨汇'
  and nodepathname not regexp '泉州公用部门'

  ) t

select count(1) from mysql_store


-- 检查
select  d.id as departmentid ,
        s.id platformid,platform ,
       case when platform='eBay' then right(irobotname,10)
            when platform='Wayfair' or platform='Walmart' then left(s.code,2)
            else s.code end 'code'
        ,s.irobotname,if(p.content = '跟帖', 'GM', 'PM') StoreOperateMode,c.LevelName level ,
       s.site
       ,case s.shopstatus when 0 then '准备中' when 1 then '正常' when 2 then '异常' when 3 then '弃用'
   		when 4 then '休假中' when 5 then '关闭' else '未知' end ShopStatus
       ,d.name NodePathName,
       null PlatformTeamName, SellUserName, d.nodepathname NodePathNameFull,
       s.accountcode,
       split(s.accountcode,'-')[1], split(s.accountcode,'-')[2],
       if(array_length(split(d.nodepathname,'>')) = 1, d.nodepathname, split(d.nodepathname,'>')[1]) Department,
       now() SyncTime from erp_user_user_platform_account_sites s
                               left join erp_user_user_channel_account_levels c on s.ChannelAccountLevelId=c.Id
                               left join erp_user_user_departments d on s.DepartmentId=d.Id
                                                                            and d.IsEnable = 1
                               left join erp_user_user_channel_account_purposes p on p.id = s.ChannelAccountPurposeId
                               left join erp_user_user_shop_sells uss on uss.accountsitesid = s.id  and uss.isfirstsell = 1 and Status =1
where NodePathName regexp '快百货'
  and nodepathname not regexp '泉州公用部门'


-- 店铺
select *
from erp_user_user_departments where IsEnable = 1 and NodePathName regexp '快'
                                 and id ='3a09272d-1c6f-22de-769b-814f25503345'

select d.NodePathName ,d.id as Department_Id ,s.DepartmentId ,s.Code
from erp_user_user_platform_account_sites s
left join erp_user_user_departments d on s.DepartmentId=d.Id  and d.IsEnable = 1
where NodePathName regexp '快百货' and Code in ('B203-PL','A21-FR')


select s.id platformid,platform ,
       case when platform='eBay' then right(irobotname,10)
            when platform='Wayfair' or platform='Walmart' then left(s.code,2)
            else s.code end 'code'
        ,s.irobotname,if(p.content = '跟帖', 'GM', 'PM') StoreOperateMode,c.LevelName level ,
       s.site,case s.shopstatus when 0 then '准备中' when 1 then '正常' when 2 then '异常' when 3 then '弃用' when 4 then '休假中' when 5 then '关闭' else '未知' end ShopStatus,d.name NodePathName,
       null PlatformTeamName, SellUserName, d.nodepathname NodePathNameFull,
       s.accountcode,
       split(s.accountcode,'-')[1], split(s.accountcode,'-')[2],
       if(array_length(split(d.nodepathname,'>')) = 1, d.nodepathname, split(d.nodepathname,'>')[1]) Department,
       now() SyncTime from erp_user_user_platform_account_sites s
                               left join erp_user_user_channel_account_levels c on s.ChannelAccountLevelId=c.Id
                               left join erp_user_user_departments d on s.DepartmentId=d.Id
                               left join erp_user_user_channel_account_purposes p on p.id = s.ChannelAccountPurposeId
                               left join erp_user_user_shop_sells uss on uss.accountsitesid = s.id  and uss.isfirstsell = 1
where NodePathName regexp '特卖汇|快百货|木工汇|商厨汇' and SellUserName='石金凤'
  and nodepathname not regexp '泉州公用部门';

select uss.SellUserName ,d.NodePathName
from erp_user_user_platform_account_sites s
left join erp_user_user_departments d on s.DepartmentId=d.Id
left join erp_user_user_shop_sells uss on uss.accountsitesid = s.id  and uss.isfirstsell = 1  and Status =1
where NodePathName regexp '特卖汇|快百货|木工汇|商厨汇' and SellUserName='石金凤'


insert into mysql_store
select s.id platformid,platform ,
       case when platform='eBay' then right(irobotname,10)
            when platform='Wayfair' or platform='Walmart' then left(s.code,2)
            else s.code end 'code'
        ,s.irobotname,if(p.content = '跟帖', 'GM', 'PM') StoreOperateMode,c.LevelName level ,
       s.site,case s.shopstatus when 0 then '准备中' when 1 then '正常' when 2 then '异常' when 3 then '弃用' when 4 then '休假中' when 5 then '关闭' else '未知' end ShopStatus,d.name NodePathName,
       null PlatformTeamName, SellUserName, d.nodepathname NodePathNameFull,
       s.accountcode,
       split(s.accountcode,'-')[1], split(s.accountcode,'-')[2],
       if(array_length(split(d.nodepathname,'>')) = 1, d.nodepathname, split(d.nodepathname,'>')[1]) Department,
       now() SyncTime from erp_user_user_platform_account_sites s
                               left join erp_user_user_channel_account_levels c on s.ChannelAccountLevelId=c.Id
                               left join erp_user_user_departments d on s.DepartmentId=d.Id
                               left join erp_user_user_channel_account_purposes p on p.id = s.ChannelAccountPurposeId
                               left join erp_user_user_shop_sells uss on uss.accountsitesid = s.id  and uss.isfirstsell = 1   and Status =1
  and nodepathname not regexp '泉州公用部门';