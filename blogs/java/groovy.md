# Groovy语法糖DSL总结

首先Groovy是JVM平台上的一种脚本语言，Java区别不大，Groovy有很多应用，例如DSL（领域专用语言），Gradle，Spring Cloud Contract等。本文主要总结Groovy在Java基础上多出的语法糖，以及作为DSL的使用

## 语法糖

- 创建范围整数

```groovy
int[] range = 0..10;
```

- 支持for in写法

```groovy
for(variable in range) { 
   statement #1 
   statement #2 
   … 
}
```