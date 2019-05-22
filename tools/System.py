#coding=utf-8
import os,sys,json,re,time,datetime,logging,zipfile,socket,platform
from bottle import request,route
from bottle import template,redirect,static_file

from MySQL import writeDb,readDb,readDb2
from Login import checkLogin,checkAccess

from Functions import AppServer,LoginCls,cmdhandle,netModule,iScheduler,SaltCLS
import Global as gl

keys = AppServer().getConfValue('keys','passkey')

cmds=cmdhandle()
netmod=netModule()

@route('/routeconf')
@checkAccess
def routeconf():
    s = request.environ.get('beaker.session')
    return template('routeconf',session=s,msg={})

@route('/staticroute')
@checkAccess
def routeconf():
    s = request.environ.get('beaker.session')
    return template('staticroute',msg={},session=s)

@route('/advroute')
@checkAccess
def routeconf():
    s = request.environ.get('beaker.session')
    return template('advroute',msg={},session=s)

@route('/showadvroute')
@checkAccess
def routeconf():
    s = request.environ.get('beaker.session')
    result = cmds.getdictrst('ip rule')
    return template('showlog',session=s,info=result)

@route('/api/getrouteinfo',method=['GET', 'POST'])
@checkAccess
def getrouteinfo():
    netmod.Initrouteinfo()
    sql = """ SELECT I.id, I.dest, I.netmask, I.gateway, I.iface FROM sysroute as I where fromtype=0 order by id """
    item_list = readDb(sql,)
    return json.dumps(item_list)

@route('/api/getrouteinfo2',method=['GET', 'POST'])
@checkAccess
def getrouteinfo():
    sql = """ SELECT I.id, I.dest, I.netmask, I.gateway, I.iface FROM sysroute as I where fromtype=1 """
    item_list = readDb(sql,)
    return json.dumps(item_list)

@route('/api/getrouteinfo3',method=['GET', 'POST'])
@checkAccess
def getrouteinfo():
    sql = """ SELECT id, rulename, left(srcaddr,100) as srcaddr, left(destaddr,100) as destaddr, pronum, iface FROM sysrouteadv order by pronum asc"""
    item_list = readDb(sql,)
    return json.dumps(item_list)

@route('/addroute')
@checkAccess
def addroute():
    s = request.environ.get('beaker.session')
    sql = " SELECT ifacename FROM netiface where status='UP' "
    ifacelist_result = readDb(sql,)
    return template('addrouteconf',session=s,info={},ifacelist_result=ifacelist_result)

@route('/addroute',method="POST")
@checkAccess
def do_addroute():
    s = request.environ.get('beaker.session')
    rttype = request.forms.get("rttype")
    destaddr = request.forms.get("ipaddr")
    netmask = request.forms.get("netmask")
    gateway = request.forms.get("gateway")
    gwiface = request.forms.get("gwiface")
    # 格式判断
    if netmod.checkip(destaddr) == False or netmod.checkmask(netmask) == False or netmod.checkip(gateway) == False :
       msg = {'color':'red','message':u'地址不合法,添加失败'}
       return(template('staticroute',msg=msg,session=s))
    # 系统判断
    if gwiface == 'auto':
       resultA = cmds.getdictrst('route add -net %s netmask %s gw %s' % (destaddr,netmask,gateway))
    else :
       resultA = cmds.getdictrst('route add -net %s netmask %s gw %s dev %s' % (destaddr,netmask,gateway,gwiface))
    if resultA.get('status') != 0 :
       msg = {'color':'red','message':u'目标不可达或其他错误，添加失败'}
       return(template('staticroute',msg=msg,session=s))
    sql = "INSERT INTO sysroute(type,dest,netmask,gateway,iface,fromtype) VALUES(%s,%s,%s,%s,%s,%s)"
    data = ('net',destaddr,netmask,gateway,gwiface,1)
    result = writeDb(sql,data)
    if result == True:
       writeROUTEconf(action='uptconf')
       writeUTMconf(action='uptconf')
       msg = {'color':'green','message':u'添加成功'}
    else:
       msg = {'color':'red','message':u'添加失败'}
       return(template('staticroute',msg=msg,session=s))

@route('/addadvroute')
@checkAccess
def addroute():
    s = request.environ.get('beaker.session')
    netmod.InitNIinfo()
    sql = " SELECT ifacename FROM netiface where status='UP' UNION select attr as ifacename FROM sysattr where status='1' and servattr='vpnrelay'"
    ifacelist_result = readDb(sql,)
    return template('addadvroute',session=s,info={},ifacelist_result=ifacelist_result)

@route('/addadvroute',method="POST")
@checkAccess
def do_addroute():
    s = request.environ.get('beaker.session')
    rulename = request.forms.get("rulename")
    srcaddr = request.forms.get("srcaddr").replace('\r\n','\n').strip()
    destaddr = request.forms.get("destaddr").replace('\r\n','\n').strip()
    pronum = request.forms.get("pronum")
    outdev = request.forms.get("ifacename")
    alladdr=srcaddr.split('\n')+destaddr.split('\n')
    #提交判断
    if outdev == '' or rulename == '':
       msg = {'color':'red','message':u'描述或出口未填写，添加失败'}
       return(template('advroute',msg=msg,session=s))
    if int(pronum) <100 or int(pronum) >32765 :
       msg = {'color':'red','message':u'优先级值填写错误，添加失败'}
       return(template('advroute',msg=msg,session=s))
    for ipmask in alladdr :
        if netmod.checkipmask(ipmask) == False and ipmask != '':
           msg = {'color':'red','message':u'地址格式错误，添加失败'}
           return(template('advroute',msg=msg,session=s))
    if outdev == "vpnrelay":
       outdev = 'tun1000'
    cmdDict=cmds.getdictrst('ip rule add prio %s fwmark 1000 dev %s' % (pronum,outdev))
    if cmdDict.get('status') == 0:
       sql = """ insert into sysrouteadv(rulename,srcaddr,destaddr,pronum,iface) VALUES(%s,%s,%s,%s,%s) """
       data = (rulename,srcaddr,destaddr,int(pronum),outdev)
       result = writeDb(sql,data)
       if result :
          writeROUTEconf(action='uptconf')
          writeUTMconf(action='uptconf')
          msg = {'color':'green','message':u'添加成功'}
       else :
          msg = {'color':'red','message':u'添加失败'}
    else:
       msg = {'color':'red','message':u'系统规则生成异常，添加失败'}
    return(template('advroute',msg=msg,session=s))

@route('/editadvroute/<id>')
@checkAccess
def editadvroute(id):
    s = request.environ.get('beaker.session')
    sql = " SELECT ifacename FROM netiface where status='UP' UNION select attr as ifacename FROM sysattr where status='1' and servattr='vpnrelay'"
    ifacelist_result = readDb(sql,)
    sql2 = """ SELECT rulename,srcaddr,destaddr,pronum,iface FROM sysrouteadv WHERE id=%s """
    result = readDb(sql2,(id,))
    if result[0].get('iface') == "tun1000":
       result[0].update(iface="vpnrelay")
    return template('addadvroute',session=s,info=result[0],ifacelist_result=ifacelist_result)

