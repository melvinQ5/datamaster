

select
c1 当期第一天,c2 报表,c3 ShopStatus,c4 shopcode
,c5 链接刊登划分
,c6 终审年月
,c7 新老品
,c8 优先级元素
,c9 自然周月
,c10 当期第一天, c11 CompanyCode,  c12 AccountCode, c13 区域, c14 销售小组, c15 销售人员,
0 + c16 销量, 0 + c17 销售额, 0 + c18 利润额_扣ad, 0 + c19 利润额_未扣ad,  0 + c20 销售额_扣运费未扣退款,  0 + c21 利润额_扣运费未扣退款,
0 + c22 退款额,
0 + c23 广告曝光量, 0 + c24 广告花费, 0 + c25 广告销售额, 0 + c26 广告销量, 0 + c27 广告点击量
, 0 + c28 运费收入, round(0 + c29,2) 交易成本, 0 + c30 采购成本, 0 + -1*c31 物流成本
,c32 主题
,c33 高潜
,c34 一级类目
,c35 是否结算项记录
,c36 在线渠道SKU数
from manual_table_duplicate where c2 ='${ReportType}'
order by c1;
