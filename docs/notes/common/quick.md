# Quick Note























### 一致性哈希算法

主要用于解决分布式系统中负载均衡的问题。

一般情况：

- 假设数据对2^32取模，构成一个虚拟圆环
- 例如几台服务器的ip取模映射到环上，把服务器放到圆环中对应的位置
- 然后数据过来之后取模映射完之后，开始顺时针找最近的服务器处理

问题：服务器数量不多，容易出现数据倾斜问题（服务器分布不均匀，缓存数据集中在部分服务器上）

解决方案：可以增加虚拟节点，例如在主机ip后加编号取模映射到环的不同位置。然后数据遇到虚拟节点之后再映射回真实节点。

### Redis部署

- 主从模式：一般主服务器写，从读。主服务器挂掉系统就挂了
- 哨兵sentinel模式：相对主从模式，多了监控主服务器，主挂掉能自动推举下一个主服务器，类似zookeeper，并且能发送故障通知。

### Redis持久化

| 方案    | 描述                                                         | 优点                   | 缺点                                         |
| ------- | ------------------------------------------------------------ | ---------------------- | -------------------------------------------- |
| **rdb** | 在配置文件中定义了rdb备份的触发条件，条件达到就开始备份redis内存快照。 | 恢复数据很快，磁盘io少 | 没有达到触发条件期间发生故障，未备份数据丢失 |
| **aof** | 将每次操作都记录到一个日志中，通过日志恢复数据。             | 丢失数据风险小         | 还原数据速度慢，磁盘io频繁。                 |

**问: 在dump rdb过程中,aof如果停止同步,会不会丢失?**

答: 不会,所有的操作缓存在内存的队列里, dump完成后,统一操作.

**问: aof重写是指什么?**

答: aof重写是指把内存中的数据,逆化成命令,写入到.aof日志里.

以解决 aof日志过大的问题.

**问: 如果rdb文件,和aof文件都存在,优先用谁来恢复数据?**

答: aof

**问: 2种是否可以同时用?**

答: 可以,而且推荐这么做

**问: 恢复时rdb和aof哪个恢复的快**

答: rdb快,因为其是数据的内存映射,直接载入到内存,而aof是命令,需要逐条执行

### Redis简单分布式锁

- set key value [expiration EX seconds|PX milliseconds] [NX|XX]    

  NX key不存在贼执行，XXkey存在则执行 

### Redis常用数据类型

- String ：基本类型，二进制安全，可以存放图片序列化对象等
- Hash：String元素组成的字典
- List：列表
- Set：无序不重复集合
- Sorted Set：有序的Set

### Redis为什么快

- 完全基于内存，C语言编写

- 数据结构相对简单

- 单进程单线程的处理请求，从而确保高并发线程安全，想多核都用上可以通过启动多个实例

- 多路I/O复用，非阻塞

### Redis和 Memcache区别

- Memcache支持简单的数据类型，不支持持久化存储，不支持主从，不支持分片

- Redis数据类型丰富，支持持久化存储，支持主从，支持分片

### InnoDB可重复读（Repeatable read）级别为啥可以避免幻读

- 表象：快照读（非阻塞读不加锁，对应加锁的叫当前读）伪MVCC

- 内在：next-key锁（行锁 + gap锁）

### Mysql事务隔离级别

|隔离级别|更新丢失|脏读|不可重复读|幻读|
|---|---|---|---|---|
|未提交读（Read uncommitted） |不可能 |可能	|可能	|可能|
|已提交读（Read committed）	|不可能 |不可能	|可能	|可能|
|可重复读（Repeatable read）	|不可能 |不可能	|不可能	|可能|
|可串行化（Serializable）	|不可能 |不可能	|不可能	|不可能|

```sql
查看隔离级别
select @@tx_isolation;
设置隔离级别
set session transaction isolation level read UNCOMMITTED;
开启事务
start transaction;
回滚
rollback;
提交
commit;
```

### Mysql常用存储引擎适用场景

- MyISAM适用频繁执行全表count，查询频率高，增删改频率不高

- InnoDB增删改查都频繁，对可靠性要求高，要求支持事务

### Mysql锁

- InnoDB默认行锁，也支持表锁,没有用到索引的时候用表级锁

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

### 数据库事务四大特性

- 原子性（Atomic）要么全做要么全不做

- 一致性（Consistency）数据要保持完整性，从一个一致状态到另一个一致状态

- 隔离性（Isolation）一个事务的执行不影响其他事务

- 持久性（Durability）事务一旦提交，变更应该永久的保存到数据库中

### 不可变对象

- 对象创建之后状态不能修改

- 对象的所有的域都是final类型

- 对象是正确创建的（对象创建过程中，this引用没用逃逸）

### 如何安全发布对象

- 在静态初始化函数中初始化一个对象引用

- 将对象的引用保存到正确的构造对象的final类型域中

- 将对象的引用保存到一个由锁保护的域中

- 将对象的引用用volatile关键字修饰，或者保存到AtomicReference对象中


### 为什么双检查单例模式实例引用不加volatile不是线程安全的

- 对象发布主要有三步 1.分配内存空间 2初始化对象 3引用指向分配的内存

- 由于指令重排的存在，可能出现132的顺序，多线程环境下，可能出现 instance != null  但是初始化工作还没完成的情况在占有锁的线程没有完成初始化时，另一个线程认为以及初始化完毕了去使用对象的时候便会有问题

- 加上 volatile 关键字就可以解决指令重排的问题

### JVM内存泄漏情景

- 类似于栈，内存的管理权不属于JVM而属于栈本身，所有被pop掉的index上还存在着过期的引用Stack.pop()的源码中手动清除了过期引用
elementData[elementCount] = null; /* to let gc do its work

- 将对象引用放入了缓存，可以用WeakHashMap作为引用外键

- 监听器和其他回调，可以用WeakHashMap作为引用外键


### ArrayList & HashMap 扩容

- ArrayList默认大小10，装不下就扩容，每次1.5倍扩容

- HashMap默认大小16，当前容量超过总容量乘以散列因子（默认0.75）就扩容，每次2倍扩容。

### 重写equals

- 四大原则，自反性，对称性，传递性，一致性，非空性

- 如果继承一个类，并且新增了值属性，重写equals会变得很麻烦，这时候推荐用组合

- 如果重写了equals但是没有重写hashcode有可能出现equals返回true但是hashcode不相等的情况

### 泛型参数

生产者用extends，消费者用super

```java
public class NewStack<T>{
    public void pushAll(Iterable <? extends T> src) {
        for (T t : src) {
            push(t);
        }
    }
    
    public void popAll(Collection <? super T> dst){
        while (!isEmpty()){
            dst.add(pop());
        }
    }    
}

```

### synchronized使用

- 修饰实例方法: 作用于当前对象实例加锁，进入同步代码前要获得当前对象实例的锁

- 修饰静态方法: :也就是给当前类加锁，会作用于类的所有对象实例，因为静态成员不属于任何一个实例对象，是类成员（ static 表明这是该类的一个静态资源，不管new了多少个对象，只有一份）。所以如果一个线程A调用一个实例对象的非静态 synchronized 方法，而线程B需要调用这个实例对象所属类的静态 synchronized 方法，是允许的，不会发生互斥现象，因为访问静态 synchronized 方法占用的锁是当前类的锁，而访问非静态 synchronized 方法占用的锁是当前实例对象锁。

- 修饰代码块: 指定加锁对象，对给定对象加锁，进入同步代码库前要获得给定对象的锁