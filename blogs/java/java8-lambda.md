# Java8新特性之Lambda

## Lambda是什么

Java8应该是目前最大的一次更新了，更新后我们迎来了很多新特性，其中便包括Lambda表达式，可以让我们进行函数式编程，看过一些经典案例之后，平时也开始大量用Lambda表达式，毕竟是真的短真的易读，语法糖真的香！

### 例1 按照两个人的年龄排序的功能

过去的写法：

```java
# 已经创建好了三个Person实例
List<Person> people = Arrays.asList(person1, person2, person3);

Collections.sort(people, new Comparator<Person>() {
    @Override
    public int compare(Person o1, Person o2) {
        return o1.getAge().compareTo(o2.getAge());
    }
});
```

Lambda版本写法：

```java
Collections.sort(people, (p1, p2) -> p1.getAge().compareTo(p2.getAge()));
```

还有更简介的方法引用写法：

```java
Collections.sort(people, Comparator.comparing(Person::getAge));
```

9102年了，函数式编程被提到的越来越多，深谙照猫画虎已经行不通了，现在函数式编程和设计模式的碰撞也很多，真的有必要了解下相关概念

### 函数式编程解决什么问题

函数式编程主要引入了**行为参数化**，我们可以把一段代码和值一样传递给方法，传入不同的代码实现不同的功能。这是不是很像策略模式以及模板模式？



public static List<Apple> filterHeavyApples(List<Apple> inventory){
List<Apple> result = new ArrayList<>();
for (Apple apple: inventory){
if (apple.getWeight() > 150) {
result.add(apple);
}
}
return result;
}



什么是谓词？
前面的代码传递了方法Apple::isGreenApple （ 它接受参数Apple 并返回一个
boolean）给filterApples，后者则希望接受一个Predicate<Apple>参数。谓词（predicate）
在数学上常常用来代表一个类似函数的东西，它接受一个参数值，并返回true或false。你
在后面会看到，Java 8也会允许你写Function<Apple,Boolean>——在学校学过函数却没学
过谓词的读者对此可能更熟悉，但用Predicate<Apple>是更标准的方式，效率也会更高一
点儿，这避免了把boolean封装在Boolean里面。



用的次数不多的可以用Lambda



但要是Lambda的长度多于几行（它的行为也不是一目了然）的话，
那你还是应该用方法引用来指向一个有描述性名称的方法，而不是使用匿名的Lambda。你应该
以代码的清晰度为准绳。



行为参数化，就是一个方法接受多个不同的行为作为参数，并在内部使用它们，完成不
同行为的能力。
 行为参数化可让代码更好地适应不断变化的要求，减轻未来的工作量。
 传递代码，就是将新行为作为参数传递给方法。但在Java 8之前这实现起来很啰嗦。为接
口声明许多只用一次的实体类而造成的啰嗦代码，在Java 8之前可以用匿名类来减少。
 Java API包含很多可以用不同行为进行参数化的方法，包括排序、线程和GUI处理。





可以把Lambda表达式理解为简洁地表示可传递的匿名函数的一种方式：它没有名称，但它
有参数列表、函数主体、返回类型，可能还有一个可以抛出的异常列表。



Lambda
的基本语法是
(parameters) -> expression
或（请注意语句的花括号）
(parameters) -> { statements; }





一言以蔽之，函数式接口就是只定义一个抽象方法的接口。你已经知道了Java API中的一些
其他函数式接口，如我们在第2章中谈到的Comparator和Runnable。



你将会在第9章中看到，接口现在还可以拥有默认方法（即在类没有对方法进行实现时，
其主体为方法提供默认实现的方法）。哪怕有很多默认方法，只要接口只定义了一个抽象
方法，它就仍然是一个函数式接口。



函数式接口的抽象方法的签名基本上就是Lambda表达式的签名。我们将这种抽象方法叫作
函数描述符。例如，Runnable接口可以看作一个什么也不接受什么也不返回（void）的函数的
签名，因为它只有一个叫作run的抽象方法，这个方法什么也不接受，什么也不返回（void）。①
我们在本章中使用了一个特殊表示法来描述Lambda和函数式接口的签名。() -> void代表
了参数列表为空，且返回void的函数。这正是Runnable接口所代表的。 举另一个例子，(Apple,
Apple) -> int代表接受两个Apple作为参数且返回int的函数。我们会在3.4节和本章后面的
表3-2中提供关于函数描述符的更多信息。



