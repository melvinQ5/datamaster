select
	t.category,
	t.department,
	t.ReportType,
	t.�ܴ�,
	t.product_tupe,
	round(a2.�������۶�-ifnull(a3.�˿��ܶ�, 0), 2) '���۶�' ,
	round(a2.���������-ifnull(a5.��滨��, 0)-ifnull(a3.�˿��ܶ�, 0), 2) '�����',
	round(((���������-ifnull(��滨��, 0)-ifnull(�˿��ܶ�, 0))/(�������۶�-ifnull(�˿��ܶ�, 0)))* 100, 2) as '������',
	������,
	round((�������۶�-ifnull(�˿��ܶ�, 0))/ ������, 2) '�͵���',
	�������۶�,
	���������,
	����������,
	�˿��ܶ�,
	round((�˿��ܶ� /(ifnull(�˿��ܶ�, 0)+(�������۶�-ifnull(�˿��ܶ�, 0))))* 100, 2) as '�˿���',
	�����˿���,
	round((�����˿��� /(ifnull(�˿��ܶ�, 0)+(�������۶�-ifnull(�˿��ܶ�, 0))))* 100, 2) as '�ѷ����˿���',
	�������˿���,
	round((�������˿��� /(ifnull(�˿��ܶ�, 0)+(�������۶�-ifnull(�˿��ܶ�, 0))))* 100, 2) as '�������˿���',
	��SPU��,
	����SPU��,
	����SPU��,
	תΪ�ص��ƷSPU��,
	תΪ�ص��Ʒ�������۶�,
	���ܳ���SPU��,
	`4�ܳ���SPU��`,
	round((�������۶�-ifnull(�˿��ܶ�, 0))/ ���ܳ���SPU��, 2) '��-��SPU����ҵ��',
	round(Ŀǰ���������� / ����SPU��, 2) 'ƽ��SPU����������',
	round((���ܳ���SPU�� / ����SPU��)* 100, 2) 'SPU���ܶ�����',
	round((`4�ܳ���SPU��` / ����SPU��)* 100, 2) 'SPU4�ܶ�����',
	��SKU��,
	����SKU��,
	����SKU��,
	���ܳ���SKU��,
	`4�ܳ���SKU��`,
	round((�������۶�-ifnull(�˿��ܶ�, 0))/ ���ܳ���SKU��, 2) '��-��SKU����ҵ��',
	round(Ŀǰ���������� / ����SKU��, 2) 'ƽ��SKU����������',
	round((���ܳ���SPU�� / ����SKU��)* 100, 2) 'SKU���ܶ�����',
	round((`4�ܳ���SPU��` / ����SKU��)* 100, 2) 'SKU4�ܶ�����',
	Ŀǰ����������,
	���ܿ�������������,
	���ܳ���������,
	`4�ܳ���������`,
	round((���ܳ��������� / Ŀǰ����������)* 100, 2) '���ӵ��ܶ�����',
	round((`4�ܳ���������` / Ŀǰ����������)* 100, 2) '����4�ܶ�����',
	�ÿ���,
	�ÿ�����,
	������������,
	�ÿ�ת����,
	�ع���,
	�����,
	�������,
	��涩����,
	���ת����,
	������۶�,
	��滨��,
	round((��滨�� /(�������۶�-ifnull(�˿��ܶ�, 0)))* 100, 2) '��滨����',
	round((������۶� /(�������۶�-ifnull(�˿��ܶ�, 0)))* 100, 2) '���ҵ��ռ��',
	���Acost,
	���cpc,
	���ع�Ĺ��Ͷ��,
	�г����Ĺ��Ͷ��,
	ifnull(�ÿ���, 0)-ifnull(�����, 0) as '��Ȼ�����ÿ���',
	ifnull(�ÿ�����, 0)-ifnull(��涩����, 0) as '��Ȼ�����ÿ�����',
	round(((ifnull(�ÿ�����, 0)-ifnull(��涩����, 0))/(ifnull(�ÿ���, 0)-ifnull(�����, 0)))* 100, 2) '��Ȼ�����ÿ�ת����'
from
	(
	select
		'�Ҿ�����' as category,
		concat(Department, '-', NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'�Ҿ�����' as category,
		Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'PM' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		concat(Department, '-', NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'�Ҿ�����' as category,
		Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'PM' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		concat(Department, '-', NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'������Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'�Ҿ�����' as category,
		Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'������Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'PM' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'������Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'������Ʒ' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		concat(Department, '-', NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������')
	group by
		concat(Department, '-', NodePathName)
union
	select
		'�Ҿ�����' as category,
		Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'PM' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
union
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'-' as product_tupe
	from
		mysql_store
	where
		Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	group by
		Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
	with ca as (
	select
		go.SKU,
		go.SPU,
		go.BoxSKU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		ListingStatus,
		ShopStatus,
		ShopCode,
		SellerSKU,
		PublicationDate
	FROM
		erp_amazon_amazon_listing al /*ʵ��Ϊ����С������SPU��*/
	inner join life_category as go
on
		go.SKU = al.SKU
		and al.SKU <> ''
		and go.ProductStatus <> 2
		and go.DevelopLastAuditTime<'2022-12-26'
	inner join mysql_store s
on
		s.code = al.ShopCode
		and al.PublicationDate < '2022-12-26'
		and s.Department in ('����һ��', '���۶���', '��������', '�����Ĳ�'))
/*��Ʒ*/
	/*���в���С����Ʒ��������*/
	select
		'�Ҿ�����' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		count(distinct case when 1 = 1 then SPU end) '��SPU��',
		count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SPU end)'����SPU��',
		count(distinct case when 1 = 1 then SKU end) '��SKU��',
		count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SKU end)'����SKU��',
		count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
		count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
	from
		ca
	where
		ca.Department in ('����һ��', '���۶���', '��������')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*��������Ʒ��������*/
			select
				'�Ҿ�����' as category,
				ca.Department,
				'�ܱ�' as ReportType,
				weekofyear('2022-12-26') as '�ܴ�',
				'��Ʒ' as product_tupe,
				count(distinct case when 1 = 1 then SPU end) '��SPU��',
				count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SPU end)'����SPU��',
				count(distinct case when 1 = 1 then SKU end) '��SKU��',
				count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SKU end)'����SKU��',
				count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
				count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
					and ca.Department in ('����һ��', '���۶���', '��������')
				group by
					ca.Department
			union
				select
					'�Ҿ�����' as category,
					'�����Ĳ�' as Department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'��Ʒ' as product_tupe,
					count(distinct case when 1 = 1 then SPU end) '��SPU��',
					count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SPU end)'����SPU��',
					count(distinct case when 1 = 1 then SKU end) '��SKU��',
					count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SKU end)'����SKU��',
					count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
					count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department = '�����Ĳ�'
				union
/*PM������Ʒ��������*/
					select
						'�Ҿ�����' as category,
						'PM' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'��Ʒ' as product_tupe,
						count(distinct case when 1 = 1 then SPU end) '��SPU��',
						count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SPU end)'����SPU��',
						count(distinct case when 1 = 1 then SKU end) '��SKU��',
						count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SKU end)'����SKU��',
						count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
						count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
							and Department in ('���۶���', '��������')
					union
/*���в�����Ʒ��������*/
						select
							'�Ҿ�����' as category,
							'���в���' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'��Ʒ' as product_tupe,
							count(distinct case when 1 = 1 then SPU end) '��SPU��',
							count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SPU end)'����SPU��',
							count(distinct case when 1 = 1 then SKU end) '��SKU��',
							count(distinct case when ListingStatus = 1 and ShopStatus = '����' then SKU end)'����SKU��',
							count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
							count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
						from
							ca
						where
							DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
								and DevelopLastAuditTime<'2022-12-26'
						union
/*�ص��Ʒ*/
							/*������С���ص��Ʒ��������*/
							select
								'�Ҿ�����' as category,
								concat(ca.Department, '-', ca.NodePathName) as department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'�ص��Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('����һ��', '���۶���', '��������')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*�������ص��Ʒ��������*/
							select
								'�Ҿ�����' as category,
								ca.Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'�ص��Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('����һ��', '���۶���', '��������')
							group by
								ca.Department
						union
							select
								'�Ҿ�����' as category,
								'�����Ĳ�' as Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'�ص��Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department = '�����Ĳ�'
						union
/*PM�����ص��Ʒ��������*/
							select
								'�Ҿ�����' as category,
								'PM' as Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'�ص��Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
								and Department in ('���۶���', '��������')
						union
/*���в����ص��Ʒ��������*/
							select
								'�Ҿ�����' as category,
								'���в���' as Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'�ص��Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							inner join lead_product lp
on
								ca.SKU = lp.SKU
						union
/*������Ʒ*/
							/*���в���С��������Ʒ��������*/
							select
								'�Ҿ�����' as category,
								concat(ca.Department, '-', ca.NodePathName) as department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'������Ʒ' as product_tupe,
								count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
								count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
								count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
									and ca.Department in ('����һ��', '���۶���', '��������')
								group by
									concat(ca.Department, '-', ca.NodePathName)
							union
/*������������Ʒ��������*/
								select
									'�Ҿ�����' as category,
									ca.Department,
									'�ܱ�' as ReportType,
									weekofyear('2022-12-26') as '�ܴ�',
									'������Ʒ' as product_tupe,
									count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
									count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
									count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
									count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
									count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
									count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and ca.Department in ('����һ��', '���۶���', '��������')
									group by
										ca.Department
								union
									select
										'�Ҿ�����' as category,
										'�����Ĳ�' as Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'������Ʒ' as product_tupe,
										count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
										count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
										count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
										count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
										count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
										count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
											and ca.Department = '�����Ĳ�'
									union
/*PM����������Ʒ��������*/
										select
											'�Ҿ�����' as category,
											'PM' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'������Ʒ' as product_tupe,
											count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
											count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
											count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
											count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
											count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
											count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
										from
											ca
										where
											ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
												and ca.BoxSKU not in (
												select
													BoxSKU
												from
													lead_product)
												and ca.Department in ('���۶���', '��������')
										union
/*���в���������Ʒ��������*/
											select
												'�Ҿ�����' as category,
												'���в���' as Department,
												'�ܱ�' as ReportType,
												weekofyear('2022-12-26') as '�ܴ�',
												'������Ʒ' as product_tupe,
												count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
												count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
												count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
												count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
												count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
												count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
											from
												ca
											where
												ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
													and ca.BoxSKU not in (
													select
														BoxSKU
													from
														lead_product)
											union
