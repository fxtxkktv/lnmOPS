%rebase base position='分组设置',managetopli="opsconf"

<link rel="stylesheet" href="/assets/css/bootstrap-select.min.css">

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">分组设置</span>
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
                    <div class="tickets-container">
                        <div class="table-toolbar" style="float:left">
                            <a id="addtask" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增任务
                            </a>
                            <a id="changetask" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改任务
                            </a>
                            <a id="downloadtasklist" href="/downloadtasklist" class="btn btn-darkorange">
                                <i class="btn-label fa fa-download"></i>导出任务
                            </a>
                            &nbsp;
                            <div class="btn-group" style="float:right;">
                              <button class="btn btn-success dropdown-toggle" style="min-width:105px;margin:0 auto; float:right ;" data-toggle="dropdown" type="button">
                                <i class="btn-label fa fa-list-ul"></i>&nbsp;全部分组
                              </button>
                              <ul class="dropdown-menu" style="min-width:105px;margin:0 auto;">
                                <li><a class="btn btn-success" href="/taskconf/alllist">全部分组</a></li>
                                %for tasklist in taskgrplist :
                                     <li><a class="btn btn-success" href="/taskconf/{{tasklist.get('id','')}}">{{tasklist.get('grpname','')}}</a></li>
                                %end
                              </ul>
                            </div>
                        </div>
                       <table id="myLoadTable" class="table table-bordered table-hover"></table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="myModal" tabindex="-1" role="dialog"  aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" >
      <div class="modal-content" id="contentDiv">
         <div class="widget-header bordered-bottom bordered-blue ">
           <i class="widget-icon fa fa-pencil themeprimary"></i>
           <span class="widget-caption themeprimary" id="modalTitle">新增任务计划</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">任务名称：</label>
                  <input type="text" class="form-control" id="taskname" name="taskname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">任务说明：</label>
                  <textarea id="taskdesc" name="taskdesc" style="height:50px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
               </div>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">时间表达式：<a href="/cronhelp">(查看帮助)</a></label>
                  <input type="text" class="form-control" id="timedesc" name="timedesc" placeholder="*/10  *  *  *  *  *" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">主机连接模式: </label>
                  <select class="form-control" id="api_type" name="api_type" style="width:100%;">
                        <option 
                        value='0'>SALT 节点模式
                        </option>
                        <option 
                        value='1'>SALT 分组模式
                        </option>
                        <option 
                        value='2'>SALT SSH模式
                        </option>
                  </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">操作主机对象: </label>
                  <select type="text" class="selectpicker show-tick form-control" multiple id="nodes" name="nodes" data-live-search="true" data-live-search-placeholder="搜索节点">
                          %for name in nodeslist:
                               <option value='{{name.get('id')}}'>{{name.get('nodeinfo')}}</option>
                          %end
                  </select>
                  <select type="text" class="selectpicker show-tick form-control" id="grpnodes" name="grpnodes" data-live-search="true" data-live-search-placeholder="搜索分组">
                          %for name in grpnodeslist:
                               <option value='{{name.get('id')}}'>{{name.get('grpname')}}</option>
                          %end
                  </select>
                  <select type="text" class="selectpicker show-tick form-control" multiple id="sshhost" name="sshhost" data-live-search="true" data-live-search-placeholder="搜索SSH主机">
                          %for name in sshconnlist:
                               <option value='{{name.get('id')}}'>{{name.get('sshinfo')}}</option>
                          %end
                  </select>
               </div>
		       <div class="form-group">
                  <label class="control-label" for="inputSuccess1">执行内容：</label>
                  <textarea id="runobject" name="runobject" style="height:50px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
               </div>
        	   <div class="form-group">
                  <input type="hidden" id="hidInput" value="">
                  <button type="button" id="subBtn" class="btn btn-primary  btn-sm">提交</button>
                  <button type="button" class="btn btn-warning btn-sm" data-dismiss="modal">关闭</button> 
	           </div>
             </form>
            </div>
         </div>
      </div>
   </div>
