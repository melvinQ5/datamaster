select GenerateDate from wt_adserving_amazon_daily where sku is null group by GenerateDate order by GenerateDate desc

-- todo ��ʱȡ shopcode + sellersku ���翯��ʱ��� sku ��Ϊ������ϵ��

-- �������Ƿ�ɹ�
select '2.1��wt_adserving_amazon_daily��',abs(t1.�����-t2.�����),abs(t1.��滨��-t2.��滨��) from
(
select '���' as team,sum(AdClicks) '�����',sum(AdSpend) '��滨��' from wt_adserving_amazon_daily
where GenerateDate>=date_add(current_date(),interval -91 day)
) t1
left join
(
select '���' as team,sum(Clicks) '�����',sum(Spend) '��滨��' from AdServing_Amazon
where Asin<>'') t2
on t1.team=t2.team