/*���в�Ʒ*/
												/*������С�����в�Ʒ��������*/
												select
													'�Ҿ�����' as category,
													concat(ca.Department, '-', ca.NodePathName) as department,
													'�ܱ�' as ReportType,
													weekofyear('2022-12-26') as '�ܴ�',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
													count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
												from
													ca
												where
													Department in ('����һ��', '���۶���', '��������')
												group by
													concat(ca.Department, '-', ca.NodePathName)
											union
/*���������в�Ʒ��������*/
												select
													'�Ҿ�����' as category,
													ca.Department,
													'�ܱ�' as ReportType,
													weekofyear('2022-12-26') as '�ܴ�',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
													count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
												from
													ca
												where
													Department in ('����һ��', '���۶���', '��������')
												group by
													ca.Department
											union
												select
													'�Ҿ�����' as category,
													'�����Ĳ�' as Department,
													'�ܱ�' as ReportType,
													weekofyear('2022-12-26') as '�ܴ�',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
													count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
												from
													ca
												where
													Department = '�����Ĳ�'
											union
/*PM�������в�Ʒ��������*/
												select
													'�Ҿ�����' as category,
													'PM' as Department,
													'�ܱ�' as ReportType,
													weekofyear('2022-12-26') as '�ܴ�',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
													count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
												from
													ca
												where
													Department in ('���۶���', '��������')
											union
/*���в������в�Ʒ��������*/
												select
													'�Ҿ�����' as category,
													'���в���' as Department,
													'�ܱ�' as ReportType,
													weekofyear('2022-12-26') as '�ܴ�',
													'-' as product_tupe,
													count(distinct case when 1 = 1 then ca.SPU end) '��SPU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SPU end)'����SPU��',
													count(distinct case when 1 = 1 then ca.SKU end) '��SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then ca.SKU end)'����SKU��',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' then concat(ShopCode, '-', SellerSKU) end)'Ŀǰ����������',
													count(distinct case when ListingStatus = 1 and ShopStatus = '����' and PublicationDate >= date_add('2022-12-26', interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode, '-', SellerSKU) end)'���ܿ�������������'
												from
													ca
) as a1
on
	t.department = a1.department
	and t.product_tupe = a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
	with ca as (
	select
		go.BoxSku,
		go.SPU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		PayTime,
		TaxGross,
		TotalGross,
		TotalProfit,
		TaxRatio,
		RefundAmount,
		ExchangeUSD,
		TransactionType,
		OrderStatus,
		OrderTotalPrice,
		od.SellerSku,
		od.ShopIrobotId,
		PlatOrderNumber
	from
		import_data.OrderDetails od
	inner join life_category as go
on
		go.BoxSKU = od.BoxSku
	join import_data.mysql_store s
on
		s.code = od.ShopIrobotId
		and s.Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	left join import_data.Basedata b
on
		b.ReportType = '�ܱ�'
			and b.FirstDay = date_add('2022-12-26', interval -7 day)
				and b.DepSite = s.Site
			where
				PayTime >= date_add('2022-12-26', interval -28 day)
					and PayTime <'2022-12-26'
					and od.OrderNumber not in
(
					select
						OrderNumber
					from
						(
						SELECT
							OrderNumber,
							GROUP_CONCAT(TransactionType) alltype
						FROM
							import_data.OrderDetails
						where
							ShipmentStatus = 'δ����'
							and OrderStatus = '����'
							and PayTime >= date_add('2022-12-26', interval -28 day)
								and PayTime < '2022-12-26'
							group by
								OrderNumber) a
					where
						alltype = '����')
)

/*���в���С����Ʒ*/
	select
		'�Ҿ�����' as category,
		concat(ca.Department, '-', ca.NodePathName) as department ,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
		count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
		round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 
      then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
		round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
		round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
	from
		ca
	where
		DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
			and DevelopLastAuditTime<'2022-12-26'
			and ca.Department in ('����һ��', '���۶���', '��������')/*�������۲���С����Ʒ*/
		group by
			concat(ca.Department, '-', ca.NodePathName)
	union
/*��������Ʒ����������������*/
		select
			'�Ҿ�����' as category,
			ca.Department,
			'�ܱ�' as ReportType,
			weekofyear('2022-12-26') as '�ܴ�',
			'��Ʒ' as product_tupe,
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
			count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
			round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
			round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
			round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
		from
			ca
		where
			DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26' /*�������۲�����Ʒ*/
			group by
				ca.Department
		union
/*PM������Ʒ�������ݼ���������*/
			select
				'�Ҿ�����' as category,
				'PM' as department,
				'�ܱ�' as ReportType,
				weekofyear('2022-12-26') as '�ܴ�',
				'��Ʒ' as product_tupe,
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
				count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
				round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
				round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
				round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
					and ca.Department in ('���۶���', '��������')
			union
/*���в�����Ʒ�������ݼ���������*/
				select
					'�Ҿ�����' as category,
					'���в���' as department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'��Ʒ' as product_tupe,
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
					count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
					round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
					round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
					round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
				union
/*�ص��Ʒ����*/
					/*�ص��Ʒ��С������*/
					select
						'�Ҿ�����' as category,
						concat(ca.Department, '-', ca.NodePathName) as department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'�ص��Ʒ' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
						and ca.Department in ('����һ��', '���۶���', '��������')/*�������۲���С����Ʒ*/
					group by
						concat(ca.Department, '-', ca.NodePathName)
				union
/*���в��Ÿ������ص��Ʒ����*/
					select
						'�Ҿ�����' as category,
						ca.Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'�ص��Ʒ' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
					group by
						ca.Department
				union
/*PM�����ص��Ʒ��������������*/
					select
						'�Ҿ�����' as category,
						'PM' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'�ص��Ʒ' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
						and Department in ('���۶���', '��������')
				union
					select
						'�Ҿ�����' as category,
						'���в���' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'�ص��Ʒ' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
					from
						ca
					inner join lead_product as lp
on
						ca.BoxSku = lp.BoxSKU
				union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
					/*���в���С��������Ʒ*/
					select
						'�Ҿ�����' as category,
						concat(ca.Department, '-', ca.NodePathName) as department ,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'������Ʒ' as product_tupe,
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
						count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
						round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
						round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
					from
						ca
					where
						ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
							and ca.BoxSKU not in (
							select
								BoxSKU
							from
								lead_product)
							and ca.Department in ('����һ��', '���۶���', '��������')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*������������Ʒ��������������*/
						select
							'�Ҿ�����' as category,
							ca.Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'������Ʒ' as product_tupe,
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
							count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
							round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
							round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
							round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
							group by
								ca.Department
						union
/*PM����������Ʒ��������������*/
							select
								'�Ҿ�����' as category,
								'PM' as Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'������Ʒ' as product_tupe,
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
								count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
								round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
								round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
								round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
									and Department in ('���۶���', '��������')
							union
/*PM����������Ʒ��������������*/
								select
									'�Ҿ�����' as category,
									'���в���' as Department,
									'�ܱ�' as ReportType,
									weekofyear('2022-12-26') as '�ܴ�',
									'������Ʒ' as product_tupe,
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
									count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
									round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
									round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
									round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
								union
/*���в�Ʒ*/
									/*���в���С���������������*/
									select
										'�Ҿ�����' as category,
										concat(ca.Department, '-', ca.NodePathName) as department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
									from
										ca
									where
										ca.Department in ('����һ��', '���۶���', '��������')
									group by
										concat(ca.Department, '-', ca.NodePathName)
								union
/*���������в�Ʒ��������������*/
									select
										'�Ҿ�����' as category,
										ca.Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
									from
										ca
									group by
										ca.Department
								union
/*PM���ų�������������*/
									select
										'�Ҿ�����' as category,
										'PM' as Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
									from
										ca
									where
										ca.Department in ('��������', '���۶���')
								union
/*���в������в�Ʒ��������������*/
									select
										'�Ҿ�����' as category,
										'���в���' as Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'-' as product_tupe,
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber end ) '������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '���ܳ���������',
										count(distinct case when PayTime >= date_add('2022-12-26', interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku, ShopIrobotId) end ) '4�ܳ���������',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end), 2)'�������۶�',
										round(sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end), 2)'���������',
										round((sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ ExchangeUSD end)/ sum(case when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ ExchangeUSD
      when PayTime >= date_add('2022-12-26', interval -7 day) and PayTime<'2022-12-26' and TaxGross <= 0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ ExchangeUSD end))* 100, 2) '����������'
									from
										ca) as a2
on
	t.department = a2.department
	and a1.product_tupe = a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
	with ca as (
	select
		go.BoxSKU,
		go.DevelopLastAuditTime,
		Department,
		NodePathName,
		RefundUSDPrice,
		ShipDate,
		RefundReason2
	from
		RefundOrders ro
	inner join OrderDetails od
on
		ro.PlatOrderNumber = od.PlatOrderNumber
		and od.TransactionType = '����'
	inner join life_category as go
on
		go.BoxSKU = od.BoxSku
	inner join mysql_store s
on
		s.Code = ro.OrderSource
		and s.Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	where
		RefundDate >= date_add('2022-12-26', interval -7 day)
			and RefundDate < '2022-12-26'
)
/*�������˿�����*/
	/*������С����Ʒ�˿�����*/
	select
		'�Ҿ�����' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		sum(ca.RefundUSDPrice) '�˿��ܶ�',
		/*PM������Ʒ�˿�����*/
		sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
		sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
	from
		ca
	where
		Department in ('����һ��', '���۶���', '��������')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*��������Ʒ�˿�����*/
			select
				'�Ҿ�����' as category,
				ca.Department,
				'�ܱ�' as ReportType,
				weekofyear('2022-12-26') as '�ܴ�',
				'��Ʒ' as product_tupe,
				sum(ca.RefundUSDPrice) '�˿��ܶ�',
				/*PM������Ʒ�˿�����*/
				sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
				sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM������Ʒ�˿�����*/
				select
					'�Ҿ�����' as category,
					'PM' as Department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'��Ʒ' as product_tupe,
					sum(ca.RefundUSDPrice) '�˿��ܶ�',
					/*PM������Ʒ�˿�����*/
					sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
					sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and Department in ('���۶���', '��������')
				union
