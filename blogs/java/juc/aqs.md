# Java读源码之ReentrantLock

## 前言

ReentrantLock 可重入锁，应该是除了 synchronized 关键字外用的最多的线程同步手段了，虽然虚拟机作者疯狂优化 synchronized 使其已经拥有了很好的性能。但 ReentrantLock 仍有其存在价值，使用灵活提供更细粒度线程控制，例如可以感知线程中断，公平锁模式，可以指定超时时间的抢锁等都是 synchronized 做不到的，并且高并发场景下仍有性能优势。具体使用场景就不累述了，本文主要研究一波实现原理。

## 案例

用一个最简单的使用案例引出我们的主角

```java
public class ReentrantLockDemo {

    // 默认是非公平锁和 synchronized 一样
    private static ReentrantLock reentrantLock = new ReentrantLock();

    public void printThreadInfo(int num) {
        reentrantLock.lock();
        try {
            System.out.println(num + " : " + Thread.currentThread().getName());
            System.out.println(num + " : " + Thread.currentThread().toString());
        } finally {
            reentrantLock.unlock();
        }
    }

    public static void main(String[] args) {
        ExecutorService executorService = Executors.newCachedThreadPool();
        IntStream.rangeClosed(0, 5)
                .forEach(num -> executorService
                        .execute(() -> new ReentrantLockDemo().printThreadInfo(num))
                );
    }

    /**
     * 输出:
     * 0 : pool-1-thread-1
     * 0 : Thread[pool-1-thread-1,5,main]
     * 3 : pool-1-thread-4
     * 3 : Thread[pool-1-thread-4,5,main]
     * 1 : pool-1-thread-2
     * 1 : Thread[pool-1-thread-2,5,main]
     * 2 : pool-1-thread-3
     * 2 : Thread[pool-1-thread-3,5,main]
     * 4 : pool-1-thread-5
     * 4 : Thread[pool-1-thread-5,5,main]
     * 5 : pool-1-thread-6
     * 5 : Thread[pool-1-thread-6,5,main]
     */
```

可以看到使用起来也很简单，而且达到了同步的效果。废话不多说我们来瞅一瞅 lock() 和 unlock() 两个方法是怎么实现的。

## 源码分析

主要定义了同步器属于哪个线程，换言之哪个线程独占这个同步器

### 非公平锁

#### 加锁

##### ReentrantLock.NonfairSync#lock()

```java
final void lock() {
    // 本地方法CAS更改状态
    if (compareAndSetState(0, 1))
        // 设置锁的主人为自己。上来就抢，非公平果然名不虚传
        setExclusiveOwnerThread(Thread.currentThread());
    else
        // CAS失败了，乞讨一把锁
        acquire(1);
}
```

##### AQS

一排问号有木有，改的什么状态？锁归谁管？引出隐藏大Boss：AbstractQueuedSynchronizer（AKA AQS）





```java
public abstract class AbstractOwnableSynchronizer
    implements java.io.Serializable {

    /** Use serial ID even though all fields transient. */
    private static final long serialVersionUID = 3737899427754241961L;

    /**
     * Empty constructor for use by subclasses.
     */
    protected AbstractOwnableSynchronizer() { }

    /**
     * The current owner of exclusive mode synchronization.
     */
    private transient Thread exclusiveOwnerThread;

    /**
     * Sets the thread that currently owns exclusive access.
     * A {@code null} argument indicates that no thread owns access.
     * This method does not otherwise impose any synchronization or
     * {@code volatile} field accesses.
     * @param thread the owner thread
     */
    protected final void setExclusiveOwnerThread(Thread thread) {
        exclusiveOwnerThread = thread;
    }

    /**
     * Returns the thread last set by {@code setExclusiveOwnerThread},
     * or {@code null} if never set.  This method does not otherwise
     * impose any synchronization or {@code volatile} field accesses.
     * @return the owner thread
     */
    protected final Thread getExclusiveOwnerThread() {
        return exclusiveOwnerThread;
    }
}
```



AQS 内部实现了一种叫 CLH 的高并发单链表

