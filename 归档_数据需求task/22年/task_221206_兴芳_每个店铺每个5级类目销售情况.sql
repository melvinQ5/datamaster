-- 1���ǵ���ά�ȣ�����ÿ�����̵���Ŀ���ݣ��������ֶ�
-- ����Դ����  ��Ŀ�����ڵ���5����5������С��5�������е���һ��������һ�������ݣ�  SKU��  ����SKU��  ��������  ����������  SKU������  ���Ӷ�����  ҵ��  ë��  ������  ����  �����·�  �˿
--  �������ݶ���Ҫ2022�꣬���۶����������������˺ż������������


select a1.AccountCode `����_�г�`, a1.NodePathNameFull `����С��`, a1.categ_5 `��Ŀ(��ఴ5��ͳ��)`,������SKU��,a3.����SKU��, round(������SKU��/a3.����SKU��,2) `SKU������`
	, ������������,a3.����������, round(������������/a3.����������,2) `���Ӷ�����` , round(ҵ��,2)`ҵ��`, round(ë��,2)`ë��`, ������, ����, �˿�,a2.�����·� 
from
	(select s.AccountCode,s.NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5,
	count(distinct od.BoxSku ) '������SKU��',
	count(distinct concat(SellerSku,ShopIrobotId)) '������������',
	sum(InCome)/7.218 'ҵ��',sum(GrossProfit)/7.218 'ë��',
	round(sum(GrossProfit)/sum(InCome),4) '������',count(distinct PlatOrderNumber) '����',sum(RefundPrice) '�˿�' 
	from import_data.OrderProfitSettle od
	inner join wt_products pp
	on od.BoxSku=pp.BoxSku
	inner join mysql_store s
	on od.ShopIrobotId=s.Code
	and s.Department in ('���۶���','��������')
	where PayTime>='2022-01-01'
	and PayTime<'2022-12-01'
	and od.OrderNumber not in
		(
		select OrderNumber from (
		SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
		where
		ShipmentStatus = 'δ����' and OrderStatus = '����'
		and PayTime >= '2022-01-01' and PayTime <'2022-12-01'
		group by OrderNumber
		) a
		where alltype = '����'
		)
	group by s.AccountCode
		,s.NodePathNameFull
		,concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
			,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) 
	) a1

left join 
(
	select t.AccountCode,t.NodePathNameFull,categ_5,group_concat(concat(t.�����·�,'')) `�����·�` 
	from
		(select a.AccountCode,a.NodePathNameFull,a.�����·�, categ_5
		from
			(select s.AccountCode,s.NodePathNameFull
				,concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
					,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5
				, month(PayTime) '�����·�'
			from OrderProfitSettle od
			inner join wt_products pp
			on od.BoxSku=pp.BoxSku
			inner join mysql_store s
			on od.ShopIrobotId=s.Code
			and s.Department in ('���۶���','��������')
			where PayTime>='2022-01-01'
			and PayTime<'2022-12-01'
			and od.OrderNumber not in
				(
				select OrderNumber from (
				SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
				where
				ShipmentStatus = 'δ����' and OrderStatus = '����'
				and PayTime >= '2022-01-01' and PayTime <'2022-12-01'
				group by OrderNumber
				) a
			where alltype = '����'
			)) a
		group by a.AccountCode ,a.NodePathNameFull ,categ_5 ,a.�����·�
		order by a.AccountCode ,a.NodePathNameFull ,categ_5 ,a.�����·� 
		) t
	group by t.AccountCode,t.NodePathNameFull,categ_5
) a2
on a1.AccountCode=a2.AccountCode and a1.categ_5 =a2.categ_5 and a1.NodePathNameFull=a2.NodePathNameFull

left join
(
/*SKU������������*/
select AccountCode,NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) categ_5,
	count(distinct al.SKU) '����SKU��',count(distinct concat(SellerSku,ShopCode)) '����������' 
from wt_products pp
inner join erp_amazon_amazon_listing al
on pp.Sku=al.SKU and al.ListingStatus = 1
and al.SKU<>''
inner join mysql_store s
on al.ShopCode=s.Code and s.ShopStatus ='����'
and Department in ('���۶���','��������')
group by AccountCode,NodePathNameFull,
	concat(ifnull(split_part(pp.CategoryPathByChineseName,'>',1),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',2),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',3),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',4),'')
		,'>',ifnull(split_part(pp.CategoryPathByChineseName,'>',5),'')) 
) a3
on a1.AccountCode=a3.AccountCode and a1.categ_5 =a3.categ_5 and a1.NodePathNameFull=a3.NodePathNameFull

