select wo.boxsku ��������sku ,wo.sellersku ����sku ,shopcode ,PayTime ����ʱ�� ,Department �������� ,epp.ProjectTeam ERP��Ʒ�б�������� ,epp.ProductName
from (
    select wo.* from wt_orderdetails wo join import_data.mysql_store ms on wo.shopcode=ms.Code
    where
        PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'
        and wo.IsDeleted=0
        and ms.Department = '��ٻ�' and TransactionType != '����'
        and boxsku =  4705982 -- ���ƺ��SKU��ERP������
        -- and boxsku =  1873998 ԴSKU��ERP��ٻ�
    ) wo
left join erp_product_products epp on epp.BoxSKU = wo.BoxSku and epp.IsMatrix=0 and epp.ProjectTeam not regexp '��ٻ�'