/*���в�����Ʒ�˿�����*/
					select
						'�Ҿ�����' as category,
						'���в���' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'��Ʒ' as product_tupe,
						sum(ca.RefundUSDPrice) '�˿��ܶ�',
						/*PM������Ʒ�˿�����*/
						sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
						sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*�ص��Ʒ*/
						/*���в���С���ص��Ʒ�˿�����*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(ca.RefundUSDPrice) '�˿��ܶ�',
							/*���в����ص��Ʒ�˿�����*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
							and Department in ('����һ��', '���۶���', '��������')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*�������ص��Ʒ�˿�����*/
						select
							'�Ҿ�����' as category,
							ca.Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(ca.RefundUSDPrice) '�˿��ܶ�',
							/*���в����ص��Ʒ�˿�����*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
						group by
							ca.Department
					union
/*PM�����ص��Ʒ�˿�����*/
						select
							'�Ҿ�����' as category,
							'PM' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(ca.RefundUSDPrice) '�˿��ܶ�',
							/*���в����ص��Ʒ�˿�����*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
							and Department in ('���۶���', '��������')
					union
/*���в����ص��Ʒ�˿�����*/
						select
							'�Ҿ�����' as category,
							'���в���' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(ca.RefundUSDPrice) '�˿��ܶ�',
							/*���в����ص��Ʒ�˿�����*/
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
						from
							ca
						inner join lead_product lp
on
							ca.BoxSKU = lp.BoxSKU
					union
/*������Ʒ*/
						/*���в���С��������Ʒ�˿�����*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'������Ʒ' as product_tupe,
							sum(ca.RefundUSDPrice) '�˿��ܶ�',
							sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
							sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('����һ��', '���۶���', '��������')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*������������Ʒ�˿�����*/
							select
								'�Ҿ�����' as category,
								ca.Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'������Ʒ' as product_tupe,
								sum(ca.RefundUSDPrice) '�˿��ܶ�',
								sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
								sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM����������Ʒ�˿�����*/
								select
									'�Ҿ�����' as category,
									'PM' as department,
									'�ܱ�' as ReportType,
									weekofyear('2022-12-26') as '�ܴ�',
									'������Ʒ' as product_tupe,
									sum(ca.RefundUSDPrice) '�˿��ܶ�',
									sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
									sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and Department in ('���۶���', '��������')
								union
/*���в���������Ʒ�˿�����*/
									select
										'�Ҿ�����' as category,
										'���в���' as department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'������Ʒ' as product_tupe,
										sum(ca.RefundUSDPrice) '�˿��ܶ�',
										sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
										sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*���в�Ʒ*/
										/*������С�����в�Ʒ�˿�����*/
										select
											'�Ҿ�����' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '�˿��ܶ�',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
										from
											ca
										where
											Department in ('����һ��', '���۶���', '��������')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*���������в�Ʒ�˿�����*/
										select
											'�Ҿ�����' as category,
											ca.Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '�˿��ܶ�',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
										from
											ca
										group by
											ca.Department
									union
/*PM�������в�Ʒ�˿�����*/
										select
											'�Ҿ�����' as category,
											'PM' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '�˿��ܶ�',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
										from
											ca
										where
											Department in ('���۶���', '��������')
									union
/*���в������в�Ʒ�˿�����*/
										select
											'�Ҿ�����' as category,
											'���в���' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(ca.RefundUSDPrice) '�˿��ܶ�',
											sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
											sum(case when ShipDate = '2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���'
										from
											ca
) as a3
on
	t.department = a3.department
	and a1.product_tupe = a3.product_tupe
