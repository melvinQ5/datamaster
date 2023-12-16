select c1 报表,
case
    when c1 = '周报' then weekofyear(c3)+1
    when c1 = '月报' then month(c3) end as 自然周月
, c3 当期第一天,c4 新老品,c5 主题,c6 优先级元素,c7 高潜,c8 一级类目,c9 链接刊登划分,c10 区域
 ,0 + c11 订单量, 0 + c12 出单SPU数, round(c13,2) 销售额, round(c14,2) 利润额_扣ad, 0 + c15 销售额_扣运费未扣退款, 0 + c16 利润额_扣运费未扣退款, 0 + c17 退款额, 0 + c18 运费收入
, 0 +c19 交易佣金, 0 + c20 采购成本, 0 + -1*c21 物流成本 , 0 + c22 广告曝光量 , 0 + c23 广告花费 , 0 + c24 广告销售额, 0 + c25 广告销量
, 0 + c26 广告点击量, 0 + c27 总未停产SPU数, 0 + c28 总在仓产品金额_万元
-- , 0+c29 是否结算项记录
,0+c30 在线渠道SKU数 ,0+c31 在线链接数
from manual_table_duplicate
order by c1 desc;


