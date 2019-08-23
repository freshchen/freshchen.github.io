# Java开发面试记录

## [Guide](<https://snailclimb.top/JavaGuide/#/./system-design/framework/Spring%E5%AD%A6%E4%B9%A0%E4%B8%8E%E9%9D%A2%E8%AF%95>)

### 蚂蚁金服

#### 面试简介

简历投递渠道是招聘网站，没有找内推。当天收到了邮件说十天内进行第一轮电话面试，职位是蚂蚁金服-资深应用开发工程师-资损防控领域（工程/算法）。

#### 电话面试

收到面试邮件的第二天晚上电话来了，怎么这么快，而且是晚上10点！我的天！！！由于去年刚毕业，现在在一家外企工作，主要工作内容是云计算平台搭建，好多java知识都淡忘了，这电话来的太突然了。不过还是硬着头皮开始了面试。

#### 自我介绍

简单介绍自己，说说现在做的项目

#### java基础

只记得六个问题了

问题1：主要使用过哪些java web框架，追问提到框架能说说如果自己设计一个MVC框架，注重考虑哪些方面。

问题2：说说你对dubbo的理解，dubbo的工作原理。

问题3：cglib和jdk实现的动态代理的区别。

问题4：BIO和NIO处理客户端来的1000个请求，各需要多少个线程。

问题5：10个线程，如何确保其中一个线程最好执行。

问题6：线程池的优点和缺点，什么时候用线程池。

#### 参考答案

refs：

[动态代理proxy与CGLib的区别](https://blog.csdn.net/hintcnuie/article/details/10954631)

[聊聊BIO，NIO和AIO ](https://www.jianshu.com/p/ef418ccf2f7d)



### 游族网络

#### 面试简介

孤陋寡闻，拿游族练练手的，没想到公司很大，电话面试比较简单，问了问java的基础，hashmap，多线程概念等，很快邀请去参加面试。

#### 现场面试

问题1：怎么部署应用，说这边开发是要负责部署的，让黑板上画一画。凉！不会画画！

问题2：servlet是单例么，springMVC是单例么

问题3：常用的负载均衡算法

#### 参考答案

refs：

[超详细！使用 LVS 实现负载均衡原理及安装配置详解](<https://blog.csdn.net/Ki8Qzvka6Gz4n450m/article/details/79119665>)

[LVS负载均衡（LVS简介、三种工作模式、十种调度算法）](<https://blog.csdn.net/weixin_40470303/article/details/80541639>)



### 商汤科技

#### 面试简介

一家AI独角兽，早有耳闻，算法方面才疏学浅不能去做算法工程师，面个JAVA曲线救国。先是HR电话询问情况，然后约现场面试，上海分公司在黄浦江边，风景优美。面试过程会先做一套题，主要内容有java，linux，docker，redis等，做完面试官问问过去做的项目，然后对着试题情况和简历提问。

#### 现场面试

问题1：java有几种引用，各有什么区别

问题2：常用的docker，linux操作,docker主要依赖什么虚拟化技术，docker能隔离什么不能隔离什么

问题3：spring bean的scope默认是什么，还有几种其他选项。

问题4：二叉树，找出节点值相加等于指定值的所有路径。

问题5：mysql索引使用的数据结构是什么，为什么不用哈希表。

问题6：如何对对象枷锁，如何对类加锁

问题7：tomcat和nagix的主要区别，以及实现的主要思想

问题8：Java servlet 和 servlet容器 和 SpringMVC servlet的区别



#### 参考答案

refs：

[强引用、软引用、弱引用、虚引用的概念](<https://www.cnblogs.com/alias-blog/p/5793108.html>)

[Spring中Bean的五个作用域](https://www.cnblogs.com/goody9807/p/7472127.html)

[docker namespace cgroup network](http://www.cnblogs.com/sammyliu/p/5878973.html)

[java中对象锁与类锁的一些理解与实例](https://www.cnblogs.com/houzheng/p/9084026.html)

[nginx和tomcat的区别](https://www.cnblogs.com/flypie/p/5153702.html)

[Nginx基本概念、模块化思想、工作流程、工作原理](https://www.baidu.com/link?url=WPRot77-1KvO2wqLhjc9qJ62sN0h5dxJIVXDIm6tyvFfjWURqNsVqDjzDEFEMKw-lnem_iUAHWNHhLOeV6wsbE-Z9C9efw16wBRScMK1K8y&wd=&eqid=9004656400116839000000065cadae70)

[Tomcat服务器原理详解](https://www.cnblogs.com/crazylqy/p/4706223.html)

