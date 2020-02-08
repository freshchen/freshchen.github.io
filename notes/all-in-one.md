# The All-in-One Note

- [基础](#基础)
  - [Linux](#Linux)
  - [操作系统](#操作系统)
  - [网络](#网络)
  - [数据结构与算法](#数据结构与算法)
- [Java](#Java)
  - [核心](#核心)
  - [JVM](#JVM)
- [JavaEE](#JavaEE)
  - [Spring](#Spring)
  - [Netty](#Netty)
- [数据库](#数据库)
  - [Mysql](#Mysql)
- [架构设计](#架构设计)
  - [设计模式](#设计模式)
  - [分布式](#分布式)
  - [缓存](#缓存)









## 软件

- 浏览器
  - chrome
    - Octotree
    - 谷歌翻译
    - One Tab
    - Infinity
    - draw.ioDesktop.Me
  - firefox
- IDE
  - IDEA
    - Lombok
  - PyCharm
  - VS Code
  - GsonFormat
- 工具
  - Xshell
  - Typora
  - Mysql Workbench
  - Fork
  - Wireshark
  - Docker desktop
  - Another redis desktop manager
  - Gilffy Diagrams
  - Logitech Optional
  - 滴答清单



## 基础

### 操作系统

#### I/O 模型

- **阻塞式 I/O 模型(blocking I/O）**
  - 描述：在阻塞式 I/O 模型中，应用程序在从调用 recvfrom 开始到它返回有数据报准备好这段时间是阻塞的，recvfrom 返回成功后，应用进程开始处理数据报
  - 优点：程序简单，在阻塞等待数据期间进程/线程挂起，基本不会占用 CPU 资源
  - 缺点：每个连接需要独立的进程/线程单独处理，当并发请求量大时为了维护程序，内存、线程切换开销较大，这种模型在实际生产中很少使用
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/bio.jpg)
- **非阻塞式 I/O 模型(non-blocking I/O）**
  - 描述：在非阻塞式 I/O 模型中，应用程序把一个套接口设置为非阻塞，就是告诉内核，当所请求的 I/O 操作无法完成时，返回一个错误，应用程序基于 I/O 操作函数将不断的轮询数据是否已经准备好，直到数据准备好为止
  - 优点：不会阻塞在内核的等待数据过程，每次发起的 I/O 请求可以立即返回，不用阻塞等待，实时性较好
  - 缺点：轮询将会不断地询问内核，这将占用大量的 CPU 时间，系统资源利用率较低，所以一般 Web 服务器不使用这种 I/O 模型
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/nio.jpg)
- **I/O 复用模型(I/O multiplexing）**
  - 描述：在 I/O 复用模型中，会用到 Select 或 Poll 函数或 Epoll 函数(Linux 2.6 以后的内核开始支持)，可以同时阻塞多个 I/O 操作，而且可以同时对多个读或者写操作的 I/O 函数进行检测，直到有数据可读或可写时，才真正调用 I/O 操作函数
  - 优点：可以基于一个阻塞对象，同时在多个描述符上等待就绪，而不是使用多个线程(每个文件描述符一个线程)，这样可以大大节省系统资源
  - 缺点：当连接数较少时效率相比多线程+阻塞 I/O 模型效率较低，可能延迟更大，因为单个连接处理需要 2 次系统调用，占用时间会有增加
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/multiplexingio.jpg)
- **信号驱动式 I/O 模型（signal-driven I/O)**
  - 描述：在信号驱动式 I/O 模型中，应用程序使用套接口进行信号驱动 I/O，并安装一个信号处理函数，进程继续运行并不阻塞，当数据准备好时，进程会收到一个 SIGIO 信号，可以在信号处理函数中调用 I/O 操作函数处理数据
  - 优点：线程并没有在等待数据时被阻塞，可以提高资源的利用率
  - 缺点：信号 I/O 在大量 IO 操作时可能会因为信号队列溢出导致没法通知，信号驱动 I/O 尽管对于处理 UDP 套接字来说有用，即这种信号通知意味着到达一个数据报，或者返回一个异步错误。但是，对于 TCP 而言，信号驱动的 I/O 方式近乎无用，因为导致这种通知的条件为数众多，每一个来进行判别会消耗很大资源，与前几种方式相比优势尽失
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/signal-drivenio.jpg)
- **异步 I/O 模型（asynchronous I/O）**
  - 描述：由 POSIX 规范定义，应用程序告知内核启动某个操作，并让内核在整个操作（包括将数据从内核拷贝到应用程序的缓冲区）完成后通知应用程序。这种模型与信号驱动模型的主要区别在于：信号驱动 I/O 是由内核通知应用程序何时启动一个 I/O 操作，而异步 I/O 模型是由内核通知应用程序 I/O 操作何时完成
  - 优点：异步 I/O 能够充分利用 DMA 特性，让 I/O 操作与计算重叠
  - 缺点：要实现真正的异步 I/O，操作系统需要做大量的工作
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/aio.jpg)

**总结**

这五种 I/O 模型中，前四种属于同步 I/O，因为其中真正的 I/O 操作(recvfrom)将阻塞进程/线程，只有异步 I/O 模型才与 POSIX 定义的异步 I/O 相匹配

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/io-model.jpg)

#### I/O处理线程模型

- **传统阻塞 I/O 服务模型**

  - 特点：
    - 采用阻塞式 I/O 模型获取输入数据。
    - 每个连接都需要独立的线程完成数据输入，业务处理，数据返回的完整操作
  - 问题：
    - 当并发数较大时，需要创建大量线程来处理连接，系统资源占用较大。
    - 连接建立后，如果当前线程暂时没有数据可读，则线程就阻塞在 Read 操作上，造成线程资源浪费
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-oio.jpg)

- **Reactor 模式**

  Reactor是非阻塞同步网络模型，通过一个或多个输入同时传递给服务处理器的服务请求的事件驱动处理模式， 基本设计思想就是I/O 复用模型结合线程池，Reactor 模式也叫 Dispatcher 模式

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-reactor-io.jpg)

  - **单 Reactor 单线程**
    - 描述：Reactor 对象通过 Select 监控客户端请求事件，收到事件后通过 Dispatch 进行分发，如果是建立连接请求事件，则由 Acceptor 通过 Accept 处理连接请求，然后创建一个 Handler 对象处理连接完成后的后续业务处理，如果不是建立连接事件，则 Reactor 会分发调用连接对应的 Handler 来响应，Handler 会完成 Read→业务处理→Send 的完整业务流程
    - 优点：模型简单，没有多线程、进程通信、竞争的问题，全部都在一个线程中完成
    - 缺点：性能问题，只有一个线程，无法完全发挥多核 CPU 的性能。Handler 在处理某个连接上的业务时，整个进程无法处理其他连接事件，很容易导致性能瓶颈
    - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-reactor-io-single.jpg)
  - **单 Reactor 多线程**
    - 描述：不同于单 Reactor 单线程的地方是Handler 只负责响应事件，不做具体业务处理，通过 Read 读取数据后，会分发给后面的 Worker 线程池进行业务处理，Worker 线程池会分配独立的线程完成真正的业务处理，Handler 收到响应结果后通过 Send 将响应结果返回给 Client
    - 优点：可以充分利用多核 CPU 的处理能力
    - 缺点：多线程数据共享和访问比较复杂；Reactor 承担所有事件的监听和响应，在单线程中运行，高并发场景下容易成为性能瓶颈
    - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-reactor-io-muti.jpg)
  - **主从 Reactor 多线程**
    - 描述：Reactor 主线程 MainReactor 对象通过 Select 监控建立连接事件，收到建立连接事件后通过 Acceptor 接收，Acceptor 处理建立连接事件后，MainReactor 将连接分配 Reactor 子线程给 SubReactor 进行处理，SubReactor 将连接加入连接队列进行监听，并创建一个 Handler 用于处理各种连接事件，当有新的事件发生时，SubReactor 会调用连接对应的 Handler 进行响应，Handler 处理方式同单 Reactor 多线程
    - 优点：主线程与子线程的数据交互简单职责明确，主线程线程只需要把新连接传给子线程，子线程完成后续的业务处理
    - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-reactor-io-ha.jpg)****

- **Proactor 模型**

  Proactor 模型是异步网络模型 ，把 I/O 操作改为异步，即交给操作系统来完成就能进一步提升性能

  - 描述：AsyOptProcessor 处理注册请求，并处理 I/O 操作，Proactor Initiator 创建 Proactor 和 Handler 对象，并将 Proactor 和 Handler 都通过 AsyOptProcessor（Asynchronous Operation Processor）注册到内核，AsyOptProcessor 完成 I/O 操作后通知 Proactor，Proactor 根据不同的事件类型回调不同的 Handler 进行业务处理，Handler 完成业务处理
  - 优点：效率更高，异步 I/O 更加充分发挥 DMA(Direct Memory Access，直接内存存取)的优势
  - 缺点：编程复杂性难以 Debug，内存使用，缓冲区在读或写操作的时间段内必须保持住，相比 Reactor 模式，在 Socket 已经准备好读或写前，是不要求开辟缓存的
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-proactor-io.jpg)





#### I/O多路复用技术select、poll、epoll之间的区别

- **select**
  - 单个进程所能打开的最大连接数有FD_SETSIZE宏定义，其大小是32个整数的大小（在32位的机器上，大小就是32 * 32，同理64位机器上FD_SETSIZE为32 * 64）
  - 每次调用时都会对连接进行线性遍历，所以随着FD的增加会造成遍历速度慢的“线性下降性能问题”
  - 内核需要将消息传递到用户空间，都需要内核拷贝动作
- **poll**
  - poll本质上和select没有区别，但是它没有最大连接数的限制，原因是它是基于链表来存储的，其他性质同select
- **epoll**
  - 虽然连接数有上限，但是很大，1G内存的机器上可以打开10万左右的连接，2G内存的机器可以打开20万左右的连接
  - 因为epoll内核中实现是根据每个fd上的callback函数来实现的，只有活跃的socket才会主动调用callback，所以在活跃socket较少的情况下，使用epoll没有前面两者的线性下降的性能问题，但是所有socket都很活跃的情况下，可能会有性能问题
  - epoll通过内核和用户空间共享一块内存来实现的消息传递

#### 进程间共享内存的8种方式

- 无名管道( pipe )：管道是一种半双工的通信方式，数据只能单向流动，而且只能在父子进程间使用
- 高级管道(popen)：将另一个程序当做一个新的进程在当前程序进程中启动，则它算是当前程序的子进程
- 有名管道 (named pipe) ： 有名管道也是半双工的通信方式，但是它允许无亲缘关系进程间的通信
- 消息队列( message queue ) ： 消息队列是由消息的链表，存放在内核中并由消息队列标识符标识。消息队列克服了信号传递信息少、管道只能承载无格式字节流以及缓冲区大小受限等缺点
- 信号量( semophore ) ： 信号量是一个计数器，可以用来控制多个进程对共享资源的访问。它常作为一种锁机制，防止某进程正在访问共享资源时，其他进程也访问该资源。因此，主要作为进程间以及同一进程内不同线程之间的同步手段
- 信号 ( sinal ) ： 信号是一种比较复杂的通信方式，用于通知接收进程某个事件已经发生
- 共享内存( shared memory ) ：共享内存就是映射一段能被其他进程所访问的内存，这段共享内存由一个进程创建，但多个进程都可以访问。共享内存是最快的 IPC 方式，它是针对其他进程间通信方式运行效率低而专门设计的。它往往与其他通信机制，如信号两，配合使用，来实现进程间的同步和通信
- 套接字( socket ) ： 套解字也是一种进程间通信机制，与其他通信机制不同的是，它可用于不同机器间的进程通信



### Linux

#### Linux常用命令

```bash
########################      文本操作      ########################
## 升序排列
ls -lrt
# 目录dos2unix转换格式
find . -type f -exec dos2unix {} \;
# 变量要保留其原来的换行符要加双引号，建议所有变量引用都用双引号加大括号圈上
echo "${var}"
# 变量长度
echo "${#var}"
# 接受所有参数
$@
# 查看数组中所有元素
${list[@]}
# 查看数组长度
${#list[@]}
# 去掉全路径的文件名，只保留目录
${path%/*}
# 定义数组
list=("1" "2" "3")
# 定义map
declare -A map=(["1"]="name" ["2"]="age")
# 删除空白行和注释行
cat <file> | grep -v ^# | grep .
cat <file> | grep -Ev '^$|^#'
# 去掉行尾巴空格
echo ${var} | sed 's/[ \t]*$//g'
# 去掉单引号
echo ${var} | sed $'s/\'//g'
# 例如查看状态是UNCONN,Recv-Q是0的端口信息
ss -ln | awk '($2=="UNCONN" && $3=="0") {print $0}'
# 统计状态是UNCONN,Recv-Q是0的端口的netid和出现的次数
ss -ln | awk '($2=="UNCONN" && $3=="0") {netids[$1]++}END{for(i in netids)print i "\t" netids[i]}'
# 大写转小写
echo ${var} | tr 'A-Z' 'a-z'
# 字符串转ASCLL码
echo "${var}" | tr -d "\n" | od -An -t dC
# 根据名字找
find <dir> -name <org>
# 根据用户找
find <dir> -user <org>
# 根据组找
find <dir> -group <org>
# 根据权限找
find <dir> -perm <org>
# 根据大小找
find <dir> -size <org>
# 根据更改找
find <dir> -mmin <org>
# 根据类型找
find <dir> -type <l|b|f>
########################     系统命令      ########################
# 查看cpu
lscpu
# 查看pci
lspci
# 查看后台job
jobs
# 后台运行
( cmd ) &
# 唤醒
fg %<job_num>
# 暂停放入后台
ctrl z
# 唤醒stop的job
bg %<job_num>
# 发送信号，优先15SIGTERM，不行再9SIGKILL
kill -SIGTERM <PID>
# 杀用户所有进程
pkill -SIGTERM -u <user_name>
# 杀父进程
pkill -P <PID>
# 杀终端
pkill -SIGTERM -u <tty_name>
# 查看cpu信息
cat /proc/cpuinfo
# 查看服务单元
systemctl
systemctl --type service
systemctl list-units
# 判断状态
systemctl <is-active|is-enabled|is-failed|isolate|is-system-running> <unit_name>
# 看错误信息
systemctl --failed
systemctl status <unit_name> -l
# 看enable disable static的单元
systemctl list-unit-files
# 查看systemd日志
journalctl
# 指定级别
journalctl -p <err|debug|info|warning...>
# 持续打印
journalctl -f
# 指定单元
journalctl -u
# 当前时钟时区
timedatectl
# 设置
timedatectl <set-ntp|set-time|set-timezone|set-local-rtc> 
# 查看hostname信息
hostnamectl status
# 本地域名解析位置
cat /etc/hosts
cat /etc/resolv.conf
# 检查网络设备
ip addr show <eno>
# 查看网络性能
ip -s link <eno>
# 跟踪请求路径
tracepath
tracepath6
# 查看网络连接
nmcli con show
# 查看网络设备信息
nmcli dev show <eno>
# 修改网络接口
nmcli con add
nmcli con mod
# 激活/取消连接
nmcli con up "<id>"
nmcli con down "<id>"
# 网络配置文件位置
ls /etc/sysconfig/network-scripts/
# 查看网卡提供商
ls -l /sys/class/net/ens1f0/device # 看输出的最后一列<id>
lspci | grep <id>

yum <repolist|list|search|install|remove|update>
# 查找rpm包
rpm -qa | grep <name>
# 查看rpm信息
rpm -qi <name>
# 解压rpm包
rpm2cpio <rpm> | cpio -id
# 用户信息
cat /etc/passwd
# 组信息
cat /etc/group
# 更改用户或组
chown -R <user> <dir>
chown -R :<group> <dir>
chown -R <user>:<group> <dir>
# 改权限
chmod -R 750 <file>
# 显示当前登录信息
w -f
# 公钥存放位置
cat ~/.ssh/known_hosts
# 私钥位置
ls /etc/ssh/ssh_host_*
# 创建私钥公钥对
ssh-keygen
# 将公钥复制到远程机器实现互信
ssh-copy-id <user>@<host>
# 检测文件挂载点
df -h
# 检测目录使用空间信息
du -h <dir>
# 文件系统挂在
mount <dir> <dir>
# 查看目录中所有打开的文件和正在运行的进程
lsof <dir>
# 取消挂载
umount <dir>
# 创建硬连接
ln <exist_path> <path>
# 创建软连接
ln -s <exist_path> <path>
########################      其他软件        ########################
# 查看证书过期时间
openssl x509 -noout -enddate -in <crt_path>
# 获取端口证书过期时间
echo 'Q' | timeout 5 openssl s_client -connect <host:port> 2>/dev/null | openssl x509 -noout -enddate
# 自签根证书
openssl genrsa -aes256 -out <ca私钥位置> 2048
openssl req -new -key <ca私钥位置> -out <ca签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress="
openssl x509 -req -sha256 -days <过期天数> -in <ca签发流程位置> -out <ca证书位置> -signkey <ca私钥位置> -CAcreateserial
# 根证书签发子证书
openssl genrsa -aes256 -out <私钥位置> 2048
openssl req -new -key <私钥位置> -out <签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" 
openssl x509 -req -sha256 -days <过期天数> -in <签发流程位置> -out <证书位置> -signkey <私钥位置> -CAkey <ca私钥> -CA <ca证书位置> -CAcreateserial
openssl pkcs12 -export -clcerts -in <证书位置> -inkey <私钥位置> -out <p12证书位置> -name <别名>

# 查看keystore
${JAVA_HOME}/bin/keytool -v -list -storepass <password> -keystore <keystore_path>
# 导入trust keystore
${JAVA_HOME}/bin/keytool -import -trustcacerts -noprompt -alias <别名> -file <证书位置> -keystore <Keystore位置>
# 导入keystore
${JAVA_HOME}/bin/keytool -importkeystore -trustcacerts -noprompt -alias <别名> -deststoretype pkcs12 -srcstoretype pkcs12 -srckeystore <p12证书位置> -destkeystore <Keystore位置>

# 删除tag和name为none的坏掉的image
docker rmi $(docker images -f "dangling=true" -q)
# 删掉所有容器
docker stop $(docker ps -qa)
docker kill $(docker ps -qa)
docker rm $(docker ps -qa)
# 删除所有镜像
docker rmi --force $(docker images -q)
```



### 网络

#### 网络模型

- 常说的模型主要有3中，TCP/IP模型是OSI模型的一种商用实现

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/net-model.jpg)

- 7层模型中主要的协议

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/osi.png)



#### TCP建立连接三次握手

- 第一次握手：建立连接时，客户端发送syn包（seq=x）到服务器，并进入**SYN_SENT**状态，等待服务器确认；SYN：同步序列编号
- 第二次握手：服务器收到syn包，必须确认客户的SYN（ack=x+1），同时自己也发送一个SYN包（seq=y），即SYN+ACK包，此时服务器进入**SYN_RECV**状态
- 客户端收到服务器的SYN+ACK包，向服务器发送确认包ACK(ack=y+1），此包发送完毕，客户端和服务器进入**ESTABLISHED**（TCP连接成功）状态，完成三次握手

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-3.png)

#### TCP结束连接四次挥手

- 第一次挥手：客户端进程发出连接释放报文，并且停止发送数据。释放数据报文首部，FIN=1，其序列号为seq=u（等于前面已经传送过来的数据的最后一个字节的序号加1），此时，客户端进入FIN-WAIT-1（终止等待1）状态。 TCP规定，FIN报文段即使不携带数据，也要消耗一个序号
- 第二次挥手：服务器收到连接释放报文，发出确认报文，ACK=1，ack=u+1，并且带上自己的序列号seq=v，此时，服务端就进入了CLOSE-WAIT（关闭等待）状态。TCP服务器通知高层的应用进程，客户端向服务器的方向就释放了，这时候处于半关闭状态，即客户端已经没有数据要发送了，但是服务器若发送数据，客户端依然要接受。这个状态还要持续一段时间，也就是整个CLOSE-WAIT状态持续的时间，客户端收到服务器的确认请求后，此时，客户端就进入FIN-WAIT-2（终止等待2）状态，等待服务器发送连接释放报文（在这之前还需要接受服务器发送的最后的数据）
- 第三次挥手：服务器将最后的数据发送完毕后，就向客户端发送连接释放报文，FIN=1，ack=u+1，由于在半关闭状态，服务器很可能又发送了一些数据，假定此时的序列号为seq=w，此时，服务器就进入了LAST-ACK（最后确认）状态，等待客户端的确认
- 第四次挥手：客户端收到服务器的连接释放报文后，必须发出确认，ACK=1，ack=w+1，而自己的序列号是seq=u+1，此时，客户端就进入了TIME-WAIT（时间等待）状态。注意此时TCP连接还没有释放，必须经过2∗∗MSL（最长报文段寿命）的时间后，当客户端撤销相应的TCB后，才进入CLOSED状态，服务器只要收到了客户端发出的确认，立即进入CLOSED状态。同样，撤销TCB后，就结束了这次的TCP连接。可以看到，服务器结束TCP连接的时间要比客户端早一些

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-4.png)

#### TCP粘包，拆包

粘包拆包问题是处于网络比较底层的问题，在数据链路层、网络层以及传输层都有可能发生。我们日常的网络应用开发大都在传输层进行，由于UDP有消息保护边界，不会发生粘包拆包问题，因此粘包拆包问题只发生在TCP协议中

- 什么是粘包、拆包

  例如客户端给服务端发了两个包，包1和包2，服务端收到了一个包（包1和包2首尾连在一起）就叫做粘包，如果服务端正常收到两个包，但是第一个包是包1的前半部分，第二个包是包1的后半部分加上包2，就叫做发生了粘包和拆包

- 为什么会发生粘包、拆包

  - 应用程序写入的数据大于套接字缓冲区大小，这将会发生拆包
  - 进行MSS（最大报文长度）大小的TCP分段，当TCP报文长度-TCP头部长度>MSS的时候将发生拆包
  - 以太网帧的payload（净荷）大于MTU（1500字节）进行ip分片
  - 接收方法不及时读取套接字缓冲区数据，这将发生粘包
  - 应用程序写入数据小于套接字缓冲区大小，网卡将应用多次写入的数据发送到网络上，这将会发生粘包

- 粘包、拆包解决办法

  - 发送端给每个数据包添加包首部，首部中应该至少包含数据包的长度，这样接收端在接收到数据后，通过读取包首部的长度字段，便知道每一个数据包的实际长度了
  - 发送端将每个数据包封装为固定长度（不够的可以通过补0填充），这样接收端每次从接收缓冲区中读取固定长度的数据就自然而然的把每个数据包拆分开来
  - 可以在数据包之间设置边界，如添加特殊符号，这样，接收端通过这个边界就可以将不同的数据包拆分开

#### TCP滑动窗口

- 作用
  - 保证可靠性
  - 拥塞控制
- 目的
  - 为了增加网络的吞吐量，想讲数据包一起发送过去，这时候便产生了“滑动窗口”这种协议。有了“滑动窗口”这个概念，我们又解决了其中出现的一些问题。例如丢包，我们又通过重发的机制去解决了
- 过程
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-window1.png)
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-window2.png)
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-window3.png)
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-window4.png)