测验3.3：在哪里可以使用Lambda？
以下哪些是使用Lambda表达式的有效方式？
(1) execute(() -> {});
public void execute(Runnable r){
r.run();
}
(2) public Callable<String> fetch() {
return () -> "Tricky example ;-)";
}
(3) Predicate<Apple> p = (Apple a) -> a.getWeight();
答案：只有1和2是有效的。
第一个例子有效，是因为Lambda() -> {}具有签名() -> void，这和Runnable中的
抽象方法run的签名相匹配。请注意，此代码运行后什么都不会做，因为Lambda是空的！
第二个例子也是有效的。事实上，fetch方法的返回类型是Callable<String>。
Callable<String>基本上就定义了一个方法，签名是() -> String，其中T被String代替
了。因为Lambda() -> "Trickyexample;-)"的签名是() -> String，所以在这个上下文
中可以使用Lambda。
第三个例子无效，因为Lambda表达式(Apple a) -> a.getWeight()的签名是(Apple) ->
Integer，这和Predicate<Apple>:(Apple) -> boolean中定义的test方法的签名不同。





：“为什么只有在需要函数式接口的时候才可以传递Lambda呢？”



@FunctionalInterface又是怎么回事？
如果你去看看新的Java API，会发现函数式接口带有@FunctionalInterface的标注（3.4
节中会深入研究函数式接口，并会给出一个长长的列表）。这个标注用于表示该接口会设计成
一个函数式接口。如果你用@FunctionalInterface定义了一个接口，而它却不是函数式接
口的话，编译器将返回一个提示原因的错误。例如，错误消息可能是“Multiple non-overriding
abstract methods found in interface Foo”，表明存在多个抽象方法。请注意，@FunctionalInterface
不是必需的，但对于为此设计的接口而言，使用它是比较好的做法。它就像是@Override
标注表示方法被重写了。





就像你在3.2.1节中学到的，函数式接口定义且只定义了一个抽象方法。函数式接口很有用，
因为抽象方法的签名可以描述Lambda表达式的签名。函数式接口的抽象方法的签名称为函数描
述符。所以为了应用不同的Lambda表达式，你需要一套能够描述常见函数描述符的函数式接口。Java 8的库设计师帮你在java.util.function包中引入了几个新的函数式接口。



java.util.function.Predicate<T>接口定义了一个名叫test的抽象方法，它接受泛型
T对象，并返回一个boolean。这恰恰和你先前创建的一样，现在就可以直接使用了。在你需要
表示一个涉及类型T的布尔表达式时，就可以使用这个接口





java.util.function.Consumer<T>定义了一个名叫accept的抽象方法，它接受泛型T
的对象，没有返回（void）。你如果需要访问类型T的对象，并对其执行某些操作，就可以使用
这个接口。比如，你可以用它来创建一个forEach方法，接受一个Integers的列表，并对其中
每个元素执行操作。



java.util.function.Function<T, R>接口定义了一个叫作apply的方法，它接受一个
泛型T的对象，并返回一个泛型R的对象。如果你需要定义一个Lambda，将输入对象的信息映射
到输出，就可以使用这个接口（比如提取苹果的重量，或把字符串映射为它的长度）。在下面的
代码中，我们向你展示如何利用它来创建一个map方法，以将一个String列表映射到包含每个
String长度的Integer列表。



Java还有一个自动装箱机制来帮助程序员执行这一任务：装
箱和拆箱操作是自动完成的。比如，这就是为什么下面的代码是有效的（一个int被装箱成为
Integer）：
List<Integer> list = new ArrayList<>();
for (int i = 300; i < 400; i++){
list.add(i);
}
但这在性能方面是要付出代价的。装箱后的值本质上就是把原始类型包裹起来，并保存在堆
里。因此，装箱后的值需要更多的内存，并需要额外的内存搜索来获取被包裹的原始值。





Java 8为我们前面所说的函数式接口带来了一个专门的版本，以便在输入和输出都是原始类
型时避免自动装箱的操作。比如，在下面的代码中，使用IntPredicate就避免了对值1000进行
装箱操作，但要是用Predicate<Integer>就会把参数1000装箱到一个Integer对象中：
public interface IntPredicate{
boolean test(int t);
}
IntPredicate evenNumbers = (int i) -> i % 2 == 0;
evenNumbers.test(1000);
Predicate<Integer> oddNumbers = (Integer i) -> i % 2 == 1;
oddNumbers.test(1000);
一般来说，针对专门的输入参数类型的函数式接口的名称都要加上对应的原始类型前缀，比
如DoublePredicate、IntConsumer、LongBinaryOperator、IntFunction等。Function
接口还有针对输出参数类型的变种：ToIntFunction<T>、IntToDoubleFunction等



请注意，任何函数式接口都不允许抛出受检异常（checked exception）。如果你需要Lambda
表达式来抛出异常，有两种办法：定义一个自己的函数式接口，并声明受检异常，或者把Lambda
包在一个try/catch块中。