</div>
<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */
    var editId;        //定义全局操作数据变量
	var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/gettaskinfo/{{grpid}}',
          contentType: "application/json",
          datatype: "json",
          cache: false,
          checkboxHeader: true,
          striped: true,
          pagination: true,
          pageSize: 15,
          pageList: [10,20,50],
          //height: 500,
          search: true,
          showColumns: true,
          showRefresh: true,
          minimumCountColumns: 2,
          clickToSelect: true,
          smartDisplay: true,
          //sidePagination : "server",
          sortOrder: 'asc',
          sortName: 'id',
          columns: [{
              field: 'bianhao',
              title: 'checkbox',      
              checkbox: true,
          },{
              field: 'xid',
              title: '编号',
              align: 'center',
              valign: 'middle',
              width:25,
              //sortable: false,
              formatter:function(value,row,index){
                return index+1;
              }
          },{
              field: 'taskname',
              title: '任务名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'taskdesc',
              title: '任务描述',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false
          },{ 
              field: 'timedesc',
              title: '时间表达式',
              align: 'center',
              valign: 'middle',
              width: 150,
              sortable: false
          },{
              field: 'api_type',
              title: 'API模式',
              align: 'center',
              valign: 'middle',
              sortable: false,
              width: 80,
              formatter: function(value,row,index){
              if( value == '0' ){
                        return '节点模式';
                } else if ( value == '1' ){  return '分组模式';
                } else { return 'SSH模式';
                }
            }
          },{ 
              field: 'ntime',
              title: '下次运行时间',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'objdesc',
              title: '操作对象',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'runobject',
              title: '执行语句',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false,
          },{
              field: 'status',
              title: '任务状态',
              align: 'center',
              valign: 'middle',
              sortable: false,
              width:25,
              formatter: function(value,row,index){
                if( value == '1' ){
                        return '<img  src="/assets/img/run_1.gif" class="img-rounded" >';
                }else{  return '<img  src="/assets/img/run_0.gif" class="img-rounded" >';
                }
            }
          },{
	      field: '',
              title: '操作',
              align: 'center',
              valign: 'middle',
              //width: 220,
              formatter:getinfo
          }]
    });
    
    function getinfo(value,row,index){
        eval('rowobj='+JSON.stringify(row));
        //定义显示启用停用按钮，只有管理员或自己编辑的任务才有权操作
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            if(rowobj['status'] == '1'){
               var style_action = '<a href="/chgstatus/taskmgrdisable/'+rowobj['id']+'" class="btn-sm btn-success" >';
            }else{
               var style_action = '<a href="/chgstatus/taskmgractive/'+rowobj['id']+'" class="btn-sm btn-danger active" >';
            }
        }else{
            var style_action = '<a class="btn-sm btn-info" disabled>';
        }
        //定义显示执行按钮，只有管理员或自己编辑的任务才有权操作
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
           var style_run = '&nbsp;<a href="/runtask/'+rowobj['id']+'" class="btn-sm btn-info" onClick="return confirm(&quot;该功能建议仅用于任务测试，确定要立即执行该任务吗?&quot;)" >';
        }else{
            var style_run = '&nbsp;<a class="btn-sm btn-info" disabled>';
        }
        //定义显示结果按钮样式，只有管理员或自己编辑的任务才有权查看
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_logs = '&nbsp;<a href="/tasklogs/'+rowobj['id']+'" class="btn-sm btn-info" >';
        }else{
            var style_logs = '&nbsp;<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/deltask/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_action,
                '<i class="fa fa-power-off"> 开关</i>',
            '</a>', 

            style_run,
                '<i class="fa fa-spinner"> 执行</i>',
            '</a>', 

            style_logs,
                '<i class="fa fa-print"> 日志</i>',
            '</a>', 

           style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }



    /**
    *添加弹出框
    */
	$('#addtask').click(function(){
        $('#modalTitle').html('新增计划任务');
        $('#api_type').click();
        $('#nodes').selectpicker('val',['noneSelectedText']); //清除默认值
        $('#grpnodes').selectpicker('val',['noneSelectedText']); //清除默认值
        $('#sshhost').selectpicker('val',['noneSelectedText']); //清除默认值
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changetask').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changetask').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changetask').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changetask').popover('hide');
                $('#taskname').val(result[0]['taskname']);
                $('#taskdesc').val(result[0]['taskdesc']);
                $('#timedesc').val(result[0]['timedesc']);
                $('#api_type').val(result[0]['api_type']);
                $('#api_type').click();
                if(result[0]['api_type']==0){
                    var arr = result[0]['api_obj'].split(',');
                    $('#nodes').selectpicker('val',arr); //处理nodes选择默认值
                }else if(result[0]['api_type']==1){
                    var arr = result[0]['api_obj'];
                    $('#grpnodes').selectpicker('val',arr); //处理grpnodes选择默认值
                }else{
                    var arr = result[0]['api_obj'].split(',');
                    $('#sshhost').selectpicker('val',arr); //处理sshhost选择默认值
                }
                $('#runobject').val(result[0]['runobject']);
                $('#modalTitle').html('任务更新');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                editId = result[0]['id'];
				isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var taskname = $('#taskname').val();
           var taskdesc = $('#taskdesc').val();
           var timedesc = $('#timedesc').val(); 
           var api_type = $('#api_type').val();
           if(api_type==0){
              var api_obj = $('#nodes').val();
           }else if(api_type==1){
              var api_obj = $('#grpnodes').val();
           }else{
              var api_obj = $('#sshhost').val();
           }
           var runobject = $('#runobject').val(); 
           var postUrl;
           if(isEdit==1){
                postUrl = "/changetask/"+editId;           //修改路径
           }else{
                postUrl = "/addtask";          //添加路径
           }

           $.post(postUrl,{taskname:taskname,taskdesc:taskdesc,timedesc:timedesc,api_type:api_type,api_obj:api_obj,runobject:runobject},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                    message.message_show(200,200,'失败','操作失败');
                  }else if(data==-2){
                    alert('时间表达式不合法');
                    //message.message_show(200,200,'失败','时间表达式不合法');
                  }else{
                    message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            },'html');
       });

});
</script>

<script src="/assets/js/bootstrap-select.min.js"></script>
<script language="JavaScript" type="text/javascript">
$(function() {
  $("#nodes").selectpicker({noneSelectedText:'请选择节点'}); //修改默认显示值
  $("#grpnodes").selectpicker({noneSelectedText:'请选择分组'}); //修改默认显示值
  $("#sshhost").selectpicker({noneSelectedText:'请选择SSH主机'}); //修改默认显示值
  $('#api_type').click(function() {
    if (this.value == '0') {
        $('#nodes').selectpicker('show');
        $('#grpnodes').selectpicker('hide');
        $('#sshhost').selectpicker('hide');
    } else if (this.value == '1'){
        $('#nodes').selectpicker('hide');
        $('#grpnodes').selectpicker('show');
        $('#sshhost').selectpicker('hide');
    } else {
        $('#nodes').selectpicker('hide');
        $('#grpnodes').selectpicker('hide');
        $('#sshhost').selectpicker('show');
    }
  });
  $('#api_type').click();
});

$(function () {
        setInterval(function () {
        var opt = {silent: true} // 定义参数以静默方式刷新
        $('#myLoadTable').bootstrapTable('refresh',opt);
        }, 10000); //30秒自动刷新
    })

</script>
