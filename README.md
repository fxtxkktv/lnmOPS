# 该项目应用于企业Windows/Linux系统OPS自动化运维
### 1.支持SALT集群管理
### 2.支持JOB任务远程调用、SSH模式调用、SALT模式调用等
### 3.集群管理、资产管理、故障管理【机房+主机+硬件+软件】
### 4.支持Web SSH在线登录管理
### 5.支持WebService精简配置，无缝对接各系统脚本传参
### 6.支持保留所有任务运行记录查询

## 安装步骤(仅针对centos/redhat发行版,其他版本自行测试)

1. 安装初始化环境 python >=2.7 (推荐lnmos定制版本,可以在"客户端下载"中获取) <br>
rpm -i Py27lnmos-2.7.15-6.el6.rpm <br>
加载python环境 <br>
export PATH=$PATH:/opt/Py27lnmos/bin <br>
检测是否安装必须工具 <br>
yum -y install wget git <br>
安装pip工具 <br>
wget https://bootstrap.pypa.io/get-pip.py <br>
/opt/Py27lnmos/bin/python get-pip.py <br>
安装virtualenv组件[使程序运行环境和系统环境分离] <br>
/opt/Py27lnmos/bin/pip install virtualenv <br> 
获取程序代码 <br>
git clone https://github.com/fxtxkktv/lnmOPS.git <br>
进入程序目录 <br>
cd lnmOPS <br>
创建程序虚拟环境 <br>
virtualenv -p /opt/Py27lnmos/bin/python --no-site-packages venv <br>
进入virtualenv环境 <br>
source venv/bin/activate <br>

2. 安装程序运行模块 <br>
MySQL服务 <br>
yum install -y gcc mysql-server mysql-devel MySQL-python <br>
安装Python程序扩展包 <br>
pip install -r readme/requirements.txt <br>
安装SALT模块[采用编译安装方式]<br>
pip install --global-option="--salt-root-dir=$(pwd)/plugins/salt/" salt==2018.3.4 <br>

3. 创建数据库并恢复数据模版 <br>
[创建数据库]: # mysql -u root -p -e "create database lnmopsdb" <br>
[恢复数据模版]: # mysql -u root -p lnmopsdb < readme/xxxxxx_Init.sql <br>
[配置数据库连接及其他]: # vim config/config.ini <br>

4. 正式运行程序 <br>
[程序调试]：python27 main.py <br>
[后台运行]: startweb.sh restart <br>
[前段访问]：https://IP地址:端口号 用户名：admin 密码: admin<br>
[修改safekey]: 首次使用建议修改passkey，可通过API接口重置管理员密码[python tools/API.py API resetAdminPass newpass]<br>

5. 程序WebSSH组件为自选组件，默认不安装，如果安装的话，可参照下列步骤。<br>
[获取WebSSH2代码]: git clone https://github.com/billchurch/WebSSH2 <br>
[安装nvm、nodejs、npm工具链]: <br>
curl  -o - https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh |bash <br>
nvm install v10.14.2<br>
进入WebSSH2程序目录,安装项目,启动项目,为和项目配合，这里采用密钥认证自动登录 <br>
cd WebSSH2/app <br>
npm install --production <br>
[修改配置]: vim WebSSH2/app/server/socket.js <br>

=======分割线开始===================================================<br>
var fs = require('fs'); //第一行添加 <br>
修改 conn.connect 方法, 注释password, 添加privateKey <br>
    username: socket.request.session.username, <br>
    //password: socket.request.session.userpassword, <br>
    privateKey: fs.readFileSync('替代程序目录/plugins/salt/etc/salt/pki/master/ssh/salt-ssh.rsa'), <br>
==========分割线====================================================<br>

[手动启动webssh,后续将随lnmOPS服务自动启动]: npm start <br>
主要配置参数文件，可按自行参数自行修改。强烈建议关闭外部映射，通过VPN方式进行远程维护 <br>
config.json （修改监听端口）<br>
erver/socket.js (修改验证方式)<br>

如有问题可直接反馈或邮件master@lnmos.com <br>

## 项目截图
### 系统管理
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/systemmgr.jpg)
### SALT终端管理
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/saltminion.jpg)
### SSH模式管理
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/sshmgr.jpg)
### 机房管理
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/itroommgr.jpg)
### 任务管理
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/taskconf.jpg)
### 帮助文档
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/help.jpg)
### 支持捐赠
![其余界面](https://github.com/fxtxkktv/lnmOPS/blob/master/readme/pay.jpg)
