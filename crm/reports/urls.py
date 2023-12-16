from django.urls import path
from . import views 
# from.表示同文件目录

# 设置命名空间
app_name ='reports'


# A mapping between URL path expressions to Python functions (your views).
urlpatterns = [
    #path第一个参数指定模板文件夹下路径是哪个template,第二个参数指定是哪个view.这里urls映射的作用就是联立二者。
    path('homepage/',views.homepage,name='homepage'),
    path('analysis/',views.analysis,name='analysis'), #初始化请求，通过浏览器地址栏
    path('',views.query,name='query'),#ajax请求，通过app_name:path_name
    path(r'export_as_excel/',views.export_as_excel,name='export_as_excel'), 
]
"""
官网举例
path('index/', views.index, name='main-view'),
path('bio/<username>/', views.bio, name='bio'), # 带尖括号的参数可以传给views
path('articles/<int:section>/', views.article, name='article-detail'), # 角括号可含一个转换器规格,将section参数转成int之后,再传递给views。
path('articles/<slug:title>/<int:section>/', views.section, name='article-section'),
path('blog/', include('blog.urls')),
"""
