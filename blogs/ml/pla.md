# 原始感知机PLA算法实现

### 1感知机简介

感知机（二类分类）根据已有的输入和输出（输出只有1或-1），计算得到分离超平面S（wx+b），其中w是S的法向量，b是S的截距。然后通过S对未知的输入给出预测分类结果，并且不断迭代进行调整。

### 2算法

```python
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D


def loadData():
    """
        加载数据
        eg:
        1   1   -1
        0   1   -1
        3   3   1
        4   3   1
        2   0.5 -1
        3   2   1
        4   4   1
        1   2   -1
        3   3   1
        3   4   1
        3   1   -1
        0.5 3   1
        2   2   -1
        3   1.8 -1
        1   3.5 1
        0.5 2.5 -1
    """
    data = np.loadtxt('testSet.txt')
    dataMat = data[:, 0:2]
    labelMat = data[:, 2]
    return dataMat, labelMat


def sign(val):
    if val >= 0:
        return 1
    else:
        return -1


def trainPerceptron(dataMat, labelMat, eta):
    """
        训练模型
        eta: learning rate(可选步)
    """
    m, n = dataMat.shape
    weight = np.zeros(n)
    bias = 0

    flag = True
    while flag:
        for i in range(m):
            if np.any(labelMat[i] * (np.dot(weight, dataMat[i]) + bias) <= 0):
                weight = weight + eta * labelMat[i] * dataMat[i].T
                bias = bias + eta * labelMat[i]
                print("weight, bias: ", end="")
                print(weight, end="  ")
                print(bias)
                flag = True
                break
            else:
                flag = False

    return weight, bias


# 可视化展示分类结果
def plotResult(dataMat, labelMat, weight, bias):
    fig = plt.figure()
    axes = fig.add_subplot(111)

    type1_x = []
    type1_y = []
    type2_x = []
    type2_y = []
    for i in range(len(labelMat)):
        if (labelMat[i] == -1):
            type1_x.append(dataMat[i][0])
            type1_y.append(dataMat[i][1])

        if (labelMat[i] == 1):
            type2_x.append(dataMat[i][0])
            type2_y.append(dataMat[i][1])

    type1 = axes.scatter(type1_x, type1_y, marker='x', s=20, c='red')
    type2 = axes.scatter(type2_x, type2_y, marker='o', s=20, c='blue')

    y = (0.1 * -weight[0] / weight[1] + -bias / weight[1], 4.0 * -weight[0] / weight[1] + -bias / weight[1])
    axes.add_line(Line2D((0.1, 4.0), y, linewidth=1, color='blue'))

    plt.xlabel('X')
    plt.ylabel('Y')

    plt.show()


def _init_():
    dataMat, labelMat = loadData()
    weight, bias = trainPerceptron(dataMat, labelMat, 1)
    plotResult(dataMat, labelMat, weight, bias)
    return weight, bias
```

### 3效果图

![](https://cdn.jsdelivr.net/gh/freshchen/resource@master/img/OldPLA.png)