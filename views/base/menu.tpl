
<!-- Page Sidebar -->
<div class="page-sidebar" id="sidebar">
    <!-- Page Sidebar Header-->
    <!--div class="sidebar-header-wrapper">
        <input type="text" class="searchinput" />
        <i class="searchicon fa fa-search"></i>
        <div class="searchhelper">搜索</div>
    </div-->
    <!-- /Page Sidebar Header -->

    <!-- Sidebar Menu -->
    <ul class="nav sidebar-menu">
        <!--Dashboard-->
        <li>
            <a href="/project">
                <i class="menu-icon glyphicon glyphicon-home"></i>
                <span class="menu-text"> 欢迎主页 </span>
            </a>
        </li>
    %if session.get('access','') == 1 :
        %if get('managetopli','')=='system':
          <li class="active open">
        %else:
          <li class="active">
    %end
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-desktop"></i>
                <span class="menu-text"> 系统管理</span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/systeminfo">
                        <span class="menu-text">系统信息</span>
                    </a>
                </li>
                <li class="">
                  <a href="/resconfig">
                  <span class="menu-text">监控配置</span>
                  </a>
                </li>
                <li class="">
                    <a href="/administrator">
                        <span class="menu-text">管&nbsp;理&nbsp;员</span>
                    </a>
                </li>
                <li class="">
                    <a href="/backupset">
                        <span class="menu-text">数据备份</span>
                    </a>
                </li>
	     </ul>
	 </li>
    %if session.get('access','') == 1 :
        %if get('managetopli','')=='saltmgr':
          <li class="active open">
        %else:
          <li class="active">
    %end
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-cubes"></i>
                <span class="menu-text"> 集中部署</span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/saltservconf">
                        <span class="menu-text">SALT配置</span>
                    </a>
                </li>
                <li class="">
                  <a href="/minionmgr">
                  <span class="menu-text">SALT终端</span>
                  </a>
                </li>
                 <li class="">
                    <a href="/nodegroup">
                        <span class="menu-text">SALT分组</span>
                    </a>
                </li>
                <li class="">
                    <a href="/sshconf">
                        <span class="menu-text">SSH管理</span>
                    </a>
                </li>
                <li class="">
                    <a href="/cmdrunconf">
                        <span class="menu-text">指令推送</span>
                    </a>
                </li>
         </ul>
     </li>
	%if get('managetopli','')=='assetconf':
          <li class="active open">
    %else:
          <li class="active">
    %end
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-tasks"></i>
                <span class="menu-text">资产管理</span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/itroomconf">
                        <span class="menu-text">机房管理</span>
                    </a>
                </li>
                <li class="">
                    <a href="/hostconf">
                        <span class="menu-text">主机管理</span>
                    </a>
                </li>
                <li class="">
                    <a href="/hardwareconf">
                        <span class="menu-text">硬件管理</span>
                    </a>
                </li>
                <li class="">
                    <a href="/softmgr">
                        <span class="menu-text">软件管理</span>
                    </a>
                </li>
            </ul>
        </li>

	%if get('managetopli','')=='opsconf':
          <li class="active open">
        %else:
          <li class="active">
        %end
	    <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-shield"></i>
                <span class="menu-text"> 运维管理 </span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/tasklist">
                        <span class="menu-text">计划列表</span>
                    </a>
                </li>
                <li class="">
                    <a href="/taskconf/alllist">
                        <span class="menu-text">任务管理</span>
                    </a>
                </li>
                <li class="">
                    <a href="/taskgroup">
                        <span class="menu-text">分组设置</span>
                    </a>
                </li>
                <!--li class="">
                    <a href="/apilists">
                        <span class="menu-text">API管理</span>
                    </a>
                </li-->
            </ul>
        </li>

        %if get('managetopli','')=='auditlog':
          <li class="active open">
         %else:
          <li class="active">
         %end
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-print"></i>
                <span class="menu-text"> 日志审计 </span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/showservlog">
                        <span class="menu-text">运维日志</span>
                    </a>
                </li>
                <li class="">
                    <a href="/applog">
                        <span class="menu-text">管理日志</span>
                    </a>
                </li>
            </ul>
        </li>
	%end

	%if get('managetopli','')=='help':
          <li class="active open">
         %else:
          <li class="active">
         %end
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-tty"></i>
                <span class="menu-text"> 帮助文档 </span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/clientdownload">
                        <span class="menu-text">文件下载</span>
                    </a>
                </li>
                <li class="">
                    <a href="/support">
                        <span class="menu-text">问题反馈</span>
                    </a>
                </li>
                <li class="">
                    <a href="/cronhelp">
                        <span class="menu-text">Cron表达式说明</span>
                    </a>
                </li>
            </ul>
        </li>

	<li class="active">
         %end
            <a href="http://blog.lnmos.com" target="_bank" class="menu-dropdown">
                <i class="menu-icon fa fa-address-book-o"></i>
                <span class="menu-text"> AboutMe </span>
                <i class="menu-expand"></i>
            </a>
	</li>
    </ul>
    <!-- /Sidebar Menu -->
</div>
<!-- /Page Sidebar -->
<!-- Page Content -->
