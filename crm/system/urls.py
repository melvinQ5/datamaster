from django.urls import path
from . import views 
# from.表示同文件目录

# 设置命名空间
app_name ='system'

urlpatterns = [ #未使用以下 自己写的登录页，使用了django 内置模块
    # path('',views.login_register,name='login_register'),
    # path('login_register/',views.login_register,name='login_register'),
    # # path('unique_username/',views.unique_uname,name='unique_username')
]
