# Quick Note





























### Java如何创建线程池

- 直接通过new ThreadPoolExecutor()创建（推荐，可以定制化，控制细节）
  - 构造参数：
    - int corePoolSize：线程池正常运行时的核心线程数，即使空闲也会等待任务
    - 在线程数少于核心数量时，有新任务进来就新建一个线程，即使有的线程没事干
    - 等超出核心数量后，就不会新建线程了，空闲的线程就得去任务队列里取任务执行了
    - int maximumPoolSize：线程池允许的最大线程数
      - 如果任务队列满了，并且池中线程数小于最大线程数，会再创建新的线程执行任务
    - long keepAliveTime：超出corePoolSize的线程的存活时间
    - TimeUnit unit：keepAliveTime参数的时间单位
    - BlockingQueue<Runnable> workQueue：核心线程全在干活，新任务进去这个阻塞队列等待执行，**只有执行execute方法时才会进入等待队列**
    - ThreadFactory threadFactory：创建新线程的工厂
    - RejectedExecutionHandler handler：workQueue满了，池中线程数也到了maximumPoolSize，就需要执行拒绝策略
      - `CallerRunsPolicy`：只要线程池没关闭，就直接用调用者所在线程来运行任务
  - 可能抛出的异常：
    - IllegalArgumentException
      - corePoolSize < 0
      - keepAliveTime < 0
      - maximumPoolSize <= 0
      - maximumPoolSize < corePoolSize
    - NullPointerException
      - workQueue，threadFactory和handler其中有一个为null
  
- 通过Executors工程创建常用的线程池方案
  - newFixedThreadPool


![](../../resource/images/threadpool.jpg)

### Java中synchronized使用

- 获取对象锁
  - 同步代码块: 指定加锁对象，对给定对象加锁
    - synchronized(this){}
  - 同步非静态方法: 作用于当前对象实例加锁，进入同步代码前要获得当前对象实例的锁
    - public synchronized void methodA(){}
- 获取类锁
  - 同步代码块: 指定加锁的类，对给定类加锁
    - synchronized(类名.class){}
  - 同步静态方法: 作用于当前对象实例加锁，进入同步代码前要获得当前对象实例的锁
    - public synchronized  static void methodA(){}

### java如何终止线程

- stop方法（别用）
  - 立刻终止线程，过于粗鲁
  - 清理工作可能完成不了
  - 会立即释放锁，有可能引起线程不同步
- interrupt方法
  - 阻塞状态下会推出阻塞状态，抛出InterruptedException；运行状态下设置中断标志位为true，继续运行，线程自行检查标志位主动终止，相对温柔

### Java中notify方法和notifyAll方法的区别

当调用wait方法后，线程会被放到对象内部的等待池中，在等待池中的线程不会去竞争CPU，只有调用Notify或者NotifyAll才会从等待池中，放入锁池中，等待对象锁的释放从而竞争CPU以执行。

- notify从等待池中随机选一个线程放入锁池
- notifyAll把所有等待池全放入锁池

### Java中sleep方法和wait方法的区别

- sleep
  - Thread类方法
  - 让出CPU，不改变锁状态
  - 任意位置执行

- wait
  - Object类方法
  - 让出CPU，释放当前占用的锁
  - 只能在synchronized中的中使用

### B树和B+树定义与区别

- M阶B树
  - 定义
    - 任意非叶子结点最多只有M个儿子，且M>2
    - 根结点的儿子数为[2, M]
    - 除根结点以外的非叶子结点的儿子数为[M/2, M]，向上取整
    - 非叶子结点的关键字个数=儿子数-1
    - 所有叶子结点位于同一层
    - k个关键字把节点拆成k+1段，分别指向k+1个儿子，同时满足查找树的大小关系
  - 特征
    - 关键字集合分布在整颗树中
    - 任何一个关键字出现且只出现在一个结点中
    - 搜索有可能在非叶子结点结束
    - 其搜索性能等价于在关键字全集内做一次二分查找
- M阶B+树
  - 定义
    - 有n棵子树的非叶子结点中含有n个关键字（b树是n-1个），这些关键字不保存数据，只用来索引，所有数据都保存在叶子节点（b树是每个关键字都保存数据）
    - 所有的叶子结点中包含了全部关键字的信息，及指向含这些关键字记录的指针，且叶子结点本身依关键字的大小自小而大顺序链接
    - 所有的非叶子结点可以看成是索引部分，结点中仅含其子树中的最大（或最小）关键字
    - 通常在b+树上有两个头指针，一个指向根结点，一个指向关键字最小的叶子结点
    - 同一个数字会在不同节点中重复出现，根节点的最大元素就是b+树的最大元素
  - 特征
    - b+树的中间节点不保存数据，所以磁盘页能容纳更多节点元素，更“矮胖”
    - b+树查询必须查找到叶子节点，b树只要匹配到即可不用管元素位置，因此b+树查找更稳定（并不慢）
    - 对于范围查找来说，b+树只需遍历叶子节点链表即可，b树却需要重复地中序遍历

