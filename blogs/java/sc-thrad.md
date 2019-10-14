# Java读源码之Thread

### 前言

> JDK版本：1.8

阅读了Object的源码，wait和notify方法与线程联系紧密，而且多线程已经是必备知识，那保持习惯，就从多线程的源头Thread类开始读起吧。由于该类比较长，只读重要部分

### 源码

#### Java线程有几种状态？

```java
// Thread类中的枚举
public enum State {
    // 线程刚创建出来还没start
    NEW,
    // 线程在JVM中运行了，需要去竞争资源，例如CPU
    RUNNABLE,
    // 线程等待获取对象监视器锁，损被别人拿着就阻塞
    BLOCKED,
    // 线程进入等待池了，等待觉醒
    WAITING,
    // 指定了超时时间
    TIMED_WAITING,
    // 线程终止
    TERMINATED;
}
```

下面这个图可以帮助理解Java线程的生命周期，**这个图要会画**！面试中被问到，当时画的很不专业，难受！

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-status.jpg)

#### 创建

那么线程如何进入初始New状态呢？让我们来看看构造，头皮发麻，怎么有七八个构造，这里只贴了一个

```java
public Thread() {
    init(null, null, "Thread-" + nextThreadNum(), 0);
}
```

还好都是调用init()方法，怕怕的点开了

```java
private void init(ThreadGroup g, Runnable target, String name,
                  long stackSize, AccessControlContext acc,
                  boolean inheritThreadLocals) {
    if (name == null) {
        throw new NullPointerException("name cannot be null");
    }

    this.name = name;
	// 获取当前线程，也就是需要被创建线程的爸爸
    Thread parent = currentThread();
    SecurityManager security = System.getSecurityManager();
    if (g == null) {
        // 通过security获取线程组，其实就是拿的当前线程的组
        if (security != null) {
            g = security.getThreadGroup();
        }

        // 获取当前线程的组，这下确保肯定有线程组了
        if (g == null) {
            g = parent.getThreadGroup();
        }
    }

    // check一下组是否存在和是否有线程组修改权限
    g.checkAccess();

    // 子类执行权限检查，子类不能重写一些不是final的敏感方法
    if (security != null) {
        if (isCCLOverridden(getClass())) {
            security.checkPermission(SUBCLASS_IMPLEMENTATION_PERMISSION);
        }
    }
	// 组里未启动的线程数加1，长时间不启动就会被回收
    g.addUnstarted();
	// 线程的组，是否后台，优先级，初始全和当前线程一样
    this.group = g;
    this.daemon = parent.isDaemon();
    this.priority = parent.getPriority();
    if (security == null || isCCLOverridden(parent.getClass()))
        // 子类重写check没过或者就没有security，这里要check下是不是连装载的权限都没有
        this.contextClassLoader = parent.getContextClassLoader();
    else
        this.contextClassLoader = parent.contextClassLoader;
    // 访问控制上下文初始化
    this.inheritedAccessControlContext =
        acc != null ? acc : AccessController.getContext();
    // 任务初始化
    this.target = target;
    // 设置权限
    setPriority(priority);
    // 如果有需要继承的ThreadLocal局部变量就copy一下
    if (inheritThreadLocals && parent.inheritableThreadLocals != null)
        this.inheritableThreadLocals =
        ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
    // 初始化JVM中待创建线程的栈大小
    this.stackSize = stackSize;

    // threadSeqNumber线程号加1
    tid = nextThreadID();
}
```

#### 运行

现在线程已经是NEW状态了，我们还需要调用start方法，让线程进入RUNNABLE状态，真正在JVM中快乐的跑起来，当获得了执行任务所需要的资源后，JVM便会调用target（Runnable）的run方法。

**注意：我们永远不要对同一个线程对象执行两次start方法**

```java
public synchronized void start() {
    // 0就是NEW状态
    if (threadStatus != 0)
        throw new IllegalThreadStateException();

    // 把当前线程加到线程组的线程数组中，然后nthreads线程数加1，nUnstartedThreads没起的线程数减1
    group.add(this);

    boolean started = false;
    // 请求资源
    try {
        start0();
        started = true;
    } finally {
        try {
            if (!started) {
    // 起失败啦，把当前线程从线程组的线程数组中删除，然后nthreads减1，nUnstartedThreads加1
                group.threadStartFailed(this);
            }
        } catch (Throwable ignore) {
            // start0出问题会自己打印堆栈信息
        }
    }
}

private native void start0();
```

#### 终止

