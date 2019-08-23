# Python可视化高级库seaborn

图片乱了，仅用作记录

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="darkgrid")
```

```python
# 加载数据集
tips = sns.load_dataset("tips")
# 首先看一下数据集的情况
pd.DataFrame(tips).head()
```
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>total_bill</th>
      <th>tip</th>
      <th>sex</th>
      <th>smoker</th>
      <th>day</th>
      <th>time</th>
      <th>size</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>16.99</td>
      <td>1.01</td>
      <td>Female</td>
      <td>No</td>
      <td>Sun</td>
      <td>Dinner</td>
      <td>2</td>
    </tr>
    <tr>
      <th>1</th>
      <td>10.34</td>
      <td>1.66</td>
      <td>Male</td>
      <td>No</td>
      <td>Sun</td>
      <td>Dinner</td>
      <td>3</td>
    </tr>
    <tr>
      <th>2</th>
      <td>21.01</td>
      <td>3.50</td>
      <td>Male</td>
      <td>No</td>
      <td>Sun</td>
      <td>Dinner</td>
      <td>3</td>
    </tr>
    <tr>
      <th>3</th>
      <td>23.68</td>
      <td>3.31</td>
      <td>Male</td>
      <td>No</td>
      <td>Sun</td>
      <td>Dinner</td>
      <td>2</td>
    </tr>
    <tr>
      <th>4</th>
      <td>24.59</td>
      <td>3.61</td>
      <td>Female</td>
      <td>No</td>
      <td>Sun</td>
      <td>Dinner</td>
      <td>4</td>
    </tr>
  </tbody>
</table>



relplot可用于绘制散点图和直线图，默认绘制散点图

```python
sns.relplot(x="total_bill", y="tip", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_4_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="smoker", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_5_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", style="smoker", data=tips)
```

![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_6_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="smoker", style="smoker", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_7_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="smoker", style="time", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_8_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="size", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_9_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="size", palette="ch:r=-.5,l=.75", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_10_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", size="size", data=tips)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_11_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", size="size", sizes=(15, 200), data=tips);
```

![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_12_0.png)

直线图

```python
df = pd.DataFrame(np.random.randn(500, 2).cumsum(axis=0), columns=["x", "y"])
sns.relplot(x="x", y="y", kind="line", data=df)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_14_1.png?raw=true)



```python
sns.relplot(x="x", y="y", sort=False, kind="line", data=df)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_15_1.png?raw=true)



```python
fmri = sns.load_dataset("fmri")
pd.DataFrame(fmri).head()
```

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>subject</th>
      <th>timepoint</th>
      <th>event</th>
      <th>region</th>
      <th>signal</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>s13</td>
      <td>18</td>
      <td>stim</td>
      <td>parietal</td>
      <td>-0.017552</td>
    </tr>
    <tr>
      <th>1</th>
      <td>s5</td>
      <td>14</td>
      <td>stim</td>
      <td>parietal</td>
      <td>-0.080883</td>
    </tr>
    <tr>
      <th>2</th>
      <td>s12</td>
      <td>18</td>
      <td>stim</td>
      <td>parietal</td>
      <td>-0.081033</td>
    </tr>
    <tr>
      <th>3</th>
      <td>s11</td>
      <td>18</td>
      <td>stim</td>
      <td>parietal</td>
      <td>-0.046134</td>
    </tr>
    <tr>
      <th>4</th>
      <td>s10</td>
      <td>18</td>
      <td>stim</td>
      <td>parietal</td>
      <td>-0.037970</td>
    </tr>
  </tbody>
</table>



```python
sns.relplot(x="timepoint", y="signal", kind="line", data=fmri)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_17_2.png)



```python
sns.relplot(x="timepoint", y="signal", ci=None, kind="line", data=fmri)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_18_1.png?raw=true)



```python
sns.relplot(x="timepoint", y="signal", kind="line", ci="sd", data=fmri)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_19_1.png?raw=true)



```python
sns.relplot(x="timepoint", y="signal", estimator=None, kind="line", data=fmri)
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_20_1.png?raw=true)



```python
sns.relplot(x="timepoint", y="signal", hue="event", kind="line", data=fmri)
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_21_2.png)



```python
sns.relplot(x="timepoint", y="signal", hue="region", style="event", kind="line", data=fmri)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_22_2.png)



```python
sns.relplot(x="timepoint", y="signal", hue="region", style="event", dashes=False, markers=True, kind="line", data=fmri)
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_23_2.png)



```python
sns.relplot(x="timepoint", y="signal", hue="event", style="event", kind="line", data=fmri)
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_24_2.png)



```python
sns.relplot(x="timepoint", y="signal", hue="region", units="subject", estimator=None, kind="line", data=fmri.query("event == 'stim'"))
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_25_1.png?raw=true)



```python
sns.relplot(x="total_bill", y="tip", hue="smoker", col="time", data=tips)
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_26_1.png?raw=true)



```python
sns.relplot(x="timepoint", y="signal", hue="subject", col="region", row="event", height=3, kind="line", estimator=None, data=fmri)
```





![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_27_1.png?raw=true)



```python
sns.relplot(x="timepoint", y="signal", hue="event", style="event", col="subject", col_wrap=5, height=3, aspect=.75, linewidth=2.5, kind="line", data=fmri.query("region == 'frontal'"))
```



![png](https://github.com/freshchen/fresh-blog/blob/master/source/images/seaborn/lesson1_28_1.png?raw=true)