```java
static final class Node {
    /** Marker to indicate a node is waiting in shared mode */
    static final Node SHARED = new Node();
    /** Marker to indicate a node is waiting in exclusive mode */
    static final Node EXCLUSIVE = null;

    /** waitStatus value to indicate thread has cancelled */
    static final int CANCELLED =  1;
    /** waitStatus value to indicate successor's thread needs unparking */
    static final int SIGNAL    = -1;
    /** waitStatus value to indicate thread is waiting on condition */
    static final int CONDITION = -2;
    /**
     * waitStatus value to indicate the next acquireShared should
     * unconditionally propagate
     */
    static final int PROPAGATE = -3;

    /**
     * Status field, taking on only the values:
     *   SIGNAL:     The successor of this node is (or will soon be)
     *               blocked (via park), so the current node must
     *               unpark its successor when it releases or
     *               cancels. To avoid races, acquire methods must
     *               first indicate they need a signal,
     *               then retry the atomic acquire, and then,
     *               on failure, block.
     *   CANCELLED:  This node is cancelled due to timeout or interrupt.
     *               Nodes never leave this state. In particular,
     *               a thread with cancelled node never again blocks.
     *   CONDITION:  This node is currently on a condition queue.
     *               It will not be used as a sync queue node
     *               until transferred, at which time the status
     *               will be set to 0. (Use of this value here has
     *               nothing to do with the other uses of the
     *               field, but simplifies mechanics.)
     *   PROPAGATE:  A releaseShared should be propagated to other
     *               nodes. This is set (for head node only) in
     *               doReleaseShared to ensure propagation
     *               continues, even if other operations have
     *               since intervened.
     *   0:          None of the above
     *
     * The values are arranged numerically to simplify use.
     * Non-negative values mean that a node doesn't need to
     * signal. So, most code doesn't need to check for particular
     * values, just for sign.
     *
     * The field is initialized to 0 for normal sync nodes, and
     * CONDITION for condition nodes.  It is modified using CAS
     * (or when possible, unconditional volatile writes).
     */
    volatile int waitStatus;

    /**
     * Link to predecessor node that current node/thread relies on
     * for checking waitStatus. Assigned during enqueuing, and nulled
     * out (for sake of GC) only upon dequeuing.  Also, upon
     * cancellation of a predecessor, we short-circuit while
     * finding a non-cancelled one, which will always exist
     * because the head node is never cancelled: A node becomes
     * head only as a result of successful acquire. A
     * cancelled thread never succeeds in acquiring, and a thread only
     * cancels itself, not any other node.
     */
    volatile Node prev;

    /**
     * Link to the successor node that the current node/thread
     * unparks upon release. Assigned during enqueuing, adjusted
     * when bypassing cancelled predecessors, and nulled out (for
     * sake of GC) when dequeued.  The enq operation does not
     * assign next field of a predecessor until after attachment,
     * so seeing a null next field does not necessarily mean that
     * node is at end of queue. However, if a next field appears
     * to be null, we can scan prev's from the tail to
     * double-check.  The next field of cancelled nodes is set to
     * point to the node itself instead of null, to make life
     * easier for isOnSyncQueue.
     */
    volatile Node next;

    /**
     * The thread that enqueued this node.  Initialized on
     * construction and nulled out after use.
     */
    volatile Thread thread;

    /**
     * Link to next node waiting on condition, or the special
     * value SHARED.  Because condition queues are accessed only
     * when holding in exclusive mode, we just need a simple
     * linked queue to hold nodes while they are waiting on
     * conditions. They are then transferred to the queue to
     * re-acquire. And because conditions can only be exclusive,
     * we save a field by using special value to indicate shared
     * mode.
     */
    Node nextWaiter;

    /**
     * Returns true if node is waiting in shared mode.
     */
    final boolean isShared() {
        return nextWaiter == SHARED;
    }

    /**
     * Returns previous node, or throws NullPointerException if null.
     * Use when predecessor cannot be null.  The null check could
     * be elided, but is present to help the VM.
     *
     * @return the predecessor of this node
     */
    final Node predecessor() throws NullPointerException {
        Node p = prev;
        if (p == null)
            throw new NullPointerException();
        else
            return p;
    }

    Node() {    // Used to establish initial head or SHARED marker
    }

    Node(Thread thread, Node mode) {     // Used by addWaiter
        this.nextWaiter = mode;
        this.thread = thread;
    }

    Node(Thread thread, int waitStatus) { // Used by Condition
        this.waitStatus = waitStatus;
        this.thread = thread;
    }
}
```





独占模式下请求获取锁

- tryAcquire 由具体AQS实现给出，先尝试拿一次锁。
- 没成功就 addWaiter 用独占模式塞一个新节点到CLH队尾，返回尾巴

```java
    public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
```

进队列之后，返回的是前一个元素

```java
    /**
     * Inserts node into queue, initializing if necessary. See picture above.
     * @param node the node to insert
     * @return node's predecessor
     */
private Node enq(final Node node) {
  // 自旋
    for (;;) {
        Node t = tail;
      	// 如果队尾为空，证明队列没内容必须初始化，现在队列中只有一个节点
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
          // 如果队尾不空就插入队尾，都是调用unsafe的CAS方法
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
              // 
                return t;
            }
        }
    }
}

    /**
     * CAS head field. Used only by enq.
     */
    private final boolean compareAndSetHead(Node update) {
        return unsafe.compareAndSwapObject(this, headOffset, null, update);
    }
```

```java
private Node addWaiter(Node mode) {
    Node node = new Node(Thread.currentThread(), mode);
    // Try the fast path of enq; backup to full enq on failure
  // 先最乐观的看看能不能一次成功，不如不行就要调用 enq 以自旋的方式入 CLH队列
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    enq(node);
  // 返回的是此时的队尾
    return node;
}
```

```java
final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
          // 返回前一个节点
            final Node p = node.predecessor();
          // 如果到了头，没有前辈大哥了，就大家公平竞争抢头，并返回中断状态
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```



```java
private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
    int ws = pred.waitStatus;
    if (ws == Node.SIGNAL)
        /*
         * 前一个节点已经准备好通知下一个节点执行了，就直接抢过来 
         */
        return true;
    if (ws > 0) {
        /*
         * Predecessor was cancelled. Skip over predecessors and
         * indicate retry.
         */
        do {
            node.prev = pred = pred.prev;
        } while (pred.waitStatus > 0);
        pred.next = node;
    } else {
        /*
         * waitStatus must be 0 or PROPAGATE.  Indicate that we
         * need a signal, but don't park yet.  Caller will need to
         * retry to make sure it cannot acquire before parking.
         */
        compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
    }
    return false;
}
```