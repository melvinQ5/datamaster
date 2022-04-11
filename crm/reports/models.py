from django.db import models

class DimChannel(models.Model):

    channel_key=models.AutoField(primary_key=True)
    last_update=models.DateTimeField(blank=True,null=True)
    channel_1=models.CharField(max_length=255,blank=True,null=True)
    channel_2=models.CharField(max_length=255,blank=True,null=True)
    channel_3=models.CharField(max_length=255,blank=True,null=True)
    channel_des=models.CharField(max_length=255,blank=True,null=True)

    class Meta:

        managed=False

        db_table='dim_channel'





class DimCustomer(models.Model):

    customer_key=models.AutoField(primary_key=True)

    ct_last_update=models.DateTimeField(blank=True,null=True)

    ct_name=models.CharField(max_length=100,blank=True,null=True)

    ct_age=models.IntegerField(blank=True,null=True)

    ct_sex=models.IntegerField(blank=True,null=True)

    ct_status=models.IntegerField(blank=True,null=True)

    ct_tel=models.CharField(max_length=100,blank=True,null=True)

    ct_tel_2=models.CharField(max_length=100,blank=True,null=True)

    ct_wx=models.CharField(max_length=100,blank=True,null=True)

    is_login_wxapp=models.IntegerField(blank=True,null=True)

    ct_duihua_key=models.IntegerField(blank=True,null=True)

    ct_online_staff_key=models.IntegerField(blank=True,null=True)

    ct_offline_staff_key=models.IntegerField(blank=True,null=True)

    ct_doctor_staff_key=models.IntegerField(blank=True,null=True)

    ct_hm_id=models.CharField(max_length=40,blank=True,null=True)

    ct_hm_temp_id=models.CharField(max_length=40,blank=True,null=True)



    class Meta:

        managed=False

        db_table='dim_customer'





class DimDate(models.Model):

    date_key=models.AutoField(primary_key=True)

    dt_timestamp=models.DateTimeField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dim_date'





class DimProduct(models.Model):

    product_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    product_1=models.CharField(max_length=255,blank=True,null=True)

    product_2=models.CharField(max_length=255,blank=True,null=True)

    product_3=models.CharField(max_length=255,blank=True,null=True)

    product_tmk=models.CharField(max_length=255,blank=True,null=True)

    product_des=models.CharField(max_length=20,blank=True,null=True)



class Meta:

    managed=False

    db_table='dim_product'





class DimStaff(models.Model):

    staff_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    tmk_id=models.CharField(max_length=255,blank=True,null=True)

    staff_id=models.CharField(max_length=255,blank=True,null=True)

    staff_name=models.CharField(max_length=255,blank=True,null=True)

    staff_dep_id=models.IntegerField(blank=True,null=True)

    staff_dep=models.CharField(max_length=255,blank=True,null=True)

    onboard_date=models.DateTimeField(blank=True,null=True)

    resign_date=models.DateTimeField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dim_staff'





class DimTime(models.Model):
    time_key=models.IntegerField(primary_key=True)

    class Meta:

        managed=False

        db_table='dim_time'





class DwdDuihua(models.Model):

    duihua_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    channel_key=models.IntegerField(blank=True,null=True)

    staff_key=models.IntegerField(blank=True,null=True)

    product_key=models.IntegerField(blank=True,null=True)

    tmk_id=models.CharField(max_length=255,blank=True,null=True)

    visitor_static_id=models.CharField(max_length=255,blank=True,null=True)

    customer_key=models.IntegerField(blank=True,null=True)

    visitor_msg_count=models.IntegerField(blank=True,null=True)

    tmk_msg_count=models.IntegerField(blank=True,null=True)

    visitor_category=models.CharField(max_length=255,blank=True,null=True)

    create_time=models.DateTimeField(blank=True,null=True)

    close_time=models.DateTimeField(blank=True,null=True)

    invite_mode=models.CharField(max_length=255,blank=True,null=True)

    close_type=models.CharField(max_length=255,blank=True,null=True)

    char_url=models.TextField(blank=True,null=True)

    refer_url=models.TextField(blank=True,null=True)

    visitor_ip=models.CharField(max_length=255,blank=True,null=True)

    serach_host=models.CharField(max_length=255,blank=True,null=True)

    dh_tel=models.IntegerField(blank=True,null=True)

    dh_wx=models.IntegerField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_duihua'





