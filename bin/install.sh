#!/bin/sh
#Actively load user env
source ~/.bash_profile

shellDir=`dirname $0`
workDir=`cd ${shellDir}/..;pwd`

#To be compatible with MacOS and Linux
txt=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    txt="''"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # linux
    txt=""
elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo "dss not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "dss not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "win32" ]]; then
    echo "dss not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "freebsd"* ]]; then

    txt=""
else
    echo "Operating system unknown, please tell us(submit issue) for better service"
    exit 1
fi

function isSuccess(){
if [ $? -ne 0 ]; then
    echo "Failed to " + $1
    exit 1
else
    echo "Succeed to" + $1
fi
}

function checkJava(){
	java -version
	isSuccess "execute java --version"
}

function checkExternalServer(){
echo "telnet check for your $SERVER_NAME, if you wait for a long time,may be your $SERVER_NAME does not prepared"
result=`echo -e "\n" | telnet $EXTERNAL_SERVER_IP $EXTERNAL_SERVER_PORT 2>/dev/null | grep Connected | wc -l`
if [ $result -eq 1 ]; then
      echo "$SERVER_NAME is OK."
else
      echo "$SERVER_NAME is Bad. You need to prepare the' $SERVER_NAME ' environment in advance"
      exit 1
fi
}

function checkPythonAndJava(){
	python --version
	isSuccess "execute python --version"
	java -version
	isSuccess "execute java --version"
}

function checkHadoopAndHive(){
	hdfs version
	isSuccess "execute hdfs version"
	hive --help
	#isSuccess "execute hive -h"
}

function checkSpark(){
	spark-submit --version
	isSuccess "execute spark-submit --version"
}

##install env:expect,
sudo yum install -y expect
isSuccess "install expect"

##install env:telnet,
sudo yum install -y telnet
isSuccess "install telnet"

##load config
echo "step1:load config"
source ${workDir}/conf/config.sh
source ${workDir}/conf/db.sh
isSuccess "load config"

local_host="`hostname --fqdn`"

##env check
echo "Please enter the mode selection such as: 1"
echo " 1: Simple"
echo " 2: Standard"
echo ""

INSTALL_MODE=1

read -p "Please input the choice:"  idx
if [[ '1' = "$idx" ]];then
  INSTALL_MODE=1
  echo "You chose Simple installation mode"
  #check for Java
  checkJava
  #check for mysql
  SERVER_NAME=MYSQL
  EXTERNAL_SERVER_IP=$MYSQL_HOST
  EXTERNAL_SERVER_PORT=$MYSQL_PORT
  checkExternalServer

elif [[ '2' = "$idx" ]];then
  INSTALL_MODE=2
  echo "You chose Standard installation mode"
  #check for Java
  checkJava
  #check for mysql
  SERVER_NAME=MYSQL
  EXTERNAL_SERVER_IP=$MYSQL_HOST
  EXTERNAL_SERVER_PORT=$MYSQL_PORT
  checkExternalServer
  #check  qualitis serivice
  SERVER_NAME=Qualitis
  EXTERNAL_SERVER_IP=$QUALISTIS_ADRESS_IP
  EXTERNAL_SERVER_PORT=$QUALISTIS_ADRESS_PORT
  checkExternalServer
  #check  azkaban serivice
  SERVER_NAME=AZKABAN
  EXTERNAL_SERVER_IP=$AZKABAN_ADRESS_IP
  EXTERNAL_SERVER_PORT=$AZKABAN_ADRESS_PORT
  checkExternalServer

else
  echo "no choice,exit!"
  exit 1
fi

##env check
echo "Do you want to clear Dss table information in the database?"
echo " 1: Do not execute table-building statements"
echo " 2: Dangerous! Clear all data and rebuild the tables."
echo ""

MYSQL_INSTALL_MODE=1

read -p "Please input the choice:"  idx
if [[ '2' = "$idx" ]];then
  MYSQL_INSTALL_MODE=2
  echo "You chose Rebuild the table"
elif [[ '1' = "$idx" ]];then
  MYSQL_INSTALL_MODE=1
  echo "You chose not execute table-building statements"
else
  echo "no choice,exit!"
  exit 1
fi