#### UDP特点

- 面向非连接
- 支持同时向多个客户端传输相同的消息
- 数据包报头8字节，额外开销小（TCP包头20字节）
- 吞吐量只受限于数据生成速率，传输速率，机器性能
- 不保证可靠交付
- 面向报文，不对应用程序提交的报文信息进行拆分和合并

#### 浏览器中输入URL到页面返回的过程

- **浏览器中输入域名例如www.baidu.com**
- **DNS域名解析**
  - 浏览器查找浏览器缓存，如果有域名对应的IP地址则返回
  - 浏览器查看本机的host文件，如果有域名对应的IP地址则返回
  - 然后是路由器缓存，路由器一般有自己的缓存，如果有域名对应的IP地址则返回
  - 向其他根域名服务器继续发出查询请求报文
  - 根域名服务器告诉本地域名服务器，下一次应查询的顶级域名服务器dns.com的IP地址
  - 本地域名服务器向顶级域名服务器dns.com进行查询
  - 顶级域名服务器dns.com告诉本地域名服务器，下一次应查询的权限域名服务器dns.baidu.com的IP地址
  - 本地域名服务器向权限域名服务器dns.baidu.com进行查询
  - 权限域名服务器dns.baidu.com告诉本地域名服务器，所查询的主机www.baidu.com的IP地址
  - 本地域名服务器最后把查询结果告诉主机
- **浏览器与目标服务器建立TCP连接**
- **浏览器通过http协议向目标服务器发送请求**
- **服务器给出响应，将指定文件发送给浏览器**
- **TCP释放链接**
- **浏览器显示页面中所有文本**

#### HTTPS过程解析

- 概述
  - HTTPS：Hypertext Transfer Protocol Secure 超文本传输安全协议
  - HTTPS 经由 HTTP 进行通信，但利用 TLS 来保证安全，即 HTTPS = HTTP + TLS
  - TLS：位于 HTTP 和 TCP 之间的协议，其内部有 TLS握手协议、TLS记录协议（OSI七层模型中的会话层，TCP/IP四层模型中定位模糊）
- 密码学基础
  - 伪随机数生成器
    - 没有真正意义上的随机数，具体可以参考 Random/TheadLocalRandom
      它的主要作用在于生成对称密码的秘钥、用于公钥密码生成秘钥对
  - 消息认证码
    - 消息认证码主要用于验证消息的完整性与消息的认证，其中消息的认证指“消息来自正确的发送者”
  - 数字签名
    - 消息认证码的缺点在于**无法防止否认**，因为共享秘钥被 client、server 两端拥有，server 可以伪造 client 发送给自己的消息（自己给自己发送消息），为了解决这个问题，我们需要它们有各自的秘钥不被第二个知晓（这样也解决了共享秘钥的配送问题）
    - 数字签名和消息认证码都**不是为了加密**
    - 可以将单向散列函数获取散列值的过程理解为使用 md5 摘要算法获取摘要的过程
    - 使用自己的私钥对自己所认可的消息生成一个该消息专属的签名，这就是数字签名，表明我承认该消息来自自己
    - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/digital-sign.png)
  - 公钥密码（非对称加密）
    - 也叫非对称密码，由公钥和私钥组成，它是最开始是为了解决秘钥的配送传输安全问题，即，我们不配送私钥，只配送公钥，私钥由本人保管
    - 它与数字签名相反，非对称密码的私钥用于解密、公钥用于加密，每个人都可以用别人的公钥加密，但只有对应的私钥才能解开密文
    - client：明文 + 公钥 = 密文
    - server：密文 + 私钥 = 明文
    - 注意：**公钥用于加密，私钥用于解密，只有私钥的归属者，才能查看消息的真正内容**
  - 证书
    - 全称公钥证书（Public-Key Certificate, PKC）,里面保存着归属者的基本信息，以及证书过期时间、归属者的公钥，并由认证机构（Certification Authority, **CA**）施加数字签名，表明，某个认证机构认定该公钥的确属于此人
- 认证流程
  - 建立TCP连接后，开始建立TLS连接
  - client端发起握手请求，会向服务器发送一个ClientHello消息，该消息包括
    - 其所支持的SSL/TLS版本
    - Cipher Suite加密算法列表（告知服务器自己支持哪些加密算法）
    - sessionID
    - 随机数等内容
  - 服务器收到请求后会向client端发送ServerHello消息，其中包括：
    - SSL/TLS版本
    - session ID，因为是首次连接会新生成一个session id发给client；
    - Cipher Suite，sever端从Client Hello消息中的Cipher Suite加密算法列表中选择使用的加密算法
    - Radmon 随机数
  - 经过ServerHello消息确定TLS协议版本和选择加密算法之后，就可以开始发送证书给client端了。证书中包含
    - 公钥
    - 签名
    - 证书机构等信息
  - 服务器向client发送ServerKeyExchange消息，消息中包含了服务器这边的EC Diffie-Hellman算法相关参数。此消息一般只在选择使用DHE 和DH_anon等加密算法组合时才会由服务器发出
  - server端发送ServerHelloDone消息，表明服务器端握手消息已经发送完成了
  - client端收到server发来的证书，会去验证证书，当认为证书可信之后，会向server发送ClientKeyExchange消息，消息中包含客户端这边的EC Diffie-Hellman算法相关参数，然后服务器和客户端都可根据接收到的对方参数和自身参数运算出Premaster secret，为生成会话密钥做准备
  - 此时client端和server端都可以根据之前通信内容计算出Master Secret（加密传输所使用的对称加密秘钥），client端通过发送此消息告知server端开始使用加密方式发送消息
  - 客户端使用之前握手过程中获得的服务器随机数、客户端随机数、Premaster secret计算生成会话密钥master secret，然后使用该会话密钥加密之前所有收发握手消息的Hash和MAC值，发送给服务器，以验证加密通信是否可用。服务器将使用相同的方法生成相同的会话密钥以解密此消息，校验其中的Hash和MAC值
  - 服务器发送ChangeCipherSpec消息，通知客户端此消息以后服务器会以加密方式发送数据
  - sever端使用会话密钥加密（生成方式与客户端相同，使用握手过程中获得的服务器随机数、客户端随机数、Premaster secret计算生成）之前所有收发握手消息的Hash和MAC值，发送给客户端去校验。若客户端服务器都校验成功，握手阶段完成，双方将按照SSL记录协议的规范使用协商生成的会话密钥加密发送数据
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tls.png)

#### ARP地址解析协议（链路层）

- 介绍
  - ARP协议提供了网络层地址（IP地址）到物理地址（mac地址）之间的动态映射
  - 网络层以上的**协议用IP地址来标识网络接口**，但以太数据帧传输时，**以物理地址来标识网络接口**。因此我们需要进行**IP地址与物理地址**之间的转化
  - 对于**IPv4来说，我们使用ARP地址解析协议**来完成IP地址与物理地址的转化（IPv6使用邻居发现协议进行IP地址与物理地址的转化，它包含在ICMPv6中）
- 工作流程
  - 每个主机都会在自己的 ARP 缓冲区中维护一个 ARP 列表，表示 IP 地址和 MAC 地址之间的对应关系
  - 主机（网络接口）**新加入网络时**（也可能只是mac地址发生变化，接口重启等）， 会发送免费ARP报文把自己IP地址与Mac地址的映射关系广播给其他主机
  - 网络上的主机接收到免费ARP报文时，会更新自己的ARP缓冲区。将新的映射关系更新到自己的ARP表中
  - 某个主机需要发送报文时，首先检查 ARP 列表中是否有对应 IP 地址的目的主机的 MAC 地址，如果有，则直接发送数据，如果没有，就向本网段的所有主机发送 ARP 数据包，该数据包包括的内容有：源主机 IP 地址，源主机 MAC 地址，目的主机的 IP 地址等
  - 当本网段的所有主机收到该 ARP 数据包时
    - 首先检查数**据包中的 IP 地址是否是自己的 IP 地址**，如果**不是，则忽略该数据包**
    - 如果是，**则首先从数据包中取出源主机的 IP 和 MAC 地址写入到 ARP 列表中，如果已经存在，则覆盖**
    - 然后将自己的 MAC 地址写入 ARP 响应包中，告诉源主机自己是它想要找的 MAC 地址
  - 源主机收到 ARP 响应包后。将目的主机的 IP 和 MAC 地址写入 ARP 列表，并利用此信息发送数据。如果源主机一直没有收到 ARP 响应数据包，表示 ARP 查询失败
- 存在问题：只要能模拟报文格式，无需身份验证
  - ARP攻击（断网）：通过发送虚假的ARP广播或ARP单播报文，其中虚假的MAC地址是不存在的
  - ARP欺骗（窃取）：通过发送虚假的ARP广播或ARP单播报文，其中虚假的MAC地址是攻击者的MAC地址，ARP欺骗（又称 中间人攻击）可以正常上网通信，会造成信息泄露





### 数据结构与算法

#### 常用排序算法

实现比较丑陋，勿喷啊

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/sort.PNG)

- **冒泡排序**：从前向后比较相邻的元素。如果前一个比后一个大，就交换他们两个，每一轮把一个最大的数运到数组最后面。

  ```java
  public static int[] sort(int[] arr) {
      int len = arr.length;
      // 冒泡总次数
      for (int i = 1; i < len; i++) {
          boolean flag = true;
          // 每次冒泡过程
          for (int j = 0; j < len - i; j++) {
              if (arr[j] > arr[j + 1]) {
                  MyUtils.swap(arr, j, j + 1);
                  flag = false;
              }
          }
          if (flag) {
              // 如果一个冒泡过程没改变，退出返回已经有序
              break;
          }
      }
      return arr;
  }
  ```

- **选择排序**：每次从未排序数组中找一个最小的元素，放到以有序数组后面

  ```java
  public static int[] sort(int[] arr) {
      int len = arr.length;
      // 选择次数
      for (int i = 0; i < len - 1; i++) {
          int min = i;
          // 每次选择过程
          for (int j = i + 1; j < len; j++) {
              if (arr[j] < arr[min]) {
                  min = j;
              }
          }
          if (min != i) {
              MyUtils.swap(arr, i, min);
          }
      }
      return arr;
  }
  ```

- **插入排序**：每次把未排序的第一个数，插入到已排序数组的适当位置（如果待插入的元素与有序序列中的某个元素相等，则将待插入元素插入到相等元素的后面）

  ```java
  public static int[] sort(int[] arr) {
      int len = arr.length;
      // 插入次数，left为未有序的左边
      for (int left = 1; left < len; left++) {
          int temp = arr[left];
          int right = left - 1;
          // right为有序部分的右边
          while (right >= 0 && temp < arr[right]) {
              arr[right + 1] = arr[right];
              right--;
          }
          // 判断是否需要插入
          if (right != left - 1) {
              arr[right + 1] = temp;
          }
      }
      return arr;
  }
  ```

- **归并排序**：将数组分成很多小份，然后依次合并

  ```java
  public static int[] sort(int[] arr) {
      sort(arr, 0, arr.length - 1);
      return arr;
  }
  
  private static void sort(int[] arr, int left, int right) {
      if (left == right) {
          return;
      }
      // 等同于(right + left)/2
      int mid = left + ((right - left) >> 1);
      sort(arr, left, mid);
      sort(arr, mid + 1, right);
      // 已经分成了许多小份，开始合并
      merge(arr, left, mid, right);
  }
  
  private static void merge(int[] arr, int left, int mid, int right) {
      int[] help = new int[right - left + 1];
      int i = 0;
      int p1 = left;
      int p2 = mid + 1;
      // 左边右边通过辅助数组合并
      while (p1 <= mid && p2 <= right) {
          help[i++] = arr[p1] < arr[p2] ? arr[p1++] : arr[p2++];
      }
      // 左边没空加到后面
      while (p1 <= mid) {
          help[i++] = arr[p1++];
      }
      // 右边没空加到后面
      while (p2 <= right) {
          help[i++] = arr[p2++];
      }
      for (int j = 0; j < help.length; j++) {
          arr[left + j] = help[j];
      }
  }
  ```

- **荷兰国旗问题**：给定一个整数数组，给定一个值K，这个值在原数组中一定存在，要求把数组中小于K的元素放到数组的左边，大于K的元素放到数组的右边，等于K的元素放到数组的中间，最终返回一个整数数组，其中只有两个值，分别是等于K的数组部分的左右两个下标值

  ```java
  public static int[] sort(int[] arr) {
      partiton(arr, 0, arr.length - 1);
      return arr;
  }
  
  public static int[] partiton(int[] arr, int left, int right) {
      int less = left - 1;
      int more = right + 1;
      int pNum = arr[right];
      while (left < more) {
          if (arr[left] < pNum) {
              MyUtils.swap(arr, ++less, left++);
          } else if (arr[left] > pNum) {
              MyUtils.swap(arr, --more, left);
          } else {
              left++;
          }
      }
      return new int[]{less, more};
  }
  ```

- **快速排序**：重新排序数列，所有元素比基准值小的摆放在基准前面，所有元素比基准值大的摆在基准的后面（相同的数可以到任一边）。在这个分区退出之后，该基准就处于数列的中间位置。这个称为分区（partition）操作，递归地（recursive）把小于基准值元素的子数列和大于基准值元素的子数列排序

  ```java
  // 基于荷兰国旗问题的快排
  public static int[] sort(int[] arr) {
      sort(arr, 0, arr.length - 1);
      return arr;
  }
  
  public static void sort(int[] arr, int left, int right) {
      if (left < right) {
          int[] pIndexs = DutchFlag.partiton(arr, left, right);
          sort(arr, left, pIndexs[0]);
          sort(arr, pIndexs[1], right);
      }
  }
  ```

- **堆排序**：先建立大根堆，然后不停做heapify，也就是把未有序的最后一位和堆首互换，然后调整堆结构

  ```java
  public static int[] sort(int[] arr) {
      int len = arr.length;
      buildBigHeap(arr, len);
      while (len > 0) {
          MyUtils.swap(arr, 0, --len);
          heapify(arr, 0, len);
      }
      return arr;
  }
  
  // 建立大根堆
  public static void buildBigHeap(int[] arr, int len) {
      for (int index = 0; index < arr.length; index++) {
          while (arr[index] > arr[(index - 1) / 2]) {
              MyUtils.swap(arr, index, (index - 1) / 2);
              index = (index - 1) / 2;
          }
      }
  }
  
  // 调整堆
  private static void heapify(int[] arr, int currRoot, int len) {
      int left = currRoot * 2 + 1;
      int right = currRoot * 2 + 2;
  
      while (left < len) {
          int largest = right < len && arr[left] < arr[right] ? right : left;
          largest = arr[largest] > arr[currRoot] ? largest : currRoot;
          if (largest == currRoot) {
              break;
          }
          MyUtils.swap(arr, currRoot, largest);
          currRoot = largest;
          left = currRoot * 2 + 1;
          right = currRoot * 2 + 2;
      }
  }
  ```

#### 二叉树

