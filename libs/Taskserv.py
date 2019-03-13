#coding=utf-8
'''
+-----------------------------------------------------------------------+
|Author: Cheng Wenfeng <277546922@qq.com>                               |
+-----------------------------------------------------------------------+
'''
#description: 守护进程类, 具备常用的start|stop|restart|status功能
#             需要改造为守护进程的程序只需要重写基类的run函数就可以了
#usage: 启动: python Taskserv.py  start
#       关闭: python Taskserv.py  stop
#       状态: python Taskserv.py  status
#       重启: python Taskserv.py  restart
#       查看: ps -axj | grep Taskserv
 
import atexit, os, sys, time, signal, re, sqlite3
import datetime
import importlib
import Global as gl

pro_path = os.path.split(os.path.realpath(__file__))[0]
sys.path.append('%s/../tools' % pro_path)

#定义初始目录
gl._init()
gl.set_value('wkdir','%s/../' % pro_path)
gl.set_value('confdir','%s/../config' % pro_path)
gl.set_value('certdir','%s/../certs' % pro_path)
gl.set_value('plgdir','%s/../plugins' % pro_path)
gl.set_value('tempdir','%s/../template' % pro_path)
gl.set_value('assets','%s/../assets' % pro_path)
gl.set_value('vwdir','%s/../views' % pro_path)
gl.set_value('logs','%s/../logs' % pro_path)

class CDaemon:
    '''
    a generic daemon class.
    usage: subclass the CDaemon class and override the run() method
    stderr  表示错误日志文件绝对路径, 收集启动过程中的错误日志
    verbose 表示将启动运行过程中的异常错误信息打印到终端,便于调试,建议非调试模式下关闭, 默认为1, 表示开启
    save_path 表示守护进程pid文件的绝对路径
    '''
    def __init__(self, save_path, stdin=os.devnull, stdout=os.devnull, stderr=os.devnull, home_dir='.', umask=022, verbose=1):
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.pidfile = save_path #pid文件绝对路径
        self.home_dir = home_dir
        self.verbose = verbose #调试开关
        self.umask = umask
        self.daemon_alive = True
 
    def daemonize(self):
        try:
            pid = os.fork()
            if pid > 0:
                sys.exit(0)
        except OSError, e:
            sys.stderr.write('fork #1 failed: %d (%s)\n' % (e.errno, e.strerror))
            sys.exit(1)
 
        os.chdir(self.home_dir)
        os.setsid()
        os.umask(self.umask)
 
        try:
            pid = os.fork()
            if pid > 0:
                sys.exit(0)
        except OSError, e:
            sys.stderr.write('fork #2 failed: %d (%s)\n' % (e.errno, e.strerror))
            sys.exit(1)
 
        sys.stdout.flush()
        sys.stderr.flush()
 
        si = file(self.stdin, 'r')
        so = file(self.stdout, 'a+')
        if self.stderr:
            se = file(self.stderr, 'a+', 0)
        else:
            se = so
 
        os.dup2(si.fileno(), sys.stdin.fileno())
        os.dup2(so.fileno(), sys.stdout.fileno())
        os.dup2(se.fileno(), sys.stderr.fileno())
 
        def sig_handler(signum, frame):
            self.daemon_alive = False
        signal.signal(signal.SIGTERM, sig_handler)
        signal.signal(signal.SIGINT, sig_handler)
 
        if self.verbose >= 1:
            print 'daemon process started ...'
 
        atexit.register(self.del_pid)
        pid = str(os.getpid())
        file(self.pidfile, 'w+').write('%s\n' % pid)
 
    def get_pid(self):
        try:
            pf = file(self.pidfile, 'r')
            pid = int(pf.read().strip())
            pf.close()
        except IOError:
            pid = None
        except SystemExit:
            pid = None
        return pid
 
    def del_pid(self):
        if os.path.exists(self.pidfile):
            os.remove(self.pidfile)
 
    def start(self, *args, **kwargs):
        if self.verbose >= 1:
            print 'ready to starting ......'
        #check for a pid file to see if the daemon already runs
        pid = self.get_pid()
        if pid:
            msg = 'pid file %s already exists, is it already running?\n'
            sys.stderr.write(msg % self.pidfile)
            sys.exit(1)
        #start the daemon
        self.daemonize()
        self.run(*args, **kwargs)
 
    def stop(self):
        if self.verbose >= 1:
            print 'stopping ...'
        pid = self.get_pid()
        if not pid:
            msg = 'pid file [%s] does not exist. Not running?\n' % self.pidfile
            sys.stderr.write(msg)
            if os.path.exists(self.pidfile):
                os.remove(self.pidfile)
            return
        #try to kill the daemon process
        try:
            i = 0
            while 1:
                os.kill(pid, signal.SIGTERM)
                time.sleep(0.1)
                i = i + 1
                if i % 10 == 0:
                    os.kill(pid, signal.SIGHUP)
        except OSError, err:
            err = str(err)
            if err.find('No such process') > 0:
                if os.path.exists(self.pidfile):
                    os.remove(self.pidfile)
            else:
                print str(err)
                sys.exit(1)
            if self.verbose >= 1:
                print 'Stopped!'
 
    def restart(self, *args, **kwargs):
        self.stop()
        self.start(*args, **kwargs)
 
    def is_running(self):
        pid = self.get_pid()
        #print(pid)
        return pid and os.path.exists('/proc/%d' % pid)
 
    def run(self, *args, **kwargs):
        'NOTE: override the method in subclass'
        print 'base class run()'
 