### Java中的四种引用类型

- 强引用
  - 最普遍的引用：Object obj = new Object();
  - 宁可抛出OOM异常也不会回收有强引用的对象
  - 通过将对象设置为null，使其被回收（栈pop中用到）
- 软引用
  - 对象处在有用但是非必须的状态
  - 只有内存空间不足才回收
  - 可以用来实现高速缓存
- 弱引用
  - 对象处在有用但是非必须的状态，比软引用更没用一点
  - GC时会被回收
  - 适用于偶尔使用且不希望影响垃圾收集的对象
- 虚引用
  - 不会觉得对象生命周期
  - 任何时候会被回收
  - 用于跟踪GC活动，起哨兵作用
  - 必须与引用队列ReferenceQueue联合使用

### JVM常用的垃圾收集器

- 年轻代

  - Serial收集器（-XX:+UseSerialGC，复制算法）
    - 单线程，进行回收时，必须停止所有工作线程
    - 简单高效，Client模式下默认的年轻代收集器 
  - ParNew收集器（-XX:+UseParNewGC，复制算法）
    - 多线程并行，其他类似Serial收集器
    - 多核下优势
  - Parallel收集器（-XX:+UseParallelGC，复制算法）
    - 多线程并行，更关注性能，吞吐量，而不是GC停顿
    - 多核下优势，Server模式下默认的年轻代收集器

- 老年代

  - Serial Old收集器（-XX:+UseSerialOldGC，标记-整理算法）
    - 单线程，进行回收时，必须停止所有工作线程
    - 简单高效，Client模式下默认的老年代收集器 
  - Parallel Old收集器（-XX:+UseParallelOldGC，标记-整理算法）
    - 多线程并行，其他类似Serial Old收集器
    - 多核下优势
  - CMS收集器（-XX:+UseConcMarkSweepGC，标记-清除算法）
    - 多线程并发

- 通用

  - G1收集器（-XX:+UseG1GC，复制+标记-整理算法）

    - 分代收集
    - 空间整合
    - 可预测的停顿
    - 多线程并发

    - 将Heap堆内存划分成多个大小相等的Region
    - 年轻代和老年代不再物理隔离

### CMS收集器执行步骤

- 初始阶段：stop-the-world
- 并发标记：并发追溯标记，程序不停顿
- 并发预清理：查找并发标记阶段从新生代晋升老年代的对象
- 重新标记：stop-the-world，扫描CMS堆中的剩余对象
- 并发清理：清理垃圾对象，程序不停顿
- 并发重置：重置CMS收集器的数据结构，程序不停顿

### JVM常用调优参数

- -Xss: 规定每个线程虚拟机栈的大小
- -Xms: 堆的初始值
- -Xmx: 堆能扩展的最大值
- -XX:SurvivorRatio：Eden区和其中一个Survivor区的比值
- -XX:NewRatio：老年代和新生代比值
- -XX:MaxTenuringThreshold：对象从年轻代进入老年代经历过GC次数的阈值

### JVM常用的垃圾回收算法

- 标记-清除算法
  - 缺点：容易产生碎片化
- 复制算法（适用与对象存活率低的场景）
  - 优点：不会碎片化
  - 缺点：浪费50%空间
- 标记-整理算法（适用于对象存活率高场景）
  - 优点：标记清除的加强版，不会碎片化
  - 缺点：性能差一点
- 分代收集算法
  - Minor GC：使用复制算法处理年轻代（eden区8/10，from survivor区1/10，to survivor区1/10），默认经历15次Minor GC仍然存活就进老年代，执行条件如下：
    - 年轻代满了执行
    - Full GC触发时也会执行
  - Full GC：主要使用标记-整理算法处理老年代（老年代默认是年轻代的两倍），执行条件如下：
    - 老年代满了执行
    - 使用CMS垃圾收集器时候，出现promotion failed或concurrent mode failed时候也会执行
    - 调用System.gc()后的某个时刻
    - 使用RMI时，一般每小时执行一次GC

### 何时真正开始Full GC（stop-the-world）

程序到达安全点，安全点是对象引用关系不会变化的点，例如方法调用，循环跳转，异常跳转等

### JavaGC如何标记垃圾对象

没有被任何其他对象引用的对象被视为垃圾。

问1：JavaGC中如何判断对象是否被引用

答1：GC中主要有两种引用判断方法

- 引用计数法
  - 优点：执行效率高
  - 缺点：无法检测出循环引用情况，导致内存泄漏
