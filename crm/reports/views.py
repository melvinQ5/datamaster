#公用依赖
from fileinput import filename
from http.client import ResponseNotReady
import json
from operator import index
from pickle import NONE
from urllib import request, response
from django.db import connection
from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
# from django.views.decorators.http import require_POST

import pymysql
from dbutils.pooled_db import PooledDB
import pandas as pd
import numpy as np
from pymysql import NULL

#图表依赖
from . charts import * #views代码量太大，拆分文件再引入
#导出excel依赖
import datetime
import xlsxwriter
#缓存设置依赖
from django.views.decorators.cache import cache_page
#识别用户已登录
from django.contrib.auth.decorators import login_required


#渲染页面-首页可视化大屏
@login_required
def homepage(request):
    return render(request,'homepage.html')

#渲染页面-销售线索管理页
@login_required
def leasManager():
    pass

#渲染页面-分析页
@login_required
def analysis(request):
    context = filter_init()
    print('===初始化filter完成,备选项已生成')
    return render(request,'report_data/analysis.html',context) 
"""
以views.query方法为例,@login_required装饰器会在query方法之前运行,即当任何URL成功定向到query方法后,@login_required将首先检查该用户是否已登录。
如果他们已登录,则query将运行并返回结果。而如果未登录,它将阻止query方法运行,而重定向至/login?next=%2Fquery。
加载页面后此时的next后的参数为一个GET请求的参数被捕捉。所以这时login.html可以用django tag语法调用{{ next }}
login.html再使用<input type="hidden" name="next" value="{{ next }}">语句,把next作为一个隐藏元素在登录时发送,
用户登录成功后此next相当于覆盖了默认的LOGIN_REDIRECT_URL ,把页面重定向回query方法。
简单地说，这个{{ next }}可以帮助我们在登录后重定向至登录前访问的网页。这个 next 可以帮助我们在登录后重定向至登录前访问的网页。-->
"""

#初始化筛选页
def filter_init():
    # 配置fliter页单选显示值和实际值，key页面显示字段，value数据库字段
    tuple2list = lambda tupleA: [item[0] for item in tupleA] #用列表推到式转换为列表,这句只转了元组的第一个item
    channel_select  = sqlParse('select distinct channel_2 from dim_channel') #页面初始化时 查数据
    list_channel = tuple2list(channel_select)
    staff_dep_select  = sqlParse('select distinct staff_dep from dim_staff') #页面初始化时 查数据
    list_staff_dep = tuple2list(staff_dep_select)
    context = {
        'channel_select':list_channel,
        'staff_dep_select':list_staff_dep,
    } #结果存入上下文
    return context


