select GenerateDate from wt_adserving_amazon_daily where sku is null group by GenerateDate order by GenerateDate desc

-- todo 临时取 shopcode + sellersku 最早刊登时间的 sku 作为关联关系。

-- 检测广告表是否成功
select '2.1【wt_adserving_amazon_daily】',abs(t1.点击数-t2.点击数),abs(t1.广告花费-t2.广告花费) from
(
select '广告' as team,sum(AdClicks) '点击数',sum(AdSpend) '广告花费' from wt_adserving_amazon_daily
where GenerateDate>=date_add(current_date(),interval -91 day)
) t1
left join
(
select '广告' as team,sum(Clicks) '点击数',sum(Spend) '广告花费' from AdServing_Amazon
where Asin<>'') t2
on t1.team=t2.team