当我们第一次提到Lambda表达式时，说它可以为函数式接口生成一个实例。然而，Lambda
表达式本身并不包含它在实现哪个函数式接口的信息。为了全面了解Lambda表达式，你应该知
道Lambda的实际类型是什么





特殊的void兼容规则
如果一个Lambda的主体是一个语句表达式， 它就和一个返回void的函数描述符兼容（当
然需要参数列表也兼容）。例如，以下两行都是合法的，尽管List的add方法返回了一个
boolean，而不是Consumer上下文（T -> void）所要求的void：

// Predicate返回了一个boolean
Predicate<String> p = s -> list.add(s);
// Consumer返回了一个void
Consumer<String> b = s -> list.add(s);





尽管如此，还有一点点小麻烦：关于能对这些变量做什么有一些限制。Lambda可以没有限
制地捕获（也就是在其主体中引用）实例变量和静态变量。但局部变量必须显式声明为final，
或事实上是final。换句话说，Lambda表达式只能捕获指派给它们的局部变量一次。（注：捕获
实例变量可以被看作捕获最终局部变量this。）



对局部变量的限制
你可能会问自己，为什么局部变量有这些限制。第一，实例变量和局部变量背后的实现有一
个关键不同。实例变量都存储在堆中，而局部变量则保存在栈上。如果Lambda可以直接访问局
部变量，而且Lambda是在一个线程中使用的，则使用Lambda的线程，可能会在分配该变量的线
程将这个变量收回之后，去访问该变量。因此，Java在访问自由局部变量时，实际上是在访问它
的副本，而不是访问原始变量。如果局部变量仅仅赋值一次那就没有什么区别了——因此就有了
这个限制。



闭包
你可能已经听说过闭包（closure，不要和Clojure编程语言混淆）这个词，你可能会想
Lambda是否满足闭包的定义。用科学的说法来说，闭包就是一个函数的实例，且它可以无限
制地访问那个函数的非本地变量。例如，闭包可以作为参数传递给另一个函数。它也可以访
问和修改其作用域之外的变量。现在，Java 8的Lambda和匿名类可以做类似于闭包的事情：
它们可以作为参数传递给方法，并且可以访问其作用域之外的变量。但有一个限制：它们不
能修改定义Lambda的方法的局部变量的内容。这些变量必须是隐式最终的。可以认为Lambda
是对值封闭，而不是对变量封闭。如前所述，这种限制存在的原因在于局部变量保存在栈上，
并且隐式表示它们仅限于其所在线程。如果允许捕获可改变的局部变量，就会引发造成线程
不安全的新的可能性，而这是我们不想看到的（实例变量可以，因为它们保存在堆中，而堆
是在线程之间共享的）。



方法引用让你可以重复使用现有的方法定义，并像Lambda一样传递它们。在一些情况下，
比起使用Lambda表达式，它们似乎更易读，感觉也更自然。



你可以把方法引用看作针对仅仅涉及单一方法的Lambda的语法糖，因为你表达同样的事情
时要写的代码更少了。





如何构建方法引用
方法引用主要有三类。
(1) 指向静态方法的方法引用（例如Integer的parseInt方法，写作Integer::parseInt）。
你的第一个
方法引用！
54 第3 章 Lambda 表达式
(2) 指向任意类型实例方法的方法引用（ 例如String 的length 方法， 写作
String::length）。
(3) 指向现有对象的实例方法的方法引用（假设你有一个局部变量expensiveTransaction
用于存放Transaction类型的对象，它支持实例方法getValue，那么你就可以写expensive-
Transaction::getValue）



编译器会进行一种与Lambda表达式类似的类型检查过程，来确定对于给定的函数
式接口，这个方法引用是否有效：方法引用的签名必须和上下文类型匹配



Supplier<Apple> c1 = Apple::new;
Apple a1 = c1.get();
这就等价于：
Supplier<Apple> c1 = () -> new Apple();
Apple a1 = c1.get();
如果你的构造函数的签名是Apple(Integer weight)，那么它就适合Function接口的签
名，于是你可以这样写：
Function<Integer, Apple> c2 = Apple::new;
Apple a2 = c2.apply(110);
这就等价于：
Function<Integer, Apple> c2 = (weight) -> new Apple(weight);
Apple a2 = c2.apply(110);