前序 中序 后续 层级遍历

  ```java
  public static void pre(TreeNode root) {
      if (root != null) {
          Stack<TreeNode> stack = new Stack<>();
          stack.push(root);
          // 先进右再进左
          while (!stack.isEmpty()) {
              root = stack.pop();
              System.out.print(root.val + " -> ");
              if (root.right != null) {
                  stack.push(root.right);
              }
              if (root.left != null) {
                  stack.push(root.left);
              }
          }
      }
      System.out.println();
  }
  
  public static void preReur(TreeNode root) {
      if (root == null) {
          return;
      }
      System.out.print(root.val + " -> ");
      preReur(root.left);
      preReur(root.right);
  
  }
  ```

  ```java
  public static void mid(TreeNode root) {
      Stack<TreeNode> stack = new Stack<>();
      // 左走到头了开始弹，然后去右
      while (root != null || !stack.isEmpty()) {
          if (root != null) {
              stack.push(root);
              root = root.left;
          } else {
              root = stack.pop();
              System.out.print(root.val + " -> ");
              root = root.right;
          }
      }
      System.out.println();
  }
  
  
  public static void midReur(TreeNode root) {
      if (root == null) {
          return;
      }
      midReur(root.left);
      System.out.print(root.val + " -> ");
      midReur(root.right);
  }
  ```

  ```java
  public static void post(TreeNode root) {
      // 把线序遍历反过来，得到前右左，然后再反过来变成左右前
      if (root != null) {
          Stack<TreeNode> stackStack = new Stack<>();
          Stack<TreeNode> stack = new Stack<>();
          stack.push(root);
          while (!stack.isEmpty()) {
              root = stack.pop();
              stackStack.push(root);
              if (root.left != null) {
                  stack.push(root.left);
              }
              if (root.right != null) {
                  stack.push(root.right);
              }
          }
          while (!stackStack.isEmpty()) {
              System.out.print(stackStack.pop().val + " -> ");
          }
      }
      System.out.println();
  }
  
  public static void postReur(TreeNode root) {
      if (root == null) {
          return;
      }
      postReur(root.left);
      postReur(root.right);
      System.out.print(root.val + " -> ");
  }
  ```

  ```java
  public static void level(TreeNode root) {
      if (root == null) {
          return;
      }
      LinkedList<TreeNode> queue = new LinkedList<>();
      queue.add(root);
      TreeNode curr = null;
      while (!queue.isEmpty()) {
          curr = queue.pop();
          System.out.print(curr.val + " -> ");
          if (curr.left != null) {
              queue.add(curr.left);
          }
          if (curr.right != null) {
              queue.add(curr.right);
          }
      }
  }
  ```

#### 算法验证对数器

- 准备样本随机生成器
- 准备一个绝对正确但是复杂度不好的算法
- 将待验证算法和绝对正确算法压测，比较

#### 主定理与递归时间复杂度的计算

- 主定理：如果有一个问题规模为 n，递推的子问题数量为 a，每个子问题的规模为n/b（假设每个子问题的规模基本一样），递推以外进行的计算工作为 f(n)（比如归并排序，需要合并序列，则 f(n)就是合并序列需要的运算量），那么对于这个问题有如下递推关系式：
- ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/main1.jpe)
- 然后就可以套公式估算递归的时间复杂度
- ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/main2.jpe)



#### B树和B+树定义与区别

- M阶B树
  - 定义
    - 任意非叶子结点最多只有M个儿子，且M>2
    - 根结点的儿子数为[2, M]
    - 除根结点以外的非叶子结点的儿子数为[M/2, M]，向上取整
    - 非叶子结点的关键字个数=儿子数-1
    - 所有叶子结点位于同一层
    - k个关键字把节点拆成k+1段，分别指向k+1个儿子，同时满足查找树的大小关系
  - 特征
    - 关键字集合分布在整颗树中
    - 任何一个关键字出现且只出现在一个结点中
    - 搜索有可能在非叶子结点结束
    - 其搜索性能等价于在关键字全集内做一次二分查找
- M阶B+树
  - 定义
    - 有n棵子树的非叶子结点中含有n个关键字（b树是n-1个），这些关键字不保存数据，只用来索引，所有数据都保存在叶子节点（b树是每个关键字都保存数据）
    - 所有的叶子结点中包含了全部关键字的信息，及指向含这些关键字记录的指针，且叶子结点本身依关键字的大小自小而大顺序链接
    - 所有的非叶子结点可以看成是索引部分，结点中仅含其子树中的最大（或最小）关键字
    - 通常在b+树上有两个头指针，一个指向根结点，一个指向关键字最小的叶子结点
    - 同一个数字会在不同节点中重复出现，根节点的最大元素就是b+树的最大元素
  - 特征
    - b+树的中间节点不保存数据，所以磁盘页能容纳更多节点元素，更“矮胖”
    - b+树查询必须查找到叶子节点，b树只要匹配到即可不用管元素位置，因此b+树查找更稳定（并不慢）
    - 对于范围查找来说，b+树只需遍历叶子节点链表即可，b树却需要重复地中序遍历

#### 并查集

- 用于解决
  - 两个元素是否在同一个集合（优化，查的过程中把路过的节点直接连头节点）
  - 合并两个元素所在的集合
- 实现
  - 数组
  - 双HashMap

#### 红黑树

- 特点
  - 每个节点非红即黑
  - 根节点总是黑色的
  - 如果节点是红色的，则它的子节点必须是黑色的（反之不一定）
  - 每个叶子节点都是黑色的空节点
  - 从根节点到叶节点或空子节点的每条路径，必须包含相同数目的黑色节点（即相同的黑色高度）

#### 跳跃表

- 特点

  - 最底层包含所有节点的一个有序的链表
  - 每一层都是一个有序的链表
  - 每个节点都有两个指针，一个指向右侧节点（没有则为空），一个指向下层节点（没有则为空）
  - 必备一个头节点指向最高层的第一个节点，通过它可以遍历整张表

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/skip-list.jpg)

#### 前缀树/字典树（Trie）

- 用于解决
  - 常用于快速检索
  - 大量字符串的排序和统计
- 基本性质
  - 根节点不包含字符，除根节点外每个节点只包含一个字符
  - 从根节点到某个节点，路径上所有的字符连接起来，就是这个节点所对应的字符串
  - 每个节点的子节点所包含的字符都不同

#### 如何从暴力递归改动态规范

- 首先写好一个暴力递归
  - 分析这个递归是否有重复计算
  - 分析这个递归的当前状态和之前递归计算的顺序是不是无关
  - 如果都满足就可以改成动态规划
- 改写成DP
  - 找出递归中变化的参数
  - 确定递归的开始位置
  - 确定一些边界或者特殊情况
  - 抽象出一次递归的步骤，分析步骤和已经固定的边界的关系
  - 找出规律后coding

#### 布隆过滤（Bloom Filter）

- **解决问题**：判断一个元素是否在一个集合中，优势是只需要占用很小的内存空间以及有着高效的查询效率

- **原理**：保存了很长的二进制向量，同时结合 Hash 函数实现

  - 首先需要k个hash函数，每个函数可以把key散列成为1个整数
  - 初始化时，需要一个长度为n比特的数组，每个比特位初始化为0
  - 某个key加入集合时，用k个hash函数计算出k个散列值，并把数组中对应的比特位置为1
  - 判断某个key是否在集合时，用k个hash函数计算出k个散列值，并查询数组中对应的比特位，如果所有的比特位都是1，认为在集合中。

- **特点**

  - 只要返回数据不存在，则肯定不存在
  - 返回数据存在，只能是大概率存在
  - 不能清除其中的数据

- **计算误差**

  - 先根据样本大小n，可以接受的误差p，计算需要申请多大内存m

    ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/bloom1.png)

  - 再由m，n得到hash function的个数k

    ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/bloom2.png)

  - 再计算实际的误差p

    ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/bloom3.png)

## Java

### 核心

#### HashMap

- ##### 应用场景

  - 键值对高效存取

- ##### 数据结构

  - 1.7数组加链表
  - 1.8数组加链表加红黑树

- ##### 线程安全

  - **不安全**
  - 多线程下使用扩容步骤存在问题
  - 线程安全的替代
    - Hashtable
    - ConcurrentHashMap
  
- ##### 默认大小

  - 初始数组默认长度16

- ##### 何时扩容

  - HashMap.Size   >=  Capacity * LoadFactor当前容量超过总容量乘以散列因子（默认0.75）就扩容，每次2倍扩容

- ##### 扩容机制

  - jdk1.7
    - 对于扩容操作，底层实现都需要新生成一个数组，然后拷贝旧数组里面的每一个Entry链表到新数组里面，这个方法在单线程下执行是没有任何问题的，但是在多线程下面却有很大问题，主要的问题在于基于**头插法**的数据迁移，会有几率造成链表倒置，从而引发链表闭链，当map.get(key)落到这个Entry时候就会进入死循环，导致程序死循环，并吃满CPU
  - jdk1.8
    - 没有使用**头插法**，而是保留了元素的顺序位置，把要迁移的元素分类之后，最后在分别放到新数组对应的位置上

- ##### 为什么数组的长度为2的幂次方

  - **计算桶中位置**

    - 求出 对象的hashcode之后模一个数组长度就可以映射到具体的桶中

      ```java
      index = hashCode % Length
      ```

    - 取余操作的性能是不如与运算的，**当长度为2的幂次方时，就可以等价成下面的与运算**

      ```java
      index = hashCode & (Length - 1)
      ```

      - 例如
        - Length是16，对应二进制 10000
        - 那么(Length - 1)，对应二进制 1111
        - 被计算出的hash值，高位忽略，只考虑低4位与运算的结果就是对应的桶

    - jdk1.8继续做了优化

      ```java
      index = hashCode ^ (hashCode >>> 16) & (Length - 1)
      ```

      - 因为我们只用到了后四位去计算index，所以高位就全忽略了产生冲突的概率大，这时我们把高16位右移并且和原值做异或运算，已最小的代价让高位也参与到计算中来

  - **扩容方面**

    - 扩容需要重计算桶中位置
    - 接上例
      - 由于默认扩容2倍，length变为32
      - 此时(Length - 1)，对应二进制 11111
      - 高位依旧忽略，现在需要考虑低5位
      - 如果第5位为0则index不变
      - 如果第5位为1则index增加一个过去数组的长度

- ##### jdk1.8 何时转红黑树

  - Node桶下链表长度超过8转为红黑树
  - Node桶下红黑树节点数小于6就转回链表

#### LinkedHashMap

- ##### 应用场景

  - 保证插入的顺序

#### Hashtable

- ##### 默认大小

  - 11

- ##### 线程安全性

  - **安全**
  - 实现
    - 方法加synchronized

#### ConcurrentHashMap

- ##### 线程安全性

  - **安全**
  - jdk1.7
    - 采用的是分段锁的机制，ConcurrentHashMap维护了一个Segment数组，Segment这个类继承了重入锁ReentrantLock，并且该类里面维护了一个 HashEntry<K,V>[] table数组，在写操作put，remove，扩容的时候，会对Segment加锁
  - jdk1.8
    - 新的版本主要使用了Unsafe类的CAS自旋赋值+synchronized同步+LockSupport阻塞等手段直接操作Node， 取消了分段的概念，实现的高效并发。实现中的优化，**等待的线程会帮助扩容的线程一起完成扩容操作**

#### TreeMap

- ##### 应用场景

  - 保证map的内部有序性

- ##### 数据结构

  - 红黑树

- ##### 线程安全性

  - 不安全
  - 线程安全的替代
    - ConcurrentSkipListMap

#### ConcurrentSkipListMap

- ##### 应用场景

  - 保证map的内部有序性
  - 并发的线程越多，ConcurrentSkipListMap越能体现出他的优势

- ##### 数据结构

  - 跳跃表

- ##### 线程安全性

  - 安全
  - 实现
    - CAS自旋操作

#### ArrayList

- ##### 特点

  - 实现标识接口RandomAccess，随机存取，查询效率高，大数据量下迭代效率差

- ##### 数据结构

  - 数组

- ##### 线程安全性

  - 不安全
  - 线程安全的替代
    - List list = Collections.synchronizedList(new ArrayList())
    - CopyOnWriteArrayList

- ##### 默认大小

  - 有个懒加载设计，new ArrayList() 返回的是一个空的默认数组
  - 当第一次add操作之后扩容成10

- ##### 何时扩容

  - 装不下就扩容
  - newCapacity = oldCapacity + (oldCapacity >> 1) 每次1.5倍扩容

- ##### 扩容机制

  - 调用 Arrays.copyOf() 方法， 改方法是 native （System.arraycopy）实现

- ##### 克隆

  - 深拷贝

#### CopyOnWriteArrayList

- ##### 数据结构

  - 数组

- ##### 线程安全性

  - 安全
  - 实现
    - 读操作不加锁，写操作是在副本上执行的，执行完了再去替换原先的值
    - 在写操作时，使用ReentrantLock保证了同步，然后开始做复制，以及写操作

- ##### 特点

  - 读取是完全不用加锁的
  - 写入也不会阻塞读取操作
  - 只有写入和写入之间需要进行同步等待

#### LinkedList

- ##### 数据结构

  - 双端链表

- ##### 线程安全性

  - 不安全
  - 线程安全的替代
    - List list = Collections.synchronizedList(new LinkedList())
    - ConcurrentLinkedQueue

- ##### 克隆

  - 浅拷贝

#### ConcurrentLinkedQueue

- ##### 应用场景

  - 适合在对性能要求相对较高，同时对队列的读写存在多个线程同时进行的场景
  - 非阻塞

- ##### 数据结构

  - 链表

- ##### 线程安全性

  - 安全
  - 实现
    - 通过 循环CAS 操作实现

#### PriorityQueue

- ##### 应用场景

  - 找最大最小元素

- ##### 数据结构

  - 堆

- ##### 线程安全性

  - 不安全
  - 线程安全的替代
    - **PriorityBlockingQueue**

#### BlockingQueue

- ##### 应用场景

  - 生产者-消费者

- ##### 线程安全性

  - 安全

- ##### 特点

  - 对插入操作、移除操作、获取元素操作提供了四种不同的方法用于不同的场景中使用
      - Throws exception抛异常
          - add(e)
          - remove()
          - element()
      - Special value回特殊值
          - offer(e)
          - poll()
          - peek()
      - Blocks阻塞
          - put(e)
          - take()
      - Times out超时
          - offer(e, time, unit)
          - poll(time, unit)
  - 不能插入null

- ##### 主要实现

  - **ArrayBlockingQueue**

    - 数据结构

      - 数组

    - 线程安全性

      - 实现

        - 可重入锁，Condition

          - ```java
            final ReentrantLock lock;
            private final Condition notEmpty;
            private final Condition notFull;
            ```

        - 插入或读取操作都需要拿锁

    - 特点

      - 容量不能改变
      - 默认情况不能保证公平性

    - 参数

      - 队列容量，其限制了队列中最多允许的元素个数
      - 指定独占锁是公平锁还是非公平锁。非公平锁的吞吐量比较高，公平锁可以保证每次都是等待最久的线程获取到锁
      - 可以指定用一个集合来初始化，将此集合中的元素在构造方法期间就先添加到队列中

  - **LinkedBlockingQueue**

    - 数据结构

      - 单向链表

    - 线程安全性

      - 可重入锁，Condition

        - ```java
          // take, poll, peek 等读操作的方法需要获取到这个锁
          private final ReentrantLock takeLock = new ReentrantLock();
          
          // 如果读操作的时候队列是空的，那么等待 notEmpty 条件
          private final Condition notEmpty = takeLock.newCondition();
          
          // put, offer 等写操作的方法需要获取到这个锁
          private final ReentrantLock putLock = new ReentrantLock();
          
          // 如果写操作的时候队列是满的，那么等待 notFull 条件
          private final Condition notFull = putLock.newCondition();
          ```

  - **PriorityBlockingQueue** 

    - 数据结构
      - 堆
    - 线程安全性
      - 实现
        - **ReentrantLock**
    - 特点
      - 自动扩容

  - **SynchronousQueue**

    - 特点
      - 没有存储，读直接交给写，写直接交给读
      - TransferStack
      - TransferQueue（默认 非公平模式）

#### TreeSet

- ##### 应用场景

  - 自动排序

- ##### 线程安全性

  - 不安全
  - 线程安全的替代
    - CopyOnWriteArraySet
    - ConcurrentSkipListSet

#### 重写equals

- 四大原则，自反性，对称性，传递性，一致性，非空性
- 如果继承一个类，并且新增了值属性，重写equals会变得很麻烦，这时候推荐用组合
- 如果重写了equals但是没有重写hashcode有可能出现equals返回true但是hashcode不相等的情况

#### 异常处理一般规范

- 在Finally块中清理资源或者使用Try-With-Resource语句
- 抛出明确的异常，避免抛出Exception这种
- 在注释Javadoc里边添加@throws声明并且描述什么样的情况会导致异常
- 将异常与它的描述信息一并抛出
- 优先catch捕获更明确的异常
- 不要捕获Throwable
- 别忽略异常
- 不要打印异常日志的同时将其抛出
- 自定义异常包裹某个异常的同时不要丢弃它原本的信息
- 如果catch住之后throw一个新异常，方法下面的内容都不会执行

#### BIO,NIO,AIO的区别

- **BIO**
  - 基于字节流(InputStream,OutputStream)，字符流(Reader,Writer)
  - 同步阻塞I/O操作
  - 一个连接对应一个线程
- **NIO**（>jdk4）
  - 多路复用，同步非阻塞I/O操作
  - 增加了Channel,Buffer,Selector等组件
  - 多个连接对应一个线程
- **AIO**（>jdk7）
  - 异步非阻塞I/O操作
  - 基于事件和回调机制
  - 请求立即返回，连接和线程无对应关系

#### BIO组件