class ClientDaemon(CDaemon):
    def __init__(self, name, save_path, stdin=os.devnull, stdout=os.devnull, stderr=os.devnull, home_dir='.', umask=022, verbose=1):
        CDaemon.__init__(self, save_path, stdin, stdout, stderr, home_dir, umask, verbose)
        self.name = name #派生守护进程类的名称
 
    def run(self, output_fn, **kwargs):
        '''处理数据库中的任务队列'''
        # 引入MySQL配置
        from Functions import AppServer
        db_name = AppServer().getConfValue('Databases','MysqlDB')
        db_user = AppServer().getConfValue('Databases','MysqlUser')
        db_pass = AppServer().getConfValue('Databases','MysqlPass')
        db_ip = AppServer().getConfValue('Databases','MysqlHost')
        db_port = AppServer().getConfValue('Databases','MysqlPort')
        dbconn = 'mysql://%s:%s@%s:%s/%s' % (db_user,db_pass,db_ip,int(db_port),db_name)
        from MySQL import writeDb
        # 定义sqlite库文件路径[SQLITE存储模式用到]
        #dbfile = '/opt/lnmOPS/logs/myapp_task.db'
        # 尝试清空DB数据库中记录的JOB信息
        try:
            #conn = sqlite3.connect(dbfile)
            #conn.execute("""delete from apscheduler_jobs ;""")
            #conn.commit()
            #conn.close()
            sql = """delete from apscheduler_jobs ;"""
            writeDb(sql,)
        except:
            True
        # 动态引入任务函数
        moduleSrc='TaskFunctions'
        dylib = importlib.import_module(moduleSrc)
        # 重新加载job队列[两种类型调度器按情况选择]
        from apscheduler.schedulers.background import BackgroundScheduler
        from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
        job_defaults = { 'max_instances': 1 }
        executors = {'default': ThreadPoolExecutor(20), 'processpool': ProcessPoolExecutor(5)}
        scheduler = BackgroundScheduler(timezone='Asia/Shanghai',executors=executors, job_defaults=job_defaults)
        # sqlite or mysql
        #scheduler.add_jobstore('sqlalchemy', url='sqlite:///%s' % dbfile)
        scheduler.add_jobstore('sqlalchemy', url='%s' % dbconn)
        from MySQL import readDb
        sql = """ Select id,timedesc from taskconf where status='1' """
        result = readDb(sql,)
        for taskobject in result:
            Taskid='TaskID_%s' % taskobject.get('id')
            FunName='TaskFunc_%s' % taskobject.get('id')
            function=getattr(dylib,FunName)
            cronlist=taskobject.get('timedesc').strip().split(' ')
            if len(cronlist) == 5:
               scheduler.add_job(func=function,trigger='cron',month=cronlist[4],day=cronlist[3],hour=cronlist[2],minute=cronlist[1],second=cronlist[0], id=Taskid)
            elif len(cronlist) == 6:
               scheduler.add_job(func=function,trigger='cron',day_of_week=cronlist[5],month=cronlist[4],day=cronlist[3],hour=cronlist[2],minute=cronlist[1],second=cronlist[0], id=Taskid)
            else:
               continue
        #print scheduler.get_jobs()
        scheduler.start()
        fd = open(output_fn, 'w')
        try:
            dtnow = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            line = '\n[%s]: System Starting all Tasks...\n' % dtnow
            fd.write(line)
            fd.flush()
            while 1:
               pass
        except KeyboardInterrupt: #捕获键盘ctrl+c,在此脚本中不生效,console下可用
            dtnow = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            line = '\n[%s]: System Stoping all Tasks, please wait...\n' % dtnow
            fd.write(line)
            fd.close()
            scheduler.shutdown()
            time.sleep(1)
            os._exit(0)
 
if __name__ == '__main__':
    help_msg = 'Usage: python %s <start|stop|restart|status>' % sys.argv[0]
    if len(sys.argv) != 2:
        print help_msg
        sys.exit(1)
    p_name = 'clientd' #守护进程名称
    pid_fn = '/tmp/myapp_task_class.pid' #守护进程pid文件的绝对路径
    log_fn = '%s/myapp_task_class.log' % gl.get_value('logs') #守护进程日志文件的绝对路径
    err_fn = '%s/myapp_taskclass.err.log' % gl.get_value('logs') #守护进程启动过程中的错误日志,内部出错能从这里看到
    cD = ClientDaemon(p_name, pid_fn, stderr=err_fn, verbose=1)
 
    if sys.argv[1] == 'start':
        cD.start(log_fn)
    elif sys.argv[1] == 'stop':
        cD.stop()
    elif sys.argv[1] == 'restart':
        cD.restart(log_fn)
    elif sys.argv[1] == 'status':
        alive = cD.is_running()
        if alive:
            print 'process [%s] is running ......' % cD.get_pid()
        else:
            print 'daemon process [%s] stopped' %cD.name
    else:
        print 'invalid argument!'
        print help_msg
