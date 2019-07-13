---
title: JDK8笔记
date: 2019-02-02 15:49:32
categories: java
top: 24
---

### 1java.util

#### 1.1Observable（观察者模式Subject）

类：当存在多对一的依赖关系的时候，我们会用到观察者模式，其中Subject用于注册，移除，发生改变时通知Observer，Observer收到通知之后进行update.Observer储存在Vector容器中。

| 方法                        | 描述                                                         |
| --------------------------- | ------------------------------------------------------------ |
| addObserver(Observer o)     | 同步方法，用于注册监听者                                     |
| deleteObserver(Observer o)  | 同步方法，用于删除监听者                                     |
| notifyObservers()           | 用于通知监听者有数据跟新，监听者自己来取数据，方法内调用notifyObservers(null) |
| notifyObservers(Object arg) | 用于通知监听者有数据跟新，并且把新的数据传递过去，同步changed状态，遍历所有观察者，调用他们的update方法 |
| deleteObservers()           | 删除所有的监听者                                             |
| setChanged()                | 设置标志位changed为true，在notifyObservers前要手动调用setChanged一次 |
| clearChanged()              | 设置标志位changed为false，notifyObservers中在复制完Vector到Object[]后会执行clearChanged，然后开始通知update |

#### 1.2Observer（观察者模式的观察者）

接口：定义了update(Observable o, Object arg)方法，当调用Observable的notifyObservers时，会触发update。观察者需要实现这个接口，重新uodate方法实现特定功能。

### 2.java.lang

#### 2.1Process

抽象类：可以由`ProcessBuilder.start()`（推荐使用）或者`Runtime.getRuntime().exec()`这两种方法创建一个封装的控制操作系统的子进程,提供了进程的输入输出，等待进程完成，检查进程状态，和杀死进程的功能。主要用来执行一些cmd命令，或者脚本。子进程中的输入输出不能保证安全不堵塞，所以输入输出都是交给父进程的。如果子进程已经没有任何引用了，也不会被立刻杀掉，而是继续异步执行着。

| 方法                                 | 描述                                                       |
| ------------------------------------ | ---------------------------------------------------------- |
| getOutputStream()                    | 获取的输出流与子进程的输入流相连接                         |
| getInputStream()                     | 获取输入流与子进程的输出流相连                             |
| getErrorStream()                     | 获取输入流与子进程的错误输出流相连                         |
| waitFor()                            | 调用的主进程等待子进程返回结果                             |
| waitFor(long timeout, TimeUnit unit) | 加入了等待的超时时间，通过unit控制时间                     |
| exitValue()                          | 返回子进程的退出值                                         |
| destroy()                            | kill子进程                                                 |
| destroyForcibly()                    | 对destroy的优化，功能相同，调用isAlive()判断状态。（推荐） |
| isAlive()                            | 检查子进程是否存活                                         |

#### 2.2Throwable

类：是所有父类和异常的父类，实现了序列化