##init db
if [[ '2' = "$MYSQL_INSTALL_MODE" ]];then
	mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -D$MYSQL_DB --default-character-set=utf8 -e "source ${workDir}/db/dss_ddl.sql"
	isSuccess "source linkis_ddl.sql"
	LOCAL_IP="`ifconfig | grep 'inet' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}'`"
	if [ $GATEWAY_INSTALL_IP == "127.0.0.1" ];then
        echo "GATEWAY_INSTALL_IP is equals 127.0.0.1 ,we will change it to ip address"
        GATEWAY_INSTALL_IP_2=$LOCAL_IP
    else
        GATEWAY_INSTALL_IP_2=$GATEWAY_INSTALL_IP
    fi
    echo $GATEWAY_INSTALL_IP_2
    sed -i "s/GATEWAY_INSTALL_IP_2/$GATEWAY_INSTALL_IP_2/g" ${workDir}/db/dss_dml.sql
    sed -i "s/GATEWAY_PORT/$GATEWAY_PORT/g" ${workDir}/db/dss_dml.sql
    if [ $AZKABAN_ADRESS_IP == "127.0.0.1" ];then
        echo "AZKABAN_ADRESS_IP is equals 127.0.0.1 ,we will change it to ip address"
        AZKABAN_ADRESS_IP_2=$LOCAL_IP
    else
        AZKABAN_ADRESS_IP_2=$AZKABAN_ADRESS_IP
    fi
    echo $AZKABAN_ADRESS_IP_2
    sed -i "s/AZKABAN_ADRESS_IP_2/$AZKABAN_ADRESS_IP_2/g" ${workDir}/db/dss_dml.sql
    sed -i "s/AZKABAN_ADRESS_PORT/$AZKABAN_ADRESS_PORT/g" ${workDir}/db/dss_dml.sql
    if [ $VISUALIS_NGINX_IP == "127.0.0.1" ]||[ $VISUALIS_NGINX_IP == "0.0.0.0" ];then
        echo "VISUALIS_NGINX_IP is equals $VISUALIS_NGINX_IP ,we will change it to ip address"
        VISUALIS_NGINX_IP_2=$LOCAL_IP
    else
        VISUALIS_NGINX_IP_2=$VISUALIS_NGINX_IP
    fi
    echo $VISUALIS_NGINX_IP_2
    sed -i "s/VISUALIS_NGINX_IP_2/$VISUALIS_NGINX_IP_2/g" ${workDir}/db/dss_dml.sql
    sed -i "s/VISUALIS_NGINX_PORT/$VISUALIS_NGINX_PORT/g" ${workDir}/db/dss_dml.sql
	mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -D$MYSQL_DB --default-character-set=utf8 -e "source ${workDir}/db/dss_dml.sql"
	isSuccess "source linkis_dml.sql"
	echo "Rebuild the table"
fi

##env check
echo "Do you want to clear davinci table information in the database ? If you have not installed davinci environment,you must input '2',if you have davinci installed,choice 1."
echo " 1: Do not execute table-building statements"
echo "WARN:"
echo " 2: Dangerous! Clear all data and rebuild the tables."
echo ""
DAVINCI_INSTALL_MODE=1
read -p "Please input the choice:"  idx
if [[ '2' = "$idx" ]];then
  DAVINCI_INSTALL_MODE=2
  echo "You chose rebuild davinci's table !!! start rebuild all tables"
  mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -D$MYSQL_DB --default-character-set=utf8 -e "source ${workDir}/db/davinci.sql"
  isSuccess "source davinci.sql"
  echo ""
elif [[ '1' = "$idx" ]];then
  DAVINCI_INSTALL_MODE=1
  echo "You chose not execute table-building statements"
  echo ""
else
  echo "no choice,exit!"
  exit 1
fi


###linkis Eurkea info
SERVER_IP=$EUREKA_INSTALL_IP
SERVER_PORT=$EUREKA_PORT
SERVER_HOME=$DSS_INSTALL_HOME

if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi
EUREKA_URL=http://$SERVER_IP:$EUREKA_PORT/eureka/

