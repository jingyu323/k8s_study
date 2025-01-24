# Oracle



## 1.数据导入

设置 linux 编码

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

export NLS_CHARACTERSET=ZHS16GBK

export NLS_NCHAR=AL16UTF16



查看数据库编码

select * from nls_database_parameters where parameter in ('NLS_LANGUAGE','NLS_TERRITORY','NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET');



导入命令 

imp scott/tiger@localhost:1521/orclpdb  file="MAN.dmp" full=y ignore=y   buffer=10000000 log=/home/oracle/imp_MAN.log



impdp scott/tiger@localhost:1521/orclpdb dumpfile=MAN.dmp directory=dump_dir REMAP_SCHEMA=TEDS:htkj LOGFILE=import.log;