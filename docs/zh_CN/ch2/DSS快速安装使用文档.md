# # 如何快速安装使用DataSphereStudio

### DataSphereStudio安装分为前端部分和后台部分，安装之前首先需要确定前、后端安装环境。

### 一、确定您的安装环境

#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DataSphereStudio根据组件丰富程度，安装环境略有差异，分为简单版和标准版，其区别如下：

----

1. **简单版**：

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;最少环境依赖，前后端基础环境部分仅需准备：[Linkis](https://github.com/WeBankFinTech/Linkis)、JAVA、MYSQL、[Nginx](https://www.nginx.com/) ，您即刻能享受到DSS已集成的数据开发Scriptis、工作流实时执行，可视化，邮件发送，DATACHECK和EVENTCHECK服务。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;点我进入[简单版DSS环境配置准备](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch2/DSS%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md#%E4%BA%8C%E7%AE%80%E5%8D%95%E7%89%88dss%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE%E5%87%86%E5%A4%87)

----


2. **标准版**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DSS还实现了很多外部系统的集成，如[Qualitis](https://github.com/WeBankFinTech/Qualitis)和[Azkaban](https://github.com/azkaban/azkaban)，如果您想使用这些外部系统，则需要在简单版的基础上，提前安装和启动好Qualitis和Azkaban服务，并确保其能够正常提供服务，并在配置中指定对应服务的IP和端口。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;点我进入[标准版DSS环境配置准备](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch2/DSS%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md#%E4%B8%89%E6%A0%87%E5%87%86%E7%89%88dss%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE%E5%87%86%E5%A4%87)

----

## 二、简单版DSS环境配置准备
DSS环境配置准备分为三部分，前后端基础软件安装、后端环境配置准备和前端环配置境准备，详细介绍如下：
### 2.1 前后端基础软件安装
Linkis标准版(0.9.1及以上)，[如何安装Linkis](https://github.com/WeBankFinTech/Linkis/wiki/%E5%A6%82%E4%BD%95%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8Linkis)

JDK (1.8.0_141以上)，[如何安装JDK](https://www.runoob.com/java/java-environment-setup.html) 

MySQL (5.5+)，[如何安装MySQL](https://www.runoob.com/mysql/mysql-install.html) 

Nginx，[如何安装Nginx](https://www.tecmint.com/install-nginx-on-centos-7/) 

### 2.2 后端环境配置准备

### a. 创建用户

  例如: **部署用户是hadoop账号**

在部署机器上创建部署用户，使用该用户进行安装。
```
     sudo useradd hadoop    
```

##### 注意:用户需要有sudo权限，且可免密登陆本机。[如何配置SSH免密登陆](https://www.jianshu.com/p/0922095f69f3)
```
      vi /etc/sudoers

      hadoop  ALL=(ALL)       NOPASSWD: NOPASSWD: ALL 
```

### b. 安装包准备

从DSS已发布的release中（[点击这里进入下载页面](https://github.com/WeBankFinTech/DataSphereStudio/releases)），下载对应安装包。先解压安装包到安装目录，并对解压后的文件进行配置修改

```
    tar -xvf  wedatasphere-dss-x.x.x-dist.tar.gz
```
##### 注意:如果安装包是用户自行编译的，则需要把[visualis-server安装包](https://github.com/WeBankFinTech/Visualis/releases)复制到DSS安装目录的share/visualis-server文件夹下，以供自动化安装使用

### c. 修改基础配置
   
```
    vi conf/config.sh   
```

```properties
<!--说明：以下为简单版DSS基础配置项，如果您想体验更多企业特性，请安装标准版DSS-->

    deployUser=hadoop  #指定部署用户

    DSS_INSTALL_HOME=/appcom/Install/DSS    #指定DSS的安装目录 

    EUREKA_INSTALL_IP=127.0.0.1 #Linkis的 EUREKA 服务主机IP地址
    
    EUREKA_PORT=20303  #Linkis的 EUREKA 服务端口号
    
    WORKSPACE_USER_ROOT_PATH=file:///tmp/Linkis   #指定用户根目录，存储用户的脚本文件和日志文件等，是用户的工作空间。

    RESULT_SET_ROOT_PATH=hdfs:///tmp/linkis  # 结果集文件路径，用于存储Job的结果集文件 

    #用于DATACHECK校验
    HIVE_META_URL=jdbc:mysql://127.0.0.1:3306/linkis?characterEncoding=UTF-8
    HIVE_META_USER=xxx
    HIVE_META_PASSWORD=xxx
    
```

### d. 修改数据库配置

```bash
    vi conf/db.sh 
```

```properties
    # 设置DSS-Server和Eventchecker AppJoint的数据库的连接信息。
    MYSQL_HOST=
    MYSQL_PORT=
    MYSQL_DB=
    MYSQL_USER=
    MYSQL_PASSWORD=
```

### 2.3 前端端环境配置准备

### a、下载安装包

   点击[release](https://github.com/WeBankFinTech/DataSphereStudio/releases) 下载对应安装包，并在安装目录进行解压：
   ```bash
       unzip wedatasphere-DataSphereStudio-x.x.x-dist.zip 
   ``` 
##### 注意:如果DSS前端安装包是用户自行编译的，则需要把[visualis前端安装包](https://github.com/WeBankFinTech/Visualis/releases)复制到DSS前端安装目录的dss/visualis文件夹下，以供自动化安装使用

### b、配置修改

&nbsp;&nbsp;&nbsp;&nbsp;进入前端工作目录,在该目录下编辑
```bash
    vi conf/config.sh 
```

更改dss的前端端口和后端linkis的gateway的IP地址及端口
```
# Configuring front-end ports
dss_port="8088"

# URL of the backend linkis gateway
linkis_url="http://127.0.0.1:9001"

# dss ip address
dss_ipaddr=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
```

   环境准备完毕，点我进入 [四、安装和使用](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch2/DSS%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md#%E5%9B%9B%E5%AE%89%E8%A3%85%E5%92%8C%E4%BD%BF%E7%94%A8)

## 三、标准版DSS环境配置准备
标准版DSS环境准备也分为三部分，前后端基础软件安装、后端环境准备和前端环境准备，详细介绍如下：
### 3.1 前后端基础软件安装
Linkis标准版(0.9.1及以上)，[如何安装Linkis](https://github.com/WeBankFinTech/Linkis/wiki/%E5%A6%82%E4%BD%95%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8Linkis)

JDK (1.8.0_141以上)，[如何安装JDK](https://www.runoob.com/java/java-environment-setup.html)

MySQL (5.5+)，[如何安装MySQL](https://www.runoob.com/mysql/mysql-install.html)

Nginx，[如何安装Nginx](https://www.tecmint.com/install-nginx-on-centos-7/)

Qualitis [如何安装Qualitis](https://github.com/WeBankFinTech/Qualitis/blob/master/docs/zh_CN/ch1/%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BA%E6%89%8B%E5%86%8C.md)

Azkaban [如何安装Azkaban](https://github.com/azkaban/azkaban) 
##### 注意：支持Azkaban调度需要配套安装linkis-jobtype，请点击[Linkis jobType安装文档](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch2/Azkaban_LinkisJobType_Deployment_Manual.md)

### 3.2 后端环境配置准备

### a. 创建用户

  例如: **部署用户是hadoop账号**

在部署机器上创建部署用户，使用该用户进行安装。
```
     sudo useradd hadoop    
```

##### 注意:用户需要有sudo权限，且可免密登陆本机。[如何配置SSH免密登陆](https://www.jianshu.com/p/0922095f69f3)
```
      vi /etc/sudoers

      hadoop  ALL=(ALL)       NOPASSWD: NOPASSWD: ALL 
```

### b. 安装包准备

从DSS已发布的release中（[点击这里进入下载页面](https://github.com/WeBankFinTech/DataSphereStudio/releases)），下载对应安装包。先解压安装包到安装目录，并对解压后的文件进行配置修改

```
    tar -xvf  wedatasphere-dss-x.x.x-dist.tar.gz
```
##### 注意:如果安装包是用户自行编译的，则需要把[visualis-server安装包](https://github.com/WeBankFinTech/Visualis/releases)复制到DSS安装目录的share/visualis-server文件夹下，以供自动化安装使用

### c. 修改基础配置
   
```
    vi conf/config.sh   
```

```properties
<!--说明：以下为标准版DSS必须配置项，请确保外部服务可用-->

    deployUser=hadoop  #指定部署用户

    DSS_INSTALL_HOME=/appcom/Install/DSS    #指定DSS的安装目录 

    EUREKA_INSTALL_IP=127.0.0.1 #Linkis的 EUREKA 服务主机IP地址
    
    EUREKA_PORT=20303  #Linkis的 EUREKA 服务端口号
    
    WORKSPACE_USER_ROOT_PATH=file:///tmp/Linkis   #指定用户根目录，存储用户的脚本文件和日志文件等，是用户的工作空间。

    RESULT_SET_ROOT_PATH=hdfs:///tmp/linkis  # 结果集文件路径，用于存储Job的结果集文件 
    
    WDS_SCHEDULER_PATH=file:///appcom/tmp/wds/scheduler #Azkaban工程存储目录

    #1、用于DATACHECK
    HIVE_META_URL=jdbc:mysql://127.0.0.1:3306/linkis?characterEncoding=UTF-8
    HIVE_META_USER=xxx
    HIVE_META_PASSWORD=xxx
    #2、用于Qualitis
    QUALITIS_ADRESS_IP=127.0.0.1 #QUALITIS服务IP地址
    QUALITIS_ADRESS_PORT=9991 #QUALITIS服务端口号 
    #3、用于AZKABAN
    AZKABAN_ADRESS_IP=127.0.0.1 #AZKABAN服务IP地址
    AZKABAN_ADRESS_PORT=9987 #AZKABAN服务端口号
    
```

### d. 修改数据库配置

```bash
    vi conf/db.sh 
```

```properties
    # 设置DSS-Server和Eventchecker AppJoint的数据库的连接信息。
    MYSQL_HOST=
    MYSQL_PORT=
    MYSQL_DB=
    MYSQL_USER=
    MYSQL_PASSWORD=
```

### 3.3 前端环境配置准备

### a、下载安装包

   点击[release](https://github.com/WeBankFinTech/DataSphereStudio/releases) 选择安装包下载，并在安装目录进行解压：
   ```bash
       unzip wedatasphere-DataSphereStudio-x.x.x-dist.zip 
   ```
##### 注意:如果DSS前端安装包是用户自行编译的，则需要把[visualis前端安装包](https://github.com/WeBankFinTech/Visualis/releases)复制到DSS前端安装目录的dss/visualis文件夹下，以供自动化安装使用

### b、配置修改

&nbsp;&nbsp;&nbsp;&nbsp;进入前端工作目录,在该目录下编辑
```bash
    vi conf/config.sh 
```


更改dss的前端端口和后端linkis的gateway的IP地址及端口
```
# Configuring front-end ports
dss_port="8088"

# URL of the backend linkis gateway
linkis_url="http://127.0.0.1:9001"

# dss ip address
dss_ipaddr=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
```

   环境准备完毕，点我进入 [四、安装和使用](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch2/DSS%E5%BF%AB%E9%80%9F%E5%AE%89%E8%A3%85%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md#%E5%9B%9B%E5%AE%89%E8%A3%85%E5%92%8C%E4%BD%BF%E7%94%A8)

# 四、安装和使用

## 4.1. DataSphereStudio 后台安装：

### a. 执行安装脚本：

```bash
    sh bin/install.sh
```

### b. 安装步骤

- install.sh脚本会询问您安装模式。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;安装模式就是简单模式或标准模式，请根据您准备的环境情况，选择合适的安装模式，简单模式和标准模式都会检查mysql服务，标准模式还会检测Qualitis服务和Azkaban服务，如果检测失败会直接退出安装。

- install.sh脚本会询问您是否需要初始化数据库并导入元数据。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;因为担心用户重复执行install.sh脚本，把数据库中的用户数据清空，所以在install.sh执行时，会询问用户是否需要初始化数据库并导入元数据。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**第一次安装**必须选是。

- install.sh脚本会询问您是否需要初始化使用[davinci](https://github.com/edp963/davinci)所依赖的库表,如果您没有安装过davinci，则需要进行初始化建表，如果您已经安装了davinci，则无需再次初始化。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;因为担心用户会mysql中已安装好的davinci数据清空，所以在install.sh执行时，会询问用户是否需要初始化。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**第一次安装**必须选是。


### c. 是否安装成功：

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;通过查看控制台打印的日志信息查看是否安装成功。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;如果有错误信息，可以查看具体报错原因。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;您也可以通过查看我们的[常见问题](https://github.com/WeBankFinTech/DataSphereStudio/wiki/FAQ)，获取问题的解答。

### d. 启动DataSphereStudio后台服务

#### (1)、启动服务：
  
  在安装目录执行以下命令，启动所有服务：    

  ./bin/start-all.sh > start.log 2>start_error.log
  
#### (2)、查看是否启动成功
    
  可以在Eureka界面查看服务启动成功情况，查看方法：
    
  使用http://${EUREKA_INSTALL_IP}:${EUREKA_PORT}, 在浏览器中打开，查看服务是否注册成功。
    
  如果您没有在config.sh指定EUREKA_INSTALL_IP和EUREKA_INSTALL_IP，则HTTP地址为：http://127.0.0.1:20303
    
  如下图，如您的Eureka主页出现以下微服务，则表示服务都启动成功，可以正常对外提供服务了：
    
  ![Eureka](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/images/zh_CN/chapter2/quickInstallUse/quickInstall.png)

## 4.2 DataSphereStudio前端安装

### a、部署

&nbsp;&nbsp;&nbsp;&nbsp;进入前端工作目录，执行安装脚本


```bash
    sh bin/install.sh
```

执行完后可以直接通过在谷歌浏览器访问：

```http://dss_ipaddr:dss_port``` 

其中dss_port为config.sh里面配置的端口，dss_ipaddr为安装机器的IP。

如果访问失败：可以通过查看 install.log的日志查看哪一步出错

#### b、如果您想手动安装前端，具体步骤如下：

1.修改配置文件：sudo vi /etc/nginx/conf.d/dss.conf
添加如下内容：
```
server {
            listen       8080;# 访问端口
            server_name  localhost;
            #charset koi8-r;
            #access_log  /var/log/nginx/host.access.log  main;
            location /dss/visualis {
            root   /appcom/Install/DSS/FRONT/dss/visualis; # visualis静态文件目录
            autoindex on;
            }
            location / {
            root   /appcom/Install/DSS/FRONT/dist; # 前端包解压的目录
            index  index.html index.html;
            }
            location /ws {#webSocket配置支持
            proxy_pass http://192.168.xxx.xxx:9001;#linkis-gateway服务的ip端口
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            }
            location /api {
            proxy_pass http://192.168.xxx.xxx:9001; # linkis-gateway服务的ip端口
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header x_real_ipP $remote_addr;
            proxy_set_header remote_addr $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_connect_timeout 4s;
            proxy_read_timeout 600s;
            proxy_send_timeout 12s;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection upgrade;
            }
            #error_page  404              /404.html;
            # redirect server error pages to the static page /50x.html
            #
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
            root   /usr/share/nginx/html;
            }
        }

```

### 2.将前端包拷贝到对应的目录:
```/appcom/Install/DSS/FRONT; # 前端包安装目录 ```

##### 注意: 手动安装DSS前端，则需要到DSS前端安装目录的dss/visualis文件夹下，解压visualis前端安装包。

### 3.启动服务
```sudo systemctl restart nginx```

### 4.谷歌浏览器访问：
```http://nginx_ip:nginx_port```

如何详细使用DSS, 点我进入 [DSS详细使用文档](https://github.com/WeBankFinTech/DataSphereStudio/blob/master/docs/zh_CN/ch3/DSS_User_Manual.md)

## 4.3、常见问题

(1)上传文件大小限制

```
sudo vi /etc/nginx/nginx.conf
```

更改上传大小

```
client_max_body_size 200m
```

 (2)接口超时

```
sudo vi /etc/nginx/conf.d/dss.conf
```


更改接口超时时间

```
proxy_read_timeout 600s
```

