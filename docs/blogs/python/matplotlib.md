# Python可视化库（绘制图表）matplotlib


## 动机

作为一个初级JAVA工作者，最近尝试学习机器学习，看完晕头转向的一些概念之后，尝试实现了第一个PLA感知机算法，成功之后甚至想叉腰得瑟一会。正在得意洋洋之时，如何让算法结果可视化呢，网上搜索了半天发现了一个好用的python第三方库matplotlib。

## matplotlib可以做什么

Matplotlib 能够创建多数类型的图表，如条形图，散点图，条形图，饼图，堆叠图，3D 图和地图图表。并且可以对图片进行调整并且保存。既然是可视化工具，就不过多介绍让我们直接实战体验吧。可能还会用到Python的一个第三方科学计算库numpy，其功能主要是对向量的一些科学计算，只会用到比较简单的计算。

## 实战演练

### 准备工作

安装matplotlib非常方便，Python3自带pip直接如下安装即可：

```python
pip install matplotlib
```

安装完成后需要引入模块如下，我们习惯将numpy别名为np，matplotlib别名为plt，为了节省篇幅就不重复导入了

```python
import matplotlib.pyplot as plt
import numpy as np
```

### 直线

首先我们构造出想画出的向量，然后调用plt.plot()绘制，通过plt.show()展现出来，如果想直接保存到本地可以加上plt.savefig()方法。让我们从画一条线开始吧。

```python
x = np.array([1, 2, 3])
plt.plot(x)
plt.show()
```

![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/line1.png?raw=true)

这个库用起来真的很简单，我们试试画两条线并且再添加一些说明信息

```python
x = np.array([1, 2, 3])
y = np.array([5, 6, 7])
plt.plot(x, label='first line')
plt.plot(y, label='second line')
# 横坐标注释
plt.xlabel('Plot Number')
# 列坐标注释
plt.ylabel('Important var')
# 生成表标题
plt.title('Matplotlib demo\nCheck it out')
# 生成小方块显示每条线对应的label
plt.legend()
plt.show()
```

![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/twoline.png?raw=true)

### 条形图

```python
one = np.array([[1, 3, 5, 7, 9], [3, 4, 6, 12, 7]])
two = np.array([[2, 4, 6, 8, 10], [4, 2, 9, 8, 11]])
# 参数1是横坐标，参数2是高度
plt.bar(one[0], one[1], label='first')
plt.bar(two[0], two[1], label='second')
plt.xlabel('bar-hist Number')
# 列坐标注释
plt.ylabel('bar-hist height')
# 生成表标题
plt.title('Matplotlib demo\nCheck it out')
# 生成小方块显示每条线对应的label
plt.legend()
plt.show()
```

![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/bar1.png?raw=true)

### 直方图

```python
# 原始数据
population_ages = [22, 55, 62, 45, 21, 22, 34, 42, 42, 4, 99, 102, 110, 120, 121, 122, 130, 111, 115, 112, 80, 75, 65,
                   54, 44, 43, 42, 48, 12, 32, 44, 9, 7]
# 横坐标，表示增量
bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130]
plt.hist(population_ages, bins, histtype='bar', rwidth=0.8)
plt.xlabel('x')
plt.ylabel('y')
plt.title('Matplotlib demo\nCheck it out')
plt.show()
```

![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/hist1.png?raw=true)

### 散点图

```python
data = np.array([[1, 2], [2, 3], [5, 6]])
# marker有许多图标：https://matplotlib.org/api/markers_api.html
plt.scatter(data[:, 0], data[:, 1], label='skitscat', color='k', s=25, marker="o")
plt.xlabel('x')
plt.ylabel('y')
plt.title('Matplotlib demo\nCheck it out')
plt.legend()
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/scatter1.png?raw=true)

### 堆叠图

```python
days = [1, 2, 3, 4, 5]
sleeping = [7, 8, 6, 11, 7]
eating = [2, 3, 4, 3, 2]
working = [7, 8, 7, 2, 2]
playing = [8, 5, 7, 8, 13]

plt.plot([], [], color='m', label='Sleeping', linewidth=2)
plt.plot([], [], color='c', label='Eating', linewidth=2)
plt.plot([], [], color='r', label='Working', linewidth=2)
plt.plot([], [], color='k', label='Playing', linewidth=2)

plt.stackplot(days, sleeping, eating, working, playing, colors=['m',
                                                                'c', 'r', 'k'])
