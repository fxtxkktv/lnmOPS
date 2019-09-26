%rebase base position='SSH管理', managetopli="saltmgr"

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.12.4/css/bootstrap-select.min.css">

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">主机列表</span>
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
                            <a id="addsshconn" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增SSH主机
                            </a>
                            <a id="changesshconn" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改SSH主机
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
           <span class="widget-caption themeprimary" id="modalTitle">新增SSH主机</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">主机描述：</label>
                  <textarea id="hostdesc" name="hostdesc" style="height:50px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
               </div>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">连接地址：</label>
                  <input type="text" class="form-control" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')" id="hostaddr" name="hostaddr" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">连接端口：</label>
                  <input type="text" class="form-control" onkeyup="this.value=this.value.replace(/\D/g,'')" id="sshport" name="sshport" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">连接用户:</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.\-\/]/ig,'')" id="sshuser" name="sshuser" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">连接密码: </label>
                  <input type="password" class="form-control" id="sshpass" name="sshpass" require>
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
          url: '/api/getsshinfo',
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
              field: 'hostdesc',
              title: '主机描述',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'hostaddr',
              title: '主机地址',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'sshport',
              title: '连接端口',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'sshuser',
              title: '连接用户',
              align: 'center',
              valign: 'middle',
              width: 150,
              sortable: false
          },{
              field: 'status',
              title: '启用状态',
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
               var style_action = '<a href="/chgstatus/sshmgrdisable/'+rowobj['id']+'" class="btn-sm btn-success" >';
            }else{
               var style_action = '<a href="/chgstatus/sshmgractive/'+rowobj['id']+'" class="btn-sm btn-danger active" >';
            }
        }else{
            var style_action = '<a class="btn-sm btn-info" disabled>';
        }
        //定义显示执行按钮，只有管理员或自己编辑的任务才有权操作
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_run = '&nbsp;<a href="/keypass/'+rowobj['hostaddr']+'" class="btn-sm btn-info" >';
        }else{
            var style_run = '&nbsp;<a class="btn-sm btn-info" disabled>';
        }
        //定义webssh样式，只有管理员或自己编辑的任务才有权删除
        console.log("{{session.get('WebSSHurl',None)}}")
        if("{{session.get('WebSSHurl',None)}}" != "1" && ({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid'])){
            var style_conn = '&nbsp;<a target="_bank" href="{{session.get('WebSSHurl',None)}}/ssh/host/'+rowobj['hostaddr']+'?port='+rowobj['sshport']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定连接吗?&quot;)"> ';
        }else{
            var style_conn = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delsshconf/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_action,
                '<i class="fa fa-power-off"> 开关</i>',
            '</a>', 
            style_run,
                '<i class="fa fa-edit"> 重建密匙互信</i>',
            '</a>', 

            style_conn,
                '<i class="fa fa-edit"> SSH连接</i>',
            '</a>', 

            style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }



    /**
    *添加弹出框
    */
	$('#addsshconn').click(function(){
        $('#modalTitle').html('新增计划任务');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changesshconn').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
            var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changesshconn').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changetask').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changesshconn').popover('hide');
                $('#hostdesc').val(result[0]['hostdesc']);
                $('#hostaddr').val(result[0]['hostaddr']);
                $('#sshport').val(result[0]['sshport']);
                $('#sshuser').val(result[0]['sshuser']);
                /*$('#sshpass').val(result[0]['sshpass']);*/ //不读取密码信息，否则容易出现密码重叠加密
                $('#modalTitle').html('主机更新');     //头部修改
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
           var hostdesc = $('#hostdesc').val();
           var hostaddr = $('#hostaddr').val(); 
           var sshport = $('#sshport').val();
           var sshuser = $('#sshuser').val(); 
           var sshpass = $('#sshpass').val(); 
           var postUrl;
           if(isEdit==1){
                postUrl = "/changesshconn/"+editId;           //修改路径
           }else{
                postUrl = "/addsshconn";          //添加路径
           }

           $.post(postUrl,{hostdesc:hostdesc,hostaddr:hostaddr,sshport:sshport,sshuser:sshuser,sshpass:sshpass},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                    message.message_show(200,200,'失败','操作失败');
                  }else if(data==-2){
                    alert('无法重复添加相同的主机IP或数据异常错误');
                    //message.message_show(200,200,'失败','时间表达式不合法');
                  }else{
                    message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            },'html');
       });

})
</script>
