# K近邻算法实现

### 1 K近邻简介

k近邻法(基本分类或回归法)，根据训练数据输入的对应输出，将数据进行分类。输入新的向量X时，找出已有数据的k个最靠近X的点，判断这些点中最多的类型为T，则新输入预测的对应类型为T。求最近距离时一般会用到kd树，优化检索。kd树的创建和检索过程请查看相关资料。

### 2算法

```python
import numpy as np
import matplotlib.pyplot as plt
import operator
from tools.time_name import init_file_name


# 处理输入格式问题，从文件中读取数据
def loadData(filename):
    """
        加载数据
        eg:
        1   1   1
        1   2   1
        1   3   1
        1   4   1
        2   4   2
        4   2   1
        3   7   1
        3   2   2
        1   6   1
        3   6   1
        3   3.5 2
        3   3.6 2
        3   3.7 2
        2.5 5   3
        2.5 7   3
    """
    data = np.loadtxt(filename)
    dataMat = data[:, 0:2]
    labelMat = data[:, 2]
    return dataMat, labelMat


# 根据输入测试实例进行k-近邻分类
def classify(in_x, data_set, labels, k):
    data_set_size = data_set.shape[0]
    diff_mat = np.tile(in_x, (data_set_size, 1)) - data_set
    sq_diff_mat = diff_mat ** 2
    sq_distances = sq_diff_mat.sum(axis=1)
    distances = sq_distances ** 0.5
    sorted_dist_indicies = distances.argsort()
    class_count = {}
    for i in range(k):
        vote_ilabel = labels[sorted_dist_indicies[i]]
        class_count[vote_ilabel] = class_count.get(vote_ilabel, 0) + 1
    sorted_class_count = sorted(class_count.items(), key=operator.itemgetter(1), reverse=True)
    return sorted_class_count[0][0]


def plotResult(dataMat, labelMat, in_x, y):
    fig = plt.figure()
    axes = fig.add_subplot(111)

    type1_x = []
    type1_y = []
    type2_x = []
    type2_y = []
    type3_x = []
    type3_y = []
    for i in range(len(labelMat)):
        if (labelMat[i] == 1):
            type1_x.append(dataMat[i][0])
            type1_y.append(dataMat[i][1])

        if (labelMat[i] == 2):
            type2_x.append(dataMat[i][0])
            type2_y.append(dataMat[i][1])

        if (labelMat[i] == 3):
            type3_x.append(dataMat[i][0])
            type3_y.append(dataMat[i][1])

    type1 = axes.scatter(type1_x, type1_y, marker='o', s=20, c='black')
    type2 = axes.scatter(type2_x, type2_y, marker='o', s=20, c='green')
    type1 = axes.scatter(type3_x, type3_y, marker='o', s=20, c='yellow')
    type4 = axes.scatter(in_x[0], in_x[1], marker='x', s=30, c='red')

    plt.xlabel('X')
    plt.ylabel('Y')

    if y == 'y':
        plt.savefig(init_file_name('knn', 'png'))
    plt.show()


def _init_(x, k, y):
    dataMat, labelMat = loadData('testSet.txt')
    in_x = x
    plotResult(dataMat, labelMat, in_x, y)
    result = int(classify(in_x, dataMat, labelMat, k))
    return result
```

### 3测试结果

```python
import statisticallearning.KNN.knn as knn
import numpy as np

old_x = [3, 5]
k = 3
x = np.array([3, 5])
y = 'y'
print('训练数据：[%s,%s] k值：%s 结果：%s' % (old_x[0], old_x[1], k, knn._init_(x, k, y)))
```

简单的测试结果如下：

训练数据：[3,5] k值：1 结果：3

训练数据：[3,5] k值：5 结果：2

训练数据：[3,5] k值：15 结果：1

![](../images/post/KNN.png?raw=true)