##function start
function installPackage(){
echo "start to install $SERVERNAME"
echo "$SERVERNAME-step1: create dir"
if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi

if ! ssh -p $SSH_PORT $SERVER_IP test -e $SERVER_HOME; then
  ssh  -p $SSH_PORT $SERVER_IP "sudo mkdir -p $SERVER_HOME;sudo chown -R $deployUser:$deployUser $SERVER_HOME"
  isSuccess "create the dir of  $SERVERNAME"
fi

echo "$SERVERNAME-step2:copy install package"
scp   -P $SSH_PORT   ${workDir}/share/$PACKAGE_DIR/$SERVERNAME.zip $SERVER_IP:$SERVER_HOME
isSuccess "copy  ${SERVERNAME}.zip"
ssh  -p $SSH_PORT $SERVER_IP "cd $SERVER_HOME/;rm -rf $SERVERNAME-bak; mv -f $SERVERNAME $SERVERNAME-bak"
ssh  -p $SSH_PORT $SERVER_IP "cd $SERVER_HOME/;unzip $SERVERNAME.zip > /dev/null"
ssh  -p $SSH_PORT $SERVER_IP "cd $SERVER_HOME/;scp -r lib/*  $SERVERNAME/lib"
isSuccess "unzip  ${SERVERNAME}.zip"

echo "$SERVERNAME-step3:subsitution conf"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/application.yml
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#port:.*#port: $SERVER_PORT#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#defaultZone:.*#defaultZone: $EUREKA_URL#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#hostname:.*#hostname: $SERVER_IP#g\" $SERVER_CONF_PATH"
isSuccess "subsitution conf of $SERVERNAME"
}
##function end

##function start
function installVisualis(){
echo "start to install $SERVERNAME"
echo "$SERVERNAME-step1: create dir"
if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi

if ! ssh -p $SSH_PORT $SERVER_IP test -e $SERVER_HOME; then
  ssh  -p $SSH_PORT $SERVER_IP "sudo mkdir -p $SERVER_HOME;sudo chown -R $deployUser:$deployUser $SERVER_HOME"
  isSuccess "create the dir of  $SERVERNAME"
fi

echo "$SERVERNAME-step2:copy install package"
scp   -P $SSH_PORT   ${workDir}/share/$PACKAGE_DIR/$SERVERNAME.zip $SERVER_IP:$SERVER_HOME
isSuccess "copy  ${SERVERNAME}.zip"
ssh  -p $SSH_PORT $SERVER_IP "cd $SERVER_HOME/;rm -rf $SERVERNAME-bak; mv -f $SERVERNAME $SERVERNAME-bak"
ssh  -p $SSH_PORT $SERVER_IP "cd $SERVER_HOME/;unzip $SERVERNAME.zip > /dev/null"
isSuccess "unzip  ${SERVERNAME}.zip"
}
##function end


