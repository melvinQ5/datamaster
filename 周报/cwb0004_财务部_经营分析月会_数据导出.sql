
-- ��������
select handletime as �·� , memo as ָ�� , handlename as ���� ,c4 + 0 as ָ��ֵ
from manual_table where c1 = '��Ӫ�����»�' 
and c2 =2023 and c3 = 11
and handlename != '�������' 
and memo not regexp '�����˿�|�����|SkU������'  -- �޳���д���ָ������
order by handletime  , memo ,handlename;