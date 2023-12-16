-- �������
CREATE EXTERNAL TABLE `����` (
    -- ճ�������������ֶ�
    -- ע�� 1 mysql �� starRocks ����������Щ��ͬ
 ENGINE=MYSQL
COMMENT "��������"
PROPERTIES (
"host" = "192.168.13.21",
"port" = "3306",
"user" = "doris_r",
"password" = "Nais@123",
"database" = "user",
"table" = "user_exchange_rates"
);

-- ע�� 1�� ��Ҫ�޸��ֶ�����: 
    -- datatime(6) -> datatime
    -- text | longtext  -> varchar(656565)
    -- ȥ�� CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
    -- DEFAULT NULL -> NULL
    -- decimal(65,2) -> decimal(38,2) �� double  ��һ�������38, Ҳ����double����

    -- ����������

-- �鿴ģ���ĵ� https://docs.starrocks.io/zh-cn/latest/table_design/table_types/table_types

-- ��������ģ��  

CREATE TABLE `����` (
    ճ�������������ֶ�
    # ע�� 1 ��Ҫ�޸��ֶ�����
) ENGINE=OLAP
PRIMARY KEY(`Id`)
COMMENT "��������"
DISTRIBUTED BY HASH(`Id`) BUCKETS 50
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- ������ϸģ��

CREATE TABLE IF NOT EXISTS detail (
    event_time DATETIME NOT NULL COMMENT "datetime of event",
    event_type INT NOT NULL COMMENT "type of event",
    user_id INT COMMENT "id of user",
    device_code INT COMMENT "device code",
    channel INT COMMENT ""
)
DUPLICATE KEY(event_time, event_type)
DISTRIBUTED BY HASH(user_id) BUCKETS 10
PROPERTIES (
"replication_num" = "3"
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- �����ۺ�ģ��
CREATE TABLE IF NOT EXISTS example_db.aggregate_tbl (
    site_id LARGEINT NOT NULL COMMENT "id of site",
    date DATE NOT NULL COMMENT "time of event",
    city_code VARCHAR(20) COMMENT "city_code of user",
    pv BIGINT SUM DEFAULT "0" COMMENT "total page views"
)
AGGREGATE KEY(site_id, date, city_code)
DISTRIBUTED BY HASH(site_id) BUCKETS 10
PROPERTIES (
"replication_num" = "3"
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- ��������ģ��
CREATE TABLE IF NOT EXISTS orders (
    create_time DATE NOT NULL COMMENT "create time of an order",
    order_id BIGINT NOT NULL COMMENT "id of an order",
    order_state INT COMMENT "state of an order",
    total_price BIGINT COMMENT "price of an order"
)
UNIQUE KEY(create_time, order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 10
PROPERTIES (
"replication_num" = "3"
"in_memory" = "false",
"storage_format" = "DEFAULT"
); 

