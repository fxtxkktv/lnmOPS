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

progname=$(which npm)

case "$1" in
  start)
        echo -en "Starting WEBSSHServer:\t\t"
        $wkdir/sbin/start-stop-daemon --start --background -m --pidfile /tmp/webssh.pid -d $wkdir/WebSSH --exec $progname -- 'start' >/dev/null 2>&1
        RETVAL=$?
        #echo
        if [ $RETVAL -eq 0 ] ;then
           echo "Done..."
        else
           echo "Failed"
        fi
        ;;
  stop)
        echo -en "Stoping WEBSSHServer:\t\t"
        $wkdir/sbin/start-stop-daemon --stop --exec $(which node) >/dev/null 2>&1
        RETVAL=$?
        if [ $RETVAL -eq 0 ] ; then
             echo "Done..."             
             RETVAL=0
        else
             echo "Failed"
             RETVAL=1
        fi
        ;;
  status)
        psnum=$(ps -ef | grep -w "node" | grep -v grep | awk '{print $2}' | xargs)
        if [ x"$psnum" != x"" ]; then
             echo "WebSSH is runing... $psnum"             
             RETVAL=0
        else
             echo "WebSSH is not runing..."
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
