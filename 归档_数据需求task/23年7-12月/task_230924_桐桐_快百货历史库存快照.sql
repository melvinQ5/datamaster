


select CreatedTime , sum(TotalPrice) as ������
FROM import_data.daily_WarehouseInventory wi
join ( select distinct BoxSku ,projectteam as department from wt_products where projectteam = '��ٻ�') tmp on wi.BoxSku = tmp.BoxSku
where WarehouseName = '��ݸ��' and TotalInventory > 0
  and CreatedTime = date_add('2023-08-01',interval -1 day)
group by CreatedTime
union all
select CreatedTime , sum(TotalPrice) as ������
FROM import_data.daily_WarehouseInventory wi
join ( select distinct BoxSku ,projectteam as department from wt_products where projectteam = '��ٻ�') tmp on wi.BoxSku = tmp.BoxSku
where WarehouseName = '��ݸ��' and TotalInventory > 0
  and CreatedTime = date_add('2023-07-01',interval -1 day)
group by CreatedTime
union all
select CreatedTime , sum(TotalPrice) as ������
FROM import_data.daily_WarehouseInventory wi
join ( select distinct BoxSku ,projectteam as department from wt_products where projectteam = '��ٻ�') tmp on wi.BoxSku = tmp.BoxSku
where WarehouseName = '��ݸ��' and TotalInventory > 0
  and CreatedTime = date_add('2023-06-01',interval -1 day)
group by CreatedTime
union all
select CreatedTime , sum(TotalPrice) as ������
FROM import_data.daily_WarehouseInventory wi
join ( select distinct BoxSku ,projectteam as department from wt_products where projectteam = '��ٻ�') tmp on wi.BoxSku = tmp.BoxSku
where WarehouseName = '��ݸ��' and TotalInventory > 0
  and CreatedTime = date_add('2023-05-01',interval -1 day)
group by CreatedTime
union all
select CreatedTime , sum(TotalPrice) as ������
FROM import_data.daily_WarehouseInventory wi
join ( select distinct BoxSku ,projectteam as department from wt_products where projectteam = '��ٻ�') tmp on wi.BoxSku = tmp.BoxSku
where WarehouseName = '��ݸ��' and TotalInventory > 0
  and CreatedTime = date_add('2023-04-01',interval -1 day)
group by CreatedTime