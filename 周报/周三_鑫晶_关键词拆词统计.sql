

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

,same_word as ( -- UKUS ��ͬ������
select t_us.searchword 
from ( select distinct searchword from tb where site = 'US') t_us 
join ( select distinct searchword from tb where site = 'UK') t_uk
on t_us.searchword = t_uk.searchword 
)

,res as (
select 
	t_aba.word `����`
	, `��Ƶ`
	,t_aba.site `վ��`
	,t_aba.searchword `������`
	,cat1
	,cat2
	,cat3
	,searchrank `��������`
	,tb_w1.searchrank_w1 `��������`
	,tb_w2.searchrank_w2 `����������`
	,searchrank - tb_w1.searchrank_w1 `����-��������`
	,tb_w1.searchrank_w1 - tb_w2.searchrank_w2 `����-����������`
	,same_word.searchword  `USUK��ͬ������`
	
-- 	,asin1 `#1 asin`
-- 	,clickrate1 `#1 �������`
-- 	,cr1 `#1 ת������`
-- 	,asin2 `#2 asin`
-- 	,clickrate2 `#2 �������`
-- 	,cr2 `#2 ת������`
-- 	,asin3 `#3 asin`
-- 	,clickrate3 `#3 �������`
-- 	,cr3 `#3 ת������`
from t_aba 
left join t_blackword on t_aba.word = t_blackword.word
left join 
	(  
	select word ,site ,count(1) ��Ƶ
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
select `����` 
	,avg(`��Ƶ`) ��Ƶ
	,count( distinct case when `����-��������` > 0 then `������` end )  `�½������������`
	,count( distinct case when `����-��������` < 0 then `������` end )  `���������������`
	,round( count( distinct case when `����-��������` < 0 then `������` end )
		/count( distinct case when `����-��������` > 0 then `������` end ) ,4) `����/�½�`
from res
group by ����
)


-- ��ʱ�
 select *
 	,case 
 		when `��������` <= 10000 and `����-��������` < -1000 and (`����-����������` <0 or `����������` is null) then 'Top1w_�ұ���������1000��_������������'
 		when `��������` <= 20000 and `����-��������` < -2000 and (`����-����������` <0 or `����������` is null) then 'Top2w_�ұ���������2000��_������������'
 		when `��������` is null then '����������'
 	end as `������ɸѡ����`
 from res order by ��Ƶ desc ,����
 