@route('/editadvroute/<id>',method="POST")
@checkAccess
def do_editadvroute(id):
    s = request.environ.get('beaker.session')
    rulename = request.forms.get("rulename")
    srcaddr = request.forms.get("srcaddr").replace('\r\n','\n').strip()
    destaddr = request.forms.get("destaddr").replace('\r\n','\n').strip()
    pronum = request.forms.get("pronum")
    outdev = request.forms.get("ifacename")
    alladdr=srcaddr.split('\n')+destaddr.split('\n')
    #提交判断
    if outdev == '' or rulename == '':
        msg = {'color':'red','message':u'描述或出口未填写，添加失败'}
        return(template('advroute',msg=msg,session=s))
    if int(pronum) <0 or int(pronum) >32765 :
        msg = {'color':'red','message':u'优先级值填写错误，添加失败'}
        return(template('advroute',msg=msg,session=s))
    for ipmask in alladdr :
        if netmod.checkipmask(ipmask) == False and ipmask != '':
           msg = {'color':'red','message':u'地址格式错误(%s)，添加失败' % ipmask}
           return(template('advroute',msg=msg,session=s))
    if outdev == "vpnrelay":
       outdev = 'tun1000'
    cmdDict=cmds.getdictrst('ip rule add prio %s fwmark 1000%s dev %s' % (pronum,id,outdev))
    if cmdDict.get('status') == 0:
       sql = """ UPDATE sysrouteadv SET rulename=%s,srcaddr=%s,destaddr=%s,pronum=%s,iface=%s WHERE id=%s """
       data = (rulename,srcaddr,destaddr,int(pronum),outdev,id)
       result = writeDb(sql,data)
       if result :
          writeROUTEconf(action='uptconf')
          writeUTMconf(action='uptconf')
          msg = {'color':'green','message':u'更新成功'}
       else :
          msg = {'color':'red','message':u'更新失败'}
    else:
       msg = {'color':'red','message':u'系统规则生成异常，添加失败'}
    return(template('advroute',msg=msg,session=s))

@route('/delroute/<stype>/<id>')
@checkAccess
def deliface(stype,id):
    s = request.environ.get('beaker.session')
    if stype == 'sys' or stype == 'static' :
       sqlquery = " select dest,netmask,gateway FROM sysroute WHERE id=%s "
       sql = " DELETE FROM sysroute WHERE id=%s "
    else:
       sqlquery = " select srcaddr,destaddr,pronum,iface as outdev FROM sysrouteadv WHERE id=%s "
       sql = " DELETE FROM sysrouteadv WHERE id=%s "
    resultA = readDb(sqlquery,(id,))
    # 判断删除入口并返回到指定界面
    if stype == 'sys':
       tpl = 'routeconf'
    elif stype == 'static':
       tpl = 'staticroute'
    elif stype == 'adv':
       tpl = 'advroute'
    # 判断提交的指令
    result = writeDb(sql,(id,))
    if result == True:
       if stype == 'adv':
          try:
             if resultA[0].get('srcaddr') == '' and resultA[0].get('destaddr') != '':
                cmds.getdictrst('ip rule del prio %s to %s' % (resultA[0].get('pronum'),resultA[0].get('destaddr')))
             elif resultA[0].get('destaddr') == '' and resultA[0].get('srcaddr') != '':
                cmds.getdictrst('ip rule del prio %s from %s dev %s' % (resultA[0].get('pronum'),resultA[0].get('srcaddr')))
             elif resultA[0].get('destaddr') == '' and resultA[0].get('srcaddr') == '':
                cmds.getdictrst('ip rule del prio %s dev %s' % (resultA[0].get('pronum'),resultA[0].get('outdev')))
             else:
                cmds.getdictrst('ip rule del prio %s from %s to %s' % (resultA[0].get('pronum'),resultA[0].get('srcaddr'),resultA[0].get('destaddr')))
             msg = {'color':'green','message':u'删除成功'}
             return template(tpl,session=s,msg=msg)
          except:
                msg = {'color':'green','message':u'删除成功'}
                return template(tpl,session=s,msg=msg)
       else:
          cmds.getdictrst('route del -net %s netmask %s gw %s' % (resultA[0].get('dest'),resultA[0].get('netmask'),resultA[0].get('gateway')))
          writeROUTEconf(action='uptconf')
          writeUTMconf(action='uptconf')
          msg = {'color':'green','message':u'删除成功'}
          return template(tpl,session=s,msg=msg)
    else:
       msg = {'color':'red','message':u'删除失败'}
       return template(tpl,session=s,msg=msg)

@route('/servtools')
@checkAccess
def servtools():
    """服务工具"""
    s = request.environ.get('beaker.session')
    return template('servtools',session=s,info={})

@route('/servtools',method="POST")
@checkAccess
def do_servtools():
    s = request.environ.get('beaker.session')
    toolsname = request.forms.get("toolsname")
    servname = request.forms.get("servname")
    result = cmds.syscmds(toolsname,servname)
    info = {}
    info['toolsname'] = toolsname
    info['servname'] = servname
    info['result'] = result
    if result :
       msg = {'color':'green','message':u'查询完成'}
    return(template('servtools',msg=msg,session=s,info=info))

@route('/resconfig')
@checkAccess
def servtools():
    """资源配置"""
    s = request.environ.get('beaker.session')
    sql = " select value from sysattr where attr='resData' and servattr='sys' "
    result = readDb(sql,)
    try:
        info = json.loads(result[0].get('value'))
    except:
        return(template('resconfig',session=s,msg={}))
    return template('resconfig',session=s,msg={},info=info)

@route('/resconfig',method="POST")
@checkAccess
def do_servtools():
    s = request.environ.get('beaker.session')
    ResState = request.forms.get("ResState")
    ResSaveDay = request.forms.get("ResSaveDay")
    ResInv = request.forms.get("ResInv")
    visitDay = request.forms.get("visitDay")
    if int(ResSaveDay) < 1 or int(visitDay) < 1 or int(ResInv) < 60 :
       msg = {'color':'red','message':'配置保存失败,参数不符合要求'}
       return redirect('/resconfig')
    idata = dict()
    idata['ResState'] = ResState
    idata['ResSaveDay'] = ResSaveDay
    idata['ResInv'] = ResInv
    idata['visitDay'] = visitDay
    sql = " update sysattr set value=%s where attr='resData' "
    iidata=json.dumps(idata)
    result = writeDb(sql,(iidata,))
    if result == True :
       msg = {'color':'green','message':'配置保存成功'}
    else:
       msg = {'color':'red','message':'配置保存失败'}
    return(template('resconfig',msg=msg,session=s,info=idata))

@route('/systeminfo')
@route('/')
@checkAccess
def systeminfo():
    """系统信息项"""
    s = request.environ.get('beaker.session')
    info=dict()
    info['hostname'] = platform.node()
    info['kernel'] = platform.platform()
    info['systime'] = cmds.getdictrst('date +"%Y%m%d %H:%M:%S"').get('result')
    cmdRun='cat /proc/uptime|awk -F. \'{run_days=$1/86400;run_hour=($1%86400)/3600;run_minute=($1%3600)/60;run_second=$1%60;printf("%d天%d时%d分%d秒",run_days,run_hour,run_minute,run_second)}\''
    info['runtime'] = cmds.getdictrst(cmdRun).get('result')
    info['pyversion'] = platform.python_version()
    info['memsize'] = cmds.getdictrst('cat /proc/meminfo |grep \'MemTotal\' |awk -F: \'{printf ("%.0fM",$2/1024)}\'|sed \'s/^[ \t]*//g\'').get('result')
    info['cpumode'] = cmds.getdictrst('grep \'model name\' /proc/cpuinfo |uniq |awk -F : \'{print $2}\' |sed \'s/^[ \t]*//g\' |sed \'s/ \+/ /g\'').get('result')
    info['v4addr'] = 'Lan: '+netmod.NatIP()
    info['appversion'] = AppServer().getVersion()
    """管理日志"""
    sql = " SELECT id,objtext,objact,objhost,objtime FROM logrecord order by id DESC limit 7 "
    logdict = readDb(sql,)
    return template('systeminfo',session=s,info=info,logdict=logdict)

class DateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
           return obj.strftime('%Y-%m-%d %H:%M:%S')
        elif isinstance(obj, datetime.date):
           return obj.strftime("%Y-%m-%d")
        else:
           return json.JSONEncoder.default(self, obj)

@route('/systeminfo',method="POST")
@checkAccess
def do_systeminfo():
    s = request.environ.get('beaker.session')
    sql = " select value from sysattr where attr='resData' "
    info = readDb(sql,)
    try:
       ninfo=json.loads(info[0].get('value'))
    except:
       return False
    visitDay = ninfo.get('visitDay')
    try:
        date = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()-(int(visitDay) * 86400)))
        sql = " select info,tim from sysinfo where tim > (%s) order by id"
        resultData = readDb2(sql,(date,))
        result = [True,resultData]
    except Exception as e:
        result = [False,str(e)]
    return json.dumps({'resultCode':0,'result':result},cls=DateEncoder)

@route('/applog')
@checkAccess
def applog():
    """服务工具"""
    s = request.environ.get('beaker.session')
    return template('applog',session=s,msg={},info={})

@route('/api/getapplog',method=['GET', 'POST'])
@checkAccess
def getapplog():
    sql = """ SELECT id,objtime,objname,objtext,objact,objhost FROM logrecord order by id desc """
    item_list = readDb(sql,)
    return json.dumps(item_list, cls=DateEncoder)

@route('/showservlog')
@checkAccess
def showservlog():
    """显示日志项"""
    s = request.environ.get('beaker.session')
    result = cmds.getdictrst('tail -300 %s/logs/myapp_run.log' % gl.get_value('wkdir'))
    return template('showlog',session=s,msg={},info=result)

@route('/download/<vdir>/<filename:re:.*\.zip|.*\.bkt>')
def download(vdir,filename):
    if vdir == 'backupset' :
       download_path = '%s/backupset' % gl.get_value('plgdir')
    return static_file(filename, root=download_path, download=filename)

@route('/syscheck')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    return template('systemcheck',session=s)

@route('/api/getsyschkinfo',method=['GET', 'POST'])
@checkAccess
def getcertinfo():
    result = cmds.envCheck('result')
    return json.dumps(result)

# 备份集管理
@route('/backupset')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    return template('backupset',session=s,msg={})

@route('/uploadfile')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    return template('uploadfile',session=s,msg={})


@route('/uploadfile', method='POST')
def do_upload():
    s = request.environ.get('beaker.session')
    category = request.forms.get('category')
    upload = request.files.get('upload')
    name, ext = os.path.splitext(upload.filename)
    if ext not in ('.bkt','.jpgsss'):
       msg = {'color':'red','message':u'文件格式不被允许.请重新上传'}
       return template('backupset',session=s,msg=msg)
    try:
       upload.save('%s/backupset' % gl.get_value('plgdir'))
       msg = {'color':'green','message':u'文件上传成功'}
       return template('backupset',session=s,msg=msg)
    except:
       msg = {'color':'red','message':u'文件上传失败'}
       return template('backupset',session=s,msg=msg)

@route('/startbackupset')
@checkAccess
def delbackupset():
    s = request.environ.get('beaker.session')
    createtm = time.strftime('%Y%m%d%H%M%S',time.localtime(time.time()))
    from MySQL import db_name,db_user,db_pass,db_ip,db_port
    backupsetname='backupset_%s.bkt' % createtm
    cmd='mysqldump -u%s -p%s -h%s -P%s %s > %s/backupset/%s ' % (db_user,db_pass,db_ip,db_port,db_name,gl.get_value('plgdir'),backupsetname)
    x,y = cmds.gettuplerst(cmd)
    if x == 0:
       msg = {'color':'green','message':u'备份完成'}
    else :
       msg = {'color':'red','message':u'备份失败'}
    return template('backupset',session=s,msg=msg)

@route('/restore/<filename>')
@checkAccess
def restore(filename):
    s = request.environ.get('beaker.session')
    if filename != "":
       from MySQL import db_name,db_user,db_pass,db_ip,db_port
       x,y=cmds.gettuplerst('mysql -h%s -P%s -u%s -p%s %s < %s/backupset/%s' % (db_ip,db_port,db_user,db_pass,db_name,gl.get_value('plgdir'),filename))
       if x == 0:
          msg = {'color':'green','message':u'备份集恢复成功,请重启服务以重新加载数据.'}
       else:
          msg = {'color':'red','message':u'备份集恢复失败'}
    else:
       msg = {'color':'red','message':u'备份集恢复失败'}
    return template('backupset',session=s,msg=msg)

@route('/delbackupset/<filename>')
@checkAccess
def delbackupset(filename):
    s = request.environ.get('beaker.session')
    if filename != "":
       x,y=cmds.gettuplerst('rm -rf %s/backupset/%s' % (gl.get_value('plgdir'),filename))
       if x == 0:
          msg = {'color':'green','message':u'备份集删除成功'}
       else:
          msg = {'color':'red','message':u'备份集删除失败'}
    return template('backupset',session=s,msg=msg)


@route('/api/getbackupsetinfo',method=['GET', 'POST'])
@checkAccess
def getbackupsetinfo():
    info=[]
    status,result=cmds.gettuplerst('find %s/backupset -name \'*.bkt\' -exec basename {} \;|sort' % gl.get_value('plgdir'))
    for i in result.split('\n'):
        if str(i) != "":
           infos={}
           infos['filename']=str(i)
           infos['filesize']=os.path.getsize('%s/backupset/%s' % (gl.get_value('plgdir'),i))
           cctime=os.path.getctime('%s/backupset/%s' % (gl.get_value('plgdir'),i))
           infos['filetime']=time.strftime('%Y%m%d%H%M%S',time.localtime(cctime))
           info.append(infos)
    return json.dumps(info)

# 集中部署
@route('/saltservconf')
@checkAccess
def saltservconf():
    """资源配置"""
    s = request.environ.get('beaker.session')
    sql = " select value from sysattr where attr='saltconf' and servattr='saltstack' "
    result = readDb(sql,)
    try:
        info = json.loads(result[0].get('value'))
    except:
        return(template('saltservconf',session=s,msg={},info={}))
    return template('saltservconf',session=s,msg={},info=info)

@route('/saltservconf',method="POST")
@checkAccess
def do_saltservconf():
    s = request.environ.get('beaker.session')
    saltListen = request.forms.get("saltListen")
    smsport = request.forms.get("smsport")
    txport = request.forms.get("txport")
    timeout = request.forms.get("timeout")
    autoAccept = request.forms.get("autoAccept")
    if int(smsport) > 65535 or int(txport) > 65535 or int(timeout) < 3 :
       msg = {'color':'red','message':'配置保存失败,参数不符合要求'}
       return redirect('/saltservconf')
    idata = dict()
    idata['saltListen'] = saltListen
    idata['smsport'] = smsport
    idata['txport'] = txport
    idata['timeout'] = timeout
    idata['autoAccept'] = autoAccept
    sql = " update sysattr set value=%s where attr='saltconf' and servattr='saltstack' "
    iidata=json.dumps(idata)
    result = writeDb(sql,(iidata,))
    if result == True :
       SaltCLS().writeSALTconf(action='uptconf')
       msg = {'color':'green','message':'配置保存成功'}
    else:
       msg = {'color':'red','message':'配置保存失败'}
    return(template('saltservconf',msg=msg,session=s,info=idata))

