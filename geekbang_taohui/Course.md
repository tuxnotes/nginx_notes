# 1 综述

由于Nginx与硬件和操作系统的深度挖掘，使得其在保持高并发的前提下实现了高吞吐量。其优秀的模块设计使得其生态圈异常丰富。大量的第三方模块使得Nginx轻松实现大量场景下的定制化需求。BSD许可证又赋予Nginx最大的灵活性。

### 1.1 Nginx优点

 - 高并发，高性能
 - 可扩展性好
 - 高可靠性
 - 热部署
 - BSD许可

### 1.2 课程模块

 - 初识Nginx
 - Nginx架构基础
 - 详解HTTP模块
 - 反向代理与负载均衡
 - Nginx的系统层性能优化
 - 从源码视角深入使用Nginx与Openresty

初识Nginx：快速了解Nginx，熟悉其基本使用

Nginx架构基础：进程模型，数据结果

详解HTTP模块：Nginx是如何处理请求的，依照处理流程来讲解常用HTTP模块中的指令、变量的用法

反向代理与负载均衡：以7层负载均衡为主，兼顾4层负载均衡，实现不同上游协议的反向代理，理解如何配置才能处理上下游流量的高效交互

Nginx的系统层性能优化：有效调节Linux系统下的CPU、内存、网络、磁盘等配置与Nginx config文件中的指令如何配合。使Nginx性能最大化

从源码视角深入使用Nginx与Openresty：从Nginx的实现层面打通前5个方面的知识，从而理解Nginx的机制与能力模型，并介绍openresty与Nginx如何有效搭配使用

# 2 初识Nginx

## 2.1 使用场景

最重用的三个使用场景：

 - 静态资源服务：通过本地文件系统提供服务
 - 反向代理服务：Nginx的强大性能；缓存；负载均衡
 - API服务：OpenResty

Nginx的三个主要应用场景

![](/home/tux/Documents/nginx/geekbang_taohui/use_case.png)

### 2.1.1 第一个应用场景

**反向代理**

- 负载均衡
- 缓存加速

上图中，一个请求过来后先到Nginx, 然后到应用服务，如Django, Tomcat等。然后再去访问redis或MySQL数据库，提供基本的数据功能。但这里有个问题：我们的应用服务因为要求开发效率非常的高，所以它的运行效率是很低的。它的QPS TPS 或并发都是受限的，所以我们需要把很多这样的应用服务组成一个集群，向用户提供高可用性。而一旦很多服务构成集群的时候，我们需要Nginx具有反向代理功能，可以把动态请求传到给应用服务。而很多应用服务构成集群，它一定会带来两个需求：第一，动态扩容；第二，有些服务出问题的时候我们需要做容灾，这样我们的反向代理必须具备负载均衡功能。

像这样的一个链路中，Nginx处于企业内网的边缘节点，随着网络链路的增长，用户体验到的时延会增加，所以可以把用户看起来不变的，或一段时间内看起来不变的动态内容缓存在Nginx部分，由Nginx直接像用户提供访问。这样时延就会减小很多。这样反向代理就衍生出另外一个功能叫缓存，它能加速我们的访问。

### 2.1.2 第二个应用场景

**静态资源**

而很多时候我们访问的css js html 图片这些静态资源是没必要由应用服务来访问的,它只需要通过本地文件，系统上放置的静态资源，直接由Nginx提供访问即可。这是Nginx的静态资源功能。

### 2.1.3 第三个应用场景

**API服务**

因为应用服务本身的性能有很多的问题，但数据库服务要比应用服务好的多，因为它的业务场景比较简单，它的并发性能和TPS都远高于应用服务，所以衍生出第三个应用场景，由Nginx直接去访问数据库或redis或应用服务，利用Nginx强大的并发性能，实现如web防火墙，这样复杂的业务功能来提供给用户。这样这要求我们的API服务有非常强大的业务处理功能，如openresty, Nginx集成javascript， 利用javascript或lua语言先天自带的工具库来提供完整的API服务。

## 2.2 Nginx出现的历史背景

Nginx为什么会出现？

主要原因：

1. 互联网的数据量快速增长

   互联网的快速普及

   全球化

   物联网

2. 摩尔定律：性能提升

   CPU频率的提高受限，开始想多核方向发展，但很多软件并没有为多核架构做好准备。

