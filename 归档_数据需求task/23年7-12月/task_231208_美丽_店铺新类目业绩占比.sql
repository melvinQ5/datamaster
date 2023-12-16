with
mysql_store_team as ( -- �޳�������Ӫ��,����dep2����ά��
select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,* from import_data.mysql_store where Department = '��ٻ�' and NodePathName != '������Ӫ��'
)

,online_lst as (
select ifnull(c3,'������Ŀ') һ����Ŀ,ifnull(c4,'������Ŀ') ������Ŀ ,ifnull(c5,'������Ŀ') ������Ŀ ,ShopCode ,11 as month
,count(distinct concat(eaal.ShopCode,eaal.SellerSKU)) ����������
from erp_amazon_amazon_listing eaal join mysql_store_team ms on eaal.ShopCode=ms.Code and ms.Department='��ٻ�'
left join manual_table j on  handlename='����_��ٻ��¾���Ŀ����_231208' and j.memo=eaal.sku
group by ifnull(c3,'������Ŀ') ,ifnull(c4,'������Ŀ')  ,ifnull(c5,'������Ŀ')  ,ShopCode )

,od as (
select month(SettlementTime) set_month ,CompanyCode ,shopcode ,ms.site ,dep2 ,NodePathName ,SellUserName ,ifnull(c3,'������Ŀ') һ����Ŀ,ifnull(c4,'������Ŀ') ������Ŀ ,ifnull(c5,'������Ŀ') ������Ŀ
,round(sum( TotalGross/ExchangeUSD) ,2) ���۶�S3
,round(sum( TotalProfit/ExchangeUSD) ,2) �����M3
,round(sum( TotalProfit ) /sum( TotalGross) ,2) ������R3
from wt_orderdetails  wo
join mysql_store_team ms on wo.shopcode = ms.code
left join manual_table j on  handlename='����_��ٻ��¾���Ŀ����_231208' and j.c2=wo.boxsku
where settlementtime >= '2023-01-01' and settlementtime < '2023-12-01' and IsDeleted=0
group by month(SettlementTime) ,CompanyCode ,shopcode ,ms.site ,dep2 ,NodePathName ,SellUserName ,ifnull(c3,'������Ŀ') ,ifnull(c4,'������Ŀ') ,ifnull(c5,'������Ŀ') )

,res as (
select od.* ,���������� from od left join  online_lst lst on od.shopcode =lst.shopcode and  od.һ����Ŀ =lst.һ����Ŀ and  od.������Ŀ =lst.������Ŀ and  od.������Ŀ =lst.������Ŀ and od.set_month =lst.month
)

select  *
,round( ���۶�S3 / sum(���۶�S3) over (partition by set_month ,shopcode ) ,4 ) �����۶�ռ��
,round( �����M3 / sum(�����M3) over (partition by set_month ,shopcode ) ,4 ) �������ռ��
,round( ���������� / sum(����������) over (partition by set_month ,shopcode ) ,4 ) ��������ռ��
from res