@route('/minionmgr')
@checkAccess
def minionmgr():
    s = request.environ.get('beaker.session')
    return template('minionmgr',session=s,msg={})

@route('/api/getminioninfo',method=['GET', 'POST'])
@checkAccess
def getminioninfo():
    sql = """ SELECT id,nodeid,hostname,IP,Mem,CPU,CPUS,OS,virtual,status from minioninfo """
    minionlist = readDb(sql,)
    return json.dumps(minionlist,cls=DateEncoder)

@route('/initscanminion')
@checkAccess
def initscanminion():
    s = request.environ.get('beaker.session')
    msg={'color':'green','message':u'扫描进程正在后台重新获取节点信息...'}
    # 触发后台进程处理扫描
    from Functions import lnmDaemonTask
    lnmDaemonTask('SaltCLS().ScanMinion')
    return template('minionmgr',session=s,msg=msg)

@route('/delminion/<id>')
@checkAccess
def delminion(id):
    s = request.environ.get('beaker.session')
    sqlx = "select id from nodegrpmgr where FIND_IN_SET(%s,grpnodes) union select id from taskconf where api_type='0' and FIND_IN_SET(%s,api_obj)"
    resultx = readDb(sqlx,(id,id))
    if resultx:
       msg={'color':'red','message':u'删除失败,该节点被关联分组或任务计划,禁止删除.建议重新扫描终端'}
       return template('minionmgr',session=s,msg=msg)
    sql = "delete from minioninfo where id in (%s) "
    result = writeDb(sql,(id,))
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       msg={'color':'green','message':u'删除成功'}
       return template('minionmgr',session=s,msg=msg)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       msg={'color':'red','message':u'删除失败'}
       return template('minionmgr',session=s,msg=msg)

@route('/nodegroup')
@checkAccess
def minionmgr():
    s = request.environ.get('beaker.session')
    sql = " select id,concat(nodeid,' | ',hostname,' | ',os) as nodeinfo from minioninfo where status='1' order by id"
    minionlist = readDb(sql,)
    return template('nodegroup',session=s,msg={},minionlist=minionlist)

@route('/addnodegrp',method="POST")
@checkAccess
def do_addnodegrp():
    s = request.environ.get('beaker.session')
    grpname = request.forms.get("grpname")
    grpdesc = request.forms.get("grpdesc")
    grpnodes = request.forms.getlist("grpnodes[]")
    grpnodes = ",".join(grpnodes)
    sql = """
            INSERT INTO
               nodegrpmgr(grpname,grpdesc,grpnodes)
            VALUES(%s,%s,%s)
        """
    data = (grpname,grpdesc,str(grpnodes))
    result = writeDb(sql,data)
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changenodegrp/<id>',method="POST")
@checkAccess
def do_changenodegrp(id):
    s = request.environ.get('beaker.session')
    grpname = request.forms.get("grpname")
    grpdesc = request.forms.get("grpdesc")
    grpnodes = request.forms.getlist("grpnodes[]")
    grpnodes = ",".join(grpnodes)
    sql = """ UPDATE nodegrpmgr SET grpname=%s,grpdesc=%s,grpnodes=%s WHERE id=%s """
    data = (grpname,grpdesc,str(grpnodes),id)
    result = writeDb(sql,data)
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'


@route('/delnodegrp/<id>')
@checkAccess
def delnodegrp(id):
    s = request.environ.get('beaker.session')
    sqlx = "select id from taskconf where api_type='1' and FIND_IN_SET(%s,api_obj)"
    resultx = readDb(sqlx,(id,))
    if resultx:
       sql = " select id,concat(nodeid,' | ',hostname) as nodeinfo from minioninfo where status='1' order by id"
       minionlist = readDb(sql,)
       msg={'color':'red','message':u'删除失败,该分组被关联任务计划,禁止删除.建议先取消关联'}
       return template('nodegroup',session=s,msg=msg,minionlist=minionlist)
    sql = "delete from nodegrpmgr where id in (%s)"
    result = writeDb(sql,(id,))
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       sql = " select id,concat(nodeid,' | ',hostname) as nodeinfo from minioninfo where status='1' order by id"
       minionlist = readDb(sql,)
       msg={'color':'green','message':u'删除成功'}
       return template('nodegroup',session=s,msg=msg,minionlist=minionlist)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       sql = " select id,concat(nodeid,' | ',hostname) as nodeinfo from minioninfo where status='1' order by id"
       minionlist = readDb(sql,)
       msg={'color':'red','message':u'删除失败'}
       return template('nodegroup',session=s,msg=msg,minionlist=minionlist)

@route('/api/getnodegrpinfo',method=['GET', 'POST'])
@checkAccess
def getminioninfo():
    sql = """ SELECT U.id,U.grpname,U.grpdesc,U.grpnodes,GROUP_CONCAT(D.nodeid) as nodeid from nodegrpmgr as U LEFT OUTER JOIN minioninfo as D on position(D.id in U.grpnodes) GROUP by U.id """
    minionlist = readDb(sql,)
    return json.dumps(minionlist,cls=DateEncoder)

@route('/cmdrunconf')
@checkAccess
def cmdrunconf():
    s = request.environ.get('beaker.session')
    sql1 = """ select id,nodeid,concat(nodeid,' | ',hostname,' | ',os ) as nodeinfo from minioninfo where status='1' order by id """
    sql2 = """ SELECT id,grpname from nodegrpmgr """
    sql3 = """ SELECT id,hostaddr,concat(hostaddr,' | ',sshport,' | ',sshuser ) as sshinfo from sshmgr WHERE status='1' """
    nodeslist = readDb(sql1,)
    grpnodeslist = readDb(sql2,)
    sshconnlist = readDb(sql3,)
    return template('cmdrunconf',session=s,msg={},nodeslist=nodeslist,grpnodeslist=grpnodeslist,sshconnlist=sshconnlist,runresult='')

