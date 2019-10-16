# Java读源码之LockSupport

## 前言

> JDK版本: 1.8 

看

suspend将线程挂起，运行->阻塞；调用后并不释放所占用的锁

resume将线程解挂，阻塞->就绪

2、suspend和resume这两种方法不建议使用，因为存在很多弊端。

（1）独占：因为suspend在调用过程中不会释放所占用的锁，所以如果使用不当会造成对公共对象的独占，使得其他线程无法访问公共对象，严重的话造成死锁。





 创建锁和其他同步类的基本线程阻塞原语。 

 这个类与使用它的每个线程关联一个许可证 

 如果获得许可证，对公园的呼叫将立即返回，并在此过程中消耗掉它;否则它可能阻塞。如果尚未获得许可证，则调用unpark将使许可证可用。 

 最多只有一个 许可证



 这个对象在线程被阻塞时进行记录，以允许监视和诊断工具识别线程被阻塞的原因。 



public static void unpark(线程线程)
提供给定线程的许可证(如果它还没有可用)。如果线程在park上被阻塞，那么它将解锁。否则，它的下一个调用park是保证不阻塞。如果没有启动给定的线程，则不能保证此操作有任何效果。





公共静态空间公园(对象阻挡器)
为线程调度的目的禁用当前线程，除非许可证可用。

如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下三种情况之一:
其他一些线程以当前线程为目标调用unpark;或

其他一些线程中断当前线程;或
虚假的调用(也就是说，没有任何理由)返回。

此方法不报告是哪些原因导致该方法返回



public static void parkNanos(Object blocker，
长nano)

除非有许可证，否则在指定的等待时间内，禁止当前线程用于线程调度。
如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下四种情况之一:

其他一些线程以当前线程为目标调用unpark;或
其他一些线程中断当前线程;或

指定的等候时间已过;或



public static void parktill (Object blocker，
长期限)

为了线程调度的目的，在指定的截止日期之前禁用当前线程，除非许可证可用。
如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下四种情况之一:

其他一些线程以当前线程为目标调用unpark;或
其他一些线程中断当前线程;或

超过指定期限;或
叫年代





公共静态对象getBlocker(线程t)
返回提供给park方法的最近一次调用的blocker对象，该方法尚未被解除阻塞，如果未被阻塞，则返回null。返回的值只是一个瞬时快照——线程可能在不同的blocker对象上解除了阻塞或阻塞。





公众静态空间公园()
为线程调度的目的禁用当前线程，除非许可证可用。

如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下三种情况之一:
其他一些线程以当前线程为目标调用unpark;或

其他一些线程中断当前线程;或
虚假的调用(也就是说，没有任何理由)返回。

此方法不报告是哪些原因导致该方法返回。调用者寿





public static void parkNanos(long nanos)
除非有许可证，否则在指定的等待时间内，禁止当前线程用于线程调度。

如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下四种情况之一:
其他一些线程以当前线程为目标调用unpark;或

其他一些线程中断当前线程;或
指定的等候时间已过;或

那个假的(也就是没有理由的)叫r





public static void parktill(截止时间长)
为了线程调度的目的，在指定的截止日期之前禁用当前线程，除非许可证可用。

如果许可证可用，则使用许可证并立即返回;否则，当前线程将出于线程调度的目的而被禁用，并处于休眠状态，直到发生以下四种情况之一:
其他一些线程以当前线程为目标调用unpark;或

其他一些线程中断当前线程;或
超过指定期限;或

虚假的调用(也就是说，没有任何理由)返回。
T



```java
package java.util.concurrent.locks;

public class LockSupport {
    private LockSupport() {} // Cannot be instantiated.

    private static void setBlocker(Thread t, Object arg) {
        // Even though volatile, hotspot doesn't need a write barrier here.
        UNSAFE.putObject(t, parkBlockerOffset, arg);
    }

    public static void unpark(Thread thread) {
        if (thread != null)
            UNSAFE.unpark(thread);
    }

    public static void park(Object blocker) {
        Thread t = Thread.currentThread();
        setBlocker(t, blocker);
        UNSAFE.park(false, 0L);
        setBlocker(t, null);
    }

    public static void parkNanos(Object blocker, long nanos) {
        if (nanos > 0) {
            Thread t = Thread.currentThread();
            setBlocker(t, blocker);
            UNSAFE.park(false, nanos);
            setBlocker(t, null);
        }
    }

    public static void parkUntil(Object blocker, long deadline) {
        Thread t = Thread.currentThread();
        setBlocker(t, blocker);
        UNSAFE.park(true, deadline);
        setBlocker(t, null);
    }

    public static Object getBlocker(Thread t) {
        if (t == null)
            throw new NullPointerException();
        return UNSAFE.getObjectVolatile(t, parkBlockerOffset);
    }

    public static void park() {
        UNSAFE.park(false, 0L);
    }

    public static void parkNanos(long nanos) {
        if (nanos > 0)
            UNSAFE.park(false, nanos);
    }

    public static void parkUntil(long deadline) {
        UNSAFE.park(true, deadline);
    }

    static final int nextSecondarySeed() {
        int r;
        Thread t = Thread.currentThread();
        if ((r = UNSAFE.getInt(t, SECONDARY)) != 0) {
            r ^= r << 13;   // xorshift
            r ^= r >>> 17;
            r ^= r << 5;
        }
        else if ((r = java.util.concurrent.ThreadLocalRandom.current().nextInt()) == 0)
            r = 1; // avoid zero
        UNSAFE.putInt(t, SECONDARY, r);
        return r;
    }

    // Hotspot implementation via intrinsics API
    private static final sun.misc.Unsafe UNSAFE;
    private static final long parkBlockerOffset;
    private static final long SEED;
    private static final long PROBE;
    private static final long SECONDARY;
    static {
        try {
            UNSAFE = sun.misc.Unsafe.getUnsafe();
            Class<?> tk = Thread.class;
            parkBlockerOffset = UNSAFE.objectFieldOffset
                (tk.getDeclaredField("parkBlocker"));
            SEED = UNSAFE.objectFieldOffset
                (tk.getDeclaredField("threadLocalRandomSeed"));
            PROBE = UNSAFE.objectFieldOffset
                (tk.getDeclaredField("threadLocalRandomProbe"));
            SECONDARY = UNSAFE.objectFieldOffset
                (tk.getDeclaredField("threadLocalRandomSecondarySeed"));
        } catch (Exception ex) { throw new Error(ex); }
    }

}
```