##function start
function installAppjoints(){
echo "start to install $APPJOINTNAME"
echo "$APPJOINTNAME Install-step1: create dir"
if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi

if ! ssh  -p $SSH_PORT  $SERVER_IP test -e $SERVER_HOME/$APPJOINTPARENT; then
  ssh  -p $SSH_PORT  $SERVER_IP "sudo mkdir -p $SERVER_HOME/$APPJOINTPARENT;sudo chown -R $deployUser:$deployUser $SERVER_HOME/$APPJOINTPARENT"
  isSuccess "create the dir of  $SERVER_HOME/$APPJOINTPARENT;"
fi

echo "$APPJOINTNAME-step2:copy install package"
scp  -P $SSH_PORT  $SERVER_HOME/share/appjoints/$APPJOINTNAME/*.zip  $SERVER_IP:$SERVER_HOME/$APPJOINTPARENT
isSuccess "copy  ${APPJOINTNAME}.zip"
ssh  -p $SSH_PORT  $SERVER_IP "cd $SERVER_HOME/$APPJOINTPARENT/;unzip -o dss-$APPJOINTNAME-appjoint.zip > /dev/null;rm -rf dss-$APPJOINTNAME-appjoint.zip"
isSuccess "install  ${APPJOINTNAME}.zip"
}
##function end

##Dss-Server Install
PACKAGE_DIR=dss/dss-server
SERVERNAME=dss-server
SERVER_IP=$DSS_SERVER_INSTALL_IP
SERVER_PORT=$DSS_SERVER_PORT
SERVER_HOME=$DSS_INSTALL_HOME
###install Dss-Server
installPackage
###update Dss-Server linkis.properties
echo "$SERVERNAME-step4:update linkis.properties"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/linkis.properties
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.linkis.server.mybatis.datasource.url.*#wds.linkis.server.mybatis.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}?characterEncoding=UTF-8#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.linkis.server.mybatis.datasource.username.*#wds.linkis.server.mybatis.datasource.username=$MYSQL_USER#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.linkis.server.mybatis.datasource.password.*#wds.linkis.server.mybatis.datasource.password=$MYSQL_PASSWORD#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.dss.appjoint.scheduler.azkaban.address.*#wds.dss.appjoint.scheduler.azkaban.address=http://${AZKABAN_ADRESS_IP}:${AZKABAN_ADRESS_PORT}#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.linkis.gateway.ip.*#wds.linkis.gateway.ip=$GATEWAY_INSTALL_IP#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.dataworlcloud.gateway.port.*#wds.dataworlcloud.gateway.port=$GATEWAY_PORT#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#wds.dss.appjoint.scheduler.project.store.dir.*#wds.dss.appjoint.scheduler.project.store.dir=$WDS_SCHEDULER_PATH#g\" $SERVER_CONF_PATH"
isSuccess "subsitution linkis.properties of $SERVERNAME"
echo "<----------------$SERVERNAME:end------------------->"
echo ""
##Flow execution Install
PACKAGE_DIR=dss/dss-flow-execution-entrance
SERVERNAME=dss-flow-execution-entrance
SERVER_IP=$FLOW_EXECUTION_INSTALL_IP
SERVER_PORT=$FLOW_EXECUTION_PORT
SERVER_HOME=$DSS_INSTALL_HOME
###Install flow execution
installPackage
###Update flow execution linkis.properties
echo "$SERVERNAME-step4:update linkis.properties"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/linkis.properties
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.linkis.entrance.config.logPath.*#wds.linkis.entrance.config.logPath=$WORKSPACE_USER_ROOT_PATH#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.linkis.resultSet.store.path.*#wds.linkis.resultSet.store.path=$RESULT_SET_ROOT_PATH#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.linkis.gateway.url.*#wds.linkis.gateway.url=http://${GATEWAY_INSTALL_IP}:${GATEWAY_PORT}#g\" $SERVER_CONF_PATH"
isSuccess "subsitution linkis.properties of $SERVERNAME"
echo "<----------------$SERVERNAME:end------------------->"
echo ""
##Appjoint entrance Install
PACKAGE_DIR=plugins/linkis/linkis-appjoint-entrance
SERVERNAME=linkis-appjoint-entrance
SERVER_IP=$APPJOINT_ENTRANCE_INSTALL_IP
SERVER_PORT=$APPJOINT_ENTRANCE_PORT
SERVER_HOME=$DSS_INSTALL_HOME
###Install appjoint entrance
installPackage
###Update appjoint entrance linkis.properties
echo "$SERVERNAME-step4:update linkis.properties"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/linkis.properties
ssh $SERVER_IP "sed -i  \"s#wds.linkis.entrance.config.logPath.*#wds.linkis.entrance.config.logPath=$WORKSPACE_USER_ROOT_PATH#g\" $SERVER_CONF_PATH"
ssh $SERVER_IP "sed -i  \"s#wds.linkis.resultSet.store.path.*#wds.linkis.resultSet.store.path=$RESULT_SET_ROOT_PATH#g\" $SERVER_CONF_PATH"
isSuccess "subsitution linkis.properties of $SERVERNAME"
echo "<----------------$SERVERNAME:end------------------->"
echo ""
##visualis-server Install
PACKAGE_DIR=visualis-server
SERVERNAME=visualis-server
SERVER_IP=$VISUALIS_SERVER_INSTALL_IP
SERVER_PORT=$VISUALIS_SERVER_PORT
SERVER_HOME=$DSS_INSTALL_HOME
###install visualis-server
installVisualis
###update visualis-server linkis.properties
echo "$SERVERNAME-step4:update linkis.properties"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/linkis.properties
if [ $VISUALIS_NGINX_IP == "127.0.0.1" ]||[ $VISUALIS_NGINX_IP == "0.0.0.0" ]; then
    VISUALIS_NGINX_IP=$local_host
fi
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.linkis.entrance.config.logPath.*#wds.linkis.entrance.config.logPath=$WORKSPACE_USER_ROOT_PATH#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.linkis.resultSet.store.path.*#wds.linkis.resultSet.store.path=$RESULT_SET_ROOT_PATH#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.dss.visualis.gateway.ip.*#wds.dss.visualis.gateway.ip=$GATEWAY_INSTALL_IP#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP  "sed -i  \"s#wds.dss.visualis.gateway.port.*#wds.dss.visualis.gateway.port=$GATEWAY_PORT#g\" $SERVER_CONF_PATH"
SERVER_CONF_PATH=$SERVER_HOME/$SERVERNAME/conf/application.yml
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#address: 127.0.0.1#address: $VISUALIS_SERVER_INSTALL_IP#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#port:  9007#port:  $VISUALIS_SERVER_PORT#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#url: http://0.0.0.0:0000/dss/visualis#url: http://$VISUALIS_NGINX_IP:$VISUALIS_NGINX_PORT/dss/visualis#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#address: 0.0.0.0#address: $VISUALIS_NGINX_IP#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#port: 0000#port: $VISUALIS_NGINX_PORT#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#defaultZone: http://127.0.0.1:20303/eureka/#defaultZone: http://$EUREKA_INSTALL_IP:$EUREKA_PORT/eureka/#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#url: jdbc:mysql://127.0.0.1:3306/xxx?characterEncoding=UTF-8#url: jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB?characterEncoding=UTF-8#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#username: xxx#username: $MYSQL_USER#g\" $SERVER_CONF_PATH"
ssh  -p $SSH_PORT $SERVER_IP "sed -i  \"s#password: xxx#password: $MYSQL_PASSWORD#g\" $SERVER_CONF_PATH"
isSuccess "subsitution linkis.properties of $SERVERNAME"
echo "<----------------$SERVERNAME:end------------------->"
echo ""
#APPJOINTS INSTALL
echo "<----------------datachecker appjoint install start------------------->"
APPJOINTPARENT=dss-appjoints
APPJOINTNAME=datachecker
#datachecker  appjoint install
installAppjoints
echo "$APPJOINTNAME:subsitution conf"
APPJOINTNAME_CONF_PATH_PATENT=$SERVER_HOME/$APPJOINTPARENT/$APPJOINTNAME/appjoint.properties
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#job.datachecker.jdo.option.url.*#job.datachecker.jdo.option.url=$HIVE_META_URL#g\" $APPJOINTNAME_CONF_PATH_PATENT"
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#job.datachecker.jdo.option.username.*#job.datachecker.jdo.option.username=$HIVE_META_USER#g\" $APPJOINTNAME_CONF_PATH_PATENT"
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#job.datachecker.jdo.option.password.*#job.datachecker.jdo.option.password=$HIVE_META_PASSWORD#g\" $APPJOINTNAME_CONF_PATH_PATENT"
isSuccess "subsitution conf of $SERVERNAME"
echo "<----------------datachecker appjoint install end------------------->"
echo ""
echo "<----------------eventchecker appjoint install start------------------->"
APPJOINTPARENT=dss-appjoints
APPJOINTNAME=eventchecker
#eventchecker  appjoint install
installAppjoints
echo "$APPJOINTNAME:subsitution conf"
APPJOINTNAME_CONF_PATH_PATENT=$SERVER_HOME/$APPJOINTPARENT/$APPJOINTNAME/appjoint.properties
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#msg.eventchecker.jdo.option.url.*#msg.eventchecker.jdo.option.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}?characterEncoding=UTF-8#g\" $APPJOINTNAME_CONF_PATH_PATENT"
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#msg.eventchecker.jdo.option.username.*#msg.eventchecker.jdo.option.username=$MYSQL_USER#g\" $APPJOINTNAME_CONF_PATH_PATENT"
ssh  -p $SSH_PORT  $SERVER_IP "sed -i  \"s#msg.eventchecker.jdo.option.password.*#msg.eventchecker.jdo.option.password=$MYSQL_PASSWORD#g\" $APPJOINTNAME_CONF_PATH_PATENT"
isSuccess "subsitution conf of $SERVERNAME"
echo "<----------------$APPJOINTNAME:end------------------->"
echo ""
echo "<----------------sendemail  appjoint install start------------------->"
APPJOINTPARENT=dss-appjoints
APPJOINTNAME=sendemail
#Sendemail  appjoint install
installAppjoints
echo "<----------------$APPJOINTNAME:end------------------->"
echo ""
echo "<----------------visualis  appjoint install start------------------->"
APPJOINTPARENT=dss-appjoints
APPJOINTNAME=visualis
#visualis  appjoint install
installAppjoints
echo "<----------------$APPJOINTNAME:end------------------->"