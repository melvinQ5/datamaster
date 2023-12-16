-- ���󱳾���ͩͩ����ERPͼ�� ��Ʒ������ĵ�������ʷ���ݣ����ڴ������ֶ�͸�ӣ�excel������

-- python ͸��
-- df_1 = pd.pivot_table(df,index=[u'BoxSku'],columns=[u'week'],values=[u'���������',u'��������',u'�����',u'����',u'���۶�',],aggfunc=[np.sum],fill_value=0,margins=1)

-- SQL��ѯ
select 
	year ,week ,BoxSku
	,sum(����) ����
	,sum(���۶�) ���۶�
	,sum(�����) �����
	,sum(weekly_order_days) ��������
	,max(����) ���������
from (
select  year `year`
       ,week_num_in_year `week`
       ,date(PayTime) pay_date
       ,od.BoxSku
       ,sum(SaleCount) '����'
       ,round(sum(TotalGross/ExchangeUSD),4) '���۶�'
       ,round(sum(TotalProfit/ExchangeUSD),4) '�����'
       ,count(distinct date(PayTime)) `weekly_order_days`
from wt_orderdetails od
inner join dim_date da
on date(od.PayTime)=da.full_date
inner join mysql_store s
on od.shopcode=s.Code
where od.PayTime>='2023-01-01'
and od.PayTime<'${EndDay}'
and s.Department = '��ٻ�'
and od.BoxSku<>''
and IsDeleted=0
and OrderStatus<>'����'
and TransactionType<>'����'   -- �������Ͳ�Ϊ����
group by year,week_num_in_year ,date(PayTime) ,od.BoxSku
order by year,week_num_in_year desc
) tmp  
where boxsku = 1000722 and week = 21
group by year ,week ,BoxSku
order by year ,week ,BoxSku