left join
(
/*�ÿ�����*/
	with ca as (
	select
		Department,
		NodePathName,
		go.SKU,
		go.BoxSKU,
		go.DevelopLastAuditTime,
		TotalCount,
		FeaturedOfferPercent,
		OrderedCount,
		ChildAsin,
		aa.ShopCode
	from
		erp_amazon_amazon_listing as al
	inner join life_category as go
on
		al.Sku = go.SKU
	inner join ListingManage aa
on
		aa.ChildAsin = al.ASIN
		and aa.ShopCode = al.ShopCode
		and aa.ReportType = '�ܱ�'
	inner join mysql_store s
on
		s.code = al.shopcode
		and s.Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	where
		aa.Monday = date_add('2022-12-26', interval -7 day)
			and aa.TotalCount * aa.FeaturedOfferPercent / 100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
	/*���в���С����Ʒ�ÿ�����*/
	select
		'�Ҿ�����' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
		sum(OrderedCount) '�ÿ�����',
		round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
		count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
	from
		ca
	where
		ca.Department in ('����һ��', '���۶���', '��������')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*��������Ʒ�ÿ�����*/
			select
				'�Ҿ�����' as category,
				ca.Department,
				'�ܱ�' as ReportType,
				weekofyear('2022-12-26') as '�ܴ�',
				'��Ʒ' as product_tupe,
				round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
				sum(OrderedCount) '�ÿ�����',
				round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
				count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM������Ʒ�ÿ�����*/
				select
					'�Ҿ�����' as category,
					'PM' as Department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'��Ʒ' as product_tupe,
					round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
					sum(OrderedCount) '�ÿ�����',
					round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
					count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department in ('���۶���', '��������')
				union
/*���в�����Ʒ�ÿ�����*/
					select
						'�Ҿ�����' as category,
						'���в���' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'��Ʒ' as product_tupe,
						round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
						sum(OrderedCount) '�ÿ�����',
						round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
						count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*�ص��Ʒ*/
						/*������С���ص��Ʒ�ÿ�����*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
							sum(OrderedCount) '�ÿ�����',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('����һ��', '���۶���', '��������')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*�������ص��Ʒ�ÿ�����*/
						select
							'�Ҿ�����' as category,
							ca.Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
							sum(OrderedCount) '�ÿ�����',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						group by
							ca.Department
					union
/*PM�����ص��Ʒ�ÿ�����*/
						select
							'�Ҿ�����' as category,
							'PM' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
							sum(OrderedCount) '�ÿ�����',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('���۶���', '��������')
					union
/*���в����ص��Ʒ�ÿ�����*/
						select
							'�Ҿ�����' as category,
							'���в���' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
							sum(OrderedCount) '�ÿ�����',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
						from
							ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
					union
/*������Ʒ*/
						/*������С��������Ʒ�ÿ�����*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'������Ʒ' as product_tupe,
							round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
							sum(OrderedCount) '�ÿ�����',
							round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
							count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
						from
							ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('����һ��', '���۶���', '��������')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*������������Ʒ�ÿ�����*/
							select
								'�Ҿ�����' as category,
								ca.Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'������Ʒ' as product_tupe,
								round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
								sum(OrderedCount) '�ÿ�����',
								round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
								count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
							from
								ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM����������Ʒ�ÿ�����*/
								select
									'�Ҿ�����' as category,
									'PM' as Department,
									'�ܱ�' as ReportType,
									weekofyear('2022-12-26') as '�ܴ�',
									'������Ʒ' as product_tupe,
									round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
									sum(OrderedCount) '�ÿ�����',
									round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
									count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
								from
									ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and ca.Department in ('���۶���', '��������')
								union
/*���в���������Ʒ�ÿ�����*/
									select
										'�Ҿ�����' as category,
										'���в���' as Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'������Ʒ' as product_tupe,
										round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
										sum(OrderedCount) '�ÿ�����',
										round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
										count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
									from
										ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*���в�Ʒ*/
										/*���в���С�����в�Ʒ�ÿ�����*/
										select
											'�Ҿ�����' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
											sum(OrderedCount) '�ÿ�����',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
										from
											ca
										where
											Department in ('����һ��', '���۶���', '��������')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*���������в�Ʒ�ÿ�����*/
										select
											'�Ҿ�����' as category,
											ca.Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
											sum(OrderedCount) '�ÿ�����',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
										from
											ca
										group by
											ca.Department
									union
/*PM�������в�Ʒ�ÿ�����*/
										select
											'�Ҿ�����' as category,
											'PM' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
											sum(OrderedCount) '�ÿ�����',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
										from
											ca
										where
											ca.Department in ('���۶���', '��������')
									union
/*���в������в�Ʒ�ÿ�����*/
										select
											'�Ҿ�����' as category,
											'���в���' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���',
											sum(OrderedCount) '�ÿ�����',
											round((sum(OrderedCount)/ sum(TotalCount * FeaturedOfferPercent / 100))* 100, 2) '�ÿ�ת����',
											count(distinct concat(ca.ChildAsin, '-', ca.ShopCode))'������������'
										from
											ca) as a4
on
	t.department = a4.department
	and a1.product_tupe = a4.product_tupe
left join
(
with ca as (
	select
		go.SKU,
		go.BoxSKU,
		DevelopLastAuditTime,
		Department,
		NodePathName,
		TotalSale7Day,
		TotalSale7DayUnit,
		Spend,
		Clicks,
		Exposure,
		UnitsOrdered7d,
		aa.SellerSKU,
		aa.ShopCode
	from
		erp_amazon_amazon_listing as al
	inner join life_category as go
on
		al.Sku = go.SKU
	inner join AdServing_Amazon aa
on
		aa.SellerSKU = al.SellerSKU
		and aa.shopcode = al.ShopCode
	inner join mysql_store as s
on
		s.code = aa.Shopcode
		and s.Department in ('����һ��', '���۶���', '��������', '�����Ĳ�')
	where
		aa.CreatedTime >= date_add('2022-12-26', interval -8 day)
			and aa.CreatedTime < date_add('2022-12-26', interval -1 day)
)
/*��Ʒ*/
	/*������С��������*/
	select
		'�Ҿ�����' as category,
		concat(ca.Department, '-', ca.NodePathName) as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		sum(Exposure) as '�ع���',
		sum(Clicks) '�����',
		round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
		sum(TotalSale7DayUnit) '��涩����',
		round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
		sum(TotalSale7Day) '������۶�',
		sum(Spend) '��滨��',
		round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
		round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
		count (distinct case
			when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
		end ) '���ع�Ĺ��Ͷ��',
		count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
	from
		ca
	where
		ca.Department in ('����һ��', '���۶���', '��������')
			and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
				and DevelopLastAuditTime<'2022-12-26'
			group by
				concat(ca.Department, '-', ca.NodePathName)
		union
/*��������Ʒ�������*/
			select
				'�Ҿ�����' as category,
				ca.Department,
				'�ܱ�' as ReportType,
				weekofyear('2022-12-26') as '�ܴ�',
				'��Ʒ' as product_tupe,
				sum(Exposure) as '�ع���',
				sum(Clicks) '�����',
				round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
				sum(TotalSale7DayUnit) '��涩����',
				round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
				sum(TotalSale7Day) '������۶�',
				sum(Spend) '��滨��',
				round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
				round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
				count (distinct case
					when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
				end ) '���ع�Ĺ��Ͷ��',
				count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
			from
				ca
			where
				DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
					and DevelopLastAuditTime<'2022-12-26'
				group by
					ca.Department
			union
/*PM������Ʒ�������*/
				select
					'�Ҿ�����' as category,
					'PM' as Department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'��Ʒ' as product_tupe,
					sum(Exposure) as '�ع���',
					sum(Clicks) '�����',
					round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
					sum(TotalSale7DayUnit) '��涩����',
					round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
					sum(TotalSale7Day) '������۶�',
					sum(Spend) '��滨��',
					round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
					round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
					count (distinct case
						when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
					end ) '���ع�Ĺ��Ͷ��',
					count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
				from
					ca
				where
					DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
						and DevelopLastAuditTime<'2022-12-26'
						and ca.Department in ('���۶���', '��������')
				union
/*���в�����Ʒ�������*/
					select
						'�Ҿ�����' as category,
						'���в���' as Department,
						'�ܱ�' as ReportType,
						weekofyear('2022-12-26') as '�ܴ�',
						'��Ʒ' as product_tupe,
						sum(Exposure) as '�ع���',
						sum(Clicks) '�����',
						round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
						sum(TotalSale7DayUnit) '��涩����',
						round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
						sum(TotalSale7Day) '������۶�',
						sum(Spend) '��滨��',
						round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
						round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
						count (distinct case
							when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
						end ) '���ع�Ĺ��Ͷ��',
						count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
					from
						ca
					where
						DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
							and DevelopLastAuditTime<'2022-12-26'
					union
/*�ص��Ʒ*/
						/*������С���ص��Ʒ�������*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(Exposure) as '�ع���',
							sum(Clicks) '�����',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
							sum(TotalSale7DayUnit) '��涩����',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
							sum(TotalSale7Day) '������۶�',
							sum(Spend) '��滨��',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '���ع�Ĺ��Ͷ��',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						where
							ca.Department in ('����һ��', '���۶���', '��������')
						group by
							concat(ca.Department, '-', ca.NodePathName)
					union
/*�������ص��Ʒ�������*/
						select
							'�Ҿ�����' as category,
							ca.Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(Exposure) as '�ع���',
							sum(Clicks) '�����',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
							sum(TotalSale7DayUnit) '��涩����',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
							sum(TotalSale7Day) '������۶�',
							sum(Spend) '��滨��',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '���ع�Ĺ��Ͷ��',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
						group by
							ca.Department
					union
/*PM�����ص��Ʒ�������*/
						select
							'�Ҿ�����' as category,
							'PM' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(Exposure) as '�ع���',
							sum(Clicks) '�����',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
							sum(TotalSale7DayUnit) '��涩����',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
							sum(TotalSale7Day) '������۶�',
							sum(Spend) '��滨��',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '���ع�Ĺ��Ͷ��',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
							and ca.Department in ('���۶���', '��������')
					union
/*���в����ص��Ʒ�������*/
						select
							'�Ҿ�����' as category,
							'���в���' as Department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'�ص��Ʒ' as product_tupe,
							sum(Exposure) as '�ع���',
							sum(Clicks) '�����',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
							sum(TotalSale7DayUnit) '��涩����',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
							sum(TotalSale7Day) '������۶�',
							sum(Spend) '��滨��',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '���ع�Ĺ��Ͷ��',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
							from ca
						inner join lead_product as lp
on
							ca.Sku = lp.SKU
					union
/*������Ʒ*/
						/*������С��������Ʒ�������*/
						select
							'�Ҿ�����' as category,
							concat(ca.Department, '-', ca.NodePathName) as department,
							'�ܱ�' as ReportType,
							weekofyear('2022-12-26') as '�ܴ�',
							'������Ʒ' as product_tupe,
							sum(Exposure) as '�ع���',
							sum(Clicks) '�����',
							round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
							sum(TotalSale7DayUnit) '��涩����',
							round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
							sum(TotalSale7Day) '������۶�',
							sum(Spend) '��滨��',
							round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
							round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
							count (distinct case
								when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
							end ) '���ع�Ĺ��Ͷ��',
							count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
							from ca
						where
							ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
								and ca.BoxSKU not in (
								select
									BoxSKU
								from
									lead_product)
								and ca.Department in ('����һ��', '���۶���', '��������')
							group by
								concat(ca.Department, '-', ca.NodePathName)
						union
/*������������Ʒ�������*/
							select
								'�Ҿ�����' as category,
								ca.Department,
								'�ܱ�' as ReportType,
								weekofyear('2022-12-26') as '�ܴ�',
								'������Ʒ' as product_tupe,
								sum(Exposure) as '�ع���',
								sum(Clicks) '�����',
								round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
								sum(TotalSale7DayUnit) '��涩����',
								round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
								sum(TotalSale7Day) '������۶�',
								sum(Spend) '��滨��',
								round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
								round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
								count (distinct case
									when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
								end ) '���ع�Ĺ��Ͷ��',
								count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
								from ca
							where
								ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
									and ca.BoxSKU not in (
									select
										BoxSKU
									from
										lead_product)
								group by
									ca.Department
							union
/*PM����������Ʒ�������*/
								select
									'�Ҿ�����' as category,
									'PM' as Department,
									'�ܱ�' as ReportType,
									weekofyear('2022-12-26') as '�ܴ�',
									'������Ʒ' as product_tupe,
									sum(Exposure) as '�ع���',
									sum(Clicks) '�����',
									round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
									sum(TotalSale7DayUnit) '��涩����',
									round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
									sum(TotalSale7Day) '������۶�',
									sum(Spend) '��滨��',
									round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
									round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
									count (distinct case
										when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
									end ) '���ع�Ĺ��Ͷ��',
									count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
									from ca
								where
									ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
										and ca.BoxSKU not in (
										select
											BoxSKU
										from
											lead_product)
										and Department in ('���۶���', '��������')
								union
/*���в���������Ʒ�������*/
									select
										'�Ҿ�����' as category,
										'���в���' as Department,
										'�ܱ�' as ReportType,
										weekofyear('2022-12-26') as '�ܴ�',
										'������Ʒ' as product_tupe,
										sum(Exposure) as '�ع���',
										sum(Clicks) '�����',
										round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
										sum(TotalSale7DayUnit) '��涩����',
										round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
										sum(TotalSale7Day) '������۶�',
										sum(Spend) '��滨��',
										round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
										round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
										count (distinct case
											when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
										end ) '���ع�Ĺ��Ͷ��',
										count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
										from ca
									where
										ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
											and ca.BoxSKU not in (
											select
												BoxSKU
											from
												lead_product)
									union
/*���в�Ʒ*/
										/*������С�����в�Ʒ�������*/
										select
											'�Ҿ�����' as category,
											concat(ca.Department, '-', ca.NodePathName) as department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(Exposure) as '�ع���',
											sum(Clicks) '�����',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
											sum(TotalSale7DayUnit) '��涩����',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
											sum(TotalSale7Day) '������۶�',
											sum(Spend) '��滨��',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '���ع�Ĺ��Ͷ��',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
											from ca
										where
											Department in ('����һ��', '���۶���', '��������')
										group by
											concat(ca.Department, '-', ca.NodePathName)
									union
/*���������в�Ʒ�������*/
										select
											'�Ҿ�����' as category,
											ca.Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(Exposure) as '�ع���',
											sum(Clicks) '�����',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
											sum(TotalSale7DayUnit) '��涩����',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
											sum(TotalSale7Day) '������۶�',
											sum(Spend) '��滨��',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '���ع�Ĺ��Ͷ��',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
											from ca
										group by
											ca.Department
									union
/*PM�������в�Ʒ�������*/
										select
											'�Ҿ�����' as category,
											'PM' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(Exposure) as '�ع���',
											sum(Clicks) '�����',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
											sum(TotalSale7DayUnit) '��涩����',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
											sum(TotalSale7Day) '������۶�',
											sum(Spend) '��滨��',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '���ع�Ĺ��Ͷ��',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
											from ca
										where
											Department in ('���۶���', '��������')
									union
/*���в������в�Ʒ�������*/
										select
											'�Ҿ�����' as category,
											'���в���' as Department,
											'�ܱ�' as ReportType,
											weekofyear('2022-12-26') as '�ܴ�',
											'-' as product_tupe,
											sum(Exposure) as '�ع���',
											sum(Clicks) '�����',
											round((sum(Clicks)/ sum(Exposure))* 100, 2) '�������',
											sum(TotalSale7DayUnit) '��涩����',
											round((sum(TotalSale7DayUnit)/ sum(Clicks))* 100, 2) '���ת����',
											sum(TotalSale7Day) '������۶�',
											sum(Spend) '��滨��',
											round((sum(Spend)/ sum(TotalSale7Day))* 100, 2) '���Acost',
											round((sum(Spend)/ sum(Clicks)), 3) '���cpc',
											count (distinct case
												when Exposure>0 then concat(ca.SellerSKU, '-', ShopCode)
											end ) '���ع�Ĺ��Ͷ��',
											count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU, '-', ShopCode) end ) '�г����Ĺ��Ͷ��'
											from ca) as a5
on
	t.department = a5.department
	and a1.product_tupe = a5.product_tupe
left join
(
with ca as(
	select
		lp.SPU,
		lp.BoxSKU,
		lp.DevelopLastAuditTime
	from
		life_category go
	inner join lead_product lp
on
		go.BoxSKU = lp.BoxSKU
		and go.SKU = lp.SKU
	where
		UpdateTime >= date_add('2022-12-26', interval -7 day)
			and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
	/*���в�����Ʒת�ص��Ʒ*/
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe,
		count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'
	from
		ca
union
/*������ƷתΪSPU��*/
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'������Ʒ' as product_tupe,
		count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'
		from ca
	where
		ca.DevelopLastAuditTime<date_add('2022-09-30', interval -1 day) ) as a6
on
	t.department = a6.Department
	and a1.product_tupe = a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
	with ca as(
	select
		lp.SPU,
		lp.BoxSKU,
		lp.DevelopLastAuditTime
	from
		life_category go
	inner join lead_product lp
on
		go.BoxSKU = lp.BoxSKU
		and go.SKU = lp.SKU
	where
		UpdateTime >= date_add('2022-12-26', interval -7 day)
			and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
	/*���в�����Ʒת�ص��Ʒ*/
	select
		'�Ҿ�����' as category,
		'���в���' as Department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'�ص��Ʒ' as product_tupe,
		round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
), 2) 'תΪ�ص��Ʒ�������۶�'
	from
		ca
	inner join OrderDetails od
