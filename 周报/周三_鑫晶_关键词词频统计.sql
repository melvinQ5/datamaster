-- monday = 

with 
tb as ( 
select *,split(searchword,' ') words 
from ABA a 
where monday = '${StartDay}' and site regexp 'US|UK|DE'
	and searchrank <= 20000
)


,t_aba as (
select * from (
	select * ,unnest as word
	from tb,unnest(words)
	) tmp 
where length(word)>1 and word REGEXP '^[a-zA-Z]'
)
-- select * from t_aba


,blackword as (
select ['for','women','womens','man','men','mens','and','the','with','of'
	,'to','in','on','up','under','set','mini','pro','inch','max'
	,'aa' ,'aaa' ,'bb' ,'zz'
	] blackwords
)

,t_blackword as (
select unnest as word 
	from blackword ,unnest(blackwords)
)

,same_word as ( -- UKUS 相同搜索词
select t_us.searchword 
from ( select distinct searchword from tb where site = 'US') t_us 
join ( select distinct searchword from tb where site = 'UK') t_uk
on t_us.searchword = t_uk.searchword 
)

,res as (
select 
	t_aba.word `单词`
	, `词频`
	,t_aba.site `站点`
	,t_aba.searchword `搜索词`
	,cat1
	,cat2
	,cat3
	,searchrank `本周排名`
	,tb_w1.searchrank_w1 `上周排名`
	,tb_w2.searchrank_w2 `上上周排名`
	,searchrank - tb_w1.searchrank_w1 `本周-上周排名`
	,tb_w1.searchrank_w1 - tb_w2.searchrank_w2 `上周-上上周排名`
	,same_word.searchword  `USUK相同搜索词`
	
-- 	,asin1 `#1 asin`
-- 	,clickrate1 `#1 点击共享`
-- 	,cr1 `#1 转化共享`
-- 	,asin2 `#2 asin`
-- 	,clickrate2 `#2 点击共享`
-- 	,cr2 `#2 转化共享`
-- 	,asin3 `#3 asin`
-- 	,clickrate3 `#3 点击共享`
-- 	,cr3 `#3 转化共享`
from t_aba 
left join t_blackword on t_aba.word = t_blackword.word
left join 
	(  
	select word ,site ,count(1) 词频
	from t_aba group by word ,site
	) t_word on t_aba.word  = t_word.word and t_aba.site = t_word.site
left join 
	 ( --  WEEK-1
	select searchword ,searchrank as searchrank_w1 ,site 
	from ABA a 
	where monday = date_add('${StartDay}',interval -1 week ) and site regexp 'US|UK|DE'
	) tb_w1
	on t_aba.searchword = tb_w1.searchword and t_aba.site = tb_w1.site 
left join 
	( --  WEEK-2
	select searchword ,searchrank as searchrank_w2 ,site 
	from ABA a 
	where monday = date_add('${StartDay}',interval -2 week ) and site regexp 'US|UK|DE'
	) tb_w2
	on t_aba.searchword = tb_w2.searchword  and t_aba.site = tb_w2.site 
left join same_word on  t_aba.searchword = same_word.searchword 
where t_blackword.word is null 
) 

,res2 as (
select 
	`站点`
	,`单词` 
	,avg(`词频`) 词频
	,count( distinct case when `本周-上周排名` > 0 then `搜索词` end )  `下降搜索词组合数`
	,count( distinct case when `本周-上周排名` < 0 then `搜索词` end )  `上升搜索词组合数`
	,round( count( distinct case when `本周-上周排名` < 0 then `搜索词` end )
		/count( distinct case when `本周-上周排名` > 0 then `搜索词` end ) ,4) `上升/下降`
from res
group by `站点`,单词
)


-- 词频统计表
select 
	 * 
	,case when `上升/下降` > 2 and `词频` >= 20 then '升降比大于2且词频达20以上'
		when `下降搜索词组合数` = 0 and `上升搜索词组合数` > 0 and `词频` >= 10 then '全上升且词频达10以上'
	end `单词筛选方案`
from res2  order by 词频 desc
