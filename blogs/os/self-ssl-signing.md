# 自签的SSL证书创建与验证过程

### 1背景

最近在装一套openstack，装完突然接到需求，有些特定的服务接口需要支持HTTPS。之前对HTTPS的概念是在HTTP的基础上加上SSL证书做验证即可，自认为密码学中学过常用加密过程，应该问题不大吧！

[首先贴上证书相关对常用名词比较简洁的解释](http://www.cnblogs.com/guogangj/p/4118605.html)

由于只是想做简单的测试，所以并没有去申请CA证书，或者制作CA证书，只是制作最简单的签名证书。

### 2制作自签证书过程

#### 2.1安装openssl

#### 2.2开始制作

```bash
$ mkdir -p /root/ssl/
$ cd /root/ssl/

# 1.生成私钥
$ openssl genrsa -out server.key 2048

# 2.生成 CSR (Certificate Signing Request)
$ openssl req -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Home/OU=Home Software/CN=<域名或者IP>/emailAddress=961011595@qq.com" -new -key server.key -out server.csr

# 3.生成自签名证书，有效期3650天
$ openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
```

Tips：其中第二步签名过程也可以手动输入

```bash
openssl req -new -key server.key -out server.csr
# 手动填入如下信息
Country Name (2 letter code) [GB]:CH
State or Province Name (full name) [Berkshire]:Shanghai
Locality Name (eg, city) [Newbury]:Shanghai
Organization Name (eg, company) [My Company Ltd]:Home
Organizational Unit Name (eg, section) []:Information Technology
Common Name (eg, your name or your server's hostname) []:<域名或者IP> 很重要不能乱填
Email Address []:martin dot zahn at akadia dot ch
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```



### 3通过Nginx验证自签证书

#### 3.1安装Nginx

[Nginx安装过程以及常用命令](https://freshchen.github.io/2019/02/15/nginx-install/)

#### 3.2配置

在Nginx配置文件/usr/local/webserver/nginx/conf/nginx.conf中加入

    server {
        listen       443 ssl;
        server_name  localhost;
    
        ssl_certificate      /root/ssl/server.crt;
        ssl_certificate_key  /root/ssl/server.key;
    
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
    
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;
    
        location / {
            root   html;
            index  index.html index.htm;
        }
    }
重启Nginx服务

```bash
[root@localhost ~]# /usr/local/webserver/nginx/sbin/nginx -s stop
[root@localhost ~]# /usr/local/webserver/nginx/sbin/nginx
```

#### 3.3测试

第一次尝试失败，因为请求的不是签名时候填入的公司域名或者IP

```bash
[root@VM_0_9_centos ssl]# wget --ca-certificate=/root/ssl/server.crt https://localhost
--2019-02-18 14:05:02--  https://localhost/
Resolving localhost (localhost)... 127.0.0.1, ::1
Connecting to localhost (localhost)|127.0.0.1|:443... connected.
    ERROR: certificate common name ‘签名时候填入的公司域名或者IP’ doesn't match requested host name ‘localhost’.
To connect to localhost insecurely, use `--no-check-certificate'.
```

再次尝试成功

```bash
[root@VM_0_9_centos ssl]# wget --ca-certificate=/root/ssl/server.crt https://<签名时的公司域名或IP>
--2019-02-18 14:05:37--  https://签名时的公司域名或IP/
Connecting to 111.230.58.162:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 612 [text/html]
Saving to: ‘index.html.1’

100%[=======================================================================================================================================================================>] 612         --.-K/s   in 0s      

2019-02-18 14:05:37 (109 MB/s) - ‘index.html.1’ saved [612/612]
```

