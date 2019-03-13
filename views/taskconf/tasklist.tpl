%rebase base position='CRON计划列表', managetopli="opsconf"

<link rel="stylesheet" href="/assets/bootstrap-select/bootstrap-select.min.css">
<link href="/assets/css/charisma-app.css" rel="stylesheet" type="text/css" />

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget" style="background: #fff;">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">计划列表</span>
                    <div class="widget-buttons">
                        <a href="#" data-toggle="maximize">
                            <i class="fa fa-expand"></i>
                        </a>
                        <a href="#" data-toggle="collapse">
                            <i class="fa fa-minus"></i>
                        </a>
                        <a href="#" data-toggle="dispose">
                            <i class="fa fa-times"></i>
                        </a>
                    </div>
                </div><!--Widget Header-->
       <div style="padding:-10px 0px;" class="widget-body no-padding">
       <form action="" method="post">
          <div class="box col-md-6" style="padding-left:0px;">
            <div class="box-inner widget" style="background: #fff;">
            <div class="box-header well" data-original-title>
                <i class="glyphicon glyphicon-list-alt widget-icon"></i>
                <span class="widget-caption themesecondary">即将执行任务</span>
            </div>
            <div class="box-content" style="height:400px;padding:0px;">
                <div style="display: block;" id="Task02">
                    <table class="table">
                        <tbody>
                        <tr>
                        <td>任务名称</td>
                        <td class="center">下次执行时间</td>
                        </tr>
                        %for job in njobdata:
                        <tr>
                        <td><a href="/tasklogs/{{job.get('id','')}}">{{job.get('taskname','')}}</a></td>
                        <td class="center" style="width:200px;">{{job.get('ntime','')}}</td>
                        </tr>
                        %end
                        </tbody>
                    </table>
                </div>
            </div>
          </div></div>
          <!--right-->
          <div class="box col-md-6" style="padding-right:0px;">
            <div class="box-inner widget" style="background: #fff;">
            <div class="box-header well" data-original-title>
                <i class="glyphicon glyphicon-list-alt widget-icon"></i>
                <span class="widget-caption themesecondary">最近执行任务</span>
            </div>
            <div class="box-content" style="height:400px;padding:0px;">
                <div style="display: block;" id="Task01">
                    <table class="table">
                        <tbody>
                        <tr>
                        <td>任务名称</td>
                        <td class="center" style="width:200px;">上次执行时间</td>
                        <td class="center" style="width:100px;">执行状态</td>
                        </tr>
                        %for sjob in sjobdata:
                        <tr>
                        <td><a href="/taskrecord/{{sjob.get('id','')}}">{{sjob.get('taskname','')}}</a></td>
                        <td class="center" style="width:200px;">{{sjob.get('jobtime','')}}</td>
                        %if sjob.get('runstatus','') == 0:
                           <td class="center" style="color:green;width:100px;">正常</td>
                        %else:
                           <td class="center" style="color:red;width:100px;">异常</td>
                        %end
                        </tr>
                        %end
                        </tbody>
                    </table>
                </div>
            </div>
          </div></div>
          <div class="box col-md-6" style="padding-left:0px;">
            <div class="box-inner widget" style="background: #fff;">
            <div class="box-header well" data-original-title>
                <i class="glyphicon glyphicon-list-alt widget-icon"></i>
                <span class="widget-caption themesecondary">执行失败任务</span>
            </div>
            <div class="box-content" style="height:330px;padding:0px;">
                <div style="display: block;" id="Task03">
                    <table class="table">
                        <tbody>
                        <tr>
                        <td>任务名称</td>
                        <td class="center" style="width:200px;">上次执行时间</td>
                        <td class="center" style="width:100px;">执行状态</td>
                        </tr>
                        %for errjob in errjobdata:
                        <tr>
                        <td><a href="/taskrecord/{{errjob.get('id','')}}">{{errjob.get('taskname','')}}</a></td>
                        <td class="center" style="width:200px;">{{errjob.get('jobtime','')}}</td>
                        %if errjob.get('runstatus','') == 0:
                           <td class="center" style="color:green;width:100px;">正常</td>
                        %else:
                           <td class="center" style="color:red;width:100px;">异常</td>
                        %end
                        </tr>
                        %end
                        </tbody>
                    </table>
                </div>
            </div>
          </div></div>
         </div>
       </form>
      </div>
     </div>
    </div>
</div>
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script> 
<script src="/assets/bootstrap-select/bootstrap-select.min.js"></script>

<script language="JavaScript">
    $(function () {
        setInterval(function () {
            //注意后面DIV的ID前面的空格，很重要！没有空格的话，会出双眼皮！（也可以使用类名）
            $("#Task01").load(location.href + " #Task01")
        }, 10000); //10秒自动刷新
    })
    $(function () {
        setInterval(function () {
            $("#Task02").load(location.href + " #Task02")
        }, 30000); //30秒自动刷新
    })
    $(function () {
        setInterval(function () {
            $("#Task03").load(location.href + " #Task03")
        }, 60000); //60秒自动刷新
    })
</script>