3. 低效的Apache

   一个连接对应一个进程，使用了进程间切换，进程间切换代价很高。

## 2.3 Nginx的使用优点

1. 高并发，高性能
2. 可扩展性好
3. 高可靠
4. 热部署，不重启进行升级
5. BSD许可证

## 2.4 Nginx的四个主要组成部分

### 2.4.1 Nginx二进制可执行文件

由各模块源码编译出的一个文件

由Nginx本身的框架、官方模块、编译进去的各种第三方模块一起构建的文件。相当于汽车本身

### 2.4.2 配置文件

nginx.conf-控制Nginx行为，相当于驾驶员

### 2.4.3 访问日志

access.log记录每一条http请求信息，tps轨迹-运营

### 2.4.4 错误日志

定位问题

## 2.5 Nginx的版本发布历史

版本发布情况：

mainline：单号，新增很多功能，但可能不稳定

stable：双号，稳定版

**版本选择**

开源：Nginx --- nginx.org

商业：Nginx Plus --- nginx.org

阿里巴巴Tengine:

Tengine是由淘宝网发起的Web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。Tengine的性能和稳定性已经早大型的网站如淘宝网，天猫商城等得到了很好的检验。Tengine很多特性领先于Nginx官方版本，其修改了Nginx官方版本的主干代码，这样就遇到一个问题，就是没办法跟Nginx的官方版本同步升级。所以虽然其生态也很丰富，也可以使用官方的第三方模块，但由于这个特点，不推荐使用。

Openresty

开源版与商业版

开源Openresty: http://openresty.org

商业版openrestry: https://openresty.com

**如果业务功能没太强的诉求，那开源的Nginx即可满足。如果开发API服务或web防火墙，则Openresty是个很好的选择**

## 2.6 编译Nginx

Nginx的官方模块不是每个都是默认开启的，需要编译开启。这样才能将第三方模块编译进Nginx的二进制文件中。

### 2.6.1 源码目录介绍

下载nginx源码文件并解压:

```bash
# wget https://nginx.org/download/nginx-1.14.2.tar.gz
# wget https://nginx.org/download/nginx-1.14.2.tar.gz
# wget https://nginx.org/download/nginx-1.14.2.tar.gz
[root@development nginx-1.14.2]# ll
total 736
drwxr-xr-x 6 nginx nginx   4096 Oct 31 13:29 auto
-rw-r--r-- 1 nginx nginx 288742 Dec  4  2018 CHANGES
-rw-r--r-- 1 nginx nginx 440121 Dec  4  2018 CHANGES.ru
drwxr-xr-x 2 nginx nginx   4096 Oct 31 13:29 conf
-rwxr-xr-x 1 nginx nginx   2502 Dec  4  2018 configure
drwxr-xr-x 4 nginx nginx     68 Oct 31 13:29 contrib
drwxr-xr-x 2 nginx nginx     38 Oct 31 13:29 html
-rw-r--r-- 1 nginx nginx   1397 Dec  4  2018 LICENSE
drwxr-xr-x 2 nginx nginx     20 Oct 31 13:29 man
-rw-r--r-- 1 nginx nginx     49 Dec  4  2018 README
drwxr-xr-x 9 nginx nginx     84 Oct 31 13:29 src
```

auto目录: 4个子目录, cc directory-- used for complie

​					lib directory-- library

​					os directory - detect os type

​				其他的文件是辅助configure脚本执行的时候去判定支持哪些模块，当前操作系统有什么特性可以供给Nginx使用

change文件：Nginx每个版本提供了哪些特性和Bug fix

conf目录：配置文件示例目录，里面包含配置文件模板，安装后拷贝到Nginx的配置文件目录

configure文件：脚本，用来生成中间文件，zhixi编译前的必备动作

contrib目录：提供了2个perl脚本和vim的工具，提供配置文件语法高亮等支持。使用方法：

```bash
[root@development nginx-1.14.2]# cp -r contrib/vim/* ~/.vim/
```

html目录：提供了两个标准的 html文件，50x错误和Index.html欢迎页面 

man目录：Linux对Nginx的帮助文件,查看帮助文件内容

```bash
[root@development man]# ls
nginx.8
[root@development man]# man ./nginx.8 
```

