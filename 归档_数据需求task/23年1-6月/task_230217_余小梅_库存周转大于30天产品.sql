-- �ֿ�Ŀǰ�����ת������ʮ��Ĳ�Ʒ��   ������ͼ۸�Ƚϸߵ�1���ظ�

/* Ŀ�ģ�����һ����Щ��Ʒ�����ת����ԭ��ҵ���Ż�
 * SKUͳ�Ʒ�Χ��ERP��Ʒ�����Ϊ ��ٻ�
 * �����ת������(`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����*ͳ������
 * 		��������ʱ�䷶Χ����ȡ��30��ɹ��µ�������;���ݺͷ���������Ʒ��230108-230216��
 * 
 * ����ͳ�Ʒ�Χ����ٻ�������������, ����ʱ�� 230108-230216
 * �վ�����sku�������վ�������=���۶� �� ͳ��������Ĭ��30�죬���״ο���ʱ���ͳ���ղ���30�죬ʹ��ͳ����-�״ο���ʱ�䣩
 */


with stat as (
select b.BoxSku
	,���������ɹ����
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${NextStartDay}','${StartDay}'),1) `�����ת����`
	,`�ڲ�sku����`,`�ڲ�sku��` , `�ڲֲ�Ʒ���`
from
 (
	SELECT BoxSku
		,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��` 
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory , wi.BoxSku
		FROM import_data.daily_WarehouseInventory wi
		join (select BoxSku from import_data.erp_product_products epp  where projectteam = '��ٻ�' and BoxSku is not null ) tmp 
			on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '��ݸ��' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by BoxSku 
) b 

left join (
select BoxSku
	, sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����` , ifnull(sum(SkuFreight),0) `��;��Ʒ�ɹ��˷�`
from (
	select Price ,DiscountedPrice , SkuFreight , wp.BoxSku
	from wt_purchaseorder wp 
	join (select BoxSku from import_data.erp_product_products epp  where projectteam = '��ٻ�' and BoxSku is not null ) tmp 
		on wp.BoxSku = tmp.BoxSku 
	where  ordertime >= '${StartDay}' and ordertime < '${NextStartDay}'
		and isOnWay = "��" and WarehouseName = '��ݸ��'
	) tmp	
group by BoxSku 
) a 
on a.BoxSku = b.BoxSku

left join (	
	select BoxSku , round(sum(pc)) `���������ɹ����` 
	from ( select distinct pd.OrderNumber, pd.BoxSku , abs(od.PurchaseCosts) pc 
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1) and Department = '��ٻ�'
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' 
		) a 
	group by BoxSku  
) c on a.BoxSku = c.BoxSku
)

, od as (
select wo.boxsku , round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) `���۶�`  
from wt_orderdetails wo 
join stat on stat.boxsku = wo.BoxSku and IsDeleted = 0 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' and Department = '��ٻ�'
group by wo.BoxSku 
)

, lt as (
select wl.boxsku , min(PublicationDate) min_publicationdate
from stat
join wt_listing wl on stat.boxsku = wl.BoxSku and IsDeleted = 0 
group by wl.boxsku 

)

select wp.sku ,stat.boxsku
	, stat.`�����ת����`
	, wp.ProductName `��Ʒ����`
	, wp.cat1 
	, wp.cat2
	, wp.cat3 
	, wp.LastPurchasePrice `���²ɹ���`
-- 	, `���վ�����`
	, case when ProductStatus = 0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as `��Ʒ״̬`
	, `�ڲֲ�Ʒ���`
	, `�ڲ�sku����`
	, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `ͳ������`
	, case when DATEDIFF(CURRENT_DATE(),min_publicationdate) <= 30 then round(`���۶�`/DATEDIFF(CURRENT_DATE(),min_publicationdate),1)
		when DATEDIFF(CURRENT_DATE(),min_publicationdate) > 30 then round(`���۶�`/30,1)
	end as `�վ�����sku����`
from stat
join import_data.wt_products wp on stat.boxsku = wp.boxsku and wp.isdeleted = 0 and `�����ת����` >= 30
left join od on stat.boxsku = od.boxsku 
left join lt on stat.boxsku = lt.boxsku 
