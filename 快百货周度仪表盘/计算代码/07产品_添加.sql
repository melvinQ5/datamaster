insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewAddSpuCnt )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 as weeks
	,count(distinct wp.spu ) `���SPU��`
from import_data.erp_product_products wp
join erp_product_product_statuses epps -- ÿ����Ʒ�������һ��������ÿ��״̬���м�¼����IsCurrentStage����ʾ����
    on wp.Id = epps.ProductId
    and IsCurrentStage = 1 and DevelopStage >10 -- �޳��������ύ�����ݣ����ݸ���
where Creationtime < '${NextStartDay}' and Creationtime >= '${StartDay}' and ProjectTeam = '��ٻ�' and IsMatrix=0
  and status != 20  -- ���������ϣ������������кͿ������
group by ProjectTeam;