@route('/cmdrunconf',method='POST')
@checkAccess
def do_cmdrunconf():
    s = request.environ.get('beaker.session')
    ctype = request.forms.get("ctype")
    if ctype == 'A' :
       nodes = request.forms.getlist("nodes")
       expr_form = 'list'
    elif ctype == 'B' :
       nodes = request.forms.getlist("grpnodes")
       expr_form = 'nodegroup'
    else:
       nodes = request.forms.getlist("sshhost")
    nodes = ",".join(nodes)
    command = request.forms.get("command")
    from SaltAPI import SaltAPI
    sapi_host = AppServer().getConfValue('SaltAPI','APIhost')
    sapi_port = AppServer().getConfValue('SaltAPI','APIport')
    sapi_user = AppServer().getConfValue('SaltAPI','APIuser')
    sapi_pass = AppServer().getConfValue('SaltAPI','APIpass')
    sapiconn = SaltAPI(url='https://%s:%s' % (sapi_host,int(sapi_port)),username='%s' % sapi_user,password='%s' % sapi_pass)
    if ctype == 'A' or ctype == 'B':
       try:
         runresult = sapiconn.remote_localexec(nodes,'cmd.run',command,expr_form)
       except:
         sql1 = """ select id,nodeid,concat(nodeid,' | ',hostname,' | ',os) as nodeinfo from minioninfo where status='1' order by id """
         sql2 = """ SELECT id,grpname from nodegrpmgr """
         sql3 = """ SELECT id,hostaddr,concat(hostaddr,' | ',sshport,' | ',sshuser ) as sshinfo from sshmgr WHERE status='1' """
         nodeslist = readDb(sql1,)
         grpnodeslist = readDb(sql2,)
         sshconnlist = readDb(sql3,)
         return template('cmdrunconf',session=s,msg={},nodeslist=nodeslist,grpnodeslist=grpnodeslist,sshconnlist=sshconnlist,runresult='')
    else:
        x,runresult=cmds.gettuplerst('salt-ssh "%s" -r "%s" -L' % (nodes,command))
    if runresult:
       result=''
       try: #区分是salt-ssh返回类型，还是salt-api类型
          for x in runresult :
              result += '%s\n%s\n\n' % (x,runresult.get(x)) 
       except:
          result = runresult
       sql1 = """ select id,nodeid,concat(nodeid,' | ',hostname,' | ',os) as nodeinfo from minioninfo where status='1' order by id """
       sql2 = """ SELECT id,grpname from nodegrpmgr """
       sql3 = """ SELECT id,hostaddr,concat(hostaddr,' | ',sshport,' | ',sshuser ) as sshinfo from sshmgr WHERE status='1' """
       nodeslist = readDb(sql1,)
       grpnodeslist = readDb(sql2,)
       sshconnlist = readDb(sql3,)
       return template('cmdrunconf',session=s,msg={},nodeslist=nodeslist,grpnodeslist=grpnodeslist,sshconnlist=sshconnlist,runresult=result)


# 资产管理
@route('/itroomconf')
@checkAccess
def itroomconf():
    s = request.environ.get('beaker.session')
    return template('itroomconf',session=s,msg={})

@route('/addroom',method="POST")
@checkAccess
def addroom():
    s = request.environ.get('beaker.session')
    roomname = request.forms.get("roomname")
    roomaddr = request.forms.get("roomaddr")
    roomsize = request.forms.get("roomsize")
    startdate = request.forms.get("startdate")
    comment = request.forms.get("comment")
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """
            INSERT INTO
               roommgr(roomname,roomaddr,roomsize,startdate,comment)
            VALUES(%s,%s,%s,%s,%s)
        """
    data = (roomname,roomaddr,roomsize,startdate,comment)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changeroom/<id>',method="POST")
@checkAccess
def changeroom(id):
    s = request.environ.get('beaker.session')
    roomname = request.forms.get("roomname")
    roomaddr = request.forms.get("roomaddr")
    roomsize = request.forms.get("roomsize")
    startdate = request.forms.get("startdate")
    comment = request.forms.get("comment")
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """ update roommgr set roomname=%s,roomaddr=%s,roomsize=%s,startdate=%s,comment=%s where id=%s """
    data = (roomname,roomaddr,roomsize,startdate,comment,id)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/delroom/<id>')
@checkAccess
def delroom(id):
    s = request.environ.get('beaker.session')
    sqlx = "select id from hardwaremgr where FIND_IN_SET(%s,roomid)"
    resultx = readDb(sqlx,(id,))
    if resultx:
       msg={'color':'red','message':u'删除失败,该机房被硬件关联占用,禁止删除.建议编辑更新或取消关联'}
       return template('itroomconf',session=s,msg=msg)
    sql = "delete from roommgr where id in (%s) "
    result = writeDb(sql,(id,))
    if result:
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       msg={'color':'green','message':u'删除成功'}
       return template('itroomconf',session=s,msg=msg)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       msg={'color':'red','message':u'删除失败'}
       return template('itroomconf',session=s,msg=msg)


@route('/api/getroominfo',method=['GET', 'POST'])
@checkAccess
def getroominfo():
    sql = """ SELECT id,roomname,roomaddr,roomsize,startdate,comment from roommgr """
    roomlist = readDb(sql,)
    return json.dumps(roomlist,cls=DateEncoder)

@route('/hardwareconf')
@checkAccess
def itroomconf():
    s = request.environ.get('beaker.session')
    sql = """ SELECT id,roomname from roommgr """
    roomlist = readDb(sql,)
    return template('hardware',session=s,msg={},roomlist=roomlist)

@route('/addhdware',method="POST")
@checkAccess
def addhdware():
    s = request.environ.get('beaker.session')
    hdnumber = request.forms.get("hdnumber")
    hdname = request.forms.get("hdname")
    hdbrand = request.forms.get("hdbrand")
    roomid = request.forms.get("roomid")
    hddate = request.forms.get("hddate")
    supplier = request.forms.get("supplier")
    comment = request.forms.get("comment")
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """
            INSERT INTO
               hardwaremgr(hdnumber,hdname,hdbrand,roomid,hddate,supplier,comment)
            VALUES(%s,%s,%s,%s,%s,%s,%s)
        """
    data = (hdnumber,hdname,hdbrand,roomid,hddate,supplier,comment)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changehdware/<id>',method="POST")
@checkAccess
def changehdware(id):
    s = request.environ.get('beaker.session')
    hdnumber = request.forms.get("hdnumber")
    hdname = request.forms.get("hdname")
    hdbrand = request.forms.get("hdbrand")
    roomid = request.forms.get("roomid")
    hddate = request.forms.get("hddate")
    supplier = request.forms.get("supplier")
    comment = request.forms.get("comment")
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """ UPDATE hardwaremgr set hdnumber=%s,hdname=%s,hdbrand=%s,roomid=%s,hddate=%s,supplier=%s,comment=%s where id=%s """
    data = (hdnumber,hdname,hdbrand,roomid,hddate,supplier,comment,id)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/delhdware/<id>')
@checkAccess
def delhdware(id):
    s = request.environ.get('beaker.session')
    sqlx = "select id from hostmgr where FIND_IN_SET(%s,selecthd)"
    resultx = readDb(sqlx,(id,))
    if resultx:
       msg={'color':'red','message':u'删除失败,该硬件被主机关联,禁止删除.建议编辑更新或取消关联'}
       sql2 = """ SELECT id,roomname from roommgr """
       roomlist = readDb(sql2,)
       return template('hardware',session=s,msg=msg,roomlist=roomlist)
    sql = "delete from hardwaremgr where id in (%s) "
    result = writeDb(sql,(id,))
    sql2 = """ SELECT id,roomname from roommgr """
    roomlist = readDb(sql2,)
    if result:
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       msg={'color':'green','message':u'删除成功'}
       return template('hardware',session=s,msg=msg,roomlist=roomlist)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       msg={'color':'red','message':u'删除失败'}
       return template('hardware',session=s,msg=msg,roomlist=roomlist)

@route('/api/gethdwareinfo',method=['GET', 'POST'])
@checkAccess
def getroominfo():
    sql = """
    SELECT U.id,U.hdnumber,U.hdname,U.hdbrand,U.roomid,D.roomname,U.hddate,U.supplier,U.comment FROM hardwaremgr as U LEFT OUTER JOIN roommgr as D on U.roomid=D.id order by hdnumber
    """
    hdlist = readDb(sql,)
    return json.dumps(hdlist,cls=DateEncoder)

@route('/api/getsoftwareinfo',method=['GET', 'POST'])
@checkAccess
def getroominfo():
    sql = """
    SELECT id,softnumber,softname,softversion,softdate,supplier,filename,comment FROM softwaremgr order by softnumber
    """
    softlist = readDb(sql,)
    return json.dumps(softlist,cls=DateEncoder)

