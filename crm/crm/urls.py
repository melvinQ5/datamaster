"""crm URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))

当一个用户请求 Django 站点的一个页面,Django 后台逻辑如下：
=> 收到前台发的URL 
=> 匹配setting.py的ROOT_URLCONF的值 
=> 匹配对应app的urls.py,若未匹配到调用错误处理views,返回提示
=> 调用views(若url中带参则一并传入) 
=> views.py 函数中决定最终返回的htmk文件路径(templates
path参数写法:
第一个参数负责和前台URL地址一致,第二个参数负责指定调用views里哪个函数,那么指定哪个html文件谁负责? views.py中函数的return负责.

def query(request):
"""

from django.contrib import admin
from django.urls import path,include
from django.conf import settings #为了使用settings文件中的内容
from django.conf.urls.static import static

# 设置命名空间
# app_name ='crm'

urlpatterns = [
    path('admin/', admin.site.urls),
    path('reports/',include('reports.urls')),
    # path('',include('system.urls')), #'' 表示只输入IP，不写目录的情况，就转入app的system的url进行遍历
    path('accounts/',include('django.contrib.auth.urls')), #使用django内置的登录用户模块 浏览器输入127.0.0.1:8000/account/login进入 
]



#动态地，利用debug状态配置static
if settings.DEBUG: 
    urlpatterns += static(settings.STATIC_URL,documnet_root=settings.STATIC_ROOT)
print(urlpatterns)
