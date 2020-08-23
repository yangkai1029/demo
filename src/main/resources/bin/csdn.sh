#!/bin/bash

source /etc/profile

function out() 
{
    if [ $? -eq 0 ]
    then
       /bin/echo -n $! > "$WORK_DIR/temp/$1.pid"
      if [ $? -eq 0 ];
      then
        sleep 1
        printf "%-10s STARTED\n" $1
      else
        echo FAILED TO WRITE PID
        exit 1
      fi
    else
      echo SERVER DID NOT START
      exit 1
    fi
}

function _stop()
{
	if [ -f "$WORK_DIR/temp/$APP_NAME.pid" ]; then
		read pid < "$WORK_DIR/temp/$APP_NAME.pid"
		if kill -0 $pid 2>/dev/null ; then 
			echo -n stoping $pid $APP_NAME
		    kill $pid
		
		    count=20
		    while [ $count -gt 0 ];
		    do
		      echo -n .
		      sleep 1
		      num=`ps -ef | grep $pid | grep -v grep | grep -E "java" | wc -l`
		      if [ $num -eq 0 ]; then
		        break;
		      fi
		      count=$(($count - 1))
		    done
		    echo 
		
		    if [ $num -gt 0 ]; then
		    	echo force stop $pid
		     	kill -9 $pid
		    fi
		    echo $APP_NAME stoped
		else
			printf "%-10s is not running\n" $APP_NAME 
		fi
	else
		printf "%-10s is not running\n" $APP_NAME
	fi
}

function _start()
{
	if [ -f "$WORK_DIR/temp/$APP_NAME.pid" ]; then
		read pid < "$WORK_DIR/temp/$APP_NAME.pid"
		if kill -0 $pid 2>/dev/null ; then 
			printf "%-10s is running\n" $APP_NAME
		else
			echo "starting $APP_NAME..."
			cd $SH_DIR 
			startForwardServer
		fi
	else
		echo "starting $APP_NAME...."
		cd $SH_DIR 
		startForwardServer
	fi
}

SH_DIR=$(cd "$(dirname "$0")"; pwd) 
WORK_DIR=$SH_DIR/..


if [ ! -n "${JAVA_OPTS}" ]; then
    echo "demo-service使用默认JAVA_OPTS与disconf信息:disconf.conf_server_host=10.1.10.219"
	JAVA_OPTS="-Ddisconf.enable.remote.conf=true -Ddisconf.app=uyun -Ddisconf.env=local -Ddisconf.version=2_0_0 -Ddisconf.conf_server_host=10.1.10.219/disconf"
fi

if [ ! -d "$WORK_DIR/logs" ]; then
	mkdir $WORK_DIR/logs 
fi
    
if [ ! -d "$WORK_DIR/temp" ]; then
	mkdir $WORK_DIR/temp 
fi

APP_NAME=planTask-service

function startForwardServer()
{
	CLASSPATH=${JAVA_HOME}/lib/*:${BASE_DIR}/lib/*:${WORK_DIR}/classes/:${WORK_DIR}/lib/*:${WORK_DIR}/

    MAIN_CLASS=com.railway.plantask.PlanTaskApplication

	
	RUN_OPTS="-Dapp.name=$APP_NAME"
	RUN_OPTS="$RUN_OPTS -Dwork.dir=$WORK_DIR"
	RUN_OPTS="$RUN_OPTS -Dlogs.dir=$WORK_DIR/logs"
	RUN_OPTS="$RUN_OPTS -Dlogback.configurationFile=$WORK_DIR/conf/logback.xml"
	##RUN_OPTS="$RUN_OPTS -Ddubbo.registry.file=$WORK_DIR/temp/dubbo-registry-$APP_NAME.cache -Dhystrix_thread_pool_size=200"
	RUN_OPTS="$RUN_OPTS -Xmx3072m -Xms256m -XX:MaxMetaspaceSize=128m -XX:+UseStringDeduplication -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${SH_DIR}"
	
	##RUN_OPTS="$RUN_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8001 -Xnoagent"

	UP_DIR=$(dirname "$PWD")
    cd ${UP_DIR}
	CMD="java -Dfile.encoding=UTF-8 ${RUN_OPTS} ${JAVA_OPTS} -cp ${CLASSPATH} ${MAIN_CLASS}"

    nohup $CMD > /dev/null 2>&1 &
    out $APP_NAME
}

cmd=$1
if [ ! -n "$1" ]
then
    cmd='status'
fi

case $cmd in
status)
	if [ -f "$WORK_DIR/temp/$APP_NAME.pid" ]; then
		read pid < "$WORK_DIR/temp/$APP_NAME.pid"
		if kill -0 $pid 2>/dev/null ; then 
			exit 0
		else
			exit 1
		fi
	else
		exit 1
	fi
    ;;
start)
	_start
    ;;
stop)
	_stop
    ;;
uninstall)
	_stop
	cd $WORK_DIR
	rm -rf $(pwd)
    ;;
restart)  
	_stop
	_start
	;;
*)  
	echo "require start|stop|status|restart|uninstall"  
	;;
esac
    