on
		ca.BoxSKU = od.BoxSku
		and DevelopLastAuditTime >= date_add('2022-09-30', interval -1 day)
			and DevelopLastAuditTime<'2022-12-26'
		join import_data.mysql_store s
on
			s.code = od.ShopIrobotId
		left join import_data.Basedata b
on
			b.ReportType = '�ܱ�'
			and b.FirstDay = date_add('2022-12-26', interval -7 day)
				and b.DepSite = s.Site
			where
				PayTime >= date_add('2022-12-26', interval -7 day)
					and PayTime <'2022-12-26'
					and od.OrderNumber not in
(
					select
						OrderNumber
					from
						(
						SELECT
							OrderNumber,
							GROUP_CONCAT(TransactionType) alltype
						FROM
							import_data.OrderDetails
						where
							ShipmentStatus = 'δ����'
							and OrderStatus = '����'
							and PayTime >= date_add('2022-12-26', interval -7 day)
								and PayTime < '2022-12-26'
							group by
								OrderNumber) a
					where
						alltype = '����')
			union
/*������ƷתΪSPU����ҵ��*/
				select
					'�Ҿ�����' as category,
					'���в���' as Department,
					'�ܱ�' as ReportType,
					weekofyear('2022-12-26') as '�ܴ�',
					'������Ʒ' as product_tupe,
					round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
), 2) 'תΪ�ص��Ʒ�������۶�'
				from
					ca
				inner join OrderDetails od
on
					ca.BoxSKU = od.BoxSku
					and DevelopLastAuditTime<date_add('2022-09-30', interval -1 day)
				join import_data.mysql_store s
on
					s.code = od.ShopIrobotId
				left join import_data.Basedata b
on
					b.ReportType = '�ܱ�'
						and b.FirstDay = date_add('2022-12-26', interval -7 day)
							and b.DepSite = s.Site
						where
							PayTime >= date_add('2022-12-26', interval -7 day)
								and PayTime <'2022-12-26'
								and od.OrderNumber not in
(
								select
									OrderNumber
								from
									(
									SELECT
										OrderNumber,
										GROUP_CONCAT(TransactionType) alltype
									FROM
										import_data.OrderDetails
									where
										ShipmentStatus = 'δ����'
										and OrderStatus = '����'
										and PayTime >= date_add('2022-12-26', interval -7 day)
											and PayTime < '2022-12-26'
										group by
											OrderNumber) a
								where
									alltype = '����')) as a7
on
	t.department = a7.Department
	and a1.product_tupe = a7.product_tupe
left join
(/*��������SPU-SKU��*/
	/*��Ʒ*/
	/*������С����Ʒ����SPU��*/
	select
		'�Ҿ�����' as category,
		'���в���' as department,
		'�ܱ�' as ReportType,
		weekofyear('2022-12-26') as '�ܴ�',
		'��Ʒ' as product_tupe,
		count(distinct SPU) '����SPU��',
		count(distinct sku) '����SKU��'
	from
		life_category
	where
		DevelopLastAuditTime >= date_add('2022-12-26', interval -7 day )
			and DevelopLastAuditTime<'2022-12-26'
	union
		select
			'�Ҿ�����' as category,
			'PM' as department,
			'�ܱ�' as ReportType,
			weekofyear('2022-12-26') as '�ܴ�',
			'��Ʒ' as product_tupe,
			count(distinct SPU) '����SPU��',
			count(distinct sku) '����SKU��'
		from
			life_category
		where
			DevelopLastAuditTime >= date_add('2022-12-26', interval -7 day )
				and DevelopLastAuditTime<'2022-12-26') as a8
on
	t.department = a8.department
	and a1.product_tupe = a8.product_tupe
order by
	t.department ,
	t.product_tupe desc;