class DwdHuifang(models.Model):

    huifang_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    duihua_key=models.IntegerField(blank=True,null=True)

    jiandang_key=models.IntegerField(blank=True,null=True)

    laiyuan_key=models.IntegerField(blank=True,null=True)

    kaidan_key=models.IntegerField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_huifang'





class DwdJiandang(models.Model):

    jiandang_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    duihua_key=models.IntegerField(blank=True,null=True)

    product_key=models.IntegerField(blank=True,null=True)

    customer_key=models.IntegerField(blank=True,null=True)

    staff_key=models.IntegerField(blank=True,null=True)

    channel_key=models.IntegerField(blank=True,null=True)

    create_jd_time=models.DateTimeField(blank=True,null=True)

    is_from_duihua=models.IntegerField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_jiandang'





class DwdJixiao(models.Model):

    jixiao_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_jixiao'





class DwdKaidan(models.Model):

    kaidan_key=models.AutoField(primary_key=True)

    kd_last_update=models.DateTimeField(blank=True,null=True)

    kd_hm_id=models.CharField(max_length=40,blank=True,null=True)

    kd_customer_key=models.IntegerField(blank=True,null=True)

    kd_product_key=models.IntegerField(blank=True,null=True)

    kd_product_name=models.CharField(max_length=100,blank=True,null=True)

    kd_pos_type=models.CharField(max_length=100,blank=True,null=True)

    kd_pos_time=models.DateTimeField(blank=True,null=True)

    kd_pos_id=models.CharField(max_length=20,blank=True,null=True)

    kd_pos_ways=models.TextField(blank=True,null=True)

    kd_pos_amount=models.FloatField(blank=True,null=True)

    kd_orders_id=models.CharField(max_length=40,blank=True,null=True)

    kd_offline_staff_key=models.IntegerField(blank=True,null=True)

    kd_customer_type=models.IntegerField(blank=True,null=True)

    kd_goods_price=models.FloatField(blank=True,null=True)

    kd_goods_count=models.IntegerField(blank=True,null=True)

    kd_goods_amount=models.FloatField(blank=True,null=True)

    kd_goods_fact_amount=models.FloatField(blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_kaidan'





class DwdLaiyuan(models.Model):

    laiyuan_key=models.AutoField(primary_key=True)

    last_update=models.DateTimeField(blank=True,null=True)

    ly_create_time=models.DateTimeField(blank=True,null=True)

    ly_product_key=models.IntegerField(blank=True,null=True)

    ly_online_staff_key=models.IntegerField(blank=True,null=True)

    ly_offline_staff_key=models.IntegerField(blank=True,null=True)

    ly_doctor_staff_key=models.IntegerField(blank=True,null=True)

    ly_customer_key=models.IntegerField(blank=True,null=True)

    ly_doctor_dep=models.CharField(max_length=40,blank=True,null=True)

    ly_customer_type=models.IntegerField(blank=True,null=True)

    ly_customer_times=models.IntegerField(blank=True,null=True)

    ly_notes=models.TextField(blank=True,null=True)

    ly_hm_id=models.CharField(max_length=100,blank=True,null=True)



    class Meta:

        managed=False

        db_table='dwd_laiyuan'





class DwsIncomes(models.Model):

    offline_stf_name=models.CharField(max_length=100,blank=True,null=True)

    prd_des=models.CharField(max_length=255,blank=True,null=True)

    online_stf_name=models.CharField(max_length=255,blank=True,null=True)

    income_time=models.DateTimeField(blank=True,null=True)

    income_amount=models.DecimalField(max_digits=10,decimal_places=0,blank=True,null=True)

    ic_last_update=models.DateTimeField(blank=True,null=True)

    ic_key=models.AutoField(primary_key=True)



    class Meta:

        managed=False

        db_table='dws_incomes'