plt.xlabel('x')
plt.ylabel('y')
plt.title('Matplotlib demo\nCheck it out')
plt.legend()
plt.show()
```

![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/stacked1.png?raw=true)

### 饼图

```python
slices = [7, 2, 5, 11]
activities = ['sleeping', 'eating', 'working', 'playing']
cols = ['c', 'm', 'r', 'b']
# slices是切片比例，startangle是起始角度，explode可以拿出不是0的切片
plt.pie(slices,
        labels=activities,
        colors=cols,
        startangle=90,
        shadow=True,
        explode=(0, 0.1, 0, 0),
        autopct='%1.1f%%')
plt.title('Matplotlib demo\nCheck it out')
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/pie1.png?raw=true)

### 文件中加载数据

```python
"""
test1.txt 内容格式如下
0   0
1  1
2  12
3  11
4  15
5  18
6  9
7  5
8  2
9  16
...
"""
data = np.loadtxt('../data/test1.txt', unpack=True)
plt.plot(data[0], data[1], label='Loaded from local file')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Matplotlib demo\nCheck it out')
plt.legend()
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/loaddata1.png?raw=true)

### 样式

```python
style.use('fivethirtyeight')
fig = plt.figure()
ax1 = fig.add_subplot(221)
ax2 = fig.add_subplot(222)
ax3 = fig.add_subplot(212)
data = np.loadtxt('../data/test1.txt', unpack=True)
ax1.plot(data[0], data[1])
ax2.plot(data[0], data[1])
ax3.plot(data[0], data[1])
plt.xlabel('x')
plt.ylabel('y')
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/style1.png?raw=true)

### 子图

```python
style.use('ggplot')
# 创建子图，1*1网格，起点（0，0）
fig = plt.figure()
ax1 = plt.subplot2grid((1, 1), (0, 0))
ax1.xaxis.label.set_color('c')
ax1.yaxis.label.set_color('r')
# 数轴距离
ax1.set_yticks([0, 1.5, 2.5, 3.5])
data = np.array([[1, 2], [3, 4]])
# 填充
ax1.fill_between([0, 1], 0, [0, 1])
# 改边框
ax1.spines['left'].set_color('c')
ax1.spines['left'].set_linewidth(5)
ax1.spines['right'].set_visible(False)
ax1.spines['top'].set_visible(False)
ax1.tick_params(axis='x', colors='#f06215')
plt.plot(data)
plt.xlabel('Plot Number')
plt.ylabel('Important var')
plt.title('Matplotlib demo\nCheck it out')
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/sub1.png?raw=true)

### 3D图

```python
style.use('ggplot')
fig = plt.figure()
ax1 = fig.add_subplot(111, projection='3d')
x = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
y = [5, 6, 7, 8, 2, 5, 6, 3, 7, 2]
z = [1, 2, 6, 3, 2, 7, 3, 3, 7, 2]
x2 = [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10]
y2 = [-5, -6, -7, -8, -2, -5, -6, -3, -7, -2]
z2 = [1, 2, 6, 3, 2, 7, 3, 3, 7, 2]
ax1.scatter(x, y, z, c='g', marker='o')
ax1.scatter(x2, y2, z2, c='r', marker='o')
ax1.set_xlabel('x axis')
ax1.set_ylabel('y axis')
ax1.set_zlabel('z axis')
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/3d1.png?raw=true)

```python
style.use('fivethirtyeight')
fig = plt.figure()
ax1 = fig.add_subplot(111, projection='3d')
x = np.array([[1, 2, 3], [5, 6, 7]])
y = np.array([[5, 6, 7], [5, 2, 4]])
z = np.array([[1, 2, 6], [1, 2, 9]])
ax1.plot_wireframe(x, y, z)
ax1.set_xlabel('x axis')
ax1.set_ylabel('y axis')
ax1.set_zlabel('z axis')
plt.show()
```

### ![结果图](https://github.com/freshchen/fresh-blog/blob/master/source/images/3d2.png?raw=true)

### 动态图

```python
style.use('fivethirtyeight')
fig = plt.figure()
ax1 = fig.add_subplot(1, 1, 1)


def animal1(i):
    data = np.loadtxt('../data/animal.txt', unpack=True)
    ax1.clear()
    ax1.plot(data[0], data[1])


ani = animation.FuncAnimation(fig, animal1, interval=1000)
plt.show()
```

动态向文件中写入数据可以监控显示数据变化