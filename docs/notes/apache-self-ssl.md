# Apache支持HTTPS


### 1背景

需要Apache提供的服务支持HTTPS，要支持HTTPS首先要有证书，证书的制作过程参考本人的另一篇博客。

[自签的SSL证书创建与验证过程](https://freshchen.github.io/2019/02/18/self-ssl-signing/)

#### Apache版本


```bash
[root@controller httpd]# apachectl -v
Server version: Apache/2.4.6 (Red Hat Enterprise Linux)
```

#### 2配置

首先配置 **/etc/httpd/conf.d/ssl.conf**  ,填入生成的证书位置

```bash
SSLCertificateFile /root/ssl/self/server.crt
SSLCertificateKeyFile /root/ssl/self/server.key
```



如果我们想把所有的HTTP请求转为走HTTPS，可以在**/etc/httpd/conf/httpd.conf**  最下方加如下


```bash
RewriteEngine on
RewriteCond %{SERVER_PORT} !^443$
RewriteRule ^/?(.*)$ https://%{SERVER_NAME}/$1 [L,R]
```



#### 3.测试

用浏览器访问，或者curl命令查看请求过程
