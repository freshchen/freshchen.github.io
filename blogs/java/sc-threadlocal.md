# Java读源码之ThreadLocal

## 前言

> JDK版本: 1.8 

之前在看Thread源码时候看到这么一个属性

```java
ThreadLocal.ThreadLocalMap threadLocals = null;
```

了解到ThreadLocal实现的是每个线程都有一个本地的副本，相当于局部变量，其实ThreadLocal就是内部实现了一个map数据结构。

- 那么既然相当于局部变量，我们要这个ThreadLocal有啥必要么，需要什么就new一个出来不就行了，为什么要放到ThreadLocal中？

- ThreadLocal是线程安全的么？

- ThreadLocal可能内存泄露？

让我们带着种种疑惑进入源码吧

## 源码

### 类声明和重要属性

```java
package java.lang;

public class ThreadLocal<T> {
    
    // hash值，类似于Hashmap，用于计算放在map内部数组的哪个index上
    private final int threadLocalHashCode = nextHashCode();
    private static int nextHashCode() { return nextHashCode.getAndAdd(HASH_INCREMENT);}
	// 初始0
    private static AtomicInteger nextHashCode = new AtomicInteger();
	// 神奇的值，这个hash值的倍数去计算index，分布会很均匀，总之很6 
    private static final int HASH_INCREMENT = 0x61c88647;
    
    static class ThreadLocalMap {

        // 注意这是一个弱引用
        static class Entry extends WeakReference<ThreadLocal<?>> {
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
        // 初始容量
        private static final int INITIAL_CAPACITY = 16;
        // map内部数组
        private Entry[] table;
        // 当前储存的数量
        private int size = 0;
        // 扩容指标
        private int threshold;
```

### 重要方法

#### set(T value)

```java
public void set(T value) {
    Thread t = Thread.currentThread();
    // 拿到当前Thread对象中的threadLocals引用，默认threadLocals值是null 
    ThreadLocalMap map = getMap(t);
    if (map != null)
        // 如果ThreadLocalMap已经初始化过，就把当前ThreadLocal实例的引用当key，设置值
        map.set(this, value);
    else
        // 如果不存在就创建一个ThreadLocalMap并且提供初始值
        createMap(t, value);
}

ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}

void createMap(Thread t, T firstValue) {
    // 可以看到我们
    t.threadLocals = new ThreadLocalMap(this, firstValue);
}
```

让我们来看看map.set(this, value);具体怎么操作ThreadLocalMap

```java
private void set(ThreadLocal<?> key, Object value) {
	// 获取ThreadLocalMap内部数组
    Entry[] tab = table;
    int len = tab.length;
    // 算出需要放在哪个桶里
    int i = key.threadLocalHashCode & (len-1);
	// 如果当前桶冲突了，这里没有用拉链法，而是使用开放定指法，index递增直到找到空桶，数据量很小的情况这样效率高
    for (Entry e = tab[i]; e != null; e = tab[i = nextIndex(i, len)]) {
        // 拿到目前桶中key
        ThreadLocal<?> k = e.get();
		// 如果桶中key和我们要set的key一样，直接更新值就ok了
        if (k == key) {
            e.value = value;
            return;
        }
		// 桶中key是null，因为是弱引用，可能被回收掉了，这个时候我们直接占为己有
        if (k == null) {
            replaceStaleEntry(key, value, i);
            return;
        }
    }
	// 如果没冲突直接新建
    tab[i] = new Entry(key, value);
    int sz = ++size;
    if (!cleanSomeSlots(i, sz) && sz >= threshold)
        rehash();
}
```

