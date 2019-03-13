%rebase base position='机房管理',managetopli="assetconf"

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
                            <a id="addhost" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增主机
                            </a>
                            <a id="changehost" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>主机修改
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
           <span class="widget-caption themeprimary" id="modalTitle">新增主机</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">主机名称：</label>
                  <input type="text" class="form-control" id="hostname" name="hostname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">网络地址：</label>
                  <input type="text" class="form-control" id="hostaddr" name="hostaddr" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" aria-describedby="inputGroupSuccess4Status" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">系统类型：</label>
                  <select id="systype" style="width:100%;" name="systype">
                    <option value=''>请选择操作系统</option>
                    <option value='windows'>Windows</option>
                    <option value='linux'>Linux</option>
                    <option value='other'>Other</option>
                  </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">关联硬件: </label>
                  <select class="selectpicker show-tick form-control" id="selecthd" name="selecthd" style="width:100%;" data-live-search="true" data-live-search-placeholder="搜索硬件">
                    %for name in hdlist:
                        <option 
                        value='{{name.get('id','')}}'>{{name.get('hdname','')}}
                        </option>
                    %end
                 </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">上线时间：</label>
                  <input type="date" class="form-control" id="hostdate" name="hostdate" require>
               </div>
		       <div class="form-group">
                  <label class="control-label" for="inputSuccess1">备注信息：</label>
                  <textarea id="comment" name="comment" style="height:60px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
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
          url: '/api/gethostinfo',
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
              field: 'hostname',
              title: '主机名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'hostaddr',
              title: '网络地址',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'systype',
              title: '系统类型',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'hdname',
              title: '关联硬件',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'hostdate',
              title: '上线时间',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'comment',
              title: '备注信息',
              align: 'center',
              valign: 'middle',
              sortable: false,
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
        /*if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_edit = '<a href="/changeroom/'+rowobj['id']+'" class="btn-sm btn-info" >';
        }else{
            var style_edit = '<a class="btn-sm btn-info" disabled>';
        }*/
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delhost/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            /*style_edit,
                '<i class="fa fa-edit"> 编辑</i>',
            '</a>', */

           style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }



    /**
    *添加弹出框
    */
    $("#selecthd").selectpicker({noneSelectedText:'请选择硬件'}); //修改默认显示值
	$('#addhost').click(function(){
        $('#modalTitle').html('新增主机');
        $('#selecthd').selectpicker('val',['noneSelectedText']); //清除默认值
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changehost').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changehost').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changehost').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changehdware').popover('hide');
                $('#hostname').val(result[0]['hostname']);
                $('#hostaddr').val(result[0]['hostaddr']);
                $('#systype').val(result[0]['systype']);
                $('#hostdate').val(result[0]['hostdate']);
                $('#comment').val(result[0]['comment']);
                $('#modalTitle').html('主机更新');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                $('#selecthd').selectpicker('val',(result[0]['selecthd'])); //处理selecthd选择默认值
                editId = result[0]['id'];
				isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var hostname = $('#hostname').val();
           var hostaddr = $('#hostaddr').val();
           var systype = $('#systype').val(); 
           var selecthd = $('#selecthd').val();
           var hostdate = $('#hostdate').val();
           var comment = $('#comment').val(); 
           var postUrl;
           if(isEdit==1){
                postUrl = "/changehost/"+editId;           //修改路径
           }else{
                postUrl = "/addhost";          //添加路径
           }

           $.post(postUrl,{hostname:hostname,hostaddr:hostaddr,systype:systype,selecthd:selecthd,hostdate:hostdate,comment:comment},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else{
                        message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            },'html');
       });

})
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.12.4/js/bootstrap-select.min.js"></script>
