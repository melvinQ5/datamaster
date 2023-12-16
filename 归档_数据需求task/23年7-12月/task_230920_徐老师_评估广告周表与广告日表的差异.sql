-- 订单表
select distinct  shopcode ,Department from wt_orderdetails where IsDeleted = 0
-- 店铺表
select distinct Code,Department from mysql_store


-- 店铺+渠道SKU维度 的数量差
select a.Week ,周_店铺_渠道SKU数 ,日_店铺_渠道SKU数 ,周_店铺_渠道SKU数 - 日_店铺_渠道SKU数 as 链接数量差
    ,周_广告花费 ,日_广告花费 ,round(周_广告花费  - 日_广告花费) as 花费差
    ,周_曝光 ,日_曝光 ,round(周_曝光  - 日_曝光) as 曝光差

from  (
select week
     ,count(distinct concat(ShopCode,SellerSku))  周_店铺_渠道SKU数
     ,round(sum(AdSpend),2) 周_广告花费
     ,round(sum(AdExposure),2) 周_曝光
     ,round(sum(AdClicks),2) 周_点击
from wt_adserving_amazon_weekly where year = 2023 and week >= 24 group by week order by week
) a
left join (
select weekofyear(GenerateDate) as week
     ,count(distinct concat(ShopCode,SellerSku))  日_店铺_渠道SKU数
    ,round(sum(AdSpend),2) 日_广告花费
    ,round(sum(AdExposure),2) 日_曝光
    ,round(sum(AdClicks),2) 日_点击
from wt_adserving_amazon_daily wa
where GenerateDate >= '2023-06-26' group by week order by week
) b
on a.Week = b.week
order by a.Week