# 接受ajax请求，返回查询数据
@login_required
@cache_page(60 * 60 * 24 * 30) #缓存装饰器，缓存30天
def query(request):
    print('---收到ajax 查询 请求:',request.POST)
    # 剔除不需要的字典元素（前台动态传参情况下，后台不知道传过来哪些参数）
    query_dict = request.POST.dict() # 将django的QueyDict 转化为pyhon的Dict
    table_name = query_dict['table_select'] 
    query_dict.pop('csrfmiddlewaretoken')
    query_dict.pop('table_select')
    query_dict['channel_2'] = query_dict.pop('channel_select') #python中 间接修改key的方法
    query_dict['staff_dep'] = query_dict.pop('staff_dep_select')
    # 传入字典key 改为 数据库字段名(如果希望sql_spelling 能复用，应该分别在每个页面的接受ajax的时候这样做）
    print('---已准备SQL动态参数:',query_dict)

    df = get_df(query_dict,table_name)
    df.columns = ['入库号','更新时间','渠道id','渠道一级','渠道二级','渠道三级','客服id','客服姓名','客服部门','昨天建档人数','近7天建档人数','近30天建档人数']
    day1_count_total = df['昨天建档人数'].sum()
    day7_count_total = df['近7天建档人数'].sum()
    day30_count_total = df['近30天建档人数'].sum()
    table = df.to_html(
        classes='ui selectable celled table', #指定表格为DataTables插件中的semantic UI主题
        table_id= 'dt_display'
    )
    print('---表格数据已渲染为html')

    # 准备echarts数据 加入context
    table_name = 'dws_cust_register_cal' #写死了
    columns = "register_date,channel_2,staff_dep,sum(register_count)"
    sql =sql_spelling(query_dict,table_name,columns) + "group by register_date,channel_2,staff_dep"
    print('---sql拼接完毕: ',sql)
    chart_result = sqlParse(sql)
    df_chart = pd.DataFrame(list(chart_result))
    df_chart.columns = ['建档日期','渠道二级','员工部门','建档人数']
    
    bar_total_trend = json.loads(preProcessing_chart(df_chart,'bar_total_trend')) #json对象转python数据格式
    print('---图表数据已渲染为python数据格式,等待转为json传给前台')
    context = {
        'day1_count_total':str(day1_count_total), #为了后续转json格式,将数字转为字符串
        'day7_count_total':str(day7_count_total),
        'day30_count_total':str(day30_count_total),
        'cust_register_day':table, #传入表格数据
        'bar_total_trend':bar_total_trend #传入图表渲染后的配置数据
    } 
    return HttpResponse(json.dumps(context, ensure_ascii=False), content_type="application/json charset=utf-8")
    #返回的必须时json格式，json.dumps的作用是将python对象转为json格式


#输入SQL参数，输出dataFrame
def get_df(query_dict,table_name):
    # 注意这个地方需要改写下，备选项是维度表所有数据，可能用户实际查询日下下没有数据
    sql =sql_spelling(query_dict,table_name)
    result = sqlParse(sql)
    df = pd.DataFrame(list(result)) #元组转列表再转df
    return df


# 导出excel功能建议放在后台处理，重新请求一次完整数据（之前筛选浏览数据后期可扩展为分页，也就是说前台不一定有完整数据）
try:
    from io import BytesIO as IO
except ImportError:
    from io import StringIO as IO
import datetime
import six
import xlsxwriter