@route('/hostconf')
@checkAccess
def itroomconf():
    s = request.environ.get('beaker.session')
    sql = " SELECT id,hdname FROM hardwaremgr "
    hdlist = readDb(sql,)
    return template('hostmgr',session=s,msg={},hdlist=hdlist)

@route('/api/gethostinfo',method=['GET', 'POST'])
@checkAccess
def getroominfo():
    sql = """
    SELECT U.id,U.hostname,U.hostaddr,U.systype,U.selecthd,D.hdname,U.hostdate,U.comment FROM hostmgr as U LEFT OUTER JOIN hardwaremgr as D on U.selecthd=D.id order by U.id
    """
    hostlist = readDb(sql,)
    return json.dumps(hostlist,cls=DateEncoder)

@route('/addhost',method="POST")
@checkAccess
def addhost():
    s = request.environ.get('beaker.session')
    hostname = request.forms.get("hostname")
    hostaddr = request.forms.get("hostaddr")
    systype = request.forms.get("systype")
    selecthd = request.forms.get("selecthd")
    hostdate = request.forms.get("hostdate")
    comment = request.forms.get("comment")
    logging.debug(selecthd)
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """
            INSERT INTO
               hostmgr(hostname,hostaddr,systype,selecthd,hostdate,comment)
            VALUES(%s,%s,%s,%s,%s,%s)
        """
    data = (hostname,hostaddr,systype,selecthd,hostdate,comment)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changehost/<id>',method="POST")
@checkAccess
def changehost(id):
    s = request.environ.get('beaker.session')
    hostname = request.forms.get("hostname")
    hostaddr = request.forms.get("hostaddr")
    systype = request.forms.get("systype")
    selecthd = request.forms.get("selecthd")
    hostdate = request.forms.get("hostdate")
    comment = request.forms.get("comment")
    #检查表单长度
    #if len(username) < 4 or (len(passwd) > 0 and len(passwd) < 8) :
    #   message = "用户名或密码长度不符要求！"
    #   return '-2'
    #检测表单各项值，如果出现为空的表单，则返回提示
    #if not (username and policy and access):
    #    message = "表单不允许为空！"
    #    return '-2'
    sql = """
            UPDATE hostmgr set hostname=%s,hostaddr=%s,systype=%s,selecthd=%s,hostdate=%s,comment=%s WHERE id=%s
        """
    data = (hostname,hostaddr,systype,selecthd,hostdate,comment,id)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/delhost/<id>')
@checkAccess
def delhost(id):
    s = request.environ.get('beaker.session')
    sql = "delete from hostmgr where id in (%s) "
    result = writeDb(sql,(id,))
    sql2 = " SELECT id,hdname FROM hardwaremgr "
    hdlist = readDb(sql2,)
    if result:
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       msg={'color':'green','message':u'删除成功'}
       return template('hostmgr',session=s,msg=msg,hdlist=hdlist)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       msg={'color':'red','message':u'删除失败'}
       return template('hostmgr',session=s,msg=msg,hdlist=hdlist)

@route('/softmgr')
@checkAccess
def itroomconf():
    s = request.environ.get('beaker.session')
    return template('softmgrconf',session=s,msg={})

@route('/addsoftware',method="POST")
@checkAccess
def addsoftware():
    s = request.environ.get('beaker.session')
    softnumber = request.forms.get('softnumber')
    softname = request.forms.get('softname')
    softversion = request.forms.get('softversion')
    softdate = request.forms.get('softdate')
    supplier = request.forms.get('supplier')
    comment = request.forms.get('comment')
    fname = request.forms.get('fname')
    softfile = request.forms.get('fdesc')
    if not (softnumber and softversion and softname and softdate and supplier):
       return '-2'
    sql = """
            INSERT INTO softwaremgr (softnumber,softname,softversion,softdate,supplier,filename,softfile,comment) VALUE (%s,%s,%s,%s,%s,%s,%s,%s)
        """
    data = (softnumber,softname,softversion,softdate,supplier,fname,softfile,comment)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changesoftware/<id>',method="POST")
@checkAccess
def changesoftware(id):
    s = request.environ.get('beaker.session')
    softnumber = request.forms.get('softnumber')
    softname = request.forms.get('softname')
    softversion = request.forms.get('softversion')
    softdate = request.forms.get('softdate')
    supplier = request.forms.get('supplier')
    comment = request.forms.get('comment')
    fname = request.forms.get('fname')
    softfile = request.forms.get('fdesc')
    if not (softnumber and softversion and softname and softdate and supplier):
       return '-2'
    if fname :
       sql = """ UPDATE softwaremgr set softnumber=%s,softname=%s,softversion=%s,softdate=%s,supplier=%s,filename=%s,softfile=%s,comment=%s where id=%s """
       data = (softnumber,softname,softversion,softdate,supplier,fname,softfile,comment,id)
    else:
       sql = """ UPDATE softwaremgr set softnumber=%s,softname=%s,softversion=%s,softdate=%s,supplier=%s,comment=%s where id=%s """
       data = (softnumber,softname,softversion,softdate,supplier,comment,id)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/downsoftfile/<id>')
def downsoftfile(id):
    sql=""" SELECT filename,softfile from softwaremgr where id=%s """
    result = readDb(sql,(id,))
    filename = result[0].get('filename')
    f = open("/tmp/%s" % filename, "wb")
    f.write(result[0].get('softfile'))
    f.close()
    download_path = "/tmp"
    return static_file(filename, root=download_path, download=filename)

@route('/delsoftware/<id>')
@checkAccess
def delhdware(id):
    s = request.environ.get('beaker.session')
    sql = "delete from softwaremgr where id in (%s) "
    result = writeDb(sql,(id,))
    if result:
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       msg={'color':'green','message':u'删除成功'}
       return template('softmgrconf',session=s,msg=msg)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       msg={'color':'red','message':u'删除失败'}
       return template('softmgrconf',session=s,msg=msg)

@route('/tasklist')
@checkAccess
def taskconf():
    s = request.environ.get('beaker.session')
    sql = """ select D.id,FROM_UNIXTIME(U.next_run_time) as ntime,D.taskname from apscheduler_jobs as U LEFT OUTER JOIN taskconf as D on position(D.id in U.id) order by ntime limit 9"""
    njobdata = readDb(sql,)
    sql2 = """ SELECT U.id,U.jobtime,U.runstatus,D.taskname FROM apscheduler_logs as U LEFT OUTER JOIN taskconf as D on U.jobid=D.id order by id DESC limit 21 """
    sjobdata = readDb(sql2,)
    #暂排除runstatus 返回None  数值为20的情况，原因待查
    sql3 = """ SELECT U.id,U.jobtime,U.runstatus,D.taskname FROM apscheduler_logs as U LEFT OUTER JOIN taskconf as D on U.jobid=D.id WHERE runstatus != '0' AND runstatus != '20' order by id DESC limit 8 """
    errjobdata = readDb(sql3,)
    return template('tasklist',session=s,njobdata=njobdata,sjobdata=sjobdata,errjobdata=errjobdata)

