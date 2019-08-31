# The All-In-One Note

- [Java8](#Java8)
  - [基础](#基础)
  - [并发](#并发)
  - [IO](#IO)
  - [JVM](#JVM)
  - [设计模式](#设计模式)
- [Java框架](#Java框架)
  - [Netty4](#Netty4)
- [服务器](#服务器)
  - [Linux常用命令](#Linux常用命令)
- [网络](#网络)
  - [TCP](#TCP)
- [数据库](#数据库)
  - [Mysql](#Mysql)
  - [Redis](#Redis)
- [分布式](#分布式)

























# Java8

## 并发

### J.U.C总览图

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/juc.png)

### J.U.C常用工具类

- **CountDownLatch**
  - 作用：主要用于一个线程要等待其他线程任务执行完再执行
- **CyclicBarrier**
  - 作用：主要用于多个线程到达起跑线之后同时等待，发令枪响齐头并进
- **Executors**
  - 作用：主要用于提供默认应用场景的线程池创建，以及一些任务调度方法
- **Semaphore**
  - 作用：主要用于限制同时执行任务的线程数量
- **Exchanger**
  - 作用：主要用于两个线程之间交换数据

### J.U.C阻塞队列BlockingQueue

- ArrayBlockingQueue
  - 结构：由数组组成的有界阻塞队列
- LinkedBlockingQueue
  - 结构：由链表组成的有界/无界阻塞队列
- LinkedTransferQueue
  - 结构：由链表组成的无界阻塞队列
- LinkedBlockingDeque
  - 结构：由链表组成的双端阻塞队列
- PriorityBlockingQueue
  - 结构：由链表组成的支持优先级排序的无界阻塞队列
- DelayQueue
  - 结构：使用PriorityQueue实现的带延迟的无界阻塞队列
- SynchronousQueue
  - 结构：不存储元素的阻塞队列

### 线程池的五种状态

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/threadpoolstatus.jpg)

### 如何创建ThreadPoolExecutor线程池

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
      - CallerRunsPolicy：只要线程池没关闭，就直接用调用者所在线程来运行任务
      - AbortPolicy：直接抛出 RejectedExecutionException异常
      - DiscardPolicy：悄悄把任务放生，不做了
      - DiscardOldestPolicy：把队列里待最久的那个任务扔了
  - 可能抛出的异常：
    - IllegalArgumentException
      - corePoolSize < 0
      - keepAliveTime < 0
      - maximumPoolSize <= 0
      - maximumPoolSize < corePoolSize
    - NullPointerException
      - workQueue，threadFactory和handler其中有一个为null
  
- 通过Executors工具类创建内置常用的线程池方案
  - newFixedThreadPool **用于负载比较重的服务器，为了资源的合理利用，需要限制当前线程数量**
  
    - 源码：
  
      ```java
      public static ExecutorService newFixedThreadPool(int nThreads) {
          return new ThreadPoolExecutor(nThreads, nThreads,
                                        0L, TimeUnit.MILLISECONDS,
                                        new LinkedBlockingQueue<Runnable>();
      }
      ```
      
     - 核心线程数和最大线程数一样，稳定高负荷工作，因此没用超出核心线程数回收的情况keepAliveTime 设置为0，等待队列用LinkedBlockingQueue无界队列

  - newSingleThreadExecutor **用于串行执行任务的场景，每个任务必须按顺序执行，不需要并发执行**
  
    - 源码：
  
      ```java
      public static ExecutorService newSingleThreadExecutor() {
          return new FinalizableDelegatedExecutorService
              (new ThreadPoolExecutor(1, 1,
                                      0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>()));
      }
      ```
  
    - 解释：
  
      类似于newFixedThreadPool，只是顾名思义池中只有一个线程干活，相当于串行 
  
  - newCachedThreadPool  **用于并发执行大量短期的小任务，或者是负载较轻的服务器**
  
    - 源码：
  
      ```java
      public static ExecutorService newCachedThreadPool() {
          return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                        60L, TimeUnit.SECONDS,
                                        new SynchronousQueue<Runnable>());
      }
      ```
  
    - 解释：
  
      没用核心线程，最大线程数无限，线程60秒没任务干就停止 ，等待队列用直接握手队列SynchronousQueue，任务直接交给线程执行不会保存
  
  - newScheduledThreadPool **用于需要多个后台线程执行周期任务，同时需要限制线程数量的场景**
  
    - 源码：
  
      ```java
      public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
          return new ScheduledThreadPoolExecutor(corePoolSize);
      }
      public ScheduledThreadPoolExecutor(int corePoolSize) {
          super(corePoolSize, Integer.MAX_VALUE,
                DEFAULT_KEEPALIVE_MILLIS, MILLISECONDS,
                new DelayedWorkQueue());
      }
      private static final long DEFAULT_KEEPALIVE_MILLIS = 10L;
      ```
  
    - 解释：
  
      ScheduledThreadPoolExecutor继承自ThreadPoolExecutor，使用优先级队列DelayedWorkQueue，运行时间短的任务先执行，否则先等待的先执行
  
  - newSingleThreadScheduledExecutor **用于需要后台单线程执行周期任务**
  
    - 解释：
  
      单线程执行版的newScheduledThreadPool ，保证任务串行执行，保证串行返回


![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/threadpool.jpg)

### synchronized关键字

- 使用方式
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
- 实现方式
  - 同步代码块：使用了monitorenter和monitorexit指令
  - 同步方法：通过方法修饰符上的ACC_AYNCHRONIZED实现
- JVM中锁升级流程
  
  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/synchronized.png)

### 如何终止线程

- stop方法（别用）
  - 立刻终止线程，过于粗鲁
  - 清理工作可能完成不了
  - 会立即释放锁，有可能引起线程不同步
- interrupt方法
  - 阻塞状态下会推出阻塞状态，抛出InterruptedException；运行状态下设置中断标志位为true，继续运行，线程自行检查标志位主动终止，相对温柔

### 线程如何通信

线程的通信是指线程之间以何种机制来交换信息，在编程中，线程之间的通信机制有两种，共享内存和消息传递

- 共享内存：线程之间共享程序的公共状态，线程之间通过写-读内存中的公共状态来隐式进行通信，典型的共享内存通信方式就是通过共享对象进行通信
- 消息传递：线程之间没有公共状态，线程之间必须通过明确的发送消息来显式进行通信，在java中典型的消息传递方式就是wait()和notify()

### notify方法和notifyAll方法的区别

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

## JVM

### 四种引用类型

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

### 常用的垃圾收集器

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

### GC如何标记垃圾对象

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

### String.intern()的用法

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

### JVM内存模型（jdk8）

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

### Java内存模型（JMM）

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/jmm.png)

### Happens-Before原则

保证单线程执行的内存可见性，多线程不能保证

- 程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作
- 监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁
- volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读
- 传递性：如果A happens-before B，且B happens-before C，那么A happens-before C
- start()规则：如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作happens-before于线程B中的任意操作
- join()规则：如果线程A执行操作ThreadB.join()并成功返回，那么线程B中的任意操作happens-before于线程A从ThreadB.join()操作成功返回
- 线程中断规则:对线程interrupt方法的调用happens-before于被中断线程的代码检测到中断事件的发生

### 指令重排

在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序

- 可以通过内存屏障避免重排序（volatile就是这么做的）
- 如果指令执行顺序不会破坏Happens-Before原则，JVM就有可能对指令重排

### 类加载双亲委派机制

- 从底向上检查ClassLoader中类是否加载
- 从顶向下调用ClassLoader加载类

### 类加载器ClassLoader种类

- BootStrapClassLoader：C++编写，加载核心库java.*
- ExtClassLoader：Java编写，加载扩展库javax.*
- AppClassLoader：Java编写，加载程序所在目录classpath
- CustomClassLoader：Java编写，定制化加载

### Java从编写到运行的大致过程

- 将写好的.java文件通过javac编译成由JVM可识别指令组成的.class文件（IED可以自动反编译.class文件，可以通过javap -c 反编译）
- 通过ClassLoader分三步加载，连接（验证，准备，解析）和初始化 将.class文件加载到JVM中
- 然后用加载的Class类经过内存分配，初始化，init调用构造来创建对象
- 最后有了对象就可以执行相关方法了

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



## IO

### BIO,NIO,AIO的区别



## 基础

### ArrayList & HashMap 扩容

- ArrayList默认大小10，装不下就扩容，每次1.5倍扩容

- HashMap默认大小16，当前容量超过总容量乘以散列因子（默认0.75）就扩容，每次2倍扩容。

### 重写equals

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



## 设计模式

[关于设计模式的一些简单案例](https://github.com/freshchen/fresh-design-pattern)

### 概念简述

- **单一责任原则**

  就一个类而言，应该只有一个引起它变化的原因。

- **开放封闭原则**

  软件实体应该是可以扩展的，但是不可修改。

- **依赖倒转原则**

  1.高层模块不应该依赖底层模块，两个都应该抽象依赖。

  2.抽象不应该依赖细节。细节应该依赖抽象。

- **迪米特法则**

  如果两个类不必彼此直接通信，那么这两个类就不应该发生直接的相互作用。如果其中一个类需要调用另一个类的摸一个方法的话，应该同通过第三方转发这个调用。

- **简单工厂模式**

  定义超类，子类通过继承重写方法实现多态，创建一个Factory工厂类，调用统一的超类接口，实例化相应的子类对象，实现解耦。

- **策略模式**

  封装实现同一功能的不同算法，通过Context上下文方式加载不同策略，可以和简单工厂模式结合使用。


- **装饰模式**

  动态地给一个对象添加一些额外的职责，就增加功能来说，装饰模式比生成子类更加灵活。

- **代理模式**

  为其他对象提供一种代理以控制对这个对象的访问。

- **工厂方法模式**

  定义一个用于创建对象的接口，让子类决定实例化哪一个类。工厂方法使一个类的实例化延迟到了其子类。

- **原型模式**

  用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。

- **模板方法模式**

  定义一个操作中的算法的骨架，而将一些步骤延迟到子类中。模板方法使得子类可以不改变一个算法的结构即可重定义该算法的某些特定的步骤。

- **外观模式（门面模式）**

  为了系统中的一组接口提供一个一致的界面，此模式定义了一个高层接口，这个接口使得这以子系统更加容易使用。

- **建造者模式**

  将一个复杂对象的构建与他的表示分离，使得同样的构建过程可以创建不同的表示。

- **观察者模式（发布订阅）**

  一对多的依赖关系，让多个观察者对象同时监听某一个主题对象。这个主题对象在状态发生变化时，会通知所有观察者对象，使它们能够自动更新自己。

- **抽象工厂方法**

  提供一个创建一系列相关或相互依赖对象的接口，而无需具体指定他们的实现。

- **状态模式**

  当一个对象的内在状态改变时允许改变其行为，这个对象看起来像是改变了其类。（状态模式主要解决的是控制一个对象状态转换的条件表达式过于复杂时的情况）

- **适配器模式**

  将一个类的接口转换成客户希望的另一个接口。Adapter模式使得原本由于接口不兼容而不能一起工作的那些类可以一起工作。

- **备忘录模式**

  在不破坏封装性的前提下，捕获一个对象的内部状态，并在对象之外保存这个状态。这样以后就可将对象恢复到原先保存的状态。

- **组合模式**

  将对象组合成树形结构以表示 “部分-整体” 的层次结构。组合模式使得用户对单个对象和组合对象的使用具有一致性。 

- **迭代器模式**

  提供一种方法顺序访问一个聚合对象中各个元素，而又不暴露该对象的内部表示。

- **单例模式**

  保证一个类仅有一个实例，并提供一个访问它的全局访问点。

- **组合聚合复用原则**

  尽量使用组合聚合，尽量不要使用类继承。

- **桥接模式**

  将抽象部分与它的实现部分分离，使它们都可以独立地变化。

- **命令模式**

  将一个请求封装为一个对象，从而使你可用不同的请求对客户进行参数化，对请求排队或记录请求日志，以及支持可撤销的操作。

- **责任链模式**

  使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系。将这个对象连成链条，并沿着这条链传递该请求，直到有一个对象处理它为止。

- **中介者模式**

  用 一个中介对象封装一系列对象交互。中介者使得各对象不需要显示地互相引用，从而使得其耦合松散，而且可以独立地改变它们之间的交互。

- **享元模式**

  运用共享技术有效地支持大量细粒度的对象。

- **解释器模式**

  给定一个语言，定义它的文法的一种表示，并定义一个解释器，这个解释器使用该表示来解释语言中的句子。

- **访问者模式**

  表示一个作用于某种对象结构中的各元素的操作。它使你可以在不改变各元素的类的前提下定义作用于这些元素的新操作。





# Java框架

## Netty4

### Netty的特点

- 一个高性能、异步事件驱动的NIO框架，它提供了对TCP、UDP和文件传输的支持
- 使用更高效的socket底层，对epoll空轮询引起的cpu占用飙升在内部进行了处理，避免了直接使用NIO的陷阱，简化了NIO的处理方式。
- 采用多种decoder/encoder 支持，对TCP粘包/分包进行自动化处理
- 可使用接受/处理线程池，提高连接效率，对重连、心跳检测的简单支持
- 可配置IO线程数、TCP参数， TCP接收和发送缓冲区使用直接内存代替堆内存，通过内存池的方式循环利用ByteBuf
- 通过引用计数器及时申请释放不再引用的对象，降低了GC频率
- 使用单线程串行化的方式，高效的Reactor线程模型
- 大量使用了volitale、使用了CAS和原子类、线程安全类的使用、读写锁的使用

### Netty执行流程

- 当客户端网络I/O请求来了就需要为其通过**Bootstrap**创建一个**Channel**，**Channel**是一个Socket的抽象
- 在创建过程中**Channel**会去**EventLoopGroup**中申请注册一个**EventLoop**，**Channel**和**EventLoopGroup**是多对一的关系，**EventLoop**对应一个Reactor线程模型
- 注册完成后**Channel**就可以执行**ChannelpipeLine**中的任务了
- **ChannelpipeLine**由各种Handler组成，主要有**ChannelInboundHandler**（读）和**ChannelOutboundHandler**（写），通过**HandlerContext**管理，各大Handler可以通过**ByteBuf**操作数据





# 服务器

## Linux常用命令

```bash
# 目录dos2unix转换格式
find . -type f -exec dos2unix {} \;
########################      $      ########################
# 变量要保留其原来的换行符要加双引号，建议所有变量引用都用双引号加大括号圈上
echo "${var}"
# 变量长度
echo "${#var}"
# 接受所有参数
$@
# 查看数组中所有元素
${list[@]}
# 查看数组长度
${#list[@]}
# 去掉全路径的文件名，只保留目录
${path%/*}
########################      =      ########################
# 定义数组
list=("1" "2" "3")
# 定义map
declare -A map=(["1"]="name" ["2"]="age")
########################     grep      ########################
# 删除空白行和注释行
cat <file> | grep -v ^# | grep .
cat <file> | grep -Ev '^$|^#'
########################     grep      ########################
# 去掉行尾巴空格
echo ${var} | sed 's/[ \t]*$//g'
# 去掉单引号
echo ${var} | sed $'s/\'//g'
########################      awk       ########################
# 例如查看状态是UNCONN,Recv-Q是0的端口信息
ss -ln | awk '($2=="UNCONN" && $3=="0") {print $0}'
# 统计状态是UNCONN,Recv-Q是0的端口的netid和出现的次数
ss -ln | awk '($2=="UNCONN" && $3=="0") {netids[$1]++}END{for(i in netids)print i "\t" netids[i]}'
########################      tr       ########################
# 大写转小写
echo ${var} | tr 'A-Z' 'a-z'
########################      od       ########################
# 字符串转ASCLL码
echo "${var}" | tr -d "\n" | od -An -t dC
########################     process      ########################
# 查看后台job
jobs
# 后台运行
( cmd ) &
# 唤醒
fg %<job_num>
# 暂停放入后台
ctrl z
# 唤醒stop的job
bg %<job_num>
# 发送信号，优先15SIGTERM，不行再9SIGKILL
kill -SIGTERM <PID>
# 杀用户所有进程
pkill -SIGTERM -u <user_name>
# 杀父进程
pkill -P <PID>
# 杀终端
pkill -SIGTERM -u <tty_name>
# 查看cpu信息
cat /proc/cpuinfo
########################     systemctl      ########################
# 查看服务单元
systemctl
systemctl --type service
systemctl list-units
# 判断状态
systemctl <is-active|is-enabled|is-failed|isolate|is-system-running> <unit_name>
# 看错误信息
systemctl --failed
systemctl status <unit_name> -l
# 看enable disable static的单元
systemctl list-unit-files
########################     journalctl      ########################
# 查看systemd日志
journalctl
# 指定级别
journalctl -p <err|debug|info|warning...>
# 持续打印
journalctl -f
# 指定单元
journalctl -u
########################     find      ########################
# 根据名字找
find <dir> -name <org>
# 根据用户找
find <dir> -user <org>
# 根据组找
find <dir> -group <org>
# 根据权限找
find <dir> -perm <org>
# 根据大小找
find <dir> -size <org>
# 根据更改找
find <dir> -mmin <org>
# 根据类型找
find <dir> -type <l|b|f>
########################     timedatectl      #####################
# 当前时钟时区
timedatectl
# 设置
timedatectl <set-ntp|set-time|set-timezone|set-local-rtc> 
########################     hostname      ########################
# 查看hostname信息
hostnamectl status
# 本地域名解析位置
cat /etc/hosts
cat /etc/resolv.conf
########################     ip      ########################
# 检查网络设备
ip addr show <eno>
# 查看网络性能
ip -s link <eno>
# 跟踪请求路径
tracepath
tracepath6
########################     nmcli      ########################
# 查看网络连接
nmcli con show
# 查看网络设备信息
nmcli dev show <eno>
# 修改网络接口
nmcli con add
nmcli con mod
# 激活/取消连接
nmcli con up "<id>"
nmcli con down "<id>"
# 网络配置文件位置
ls /etc/sysconfig/network-scripts/
########################      yum        ########################
yum <repolist|list|search|install|remove|update>
########################      rpm        ########################
# 查找rpm包
rpm -qa | grep <name>
# 查看rpm信息
rpm -qi <name>
# 解压rpm包
rpm2cpio <rpm> | cpio -id
########################     user:group      ####################
# 用户信息
cat /etc/passwd
# 组信息
cat /etc/group
# 更改用户或组
chown -R <user> <dir>
chown -R :<group> <dir>
chown -R <user>:<group> <dir>
# 改权限
chmod -R 750 <file>
########################     ssh      ########################
# 显示当前登录信息
w -f
# 公钥存放位置
cat ~/.ssh/known_hosts
# 私钥位置
ls /etc/ssh/ssh_host_*
# 创建私钥公钥对
ssh-keygen
# 将公钥复制到远程机器实现互信
ssh-copy-id <user>@<host>
########################     fs      ########################
# 检测文件挂载点
df -h
# 检测目录使用空间信息
du -h <dir>
# 文件系统挂在
mount <dir> <dir>
# 查看目录中所有打开的文件和正在运行的进程
lsof <dir>
# 取消挂载
umount <dir>
########################     ln      ########################
# 创建硬连接
ln <exist_path> <path>
# 创建软连接
ln -s <exist_path> <path>
########################      openssl        ########################
# 查看证书过期时间
openssl x509 -noout -enddate -in <crt_path>
# 获取端口证书过期时间
echo 'Q' | timeout 5 openssl s_client -connect <host:port> 2>/dev/null | openssl x509 -noout -enddate
# 自签根证书
openssl genrsa -aes256 -out <ca私钥位置> 2048
openssl req -new -key <ca私钥位置> -out <ca签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress="
openssl x509 -req -sha256 -days <过期天数> -in <ca签发流程位置> -out <ca证书位置> -signkey <ca私钥位置> -CAcreateserial
# 根证书签发子证书
openssl genrsa -aes256 -out <私钥位置> 2048
openssl req -new -key <私钥位置> -out <签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" 
openssl x509 -req -sha256 -days <过期天数> -in <签发流程位置> -out <证书位置> -signkey <私钥位置> -CAkey <ca私钥> -CA <ca证书位置> -CAcreateserial
openssl pkcs12 -export -clcerts -in <证书位置> -inkey <私钥位置> -out <p12证书位置> -name <别名>
########################      keytool        ########################
# 查看keystore
${JAVA_HOME}/bin/keytool -v -list -storepass <password> -keystore <keystore_path>
# 导入trust keystore
${JAVA_HOME}/bin/keytool -import -trustcacerts -noprompt -alias <别名> -file <证书位置> -keystore <Keystore位置>
# 导入keystore
${JAVA_HOME}/bin/keytool -importkeystore -trustcacerts -noprompt -alias <别名> -deststoretype pkcs12 -srcstoretype pkcs12 -srckeystore <p12证书位置> -destkeystore <Keystore位置>
########################      docker        ########################
# 删除tag和name为none的坏掉的image
docker rmi $(docker images -f "dangling=true" -q)
# 删掉所有容器
docker stop $(docker ps -qa)
docker kill $(docker ps -qa)
docker rm $(docker ps -qa)
# 删除所有镜像
docker rmi --force $(docker images -q)
########################      openssl        ########################
# 查看证书过期时间
openssl x509 -noout -enddate -in <crt_path>
# 获取端口证书过期时间
echo 'Q' | timeout 5 openssl s_client -connect <host:port> 2>/dev/null | openssl x509 -noout -enddate
# 自签根证书
openssl genrsa -aes256 -out <ca私钥位置> 2048
openssl req -new -key <ca私钥位置> -out <ca签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress="
openssl x509 -req -sha256 -days <过期天数> -in <ca签发流程位置> -out <ca证书位置> -signkey <ca私钥位置> -CAcreateserial
# 根证书签发子证书
openssl genrsa -aes256 -out <私钥位置> 2048
openssl req -new -key <私钥位置> -out <签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" 
openssl x509 -req -sha256 -days <过期天数> -in <签发流程位置> -out <证书位置> -signkey <私钥位置> -CAkey <ca私钥> -CA <ca证书位置> -CAcreateserial
openssl pkcs12 -export -clcerts -in <证书位置> -inkey <私钥位置> -out <p12证书位置> -name <别名>
########################      keytool        ########################
# 查看keystore
${JAVA_HOME}/bin/keytool -v -list -storepass <password> -keystore <keystore_path>
# 导入trust keystore
${JAVA_HOME}/bin/keytool -import -trustcacerts -noprompt -alias <别名> -file <证书位置> -keystore <Keystore位置>
# 导入keystore
${JAVA_HOME}/bin/keytool -importkeystore -trustcacerts -noprompt -alias <别名> -deststoretype pkcs12 -srcstoretype pkcs12 -srckeystore <p12证书位置> -destkeystore <Keystore位置>
```



# 网络

## TCP

### TCP粘包，拆包

粘包拆包问题是处于网络比较底层的问题，在数据链路层、网络层以及传输层都有可能发生。我们日常的网络应用开发大都在传输层进行，由于UDP有消息保护边界，不会发生粘包拆包问题，因此粘包拆包问题只发生在TCP协议中

- 什么是粘包、拆包

  例如客户端给服务端发了两个包，包1和包2，服务端收到了一个包（包1和包2首尾连在一起）就叫做粘包，如果服务端正常收到两个包，但是第一个包是包1的前半部分，第二个包是包1的后半部分加上包2，就叫做发生了粘包和拆包

- 为什么会发生粘包、拆包

  - 应用程序写入的数据大于套接字缓冲区大小，这将会发生拆包
  - 进行MSS（最大报文长度）大小的TCP分段，当TCP报文长度-TCP头部长度>MSS的时候将发生拆包
  - 以太网帧的payload（净荷）大于MTU（1500字节）进行ip分片
  - 接收方法不及时读取套接字缓冲区数据，这将发生粘包
  - 应用程序写入数据小于套接字缓冲区大小，网卡将应用多次写入的数据发送到网络上，这将会发生粘包

- 粘包、拆包解决办法

  - 发送端给每个数据包添加包首部，首部中应该至少包含数据包的长度，这样接收端在接收到数据后，通过读取包首部的长度字段，便知道每一个数据包的实际长度了
  - 发送端将每个数据包封装为固定长度（不够的可以通过补0填充），这样接收端每次从接收缓冲区中读取固定长度的数据就自然而然的把每个数据包拆分开来
  - 可以在数据包之间设置边界，如添加特殊符号，这样，接收端通过这个边界就可以将不同的数据包拆分开





# 数据库

## Redis

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



## Mysql

### Mysql常用命令

```mysql
# 查配置
show variables like '%';
# 放开用户的远程操作权限
GRANT ALL PRIVILEGES ON *.* TO '<user>'@'%' IDENTIFIED BY '<password>' WITH GRANT OPTION;
# 刷新权限规则生效
flush privileges;
# 在线改配置
set <global|session>
```

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



# 分布式

### 一致性哈希算法

主要用于解决分布式系统中负载均衡的问题。

一般情况：

- 假设数据对2^32取模，构成一个虚拟圆环
- 例如几台服务器的ip取模映射到环上，把服务器放到圆环中对应的位置
- 然后数据过来之后取模映射完之后，开始顺时针找最近的服务器处理

问题：服务器数量不多，容易出现数据倾斜问题（服务器分布不均匀，缓存数据集中在部分服务器上）

解决方案：可以增加虚拟节点，例如在主机ip后加编号取模映射到环的不同位置。然后数据遇到虚拟节点之后再映射回真实节点。



