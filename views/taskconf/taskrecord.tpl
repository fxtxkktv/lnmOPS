%rebase base position='任务记录详情', managetopli="opsconf"

<link rel="stylesheet" href="/assets/bootstrap-select/bootstrap-select.min.css">
<link href="/assets/css/charisma-app.css" rel="stylesheet" type="text/css" />

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget" style="background: #fff;">
                <!--div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">任务记录详情</span>
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
                </div--><!--Widget Header-->
       <div style="padding:-10px 0px;" class="widget-body no-padding">
       <form action="" method="post">
          <div class="box col-md-12" style="padding-left:0px;">
            <div class="box-inner widget" style="background: #fff;">
            <div class="box-header well" data-original-title>
                <i class="glyphicon glyphicon-list-alt widget-icon"></i>
                <span class="widget-caption themesecondary">执行记录信息</span>
            </div>
            <div class="modal-body" style="width:100%">
                  <label class="" for="inputSuccess1">任务描述</label>
                  <textarea style="height:60px;width:100%;resize:vertical;font-family:sans-serif;" readonly>{{info.get('comment','')}}</textarea>
            </div>
            <div class="modal-body" style="width:100%">
                  <label class="" for="inputSuccess1">操作指令</label>
                  <textarea style="height:25px;width:100%;resize:vertical;font-family:sans-serif;" readonly>{{info.get('runcmd','')}}</textarea>
            </div>
            <div class="modal-body" style="width:100%">
                  <label class="" for="inputSuccess1">返回结果</label>
                  <textarea style="width:100%;height:250px;background-color:#000000;color:#33ff33;resize:none;font-family:sans-serif;" maxlength="2048" readonly>{{info.get('result','')}}</textarea>
            </div>
            <div class="modal-footer">
                        <a style="float:left" href="/tasklogs/{{info.get('jobid','')}}" class="btn btn-primary ">返回记录列表</a>
            </div>
          </div></div></div>
         </div>
       </form>
      </div>
     </div>
    </div>
</div>
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script> 
<script src="/assets/bootstrap-select/bootstrap-select.min.js"></script>