select t.category, t.department, t.ReportType, t.�ܴ�, t.product_tupe,round(a2.�������۶�-ifnull(a3.�˿��ܶ�,0),2) '���۶�' ,
round(a2.���������-ifnull(a5.��滨��,0)-ifnull(a3.�˿��ܶ�,0),2) '�����',round(((���������-ifnull(��滨��,0)-ifnull(�˿��ܶ�,0))/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) as '������',
������,round((�������۶�-ifnull(�˿��ܶ�,0))/������,2) '�͵���',�������۶�,���������,����������,
�˿��ܶ�,round((�˿��ܶ�/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�˿���',
�����˿���,round((�����˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�ѷ����˿���',
�������˿���,round((�������˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�������˿���',
��SPU��,����SPU��,����SPU��,תΪ�ص��ƷSPU��,תΪ�ص��Ʒ�������۶�,���ܳ���SPU��,`4�ܳ���SPU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SPU��,2) '��-��SPU����ҵ��',
round(Ŀǰ����������/����SPU��,2) 'ƽ��SPU����������',
round((���ܳ���SPU��/����SPU��)*100,2) 'SPU���ܶ�����',
round((`4�ܳ���SPU��`/����SPU��)*100,2) 'SPU4�ܶ�����',
��SKU��,����SKU��,����SKU��,���ܳ���SKU��,`4�ܳ���SKU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SKU��,2) '��-��SKU����ҵ��',
round(Ŀǰ����������/����SKU��,2) 'ƽ��SKU����������',
round((���ܳ���SPU��/����SKU��)*100,2) 'SKU���ܶ�����',
round((`4�ܳ���SPU��`/����SKU��)*100,2) 'SKU4�ܶ�����',
Ŀǰ����������,���ܿ�������������,���ܳ���������,`4�ܳ���������`,round((���ܳ���������/Ŀǰ����������)*100,2) '���ӵ��ܶ�����',
round((`4�ܳ���������`/Ŀǰ����������)*100,2) '����4�ܶ�����',
�ÿ���,�ÿ�����,������������,�ÿ�ת����,
�ع���, �����, �������, ��涩����, ���ת����, ������۶�, ��滨��, round((��滨��/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '��滨����',
round((������۶�/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '���ҵ��ռ��',���Acost, ���cpc, ���ع�Ĺ��Ͷ��, �г����Ĺ��Ͷ��,
ifnull(�ÿ���,0)-ifnull(�����,0) as '��Ȼ�����ÿ���',ifnull(�ÿ�����,0)-ifnull(��涩����,0) as '��Ȼ�����ÿ�����',
round(((ifnull(�ÿ�����,0)-ifnull(��涩����,0))/(ifnull(�ÿ���,0)-ifnull(�����,0)))*100,2) '��Ȼ�����ÿ�ת����'
from
(select '�������' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '�������' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '�������' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '�������' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '�������' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*ʵ��Ϊ����С������SPU��*/
inner join tool_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�'))
/*��Ʒ*/
/*���в���С����Ʒ��������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where ca.Department  in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ��������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('����һ��','���۶���','��������')
group by ca.Department
union
select '�������' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='�����Ĳ�'

union
/*PM������Ʒ��������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('���۶���','��������')
union
/*���в�����Ʒ��������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ��������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ��������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '�������' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='�����Ĳ�'

union
/*PM�����ص��Ʒ��������*/
select '�������' as category,'PM' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ��������*/
select '�������' as category,'���в���' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*������Ʒ*/
/*���в���С��������Ʒ��������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '�������' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='�����Ĳ�'
union
/*PM����������Ʒ��������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ��������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ��������*/
select '�������' as category, concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������*/
select '�������' as category, ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by ca.Department
union
select '�������' as category, '�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department='�����Ĳ�'
union
/*PM�������в�Ʒ��������*/
select '�������' as category, 'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ��������*/
select '�������' as category, '���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join tool_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')
)

/*���в���С����Ʒ*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '�������' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '�������' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='����'
inner join tool_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*�������˿�����*/
/*������С����Ʒ�˿�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�˿�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�˿�����*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('���۶���','��������')
union
/*���в�����Ʒ�˿�����*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*���в���С���ص��Ʒ�˿�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�˿�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ�˿�����*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�˿�����*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*������Ʒ*/
/*���в���С��������Ʒ�˿�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�˿�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�˿�����*/
select '�������' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�˿�����*/
select '�������' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�˿�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�˿�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
group by ca.Department
union
/*PM�������в�Ʒ�˿�����*/
select '�������' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�˿�����*/
select '�������' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*�ÿ�����*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join tool_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '�ܱ�'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
/*���в���С����Ʒ�ÿ�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�ÿ�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�ÿ�����*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�ÿ�����*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�ÿ�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�ÿ�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�ÿ�����*/
select '�������' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�ÿ�����*/
select '�������' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�ÿ�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�ÿ�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�ÿ�����*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ�ÿ�����*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С�����в�Ʒ�ÿ�����*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�ÿ�����*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
group by ca.Department
union
/*PM�������в�Ʒ�ÿ�����*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('���۶���','��������')
union
/*���в������в�Ʒ�ÿ�����*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join tool_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*��Ʒ*/
/*������С��������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�������*/
select '�������' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�������*/
select '�������' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
group by ca.Department
union
/*PM�������в�Ʒ�������*/
select '�������' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�������*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from tool_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '�������' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��' from ca
union
/*������ƷתΪSPU��*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from tool_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '�������' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')

union
/*������ƷתΪSPU����ҵ��*/
select '�������' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*��������SPU-SKU��*/
/*��Ʒ*/
/*������С����Ʒ����SPU��*/
select '�������' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from tool_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '�������' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from tool_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;

select t.category, t.department, t.ReportType, t.�ܴ�, t.product_tupe,round(a2.�������۶�-ifnull(a3.�˿��ܶ�,0),2) '���۶�' ,
round(a2.���������-ifnull(a5.��滨��,0)-ifnull(a3.�˿��ܶ�,0),2) '�����',round(((���������-ifnull(��滨��,0)-ifnull(�˿��ܶ�,0))/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) as '������',
������,round((�������۶�-ifnull(�˿��ܶ�,0))/������,2) '�͵���',�������۶�,���������,����������,
�˿��ܶ�,round((�˿��ܶ�/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�˿���',
�����˿���,round((�����˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�ѷ����˿���',
�������˿���,round((�������˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�������˿���',
��SPU��,����SPU��,����SPU��,תΪ�ص��ƷSPU��,תΪ�ص��Ʒ�������۶�,���ܳ���SPU��,`4�ܳ���SPU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SPU��,2) '��-��SPU����ҵ��',
round(Ŀǰ����������/����SPU��,2) 'ƽ��SPU����������',
round((���ܳ���SPU��/����SPU��)*100,2) 'SPU���ܶ�����',
round((`4�ܳ���SPU��`/����SPU��)*100,2) 'SPU4�ܶ�����',
��SKU��,����SKU��,����SKU��,���ܳ���SKU��,`4�ܳ���SKU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SKU��,2) '��-��SKU����ҵ��',
round(Ŀǰ����������/����SKU��,2) 'ƽ��SKU����������',
round((���ܳ���SPU��/����SKU��)*100,2) 'SKU���ܶ�����',
round((`4�ܳ���SPU��`/����SKU��)*100,2) 'SKU4�ܶ�����',
Ŀǰ����������,���ܿ�������������,���ܳ���������,`4�ܳ���������`,round((���ܳ���������/Ŀǰ����������)*100,2) '���ӵ��ܶ�����',
round((`4�ܳ���������`/Ŀǰ����������)*100,2) '����4�ܶ�����',
�ÿ���,�ÿ�����,������������,�ÿ�ת����,
�ع���, �����, �������, ��涩����, ���ת����, ������۶�, ��滨��, round((��滨��/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '��滨����',
round((������۶�/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '���ҵ��ռ��',���Acost, ���cpc, ���ع�Ĺ��Ͷ��, �г����Ĺ��Ͷ��,
ifnull(�ÿ���,0)-ifnull(�����,0) as '��Ȼ�����ÿ���',ifnull(�ÿ�����,0)-ifnull(��涩����,0) as '��Ȼ�����ÿ�����',
round(((ifnull(�ÿ�����,0)-ifnull(��涩����,0))/(ifnull(�ÿ���,0)-ifnull(�����,0)))*100,2) '��Ȼ�����ÿ�ת����'
from
(select '���ְ���' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '���ְ���' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '���ְ���' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '���ְ���' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '���ְ���' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*ʵ��Ϊ����С������SPU��*/
inner join like_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�'))
/*��Ʒ*/
/*���в���С����Ʒ��������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where ca.Department  in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ��������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('����һ��','���۶���','��������')
group by ca.Department
union
select '���ְ���' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='�����Ĳ�'

union
/*PM������Ʒ��������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('���۶���','��������')
union
/*���в�����Ʒ��������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ��������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ��������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '���ְ���' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='�����Ĳ�'

union
/*PM�����ص��Ʒ��������*/
select '���ְ���' as category,'PM' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ��������*/
select '���ְ���' as category,'���в���' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*������Ʒ*/
/*���в���С��������Ʒ��������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '���ְ���' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='�����Ĳ�'
union
/*PM����������Ʒ��������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ��������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ��������*/
select '���ְ���' as category, concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������*/
select '���ְ���' as category, ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by ca.Department
union
select '���ְ���' as category, '�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department='�����Ĳ�'
union
/*PM�������в�Ʒ��������*/
select '���ְ���' as category, 'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ��������*/
select '���ְ���' as category, '���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join like_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')
)

/*���в���С����Ʒ*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '���ְ���' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '���ְ���' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='����'
inner join like_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*�������˿�����*/
/*������С����Ʒ�˿�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�˿�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�˿�����*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('���۶���','��������')
union
/*���в�����Ʒ�˿�����*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*���в���С���ص��Ʒ�˿�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�˿�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ�˿�����*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�˿�����*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*������Ʒ*/
/*���в���С��������Ʒ�˿�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�˿�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�˿�����*/
select '���ְ���' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�˿�����*/
select '���ְ���' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�˿�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�˿�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
group by ca.Department
union
/*PM�������в�Ʒ�˿�����*/
select '���ְ���' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�˿�����*/
select '���ְ���' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*�ÿ�����*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join like_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '�ܱ�'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
/*���в���С����Ʒ�ÿ�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�ÿ�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�ÿ�����*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�ÿ�����*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�ÿ�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�ÿ�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�ÿ�����*/
select '���ְ���' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�ÿ�����*/
select '���ְ���' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�ÿ�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�ÿ�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�ÿ�����*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ�ÿ�����*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С�����в�Ʒ�ÿ�����*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�ÿ�����*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
group by ca.Department
union
/*PM�������в�Ʒ�ÿ�����*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('���۶���','��������')
union
/*���в������в�Ʒ�ÿ�����*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join like_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*��Ʒ*/
/*������С��������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�������*/
select '���ְ���' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�������*/
select '���ְ���' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
group by ca.Department
union
/*PM�������в�Ʒ�������*/
select '���ְ���' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�������*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from like_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '���ְ���' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��' from ca
union
/*������ƷתΪSPU��*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from like_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '���ְ���' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')

union
/*������ƷתΪSPU����ҵ��*/
select '���ְ���' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*��������SPU-SKU��*/
/*��Ʒ*/
/*������С����Ʒ����SPU��*/
select '���ְ���' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from like_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '���ְ���' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from like_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;


select t.category, t.department, t.ReportType, t.�ܴ�, t.product_tupe,round(a2.�������۶�-ifnull(a3.�˿��ܶ�,0),2) '���۶�' ,
round(a2.���������-ifnull(a5.��滨��,0)-ifnull(a3.�˿��ܶ�,0),2) '�����',round(((���������-ifnull(��滨��,0)-ifnull(�˿��ܶ�,0))/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) as '������',
������,round((�������۶�-ifnull(�˿��ܶ�,0))/������,2) '�͵���',�������۶�,���������,����������,
�˿��ܶ�,round((�˿��ܶ�/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�˿���',
�����˿���,round((�����˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�ѷ����˿���',
�������˿���,round((�������˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�������˿���',
��SPU��,����SPU��,����SPU��,תΪ�ص��ƷSPU��,תΪ�ص��Ʒ�������۶�,���ܳ���SPU��,`4�ܳ���SPU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SPU��,2) '��-��SPU����ҵ��',
round(Ŀǰ����������/����SPU��,2) 'ƽ��SPU����������',
round((���ܳ���SPU��/����SPU��)*100,2) 'SPU���ܶ�����',
round((`4�ܳ���SPU��`/����SPU��)*100,2) 'SPU4�ܶ�����',
��SKU��,����SKU��,����SKU��,���ܳ���SKU��,`4�ܳ���SKU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SKU��,2) '��-��SKU����ҵ��',
round(Ŀǰ����������/����SKU��,2) 'ƽ��SKU����������',
round((���ܳ���SPU��/����SKU��)*100,2) 'SKU���ܶ�����',
round((`4�ܳ���SPU��`/����SKU��)*100,2) 'SKU4�ܶ�����',
Ŀǰ����������,���ܿ�������������,���ܳ���������,`4�ܳ���������`,round((���ܳ���������/Ŀǰ����������)*100,2) '���ӵ��ܶ�����',
round((`4�ܳ���������`/Ŀǰ����������)*100,2) '����4�ܶ�����',
�ÿ���,�ÿ�����,������������,�ÿ�ת����,
�ع���, �����, �������, ��涩����, ���ת����, ������۶�, ��滨��, round((��滨��/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '��滨����',
round((������۶�/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '���ҵ��ռ��',���Acost, ���cpc, ���ع�Ĺ��Ͷ��, �г����Ĺ��Ͷ��,
ifnull(�ÿ���,0)-ifnull(�����,0) as '��Ȼ�����ÿ���',ifnull(�ÿ�����,0)-ifnull(��涩����,0) as '��Ȼ�����ÿ�����',
round(((ifnull(�ÿ�����,0)-ifnull(��涩����,0))/(ifnull(�ÿ���,0)-ifnull(�����,0)))*100,2) '��Ȼ�����ÿ�ת����'
from
(select '����ʱ��' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '����ʱ��' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '����ʱ��' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '����ʱ��' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '����ʱ��' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*ʵ��Ϊ����С������SPU��*/
inner join healthy_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�'))
/*��Ʒ*/
/*���в���С����Ʒ��������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where ca.Department  in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ��������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('����һ��','���۶���','��������')
group by ca.Department
union
select '����ʱ��' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='�����Ĳ�'

union
/*PM������Ʒ��������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('���۶���','��������')
union
/*���в�����Ʒ��������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ��������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ��������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '����ʱ��' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='�����Ĳ�'

union
/*PM�����ص��Ʒ��������*/
select '����ʱ��' as category,'PM' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ��������*/
select '����ʱ��' as category,'���в���' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*������Ʒ*/
/*���в���С��������Ʒ��������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '����ʱ��' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='�����Ĳ�'
union
/*PM����������Ʒ��������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ��������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ��������*/
select '����ʱ��' as category, concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������*/
select '����ʱ��' as category, ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by ca.Department
union
select '����ʱ��' as category, '�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department='�����Ĳ�'
union
/*PM�������в�Ʒ��������*/
select '����ʱ��' as category, 'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ��������*/
select '����ʱ��' as category, '���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join healthy_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')
)

/*���в���С����Ʒ*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '����ʱ��' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '����ʱ��' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='����'
inner join healthy_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*�������˿�����*/
/*������С����Ʒ�˿�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�˿�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�˿�����*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('���۶���','��������')
union
/*���в�����Ʒ�˿�����*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*���в���С���ص��Ʒ�˿�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�˿�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ�˿�����*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�˿�����*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*������Ʒ*/
/*���в���С��������Ʒ�˿�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�˿�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�˿�����*/
select '����ʱ��' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�˿�����*/
select '����ʱ��' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�˿�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�˿�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
group by ca.Department
union
/*PM�������в�Ʒ�˿�����*/
select '����ʱ��' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�˿�����*/
select '����ʱ��' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*�ÿ�����*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join healthy_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '�ܱ�'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
/*���в���С����Ʒ�ÿ�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�ÿ�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�ÿ�����*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�ÿ�����*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�ÿ�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�ÿ�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�ÿ�����*/
select '����ʱ��' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�ÿ�����*/
select '����ʱ��' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�ÿ�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�ÿ�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�ÿ�����*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ�ÿ�����*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С�����в�Ʒ�ÿ�����*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�ÿ�����*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
group by ca.Department
union
/*PM�������в�Ʒ�ÿ�����*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('���۶���','��������')
union
/*���в������в�Ʒ�ÿ�����*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join healthy_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*��Ʒ*/
/*������С��������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�������*/
select '����ʱ��' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�������*/
select '����ʱ��' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
group by ca.Department
union
/*PM�������в�Ʒ�������*/
select '����ʱ��' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�������*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from healthy_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '����ʱ��' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��' from ca
union
/*������ƷתΪSPU��*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from healthy_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '����ʱ��' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')

union
/*������ƷתΪSPU����ҵ��*/
select '����ʱ��' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*��������SPU-SKU��*/
/*��Ʒ*/
/*������С����Ʒ����SPU��*/
select '����ʱ��' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from healthy_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '����ʱ��' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from healthy_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;



select t.category, t.department, t.ReportType, t.�ܴ�, t.product_tupe,round(a2.�������۶�-ifnull(a3.�˿��ܶ�,0),2) '���۶�' ,
round(a2.���������-ifnull(a5.��滨��,0)-ifnull(a3.�˿��ܶ�,0),2) '�����',round(((���������-ifnull(��滨��,0)-ifnull(�˿��ܶ�,0))/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) as '������',
������,round((�������۶�-ifnull(�˿��ܶ�,0))/������,2) '�͵���',�������۶�,���������,����������,
�˿��ܶ�,round((�˿��ܶ�/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�˿���',
�����˿���,round((�����˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�ѷ����˿���',
�������˿���,round((�������˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�������˿���',
��SPU��,����SPU��,����SPU��,תΪ�ص��ƷSPU��,תΪ�ص��Ʒ�������۶�,���ܳ���SPU��,`4�ܳ���SPU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SPU��,2) '��-��SPU����ҵ��',
round(Ŀǰ����������/����SPU��,2) 'ƽ��SPU����������',
round((���ܳ���SPU��/����SPU��)*100,2) 'SPU���ܶ�����',
round((`4�ܳ���SPU��`/����SPU��)*100,2) 'SPU4�ܶ�����',
��SKU��,����SKU��,����SKU��,���ܳ���SKU��,`4�ܳ���SKU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SKU��,2) '��-��SKU����ҵ��',
round(Ŀǰ����������/����SKU��,2) 'ƽ��SKU����������',
round((���ܳ���SPU��/����SKU��)*100,2) 'SKU���ܶ�����',
round((`4�ܳ���SPU��`/����SKU��)*100,2) 'SKU4�ܶ�����',
Ŀǰ����������,���ܿ�������������,���ܳ���������,`4�ܳ���������`,round((���ܳ���������/Ŀǰ����������)*100,2) '���ӵ��ܶ�����',
round((`4�ܳ���������`/Ŀǰ����������)*100,2) '����4�ܶ�����',
�ÿ���,�ÿ�����,������������,�ÿ�ת����,
�ع���, �����, �������, ��涩����, ���ת����, ������۶�, ��滨��, round((��滨��/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '��滨����',
round((������۶�/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '���ҵ��ռ��',���Acost, ���cpc, ���ع�Ĺ��Ͷ��, �г����Ĺ��Ͷ��,
ifnull(�ÿ���,0)-ifnull(�����,0) as '��Ȼ�����ÿ���',ifnull(�ÿ�����,0)-ifnull(��涩����,0) as '��Ȼ�����ÿ�����',
round(((ifnull(�ÿ�����,0)-ifnull(��涩����,0))/(ifnull(�ÿ���,0)-ifnull(�����,0)))*100,2) '��Ȼ�����ÿ�ת����'
from
(select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*ʵ��Ϊ����С������SPU��*/
inner join other_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�'))
/*��Ʒ*/
/*���в���С����Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where ca.Department  in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='�����Ĳ�'

union
/*PM������Ʒ��������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('���۶���','��������')
union
/*���в�����Ʒ��������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='�����Ĳ�'

union
/*PM�����ص��Ʒ��������*/
select '������Ŀ' as category,'PM' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ��������*/
select '������Ŀ' as category,'���в���' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*������Ʒ*/
/*���в���С��������Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='�����Ĳ�'
union
/*PM����������Ʒ��������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ��������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ��������*/
select '������Ŀ' as category, concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������*/
select '������Ŀ' as category, ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category, '�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department='�����Ĳ�'
union
/*PM�������в�Ʒ��������*/
select '������Ŀ' as category, 'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ��������*/
select '������Ŀ' as category, '���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join other_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')
)

/*���в���С����Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='����'
inner join other_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*�������˿�����*/
/*������С����Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('���۶���','��������')
union
/*���в�����Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*���в���С���ص��Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*������Ʒ*/
/*���в���С��������Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
group by ca.Department
union
/*PM�������в�Ʒ�˿�����*/
select '������Ŀ' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�˿�����*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*�ÿ�����*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join other_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '�ܱ�'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
/*���в���С����Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С�����в�Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
group by ca.Department
union
/*PM�������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('���۶���','��������')
union
/*���в������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join other_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*��Ʒ*/
/*������С��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
group by ca.Department
union
/*PM�������в�Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from other_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��' from ca
union
/*������ƷתΪSPU��*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from other_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')

union
/*������ƷתΪSPU����ҵ��*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*��������SPU-SKU��*/
/*��Ʒ*/
/*������С����Ʒ����SPU��*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from other_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from other_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;



select t.category, t.department, t.ReportType, t.�ܴ�, t.product_tupe,round(a2.�������۶�-ifnull(a3.�˿��ܶ�,0),2) '���۶�' ,
round(a2.���������-ifnull(a5.��滨��,0)-ifnull(a3.�˿��ܶ�,0),2) '�����',round(((���������-ifnull(��滨��,0)-ifnull(�˿��ܶ�,0))/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) as '������',
������,round((�������۶�-ifnull(�˿��ܶ�,0))/������,2) '�͵���',�������۶�,���������,����������,
�˿��ܶ�,round((�˿��ܶ�/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�˿���',
�����˿���,round((�����˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�ѷ����˿���',
�������˿���,round((�������˿���/(ifnull(�˿��ܶ�,0)+(�������۶�-ifnull(�˿��ܶ�,0))))*100,2) as '�������˿���',
��SPU��,����SPU��,����SPU��,תΪ�ص��ƷSPU��,תΪ�ص��Ʒ�������۶�,���ܳ���SPU��,`4�ܳ���SPU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SPU��,2) '��-��SPU����ҵ��',
round(Ŀǰ����������/����SPU��,2) 'ƽ��SPU����������',
round((���ܳ���SPU��/����SPU��)*100,2) 'SPU���ܶ�����',
round((`4�ܳ���SPU��`/����SPU��)*100,2) 'SPU4�ܶ�����',
��SKU��,����SKU��,����SKU��,���ܳ���SKU��,`4�ܳ���SKU��`,
round((�������۶�-ifnull(�˿��ܶ�,0))/���ܳ���SKU��,2) '��-��SKU����ҵ��',
round(Ŀǰ����������/����SKU��,2) 'ƽ��SKU����������',
round((���ܳ���SPU��/����SKU��)*100,2) 'SKU���ܶ�����',
round((`4�ܳ���SPU��`/����SKU��)*100,2) 'SKU4�ܶ�����',
Ŀǰ����������,���ܿ�������������,���ܳ���������,`4�ܳ���������`,round((���ܳ���������/Ŀǰ����������)*100,2) '���ӵ��ܶ�����',
round((`4�ܳ���������`/Ŀǰ����������)*100,2) '����4�ܶ�����',
�ÿ���,�ÿ�����,������������,�ÿ�ת����,
�ع���, �����, �������, ��涩����, ���ת����, ������۶�, ��滨��, round((��滨��/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '��滨����',
round((������۶�/(�������۶�-ifnull(�˿��ܶ�,0)))*100,2) '���ҵ��ռ��',���Acost, ���cpc, ���ع�Ĺ��Ͷ��, �г����Ĺ��Ͷ��,
ifnull(�ÿ���,0)-ifnull(�����,0) as '��Ȼ�����ÿ���',ifnull(�ÿ�����,0)-ifnull(��涩����,0) as '��Ȼ�����ÿ�����',
round(((ifnull(�ÿ�����,0)-ifnull(��涩����,0))/(ifnull(�ÿ���,0)-ifnull(�����,0)))*100,2) '��Ȼ�����ÿ�ת����'
from
(select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,concat(Department,'-',NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������')
group by concat(Department,'-',NodePathName)
union
select '������Ŀ' as category,Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe
from mysql_store
where Department  in ('����һ��','���۶���','��������','�����Ĳ�')
group by Department
) t
left join
(
/*Ŀǰ����SPU-SKU��-Ŀǰ�ۼ�SPU-SKU��*/
with ca as (
select go.SKU,go.SPU,go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,ListingStatus,ShopStatus,ShopCode,SellerSKU,PublicationDate
FROM erp_amazon_amazon_listing al  /*ʵ��Ϊ����С������SPU��*/
inner join proall_category as go
on go.SKU=al.SKU
and al.SKU <>''
and go.ProductStatus<>2
and go.DevelopLastAuditTime<'2022-12-26'
inner join mysql_store s
on s.code = al.ShopCode
and al.PublicationDate < '2022-12-26'
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�'))
/*��Ʒ*/
/*���в���С����Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where ca.Department  in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department  in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department ='�����Ĳ�'

union
/*PM������Ʒ��������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department  in ('���۶���','��������')
union
/*���в�����Ʒ��������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when 1=1 then SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SPU end)'����SPU��',
count(distinct case when 1=1 then SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������'
from ca
where  DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department ='�����Ĳ�'

union
/*PM�����ص��Ʒ��������*/
select '������Ŀ' as category,'PM' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ��������*/
select '������Ŀ' as category,'���в���' as  Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
inner join lead_product lp
on ca.SKU=lp.SKU
union
/*������Ʒ*/
/*���в���С��������Ʒ��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category,'�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department='�����Ĳ�'
union
/*PM����������Ʒ��������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ��������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from  ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ��������*/
select '������Ŀ' as category, concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������*/
select '������Ŀ' as category, ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in  ('����һ��','���۶���','��������')
group by ca.Department
union
select '������Ŀ' as category, '�����Ĳ�' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department='�����Ĳ�'
union
/*PM�������в�Ʒ��������*/
select '������Ŀ' as category, 'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ��������*/
select '������Ŀ' as category, '���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when 1=1 then ca.SPU end) '��SPU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SPU end)'����SPU��',
count(distinct case when 1=1 then ca.SKU end) '��SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then ca.SKU end)'����SKU��',
count(distinct  case when ListingStatus=1 and ShopStatus='����'then concat(ShopCode,'-',SellerSKU) end)'Ŀǰ����������',
count(distinct  case when ListingStatus=1 and ShopStatus='����'and PublicationDate >=date_add('2022-12-26',interval -7 day ) and PublicationDate < '2022-12-26'
      then concat(ShopCode,'-',SellerSKU) end)'���ܿ�������������' from ca
) as a1
on t.department=a1.department
and t.product_tupe=a1.product_tupe
left join
(
/*���۶������������������SKU����������SPU��������������������*/
with ca as (
select go.BoxSku,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join proall_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -28 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -28 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')
)

/*���в���С����Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ����������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'/*�������۲�����Ʒ*/
group by ca.Department
union
/*PM������Ʒ�������ݼ���������*/
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������ݼ���������*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ����*/
/*�ص��Ʒ��С������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('����һ��','���۶���','��������')/*�������۲���С����Ʒ*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���в��Ÿ������ص��Ʒ����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('���۶���','��������')
union
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*������Ʒ-����Ʒ���ص��Ʒ��������Ʒ*/
/*���в���С��������Ʒ*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*PM����������Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С���������������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ��������������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
group by ca.Department
union
/*PM���ų�������������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca
where ca.Department in ('��������','���۶���')
union
/*���в������в�Ʒ��������������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '���ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26' and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.SPU end ) '4�ܳ���SPU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '���ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4�ܳ���SKU��',
count(distinct case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '���ܳ���������',
count(distinct case when PayTime>=date_add('2022-12-26',interval -28 day) and PayTime<'2022-12-26'and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4�ܳ���������',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'�������۶�',
round(sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'���������',
round((sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-12-26',interval -7 day) and PayTime<'2022-12-26' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '����������'
from ca) as a2
on t.department=a2.department
and a1.product_tupe=a2.product_tupe
left join
(
/*�˿�����(Ŀǰ����Դ�������� 1���������д������SKU�������˿����ֻ��һ�ʶ��� 2��һ�ʶ������������˿�)*/
with ca as (
select go.BoxSKU,go.DevelopLastAuditTime,Department,NodePathName,RefundUSDPrice,ShipDate,RefundReason2 from RefundOrders ro
inner join OrderDetails od
on ro.PlatOrderNumber=od.PlatOrderNumber
and od.TransactionType='����'
inner join proall_category as go
on go.BoxSKU=od.BoxSku
inner join mysql_store s
on s.Code=ro.OrderSource
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where RefundDate >= date_add('2022-12-26',interval -7 day) and RefundDate < '2022-12-26'
)
/*�������˿�����*/
/*������С����Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and Department in ('���۶���','��������')
union
/*���в�����Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*PM������Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*���в���С���ص��Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
group by ca.Department
union
/*PM�����ص��Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
and Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',/*���в����ص��Ʒ�˿�����*/
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
inner join lead_product lp
on ca.BoxSKU=lp.BoxSKU
union
/*������Ʒ*/
/*���в���С��������Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�˿�����*/
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�˿�����*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�˿�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�˿�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
group by ca.Department
union
/*PM�������в�Ʒ�˿�����*/
select '������Ŀ' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�˿�����*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(ca.RefundUSDPrice) '�˿��ܶ�',
sum(case when ShipDate>'2000-01-02' then ca.RefundUSDPrice end) '�����˿���',
sum(case when ShipDate='2000-01-01' and RefundReason2 in ('�ͻ�����ԭ��', '������ȡ������') then ca.RefundUSDPrice end) '�������˿���' from ca
) as a3
on t.department=a3.department
and a1.product_tupe=a3.product_tupe
left join
(
/*�ÿ�����*/
with ca as (
select Department,NodePathName,go.SKU,go.BoxSKU,go.DevelopLastAuditTime,TotalCount,FeaturedOfferPercent,OrderedCount,ChildAsin,aa.ShopCode from erp_amazon_amazon_listing  as al
inner join proall_category as go
on al.Sku =go.SKU
inner join ListingManage aa
on aa.ChildAsin = al.ASIN
and aa.ShopCode = al.ShopCode
and aa.ReportType = '�ܱ�'
inner join mysql_store s
on s.code = al.shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.Monday=date_add('2022-12-26',interval -7 day)
and aa.TotalCount*aa.FeaturedOfferPercent/100>0
)
/*�ÿ������ÿ��������ÿ�ת����*/
/*���в���С����Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName)  as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������'  from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('���۶���','��������')
union
/*���в���������Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*���в���С�����в�Ʒ�ÿ�����*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
group by ca.Department
union
/*PM�������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca
where ca.Department in ('���۶���','��������')
union
/*���в������в�Ʒ�ÿ�����*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
round(sum(TotalCount * FeaturedOfferPercent / 100)) '�ÿ���', sum(OrderedCount) '�ÿ�����',round((sum(OrderedCount)/sum(TotalCount * FeaturedOfferPercent / 100))*100,2) '�ÿ�ת����',count(distinct concat(ca.ChildAsin,'-',ca.ShopCode))'������������' from ca) as a4
on t.department=a4.department
and a1.product_tupe=a4.product_tupe
left join
(
with ca as (
select go.SKU,go.BoxSKU,DevelopLastAuditTime,Department,NodePathName,TotalSale7Day,TotalSale7DayUnit,Spend,Clicks,Exposure,UnitsOrdered7d,aa.SellerSKU,aa.ShopCode from erp_amazon_amazon_listing as al
inner join proall_category as go
on al.Sku =go.SKU
inner join AdServing_Amazon aa
on aa.SellerSKU = al.SellerSKU
and aa.shopcode = al.ShopCode
inner join mysql_store as s
on s.code = aa.Shopcode
and s.Department in ('����һ��','���۶���','��������','�����Ĳ�')
where aa.CreatedTime >=date_add('2022-12-26',interval -8 day) and aa.CreatedTime < date_add('2022-12-26',interval -1 day)
)
/*��Ʒ*/
/*������С��������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where ca.Department in ('����һ��','���۶���','��������')
and DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by concat(ca.Department,'-',ca.NodePathName)
union
/*��������Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
group by ca.Department
union
/*PM������Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
and ca.Department in ('���۶���','��������')
union
/*���в�����Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'
from ca
where DevelopLastAuditTime >=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
union
/*�ص��Ʒ*/
/*������С���ص��Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
where ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*�������ص��Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
group by ca.Department
union
/*PM�����ص��Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
and ca.Department in ('���۶���','��������')
union
/*���в����ص��Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
inner join lead_product as lp
on ca.Sku =lp.SKU
union
/*������Ʒ*/
/*������С��������Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*������������Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM����������Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('���۶���','��������')
union
/*���в���������Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*���в�Ʒ*/
/*������С�����в�Ʒ�������*/
select '������Ŀ' as category,concat(ca.Department,'-',ca.NodePathName) as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('����һ��','���۶���','��������')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*���������в�Ʒ�������*/
select '������Ŀ' as category,ca.Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
group by ca.Department
union
/*PM�������в�Ʒ�������*/
select '������Ŀ' as category,'PM' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca
where Department in ('���۶���','��������')
union
/*���в������в�Ʒ�������*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','-' as product_tupe,
sum(Exposure) as '�ع���',sum(Clicks) '�����',round((sum(Clicks)/sum(Exposure))*100,2)  '�������',sum(TotalSale7DayUnit) '��涩����',
round((sum(TotalSale7DayUnit)/sum(Clicks))*100,2)  '���ת����',sum(TotalSale7Day) '������۶�',sum(Spend) '��滨��',
round((sum(Spend)/sum(TotalSale7Day))*100,2) '���Acost',round((sum(Spend)/sum(Clicks)),3) '���cpc',
count (distinct case when Exposure>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '���ع�Ĺ��Ͷ��',
count(distinct case when UnitsOrdered7d>0 then concat(ca.SellerSKU,'-',ShopCode) end ) '�г����Ĺ��Ͷ��'from ca) as a5
on t.department=a5.department
and a1.product_tupe=a5.product_tupe
left join
(
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from proall_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��' from ca
union
/*������ƷתΪSPU��*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
count(distinct ca.SPU) 'תΪ�ص��ƷSPU��'from ca
where ca.DevelopLastAuditTime<date_add('2022-09-30',interval -1 day) ) as a6
on t.department=a6.Department
and a1.product_tupe=a6.product_tupe
left join
(
/*תΪ�ص��Ʒ����ҵ��*/
with ca as(
select lp.SPU,lp.BoxSKU,lp.DevelopLastAuditTime from proall_category  go
inner join lead_product lp
on go.BoxSKU=lp.BoxSKU
and go.SKU=lp.SKU
where UpdateTime>=date_add('2022-12-26',interval -7 day)
and UpdateTime<'2022-12-26'
)
/*��Ʒ*/
/*���в�����Ʒת�ص��Ʒ*/
select '������Ŀ' as category,'���в���'as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','�ص��Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime>=date_add('2022-09-30',interval -1 day) and DevelopLastAuditTime<'2022-12-26'
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')

union
/*������ƷתΪSPU����ҵ��*/
select '������Ŀ' as category,'���в���' as Department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','������Ʒ' as product_tupe,
round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / ExchangeUSD
),2) 'תΪ�ص��Ʒ�������۶�' from ca
inner join OrderDetails od
on ca.BoxSKU=od.BoxSku
and DevelopLastAuditTime<date_add('2022-09-30',interval -1 day)
join import_data.mysql_store s
on s.code = od.ShopIrobotId
left join import_data.Basedata b
on b.ReportType = '�ܱ�'
and b.FirstDay = date_add('2022-12-26',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-12-26',interval -7 day)
and PayTime <'2022-12-26'
and od.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
where
ShipmentStatus = 'δ����' and OrderStatus = '����'
and PayTime >=date_add('2022-12-26',interval -7 day) and PayTime < '2022-12-26'
group by OrderNumber) a
where alltype = '����')) as a7
on t.department=a7.Department
and a1.product_tupe=a7.product_tupe
left join
(/*��������SPU-SKU��*/
/*��Ʒ*/
/*������С����Ʒ����SPU��*/
select '������Ŀ' as category,'���в���' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from proall_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26'
union
select '������Ŀ' as category,'PM' as department,'�ܱ�' as ReportType,weekofyear('2022-12-26') as '�ܴ�','��Ʒ' as product_tupe,
count(distinct SPU) '����SPU��',count(distinct sku) '����SKU��' from proall_category
where DevelopLastAuditTime >=date_add('2022-12-26',interval -7 day ) and DevelopLastAuditTime<'2022-12-26') as a8
on t.department=a8.department
and a1.product_tupe=a8.product_tupe
order by t.department ,t.product_tupe desc;