@login_required
def export_as_excel(request):
    print('---收到ajax 下载 请求:',request.GET)
    # 以下这段与query()区别在于: 导出需要请求全部数据,查询以后可扩展只查分页的数据
    query_dict = request.GET.dict() # 将django的QueyDict 转化为pyhon的Dict

    table_name = query_dict['table_select']
    query_dict.pop('csrfmiddlewaretoken')
    query_dict.pop('table_select')
    query_dict['channel_2'] = query_dict.pop('channel_select') #python中 间接修改key的方法
    query_dict['staff_dep'] = query_dict.pop('staff_dep_select')
    # 传入字典key 改为 数据库字段名(如果希望sql_spelling 能复用，应该分别在每个页面的接受ajax的时候这样做）
    df = get_df(query_dict,table_name)
    df.columns = ['入库号','更新时间','渠道id','渠道一级','渠道二级','渠道三级','客服id','客服姓名','客服部门','昨天建档人数','近7天建档人数','近30天建档人数']

    excel_file=IO()
    xlsxwriter = pd.ExcelWriter(excel_file,engine='xlsxwriter')
    df.to_excel(xlsxwriter,'data',index=True)
    xlsxwriter.save()
    xlsxwriter.close()
    excel_file.seek(0)

    #设置浏览器mime类型
    response = HttpResponse(excel_file.read(),content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    #设置文件名
    now = datetime.datetime.now().strftime("%Y%m%d%H%M%S") #当前精确时间不会重复,适合用来命名默认导出文件
    response['Content-Disposition'] = 'attachment;filename=' + now +'.xlsx'
    return response
    


# -------配置数据库连接池,sql拼写,sql执行--------
pool = PooledDB(
    creator=pymysql,   # 要用的数据库的moudle
    maxconnections=6,  # 连接池允许的最大连接数，0和None表示不限制连接数
    mincached=2,  # 初始化时，链接池中至少创建的空闲的链接，0表示不创建
    maxcached=5,  # 链接池中最多闲置的链接，0和None不限制
    maxshared=3, # 链接池中最多共享的链接数量，0和None表示全部共享。PS: 无用，因为pymysql和MySQLdb等模块的 threadsafety都为1，所有值无论设置为多少，_maxcached永远为0，所以永远是所有链接都共享。
    blocking=True,  # 连接池中如果没有可用连接后，是否阻塞等待。True，等待；False，不等待然后报错
    maxusage=None,  # 一个链接最多被重复使用的次数，None表示无限制
    setsession=[],  # 开始会话前执行的命令列表。如：["set datestyle to ...", "set time zone ..."]
    ping=0, # ping MySQL服务端，检查是否服务可用，如：0 = None = never, 1 = default = whenever it is requested, 2 = when a cursor is created, 4 = when a query is executed, 7 = always
    host="127.0.0.1",
    port=3306,
    user="root",
    password="sql123",
    database="meidata",
)


def sql_spelling (query_dict,table_name,columns="*"):
    sql = "select "+ columns +" from "+ table_name + " where 1=1 "
    for k,v in query_dict.items():
        sql += "and "+ k + " = '" +v+ "'"
    print('---sql拼接完毕: ',sql)
    return sql


def sqlParse(sql): 
    # 执行SQL查询
    conn = pool.connection()  #获取数据库连接
    cursor = conn.cursor()
    cursor.execute(sql) #注意 pymysql参数不能传表名和字段名，提前拼好
    result = cursor.fetchall() #返回的是一个元组 tuple
    conn.close()
    return result


# -------配置图表数据--------
D_TRANS = {
            'MAT': '滚动年',
            'QTR': '季度',
            'Value': '金额',
            'Volume': '盒数',
            'Volume (Counting Unit)': '最小制剂单位数',
            '滚动年': 'MAT',
            '季度': 'QTR',
            '金额': 'Value',
            '盒数': 'Volume',
            '最小制剂单位数': 'Volume (Counting Unit)'
           } 

# 根据不同的图表类型，按不同的方式处理数据，创建图表对象
def preProcessing_chart(df,  # 输入经过pivoted方法透视过的df，不是原始df
                  chart_type,  # 图表类型字符串，人为设置，根据图表类型不同做不同的Pandas数据处理，及生成不同的Pyechart对象
                  form_dict=None,  # 前端表单字典，用来获得一些变量作为图表的标签如单位
                  ):
    #label = D_TRANS[form_dict['PERIOD_select'][0]] + D_TRANS[form_dict['UNIT_select'][0]]


    if chart_type == 'bar_total_trend':
        df_abs = df
        # df.sum(axis=0) 默认 ↓ axis=0求和是纵向求和，求和值是在表格最下方的
        # 那相应的如果求和是横向求和，值是在表格最右边，→ axis=1。
        df_abs.set_index('建档日期')  # 行索引日期数据变成2020-06的形式
        # df_abs = df_abs.to_frame()  # series转换成df
        #df_abs.columns = [label]  # 用一些设置变量为系列命名，准备作为图表标签
        #df_gr = df_abs.pct_change(periods=4)  # 获取同比增长率
        #df_gr.dropna(how='all', inplace=True)  # 删除没有同比增长率的行，也就是时间序列数据的最前面几行，他们没有同比
        #df_gr.replace([np.inf, -np.inf, np.nan], '-', inplace=True)  # 所有分母为0或其他情况导致的inf和nan都转换为'-'
        chart = echarts_stackbar(df=df_abs,
                                 #df_gr=df_gr
                                 )  # 调用stackbar方法生成Pyecharts图表对象
        return chart.dump_options()  # 用json格式返回Pyecharts图表对象的全局设置，完成后端准备工作
    else:
        return None
