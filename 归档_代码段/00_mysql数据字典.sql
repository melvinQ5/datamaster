--查看数据字典 

SELECT
-- a.TABLE_SCHEMA as tableSchema,
a.TABLE_NAME as tableName,
b.TABLE_COMMENT as tableComment,
a.COLUMN_NAME as columnName,
a.COLUMN_COMMENT as columnComment,
a.COLUMN_KEY as columnKey,
a.ORDINAL_POSITION as ordinalPosition,
a.IS_NULLABLE as isNullable,
a.COLUMN_TYPE as columnType
from information_schema.COLUMNS a
LEFT JOIN information_schema.TABLES b ON a.TABLE_NAME=b.TABLE_NAME
-- where a.TABLE_NAME='${tbName}'
ORDER BY b.TABLE_NAME,a.ORDINAL_POSITION