- 可达性分析法（主流）

问2：可达性分析中，哪些对象可作为GC root

答2：

- 虚拟机栈中变量表引用的对象
- 方法区中常量引用的对象
- 方法区中类静态属性引用的对象
- 本地方法栈中JNI引用的对象
- 活跃线程的引用对象

### Java中String.intern()的用法

- 作用
  - 直接使用双引号声明出来的`String`对象会直接存储在常量池中。
  - 如果不是用双引号声明的`String`对象，可以使用`String`提供的`intern`方法。intern 方法会从字符串常量池中查询当前字符串是否存在，若不存在就会将当前字符串放入常量池中的StringTable，StringTable默认大小1009，可以通过参数修改 -XX:StringTableSize=111111

- 区别

  - jdk6之前包括jdk6，intern方法会在常量池中创建相同String对象
  - jdk7开始，intern只会把堆中String对象的引用放入常量池中，主要原因是常量池从永久代已移入堆中

```java
String s = new String("1");
s.intern();
String s2 = "1";
System.out.println(s == s2);

String s3 = new String("1") + new String("1");
s3.intern();
String s4 = "11";
System.out.println(s3 == s4);

// 打印结果是
// jdk6 下false false
// jdk7 下false true

String s = new String("1");
String s2 = "1";
s.intern();
System.out.println(s == s2);

String s3 = new String("1") + new String("1");
String s4 = "11";
s3.intern();
System.out.println(s3 == s4);

// 打印结果是
// jdk6 下false false
// jdk7 下false false
```

### Java内存模型（jdk8）

- 线程私有
  - 程序计数器，唯一不会OOM的区域
  - 虚拟机栈
    - 局部变量表
    - 操作栈
    - 动态链接
    - 返回地址
  - 本地方法栈
- 线程共享 
  - Metadata元空间
    - 本地内存存放Class对象
  - heap堆
    - 常量池
    - 实例对象

### Java类加载双亲委派机制

- 从底向上检查ClassLoader中类是否加载
- 从顶向下调用ClassLoader加载类

### Java类加载器ClassLoader种类

- BootStrapClassLoader：C++编写，加载核心库java.*
- ExtClassLoader：Java编写，加载扩展库javax.*
- AppClassLoader：Java编写，加载程序所在目录classpath
- CustomClassLoader：Java编写，定制化加载

### Java从编写到运行的大致过程

- 将写好的.java文件通过javac编译成由JVM可识别指令组成的.class文件（IED可以自动反编译.class文件，可以通过javap -c 反编译）
- 通过ClassLoader分三步加载，连接（验证，准备，解析）和初始化 将.class文件加载到JVM中
- 然后用加载的Class类经过内存分配，初始化，init调用构造来创建对象
- 最后有了对象就可以执行相关方法了

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

### Java不可变对象

- 对象创建之后状态不能修改

- 对象的所有的域都是final类型

- 对象是正确创建的（对象创建过程中，this引用没用逃逸）

### Java如何安全发布对象

- 在静态初始化函数中初始化一个对象引用

- 将对象的引用保存到正确的构造对象的final类型域中

- 将对象的引用保存到一个由锁保护的域中

- 将对象的引用用volatile关键字修饰，或者保存到AtomicReference对象中


### Java为什么双检查单例模式实例引用不加volatile不是线程安全的

- 对象发布主要有三步 1.分配内存空间 2初始化对象 3引用指向分配的内存

- 由于指令重排的存在，可能出现132的顺序，多线程环境下，可能出现 instance != null  但是初始化工作还没完成的情况在占有锁的线程没有完成初始化时，另一个线程认为以及初始化完毕了去使用对象的时候便会有问题

- 加上 volatile 关键字就可以解决指令重排的问题

### JVM内存泄漏情景

- 类似于栈，内存的管理权不属于JVM而属于栈本身，所有被pop掉的index上还存在着过期的引用Stack.pop()的源码中手动清除了过期引用
elementData[elementCount] = null; /* to let gc do its work

- 将对象引用放入了缓存，可以用WeakHashMap作为引用外键

- 监听器和其他回调，可以用WeakHashMap作为引用外键


### Java中ArrayList & HashMap 扩容

- ArrayList默认大小10，装不下就扩容，每次1.5倍扩容

- HashMap默认大小16，当前容量超过总容量乘以散列因子（默认0.75）就扩容，每次2倍扩容。

### Java重写equals

- 四大原则，自反性，对称性，传递性，一致性，非空性

- 如果继承一个类，并且新增了值属性，重写equals会变得很麻烦，这时候推荐用组合

- 如果重写了equals但是没有重写hashcode有可能出现equals返回true但是hashcode不相等的情况

### Java泛型参数

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
