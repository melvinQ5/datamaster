-- 同步数据
INSERT INTO dws_cust_register_day(
channel_key,channel_1,channel_2,channel_3,
staff_id,staff_name,staff_dep,
day30_count,day7_count,day1_count)
SELECT
    jd.channel_key,channel_1,channel_2,channel_3,
    staff_id,staff_name,staff_dep,
    count(distinct customer_key) day30_count,
    count(if(datediff('2018-03-31',jd.create_jd_time)<6,customer_key,null)) day7_count,
    count(if(datediff('2018-03-31',jd.create_jd_time)=1,customer_key,null)) day1_count
FROM dwd_jiandang jd
		LEFT JOIN dim_channel ch on jd.channel_key = ch.channel_key
    LEFT JOIN dim_staff st on jd.staff_key = st.staff_key
where create_jd_time between '2018-03-02' and '2018-03-31'
group by jd.channel_key,channel_1,channel_2,channel_3,
staff_id,staff_name,staff_dep


/*
DWS
    cube;
    dws_cust_register_cal 轻度汇总：
    对每天分组，求每天+每员工（分12级）+每个渠道（分123级）+每个项目（分123级）的建档人数（新增）

ADS 指标建模：
    计算每天+每个渠道（分123级）+每个员工（分12级）的三个指标
*/
set @task_day:= '2018-3-31'; 

INSERT INTO dws_cust_register_cal(
register_date,
channel_1,channel_2,channel_3,
staff_id,staff_name,staff_dep,
product_1,product_2,product_3,product_des,
register_count)

SELECT
    DATE_FORMAT(create_jd_time,"%Y-%m-%d") AS create_jd_DATE,
		channel_1,channel_2,channel_3,
    staff_id,staff_name,staff_dep,
		product_1,product_2,product_3,product_des,
    count(distinct customer_key) register_count
FROM dwd_jiandang jd
		LEFT JOIN dim_channel ch on jd.channel_key = ch.channel_key
    LEFT JOIN dim_staff st on jd.staff_key = st.staff_key
		LEFT JOIN dim_product pd on jd.product_key = pd.product_key 
WHERE create_jd_time between '2018-03-01' and @task_day
GROUP BY 
	create_jd_DATE,
	channel_1,channel_2,channel_3,
	staff_dep,staff_id,staff_name,
	product_1,product_2,product_3,product_des