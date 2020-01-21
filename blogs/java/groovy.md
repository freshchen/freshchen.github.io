# Groovy语法糖以及DSL

## 前言

### Why

初次接触到Groovy是在实习中接触到一个 纯Groovy写的项目，当时看了下这不就是没有分号的Java么，而且也是有年纪的语言了，并不想投入时间学习。后来工作中越来越多的看到Groovy的身影，Gradle，Spring Cloud Contract等等都支持Groovy作为DSL（领域专用语言），同时Groovy在测试领域也有一席之地，因为语法简单，可以很快捷的编写Test Case，总之可以把Groovy看作Java的小伙伴，好帮手。

### What

Groovy是JVM平台上的一种面向对象且同时支持静态动态的脚本语言，语法和Java区别不大，提供了一些语法糖，代码的表达能力更强。默认小伙伴们都已经有了Java基础，本文主要介绍Groovy比Java多出的语法糖，以及使用较多的DSL。

## 语法糖

大致了解一些语法糖可以更舒服的看DSL

- 可以用def关键字定义变量和方法，编译期做类型推断
- 多变量同时创建

```groovy
def (aa, bb) = [1, 2]
```

- 范围创建

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

- 方法参数支持默认值

```groovy
def someMethod(parameter1, parameter2 = 0, parameter3 = 0) { 
   // Method code goes here 
} 
```

- 字符串支持单引号和双引号，类似于shell，python，双引号中可识别变量

- 列表创建

```groovy
List<String> strings = ["g", "r", "o", "o", "v", "y"]
```

- map创建

```groovy
Map<String, String> stringMap = ["name": "wang", "age": "99"]
```

- 正则表达式，～后面直接跟正则语句，可直接用于判断

```groovy
if ( "Groovy" =~ "^G")
```

- trait关键字声明一个可以有属性和默认实现的接口，Java8之后的接口也都能达到同样效果

- 支持闭包，自己Call自己

``` groovy
def closure = { param -> println "Hello ${param}" };
closure.call("World");

10.times {num -> println num} 
```

- 函数科里化贼方便

```groovy
def cl1 = {int a, b, c ->
	a + b + c
}
def cl1Curry1 = cl1.curry(1)
```

- 调用shell方便

```java
println "ls -l".execute().text
```

- instanceof可以简写成in



## DSL

### 链式调用

在不产生歧义的情况下我们可以省略方法调用中的括号，使代码更像说话

```groovy
// equivalent to: turn(left).then(right)
turn left then right

// equivalent to: take(2.pills).of(chloroquinine).after(6.hours)
take 2.pills of chloroquinine after 6.hours

// equivalent to: paint(wall).with(red, green).and(yellow)
paint wall with red, green and yellow

// with named parameters too
// equivalent to: check(that: margarita).tastes(good)
check that: margarita tastes good

// with closures as parameters
// equivalent to: given({}).when({}).then({})
given { } when { } then { }
```

### 运算符重载

| Operator                  | Method                  |
| :------------------------ | :---------------------- |
| `a + b`                   | a.plus(b)               |
| `a - b`                   | a.minus(b)              |
| `a * b`                   | a.multiply(b)           |
| `a ** b`                  | a.power(b)              |
| `a / b`                   | a.div(b)                |
| `a % b`                   | a.mod(b)                |
| `a | b`                   | a.or(b)                 |
| `a & b`                   | a.and(b)                |
| `a ^ b`                   | a.xor(b)                |
| `a++` or `++a`            | a.next()                |
| `a--` or `--a`            | a.previous()            |
| `a[b]`                    | a.getAt(b)              |
| `a[b] = c`                | a.putAt(b, c)           |
| `a << b`                  | a.leftShift(b)          |
| `a >> b`                  | a.rightShift(b)         |
| `a >>> b`                 | a.rightShiftUnsigned(b) |
| `switch(a) { case(b) : }` | b.isCase(a)             |
| `if(a)`                   | a.asBoolean()           |
| `~a`                      | a.bitwiseNegate()       |
| `-a`                      | a.negative()            |
| `+a`                      | a.positive()            |
| `a as b`                  | a.asType(b)             |
| `a == b`                  | a.equals(b)             |
| `a != b`                  | ! a.equals(b)           |
| `a <=> b`                 | a.compareTo(b)          |
| `a > b`                   | a.compareTo(b) > 0      |
| `a >= b`                  | a.compareTo(b) >= 0     |
| `a < b`                   | a.compareTo(b) < 0      |
| `a <= b`                  | a.compareTo(b) <= 0     |

### 脚本基类

我们运行的Groovy脚本在编译过程中都自动继承了 [groovy.lang.Script](https://docs.groovy-lang.org/2.5.9/html/gapi/index.html?groovy/lang/Script.html) 这个抽象类，并把脚步内容绑定到run方法中执行。

可以通过创建一个Binding在脚本和基类中创建公用的变量

```groovy
def binding = new Binding()             
def shell = new GroovyShell(binding)    
binding.setVariable('x',1)              
binding.setVariable('y',3)
shell.evaluate 'z=2*x+y'                
assert binding.getVariable('z') == 5   
```

可以自定义基类

```groovy
class BaseScript extends Script{

    String name
    public void greet() { println "Hello, $name!" }

    @Override
    Object run() {
        greet()
    }
}
```

```groovy
@BaseScript demo.BaseScript baseScript

setName "100"
greet()
```

### @DelegatesTo

是一个文档与编译时注释，当我们使用了委托模式去执行闭包时，文档生成，IDE以及类型推断都无法准确知道闭包具体被委托到哪里执行，我们就需要使用此注解显示声明。

当我们要实现如下效果时，我们需要定义一个email方法接受一个闭包，然后通过构建模式创建一个EmailSpec，去初始化并且委托执行闭包

```groovy
email {
    from 'dsl-guru@mycompany.com'
    to 'john.doe@waitaminute.com'
    subject 'The pope has resigned!'
    body {
        p 'Really, the pope has resigned!'
    }
}
```

```groovy
def email(@DelegatesTo(strategy=Closure.DELEGATE_ONLY, value=EmailSpec) Closure cl) {
    // ...
}
```

当我们要委托给方法的另一个参数时可以

```groovy
def exec(@DelegatesTo.Target Object target, @DelegatesTo Closure code) {
  // rehydrate方法创建一个闭包副本
   def clone = code.rehydrate(target, this, this)
   clone()
}
```

### 自定义编译器

增加默认导入，并且支持别名

```groovy
import org.codehaus.groovy.control.customizers.ImportCustomizer

def icz = new ImportCustomizer()
// "normal" import
icz.addImports('java.util.concurrent.atomic.AtomicInteger', 'java.util.concurrent.ConcurrentHashMap')
// "aliases" import
icz.addImport('CHM', 'java.util.concurrent.ConcurrentHashMap')
// "static" import
icz.addStaticImport('java.lang.Math', 'PI') // import static java.lang.Math.PI
// "aliased static" import
icz.addStaticImport('pi', 'java.lang.Math', 'PI') // import static java.lang.Math.PI as pi
// "star" import
icz.addStarImports 'java.util.concurrent' // import java.util.concurrent.*
// "static star" import
icz.addStaticStars 'java.lang.Math' // import static java.lang.Math.*
```

可用于限制AST的级别，比如使用者不能用闭包，不允许导入其他包等等

### 构建

Groovy内置了很多好用的构建器，具体使用查看官方教程

[官方教程](http://docs.groovy-lang.org/docs/latest/html/documentation/core-domain-specific-languages.html)