|                  | Byte Based                                                   | Character Based                                              |                                                              |                                                              |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
|                  | Input                                                        | Output                                                       | Input                                                        | Output                                                       |
| Basic            | [InputStream](http://tutorials.jenkov.com/java-io/inputstream.html) | [OutputStream](http://tutorials.jenkov.com/java-io/outputstream.html) | [Reader](http://tutorials.jenkov.com/java-io/reader.html) [InputStreamReader](http://tutorials.jenkov.com/java-io/inputstreamreader.html) | [Writer](http://tutorials.jenkov.com/java-io/writer.hml) [OutputStreamWriter](http://tutorials.jenkov.com/java-io/outputstreamwriter.html) |
| Arrays           | [ByteArrayInputStream](http://tutorials.jenkov.com/java-io/bytearrayinputstream.html) | [ByteArrayOutputStream](http://tutorials.jenkov.com/java-io/bytearrayoutputstream.html) | [CharArrayReader](http://tutorials.jenkov.com/java-io/chararrayreader.html) | [CharArrayWriter](http://tutorials.jenkov.com/java-io/chararraywriter.html) |
| Files            | [FileInputStream](http://tutorials.jenkov.com/java-io/fileinputstream.html) [RandomAccessFile](http://tutorials.jenkov.com/java-io/randomaccessfile.html) | [FileOutputStream](http://tutorials.jenkov.com/java-io/fileoutputstream.html) [RandomAccessFile](http://tutorials.jenkov.com/java-io/randomaccessfile.html) | [FileReader](http://tutorials.jenkov.com/java-io/filereader.html) | [FileWriter](http://tutorials.jenkov.com/java-io/filewriter.html) |
| Pipes            | [PipedInputStream](http://tutorials.jenkov.com/java-io/pipedinputstream.html) | [PipedOutputStream](http://tutorials.jenkov.com/java-io/pipedoutputstream.html) | [PipedReader](http://tutorials.jenkov.com/java-io/pipedreader.html) | [PipedWriter](http://tutorials.jenkov.com/java-io/pipedwriter.html) |
| Buffering        | [BufferedInputStream](http://tutorials.jenkov.com/java-io/bufferedinputstream.html) | [BufferedOutputStream](http://tutorials.jenkov.com/java-io/bufferedoutputstream.html) | [BufferedReader](http://tutorials.jenkov.com/java-io/bufferedreader.html) | [BufferedWriter](http://tutorials.jenkov.com/java-io/bufferedwriter.html) |
| Filtering        | [FilterInputStream](http://tutorials.jenkov.com/java-io/filterinputstream.html) | [FilterOutputStream](http://tutorials.jenkov.com/java-io/filteroutputstream.html) | [FilterReader](http://tutorials.jenkov.com/java-io/filterreader.html) | [FilterWriter](http://tutorials.jenkov.com/java-io/filterwriter.html) |
| Parsing          | [PushbackInputStream](http://tutorials.jenkov.com/java-io/pushbackinputstream.html) [StreamTokenizer](http://tutorials.jenkov.com/java-io/streamtokenizer.html) |                                                              | [PushbackReader](http://tutorials.jenkov.com/java-io/pushbackreader.html) [LineNumberReader](http://tutorials.jenkov.com/java-io/linenumberreader.html) |                                                              |
| Strings          |                                                              |                                                              | [StringReader](http://tutorials.jenkov.com/java-io/stringreader.html) | [StringWriter](http://tutorials.jenkov.com/java-io/stringwriter.html) |
| Data             | [DataInputStream](http://tutorials.jenkov.com/java-io/datainputstream.html) | [DataOutputStream](http://tutorials.jenkov.com/java-io/dataoutputstream.html) |                                                              |                                                              |
| Data - Formatted |                                                              | [PrintStream](http://tutorials.jenkov.com/java-io/printstream.html) |                                                              | [PrintWriter](http://tutorials.jenkov.com/java-io/printwriter.html) |
| Objects          | [ObjectInputStream](http://tutorials.jenkov.com/java-io/objectinputstream.html) | [ObjectOutputStream](http://tutorials.jenkov.com/java-io/objectoutputstream.html) |                                                              |                                                              |
| Utilities        | [SequenceInputStream](http://tutorials.jenkov.com/java-io/sequenceinputstream.html) |                                                              |                                                              |                                                              |

#### Java泛型参数

生产者用extends，消费者用super

```java
public class NewStack<T>{
    public void pushAll(Iterable <? extends T> src) {
        for (T t : src) {
            push(t);
        }
    }
    
    public void popAll(Collection <? super T> dst){
        while (!isEmpty()){
            dst.add(pop());
        }
    }    
}

```

#### J.U.C总览图

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/juc.png)

#### J.U.C常用同步器

- **CountDownLatch**
  - 作用：主要用于线程要等待其他线程任务执行完再执行，等到条件满足之后一起起跑
- **CyclicBarrier**
  - 作用：可以重复利用的CountDownLatch
- **Executors**
  - 作用：主要用于提供默认应用场景的线程池创建，以及一些任务调度方法
- **Semaphore**
  - 作用：主要用于限制同时执行任务的线程数量
- **Exchanger**
  - 作用：主要用于两个线程之间交换数据

#### AbstractQueuedSynchronizer(AQS)

- 大致原理
  - CAS
  - CLH
  - LockSupport
  - Condition

- 大名鼎鼎的AQS，这里涉及源码较多，就贴连接吧
- [一行一行源码分析清楚AbstractQueuedSynchronizer](https://www.javadoop.com/post/AbstractQueuedSynchronizer)
- [一行一行源码分析清楚AbstractQueuedSynchronizer-2](https://www.javadoop.com/post/AbstractQueuedSynchronizer-2)
- [一行一行源码分析清楚AbstractQueuedSynchronizer-3](https://www.javadoop.com/post/AbstractQueuedSynchronizer-3)

#### ReentrantLock

- 特征
  - 公平锁
  - 非公平锁
    - 非公平锁在调用 lock 后，首先就会调用 CAS 进行一次抢锁，如果这个时候恰巧锁没有被占用，那么直接就获取到锁返回了。
    - 非公平锁在 CAS 失败后，和公平锁一样都会进入到 tryAcquire 方法，在 tryAcquire 方法中，如果发现锁这个时候被释放了（state == 0），非公平锁会直接 CAS 抢锁，但是公平锁会判断等待队列是否有线程处于等待状态，如果有则不去抢锁，乖乖排到后面。
  - 可重入

- 实现

  - AQS
  - lockSupport + CAS + CLH

- 过程

  - 加锁过程 reentrantLock.lock() 
    - acquire()要锁
    - tryAcquire()尝试拿锁
    - 如没拿到锁，则addWaiter()加入等待队列
    - 加入等待队列冲突了，则enq()自旋的插入队列
    - 然后acquireQueued()循环的拿等待队列的头去抢锁
    - 没抢到的线程都要被挂起shouldParkAfterFailedAcquire()， LockSupport.park()
  - 解锁过程 reentrantLock.unlock()
    - release()解锁
    - tryRelease()尝试解锁
    - unparkSuccessor()唤醒阻塞队列的后继，LockSupport.unpark()
    - 然后也进acquireQueued()

  

#### J.U.C阻塞队列BlockingQueue

- ArrayBlockingQueue
  - 结构：由数组组成的有界阻塞队列
- LinkedBlockingQueue
  - 结构：由链表组成的有界/无界阻塞队列
- LinkedTransferQueue
  - 结构：由链表组成的无界阻塞队列
- LinkedBlockingDeque
  - 结构：由链表组成的双端阻塞队列
- PriorityBlockingQueue
  - 结构：由堆结构支持优先级排序的无界阻塞队列
- DelayQueue
  - 结构：使用PriorityQueue实现的带延迟的无界阻塞队列
- SynchronousQueue
  - 结构：不存储元素的阻塞队列

#### 线程池的五种状态

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/threadpoolstatus.jpg)

#### 如何创建线程池

- 结构图
  
- ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/thread-pool.jpg)
  
- 直接通过new ThreadPoolExecutor()创建（推荐，可以定制化，控制细节）
  - 构造参数：
    - int corePoolSize：线程池正常运行时的核心线程数，即使空闲也会等待任务在线程数少于核心数量时，有新任务进来就新建一个线程，即使有的线程没事干，等超出核心数量后，就不会新建线程了，空闲的线程就得去任务队列里取任务执行了
    - int maximumPoolSize：线程池允许的最大线程数
      - 如果任务队列满了，并且池中线程数小于最大线程数，会再创建新的线程执行任务
    - long keepAliveTime：超出corePoolSize的线程的存活时间
    - TimeUnit unit：keepAliveTime参数的时间单位
    - BlockingQueue<Runnable> workQueue：核心线程全在干活，新任务进去这个阻塞队列等待执行，**只有执行execute方法时才会进入等待队列**
    - ThreadFactory threadFactory：创建新线程的工厂
    - RejectedExecutionHandler handler：workQueue满了，池中线程数也到了maximumPoolSize，就需要执行拒绝策略
      - CallerRunsPolicy：只要线程池没关闭，就直接用调用者所在线程来运行任务
      - AbortPolicy：直接抛出 RejectedExecutionException异常
      - DiscardPolicy：悄悄把任务放生，不做了
      - DiscardOldestPolicy：把队列里待最久的那个任务扔了
  - 可能抛出的异常：
    - IllegalArgumentException
      - corePoolSize < 0
      - keepAliveTime < 0
      - maximumPoolSize <= 0
      - maximumPoolSize < corePoolSize
    - NullPointerException
      - workQueue，threadFactory和handler其中有一个为null
  
- 通过Executors工具类创建内置常用的线程池方案
  - newFixedThreadPool **用于负载比较重的服务器，为了资源的合理利用，需要限制当前线程数量**
  
    - 源码：
  
      ```java
      public static ExecutorService newFixedThreadPool(int nThreads) {
          return new ThreadPoolExecutor(nThreads, nThreads,
                                        0L, TimeUnit.MILLISECONDS,
                                        new LinkedBlockingQueue<Runnable>();
      }
      ```
      
     - 核心线程数和最大线程数一样，稳定高负荷工作，因此没用超出核心线程数回收的情况keepAliveTime 设置为0，等待队列用LinkedBlockingQueue无界队列

  - newSingleThreadExecutor **用于串行执行任务的场景，每个任务必须按顺序执行，不需要并发执行**
  
    - 源码：
  
      ```java
      public static ExecutorService newSingleThreadExecutor() {
          return new FinalizableDelegatedExecutorService
              (new ThreadPoolExecutor(1, 1,
                                      0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>()));
      }
      ```
  
    - 解释：
  
      类似于newFixedThreadPool，只是顾名思义池中只有一个线程干活，相当于串行 
  
  - newCachedThreadPool  **用于并发执行大量短期的小任务，或者是负载较轻的服务器**
  
    - 源码：
  
      ```java
      public static ExecutorService newCachedThreadPool() {
          return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                        60L, TimeUnit.SECONDS,
                                        new SynchronousQueue<Runnable>());
      }
      ```
  
    - 解释：
  
      没用核心线程，最大线程数无限，线程60秒没任务干就停止 ，等待队列用直接握手队列SynchronousQueue，任务直接交给线程执行不会保存
  
  - newScheduledThreadPool **用于需要多个后台线程执行周期任务，同时需要限制线程数量的场景**
  
    - 源码：
  
      ```java
      public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
          return new ScheduledThreadPoolExecutor(corePoolSize);
      }
      public ScheduledThreadPoolExecutor(int corePoolSize) {
          super(corePoolSize, Integer.MAX_VALUE,
                DEFAULT_KEEPALIVE_MILLIS, MILLISECONDS,
                new DelayedWorkQueue());
      }
      private static final long DEFAULT_KEEPALIVE_MILLIS = 10L;
      ```
  
    - 解释：
  
      ScheduledThreadPoolExecutor继承自ThreadPoolExecutor，使用优先级队列DelayedWorkQueue，运行时间短的任务先执行，否则先等待的先执行
  
  - newSingleThreadScheduledExecutor **用于需要后台单线程执行周期任务**
  
    - 解释：
  
      单线程执行版的newScheduledThreadPool ，保证任务串行执行，保证串行返回


![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/threadpool.jpg)

#### synchronized关键字

- 作用：
  - 同步
  - 可见性

- 使用方式
  - 获取对象锁
    - 同步代码块: 指定加锁对象，对给定对象加锁
      - synchronized(this){}
    - 同步非静态方法: 作用于当前对象实例加锁，进入同步代码前要获得当前对象实例的锁
      - public synchronized void methodA(){}
  - 获取类锁
    - 同步代码块: 指定加锁的类，对给定类加锁
      - synchronized(类名.class){}
    - 同步静态方法: 作用于当前对象实例加锁，进入同步代码前要获得当前对象实例的锁
      - public synchronized  static void methodA(){}
- 实现方式
  - 同步代码块：使用了monitorenter和monitorexit指令
  - 同步方法：通过方法修饰符上的ACC_AYNCHRONIZED实现
  - monitorexit结束时会把更新直接刷入主内存
- JVM中锁升级流程
  
  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/synchronized.png)

#### volatile关键字

- 作用：
  - 保证数据线程可见性
  - 避免指令重排
- 实现：
  - 在字节码中加入了 lock 指令：
    - 锁总线，其它CPU对内存的读写请求都会被阻塞，直到锁释放，**不过实际后来的处理器都采用锁缓存替代锁总线**，因为锁总线的开销比较大，锁总线期间其他CPU没法访问内存，通过缓存一致性协议确保拿到缓存值是最新的
    - lock后的写操作会把已修改的数据写回内存，同时让其它线程相关缓存行失效，从而重新从主存中加载最新的数据
    - 不是内存屏障却能完成类似内存屏障的功能，阻止屏障两边的指令重排序

#### 如何终止线程

- stop方法（别用）
  - 立刻终止线程，过于粗鲁
  - 清理工作可能完成不了
  - 会立即释放锁，有可能引起线程不同步
- interrupt方法
  - 阻塞状态下会推出阻塞状态，抛出InterruptedException；运行状态下设置中断标志位为true，继续运行，线程自行检查标志位主动终止，相对温柔

#### 线程如何通信

线程的通信是指线程之间以何种机制来交换信息，在编程中，线程之间的通信机制有两种，共享内存和消息传递

- 共享内存：线程之间共享程序的公共状态，线程之间通过写-读内存中的公共状态来隐式进行通信，典型的共享内存通信方式就是通过共享对象进行通信
- 消息传递：线程之间没有公共状态，线程之间必须通过明确的发送消息来显式进行通信，在java中典型的消息传递方式就是wait()和notify()

#### notify方法和notifyAll方法的区别

当调用wait方法后，线程会被放到对象内部的等待池中，在等待池中的线程不会去竞争CPU，只有调用Notify或者NotifyAll才会从等待池中，放入锁池中，等待对象锁的释放从而竞争CPU以执行。

- notify从等待池中随机选一个线程放入锁池
- notifyAll把所有等待池全放入锁池

#### Java中sleep方法和wait方法的区别

- sleep
  - Thread类方法
  - 让出CPU，不改变锁状态
  - 任意位置执行

- wait
  - Object类方法
  - 让出CPU，释放当前占用的锁
  - 只能在synchronized中的中使用

#### ThreadLocal

- 作用
  - 主要解决的就是让每个线程绑定自己的值，可以将ThreadLocal类形象的比喻成存放数据的盒子，盒子中可以存储每个线程的私有数据
- 实现
  - 数据结构
    - Map
  - Thread 类中有一个 threadLocals 和 一个 inheritableThreadLocals 变量，它们都是 ThreadLocalMap类型的变量,我们可以把 ThreadLocalMap 理解为ThreadLocal类实现的定制化的 HashMap,默认情况下这两个变量都是null
  - 最终的变量是放在了当前线程的 ThreadLocalMap 中，并不是存在 ThreadLocal 上，ThreadLocal 可以理解为只是ThreadLocalMap的封装，传递了变量值
- 问题
  - 内存泄露
    - 原因
      - ThreadLocalMap 中使用的 key 为 ThreadLocal 的弱引用,而 value 是强引用
      - 如果 ThreadLocal 没有被外部强引用的情况下，在垃圾回收的时候会 key 会被清理掉，而 value 不会被清理掉。这样一来，ThreadLocalMap中就会出现key为null的Entry。假如我们不做任何措施的话，value 永远无法被GC 回收
    - 解决方案
      - 使用完 ThreadLocal方法后 最好手动调用remove()方法

#### 安全发布对象

- 概念
  - 发布对象：使一个对象能被当前范围之外的代码所使用
  - 对象溢出：一种错误的发布。当一个对象还没有构造完成时，就使它被其他线程所见
- 如何安全发布对象
  - 在静态初始化函数中初始化一个对象引用
  - 将对象的引用保存到volatile类型域或者AtomicReference对象中
  - 将对象的引用保存到某个正确构造对象的final类型域中
  - 将对象的引用保存到一个由锁保护的域中

#### final语义

- 用 final 修饰的类不可以被继承
- 用 final 修饰的方法不可以被覆写
- 用 final 修饰的属性一旦初始化以后不可以被修改
- 如果一个对象**完全初始化**以后，一个线程持有该对象的引用，那么这个线程一定可以看到正确初始化的 final 属性的值（也就是不加final可能看到的是默认的0值）
- final 属性的 freeze 操作发生于被调用的构造方法结束的时候
- final 属性可以通过反射和其他方法来改变

#### JDBC连接数据库步骤

- 加载JDBC驱动程序

- ###### 拼接JDBC需要连接的URL

- ###### 创建数据库的连接

- ###### 创建一个Statement

- ###### 执行SQL语句

- ###### 处理执行完SQL之后的结果

- ###### 关闭使用的JDBC对象

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/jdbc.png)

#### 数据库连接池

- 功能
  - 连接池的建立
    - 在系统初始化时，依照系统配置来创建连接池，并在池中建立几个连接对象，以便使用时获取。连接池中的连接不允许随意建立和关闭，避免系统开销。
  - 连接的使用和管理
    - 当客户请求数据库连接时，首先查看连接池中是否有空闲连接，如果存在空闲连接，则将连接分配给客户使用；如果没有空闲连接，则查看当前所开的连接数是否已经达到最大连接数，如果没达到就重新创建一个连接给请求的客户；如果达到就按设定的最大等待时间进行等待，如果超出最大等待时间，则抛出异常给客户
    - 当客户释放数据库连接时，先判断该连接的引用次数是否超过了规定值，如果超过就从连接池中删除该连接，否则保留为其他客户服务。
  - 连接池的关闭
    - 当系统或者应用关闭时，关闭连接池，释放所有连接。 

- 优势
  -  资源复用 
    -  由于数据库连接得到重用，避免了频繁创建、释放连接引起的大量性能开销。在减少系统消耗的基础上，另一方面也增进了系统运行环境的平稳性（减少内存碎片以及数据库临时进程/线程的数量） 
  -  更快的系统响应速度 
    -  数据库连接池在初始化过程中，往往已经创建了若干数据库连接至于池中备用。此时连接的初始化工作均已完成。对于业务请求处理而言，直接利用现有可用连接，避免了数据库连接初始化和释放过程的时间，从而缩减了系统整体响应时间 
  -  统一的连接管理，避免数据库连接泄漏 
    -  在较为完备的数据库连接池实现中，可根据预先的连接占用超时设定，强制收回被占用连接。从而避免了常规数据库连接操作中可能出现的资源泄漏 
- 常用实现
  - dhcp
  - c3p0
  - druid

#### 注解

- 作用
  - 再编译，构建或者运行阶段提供一些元数据，不影响正常运行逻辑
- 自定义注解
  - @Retention	指定生命周期
    - RetentionPolicy.RUNTIME：运行时可以被反射捕获到
    -  RetentionPolicy.CLASS：注解会保留在.class字节码文件中，这是注解的默认选项，运行中获取不到
    -  RetentionPolicy.SOURCE：只在编译阶段有用，不被保存到class文件中
  - @Target     指定注解可以加在哪里
    - ElementType.ANNOTATION_TYPE：只能用于定义其他注解
    - ElementType.CONSTRUCTOR
    - ElementType.FIELD
    - ElementType.LOCAL_VARIABLE
    - ElementType.METHOD
    - ElementType.PACKAGE
    - ElementType.PARAMETER
    - ElementType.TYPE： 可以是类、接口、枚举或注释 
  - @Inherited    使用了注解的类的子类会继承这个注解
  - @Documented     用于在JavaDoc中生成

### JVM

#### 如何分析jvm线程堆栈

```bash
# 查运行中的java应用
root@64b47b31317a:/# jps -ml
1 /app.jar --spring.profiles.active=pro
116 sun.tools.jps.Jps -ml
# 根据第一列的PID找出 load比较高的应用PID
top -p <pids>
root@64b47b31317a:/# top -p 1
# dump线程堆栈信息
jstack <pid>
root@64b47b31317a:/# jstack 1
"lettuce-eventExecutorLoop-1-3" #33 daemon prio=5 os_prio=0 tid=0x00007fe394367000 nid=0x24 waiting on condition [0x00007fe376bd3000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
省略若干
# 查看java.lang.Thread.State状态
```

#### 四种引用类型

- 强引用
  - 最普遍的引用：Object obj = new Object();
  - 宁可抛出OOM异常也不会回收有强引用的对象
  - 通过将对象设置为null，使其被回收（栈pop中用到）
- 软引用
  - 对象处在有用但是非必须的状态
  - 只有内存空间不足才回收
  - 可以用来实现高速缓存
- 弱引用
  - 对象处在有用但是非必须的状态，比软引用更没用一点
  - GC时会被回收
  - 适用于偶尔使用且不希望影响垃圾收集的对象
- 虚引用
  - 不会决定对象生命周期
  - 任何时候会被回收
  - 用于跟踪GC活动，起哨兵作用
  - 必须与引用队列ReferenceQueue联合使用

#### 常用的垃圾收集器

- 年轻代
  - Serial收集器（-XX:+UseSerialGC，复制算法）
    - 单线程，进行回收时，必须停止所有工作线程
    - 简单高效，Client模式下默认的年轻代收集器 
  - ParNew收集器（-XX:+UseParNewGC，复制算法）
    - 多线程并行，其他类似Serial收集器
    - 多核下优势
  - Parallel收集器（-XX:+UseParallelGC，复制算法）
    - 多线程并行，更关注性能，吞吐量，而不是GC停顿
    - 多核下优势，Server模式下默认的年轻代收集器
- 老年代
  - Serial Old收集器（-XX:+UseSerialOldGC，标记-整理算法）
    - 单线程，进行回收时，必须停止所有工作线程
    - 简单高效，Client模式下默认的老年代收集器 
  - Parallel Old收集器（-XX:+UseParallelOldGC，标记-整理算法）
    - 多线程并行，其他类似Serial Old收集器
    - 多核下优势
  - CMS收集器（-XX:+UseConcMarkSweepGC，标记-清除算法）
    - 多线程并发
- 通用
  - G1收集器（-XX:+UseG1GC，复制+标记-整理算法）
    - 分代收集
    - 空间整合
    - 可预测的停顿
    - 多线程并发
    - 将Heap堆内存划分成多个大小相等的Region
    - 年轻代和老年代不再物理隔离

#### CMS收集器执行步骤

- 初始阶段：stop-the-world
- 并发标记：并发追溯标记，程序不停顿
- 并发预清理：查找并发标记阶段从新生代晋升老年代的对象
- 重新标记：stop-the-world，扫描CMS堆中的剩余对象
- 并发清理：清理垃圾对象，程序不停顿
- 并发重置：重置CMS收集器的数据结构，程序不停顿

#### JVM常用调优参数

- -Xss: 规定每个线程虚拟机栈的大小
- -Xms: 堆的初始值
- -Xmx: 堆能扩展的最大值
- -XX:SurvivorRatio：Eden区和其中一个Survivor区的比值
- -XX:NewRatio：老年代和新生代比值
- -XX:MaxTenuringThreshold：对象从年轻代进入老年代经历过GC次数的阈值

#### JVM常用的垃圾回收算法

- 标记-清除算法
  - 缺点：容易产生碎片化
- 复制算法（适用与对象存活率低的场景）
  - 优点：不会碎片化
  - 缺点：浪费50%空间
- 标记-整理算法（适用于对象存活率高场景）
  - 优点：标记清除的加强版，不会碎片化
  - 缺点：性能差一点
- 分代收集算法
  - Minor GC：使用复制算法处理年轻代（eden区8/10，from survivor区1/10，to survivor区1/10），默认经历15次Minor GC仍然存活就进老年代，执行条件如下：
    - 年轻代满了执行
    - Full GC触发时也会执行
  - Full GC：主要使用标记-整理算法处理老年代（老年代默认是年轻代的两倍），执行条件如下：
    - 老年代满了执行
    - 使用CMS垃圾收集器时候，出现promotion failed或concurrent mode failed时候也会执行
    - 调用System.gc()后的某个时刻
    - 使用RMI时，一般每小时执行一次GC

#### 何时真正开始Full GC（stop-the-world）

程序到达安全点，安全点是对象引用关系不会变化的点，例如方法调用，循环跳转，异常跳转等

#### GC如何标记垃圾对象

没有被任何其他对象引用的对象被视为垃圾。

问1：JavaGC中如何判断对象是否被引用

答1：GC中主要有两种引用判断方法

- 引用计数法
  - 优点：执行效率高
  - 缺点：无法检测出循环引用情况，导致内存泄漏
- 可达性分析法（主流）

问2：可达性分析中，哪些对象可作为GC root

答2：

- 虚拟机栈中变量表引用的对象
- 方法区中常量引用的对象
- 方法区中类静态属性引用的对象
- 本地方法栈中JNI引用的对象
- 活跃线程的引用对象

#### String.intern()的用法

- 作用
  - 直接使用双引号声明出来的`String`对象会直接存储在常量池中。
  - 如果不是用双引号声明的`String`对象，可以使用`String`提供的`intern`方法同步到常量池中。intern 方法会从字符串常量池中查询当前字符串是否存在，若不存在就会将当前字符串放入常量池StringTable中，StringTable默认大小1009，可以通过参数修改 -XX:StringTableSize=123456...
  
- 区别
  - jdk6之前包括jdk6，intern方法会在常量池中创建相同String对象
  - jdk7开始，intern只会把堆中String对象的引用放入常量池中，主要原因是常量池从永久代已移入堆中
  
- 案例

  - ```java
    String s = new String("1");
    s.intern();
    String s2 = "1";
    System.out.println(s == s2);
    
    String s3 = new String("1") + new String("1");
    s3.intern();
    String s4 = "11";
    System.out.println(s3 == s4);
    
    // 打印结果是
    // jdk6 下false false
    // jdk7 下false true
    ```

  - 分析：“1”会在常量池中新建一个1，然后又new了一个String对象赋值给s，调用s.intern()因为1已经在常量池中存在，所以不起效果，所以s和s1持有两个不同的引用。然后拼接两个1，创建出s3，此时常量池中不存在11，调用s3.intern()后，jdk6，会去常量池中新建一个11，而从jdk7开始，直接在常量池中创建一个保存s3地址的引用

#### JVM内存模型（jdk8）

- 线程私有
  - 程序计数器，唯一不会OOM的区域
  - 虚拟机栈
    - 局部变量表
    - 操作栈
    - 动态链接
    - 返回地址
  - 本地方法栈
- 线程共享 
  - Metadata元空间
    - 本地内存存放Class对象
  - heap堆
    - 常量池
    - 实例对象

#### Java内存模型（JMM）

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/jmm.png)

#### Happens-Before原则

保证单线程执行的内存可见性，多线程不能保证

- 程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作
- 监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁
- volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读
- 传递性：如果A happens-before B，且B happens-before C，那么A happens-before C
- start()规则：如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作happens-before于线程B中的任意操作
- join()规则：如果线程A执行操作ThreadB.join()并成功返回，那么线程B中的任意操作happens-before于线程A从ThreadB.join()操作成功返回
- 线程中断规则:对线程interrupt方法的调用happens-before于被中断线程的代码检测到中断事件的发生

#### 指令重排

在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序

- 可以通过内存屏障避免重排序（volatile的实现类似内存屏障）
- 如果指令执行顺序不会破坏Happens-Before原则，JVM就有可能对指令重排

#### 类加载双亲委派机制

- 从底向上检查ClassLoader中类是否加载
- 从顶向下调用ClassLoader加载类

#### 类加载器ClassLoader种类

- BootStrapClassLoader：C++编写，加载核心库java.*
- ExtClassLoader：Java编写，加载扩展库javax.*
- AppClassLoader：Java编写，加载程序所在目录classpath
- CustomClassLoader：Java编写，定制化加载

#### Java从编写到运行的大致过程

- 将写好的.java文件通过javac调用编译器生成JVM可识别指令组成的.class文件（IED可以自动反编译.class文件，也可以通过javap -v 反编译）
- 通过ClassLoader分三步加载，连接（验证，准备，解析）和初始化 将.class文件加载到JVM中生成Class类
- 然后用加载的Class类经过内存分配，初始化，init调用构造创建出对象
- 最后有了对象就可以执行相关方法了

#### 不可变对象

- 对象创建之后状态不能修改

- 对象的所有的域都是final类型

- 对象是正确创建的（对象创建过程中，this引用没用逃逸）

#### 如何安全发布对象

- 在静态初始化函数中初始化一个对象引用

- 将对象的引用保存到正确的构造对象的final类型域中

- 将对象的引用保存到一个由锁保护的域中

- 将对象的引用用volatile关键字修饰，或者保存到AtomicReference对象中


#### 为什么双检查单例模式实例引用不加volatile不是线程安全的

- 对象发布主要有三步 1.分配内存空间 2初始化对象 3引用指向分配的内存

- 由于指令重排的存在，可能出现132的顺序，多线程环境下，可能出现 instance != null  但是初始化工作还没完成的情况在占有锁的线程没有完成初始化时，另一个线程认为以及初始化完毕了去使用对象的时候便会有问题

- 加上 volatile 关键字就可以解决指令重排的问题

#### JVM内存泄漏情景

- 类似于栈，内存的管理权不属于JVM而属于栈本身，所有被pop掉的index上还存在着过期的引用Stack.pop()的源码中手动清除了过期引用
elementData[elementCount] = null; /* to let gc do its work

- 将对象引用放入了缓存，可以用WeakHashMap作为引用外键

- 监听器和其他回调，可以用WeakHashMap作为引用外键



## JavaEE

### Spring

#### 什么是IoC和DI

- IoC（控制反转），控制反转是把传统上由程序代码直接操控的对象的调用权交给IoC容器，通过IoC容器来实现对象组件的依赖注入，依赖检查，自动装配等对象生命周期管理
- DI（依赖注入）主要是遵循设计模式中依赖倒转原则中的“高层模块不应该依赖底层模块，两个都应该抽象依赖”，依赖注入的方式主要包括，setter方法，interface接口，constructor构造函数，annotation注解


![Spring Ioc容器](https://cdn.jsdelivr.net/gh/freshchen/resource/img/spring-ioc.PNG)

#### BeanFactory和ApplicationContext

BeanFactory和ApplicationContext是Spring的两大核心接口，都可以当做Spring的容器，ApplicationContext是BeanFactory的子接口

- **BeanFactory**
  - 是Spring里面最底层的接口，包含了各种Bean的定义，读取bean配置文档，管理bean的加载、实例化，控制bean的生命周期，维护bean之间的依赖关系
  - BeanFactroy采用的是延迟加载形式来注入Bean的，即只有在使用到某个Bean时(调用getBean())，才对该Bean进行加载实例化
- **ApplicationContext**
  - ApplicationContext接口作为BeanFactory的派生，除了提供BeanFactory所具有的功能外，还提供了更完整的框架功能
    - 继承MessageSource，因此支持国际化。
    - 统一的资源文件访问方式。
    - 提供在监听器中注册bean的事件。
    - 同时加载多个配置文件。
    - 载入多个（有继承关系）上下文 ，使得每一个上下文都专注于一个特定的层次，比如应用的web层。
  - 在容器启动时，一次性创建了所有的Bean

#### Bean的五种作用域

- singleton：单例模式，在整个Spring IoC容器中，使用singleton定义的Bean将只有一个实例，Spring容器启动时就生成了
- prototype：原型模式，每次通过容器的getBean方法获取prototype定义的Bean时，都将产生一个新的Bean实例，Spring容易启动时没用生成
- request：对于每次HTTP请求，使用request定义的Bean都将产生一个新实例，即每次HTTP请求将会产生不同的Bean实例。只有在Web应用中使用Spring时，该作用域才有效
- session：对于每次HTTP Session，使用session定义的Bean豆浆产生一个新实例。同样只有在Web应用中使用Spring时，该作用域才有效
- globalsession：每个全局的HTTP Session，使用session定义的Bean都将产生一个新实例。典型情况下，仅在使用portlet context的时候有效。同样只有在Web应用中使用Spring时，该作用域才有效

#### Bean的生命周期

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/spring-bean-lifecycle.png)

- 读取XML或者注解，注册到Spring容器中，然后通过工厂或者自定义动态工厂去创建Bean
- BeanPostProcessor 加入一些增强功能，相当于动态代理



#### AOP（面向切面编程）基础

- **通知(Advice)**

  通知定义了在切入点代码执行时间点附近需要做的工作。

  - Spring支持五种类型的通知：
    - **前置通知[Before advice]**：在连接点前面执行，前置通知不会影响连接点的执行，除非此处抛出异常
    - **正常返回通知[After returning advice]**：在连接点正常执行完成后执行，如果连接点抛出异常，则不会执行
    - **异常返回通知[After throwing advice]**：在连接点抛出异常后执行
    - **返回通知[After (finally) advice]**：在连接点执行完成后执行，不管是正常执行完成，还是抛出异常，都会执行返回通知中的内容
    - **环绕通知[Around advice]**：环绕通知围绕在连接点前后，比如一个方法调用的前后。这是最强大的通知类型，能在方法调用前后自定义一些操作。环绕通知还需要负责决定是继续处理join point(调用ProceedingJoinPoint的proceed方法)还是中断执行

- **连接点(Joinpoint)**

  程序能够应用通知的一个“时机”，这些“时机”就是连接点，例如方法调用时、异常抛出时、方法返回后等等

- **切入点(Pointcut)**

  通知定义了切面要发生的“故事”，连接点定义了“故事”发生的时机，那么切入点就定义了“故事”发生的地点，例如某个类或方法的名称，Spring中允许我们方便的用正则表达式来指定。

- **切面(Aspect)**

  通知、连接点、切入点共同组成了切面：时间、地点和要发生的“故事”

- **引入(Introduction)**

  引入允许我们向现有的类添加新的方法和属性(Spring提供了一个方法注入的功能）

- **目标(Target)**

  即被通知的对象，如果没有AOP，那么通知的逻辑就要写在目标对象中，有了AOP之后它可以只关注自己要做的事，解耦合

- **代理(proxy)**

  应用通知的对象，详细内容参见设计模式里面的动态代理模式

- **织入(Weaving)**

  把切面应用到目标对象来创建新的代理对象的过程，aop织入的三种方式:

  - 编译时：当一个类文件被编译时进行织入，这需要特殊的编译器才可以做的到，例如AspectJ的织入编译器；

  - 类加载时：使用特殊的ClassLoader在目标类被加载到程序之前增强类的字节代码；

  - 运行时：切面在运行的某个时刻被织入,SpringAOP就是以这种方式织入切面的，Spring默认使用了JDK的动态代理技术，如果没有实现接口则转为使用Cglib

#### Spring事务

Spring事务的本质其实就是数据库对事务的支持，没有数据库的事务支持，spring是无法提供事务功能的。真正的数据库层的事务提交和回滚是通过binlog或者redo log实现的

- **Spring事务的种类**
  - 编程式事务管理使用TransactionTemplate
  - 声明式事务管理建立在AOP之上的。其本质是通过AOP功能，对方法前后进行拦截，将事务处理的功能编织到拦截的方法中，也就是在目标方法开始之前加入一个事务，在执行完目标方法之后根据执行情况提交或者回滚事务
- **spring的事务传播行为**
  - PROPAGATION_REQUIRED：如果当前没有事务，就创建一个新事务，如果当前存在事务，就加入该事务，该设置是最常用的设置
  - PROPAGATION_SUPPORTS：支持当前事务，如果当前存在事务，就加入该事务，如果当前不存在事务，就以非事务执行
  - PROPAGATION_MANDATORY：支持当前事务，如果当前存在事务，就加入该事务，如果当前不存在事务，就抛出异常
  - PROPAGATION_REQUIRES_NEW：创建新事务，无论当前存不存在事务，都创建新事务
  - PROPAGATION_NOT_SUPPORTED：以非事务方式执行操作，如果当前存在事务，就把当前事务挂起
  - PROPAGATION_NEVER：以非事务方式执行，如果当前存在事务，则抛出异常
  - PROPAGATION_NESTED：如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则按REQUIRED属性执行
- **Spring中的隔离级别**
  - ISOLATION_DEFAULT：这是个 PlatfromTransactionManager 默认的隔离级别，使用数据库默认的事务隔离级别
  - ISOLATION_READ_UNCOMMITTED：读未提交，允许另外一个事务可以看到这个事务未提交的数据
  - ISOLATION_READ_COMMITTED：读已提交，保证一个事务修改的数据提交后才能被另一事务读取，而且能看到该事务对已有记录的更新
  -  ISOLATION_REPEATABLE_READ：可重复读，保证一个事务修改的数据提交后才能被另一事务读取，但是不能看到该事务对已有记录的更新
  - ISOLATION_SERIALIZABLE：一个事务在执行的过程中完全看不到其他事务对数据库所做的更新



### SpringMVC

#### SpringMVC请求处理流程

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/springmvc.png)

-  用户发送请求至前端控制器DispatcherServlet
- DispatcherServlet收到请求调用HandlerMapping处理器映射器。
- 处理器映射器根据请求url找到具体的处理器，生成处理器对象及处理器拦截器(如果有则生成)一并返回给DispatcherServlet。
- DispatcherServlet通过HandlerAdapter处理器适配器调用处理器
- HandlerAdapter执行处理器(handler，也叫后端控制器)。
- Controller执行完成返回ModelAndView
- HandlerAdapter将handler执行结果ModelAndView返回给DispatcherServlet
- DispatcherServlet将ModelAndView传给ViewReslover视图解析器
- ViewReslover解析后返回具体View对象
- DispatcherServlet对View进行渲染视图（即将模型数据填充至视图中）。
- DispatcherServlet响应用户

#### SpringMvc的控制器是不是单例模式是不是线程安全

- 是单例模式,所以在多线程访问的时候有线程安全问题
- 不要用同步,会影响性能,解决方案把控制器变为无状态对象
- 如果一定有成员变量，可以增加注解@Scope(value = "prototype")改为原型模式

#### 如何解决跨域

- CORS
  - 通过实现Spring MVC中的拦截器HandlerInterceptor 加上跨域需要的请求头

### MyBatis

#### 执行流程

- 通过XML配置
  - 创建SqlSessionFactory
    - SqlSessionFactoryBuilder通过XPathParser解析主配置文件
      - SqlSessionFactoryBuilder和配置文件是一对一的，只能解析一次
      - 解析完成之后配置文件信息保存在了Configuration对象实例
      - 将configuration交给DefaultSqlSessionFactory创建实例
    - 获取SqlSession
        - SqlSessionFactory从configuration中拿到执行器类型
        - 然后openSessionFromDataSource生成DefaultSqlSession
            - 获取environment（数据库连接地址用户密码等）
            - 获取transactionFactory
            - 创建一个事务
            - 用上面创建的事务，以及传入的执行器类型创建执行器executor
            - 最后根据executor，configuration，是否自动提交创建DefaultSqlSession
    - 有了SqlSession就可以向数据库发送请求了
        - 根据传入的ID到mapping配置文件中找到要执行的sql语句模板
        - executor依靠MapperStatement对象将复制内容与sql动态占位符绑定，创建出Statement
    - SqlSession提交事务
        - 根据dirty属性决定提交还是回滚
    - 关闭SqlSession

#### 匹配符$和#的区别

- # 
  - 可以防止sql注入，值不是直接放在语句中而是用占位符?
  - 只在条件例如where语句中起作用
- $
  - 可以用于动态sql，值是直接嵌入到sql中的
  - 不能防止sql注入

#### ResultType和ResultMap

都是用于映射sql返回结果，数据库表中字段与Entity字段的映射

- ResultType
  - 两边字段名一致
- ResultMap
  - 两变字段名可以不一致，显示指定对应关系
  - 还可以添加构造，生成数据库中没有的字段的数据

### JOOQ

是一款ORM框架

- 作用
  - 基于流式的api操作数据库，提供自动生成表结构功能，支持生成sql，执行sql，解析sql执行结果

### SpringBoot

[纯洁的微笑](http://www.ityouknow.com/spring-boot.html)

#### 启动流程

[link](https://www.cnblogs.com/shamo89/p/8184960.html)

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/springboot-start.png)

- 注解

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/springboot-start-1.png)

- SpringApplication.run()

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/springboot-start-2.png)

### Netty

#### Netty的特点

- 一个高性能、异步事件驱动的NIO框架，它提供了对TCP、UDP和文件传输的支持
- 使用更高效的socket底层，对epoll空轮询引起的cpu占用飙升在内部进行了处理，避免了直接使用NIO的陷阱，简化了NIO的处理方式。
- 采用多种decoder/encoder 支持，对TCP粘包/分包进行自动化处理
- 可使用接受/处理线程池，提高连接效率，对重连、心跳检测的简单支持
- 可配置IO线程数、TCP参数， TCP接收和发送缓冲区使用直接内存代替堆内存，通过内存池的方式循环利用ByteBuf
- 通过引用计数器及时申请释放不再引用的对象，降低了GC频率
- 使用单线程串行化的方式，高效的Reactor线程模型
- 大量使用了volitale、使用了CAS和原子类、线程安全类的使用、读写锁的使用

#### Netty执行流程

- 当客户端网络I/O请求来了就需要为其通过**Bootstrap**创建一个**Channel**，**Channel**是一个Socket的抽象
- 在创建过程中**Channel**会去**EventLoopGroup**中申请注册一个**EventLoop**，**Channel**和**EventLoopGroup**是多对一的关系，**EventLoop**对应一个Reactor线程模型
- 注册完成后**Channel**就可以执行**ChannelpipeLine**中的任务了
- **ChannelpipeLine**由各种Handler组成，主要有**ChannelInboundHandler**（读）和**ChannelOutboundHandler**（写），通过**HandlerContext**管理，各大Handler可以通过**ByteBuf**操作数据

### Vert.x

#### 官网笔记

- 流式API
- 事件驱动
- Reactor模型，不同于node.js，可以支持多Reactor，充分利用CPU
- EventLoop中不要使用阻塞方法，有专门的方式兼容运行阻塞代码
- 异步结果可以组合，或者构成链式结构
- Verticle
  - 推荐的开发方式，便于并发，部署，扩展
  - 一个Vert.x实例默认维护N个event loop threads (where N by default is core*2) 
  - 支持多语言
  - 同一个Vert.x实例上运行多个Verticle构成一个应用，Verticle之间通过event bus联系
  - 三种类型
    - Standard Verticles：常用，通过event loop thread执行
    - Worker Verticles：通过worker pool执行，单线程
    - Multi-threaded worker verticles：通过worker pool执行，多线程
  - 可以设置不同的上下文context 
  - 支持定时器
- Event Bus事件总线
  - 很简单的绑定消息传递的地址
  - Handlers和Adress可以是一对一，一对多或者多对多的
  - 支持消息订阅模式
  - 支持点对点，以及传统的请求响应模式
  - 消息有可能丢失，需要自己实现幂等，通过重试等方式
  - 支持String，buffer，json消息格式，当然也可以自己定义格式通过codec
  - 不止可以单点，也可以作为集群总线

## 数据库

### Mysql

#### 基本架构

MySQL 主要分为 Server 层和存储引擎层

- **Server 层**：主要包括连接器、查询缓存、分析器、优化器、执行器等，所有跨存储引擎的功能都在这一层实现，比如存储过程、触发器、视图，函数等，还有一个通用的日志模块 binglog 日志模块。
- **存储引擎**： 主要负责数据的存储和读取，采用可以替换的插件式架构，支持 InnoDB、MyISAM、Memory 等多个存储引擎，其中 InnoDB 引擎有自有的日志模块 redolog 模块。**现在最常用的存储引擎是 InnoDB，它从 MySQL 5.5.5 版本开始就被当做默认存储引擎了。**
- **组件介绍**
  - **连接器：** 身份认证和权限相关(登录 MySQL 的时候)
  - **查询缓存:**  执行查询语句的时候，会先查询缓存（MySQL 8.0 版本后移除，因为这个功能不太实用）
  - **分析器:**  没有命中缓存的话，SQL 语句就会经过分析器，分析器说白了就是要先看你的 SQL 语句要干嘛，再检查你的 SQL 语句语法是否正确
  - **优化器：** 按照 MySQL 认为最优的方案去执行
  - **执行器:**  执行语句，然后从存储引擎返回数据



![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/mysql-fw.png)

#### SQL执行过程

- 查询等过程如下：
  - 权限校验---》查询缓存---》分析器---》优化器---》权限校验---》执行器---》引擎
- 更新等语句执行流程如下
  - 分析器----》权限校验----》执行器---》引擎---redo log prepare---》binlog---》redo log commit

#### MyISAM和InnoDB区别

- **是否支持行级锁** : MyISAM 只有表级锁(table-level locking)，而InnoDB 支持行级锁(row-level locking)和表级锁,默认为行级锁。

- **是否支持事务和崩溃后的安全恢复： MyISAM** 强调的是性能，每次查询具有原子性,其执行速度比InnoDB类型更快，但是不提供事务支持。但是**InnoDB** 提供事务支持事务，外部键等高级数据库功能。 具有事务(commit)、回滚(rollback)和崩溃修复能力(crash recovery capabilities)的事务安全(transaction-safe (ACID compliant))型表。

- **是否支持外键：** MyISAM不支持，而InnoDB支持。

- **是否支持MVCC** ：仅 InnoDB 支持。应对高并发事务, MVCC比单纯的加锁更高效;MVCC只在 READ COMMITTED 和 REPEATABLE READ 两个隔离级别下工作;MVCC可以使用 乐观(optimistic)锁 和 悲观(pessimistic)锁来实现;各数据库中MVCC实现并不统一

#### 数据库事务四大特性

- 原子性（Atomic）要么全做要么全不做
- 一致性（Consistency）数据要保持完整性，从一个一致状态到另一个一致状态，执行事务前后，多个事务对同一个数据读取的结果是相同的
- 隔离性（Isolation）一个事务的执行不影响其他事务
- 持久性（Durability）事务一旦提交，变更应该永久的保存到数据库中

#### 事务隔离级别

|隔离级别|脏读|不可重复读|幻读|
|---|---|---|---|
|未提交读（Read uncommitted）  |可能	|可能	|可能|
|已提交读（Read committed）	|不可能	|可能	|可能|
|可重复读（Repeatable read）	|不可能	|不可能	|可能|
|可串行化（Serializable）	|不可能	|不可能	|不可能|

- Read uncommitted会出现的现象--->脏读：**一个事务读取到另外一个事务未提交的数据 **
  - 例子：A向B转账，**A执行了转账语句，但A还没有提交事务，B读取数据，发现自己账户钱变多了**！B跟A说，我已经收到钱了。A回滚事务【rollback】，等B再查看账户的钱时，发现钱并没有多。
  - 出现脏读的本质就是因为**操作(修改)完该数据就立马释放掉锁**，导致读的数据就变成了无用的或者是**错误的数据**。
- Read committed出现的现象--->不可重复读：**一个事务读取到另外一个事务已经提交的数据，也就是说一个事务可以看到其他事务所做的修改**
  - 注：**A查询数据库得到数据，B去修改数据库的数据，导致A多次查询数据库的结果都不一样【危害：A每次查询的结果都是受B的影响的，那么A查询出来的信息就没有意思了】**
- Repeatable read避免不可重复读是**事务级别**的快照！每次读取的都是当前事务的版本，即使被修改了，也只会读取当前事务版本的数据
  - 至于虚读(幻读)：**是指在一个事务内读取到了别的事务插入的数据，导致前后读取不一致。**
    - 注：**和不可重复读类似，但虚读(幻读)会读到其他事务的插入的数据，导致前后读取不一致**
    - MySQL的Repeatable read隔离级别加上GAP间隙锁**已经大概率处理了幻读了**。

#### 常用存储引擎适用场景

- MyISAM适用频繁执行全表count，查询频率高，增删改频率不高

- InnoDB增删改查都频繁，对可靠性要求高，要求支持事务

#### 锁

- 粒度划分
  - **表锁**开销小，加锁快；不会出现死锁；锁定力度大，发生锁冲突概率高，并发度最低
  - **行锁**开销大，加锁慢；会出现死锁；锁定粒度小，发生锁冲突的概率低，并发度高
- InnoDB默认行锁，也支持表锁,没有用到索引的时候用表级锁
- MyISAM默认表锁
- 手动给表加锁 lock tables <table_name> <read|write> ， 解锁 unlock tables <table_name>
- 共享锁（S）：`SELECT * FROM table_name WHERE ... LOCK IN SHARE MODE`。
- 排他锁（X)：`SELECT * FROM table_name WHERE ... FOR UPDATE`
- InnoDB支持事务，关闭事务自动提交方法 set autocommit = 0

#### InnoDB锁种类

- 支持行锁表锁
- 行锁有三种实现
  - Record Lock：单个行记录上的锁。
  - Gap Lock：间隙锁，锁定一个范围，但不包括记录本身。GAP锁的目的，是为了防止同一事务的两次当前读，可能出现幻读的情况。因为索引结构是b+树所以最后叶子节点一层有序
  - Next-Key Lock：Record 和 Gap锁的合体，锁定一个范围，并且锁定记录本身。对于行的查询，都是采用该方法，主要目的是解决幻读的问题。

- 如果没有索引就直接上表锁

#### MVCC和事务的隔离级别

- 描述
  - 数据库事务有不同的隔离级别，不同的隔离级别对锁的使用是不同的，**锁的应用最终导致不同事务的隔离级别**
  - MVCC(Multi-Version Concurrency Control)多版本并发控制，可以简单地认为：**MVCC就是行级锁的一个变种(升级版)**。
  - 事务的隔离级别就是**通过锁的机制来实现**，只不过**隐藏了加锁细节**

- 特点
  - **MVCC一般读写是不阻塞的**(所以说MVCC很多情况下避免了加锁的操作)
  - MVCC实现的**读写不阻塞**正如其名：**多版本**并发控制--->通过一定机制生成一个数据请求**时间点的一致性数据快照（Snapshot)**，并用这个快照来提供一定级别（**语句级或事务级**）的**一致性读取**。从用户的角度来看，好像是**数据库可以提供同一数据的多个版本**。
    - 其中数据快照有**两个级别**：
      - 语句级 
        - 针对于Read committed隔离级别
      - 事务级别 
        - 针对于Repeatable read隔离级别

#### InnoDB 可重复读（Repeatable read）级别为什么可以大概率避免幻读

- 表象：快照读（非阻塞读不加锁，对应加锁的叫当前读）伪MVCC
- 内在：next-key锁（行锁 + gap锁）

#### Mysql事务日志

- 描述
  - 使用事务日志，存储引擎在修改表的数据时只需要修改其内存拷贝，再把该修改行为记录到持久在硬盘上的事务日志中，而不用每次都将修改的数据本身持久到磁盘
  - 事务日志采用的是追加的方式，因此写日志的操作是磁盘上一小块区域内的顺序I/O，而不像随机I/O需要在磁盘的多个地方移动磁头，所以采用事务日志的方式相对来说要快得多
  - 事务日志持久以后，内存中被修改的数据在后台可以慢慢地刷回到磁盘，所以修改数据需要写两次磁盘
- **回滚日志 -- Undo Log**
  - 描述
    - 保证事务的 **原子性**
    -  在 MySQL 中，恢复机制是通过回滚日志（`undo log`）实现的，所有事务进行的修改都会先记录到这个回滚日志中，然后在对数据库中的对应行进行写入
- **重做日志 -- Redo Log**
  - 描述
    - 保证事务的**持久性**
    - 重做日志由两部分组成，一是 **内存** 中的重做日志缓冲区，因为重做日志缓冲区在内存中，所以它是易失的，另一个就是在 **磁盘** 上的重做日志文件，它是持久的

#### MySQL Server 日志

- **binlog**
  - 描述
    - 是 Mysql sever 层维护的一种二进制日志，其主要是用来记录对 mysql 数据更新或潜在发生更新的 SQL 语句，并以"事务"的形式保存在磁盘中
  - 作用
    - 复制：MySQL Replication 在 Master 端开启 `binlog` ，Master 把它的二进制日志传递给 `slaves` 并回放来达到 `master-slave` 数据一致的目的
    - 数据恢复：通过 mysqlbinlog 工具恢复数据
    - 增量备份

#### SQL语句执行得很慢的原因

- 偶尔很慢
  - 数据库在刷新脏页
    - redolog写满了
    - 内存不够用了
    - MySQL 认为系统“空闲”的时候
    - MySQL 正常关闭的时候
  - 拿不到锁
    - 如果要判断是否真的在等待锁，我们可以用 **show processlist**
- 一直很慢
  - 没用到索引
  - 数据库选错了索引

#### SQL慢查询的优化

- 分析过程
  - 开启慢日志，查看慢日志，找到查询比较慢的语句
  - 使用explain分析sql
  - 分析结果中type字段，从好到坏是const、eq_reg、ref、range、index和all，是index和all就有问题需要优化
  - extra字段是Using filesort指用的外部索引例如文件系统索引等，Using temporary指用的临时表，这两种情况也需要优化
  - 使用show profile查看SQL执行时的底层 性能问题
- 解决
  - 没有索引可以试图建立索引，反复测试
    - 加索引 alter table <table-name> add index index_name(<column-name>)
    - 有时候优化器选择不一定准确，需要手动测试，强制使用某一个索引可以在sql语句中加入 force index(<column-name>)
    - 最后稳定之后再把不必要的索引删除 
  - 增加查询筛选的限制条件
  - 改写一些导致索引失效的SQL语句
  - 优化数据库结构 
    - 将字段很多的表分解成多个表 
    - 对于需要经常联合查询的表，可以建立中间表以提高查询效率
  - 分解关联查询
    - 将一个大的查询分解为多个小查询
  - 优化LIMIT分页
    - 筛选字段上加索引
    - 先查询出主键id值
    - **关延迟联**
    - 建立联合索引

#### 索引为什么能提高查询速度

- 不使用索引如和查询

  - Mysql最小存储结构是页，页是一个单链表把数据连在一起
  - 各个页通过双端链表连在一起
  - 查询时，我们要遍历双端链表找到数据所在的页，然后再在页中遍历找到对应的数据项

- 而我们使用索引时Innodb默认使用B+树实现如下效果，大大提高了效率

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/mysql-index.jpg)

#### Hash索引的局限性

- 哈希索引也没办法利用索引完成**排序**
- 不支持**最左匹配原则**
- 在有大量重复键值情况下，哈希索引的效率也是极低的---->**哈希碰撞**问题。
- **不支持范围查询**

#### 稀疏索引和聚集索引 

- 聚集索引
  - 指索引项的排序方式和表中数据记录排序方式一致的索引
  - 在叶子节点存储的是**表中的数据**
- 稀疏索引
  - 稀疏索引只为某些搜索码值建立索引记录；在搜索时，找到其最大的搜索码值小于或等于所查找记录的搜索码值的索引项，然后从该记录开始向后顺序查询直到找到为止
  - 叶子节点存储的是**主键和索引列**
- InnoDB 主键走聚集索引，其他走稀疏索引
- MyISAM 全是走稀疏索引

#### InnoDB聚集索引和普通索引有什么差异？ 

[好文](https://www.cnblogs.com/AbnerLc/p/11923242.html)

- InnoDB **聚集索引** 的叶子节点存储行记录，因此， InnoDB必须要有，且只有一个聚集索引：

　　　　（1）如果表定义了PK，则PK就是聚集索引；

　　　　（2）如果表没有定义PK，则第一个not NULL unique列是聚集索引；

　　　　（3）否则，InnoDB会创建一个隐藏的row-id作为聚集索引；

- InnoDB **普通索引** 的叶子节点存储主键值。

　　　　画外音：注意，不是存储行记录头指针，MyISAM的索引叶子节点存储记录指针。

#### 覆盖索引

- 回表
  - 当我们查询普通索引时，结果是主键的值，这时候就需要用主键值去查主键的索引树，这就是回表
- 当我们需要查询的列上都有索引时，我们需要查询的数据就已经全部拿到了，就不需要回表，大大提高了效率
- 如何实现覆盖索引
  - 可以通过把需要查的列建立联合索引
- 特征
  - explain的输出结果Extra字段为Using index时证明查询走了覆盖索引
  - explain的输出结果Extra字段为Using index condition时就没有用到覆盖索引，存在回表
- 使用场景
  - **全表count查询优化**
  - **列查询回表优化**
  - **分页查询**

#### 联合索引

- **最左匹配原则**
  - 索引只能用于查找key是否**存在（相等）**，遇到范围查询`(>、<、between、like`左匹配)等就**不能进一步匹配**了，后面的条件退化为线性查找
  - 例如创建 union index (a , b ,c)  查（a，b）走索引，查（a，c）走不了索引

#### 性能优化show profile 

- select @@profiling     查看是否开启性能分析 

- set profiling=1; 		开启
- show profiles;          看最近的执行大体情况
- show profile all for query <query_id>;              找到有问题的命令，然后用id查看详细信息

#### 大表优化

- 查询限定数据范围

  - 比如：我们当用户在查询订单历史的时候，我们可以控制在一个月的范围内

- 读写分离

  - 主库负责写，从库负责读

- 垂直拆分

  - 概述
    - 简单来说垂直拆分是指数据表列的拆分，把一张列比较多的表拆分为多张表
  - 优点
    - 可以使得列数据变小，在查询时减少读取的Block数，减少I/O次数。此外，垂直分区可以简化表的结构，易于维护
  - 缺点
    - 主键会出现冗余，需要管理冗余列，并会引起Join操作，可以通过在应用层进行Join来解决。此外，垂直分区会让事务变得更加复杂

- 水平拆分

  - 概述
    - 保持数据表结构不变，通过某种策略存储数据分片。这样每一片数据分散到不同的表或者库中，达到了分布式的目的。 水平拆分可以支撑非常大的数据量，**水平拆分最好分库**
  - 优点
    - 支持非常大的数据量存储，应用端改造也少
  - 缺点
    - 拆分会带来逻辑、部署、运维的各种复杂度大大提高，所以实际中使用逻辑上的分片方案来代替

  - 实际中使用的方案
    - **客户端代理：** **分片逻辑在应用端，封装在jar包中，通过修改或者封装JDBC层来实现。** 当当网的 **Sharding-JDBC** 、阿里的TDDL是两种比较常用的实现
    - **中间件代理：** **在应用和数据中间加了一个代理层。分片逻辑统一维护在中间件服务中。** 我们现在谈的 **Mycat** 、360的Atlas、 网易的DDB等等都是这种架构的实现

#### 集群

- 主从复制
  - 只保证HA，主服务器对外服务，从机只做备份，有点浪费
- mysql proxy读写分离
  - 可以让写操作去主服务器，从服务器只负责读，充分利用
- MyCat分库分表
  - 如何切分
    - id hash
    - 日期
    - id范围等等
  - 问题
    - 跨库join
      - 将不同库的join拆分成多个select
      - 建立全局表，每个库都有张相同的表
      - 冗余字段，不遵守三范式
      - E-R分片，将有关系的记录存储到一个库中 
    - 分布式事务，mycat支持的都不好
      - 强一致性，一般不用
      - 最终一致性
    - 分布式主键
      - redis incr 命令
      - 数据库生成
      - UUID
      - snowflake算法



#### 高性能实践的一些规范

[参考](https://mp.weixin.qq.com/s?__biz=Mzg2OTA0Njk0OA==&mid=2247485117&idx=1&sn=92361755b7c3de488b415ec4c5f46d73&chksm=cea24976f9d5c060babe50c3747616cce63df5d50947903a262704988143c2eeb4069ae45420&token=79317275&lang=zh_CN#rd) 

- ##### 命令规范

  - 所有数据库对象名称必须使用小写字母并用下划线分割
  - 所有数据库对象名称禁止使用 MySQL 保留关键字（如果表名中包含关键字查询时，需要将其用单引号括起来）
  - 数据库对象的命名要能做到见名识意，并且最后不要超过 32 个字符
  - 临时库表必须以 tmp_为前缀并以日期为后缀，备份表必须以 bak_为前缀并以日期 (时间戳) 为后缀
  - 所有存储相同数据的列名和列类型必须一致（一般作为关联列，如果查询时关联列类型不一致会自动进行数据类型隐式转换，会造成列上的索引失效，导致查询效率降低）

- ##### 设计规范

  - 所有表必须使用 Innodb 存储引擎
  - 数据库和表的字符集统一使用 UTF8
  - 所有表和字段都需要添加注释
  - 尽量控制单表数据量的大小,建议控制在 500 万以内
  - 谨慎使用 MySQL 分区表
  - 尽量做到冷热数据分离,减小表的宽度
  -  禁止在表中建立预留字段
  -  禁止在数据库中存储图片,文件等大的二进制数据
  -  优先选择符合存储需要的最小的数据类型
  -  避免使用 TEXT,BLOB 数据类型，最常见的 TEXT 类型可以存储 64k 的数据
  -  避免使用 ENUM 类型
  -  尽可能把所有列定义为 NOT NULL
  -  使用 TIMESTAMP(4 个字节) 或 DATETIME 类型 (8 个字节) 存储时间
  -  同财务相关的金额类数据必须使用 decimal 类型
  
- ##### 索引规范

  -  限制每张表上的索引数量,建议单张表索引不超过 5 个
  -  禁止给表中的每一列都建立单独的索引
  -  每个 Innodb 表必须有个主键
  - **常见索引列建议**
    -  出现在 SELECT、UPDATE、DELETE 语句的 WHERE 从句中的列
    -  包含在 ORDER BY、GROUP BY、DISTINCT 中的字段
    -  并不要将符合 1 和 2 中的字段的列都建立一个索引， 通常将 1、2 中的字段建立联合索引效果更好
    -  多表 join 的关联列
  - 选择索引列的顺序
    -  区分度最高的放在联合索引的最左侧（区分度=列中不同值的数量/列的总行数）
    -  尽量把字段长度小的列放在联合索引的最左侧（因为字段长度越小，一页能存储的数据量越大，IO 性能也就越好）
    -  使用最频繁的列放到联合索引的左侧（这样可以比较少的建立一些索引）
  -  避免建立冗余索引和重复索引
  -  尽量避免使用外键约束

- ##### SQL语句规范

  - 禁止使用 SELECT * 必须使用 SELECT <字段列表> 查询
  -  禁止使用不含字段列表的 INSERT 语句
  -  避免使用子查询，可以把子查询优化为 join 操作
  -  避免使用 JOIN 关联太多的表
  -  对应同一列进行 or 判断时，使用 in 代替 or
  -  禁止使用 order by rand() 进行随机排序
  -  WHERE 从句中禁止对列进行函数转换和计算
  -  在明显不会有重复值时使用 UNION ALL 而不是 UNION
  -  拆分复杂的大 SQL 为多个小 SQL
  -  对于连续数值，使用`BETWEEN`不用`IN`：`SELECT id FROM t WHERE num BETWEEN 1 AND 5`
  -  尽量避免在 WHERE 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描





#### 常用命令

[一千行MySQL命令](https://snailclimb.gitee.io/javaguide/#/database/一千行MySQL命令)

```mysql
# 查配置
show variables like '%';
# 放开用户的远程操作权限
GRANT ALL PRIVILEGES ON *.* TO '<user>'@'%' IDENTIFIED BY '<password>' WITH GRANT OPTION;
# 刷新权限规则生效
flush privileges;
# 在线改配置
set <global|session>
# 查看隔离级别
select @@tx_isolation;
# 设置隔离级别
set session transaction isolation level read UNCOMMITTED;
# 开启事务
start transaction;
# 事务回滚
rollback;
# 事务提交
commit;
# 关闭事务自动提交
set autocommit = 0
# 加共享锁
<command> lock in share mode
# 加排他锁
<command> for update
# 索引创建
ALTER TABLE table_name ADD INDEX index_name (column_list)
ALTER TABLE table_name ADD UNIQUE (column_list)
ALTER TABLE table_name ADD PRIMARY KEY (column_list)
CREATE INDEX index_name ON table_name (column_list)
CREATE UNIQUE INDEX index_name ON table_name (column_list)
# 删除索引
DROP INDEX index_name ON talbe_name
ALTER TABLE table_name DROP INDEX index_name
ALTER TABLE table_name DROP PRIMARY KEY
# 查看索引
show index from table_name;
show keys from table_name;
```



## 架构设计

### 设计模式

[关于设计模式的一些简单案例](https://github.com/freshchen/fresh-design-pattern)

#### 概念简述

- **单一责任原则**

  就一个类而言，应该只有一个引起它变化的原因。

- **开放封闭原则**

  软件实体应该是可以扩展的，但是不可修改。

- **依赖倒转原则**

  1.高层模块不应该依赖底层模块，两个都应该抽象依赖。

  2.抽象不应该依赖细节。细节应该依赖抽象。

- **迪米特法则**

  如果两个类不必彼此直接通信，那么这两个类就不应该发生直接的相互作用。如果其中一个类需要调用另一个类的摸一个方法的话，应该同通过第三方转发这个调用

- **组合聚合复用原则**

  尽量使用组合聚合，尽量不要使用类继承。

- **简单工厂模式**

  定义超类，子类通过继承重写方法实现多态，创建一个Factory工厂类，调用统一的超类接口，实例化相应的子类对象，实现解耦。

- **策略模式**

  封装实现同一功能的不同算法，通过Context上下文方式加载不同策略，可以和简单工厂模式结合使用。

- **装饰模式**

  动态地给一个对象添加一些额外的职责，就增加功能来说，装饰模式比生成子类更加灵活。

- **代理模式**

  为其他对象提供一种代理以控制对这个对象的访问。

- **工厂方法模式**

  定义一个用于创建对象的接口，让子类决定实例化哪一个类。工厂方法使一个类的实例化延迟到了其子类。

- **原型模式**

  用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。

- **模板方法模式**

  定义一个操作中的算法的骨架，而将一些步骤延迟到子类中。模板方法使得子类可以不改变一个算法的结构即可重定义该算法的某些特定的步骤。

- **外观模式（门面模式）**

  为了系统中的一组接口提供一个一致的界面，此模式定义了一个高层接口，这个接口使得这以子系统更加容易使用。

- **建造者模式**

  将一个复杂对象的构建与他的表示分离，使得同样的构建过程可以创建不同的表示。

- **观察者模式（发布订阅）**

  一对多的依赖关系，让多个观察者对象同时监听某一个主题对象。这个主题对象在状态发生变化时，会通知所有观察者对象，使它们能够自动更新自己。

- **抽象工厂方法**

  提供一个创建一系列相关或相互依赖对象的接口，而无需具体指定他们的实现。

- **状态模式**

  当一个对象的内在状态改变时允许改变其行为，这个对象看起来像是改变了其类。（状态模式主要解决的是控制一个对象状态转换的条件表达式过于复杂时的情况）

- **适配器模式**

  将一个类的接口转换成客户希望的另一个接口。Adapter模式使得原本由于接口不兼容而不能一起工作的那些类可以一起工作。

- **备忘录模式**

  在不破坏封装性的前提下，捕获一个对象的内部状态，并在对象之外保存这个状态。这样以后就可将对象恢复到原先保存的状态。

- **组合模式**

  将对象组合成树形结构以表示 “部分-整体” 的层次结构。组合模式使得用户对单个对象和组合对象的使用具有一致性。 

- **迭代器模式**

  提供一种方法顺序访问一个聚合对象中各个元素，而又不暴露该对象的内部表示。

- **单例模式**

  保证一个类仅有一个实例，并提供一个访问它的全局访问点。

- **桥接模式**

  将抽象部分与它的实现部分分离，使它们都可以独立地变化。

- **命令模式**

  将一个请求封装为一个对象，从而使你可用不同的请求对客户进行参数化，对请求排队或记录请求日志，以及支持可撤销的操作。

- **责任链模式**

  使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系。将这个对象连成链条，并沿着这条链传递该请求，直到有一个对象处理它为止。

- **中介者模式**

  用 一个中介对象封装一系列对象交互。中介者使得各对象不需要显示地互相引用，从而使得其耦合松散，而且可以独立地改变它们之间的交互。

- **享元模式**

  运用共享技术有效地支持大量细粒度的对象。

- **解释器模式**

  给定一个语言，定义它的文法的一种表示，并定义一个解释器，这个解释器使用该表示来解释语言中的句子。

- **访问者模式**

  表示一个作用于某种对象结构中的各元素的操作。它使你可以在不改变各元素的类的前提下定义作用于这些元素的新操作。

#### Java中的观察者模式

- **Observable（观察者模式Subject）**

类：当存在多对一的依赖关系的时候，我们会用到观察者模式，其中Subject用于注册，移除，发生改变时通知Observer，Observer收到通知之后进行update操作。Observer储存在Vector容器中

- **Observer（观察者模式的观察者）**

接口：定义了update(Observable o, Object arg)方法，当调用Observable的notifyObservers时，会触发update。观察者需要实现这个接口，重写update方法实现特定功能

#### Java中的单例模式

- 普通的线程安全单例

  ```java
  public class Singleton{
  
      private static final Singleton INSTANCE = new Singleton();
    
      private Singleton(){}
  
      public static Singleton getSingleton(){
          return INSTANCE;
      }
  }
  ```

- 双检查线程安全单例

  ```java
  public class SafePublish {
  
      private volatile static SafePublish instance = null;
  
      public static SafePublish getInstance() {
          if (instance == null) {
              synchronized (SafePublish.class) {
                  if (instance == null) {
                      instance = new SafePublish();
                  }
              }
          }
          return instance;
      }
  
      private SafePublish() {}
  }
  ```

- 枚举线程安全单利

  ```java
  public enum Singleton {
      INSTANCE;
  }
  ```

  



### 分布式

#### SOA

- 理念
  - SOA 定义了良好的对外接口，通过网络协议对外提供服务，服务之间表现为松祸合性，
    松祸合性具有灵活的特点，可以对服务流程进行灵活组装和编排，而不需要对服务本
    身做改变。
  - 组成整个业务流程的每个服务的内部结构和实现在发生改变时，不影响整个流程对外提供
    服务，只要对外的接口保持不变，则改变服务内部的实现机制对外部来说可以是透明的。
  - SOA 在这一时代的数据通信格式通常为XML ，因为XML 标记定义在大规模、高并发
    通信过程中，元余的标记会给性能带来极大的影响，所以后来被JSON 所取代。
  - SOA 通过定义标准的对外接口，可以让底层通用服务进行下沉，供多个上层的使用方
    同时使用，增加了服务的可重用性。
  - SOA 可以让企业最大化地使用内部和外部的公共服务，避免重复造轮子，例如：通过
    SOA 从外部获取时间服务。

- 实现
  - Web Service 通过注册中心链接服务
  - ESB 企业级系统总线，主要用于整个新老系统

#### 微服务

- 理念
  - 微服务把每一个职责单一的功能放在一个独立的服务中。
  - 每个服务运行在一个单独的进程中。
  - 每个服务有多个实例在运行，每个实例可以运行在容器化平台内，达到平滑伸缩的效
    果。
  - 每个服务有自己的数据存储，实际上，每个服务应该有自己独享的数据库、缓存、消息
    队列等资源。
  - 每个服务应该有自己的运营平台，以及独享的运营人员，这包括技术运维和业务运营人
    员：每个服务都高度自治，内部的变化对外透明。
  - 每个服务都可根据性能需求独立地进行水平伸缩。

#### 微服务架构与SOA 服务化的对比

- 目的不同
  - SOA 服务化涉及的范围更广一些，强调不同的异构服务之间的协作和契约，并强调有
    效集成、业务流程编排、历史应用集成等，典型代表为Web Service 和ESB 。
  - 微服务使用一系列的微小服务来实现整体的业务流程，目的是有效地拆分应用，实现敏
    捷开发和部署，在每个微小服务的团队里，减少了跨团队的沟通，让专业的人做专业
    的事，缩小变更和法代影响的范围，并达到单一微服务更容易水平扩展的目的。
- 部署方式不同
  - 微服务将完整的应用拆分成多个细小的服务，通常使用敏捷扩容、缩容的Docker 技术
    来实现自动化的容器管理， 每个微服务运行在单一的进程内，微服务中的部署互相独
    立、互不影响。
  - SOA 服务化通常将多个业务服务通过组件化模块方式打包在一个War 包里，然后统一
    部署在一个应用服务器上。
- 服务粒度不同
  - 微服务倡导将服务拆分成更细的粒度，通过多个服务组合来实现业务流程的处理，拆分
    到职责单一， 甚至小到不能再进行拆分。
  - SOA 对粒度没有要求， 在实践中服务通常是粗粒度的，强调接口契约的规范化，内部
    实现可以更粗粒度。

#### 微服务的分解和组合模式

- 服务代理模式
- 服务聚合模式
- 服务串联模式
- 服务分支模式
- 服务异步消息模式

#### 微服务的容错模式

- 舱壁隔离模式
  - 微服务容器分组
  - 线程池隔离
- 熔断模式
- 限流模式
  - 计数器
  - 令牌筒
  - 信号量
- 失效转移模式

#### RPC

- JDK RMI
  - RM I 采用JDK 自带的专用序列化协议，不能跨语言。
  - 使用了底层的网络协议， 不如基于文本的HTTP 可读，也不如HTTP 被广泛认可和应用
  - 开源框架的飞速发展，严重削弱了JDK 资深技术的流行程度。
- Hessian 及Burlap
- Spring HTIP Invoke

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/rpc-1.png)

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/rpc-2.png)

#### SOA框架

- Dubbo
  - 默认使用Dubbo 协议传输Hessian 序列化的数据。Dubbo 使用ZooKeeper 作
    为注册中心来注册和发现服务
- HSF
- Thrift
- AXIS
- Mule ESB

#### 微服务框架

- Netflix
- Spring Cloud Netflix
  - 服务在Eureka 实例中注册，由Spring 管理的Bean 来发现和调用。
  - 通过配置的方式可以启动嵌入式的Eureka 服务器。
  - Feign 客户端通过声明的方式即可导入服务代理。
  - Zuul 使用Ribbon 服务实现客户端的负载均衡。
  - 通过声明的方式即可插入Hystrix 的客户端。
  - 通过配置的方式即可启动Hystrix 面板服务器。
  - 在Spring 环境中可以直接配置Netflix 的组件。
  - Zuul 可以自动注册过滤器和路由器，形成一个反向代理服务器。
  - Hystrix 面板可以对服务的状态进行监控，并提供了容错机制。

#### 一致性哈希算法

主要用于解决分布式系统中负载均衡的问题。

一般情况：

- 假设数据hash过后返回值大小2^64，构成一个虚拟圆环
- 例如几台服务器的ip取模映射到环上，把服务器放到圆环中对应的位置
- 然后数据过来之后取模映射完之后，开始顺时针找最近的服务器处理

问题：服务器数量不多，容易出现数据倾斜问题（服务器分布不均匀，缓存数据集中在部分服务器上）

解决方案：可以增加虚拟节点，例如在主机ip后加编号取模映射到环的不同位置。然后数据遇到虚拟节点之后再映射回真实节点。

#### 酸碱平衡理论

ACID 在英文中的意思是“酸”， BASE 的意思是“碱”

- 强一致性
  - 具有ACID 特性的数据库支持强一致性
  - 支付交易系统需要强一致性
  - 但是由于服务拆分我们很难把多个服务需要强一致的数据放到同一个数据库分片中，这时候只能保证最终一致性
- 最终一致性
  - CAP （帽子原理）任何分布式系统只可同时满足以上两点，无法三者兼顾
    - 一致性
    - 可用性
    - 分区容忍性
  - BASE 思想与ACID 原理截然不同，它满足CAP 原理，通过牺牲强一致性获得可用性， 一
    般应用于服务化系统的应用层或者大数据处理系统中，通过达到最终一致性来尽量满足业务的
    绝大多数需求。
    - BA: Basically Available ，基本可用
    - **S: Soft State ，软状态，状态可以在一段时间内不同步**。
      - **可以通过类似binlog的日志，或者在数据库中记录执行状态**
    - E: Eventually Consistent ，最终一致，在一定的时间窗口内， 最终数据达成一致即可。
- 总结
  - 使用向上扩展（强悍的硬件）井运行专业的关系型数据库（例如Oracle 、DB2 和MySQL),
    能够保证强一致性，能用向上扩展解决的问题都不是问题
  - 如果向上扩展的成本很高，则可以对廉价硬件运行的开源关系型数据库（例如MySQL)
    进行水平伸缩和分片，将相关数据分到数据库的同一个片上，仍然能够使用关系型数
    据库保证事务
  - 如果业务规则限制，无法将相关数据分到同一个分片上，就需要实现最终一致性，在记
    录事务的软状态（中间状态、临时状态）时若出现不一致，则可以通过系统自动化或
    者人工干预来修复不一致的问题。

#### 分布式一致性协议

- **DTS** ：国际开放标准组织Open Group 定义了DTS （分布式事务处理模型〉，模型中包含4 种角色，事务管理器是统管全局的管理者（协调者），资源管理器和通信资源管理器是事务的参与者。
  - 应用程序
  - 事务管理器
  - 资源管理器
  - 通信资源管理器
  - 在JEE 规范中定义了TX 协议和兀也协议， TX 协议定义应用程序与事务管理器之间的接
    口， XA 协议则定义事务管理器与资源管理器之间的接口。
- **两阶段提交**：两阶段提交协议把分布式事务分为两个阶段， 一个是准备阶段，另一个是提交阶段。准备
  阶段和提交阶段都是由事务管理器发起的
  - 准备阶段： 协调者向参与者发起指令，参与者评估自己的状态，如果参与者评估指令可
    以完成，则会写redo 或者undo 日在、（ Write-Ahead Log 的一种），然后锁定资源，执行
    操作，但是并不提交。
  - 提交阶段： 如果每个参与者明确返回准备成功，也就是预留资源和执行操作成功，则协
    调者向参与者发起提交指令，参与者提交资源变更的事务，释放锁定的资源；如果任
    何一个参与者明确返回准备失败， 也就是预留资源或者执行操作失败，则协调者向参
    与者发起中止指令，参与者取消己经变更的事务，执行undo 日志，释放锁定的资源。
  - 特点：强一致性
  - 缺点
    - 阻塞：从上面的描述来看，对于任何一次指令都必须收到明确的响应，才会继续进行下
      一步，否则处于阻塞状态，占用的资源被一直锁定，不会被释放。
    - 单点故障：如果协调者岩机，参与者没有协调者指挥，则会一直阻塞，尽管可以通过选
      举新的协调者替代原有协调者，但是如果协调者在发送一个提交指令后岩机，而提交
      指令仅仅被一个参与者接收，并且参与者接收后也岩机，则新上任的协调者无法处理
      这种情况。
    - 脑裂：协调者发送提交指令，有的参与者接收到并执行了事务，有的参与者没有接收到
      事务就没有执行事务，多个参与者之间是不一致的。
- **三阶段提交**：三阶段提交协议是两阶段提交协议的改进版本。它通过超时机制解决了阻塞的问题， 井且
  把两个阶段增加为以下三个阶段。
  - 询问阶段：协调者询问参与者是否可以完成指令，协调者只需要回答是或不是，而不需
    要做真正的操作，这个阶段超时会导致中止。
  - 准备阶段： 如果在询问阶段所有参与者都返回可以执行操作，则协调者向参与者发送预
    执行请求，然后参与者写re do 和undo 日志，执行操作但是不提交操作：如果在询问阶
    段任意参与者返回不能执行操作的结果，则协调者向参与者发送中止请求，这里的逻
    辑与两阶段提交协议的准备阶段是相似的。
  - 提交阶段：如果每个参与者在准备阶段返回准备成功，也就是说预留资源和执行操作成
    功，则协调者向参与者发起提交指令，参与者提交资源变更的事务，释放锁定的资源：
    如果任何参与者返回准备失败，也就是说预留资源或者执行操作失败，则协调者向参
    与者发起中止指令，参与者取消已经变更的事务，执行undo 日志，释放锁定的资源，
    这里的逻辑与两阶段提交协议的提交阶段一致。
  - 特点
    - 增加了一个询问阶段，询问阶段可以确保尽可能早地发现无法执行操作而需要中止的行
      为，但是它并不能发现所有这种行为，只会减少这种情况的发生。
    - 在准备阶段以后，协调者和参与者执行的任务中都增加了超时，一旦超时，则协调者和
      参与者都会继续提交事务，默认为成功，这也是根据概率统计超时后默认为成功的正
      确性最大。
- **TCC**
  - TCC 协议将一个任务拆分成Try 、Confirm 、Cancel 三个步骤
  - TCC 是简化版的三阶段提交协议，解决了两阶段提交协议的
    阻塞问题，但是没有解决极端情况下会出现不一致和脑裂的问题。然而， TCC 通过自动化补偿
    手段，将需要人工处理的不一致情况降到最少，也是一种非常有用的解决方案。某著名的互联
    网公司在内部的一些中间件上实现了TCC 模式。

#### 保证最终一致性的模式

- 查询模式
  - 为了能够实现查询，每个服务操作都需要有唯一的流水号标识，也可使用此次服务操作对
    应的资源ID 来标识，例如：请求流水号、订单号等。
- 补偿模式
  - 自动恢复：程序根据发生不一致的环境，通过继续进行未完成的操作，或者回滚己经完
    成的操作，来自动达到一致状态。
  - 通知运营：如果程序无法自动恢复，并且设计时考虑到了不一致的场景，则可以提供运
    营功能，通过运营手工进行补偿。
  - 技术运营：如果很不巧，系统无法自动回复，又没有运营功能，那么必须通过技术手段
    来解决，技术手段包括进行数据库变更或者代码变更，这是最糟的一种场景，也是我
    们在生产中尽量避免的场景。
- 异步确保模式
  - 异步确保模式是补偿模式的一个典型案例
  - 在实践中将要执行的异步操作封装后持久入库，然后通过定时捞取未完成的任务进行补偿
    操作来实现异步确保模式，只要定时系统足够健壮，则任何任务最终都会被成功执行
- 定期校对模式
  - 实现定期校对的一个关键就是分布式系统中需要有一个自始至终唯一的ID ， 生成全
    局唯一ID 有以下两种方法。
    - 持久型： 使用数据库表自增字段或者Sequence 生成，为了提高效率，每个应用节点可
      以缓存一个批次的ID ，如果机器重启则可能会损失一部分ID ，但是这并不会产生任何
      问题。
    - 时间型：一般由机器号、业务号、时间、单节点内自增D 组成，由于时间一般精确到
      秒或者毫秒，因此不需要持久就能保证在分布式系统中全局唯一、粗略递增等。
  - 在分布式系统中构建了唯一ID 、调用链等基础设施后，我们很容易对系统间的不一致进行
    核对。通常我们需要构建第三方的定期核对系统，从第三方的角度来监控服务执行的健康程度。
- 可靠消息模式
  - 消息的可靠发送
    - 在发送消息之前将消息持久到数据库，状态标记为待发送， 然后发送消息，如果
      发送成功，则将消息改为发送成功。定时任务定时从数据库捞取在一定时间内未发送的消息并
      将消息发送。
    - 该实现方式与第1 种类似，不同的是持久消息的数据库是独立的， 并不藕合在业
      务系统中。发送消息前，先发送一个预消息给某个第三方的消息管理器，消息管理器将其持久
      到数据库，并标记状态为待发送，在发送成功后，标记消息为发送成功。定时任务定时从数据库中捞取一定时间内未发送的消息，查询业务系统是否要继续发送，根据查询结果来确定消息
      的状态
- 消息处理器的事等性
  - 使用数据库表的唯一键进行滤重，拒绝重复的请求。
  - 使用分布式表对请求进行滤重。
  - 使用状态流转的方向性来滤重，通常使用数据库的行级锁来实现。
  - 根据业务的特点，操作本身就是幕等的， 例如： 删除一个资源、增加一个资源、获得一
    个资源等。
- 缓存一致性模式
  - 如果性能要求不是非常高，则尽量使用分布式缓存，而不要使用本地缓存。
  - 写缓存时数据一定要完整， 如果缓存数据的一部分有效， 另一部分无效，则宁可在需要
    时回源数据库，也不要把部分数据放入缓存中。
  - 使用缓存牺牲了一致性，为了提高性能，数据库与缓存只需要保持弱一致性，而不需要
    保持强一致性，否则违背了使用缓存的初衷。
  - 读的顺序是先读缓存，后读数据库，写的顺序要先写数据库，后写缓存。

#### 超时问题的解决方案

- 同步调用模式
  - 两状态的同步接口：成功和失败
  - 三状态的同步接口：：成功、失败和处理中
- 异步调罔模式
  - 异步调用撞口超时
  - 异步调用内部超时
  - 异步调用固调超时

#### 压测工具

- ab
  - ab 是一款针对HTTP 实现的服务进行性能压测的工具
  - ab -c 10 -n 100 000 http://localhost : 8080/genid
  - ab 只能测试简单的RESTful 风格的接口，无法进行多个业务逻辑的串联测试
- jmeter
  - 它可以用于测试静态和动态资源，例如静态文件、Java Applet、CGI 脚本、Java 类库、数据库、FTP 服务器， HTTP服务器等。
- mysqlslap
  - mysqlslap 是MySQL 自带的一款性能压测工具，通过模拟多个并发客户端访问MySQL 来
    执行压力测试，同时提供了详细的数据性能报告。
  - 命令
    - mysqlslap -a -uroot -pyouarebest
    - mysqlslap -a - c 100 -uroot - pyouarebest
    - mysqlslap -a -i 10 -uroot - pyouarebest
    - rnysqlslap - a -clO --nurnber-of-quer 工es=lOOO --auto-generate-sql-load- type=read
      -uroot -pyouarebest
    - mysqlslap -a -cl0 --number-of-queries=l 000 - -auto-genera te - sql-load- type=wri te
      -uroot -pyouarebest
    - mysqlslap -a -clO --number-of-queries=lOOO -- auto-generate-sql-load-type =mixed -uroot -pyouarebest
    - mysqlslap -a --concurrency=S0 , 100 --number-of-queries 1000 一－ debug-info
      --engine=myisam, innodb --iterations=S -uroot -pyouarebest
- sysbench
  - CPU 性能测试
    - sysbench --test=cpu --cpu-max-prime=20000 run
  - 线程锁性能测试
    - sysbench --test=threads --num- threads=64 --thread-yields=lOO --thread-locks=2 run
  - 磁盘随机1/0 性能测试
    - sysbench --test=fileio -- file - num=l6 --file-total-size=lOOM prepare
  - 内存性能测试
    - sysbench --test=memory --num-threads=512 --memory-block-size=256M --memory total-size=32G run
  - M ySQL 事务性操作测试
    - sysbench --test=oltp --mysql-table-engi 口e=myisam oltp-table- size=lOOO --mysql-user=root --mysql-host=localhost - - mysql-password=youarebest --mysql-db=test run
- dd
  - dd 可以用于测试磁盘顺序110 的存取速度。
- LoadRunner
  - LoadRunner 是惠普的一款商业化性能测试工具
- hprof
  - hprof 是JDK 自带的分析内存堆和CPU 使用情况的命令行工具。实际上， hprof 并不是一
    个可执行的命令，而是一个JVM 执行时动态加载的本地代理库，力日载后运行在只币f 进程中。
    通过在NM 启动时配置不同的选项，可以让hprof 监控不同的性能指标，包括堆、CPU 使用情
    况、械和线程等。hprof 会生成二进制或者文本格式的输出文件，对二进制格式的输出可以借助
    命令行工具HAT 进行分析，开发者可以通过分析输出文件来找到性能瓶颈。
  - java agentlib : hprof=cpu=times,interval=20,depth=3 类路径
  - java -agentlib : hprof=heap=sites 类路径

#### 大数据日志系统

日志框架主流slf4j+logback或slf4j+log4j2

- 日志收集器
  - Logstash
  - Fluentd
  - Flume
  - Scribe
  - Rsyslog
- 日志缓冲队列
  - Kafka
  - Redis
  - RabbitMQ
- 日志解析器
  - Logstash
  - Fluentd
- 日志存储和搜索
  - Elasticsearch
  - Solr
- 日志展示系统
  - Kibana

#### APM （应用性能管理，调用链管理）系统

TraceID 和SpanID跟踪请求，谷歌的Dapper 论文提到的调用链跟踪原理

- Pinpoint
- Zipkin
- CAT

#### 故障排除小工具

- jvm命令行
  - jad or jd-gui：反编译
  - btrace：线上debug，增加日志，切面功能
  - jmap：查看内存使用
  - jstat：jstat 利用了口叫内建的指令对Java 应用程序的资源和性能进行实时的命令行监控，包括对堆大小和垃圾回收状况的监控等。与jmap 对比， jstat 更倾向于输出累积的信息与打印GC 等的统计信息等。
  - jinfo：可以输出井修改运行时的Java 进程的环境变量和虚拟机参数。
  - javah ：生成Java 类中本地方法的C 头文件，一般用于开发JNI 库。
  - jps ：用于查找Java 进程，通常使用ps 命令代替。
  - jhat：用于分析内存堆的快照文件。
  - jdb ：远程调试，用于线上定位问题。
  - jstatd: jstat 的服务器版本。
- GUI
  - JCorisole: JDK 自带的可以查看Java 内存和线程堆拢的工具，己经过时。
  - JVisualVM: JDK 自带的可以查看Java 内存和线程堆拢的工具，功能丰富、完善，是JConsole 的替代版本。
  - JMAT: Eclipse 组织开发的全功能的开源Java 性能跟踪、分析和定位工具。
  - JProfiler ： 全功能的商业化Java 性能跟踪、分析和定位工具。
- Linux
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/linux-cmd-1.PNG)
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/linux-cmd-2.PNG)
  - ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/linux-cmd-3.PNG)

#### 常用的4 种开发模式

- 瀑布式开发
- 迭代式开发
- 螺旋式开发
- 敏捷软件开发

### 缓存

#### 引入缓存

-  **场景**：例如我们系统面临大量的查询请求，我们的数据库后端面对如此频繁的IO可能出现性能问题，甚至直接崩溃。就好比CPU和内存之间的关系，CPU处理的太快了，内存速度跟不上，这时最先想到的解决方案就是引入缓存
-  **目标**：
   -  加快用户访问速度，提高用户体验
   -  降低后端负载，减少潜在的风险，保证系统平稳
   -  保证数据“尽可能”及时更新

#### 如何保证缓存与数据库的双写一致性

- 要求强一致性（实际很少）：
  - 方案：**读请求和写请求串行化**，串到一个**内存队列**里去
  - 问题：吞吐量大幅度降低，用比正常情况下多几倍的机器去支撑线上请求
- 不要求强一致性：
  - 方案Cache Aside Pattern
    - 读的时候，先读缓存，缓存没有的话，就读数据库，然后取出数据后放入缓存，同时返回响应
    - 更新的时候，**先更新数据库，然后再删除缓存**
      - **为什么是删除缓存，而不是更新缓存**
        - 在复杂点的缓存场景，缓存不单单是数据库中直接取出来的值
        - 这个缓存不一定被频繁访问到
  - 问题1：
    - 先更新数据库，再删除缓存。如果删除缓存失败了，那么会导致数据库中是新数据，缓存中是旧数据，数据就出现了不一致
  - 解决思路：
    - 先删除缓存，再更新数据库。如果数据库更新失败了，那么数据库中是旧数据，缓存中是空的，那么数据不会不一致。因为读的时候缓存没有，所以去读了数据库中的旧数据，然后更新到缓存中
  - 问题2：
    - 如果采用了上述的先删缓存再更新数据库，一个请求过来，去读缓存，发现缓存空了，去查询数据库，**查到了修改前的旧数据**，放到了缓存中。随后数据变更的程序完成了数据库的修改。完了，数据库和缓存中的数据不一样了
  - 解决思路：
    - 再数据库更新操作还没成功之前，将读请求放入队列（JVM内部队列即可）中等待更新完成，如果请求在等待时间范围内，不断轮询发现可以取到值了，那么就直接返回；如果请求等待的时间超过一定时长，那么这一次直接从数据库中读取当前的旧值

#### 缓存可能引入的问题

- **缓存穿透**
  - 场景：大量查询一个数据库中没有的key，每次请求都走到了后端数据库，缓存没有起到作用
  - 解决方案：
    - 缓存空对象：查不到的key就在缓存中设置一个空对象由一个特殊的值标识，然后给这个key设置过期时间，一般为5分钟。可能的问题是5分钟内可能数据不一致，可以在新增操作中加入缓存空值的检查
    - 布隆过滤器：查不到的key查询布隆过滤器，返回true证明这个key后端没有值，如果false就查询数据库，有值就更新缓存，没值就更行布隆过滤器（可以利用 Redis 的 Bitmaps 实现布隆过滤器[GitHub 类似的方案](https://github.com/erikdubbelboer/Redis-Lua-scaling-bloom-filter)，**这种方法适用于数据命中不高，数据相对固定实时性低（通常是数据集较大）的应用场景**，代码维护较为复杂，但是缓存空间占用少）
- **缓存雪崩**
  - 场景：缓存直接崩掉了
  - 解决方案：
    - 缓存高可用：Redis Sentinel，Redis Cluster
    - 本地缓存：Ehcache，Guava Cache 
    - 请求 DB 限流：限制DB每秒请求 Guava RateLimiter，Sentinel
    - 服务降级：提供默认返回Hystrix、Sentinel
- **缓存击穿**
  - 场景：是指某个**极度“热点”**数据在某个时间点过期时，恰好在这个时间点对这个 KEY 有大量的并发请求过来
  - 解决方案：
    - 加锁：使用分布式锁（setnx ），保证有且只有一个线程去查询 DB ，并更新到缓存
      - set key value [ex seconds|px milliseconds] [nx|xx]   nx key不存在贼执行，xx key存在则执行 
    - 手动过期：缓存上从不设置过期时间，功能上将过期时间存在 KEY 对应的 VALUE 里，如果发现要过期，通过一个后台的异步线程进行缓存的构建，也就是“手动”过期。通过后台的异步线程，保证有且只有一个线程去查询 DB

#### Redis分布式锁

- 单节点分布式锁

  - SET resource_name my_random_value NX PX 30000

- Redlock

  - 安全特性：互斥访问，即永远只有一个 client 能拿到锁

  - 免死锁：最终 client 都可能拿到锁，不会出现死锁的情况，即使原本锁住某资源的 client crash 了或者出现了网络分区

  - 容错性：只要大部分 Redis 节点存活就可以正常提供服务

  - 实现

    - **原理**

      假如起了 5 个 master 节点，分布在不同的机房尽量保证可用性。为了获得锁，client 会进行如下操作：

      1. 得到当前的时间，微秒单位
      2. 尝试顺序地在 5 个实例上申请锁，当然需要使用相同的 key 和 random value，这里一个 client 需要合理设置与 master 节点沟通的 timeout 大小，避免长时间和一个 fail 了的节点浪费时间
      3. 当 client 在大于等于 3 个 master 上成功申请到锁的时候，且它会计算申请锁消耗了多少时间，这部分消耗的时间采用获得锁的当下时间减去第一步获得的时间戳得到，如果锁的持续时长（lock validity time）比流逝的时间多的话，那么锁就真正获取到了。
      4. 如果锁申请到了，那么锁真正的 lock validity time 应该是 origin（lock validity time） - 申请锁期间流逝的时间
      5. 如果 client 申请锁失败了，那么它就会在少部分申请成功锁的 master 节点上执行释放锁的操作，重置状态

    - 失败重试

      如果一个 client 申请锁失败了，那么它需要稍等一会在重试避免多个 client 同时申请锁的情况，最好的情况是一个 client 需要几乎同时向 5 个 master 发起锁申请。另外就是如果 client 申请锁失败了它需要尽快在它曾经申请到锁的 master 上执行 unlock 操作，便于其他 client 获得这把锁，避免这些锁过期造成的时间浪费，当然如果这时候网络分区使得 client 无法联系上这些 master，那么这种浪费就是不得不付出的代价了。

    - 放锁

      放锁操作很简单，就是依次释放所有节点上的锁就行了

    - 性能、崩溃恢复和 fsync

      如果我们的节点没有持久化机制，client 从 5 个 master 中的 3 个处获得了锁，然后其中一个重启了，这是注意 **整个环境中又出现了 3 个 master 可供另一个 client 申请同一把锁！** 违反了互斥性。如果我们开启了 AOF 持久化那么情况会稍微好转一些，因为 Redis 的过期机制是语义层面实现的，所以在 server 挂了的时候时间依旧在流逝，重启之后锁状态不会受到污染。但是考虑断电之后呢，AOF部分命令没来得及刷回磁盘直接丢失了，除非我们配置刷回策略为 fsnyc = always，但这会损伤性能。解决这个问题的方法是，当一个节点重启之后，我们规定在 max TTL 期间它是不可用的，这样它就不会干扰原本已经申请到的锁，等到它 crash 前的那部分锁都过期了，环境不存在历史锁了，那么再把这个节点加进来正常工作。

#### Redis事务

- Redis的事务是通过**MULTI，EXEC，DISCARD和WATCH**这四个命令来完成的
- Redis的单个命令都是**原子性**的，所以这里确保事务性的对象是**命令集合**
- Redis将命令集合序列化并确保处于同一事务的**命令集合连续且不被打断**的执行
- Redis不支持回滚操作

#### Redis部署

- 主从模式：一般主服务器写，从读。主服务器挂掉系统就挂了
- 哨兵sentinel模式：相对主从模式，多了监控主服务器，主挂掉能自动推举下一个主服务器，类似zookeeper，并且能发送故障通知。
- redis cluster：
  - 去中心化，去中间件，集群中的每个节点都是平等的关系
  - Redis 集群没有并使用传统的一致性哈希来分配数据，而是采用另外一种叫做`哈希槽 (hash slot)`的方式来分配的。redis cluster 默认分配了 16384 个slot，当我们set一个key 时，会用`CRC16`算法来取模得到所属的`slot`，然后将这个key 分到哈希槽区间的节点上，具体算法就是：`CRC16(key) % 16384`

#### Redis持久化

主进程调用fork函数开启一个子线程开始做同步，主进程继续工作，子线程全部写完覆盖老备份

| 方案    | 描述                                                         | 优点                   | 缺点                                         |
| ------- | ------------------------------------------------------------ | ---------------------- | -------------------------------------------- |
| **rdb** | 在配置文件中定义了rdb备份的触发条件，条件达到就开始备份redis内存快照。 | 恢复数据很快，磁盘io少 | 没有达到触发条件期间发生故障，未备份数据丢失 |
| **aof** | 将每次操作都记录到一个日志中，通过日志恢复数据。             | 丢失数据风险小         | 还原数据速度慢，磁盘io频繁。                 |

**问: 在dump rdb过程中,aof如果停止同步,会不会丢失?**

答: 不会,所有的操作缓存在内存的队列里, dump完成后,统一操作.

**问: aof重写是指什么?**

答: aof重写是指把内存中的数据,逆化成命令,写入到.aof日志里.

以解决 aof日志过大的问题.

**问: 如果rdb文件,和aof文件都存在,优先用谁来恢复数据?**

答: aof

**问: 2种是否可以同时用?**

答: 可以,而且推荐这么做

**问: 恢复时rdb和aof哪个恢复的快**

答: rdb快,因为其是数据的内存映射,直接载入到内存,而aof是命令,需要逐条执行

#### Redis常用数据类型

- String ：基本类型，二进制安全，可以存放图片序列化对象等
- Hash：String元素组成的字典
- List：列表
- Set：无序不重复集合
- Sorted Set：有序的Set

#### Redis为什么快

- 完全基于内存，C语言编写
- 数据结构相对简单
- 单进程单线程的处理请求，从而确保高并发线程安全，想多核都用上可以通过启动多个实例
- 多路I/O复用，非阻塞

#### Redis和 Memcache区别

- Memcache支持简单的数据类型，不支持持久化存储，不支持主从，不支持分片
- Redis数据类型丰富，支持持久化存储，支持主从，支持分片

