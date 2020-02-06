# Spring Cloud Contract 微服务契约测试框架

## 简介

### 使用场景

主要用于在微服务架构下做CDC（消费者驱动契约）测试，建议只用来做测试，不能做契约，因为安全性没那么高。下图展示了多个微服务的调用，如果我们更改了一个模块要如何进行测试呢？

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/contract-1.png)

- 传统的两种测试思路
  - 模拟生产环境部署所有的微服务，然后进行测试
    - 优点
      - 测试结果可信度高
    - 缺点
      - 测试成本太大，装一整套环境耗时，耗力，耗机器
  - Mock其他微服务做端到端的测试
    - 优点
      - 不用装整套产品了，测的也方便快捷
    - 缺点
      - 需要写很多服务的Mock，要维护一大堆不同版本用途的simulate（模拟器），同样耗时耗力

- Spring Cloud Contrct解决思路
  - 每个服务都生产可被验证的 Stub Runner，通过WireMock调用，服务双方签订契约，一方变化就更新自己的Stub，并且测对方的Stub。Stub只提供了数据，而Mock可在Stub的基础上增加验证

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/contract-2.png)

- 测试流程

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/contrct-3.png)