from pyecharts.charts import Bar,Line
from pyecharts import options as opts

#----生成pyecharts图像
def echarts_stackbar(
        df, #传入行索引为date的时间序列面板数据
        df_gr=None, #比如传入同比增长率df，可以为空
        datatype = 'ABS' #主Y轴默认为绝对值，形式可以是绝对值or增长率or份额，用来确定一些标签格式，
    ) -> Bar:
    axislabel_format='{value}' #主Y轴默认格式
    max = df['建档人数'].max() #主Y轴默认最大值， 之后要抽象为一个比如叫度量值
    min = df['建档人数'].min() #主Y轴默认最小值
    if datatype in ['SHARE','GR']: # 如果是份额SHARE或者增长率GR的设置
        df = df.multiply(100).round(2) # multiply 乘法
        axislabel_format ='{value}%' #主Y轴格式改为百分比
        max = 100 # 改最大最小值
        min = 0 
    if df_gr is  not None:
        df_gr = df_gr.multiply(100).round(2) #如果有同比增长率,原始数据 乘以 100展现
    if df.empty is False: 
        stackbar =(
            Bar() #实例化一个柱状图或条形图（直角坐标系图表之一）
            .add_xaxis(df.index.tolist())
        )
        print(df.columns)
        # 预留的枚举，这个方法以后可以根据输入对象不同从单一柱状图变成堆积柱状图;
        # python的 enumerate(sequence) 函数将一个可遍历数据对象组合成一个索引序列，同时列出数据及下标
        stackbar.add_yaxis(
            series_name='建档人数',#之后要抽象为一个比如叫度量值，多个系列可以获取df.columns再遍历
            y_axis=df['建档人数'].values.tolist(), 
            label_opts = opts.LabelOpts(is_show=False), #标签配置项之 是否显示标签
            z_level  = 1, #指定渲染图层，低版本pyecharts可能因为没有该参数报错
            )
        #若有同比增长率，加入次Y轴
        if df_gr is not None:
            stackbar.extend_axis(
                yaxis=opts.AxisOpts( #坐标轴配置项
                    name='同比增长率',
                    type_ = "value",
                    axislabel_opts=opts.LabelOpts(formatter="{value}%"),
                )
            )
        #全局配置
        stackbar.set_global_opts(
            legend_opts=opts.LegendOpts(pos_top='5%',pos_left='10%',pos_right='60%'), #图例配置项
            toolbox_opts=opts.ToolboxOpts(is_show=True,
	             pos_top="top",
	             pos_left="right",
	             feature={"saveAsImage": {},
	                "restore": {} ,
	                "magicType":{"show": True, "type":["line","bar"]},
	                "dataView": {} }), #工具箱,默认为所有工具，可自行增添
            tooltip_opts=opts.TooltipOpts(trigger='axis', #提示框
                axis_pointer_type='cross',
            ),
            xaxis_opts= opts.AxisOpts(
                type_='category',
                boundary_gap= True,
                axislabel_opts=opts.LabelOpts(rotate=90),  # x轴标签方向rotate有时能解决拥挤显示不全的问题
                splitline_opts=opts.SplitLineOpts(is_show=False,
                    linestyle_opts=opts.LineStyleOpts(
                        type_='dotted',
                        opacity=0.5,)
                )
            ),
            yaxis_opts= opts.AxisOpts(
                max_ = max,
                min_ = 0, #最小值从0轴开始还是从最小值或指定值开始
                type_ = "value",
                axislabel_opts=opts.LabelOpts(formatter=axislabel_format),
                splitline_opts=opts.SplitLineOpts(is_show=False,
                    linestyle_opts=opts.LineStyleOpts(
                        type_='dotted',
                        opacity=0.5,)
                )
            )
        )
        if df_gr is not None: #配置折线图
            line =(
                Line()
                    .add_xaxis(xaxis_data = df_gr.index.tolist())
                    .add_yaxis(
                        series_name="同比增长率",
                        yaxis_index=1,
                        y_axis=df_gr.index.tolist(),
                        label_opts=opts.LabelOpts(is_show=False),
                        linestyle_opts=opts.LineStyleOpts(width=3), #线样式配置
                        symbol_size=8,
                        itemstyle_opts=opts.ItemStyleOpts(border_width=1, border_color='', border_color0='white'),
                        z_level=2  # 渲染图层大于柱状图，保证线图在上方
                    )
            )
    else:
        stackbar = (Bar())
    if df_gr is not None: #如果有次坐标，最后用overlap方法组合一下Bar()和Line()
        return stackbar.overlap(line) #函数最终要么返回组合图
    else:
        return stackbar #函数最终要么返回柱状图