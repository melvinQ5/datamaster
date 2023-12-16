
select '6�¿�ٻ�' ͳ�Ʒ�Χ ,round(a_gen_in2d/b_gen_in2d,4) `2��������`
	,round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	from
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1



select '6�¿�ٻ�������' ͳ�Ʒ�Χ , round(a_gen_in2d/b_gen_in2d,4) `������2��������`
	,round(a_deliv_in5d/b_deliv_in5d,4) `�������5�췢����`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	from
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����'
		join ( select spu from import_data.dep_kbh_product_level  where Department = '��ٻ�'  and prod_level regexp '����|����' group by spu ) dkpl on dkpl.SPU = wo.Product_SPU
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1