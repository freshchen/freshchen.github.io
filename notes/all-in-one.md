# The All-in-One Note

- [基础](#基础)
  - [Linux](#Linux)
  - [操作系统](#操作系统)
  - [网络](#网络)
  - [数据结构与算法](#数据结构与算法)
- [Java](#Java)
  - [核心](#核心)
  - [并发](#并发)
  - [IO](#JavaIO)
  - [JVM](#JVM)
- [JavaEE](#JavaEE)
  - [Spring](#Spring)
  - [Netty](#Netty)
- [数据库](#数据库)
  - [Mysql](#Mysql)
- [架构设计](#架构设计)
  - [设计模式](#设计模式)
  - [系统设计](#系统设计)






















# 基础

## 操作系统

### I/O 模型

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

### I/O处理线程模型

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





### I/O多路复用技术select、poll、epoll之间的区别

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

### 进程间共享内存的8种方式

- 无名管道( pipe )：管道是一种半双工的通信方式，数据只能单向流动，而且只能在父子进程间使用
- 高级管道(popen)：将另一个程序当做一个新的进程在当前程序进程中启动，则它算是当前程序的子进程
- 有名管道 (named pipe) ： 有名管道也是半双工的通信方式，但是它允许无亲缘关系进程间的通信
- 消息队列( message queue ) ： 消息队列是由消息的链表，存放在内核中并由消息队列标识符标识。消息队列克服了信号传递信息少、管道只能承载无格式字节流以及缓冲区大小受限等缺点
- 信号量( semophore ) ： 信号量是一个计数器，可以用来控制多个进程对共享资源的访问。它常作为一种锁机制，防止某进程正在访问共享资源时，其他进程也访问该资源。因此，主要作为进程间以及同一进程内不同线程之间的同步手段
- 信号 ( sinal ) ： 信号是一种比较复杂的通信方式，用于通知接收进程某个事件已经发生
- 共享内存( shared memory ) ：共享内存就是映射一段能被其他进程所访问的内存，这段共享内存由一个进程创建，但多个进程都可以访问。共享内存是最快的 IPC 方式，它是针对其他进程间通信方式运行效率低而专门设计的。它往往与其他通信机制，如信号两，配合使用，来实现进程间的同步和通信
- 套接字( socket ) ： 套解字也是一种进程间通信机制，与其他通信机制不同的是，它可用于不同机器间的进程通信



## Linux

### Linux常用命令

```bash
########################      文本操作      ########################
# 升序排列
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



## 网络

### 网络模型

- 常说的模型主要有3中，TCP/IP模型是OSI模型的一种商用实现

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/net-model.jpg)

- 7层模型中主要的协议

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/osi.png)



### TCP建立连接三次握手

- 第一次握手：建立连接时，客户端发送syn包（seq=x）到服务器，并进入**SYN_SENT**状态，等待服务器确认；SYN：同步序列编号
- 第二次握手：服务器收到syn包，必须确认客户的SYN（ack=x+1），同时自己也发送一个SYN包（seq=y），即SYN+ACK包，此时服务器进入**SYN_RECV**状态
- 客户端收到服务器的SYN+ACK包，向服务器发送确认包ACK(ack=y+1），此包发送完毕，客户端和服务器进入**ESTABLISHED**（TCP连接成功）状态，完成三次握手

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-3.png)

### TCP结束连接四次挥手

- 第一次挥手：客户端进程发出连接释放报文，并且停止发送数据。释放数据报文首部，FIN=1，其序列号为seq=u（等于前面已经传送过来的数据的最后一个字节的序号加1），此时，客户端进入FIN-WAIT-1（终止等待1）状态。 TCP规定，FIN报文段即使不携带数据，也要消耗一个序号
- 第二次挥手：服务器收到连接释放报文，发出确认报文，ACK=1，ack=u+1，并且带上自己的序列号seq=v，此时，服务端就进入了CLOSE-WAIT（关闭等待）状态。TCP服务器通知高层的应用进程，客户端向服务器的方向就释放了，这时候处于半关闭状态，即客户端已经没有数据要发送了，但是服务器若发送数据，客户端依然要接受。这个状态还要持续一段时间，也就是整个CLOSE-WAIT状态持续的时间，客户端收到服务器的确认请求后，此时，客户端就进入FIN-WAIT-2（终止等待2）状态，等待服务器发送连接释放报文（在这之前还需要接受服务器发送的最后的数据）
- 第三次挥手：服务器将最后的数据发送完毕后，就向客户端发送连接释放报文，FIN=1，ack=u+1，由于在半关闭状态，服务器很可能又发送了一些数据，假定此时的序列号为seq=w，此时，服务器就进入了LAST-ACK（最后确认）状态，等待客户端的确认
- 第四次挥手：客户端收到服务器的连接释放报文后，必须发出确认，ACK=1，ack=w+1，而自己的序列号是seq=u+1，此时，客户端就进入了TIME-WAIT（时间等待）状态。注意此时TCP连接还没有释放，必须经过2∗∗MSL（最长报文段寿命）的时间后，当客户端撤销相应的TCB后，才进入CLOSED状态，服务器只要收到了客户端发出的确认，立即进入CLOSED状态。同样，撤销TCB后，就结束了这次的TCP连接。可以看到，服务器结束TCP连接的时间要比客户端早一些

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/tcp-4.png)

### TCP粘包，拆包

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

### 浏览器中输入URL到页面返回的过程

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

### ARP地址解析协议（链路层）

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





## 数据结构与算法

### 常用排序算法

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

### 二叉树

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

### 算法验证对数器

- 准备样本随机生成器
- 准备一个绝对正确但是复杂度不好的算法
- 将待验证算法和绝对正确算法压测，比较

### 主定理与递归时间复杂度的计算

- 主定理：如果有一个问题规模为 n，递推的子问题数量为 a，每个子问题的规模为n/b（假设每个子问题的规模基本一样），递推以外进行的计算工作为 f(n)（比如归并排序，需要合并序列，则 f(n)就是合并序列需要的运算量），那么对于这个问题有如下递推关系式：
- ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/main1.jpe)
- 然后就可以套公式估算递归的时间复杂度
- ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/main2.jpe)



### B树和B+树定义与区别

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

### 并查集

- 用于解决
  - 两个元素是否在同一个集合（优化，查的过程中把路过的节点直接连头节点）
  - 合并两个元素所在的集合
- 实现
  - 数组
  - 双HashMap

### 红黑树

- 每个节点非红即黑
- 根节点总是黑色的
- 如果节点是红色的，则它的子节点必须是黑色的（反之不一定）
- 每个叶子节点都是黑色的空节点
- 从根节点到叶节点或空子节点的每条路径，必须包含相同数目的黑色节点（即相同的黑色高度）

### 前缀树/字典树（Trie）

- 用于解决
  - 常用于快速检索
  - 大量字符串的排序和统计
- 基本性质
  - 根节点不包含字符，除根节点外每个节点只包含一个字符
  - 从根节点到某个节点，路径上所有的字符连接起来，就是这个节点所对应的字符串
  - 每个节点的子节点所包含的字符都不同

### 如何从暴力递归改动态规范

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



# Java

## 并发

### J.U.C总览图

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/juc.png)

### J.U.C常用同步器

- **CountDownLatch**
  - 作用：主要用于一个线程要等待其他线程任务执行完再执行
- **CyclicBarrier**
  - 作用：主要用于多个线程到达起跑线之后同时等待，发令枪响齐头并进
- **Executors**
  - 作用：主要用于提供默认应用场景的线程池创建，以及一些任务调度方法
- **Semaphore**
  - 作用：主要用于限制同时执行任务的线程数量
- **Exchanger**
  - 作用：主要用于两个线程之间交换数据

### J.U.C阻塞队列BlockingQueue

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

### 线程池的五种状态

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/threadpoolstatus.jpg)

### 如何创建ThreadPoolExecutor线程池

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

### synchronized关键字

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
- JVM中锁升级流程
  
  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/synchronized.png)

### volatile关键字

- 作用：
  - 保证数据线程可见性
  - 避免指令重排
- 实现：
  - 在字节码中加入了 lock 指令：
    - 锁总线，其它CPU对内存的读写请求都会被阻塞，直到锁释放，**不过实际后来的处理器都采用锁缓存替代锁总线**，因为锁总线的开销比较大，锁总线期间其他CPU没法访问内存，通过缓存一致性协议确保拿到缓存值是最新的
    - lock后的写操作会把已修改的数据写回内存，同时让其它线程相关缓存行失效，从而重新从主存中加载最新的数据
    - 不是内存屏障却能完成类似内存屏障的功能，阻止屏障两边的指令重排序

### 如何终止线程

- stop方法（别用）
  - 立刻终止线程，过于粗鲁
  - 清理工作可能完成不了
  - 会立即释放锁，有可能引起线程不同步
- interrupt方法
  - 阻塞状态下会推出阻塞状态，抛出InterruptedException；运行状态下设置中断标志位为true，继续运行，线程自行检查标志位主动终止，相对温柔

### 线程如何通信

线程的通信是指线程之间以何种机制来交换信息，在编程中，线程之间的通信机制有两种，共享内存和消息传递

- 共享内存：线程之间共享程序的公共状态，线程之间通过写-读内存中的公共状态来隐式进行通信，典型的共享内存通信方式就是通过共享对象进行通信
- 消息传递：线程之间没有公共状态，线程之间必须通过明确的发送消息来显式进行通信，在java中典型的消息传递方式就是wait()和notify()

### notify方法和notifyAll方法的区别

当调用wait方法后，线程会被放到对象内部的等待池中，在等待池中的线程不会去竞争CPU，只有调用Notify或者NotifyAll才会从等待池中，放入锁池中，等待对象锁的释放从而竞争CPU以执行。

- notify从等待池中随机选一个线程放入锁池
- notifyAll把所有等待池全放入锁池

### Java中sleep方法和wait方法的区别

- sleep
  - Thread类方法
  - 让出CPU，不改变锁状态
  - 任意位置执行

- wait
  - Object类方法
  - 让出CPU，释放当前占用的锁
  - 只能在synchronized中的中使用

## JVM

### 如何分析jvm线程堆栈

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

### 四种引用类型

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

### 常用的垃圾收集器

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

### CMS收集器执行步骤

- 初始阶段：stop-the-world
- 并发标记：并发追溯标记，程序不停顿
- 并发预清理：查找并发标记阶段从新生代晋升老年代的对象
- 重新标记：stop-the-world，扫描CMS堆中的剩余对象
- 并发清理：清理垃圾对象，程序不停顿
- 并发重置：重置CMS收集器的数据结构，程序不停顿

### JVM常用调优参数

- -Xss: 规定每个线程虚拟机栈的大小
- -Xms: 堆的初始值
- -Xmx: 堆能扩展的最大值
- -XX:SurvivorRatio：Eden区和其中一个Survivor区的比值
- -XX:NewRatio：老年代和新生代比值
- -XX:MaxTenuringThreshold：对象从年轻代进入老年代经历过GC次数的阈值

### JVM常用的垃圾回收算法

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

### 何时真正开始Full GC（stop-the-world）

程序到达安全点，安全点是对象引用关系不会变化的点，例如方法调用，循环跳转，异常跳转等

### GC如何标记垃圾对象

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

### String.intern()的用法

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

### JVM内存模型（jdk8）

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

### Java内存模型（JMM）

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/jmm.png)

### Happens-Before原则

保证单线程执行的内存可见性，多线程不能保证

- 程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作
- 监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁
- volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读
- 传递性：如果A happens-before B，且B happens-before C，那么A happens-before C
- start()规则：如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作happens-before于线程B中的任意操作
- join()规则：如果线程A执行操作ThreadB.join()并成功返回，那么线程B中的任意操作happens-before于线程A从ThreadB.join()操作成功返回
- 线程中断规则:对线程interrupt方法的调用happens-before于被中断线程的代码检测到中断事件的发生

### 指令重排

在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序

- 可以通过内存屏障避免重排序（volatile的实现类似内存屏障）
- 如果指令执行顺序不会破坏Happens-Before原则，JVM就有可能对指令重排

### 类加载双亲委派机制

- 从底向上检查ClassLoader中类是否加载
- 从顶向下调用ClassLoader加载类

### 类加载器ClassLoader种类

- BootStrapClassLoader：C++编写，加载核心库java.*
- ExtClassLoader：Java编写，加载扩展库javax.*
- AppClassLoader：Java编写，加载程序所在目录classpath
- CustomClassLoader：Java编写，定制化加载

### Java从编写到运行的大致过程

- 将写好的.java文件通过javac调用编译器生成JVM可识别指令组成的.class文件（IED可以自动反编译.class文件，也可以通过javap -v 反编译）
- 通过ClassLoader分三步加载，连接（验证，准备，解析）和初始化 将.class文件加载到JVM中生成Class类
- 然后用加载的Class类经过内存分配，初始化，init调用构造创建出对象
- 最后有了对象就可以执行相关方法了

### 不可变对象

- 对象创建之后状态不能修改

- 对象的所有的域都是final类型

- 对象是正确创建的（对象创建过程中，this引用没用逃逸）

### 如何安全发布对象

- 在静态初始化函数中初始化一个对象引用

- 将对象的引用保存到正确的构造对象的final类型域中

- 将对象的引用保存到一个由锁保护的域中

- 将对象的引用用volatile关键字修饰，或者保存到AtomicReference对象中


### 为什么双检查单例模式实例引用不加volatile不是线程安全的

- 对象发布主要有三步 1.分配内存空间 2初始化对象 3引用指向分配的内存

- 由于指令重排的存在，可能出现132的顺序，多线程环境下，可能出现 instance != null  但是初始化工作还没完成的情况在占有锁的线程没有完成初始化时，另一个线程认为以及初始化完毕了去使用对象的时候便会有问题

- 加上 volatile 关键字就可以解决指令重排的问题

### JVM内存泄漏情景

- 类似于栈，内存的管理权不属于JVM而属于栈本身，所有被pop掉的index上还存在着过期的引用Stack.pop()的源码中手动清除了过期引用
elementData[elementCount] = null; /* to let gc do its work

- 将对象引用放入了缓存，可以用WeakHashMap作为引用外键

- 监听器和其他回调，可以用WeakHashMap作为引用外键



## JavaIO

### BIO,NIO,AIO的区别

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

## 核心

### HashMap

- #### 应用场景

  - 键值对高效存取

- #### 数据结构

  - 1.7数组加链表
  - 1.8数组加链表加红黑树

- #### 线程安全

  - **不安全**
  - 多线程下使用扩容步骤存在问题
  - 线程安全的替代
    - Hashtable
    - ConcurrentHashMap
    - ConcurrentSkipListMap

- #### 默认大小

  - 初始数组默认长度16

- #### 何时扩容

  - HashMap.Size   >=  Capacity * LoadFactor当前容量超过总容量乘以散列因子（默认0.75）就扩容，每次2倍扩容

- #### 扩容机制

  - jdk1.7
    - 对于扩容操作，底层实现都需要新生成一个数组，然后拷贝旧数组里面的每一个Entry链表到新数组里面，这个方法在单线程下执行是没有任何问题的，但是在多线程下面却有很大问题，主要的问题在于基于**头插法**的数据迁移，会有几率造成链表倒置，从而引发链表闭链，当map.get(key)落到这个Entry时候就会进入死循环，导致程序死循环，并吃满CPU
  - jdk1.8
    - 没有使用**头插法**，而是保留了元素的顺序位置，把要迁移的元素分类之后，最后在分别放到新数组对应的位置上

- #### 为什么数组的长度为2的幂次方

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

- #### jdk1.8 何时转红黑树

  - Node桶下链表长度超过8转为红黑树
  - Node桶下红黑树节点数小于6就转回链表

### LinkedHashMap

- #### 应用场景

  - 保证插入的顺序

### Hashtable

- #### 默认大小

  - 11

- #### 线程安全性

  - **安全**
  - 实现
    - 方法加synchronized

### ConcurrentHashMap

- #### 线程安全性

  - **安全**
  - jdk1.7
    - 采用的是分段锁的机制，ConcurrentHashMap维护了一个Segment数组，Segment这个类继承了重入锁ReentrantLock，并且该类里面维护了一个 HashEntry<K,V>[] table数组，在写操作put，remove，扩容的时候，会对Segment加锁
  - jdk1.8
    - 新的版本主要使用了Unsafe类的CAS自旋赋值+synchronized同步+LockSupport阻塞等手段直接操作Node， 取消了分段的概念，实现的高效并发。实现中的优化，**等待的线程会帮助扩容的线程一起完成扩容操作**

### ConcurrentSkipListMap

### ArrayList

- #### 特点

  - 实现标识接口RandomAccess，随机存取，查询效率高，大数据量下迭代效率差

- #### 数据结构

  - 数组

- #### 线程安全性

  - 不安全
  - 线程安全的替代
    - List list = Collections.synchronizedList(new ArrayList())
    - CopyOnWriteArrayList

- #### 默认大小

  - 有个懒加载设计，new ArrayList() 返回的是一个空的默认数组
  - 当第一次add操作之后扩容成10

- #### 何时扩容

  - 装不下就扩容
  - newCapacity = oldCapacity + (oldCapacity >> 1) 每次1.5倍扩容

- #### 扩容机制

  - 调用 Arrays.copyOf() 方法， 改方法是 native （System.arraycopy）实现

- #### 克隆

  - 深拷贝

### LinkedList

- #### 数据结构

  - 双端链表

- #### 线程安全性

  - 不安全
  - 线程安全的替代
    - List list = Collections.synchronizedList(new LinkedList())
    - ConcurrentLinkedQueue

- #### 克隆

  - 浅拷贝

### TreeSet

- #### 应用场景

  - 自动排序

- #### 线程安全性

  - 不安全
  - 线程安全的替代
    - CopyOnWriteArraySet
    - ConcurrentSkipListSet

### PriorityQueue

- #### 应用场景

  - 找最大最小元素

- #### 数据结构

  - 堆

### 重写equals

- 四大原则，自反性，对称性，传递性，一致性，非空性

- 如果继承一个类，并且新增了值属性，重写equals会变得很麻烦，这时候推荐用组合

- 如果重写了equals但是没有重写hashcode有可能出现equals返回true但是hashcode不相等的情况

### 异常处理一般规范

- 在Finally块中清理资源或者使用Try-With-Resource语句
- 抛出明确的异常，避免抛出Exception这种
- 在注释Javadoc里边添加@throws声明并且描述什么样的情况会导致异常
- 将异常与它的描述信息一并抛出
- 优先catch捕获更明确的异常
- 不要捕获Throwable
- 别忽略异常
- 不要打印异常日志的同时将其抛出
- 自定义异常包裹某个异常的同时不要丢弃它原本的信息



### Java泛型参数

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



# JavaEE

## Spring

### 什么是IoC和DI

- IoC（控制反转），控制反转是把传统上由程序代码直接操控的对象的调用权交给IoC容器，通过IoC容器来实现对象组件的依赖注入，依赖检查，自动装配等对象生命周期管理
- DI（依赖注入）主要是遵循设计模式中依赖倒转原则中的“高层模块不应该依赖底层模块，两个都应该抽象依赖”，依赖注入的方式主要包括，setter方法，interface接口，constructor构造函数，annotation注解


![Spring Ioc容器](https://cdn.jsdelivr.net/gh/freshchen/resource/img/spring-ioc.PNG)

### BeanFactory和ApplicationContext

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

### Bean的五种作用域

- singleton：单例模式，在整个Spring IoC容器中，使用singleton定义的Bean将只有一个实例
- prototype：原型模式，每次通过容器的getBean方法获取prototype定义的Bean时，都将产生一个新的Bean实例
- request：对于每次HTTP请求，使用request定义的Bean都将产生一个新实例，即每次HTTP请求将会产生不同的Bean实例。只有在Web应用中使用Spring时，该作用域才有效
- session：对于每次HTTP Session，使用session定义的Bean豆浆产生一个新实例。同样只有在Web应用中使用Spring时，该作用域才有效
- globalsession：每个全局的HTTP Session，使用session定义的Bean都将产生一个新实例。典型情况下，仅在使用portlet context的时候有效。同样只有在Web应用中使用Spring时，该作用域才有效

### Bean的生命周期

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/spring-bean-lifecycle.png)

### AOP（面向切面编程）基础

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

### Spring事务

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



## SpringMVC

### SpringMVC请求处理流程

![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/springmvc.png)

### SpringMvc的控制器是不是单例模式是不是线程安全

- 是单例模式,所以在多线程访问的时候有线程安全问题
- 不要用同步,会影响性能,解决方案把控制器变为无状态对象
- 如果一定有成员变量，可以增加注解@Scope(value = "prototype")改为原型模式



## Netty

### Netty的特点

- 一个高性能、异步事件驱动的NIO框架，它提供了对TCP、UDP和文件传输的支持
- 使用更高效的socket底层，对epoll空轮询引起的cpu占用飙升在内部进行了处理，避免了直接使用NIO的陷阱，简化了NIO的处理方式。
- 采用多种decoder/encoder 支持，对TCP粘包/分包进行自动化处理
- 可使用接受/处理线程池，提高连接效率，对重连、心跳检测的简单支持
- 可配置IO线程数、TCP参数， TCP接收和发送缓冲区使用直接内存代替堆内存，通过内存池的方式循环利用ByteBuf
- 通过引用计数器及时申请释放不再引用的对象，降低了GC频率
- 使用单线程串行化的方式，高效的Reactor线程模型
- 大量使用了volitale、使用了CAS和原子类、线程安全类的使用、读写锁的使用

### Netty执行流程

- 当客户端网络I/O请求来了就需要为其通过**Bootstrap**创建一个**Channel**，**Channel**是一个Socket的抽象
- 在创建过程中**Channel**会去**EventLoopGroup**中申请注册一个**EventLoop**，**Channel**和**EventLoopGroup**是多对一的关系，**EventLoop**对应一个Reactor线程模型
- 注册完成后**Channel**就可以执行**ChannelpipeLine**中的任务了
- **ChannelpipeLine**由各种Handler组成，主要有**ChannelInboundHandler**（读）和**ChannelOutboundHandler**（写），通过**HandlerContext**管理，各大Handler可以通过**ByteBuf**操作数据



# 数据库

## Mysql

### 常用命令

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



### 索引为什么能提高查询速度

- 不使用索引如和查询

  - Mysql最小存储结构是页，页是一个单链表把数据连在一起
  - 各个页通过双端链表连在一起
  - 查询时，我们要遍历双端链表找到数据所在的页，然后再在页中遍历找到对应的数据项

- 而我们使用索引时Innodb默认使用B+树实现如下效果，大大提高了效率

  ![](https://cdn.jsdelivr.net/gh/freshchen/resource/img/mysql-index.jpg)

### Hash索引的局限性

- 哈希索引也没办法利用索引完成**排序**
- 不支持**最左匹配原则**
- 在有大量重复键值情况下，哈希索引的效率也是极低的---->**哈希碰撞**问题。
- **不支持范围查询**

### InnoDB 可重复读（Repeatable read）级别为啥可以避免幻读

- 表象：快照读（非阻塞读不加锁，对应加锁的叫当前读）伪MVCC

- 内在：next-key锁（行锁 + gap锁）

### 事务隔离级别

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
    - MySQL的`Repeatable read`隔离级别加上GAP间隙锁**已经处理了幻读了**。
- Serializable 既然Innodb已经避免了幻读还有场景用么，
  - **丢失更新**：一个事务的更新**覆盖了其它事务的更新结果**

### 常用存储引擎适用场景

- MyISAM适用频繁执行全表count，查询频率高，增删改频率不高

- InnoDB增删改查都频繁，对可靠性要求高，要求支持事务

### 锁

- 粒度划分
  - **表锁**开销小，加锁快；不会出现死锁；锁定力度大，发生锁冲突概率高，并发度最低
  - **行锁**开销大，加锁慢；会出现死锁；锁定粒度小，发生锁冲突的概率低，并发度高

- InnoDB默认行锁，也支持表锁,没有用到索引的时候用表级锁
- MyISAM默认表锁
- 手动给表加锁 lock tables <table_name> <read|write> ， 解锁 unlock tables <table_name>
- 共享锁（S）：`SELECT * FROM table_name WHERE ... LOCK IN SHARE MODE`。
- 排他锁（X)：`SELECT * FROM table_name WHERE ... FOR UPDATE`
- InnoDB支持事务，关闭事务自动提交方法 set autocommit = 0

### MVCC和事务的隔离级别

- 描述
  - 数据库事务有不同的隔离级别，不同的隔离级别对锁的使用是不同的，**锁的应用最终导致不同事务的隔离级别**
  - MVCC(Multi-Version Concurrency Control)多版本并发控制，可以简单地认为：**MVCC就是行级锁的一个变种(升级版)**。
  - 事务的隔离级别就是**通过锁的机制来实现**，只不过**隐藏了加锁细节**

- 特点
  - **MVCC一般读写是不阻塞的**(所以说MVCC很多情况下避免了加锁的操作)
  - MVCC实现的**读写不阻塞**正如其名：**多版本**并发控制--->通过一定机制生成一个数据请求**时间点的一致性数据快照（Snapshot)**，并用这个快照来提供一定级别（**语句级或事务级**）的**一致性读取**。从用户的角度来看，好像是**数据库可以提供同一数据的多个版本**。
    - 其中数据快照有**两个级别**：
      - 语句级 
        - 针对于`Read committed`隔离级别
      - 事务级别 
        - 针对于`Repeatable read`隔离级别

### SQL慢查询的优化

- 分析过程
  - 开启慢日志，查看慢日志，找到查询比较慢的语句
  - 使用explain分析sql
  - 分析结果中type字段，从好到坏是const、eq_reg、ref、range、index和all，是index和all就有问题需要优化
  - extra字段是Using filesort指用的外部索引例如文件系统索引等，Using temporary指用的临时表，这两种情况也需要优化
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

### 稀疏索引和聚集索引 

- 聚集索引
  - 指索引项的排序方式和表中数据记录排序方式一致的索引
  - 在叶子节点存储的是**表中的数据**
- 稀疏索引
  - 稀疏索引只为某些搜索码值建立索引记录；在搜索时，找到其最大的搜索码值小于或等于所查找记录的搜索码值的索引项，然后从该记录开始向后顺序查询直到找到为止
  - 叶子节点存储的是**主键和索引列**
- InnoDB 主键走聚集索引，其他走稀疏索引
- MyISAM 全是走稀疏索引

### 联合索引

- **最左匹配原则**
  - 索引只能用于查找key是否**存在（相等）**，遇到范围查询`(>、<、between、like`左匹配)等就**不能进一步匹配**了，后面的条件退化为线性查找
  - 例如创建 union index (a , b ,c)  查（a，b）走索引，查（a，c）走不了索引

### 数据库事务四大特性

- 原子性（Atomic）要么全做要么全不做

- 一致性（Consistency）数据要保持完整性，从一个一致状态到另一个一致状态

- 隔离性（Isolation）一个事务的执行不影响其他事务

- 持久性（Durability）事务一旦提交，变更应该永久的保存到数据库中



# 架构设计

## 设计模式

[关于设计模式的一些简单案例](https://github.com/freshchen/fresh-design-pattern)

### 概念简述

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

### Java中的观察者模式

- **Observable（观察者模式Subject）**

类：当存在多对一的依赖关系的时候，我们会用到观察者模式，其中Subject用于注册，移除，发生改变时通知Observer，Observer收到通知之后进行update操作。Observer储存在Vector容器中

- **Observer（观察者模式的观察者）**

接口：定义了update(Observable o, Object arg)方法，当调用Observable的notifyObservers时，会触发update。观察者需要实现这个接口，重写update方法实现特定功能

### Java中的单例模式

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

  



## 系统设计

### 一致性哈希算法

主要用于解决分布式系统中负载均衡的问题。

一般情况：

- 假设数据hash过后返回值大小2^64，构成一个虚拟圆环
- 例如几台服务器的ip取模映射到环上，把服务器放到圆环中对应的位置
- 然后数据过来之后取模映射完之后，开始顺时针找最近的服务器处理

问题：服务器数量不多，容易出现数据倾斜问题（服务器分布不均匀，缓存数据集中在部分服务器上）

解决方案：可以增加虚拟节点，例如在主机ip后加编号取模映射到环的不同位置。然后数据遇到虚拟节点之后再映射回真实节点。

### 布隆过滤（Bloom Filter）

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

### 引入缓存

-  **场景**：例如我们系统面临大量的查询请求，我们的数据库后端面对如此频繁的IO可能出现性能问题，甚至直接崩溃。就好比CPU和内存之间的关系，CPU处理的太快了，内存速度跟不上，这时最先想到的解决方案就是引入缓存
-  **目标**：
   -  加快用户访问速度，提高用户体验
   -  降低后端负载，减少潜在的风险，保证系统平稳
   -  保证数据“尽可能”及时更新

### 如何保证缓存与数据库的双写一致性

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

### 缓存可能引入的问题

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

### Redis部署

- 主从模式：一般主服务器写，从读。主服务器挂掉系统就挂了
- 哨兵sentinel模式：相对主从模式，多了监控主服务器，主挂掉能自动推举下一个主服务器，类似zookeeper，并且能发送故障通知。
- redis cluster：
  - 去中心化，去中间件，集群中的每个节点都是平等的关系
  - Redis 集群没有并使用传统的一致性哈希来分配数据，而是采用另外一种叫做`哈希槽 (hash slot)`的方式来分配的。redis cluster 默认分配了 16384 个slot，当我们set一个key 时，会用`CRC16`算法来取模得到所属的`slot`，然后将这个key 分到哈希槽区间的节点上，具体算法就是：`CRC16(key) % 16384`

### Redis持久化

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

### Redis常用数据类型

- String ：基本类型，二进制安全，可以存放图片序列化对象等
- Hash：String元素组成的字典
- List：列表
- Set：无序不重复集合
- Sorted Set：有序的Set

### Redis为什么快

- 完全基于内存，C语言编写
- 数据结构相对简单
- 单进程单线程的处理请求，从而确保高并发线程安全，想多核都用上可以通过启动多个实例
- 多路I/O复用，非阻塞

### Redis和 Memcache区别

- Memcache支持简单的数据类型，不支持持久化存储，不支持主从，不支持分片
- Redis数据类型丰富，支持持久化存储，支持主从，支持分片