%rebase base position='SALT服务配置', managetopli="saltmgr"

<link rel="stylesheet" href="/assets/bootstrap-select/bootstrap-select.min.css">
<link href="/assets/css/charisma-app.css" rel="stylesheet" type="text/css" />

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget" style="background: #fff;">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">SALT服务配置</span>
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
                <span class="widget-caption themesecondary">操作信息</span>
            </div>
            <div class="box-content" style="height:350px;padding:0px;">
            <div class="modal-body" style="width:100%;">
                        <label class="" for="inputSuccess1">对象类型</label>
                        <select class="form-control" id="ctype" name="ctype">
                            <option selected value='A'>节点模式</option>
                            <option value='B'>分组模式</option>
                            <option value='C'>SSH模式</option>
                        </select>
            </div>
            <div class="modal-body" style="width:100%">
                  <label class="" for="inputSuccess1">操作对象</label>
                  <select type="text" class="selectpicker show-tick form-control" multiple id="nodes" name="nodes" data-live-search="true" data-live-search-placeholder="搜索节点">
                          %for name in nodeslist:
                               <option value='{{name.get('nodeid')}}'>{{name.get('nodeinfo')}}</option>
                          %end
                  </select>
                  <select type="text" class="selectpicker show-tick form-control" id="grpnodes" name="grpnodes" data-live-search="true" data-live-search-placeholder="搜索分组">
                          %for name in grpnodeslist:
                               <option value='grp_{{name.get('id')}}'>{{name.get('grpname')}}</option>
                          %end
                  </select>
                  <select type="text" class="selectpicker show-tick form-control" multiple id="sshhost" name="sshhost" data-live-search="true" data-live-search-placeholder="搜索SSH主机">
                          %for name in sshconnlist:
                               <option value='{{name.get('hostaddr')}}'>{{name.get('sshinfo')}}</option>
                          %end
                  </select>
            </div>
            <div class="modal-body" style="width:100%">
                  <label class="" for="inputSuccess1">指令描述</label>
                  <textarea id="command" name="command" style="height:25px;width:100%;resize:vertical;font-family:sans-serif;" ></textarea>
            </div>
            <div class="modal-body" style="width:100%">
                        <span style="color:#666666;" id="signc">备注: 指令描述中不允许出现交互指令或无法返回的指令,否则无法出现结果.(超时时间120s)</span>
            </div>
            <div class="modal-body">
                    <div class="" style="padding-top: 3px;padding-bottom:3px;">
                        <button type="submit" style="float:left;" class="btn btn-primary">执行</button>
                    </div>
            </div>
          </div></div></div>
          <!--right-->
          <div class="box col-md-6" style="padding-right:0px;">
            <div class="box-inner widget" style="background: #fff;">
            <div class="box-header well" data-original-title>
                <i class="glyphicon glyphicon-list-alt widget-icon"></i>
                <span class="widget-caption themesecondary">运行结果</span>
            </div>
            <div class="box-content" style="height:350px;padding:0px;">
             <div class="modal-body" style="width:100%">
                  <textarea id="runresult" name="runresult" 
                  %if runresult == '' :
                      style="width:100%;height:330px;resize:none" 
                  %else:
                      style="width:100%;height:330px;background-color:#000000;color:#33ff33;resize:none;font-family:sans-serif;" 
                  %end
                  readonly >{{runresult}}</textarea>
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
<script language="JavaScript" type="text/javascript">
$(function() {
  $("#nodes").selectpicker({noneSelectedText:'请选择节点'}); //修改默认显示值
  $("#grpnodes").selectpicker({noneSelectedText:'请选择分组'}); //修改默认显示值
  $("#sshhost").selectpicker({noneSelectedText:'请选择主机'}); //修改默认显示值
  $('#ctype').click(function() {
    if (this.value == 'A') {
        $('#nodes').selectpicker('show');
        $('#grpnodes').selectpicker('hide');
        $('#sshhost').selectpicker('hide');
    }else if(this.value == 'B'){
        $('#nodes').selectpicker('hide');
        $('#grpnodes').selectpicker('show');
        $('#sshhost').selectpicker('hide');
    }else{
        $('#nodes').selectpicker('hide');
        $('#grpnodes').selectpicker('hide');
        $('#sshhost').selectpicker('show');
    }
  });
  $('#ctype').click();
});
</script>
