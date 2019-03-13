# 该项目应用于企业Windows/Linux系统JOB任务维护
### 1.支持SALT集群管理
### 7.支持JOB任务远程调用、SSH模式调用、SALT模式调用等

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

3. 创建数据库并恢复数据模版 <br>
[创建数据库]: # mysql -u root -p -e "create database vpndb" <br>
[恢复数据模版]: # mysql -u root -p vpndb < readme/xxxxxx_Init.sql <br>
[配置数据库连接及其他]: # vim config/config.ini <br>

4. 正式运行程序 <br>
[程序调试]：python27 main.py <br>
[后台运行]: startweb.sh restart <br>
[前段访问]：https://IP地址:端口号 用户名：admin 密码: admin<br>
[修改safekey]: 首次使用建议修改passkey，可通过API接口重置管理员密码[python tools/API.py API resetAdminPass newpass]<br>

备注：程序启动将自动接管网络接口配置、DNS服务、DHCP服务等相关，建议关闭系统中涉及到的相关程序，以免相互冲突。<br>

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