src目录：源代码，框架都这个目录中

### 2.6.2 Configuration

编译前先看看configure支持哪些参数：

```bash
[root@development nginx-1.14.2]# ./configure --help | more
```

这里分为几个大块：

1 PATH相关，编译时去哪里找一些文件作为其辅助文件

如动态模块--modules-path=PATH

nginx.lock文件的位置：--lock-path=PATH

如果没有变动，则只需要指定--prefix=PATH,其他的配置则在prefix指定的目录中建立响应的文件夹

2 第二类参数主要是确定使用哪些模块，不使用哪些模块。参数的前缀通常是with 或without. 带with的，意味着默认是不会编译进nginx的；带without的默认是便已进Nginx的。

3 第三类参数指定了Nginx编译过程中需要的特殊参数。如gcc编译需要设定的优化参数，开启debug级别日志等

configure：

```bash
[root@development nginx-1.14.2]# ./configure --prefix=/root/nginx # /root/nginx目录此时可以不存在 
```

configure之后会生成一些中间文件，放到objs目录

### 2.6.3 生成中间文件介绍

```bash
[root@development objs]# pwd
/root/nginx-1.14.2/objs
[root@development objs]# ll
total 80
-rw-r--r-- 1 root root 17628 Nov  4 12:46 autoconf.err
-rw-r--r-- 1 root root 39263 Nov  4 12:46 Makefile
-rw-r--r-- 1 root root  6793 Nov  4 12:46 ngx_auto_config.h
-rw-r--r-- 1 root root   657 Nov  4 12:46 ngx_auto_headers.h
-rw-r--r-- 1 root root  5725 Nov  4 12:46 ngx_modules.c
drwxr-xr-x 9 root root    84 Nov  4 12:46 src
```

这里比较重要的是ngx_modules.c文件，它决定了接下来编译的时候有哪些模块会被编译进Nginx。

所有的模块都列在这个文件中

### 2.6.3 执行编译

```bash
[root@development nginx-1.14.2]# pwd
/root/nginx-1.14.2
[root@development nginx-1.14.2]# make
```

make没有错误的话，编译后的nginx二进制文件放在objs目录中。这里需要知道编译后二进制文件的位置，因为在升级的过程中，make之后并不是执行make install进行安装升级，而是将make之后生成的二进制文件拷贝到安装目录中

编译时生的中间文件都放在objs/src文件中

安装:

```bash
[root@development nginx-1.14.2]# make install
[root@development nginx-1.14.2]# ll /root/nginx
total 4
drwxr-xr-x 2 root root 4096 Nov  4 13:02 conf
drwxr-xr-x 2 root root   38 Nov  4 13:02 html
drwxr-xr-x 2 root root    6 Nov  4 13:02 logs
drwxr-xr-x 2 root root   18 Nov  4 13:02 sbin
```

## 2.7 Nginx配置语法

Nginx配置文件是一个ascii文本文件，主要由两部分组成：一部分是directive指令；一部分是directive block指令块。

1. 配置文件由指令和指令块构成
2. 每条指令以; 分号结尾，指令与参数间以空格分隔
3. 指令块以{}大括号将多条指令组织在一起
4. include语句允许组合多个配置文件以提升可维护性
5. 使用#符号添加注释，提高可读性
6. 使用$符号使用变量
7. 部分执行的参数支持正则表达式

```nginx
http {
    include		mime.types;
    upstream thwp {
        server 127.0.0.1:8000;
    }
    
    server {
        listen 443 http2;
        #Nginx配置语法
        limit req zone $binary_remote_addr zone=one:10m rate=1r/s;
        location ~* \.(gif|jpg|jpeg)$ {
            proxy_cache my_cache;
            expires 3m;proxy_cache_key $host$uri$is_args$args;
            proxy_pass http://thwp;
        }
    }
}
```

**配置参数：时间的单位**

ms		milliseconds

s		seconds

m		minutes

h		hours

d 		days

w		weeks

M		months, 30 days

y		years, 365 days

**配置参数: 空间的单位**

当数字后不加任何空间单位时，表示bytes

 		bytes

k/K		kilobytes

m/M	megabytes

g/G		gigabytes

**http配置的指令块**

包含4个块：

- http
- upstream
- server
- location