测验3.7：构造函数引用
你已经看到了如何将有零个、一个、两个参数的构造函数转变为构造函数引用。那要怎么
样才能对具有三个参数的构造函数，比如Color(int, int, int)，使用构造函数引用呢？
答案：你看，构造函数引用的语法是ClassName::new，那么在这个例子里面就是
Color::new。但是你需要与构造函数引用的签名匹配的函数式接口。但是语言本身并没有提
供这样的函数式接口，你可以自己创建一个：
public interface TriFunction<T, U, V, R>{
R apply(T t, U u, V v);
}
现在你可以像下面这样使用构造函数引用了：
TriFunction<Integer, Integer, Integer, Color> colorFactory = Color::new;







Comparator<Apple> c = Comparator.comparing(Apple::getWeight);
1. 逆序
如果你想要对苹果按重量递减排序怎么办？用不着去建立另一个Comparator的实例。接口
有一个默认方法reversed可以使给定的比较器逆序。因此仍然用开始的那个比较器，只要修改
一下前一个例子就可以对苹果按重量递减排序：
inventory.sort(comparing(Apple::getWeight).reversed());
2. 比较器链
上面说得都很好，但如果发现有两个苹果一样重怎么办？哪个苹果应该排在前面呢？你可能
需要再提供一个Comparator来进一步定义这个比较。比如，在按重量比较两个苹果之后，你可
能想要按原产国排序。thenComparing方法就是做这个用的。它接受一个函数作为参数（就像
comparing方法一样），如果两个对象用第一个Comparator比较之后是一样的，就提供第二个
Comparator。你又可以优雅地解决这个问题了：
inventory.sort(comparing(Apple::getWeight)
.reversed()
.thenComparing(Apple::getCountry));







谓词接口包括三个方法：negate、and和or，让你可以重用已有的Predicate来创建更复
杂的谓词。比如，你可以使用negate方法来返回一个Predicate的非，比如苹果不是红的：
Predicate<Apple> notRedApple = redApple.negate();
你可能想要把两个Lambda用and方法组合起来，比如一个苹果既是红色又比较重：
Predicate<Apple> redAndHeavyApple =
redApple.and(a -> a.getWeight() > 150);
你可以进一步组合谓词，表达要么是重（150克以上）的红苹果，要么是绿苹果：
Predicate<Apple> redAndHeavyAppleOrGreen =
redApple.and(a -> a.getWeight() > 150)
.or(a -> "green".equals(a.getColor()));
这一点为什么很好呢？从简单Lambda表达式出发，你可以构建更复杂的表达式，但读起来
仍然和问题的陈述差不多！请注意，and和or方法是按照在表达式链中的位置，从左向右确定优
先级的。因此，a.or(b).and(c)可以看作(a || b) && c。





函数复合
最后，你还可以把Function接口所代表的Lambda表达式复合起来。Function接口为此配
了andThen和compose两个默认方法，它们都会返回Function的一个实例。
andThen方法会返回一个函数，它先对输入应用一个给定函数，再对输出应用另一个函数。
比如，假设有一个函数f给数字加1 (x -> x + 1)，另一个函数g给数字乘2，你可以将它们组
合成一个函数h，先给数字加1，再给结果乘2：
Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
Function<Integer, Integer> h = f.andThen(g);
int result = h.apply(1);
你也可以类似地使用compose方法，先把给定的函数用作compose的参数里面给的那个函
数，然后再把函数本身用于结果。比如在上一个例子里用compose的话，它将意味着f(g(x))，
而andThen则意味着g(f(x))：
Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
Function<Integer, Integer> h = f.compose(g);
int result = h.apply(1);





以下是你应从本章中学到的关键概念。
 Lambda表达式可以理解为一种匿名函数：它没有名称，但有参数列表、函数主体、返回
类型，可能还有一个可以抛出的异常的列表。
 Lambda表达式让你可以简洁地传递代码。
 函数式接口就是仅仅声明了一个抽象方法的接口。
 只有在接受函数式接口的地方才可以使用Lambda表达式。
 Lambda表达式允许你直接内联，为函数式接口的抽象方法提供实现，并且将整个表达式
作为函数式接口的一个实例。
 Java 8自带一些常用的函数式接口，放在java.util.function包里，包括Predicate
<T>、Function<T,R>、Supplier<T>、Consumer<T>和BinaryOperator<T>，如表
3-2所述。
 为了避免装箱操作，对Predicate<T>和Function<T, R>等通用函数式接口的原始类型
特化：IntPredicate、IntToLongFunction等。

环绕执行模式（即在方法所必需的代码中间，你需要执行点儿什么操作，比如资源分配
和清理）可以配合Lambda提高灵活性和可重用性。
 Lambda表达式所需要代表的类型称为目标类型。
 方法引用让你重复使用现有的方法实现并直接传递它们。
 Comparator、Predicate和Function等函数式接口都有几个可以用来结合Lambda表达
式的默认方法。