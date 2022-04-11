from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.http import require_POST
from .models import User 
#from django.views.decorators.csrf import ensure_csrf_cookie


#跳转登录和注册页面
def login_register(request):
    return render(request,'login_register.html')




@require_POST  #似乎这样写不用判断是 post请求还是get请求
#验证用户名唯一
def unique_uname(request):
    # 通过写SQL知道接受什么参数
    try:
        #接受参数
        username = request.POST.get('username') 
        #查询是否该有用户
        user = User.objects.get(username=username)  #get\filter等方法查询数据
        #若有用户返回页面json
        return JsonResponse({'code':200,'msg':'该用户名已存在，换个试试'})
    except User.DoesNotExist as e:
        # 异常信息返回用户不存在
        return JsonResponse({'code':400,'msg':'√ 该用户名可用'})
