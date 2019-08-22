# Quick Note

#### Mysql存储引擎 

InnoDB 主键走聚集索引，其他走稀疏索引
MyISAM 全是走稀疏索引



#### Mysql简单优化步骤

查看慢日志，找到查询比较慢的语句
加索引 alter table <table-name> add index index_name(<attr-name>)



#### 不小心提交了.idea类似的配置文件，先reset再修改远程

git push origin master --force

