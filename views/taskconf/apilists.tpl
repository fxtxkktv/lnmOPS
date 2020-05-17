%rebase base position='API管理',managetopli="opsconf"

<link rel="stylesheet" href="/assets/css/bootstrap-select.min.css">

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">API管理(主要提供WebService接口服务)</span>
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
                            <a id="addapis" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-cog"></i>新增API
                            </a>
                            <a id="changeapis" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改API
                            </a>
                            %if msg.get('message'):
                      		    <span style="color:{{msg.get('color','')}};font-weight:bold;">&emsp;{{msg.get('message','')}}</span>
                    	    %end
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
           <span class="widget-caption themeprimary" id="modalTitle">API信息</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label"  for="inputSuccess1">API名称:</label>
                  <input type="text" class="form-control" id="api_name" name="api_name" require>
               </div>
                <div class="form-group">
                 <label class="control-label"  for="inputSuccess1">API版本:</label>
                 <input type="text" class="form-control" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" id="api_version" name="api_version" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">API说明:</label>
                  <input type="text" class="form-control" id="api_desc" name="api_desc" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">API安全地址:(空表示不限制)</label>
                  <textarea type="text" class="" style="height:25px;width:100%;line-height:1.5;resize:vertical;" onkeyup="this.value=this.value.replace(/[^\d.,/]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d.,/]/g,'')" id="api_safe" name="api_safe" ></textarea>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">API参数定义:</label>
                  <textarea id="api_options" name="api_options" style="height:25px;width:100%;line-height:1.5;resize:vertical;" onkeyup="this.value=this.value.replace(/[^a-zA-Z,_]/g,'')" ></textarea>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">主机连接模式: </label>
                  <select class="form-control" id="api_type" name="api_type" style="width:100%;">
                        <option 
                        value='1'>本机模式
                        </option>
                        <option 
                        value='2'>SALT SSH模式
                        </option>
                  </select>
               </div>
               <div class="form-group" id="sshzone">
                  <label class="control-label" for="inputSuccess1">SSH主机: </label>
                  <select type="text" class="selectpicker show-tick form-control" id="api_host" name="api_host" data-live-search="true" data-live-search-placeholder="搜索SSH主机">
                          %for name in sshconnlist:
                               <option value='{{name.get('id')}}'>{{name.get('sshinfo')}}</option>
                          %end
                  </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">API脚本路径:</label>
                  <textarea id="api_script_path" name="api_script_path" style="height:25px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
               </div>
        	   <div class="form-group">
                  <input type="hidden" id="hidInput" value="">
                  <button type="button" id="subBtn" class="btn btn-primary  btn-sm">提交</button>
                  <button type="button" id="Closebtn" class="btn btn-warning btn-sm" data-dismiss="modal">关闭</button> 
	           </div>
             </form>
            </div>
         </div>
      </div>
   </div>
</div>

<script src="/assets/js/bootstrap-select.min.js"></script>

<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */
    var editId;        //定义全局操作数据变量
	var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/getapilist',
          contentType: "application/json",
          datatype: "json",
          cache: false,
          checkboxHeader: true,
          striped: true,
          pagination: true,
          pageSize: 15,
          pageList: [10,20,50],
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
              field: 'api_name',
              title: 'API名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'api_version',
              title: 'API版本',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'api_desc',
              title: 'API说明',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false
          },{
              field: 'api_options',
              title: 'API参数',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'api_safe',
              title: 'API安全',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'api_type',
              title: 'API模式',
              align: 'center',
              valign: 'middle',
              sortable: false,
              formatter: function(value,row,index){
              if( value == '1' ){
                        return '本机模式';
                } else { return 'SSH模式';
                }
            }
          },{
              field: 'hostaddr',
              title: 'API主机',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'api_script_path',
              title: '脚本路径',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
	      field: '',
              title: '操作',
              align: 'center',
              valign: 'middle',
              width:220,
              formatter:getinfo
          }]
      });

    function getinfo(value,row,index){
        eval('rowobj='+JSON.stringify(row));
        //定义编辑按钮样式，只有管理员或自己编辑的任务才有权编辑
        if((rowobj['fname'] != '') && ({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid'])){
            var style_edit = '<a href="/wsapi/appid='+rowobj['id']+'&opts1=111&opts2=222" target="_bank" class="btn-sm btn-info" >';
        }else{
            var style_edit = '<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delapirecords/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_edit,
                '<i class="fa fa-edit"> API演示</i>',
            '</a>', 

           style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }


    /**
    *添加弹出框
    */
	$('#addapis').click(function(){
        $('#modalTitle').html('新增API');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changeapis').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changetaskgrp').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changetaskgrp').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#api_name').val(result[0]['api_name']);
                $('#api_desc').val(result[0]['api_desc']);
                $('#api_version').val(result[0]['api_version']);
                $('#api_safe').val(result[0]['api_safe']);
                $('#api_options').val(result[0]['api_options']);
                $('#api_type').val(result[0]['api_type']);
                var arr = result[0]['api_host'];
                $('#api_host').selectpicker('val',arr); //处理api_host选择默认值
                $('#api_script_path').val(result[0]['api_script_path']);
                $('#api_type').click();
                $('#modalTitle').html('API更新');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                document.getElementById("api_name").readOnly=true;
                editId = result[0]['id'];
				isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var api_name = $('#api_name').val();
           var api_desc = $('#api_desc').val();
           var api_version = $('#api_version').val(); 
           var api_safe = $('#api_safe').val();
           var api_options = $('#api_options').val();
           var api_type = $('#api_type').val();
           var api_host = $('#api_host').val();
           var api_script_path = $('#api_script_path').val();

           var postUrl;
           if(isEdit==1){
                postUrl = "/changeapis/"+editId;           //修改路径
           }else{
                postUrl = "/addapis";          //添加路径
           }
           
           //ajax方式
           var fd = new FormData();
           fd.append('api_name', api_name);
           fd.append('api_desc', api_desc);
           fd.append('api_version', api_version);
           fd.append('api_safe', api_safe);
           fd.append('api_options', api_options);
           fd.append('api_type', api_type);
           fd.append('api_host', api_host);
           fd.append('api_script_path', api_script_path);
           $.ajax({
            type: 'POST',
            url: postUrl,
            data: fd,
            processData: false,
            contentType: false
            }).done(function(data) {
                if(data==0){
                    $('#modalForm')[0].reset();
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else{
                      message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            });
       });
})

$(function() {
  $("#sshhost").selectpicker({noneSelectedText:'请选择SSH主机'}); //修改默认显示值
  $('#api_type').click(function() {
    if (this.value == '1') {
        $('#sshzone').hide();
    } else {
        $('#sshzone').show();
        //$('#api_host').selectpicker('show');
    }
  });
  $('#api_type').click();
});


</script>
