select wo.boxsku 出单塞盒sku ,wo.sellersku 渠道sku ,shopcode ,PayTime 付款时间 ,Department 出单部门 ,epp.ProjectTeam ERP产品列表归属部门 ,epp.ProductName
from (
    select wo.* from wt_orderdetails wo join import_data.mysql_store ms on wo.shopcode=ms.Code
    where
        PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'
        and wo.IsDeleted=0
        and ms.Department = '快百货' and TransactionType != '其他'
        and boxsku =  4705982 -- 复制后的SKU在ERP特卖汇
        -- and boxsku =  1873998 源SKU在ERP快百货
    ) wo
left join erp_product_products epp on epp.BoxSKU = wo.BoxSku and epp.IsMatrix=0 and epp.ProjectTeam not regexp '快百货'