@route('/taskconf/<id>')
@checkAccess
def taskconf(id):
    s = request.environ.get('beaker.session')
    sql1 = """ select id,nodeid,concat(nodeid,' | ',hostname,' | ',os ) as nodeinfo from minioninfo where status='1' order by id """
    sql2 = """ SELECT id,grpname from nodegrpmgr """
    sql3 = """ SELECT id,concat(hostaddr,' | ',sshport,' | ',sshuser ) as sshinfo from sshmgr WHERE status='1' """
    sql4 = """ SELECT id,grpname from taskgrpmgr"""
    nodeslist = readDb(sql1,)
    grpnodeslist = readDb(sql2,)
    sshconnlist = readDb(sql3,)
    taskgrplist = readDb(sql4,)
    return template('taskconf',grpid=id,session=s,msg={},nodeslist=nodeslist,grpnodeslist=grpnodeslist,sshconnlist=sshconnlist,taskgrplist=taskgrplist)

@route('/addtask',method='POST')
@checkAccess
def do_taskconf():
    s = request.environ.get('beaker.session')
    api_type = request.forms.get("api_type")
    if api_type == '0' or api_type == '2':
       api_obj = request.forms.getlist("api_obj[]")
    else:
       api_obj = request.forms.getlist("api_obj")
    api_obj = ",".join(api_obj)
    taskname = request.forms.get("taskname")
    taskdesc = request.forms.get("taskdesc")
    timedesc = request.forms.get("timedesc")
    if iScheduler().TimeAuth(timedesc) == False:
       return '-2'
    runobject = request.forms.get("runobject")
    sql = """ insert into taskconf (taskname,taskdesc,timedesc,api_type,api_obj,runobject) value (%s,%s,%s,%s,%s,%s) """
    data = (taskname,taskdesc,timedesc,api_type,api_obj,runobject)
    result = writeDb(sql,data)
    if result:
       iScheduler().writeTaskFunc()
       cmds.servboot('taskserv')
       return '0'
    else :
       return '-1'
    
@route('/changetask/<id>',method='POST')
@checkAccess
def do_taskconf(id):
    s = request.environ.get('beaker.session')
    api_type = request.forms.get("api_type")
    if api_type == '0' or api_type == '2':
       api_obj = request.forms.getlist("api_obj[]")
    else:
       api_obj = request.forms.getlist("api_obj")
    api_obj = ",".join(api_obj)
    taskname = request.forms.get("taskname")
    taskdesc = request.forms.get("taskdesc")
    timedesc = request.forms.get("timedesc")
    if iScheduler().TimeAuth(timedesc) == False:
       return '-2'
    runobject = request.forms.get("runobject")
    sql = """ update taskconf set taskname=%s,taskdesc=%s,timedesc=%s,api_type=%s,api_obj=%s,runobject=%s where id=%s """
    data = (taskname,taskdesc,timedesc,api_type,api_obj,runobject,id)
    result = writeDb(sql,data)
    if result:
       iScheduler().writeTaskFunc()
       cmds.servboot('taskserv')
       return '0'
    else :
       return '-1'

@route('/api/gettaskinfo/<id>',method=['GET', 'POST'])
@checkAccess
def gettaskinfo(id):
    if id == 'alllist':
       sql = """
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.nodeid) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN minioninfo as D on position(D.id in U.api_obj)
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type='0' GROUP BY U.id 
        union 
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.grpname) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN nodegrpmgr as D on position(D.id in U.api_obj) 
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type="1" GROUP BY U.id
        union
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.hostaddr) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN sshmgr as D on position(D.id in U.api_obj) 
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type='2' GROUP BY U.id ;   
        """
       tasklist = readDb(sql,)
    else:
       sql2= """ SELECT grptasks from taskgrpmgr where id=%s """
       result = readDb(sql2,(id,))
       sql3 = """
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.nodeid) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN minioninfo as D on position(D.id in U.api_obj)
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type='0' AND FIND_IN_SET(U.id,%s) GROUP BY U.id 
        union 
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.grpname) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN nodegrpmgr as D on position(D.id in U.api_obj) 
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type='1' AND FIND_IN_SET(U.id,%s) GROUP BY U.id
        union
        SELECT U.id,U.taskname,U.taskdesc,U.timedesc,U.api_type,U.api_obj,GROUP_CONCAT(D.hostaddr) as objdesc,FROM_UNIXTIME(E.next_run_time) as ntime,U.runobject,U.status
        FROM taskconf as U LEFT OUTER JOIN sshmgr as D on position(D.id in U.api_obj) 
        LEFT OUTER JOIN apscheduler_jobs as E on position(U.id in E.id)
        where api_type='2' AND FIND_IN_SET(U.id,%s) GROUP BY U.id ;   
        """
       tasklist = readDb(sql3,(str(result[0].get('grptasks')),str(result[0].get('grptasks')),str(result[0].get('grptasks'))))
    return json.dumps(tasklist,cls=DateEncoder)


@route('/sshconf')
@checkAccess
def do_sshconf():
    s = request.environ.get('beaker.session')
    s['WebSSHurl'] = AppServer().getConfValue('WSSHAPI','WebSSHurl')
    return template('sshconf',session=s,msg={},info={})

@route('/addsshconn',method='POST')
@checkAccess
def do_addsshconn():
    s = request.environ.get('beaker.session')
    hostdesc = request.forms.get("hostdesc")
    hostaddr = request.forms.get("hostaddr")
    sshport = request.forms.get("sshport")
    sshuser = request.forms.get("sshuser")
    sshpass = request.forms.get("sshpass")
    if sshpass :
       sshpass = LoginCls().encode(keys,sshpass)
    else:
       return '-1'
    sql = """ insert into sshmgr (hostdesc,hostaddr,sshport,sshuser,sshpass) value (%s,%s,%s,%s,%s) """
    data = (hostdesc,hostaddr,sshport,sshuser,sshpass)
    result = writeDb(sql,data)
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       SaltCLS().SSHkeyPass(hostaddr)
       return '0'
    else :
       return '-2'

@route('/changesshconn/<id>',method='POST')
@checkAccess
def do_changesshconn(id):
    s = request.environ.get('beaker.session')
    hostdesc = request.forms.get("hostdesc")
    hostaddr = request.forms.get("hostaddr")
    sshport = request.forms.get("sshport")
    sshuser = request.forms.get("sshuser")
    sshpass = request.forms.get("sshpass")
    sql = " select sshpass from sshmgr where id=%s "
    result = readDb(sql,(id,))
    if not sshpass :
       sshpass = result[0].get('sshpass')
    else :
       sshpass = LoginCls().encode(keys,sshpass)
    sql = """ UPDATE sshmgr set hostdesc=%s,hostaddr=%s,sshport=%s,sshuser=%s,sshpass=%s WHERE id=%s """
    data = (hostdesc,hostaddr,sshport,sshuser,sshpass,id)
    result = writeDb(sql,data)
    if result:
       SaltCLS().writeSALTconf(action='uptconf')
       SaltCLS().SSHkeyPass(hostaddr)
       return '0'
    else :
       return '-1'

#密匙互信接口
@route('/keypass/<hostaddr>')
@checkAccess
def do_keypass(hostaddr):
    s = request.environ.get('beaker.session')
    if SaltCLS().SSHkeyPass(hostaddr) == True:
       msg = {'color':'green','message':u'重建密匙互信成功'}
       return template('sshconf',session=s,msg=msg)
    else:
       msg = {'color':'red','message':u'重建密匙互信失败,请检查连接信息'}
       return template('sshconf',session=s,msg=msg)

