#coding=utf-8
'''
+-----------------------------------------------------------------------+
|Author: Cheng Wenfeng <277546922@qq.com>                               |
+-----------------------------------------------------------------------+
'''
import os,sys,time,json
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

from MySQL import readDb,writeDb
from Functions import mkdir
import salt.config,salt.utils.event

def main(mode):
    __opts__ = salt.config.client_config('%s/plugins/salt/etc/salt/master' % gl.get_value('wkdir'))
    event = salt.utils.event.MasterEvent(__opts__['sock_dir'])
    for eachevent in event.iter_events(full=True):
       ret = eachevent['data']
       print eachevent
       if "salt/job/" in eachevent['tag']:
         #Return Event
         if ret.has_key('id') and ret.has_key('jid') and (ret.has_key('return') or ret.has_key('stdout')):
            try: 
               ret['fun']
            except:
               ret['fun'] = 'ssh.shell'
            finally:
               pass
            #Ignore saltutil.find_job event
            if ret['fun'] == "saltutil.find_job" or ret['fun'] == "mine.update":
               continue
            # 重写SALT-SSH模块中无法获取success状态，统一获取retcode代码
            ret['success'] = ret['retcode']
            try:
               ret['return']
            except:
               ret['return'] = ret['stdout']+ret['stderr']
            finally:
               pass
            if mode == 'rundaemon':
               # write SQL mode (存在阻塞问题)
               #i=1
               #while True:
               #   sql = ''' select count(*) as count from apscheduler_logs where jid=%s '''
               #   result = readDb(sql,(ret['jid'],))
               #   if result[0].get('count') == 0 and (ret['fun'] == 'cmd.run' or ret['fun'] == 'ssh.shell'):
               #      time.sleep(1) #延迟写入数据库1s
               #      if i > 10:
               #         break
               #      i+=1
               #   else:
               #      sql = ''' UPDATE apscheduler_logs SET full_ret=CONCAT(full_ret,"_sep_",%s),run_status=%s where jid=%s ''' 
               #      break
               #writeDb(sql,(json.dumps(ret),ret['success'],ret['jid']))
               #
               # storage result file
               mkdir('%s/plugins/salt/jid/%s' % (gl.get_value('wkdir'),ret['jid'][0:8]))
               rfile=open('%s/plugins/salt/jid/%s/%s' % (gl.get_value('wkdir'),ret['jid'][0:8],ret['jid']),'a')
               rfile.write('%s\n' % json.dumps(ret))
               rfile.close()
            else:
               print ret
               # Other Event
         else:
            pass

if __name__ == '__main__' :
   if len(sys.argv) >= 2:
     if sys.argv[1] == 'debug':
        main(mode='debug')
     elif sys.argv[1] == 'rundaemon':
        main(mode='rundaemon')
     else:
        print '%s opts: rundaemon/debug' % sys.argv[0]
        sys.exit()
   else:
     print '%s opts: rundaemon/debug' % sys.argv[0]
     sys.exit()
