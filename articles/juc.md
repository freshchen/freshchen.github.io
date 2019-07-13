---
title: J.U.C 源码初体验
date: 2019-06-19
categories: java
top: 30
---

# 前言

功力还不够，只是粗略的看下J.U.C下类的实现方案。

## J.U.C 学习之atomic包结构

#### AtomicBoolean,AtomicInteger,AtomicIntegerArray,AtomicLong，AtomicLongArray,AtomicReference,AtomicReferenceArray

1.volatile修饰value，实现的区别是value属性的类型不同，AtomicBoolean中的value值0和1对应true和false，AtomicReference的value使用泛型

2.调用sun.misc.Unsafe中的native本地方法实现实现CAS原子性操作

```java
private volatile int value;

private static final Unsafe unsafe = Unsafe.getUnsafe();
private static final long valueOffset;
```

#### AtomicIntegerFieldUpdater,AtomicLongFieldUpdater,AtomicReferenceFieldUpdater

1. 调用sun.misc.Unsafe中的native本地方法实现实现CAS原子性操作
2. 利用反射操作类属性

```java
private static final sun.misc.Unsafe U = sun.misc.Unsafe.getUnsafe();
private final long offset;
AtomicIntegerFieldUpdaterImpl(final Class<T> tclass,final String fieldName,final Class<?> caller)
```

#### AtomicMarkableReference,AtomicStampedReference

1.引入成员静态私有类Pair，用于查看引用是否被修改，或者改变次数。

2.volatile保证修改的可见性

```java
private static class Pair<T> {
    final T reference;
    final boolean mark;
    private Pair(T reference, boolean mark) {
        this.reference = reference;
        this.mark = mark;
    }
    static <T> Pair<T> of(T reference, boolean mark) {
        return new Pair<T>(reference, mark);
    }
}

private volatile Pair<V> pair;
```

#### DoubleAccumulator,DoubleAdder,LongAccumulator,LongAdder

作用：jdk1.8中加入，主要用于高并发情景下的统计工作，不能保证细粒度的同步，不能取代Atomic前缀的类。

```java
@sun.misc.Contended static final class Cell {
    volatile long value;
    Cell(long x) { value = x; }
    final boolean cas(long cmp, long val) {
        return UNSAFE.compareAndSwapLong(this, valueOffset, cmp, val);
    }

    // Unsafe mechanics
    private static final sun.misc.Unsafe UNSAFE;
    private static final long valueOffset;
    static {
        try {
            UNSAFE = sun.misc.Unsafe.getUnsafe();
            Class<?> ak = Cell.class;
            valueOffset = UNSAFE.objectFieldOffset
                (ak.getDeclaredField("value"));
        } catch (Exception e) {
            throw new Error(e);
        }
    }
}
```

## J.U.C 学习之locks包结构

#### AbstractQueuedSynchronizer

同步锁实现的基础。

1.定义了静态不变私有属性类Node，定义了一个类似CLH的队列，用于实现等待队列和条件队列

```java
static final class Node {
    // 共享资源模式
    static final Node SHARED = new Node();
    // 独占资源模式
    static final Node EXCLUSIVE = null;
    static final int CANCELLED =  1;
    static final int SIGNAL    = -1;
    static final int CONDITION = -2;
    static final int PROPAGATE = -3;
    // 设置资源为上面四种状态
    volatile int waitStatus;
    // 前一个节点
    volatile Node prev;
    // 下一个节点
    volatile Node next;
    // 节点对应的线程
    volatile Thread thread;
    // 条件等待队列
    Node nextWaiter;
}
```

2.调用sun.misc.Unsafe中的native本地方法实现实现CAS原子性操作，CLH队列自旋

```java
private Node enq(final Node node) {
    for (;;) {
        Node t = tail;
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
                return t;
            }
        }
    }
}
```

#### ReentrantLock

1.Sync内部抽象类实现可重入同步逻辑

2.NonfairSync继承Sync实现非公平锁

3.FairSync继承Sync实现公平锁

4.其他方法通过调用Sync中的方法供外部调用

#### ReentrantReadWriteLock

1.和ReentrantLock实现方案类似，新增了ReadLock，WriteLock

#### StampedLock

1.jdk1.8以后提供的改进版的读写锁

2.不是可重入锁

#### LockSupport

1.通过Unsafe native 方法实现了挂起，唤醒的功能，AQS中也有使用

2.应该避免使用Object下的挂起操作。LockSupport.park对应Object.wait，LockSupport.unpark对应Object.notify

## J.U.C 学习之高并发数据结构

#### ArrayBlockingQueue

1.内部类Itr实现Iterator迭代器

2.Itrs将多个Itr组合起来

```java
private class Node extends WeakReference<Itr> {
    Node next;

    Node(Itr iterator, Node next) {
        super(iterator);
        this.next = next;
    }
}
```

3.使用Lock和Condition

```java
/** Main lock guarding all access */
final ReentrantLock lock;

/** Condition for waiting takes */
private final Condition notEmpty;

/** Condition for waiting puts */
private final Condition notFull;
```