@route('/chgstatus/<nodetype>/<id>')
@checkAccess
def do_chgstatus(nodetype,id):
    s = request.environ.get('beaker.session')
    sql_1 = """ update sshmgr set status=%s where id=%s """
    sql_2 = """ update taskconf set status=%s where id=%s """
    msg = {'color':'green','message':u'状态更新成功'}
    if nodetype == 'sshmgrdisable':
       data_1=(0,id)
       writeDb(sql_1,data_1)
       return template('sshconf',session=s,msg=msg)
    elif nodetype == 'sshmgractive':
       data_1=(1,id)
       writeDb(sql_1,data_1)
       return template('sshconf',session=s,msg=msg)
    elif nodetype == 'taskmgrdisable':
       data_2=(0,id)
       writeDb(sql_2,data_2)
       #重新加载Task服务
       iScheduler().writeTaskFunc()
       cmds.servboot('taskserv')
       return redirect('/taskconf/alllist')
    elif nodetype == 'taskmgractive':
       data_2=(1,id)
       writeDb(sql_2,data_2)
       #重新加载Task服务
       iScheduler().writeTaskFunc()
       cmds.servboot('taskserv')
       return redirect('/taskconf/alllist')

@route('/delsshconf/<id>')
@checkAccess
def do_delsshconf(id):
    s = request.environ.get('beaker.session')
    sqlx = "select id from taskconf where api_type='2' and FIND_IN_SET(%s,api_obj)"
    resultx = readDb(sqlx,(id,))
    if resultx:
       msg={'color':'red','message':u'删除失败,该配置被关联任务计划,禁止删除.建议先取消关联'}
       return template('sshconf',session=s,msg=msg)
    sql = """ delete from sshmgr where id=%s """
    result = writeDb(sql,(id,))
    if result:
       msg = {'color':'green','message':u'删除成功'}
    else:
       msg = {'color':'red','message':u'删除失败'}
    return template('sshconf',session=s,msg=msg)

@route('/deltask/<id>')
@checkAccess
def do_deltask(id):
    s = request.environ.get('beaker.session')
    sql = """ delete from taskconf where id=%s """
    result = writeDb(sql,(id,))
    if result:
       iScheduler().writeTaskFunc()
       cmds.servboot('taskserv')
       msg = {'color':'green','message':u'删除成功'}
    else:
       msg = {'color':'red','message':u'删除失败'}
    return redirect('/taskconf/alllist')

@route('/runtask/<id>')
@checkAccess
def do_runtask(id):
    s = request.environ.get('beaker.session')
    sql = """ SELECT status from taskconf where id=%s """
    result = readDb(sql,(id,))
    if result[0].get('status') == 0 :
       iScheduler().TaskFuncAPI(id,0)
    else:
       iScheduler().TaskFuncAPI(id)
    return redirect('/taskconf/alllist')

@route('/tasklogs/<id>')
@checkAccess
def gettasklogs(id):
    s = request.environ.get('beaker.session')
    sql = """ SELECT id,taskname FROM taskconf where id=%s """
    info = readDb(sql,(id,))
    return template('tasklogs',session=s,msg={},info=info[0])

@route('/api/gettasklogs/<id>',method=['GET', 'POST'])
@checkAccess
def getsshinfo(id):
    sql = """ SELECT id,jobid,jobtime,apimode,hostlist,runstatus FROM apscheduler_logs where jobid=%s order by jobtime desc limit 500"""
    logs = readDb(sql,(id,))
    return json.dumps(logs,cls=DateEncoder)

@route('/taskrecord/<id>')
@checkAccess
def gettaskrecord(id):
    s = request.environ.get('beaker.session')
    sql = """ SELECT jobid,jobtime,apimode,hostlist,runstatus,runFuncAPI,jobresult FROM apscheduler_logs where id=%s """
    info = readDb(sql,(id,))
    infos = {}
    infos['jobid'] = info[0].get('jobid')
    infos['comment'] = '日志ID:%s\n执行时间:%s\n操作模式:%s;操作主机:%s;运行状态:%s' % (id,info[0].get('jobtime'),info[0].get('apimode'),info[0].get('hostlist'),info[0].get('runstatus'))
    infos['runcmd'] = info[0].get('runFuncAPI')
    infos['result'] = info[0].get('jobresult')
    return template('taskrecord',session=s,msg={},info=infos)

@route('/api/getsshinfo',method=['GET', 'POST'])
@checkAccess
def getsshinfo():
    sql = """ SELECT id,hostdesc,hostaddr,sshport,sshuser,sshpass,status FROM sshmgr """
    sshlist = readDb(sql,)
    return json.dumps(sshlist,cls=DateEncoder)

@route('/taskgroup')
@checkAccess
def minionmgr():
    s = request.environ.get('beaker.session')
    sql = " select id,taskname from taskconf where status='1' order by id"
    tasklist = readDb(sql,)
    return template('taskgroup',session=s,msg={},tasklist=tasklist)

@route('/addtaskgrp',method="POST")
@checkAccess
def do_addtaskgrp():
    s = request.environ.get('beaker.session')
    grpname = request.forms.get("grpname")
    grpdesc = request.forms.get("grpdesc")
    grptasks = request.forms.getlist("grptasks[]")
    grptasks = ",".join(grptasks)
    sql = """
            INSERT INTO
               taskgrpmgr(grpname,grpdesc,grptasks)
            VALUES(%s,%s,%s)
        """
    data = (grpname,grpdesc,str(grptasks))
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changetaskgrp/<id>',method="POST")
@checkAccess
def do_changetaskgrp(id):
    s = request.environ.get('beaker.session')
    grpname = request.forms.get("grpname")
    grpdesc = request.forms.get("grpdesc")
    grptasks = request.forms.getlist("grptasks[]")
    grptasks = ",".join(grptasks)
    sql = """ UPDATE taskgrpmgr SET grpname=%s,grpdesc=%s,grptasks=%s WHERE id=%s """
    data = (grpname,grpdesc,str(grptasks),id)
    result = writeDb(sql,data)
    if result:
       #wrtlog('User','新增成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       #wrtlog('User','新增失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/deltaskgrp/<id>')
@checkAccess
def deltaskgrp(id):
    s = request.environ.get('beaker.session')
    sql = "delete from taskgrpmgr where id in (%s) "
    result = writeDb(sql,(id,))
    if result:
       #wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       sql = " select id,taskname from taskconf where status='1' order by id"
       tasklist = readDb(sql,)
       msg={'color':'green','message':u'删除成功'}
       return template('taskgroup',session=s,msg=msg,tasklist=tasklist)
    else:
       #wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       sql = " select id,taskname from taskconf where status='1' order by id"
       tasklist = readDb(sql,)
       msg={'color':'red','message':u'删除失败'}
       return template('taskgroup',session=s,msg=msg,tasklist=tasklist)

@route('/api/gettaskgrpinfo',method=['GET', 'POST'])
@checkAccess
def gettaskgrpinfo():
    sql = """ SELECT U.id,U.grpname,U.grpdesc,U.grptasks,GROUP_CONCAT(D.taskname) as tasknames from taskgrpmgr as U LEFT OUTER JOIN taskconf as D on position(D.id in U.grptasks) GROUP by U.id """
    taskgrplist = readDb(sql,)
    return json.dumps(taskgrplist,cls=DateEncoder)

@route('/apilists')
@checkAccess
def taskconf():
    s = request.environ.get('beaker.session')
    return template('apilists',session=s,msg={})

@route('/downloadtasklist')
@checkAccess
def taskconf():
    s = request.environ.get('beaker.session')
    filename='Tasklist_%s.xls' % datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    iScheduler().ExportTaskList(filename)
    return static_file(filename, root='/tmp', download=filename)

if __name__ == '__main__' :
   sys.exit()
