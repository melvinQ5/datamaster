with 
ta as (
select [
'1000034.01',
'1070064.01',
'1069957.01',
'1070066.01',
'1000417.01',
'1000854.01',
'1001264.01',
'1049914.10',
'1001534.01',
'1001704.01',
'1001911.01',
'1049981.03',
'1002458.01',
'1002497.01',
'1002665.01',
'1070067.01',
'1002801.01',
'1050050.01',
'1003051.01',
'1003257.01',
'1003327.01',
'1003484.01',
'1003946.01',
'1004386.01',
'1004839.01',
'1004990.01',
'1004991.01',
'1005729.01',
'1005885.01',
'1050135.05',
'1006126.01',
'1007616.01',
'1008023.01',
'1050202.02',
'1008379.01',
'1008547.01',
'1009056.01',
'1009409.01',
'1050534.01',
'1010127.01',
'1010738.01',
'1010811.01',
'1011897.01',
'1012033.01',
'1012384.01',
'1012519.01',
'1012828.01',
'1012884.01',
'1012910.01',
'1051851.02',
'1013841.01',
'1141302.01',
'1014985.01',
'1015259.01',
'1015296.01',
'1015372.01',
'1015412.01',
'1070089.01',
'1016687.01',
'1016744.01',
'1053154.01',
'1146340.01',
'1018213.01',
'1019576.01',
'1019894.01',
'1054318.02',
'1070096.01',
'1021217.01',
'1054940.02',
'1022517.01',
'1022764.01',
'1022953.01',
'1022982.01',
'1055529.01',
'1023043.01',
'1055669.02',
'1068313.01',
'1023487.01',
'1023534.01',
'1023758.01',
'1024233.01',
'1026151.01',
'1026799.01',
'1068681.01',
'1027180.01',
'1027852.01',
'1028055.01',
'1028074.01',
'1056875.01',
'1029426.01',
'1029482.01',
'1029807.01',
'1029883.01',
'1029886.01',
'1029988.01',
'1030068.01',
'1030849.01',
'1030998.01',
'1031230.01',
'1057449.01',
'1031682.01',
'1032352.01',
'1070143.01',
'1032560.01',
'1058266.04',
'1058354.03',
'1033807.01',
'1118331.02',
'1035477.01',
'1058716.02',
'1035849.01',
'1036013.01',
'1036793.01',
'1059046.01',
'1058807.05',
'1059278.02',
'1038352.01',
'1038877.01',
'1038965.01',
'1059761.05',
'1039209.01',
'1039237.01',
'1060090.01',
'1039883.01',
'1060421.03',
'1060424.01',
'1040337.01',
'1040581.01',
'1060781.01',
'1059857.06',
'1061409.02',
'1061585.04',
'1060856.02',
'1044563.01',
'1060856.10',
'1044883.01',
'1060856.13',
'1044988.01',
'1063254.05',
'1045079.01',
'1063690.02',
'1063690.10',
'1063729.01',
'1046402.01',
'1046600.01',
'1065470.03',
'1049749.01',
'5007577.01',
'5006114.02',
'5007852.01',
'5010421.02',
'5014947.01',
'5018726.01',
'5019304.03',
'5024689.01',
'5030830.01',
'5032334.01',
'5031232.01',
'5032803.01',
'5034363.01',
'5034381.02',
'5035685.01',
'5036212.01',
'5036697.01',
'5037136.01',
'5037169.01',
'5040180.01',
'5041671.01',
'5044187.02',
'5044453.01',
'5044327.01',
'5080465.01',
'5087741.01',
'5090613.01',
'5097434.01',
'5110990.01',
'5112621.01',
'5110179.01',
'5113408.01',
'5110972.01',
'5112156.01',
'5118676.01',
'5113869.01',
'5108209.01',
'5121105.01',
'5122536.01',
'5131990.01',
'5132007.01',
'5133591.01',
'5125714.01',
'5134451.01',
'5133156.01',
'5129243.01',
'5141759.01',
'5140737.01',
'5145438.01',
'5121933.01',
'5148575.01',
'5150138.01',
'5146896.01',
'5154909.01',
'5159930.01'
] arr 
)

,tb as (
select * 
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)

,t_list as ( -- 在线链接
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from tb
join import_data.erp_amazon_amazon_listing wl on tb.arr = wl.SKU 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
	and wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
--     and wl.sku='1008023.01'
)

,t_list_stat as ( -- 表1 刊登计算
select sku 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉3` 
-- 	,min(PublicationDate) `首次刊登时间`
from t_list
group by sku )
-- 统计
select *
from tb 
left join t_list_stat b on tb.arr = b.sku
where sku ='1008023.01' ;


select ms.NodePathName 
from  import_data.erp_amazon_amazon_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
	and wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
    and wl.sku='1008023.01'

