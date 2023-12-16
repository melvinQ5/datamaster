/*
 * Ŀ�ģ�
 * 	Ӧ�ó���1 ����Ƿ񿪹��
 * 	Ӧ�ó���2 ֧���Զ���������
 * ���㣺
 * 	Ϊ�˼���Ƿ񿪹�棬Ϊ���̳���Ʒ���ֺõ�δ���������ݣ�ȥͬ����Ʒ����
 * 
 * ����Դ��
 * 	��� > ����� > ����Ʒ
 * select * from amazon_ad_groups limit 10;
 * select * from amazon_ad_products limit 10;
 * select * from amazon_ad_campaigns limit 10;
 * 	amazon_ad_campaigns -- 3w������
 * 	amazon_ad_groups -- Լ���ڹ���Ʒ�� 2200w������ 
 *  erp_amazon_amazon_ad_products  -- 2200w������
*/

-- �¿��� �Ƿ񿪹��
with t_list as ( -- ���¿����������� ����������Ʒ��
select wl.id ,wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	MinPublicationDate >= '${StartDay}' 
	and MinPublicationDate < '${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
	and wl.ListingStatus =1 and ms.shopstatus = '����'
)


select count(1) from (

select ta.sellersku , ta.shopcode ,ta.asin ,NodePathName ,SellUserName
from t_list ta
left join import_data.erp_amazon_amazon_ad_products tb on ta.id =tb.ListingId -- 1�Զ�left join,��ȥ�� 
where tb.ListingId is null
group by ta.sellersku , ta.shopcode ,ta.asin ,NodePathName ,SellUserName

) tb 



	
	
