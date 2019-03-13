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

PATH=$PATH:$wkdir/venv/bin

progname="$wkdir/libs/Taskserv.py"

case "$1" in
  start)
        echo -en "Starting TASKServer:\t\t"
        $wkdir/sbin/start-stop-daemon --start --background -m --pidfile /tmp/taskserv.pid --exec $wkdir/venv/bin/python -- $progname restart
        RETVAL=$?
        #echo
        if [ $RETVAL -eq 0 ] ;then
           echo "Done..."
        else
           echo "Failed"
        fi
        ;;
  stop)
        echo -en "Stoping TASKServer:\t\t"
        if ps -ef | grep -E "$progname" | grep -v grep | awk '{print $2}' | xargs kill -9 &> /dev/null; then
             echo "Done..."             
             RETVAL=0
        else
             echo "Failed"
             RETVAL=1
        fi
        ;;
  status)
        psnum=$(ps -ef | grep "$progname" | grep -v grep | awk '{print $2}' | xargs)
        if [ x"$psnum" != x"" ]; then
             echo "$progname is runing... $psnum"             
             RETVAL=0
        else
             echo "$progname is not runing..."
             RETVAL=1
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