现在我们的线程已经到RUNNABLE状态了，一切顺利的话任务执行完成，自动进入TERMINATED状态，天有不测风云，我们还会再各个状态因为异常到达TERMINATED状态。

Thread类为我们提供了interrupt方法，可以设置中断标志位，设置了中断之后不一定有影响，还需要满足一定的条件才能发挥作用：

- **RUNNABLE**状态下
  - 默认什么都不会发生，需要代码中循环检查 中断标志位
- **WAITING**/**TIMED_WAITING**状态下
  - 这两个状态下，会从对象等待池中出来，等拿到监视器锁会抛出**InterruptedException**异常，然后中断标志位被清空。但是如果我们同时调用了notify和interrupt方法，程序可能不会停止继续执行可能抛异常停止
- **BLOCKED**状态下
  - 如果线程在等待锁，对线程对象调用interrupt()只是会设置线程的中断标志位，**线程依然会处于BLOCKED状态**
- **NEW**/**TERMINATE**状态下
  - 啥也不发生

```java
// 设置别的线程中断
public void interrupt() {
    if (this != Thread.currentThread())
        checkAccess();
	// 拿一个可中断对象Interruptible的锁
    synchronized (blockerLock) {
        Interruptible b = blocker;
        if (b != null) {
            interrupt0();           // 设置中断标志位
            b.interrupt(this);
            return;
        }
    }
    interrupt0();
}

// 获取当前线程中断标志位，然后重置中断标志位
public static boolean interrupted() {
    return currentThread().isInterrupted(true);
}

// 检查线程中断标志位
public boolean isInterrupted() {
    return isInterrupted(false);
}
```

#### 等待

实际线程的











#### 其他方法

##### yield

告诉操作系统的调度器：我的cpu可以先让给其他线程,但是我占有的同步资源不让。

**注意，调度器可以不理会这个信息**。这个方法几乎没用，调试并发bug可能能派上用场

```java
public static native void yield();
```



















#### 类声明和重要属性

```java
package java.lang;

public class Thread implements Runnable {

    private volatile String name;
    private int            priority;
    private Thread         threadQ;
    private long           eetop;

    /* Whether or not to single_step this thread. */
    private boolean     single_step;

    //是否后台
    private boolean     daemon = false;

    /* JVM state */
    private boolean     stillborn = false;
    // 要跑的任务
    private Runnable target;
    // 线程组
    private ThreadGroup group;
    // 上下文加载器
    private ClassLoader contextClassLoader;
    // 权限控制上下文
    private AccessControlContext inheritedAccessControlContext;

    /* For autonumbering anonymous threads. */
    private static int threadInitNumber;
    private static synchronized int nextThreadNum() {
        return threadInitNumber++;
    }

    /* ThreadLocal values pertaining to this thread. This map is maintained
     * by the ThreadLocal class. */
    ThreadLocal.ThreadLocalMap threadLocals = null;

    /*
     * InheritableThreadLocal values pertaining to this thread. This map is
     * maintained by the InheritableThreadLocal class.
     */
    ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;

    /*
     * The requested stack size for this thread, or 0 if the creator did
     * not specify a stack size.  It is up to the VM to do whatever it
     * likes with this number; some VMs will ignore it.
     */
    private long stackSize;

    /*
     * JVM-private state that persists after native thread termination.
     */
    private long nativeParkEventPointer;

    /*
     * Thread ID
     */
    private long tid;

    // 线程init之后的ID
    private static long threadSeqNumber;

    // 0就是线程还处于NEW状态，没start
    private volatile int threadStatus = 0;


    /**
     * The argument supplied to the current call to
     * java.util.concurrent.locks.LockSupport.park.
     * Set by (private) java.util.concurrent.locks.LockSupport.setBlocker
     * Accessed using java.util.concurrent.locks.LockSupport.getBlocker
     */
    volatile Object parkBlocker;

    /* The object in which this thread is blocked in an interruptible I/O
     * operation, if any.  The blocker's interrupt method should be invoked
     * after setting this thread's interrupt status.
     */
    private volatile Interruptible blocker;
    private final Object blockerLock = new Object();

    /* Set the blocker field; invoked via sun.misc.SharedSecrets from java.nio code
     */
    void blockedOn(Interruptible b) {
        synchronized (blockerLock) {
            blocker = b;
        }
    }

    /**
     * The minimum priority that a thread can have.
     */
    public final static int MIN_PRIORITY = 1;

   /**
     * The default priority that is assigned to a thread.
     */
    public final static int NORM_PRIORITY = 5;

    /**
     * The maximum priority that a thread can have.
     */
    public final static int MAX_PRIORITY = 10;
```

