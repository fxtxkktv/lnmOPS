#!/bin/sh
# +-----------------------------------------------------------------------+
# |       Author: Cheng Wenfeng   <277546922@qq.com>                      |
# +-----------------------------------------------------------------------+
#
wkdir=$(cd $(dirname $0); pwd)
if [ ! -f $wkdir/main.py ] ;then
   wkdir=$(cd $(dirname $0)/../; pwd)
fi

source $wkdir/venv/bin/activate

pidfile="/tmp/myapp.pid"
myapp="$wkdir/main.py"
logfile="$wkdir/logs/myapp_run.log"

case "$1" in
  start)
        echo -en "Starting WebServer:\t\t"
        $wkdir/sbin/start-stop-daemon --start --background --no-close -m --pidfile $pidfile --exec $wkdir/venv/bin/python -- $myapp 2>>$logfile
        RETVAL=$?
        #echo
        if [ $RETVAL -eq 0 ] ;then
           echo "Done..."
        else
           echo "Failed"
        fi
        ;;
  stop)
        echo -en "Stoping WebServer:\t\t"
        # 这个地方存在误杀情况，依赖python环境启动的服务将被误杀
        #$wkdir/sbin/start-stop-daemon --stop --exec $wkdir/venv/bin/python >/dev/null 2>&1
        if ps -ef | grep "$myapp" | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null; then
             echo "Done..."             
             RETVAL=0
        else
             echo "Failed"
             RETVAL=1
        fi
        ;;
  status)
        if [ -f $pidfile ] && [ x"$(cat $pidfile)" != x"" ];then
           cat $pidfile
        else
           echo "WebServer checking Failed..."
        fi
        ;;
  restart)
        $0 stop
        $0 start
        RETVAL=$?
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 2
esac
