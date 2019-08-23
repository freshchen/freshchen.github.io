# Quick Note






### Mysql锁

- InnoDB默认行锁，也支持表锁

- MyISAM默认表锁

- 手动给表加锁 lock tables <table_name> <read|write> ， 解锁 unlock tables <table_name>

- 加共享锁/读锁  在sql语句后面加 lock in share mode

- InnoDB支持事务，关闭事务自动方法 set autocommit = 0


### Mysql简单优化步骤

- 查看慢日志，找到查询比较慢的语句

- 使用explain分析sql。分析结果中type字段是index和all就有问题需要优化，extra字段是Using filesort指用的外部索引例如文件系统索引等，Using temporary指用的临时表，这两种情况也需要优化

- 加索引 alter table <table-name> add index index_name(<column-name>)

- 有时候优化器选择不一定准确，需要手动测试，强制使用某一个索引可以在sql语句中加入 force index(<column-name>)



### Mysql稀疏索引和聚集索引 

- InnoDB 主键走聚集索引，其他走稀疏索引

- MyISAM 全是走稀疏索引
