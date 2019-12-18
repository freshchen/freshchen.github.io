# Java读源码之ArrayList

### 前言

 JDK版本: 1.8 

Java中用的最频繁的应该就是各种集合类了，而ArrayList又是线性表中用的比较多的，且是面试常考点，很值得深入研究一下，先上一张类结构图

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/sc-arraylist.png)

内容较多，这里挑比较重点的内容来读

### 源码

#### 类声明

```java
public class ArrayList<E> extends AbstractList<E> implements List<E>, RandomAccess, Cloneable, java.io.Serializable
```

#### 构造

| Constructor |  Description                                  |
| ---|---|
| `ArrayList()`|构造一个空的List，第一次新增之后默认初始化容量10 |
| `ArrayList(Collection c)`|构造一个包含指定集合的元素的List，按集合的迭代器返回元素的顺序排列. |
| `ArrayList(int initialCapacity)`|构造一个空的List，指定初始化容量 |

#### 主要属性

```java
    /**
     * 默认初始化大小
     */
    private static final int DEFAULT_CAPACITY = 10;

    /**
     * Shared empty array instance used for empty instances.
     */
    private static final Object[] EMPTY_ELEMENTDATA = {};

    /**
     * Shared empty array instance used for default sized empty instances. We
     * distinguish this from EMPTY_ELEMENTDATA to know how much to inflate when
     * first element is added.
     */
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    /**
     * The array buffer into which the elements of the ArrayList are stored.
     * The capacity of the ArrayList is the length of this array buffer. Any
     * empty ArrayList with elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA
     * will be expanded to DEFAULT_CAPACITY when the first element is added.
     */
    transient Object[] elementData; // non-private to simplify nested class access

    /**
     * The size of the ArrayList (the number of elements it contains).
     *
     * @serial
     */
    private int size;
```

