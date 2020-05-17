%rebase base position='分组管理',managetopli="saltmgr"

<link rel="stylesheet" href="/assets/bootstrap-select/bootstrap-select.min.css">

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">分组列表</span>
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
                            <a id="addnodegrp" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增分组
                            </a>
                            <a id="changenodegrp" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>编辑分组
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
           <span class="widget-caption themeprimary" id="modalTitle">新增分组</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">分组名称：</label>
                  <input type="text" class="form-control" id="grpname" name="grpname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">分组描述：</label>
                  <textarea id="grpdesc" name="grpdesc" style="height:60px;width:100%;line-height:1.5;resize:vertical;" ></textarea>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">关联节点: </label>
                  <select class="selectpicker show-tick form-control" multiple id="grpnodes" name="grpnodes" style="width:100%;" data-live-search="true" data-live-search-placeholder="搜索节点">
                    %for name in minionlist:
                        <option 
                        value='{{name.get('id','')}}'>{{name.get('nodeinfo','')}}
                        </option>
                    %end
                 </select>
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
          url: '/api/getnodegrpinfo',
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
              field: 'grpname',
              title: '分组名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'grpdesc',
              title: '分组描述',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'nodeid',
              title: '关联节点',
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
        /*if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_edit = '<a href="/changeroom/'+rowobj['id']+'" class="btn-sm btn-info" >';
        }else{
            var style_edit = '<a class="btn-sm btn-info" disabled>';
        }*/
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delnodegrp/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
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
    $("#grpnodes").selectpicker({noneSelectedText:'请选择节点'}); //修改默认显示值
	$('#addnodegrp').click(function(){
        $('#modalTitle').html('新增分组');
        $('#grpnodes').selectpicker('val',['noneSelectedText']); //清除默认值
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changenodegrp').popover({
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
                $('#grpname').val(result[0]['grpname']);
                $('#grpdesc').val(result[0]['grpdesc']);
                $('#modalTitle').html('分组变更');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                //console.log(result[0]['grpnodes'])
                var arr = result[0]['grpnodes'].split(',');
                //console.log(arr)
                $('#grpnodes').selectpicker('val',arr); //处理grpnodes选择默认值
                document.getElementById("grpname").readOnly=true;
                editId = result[0]['id'];
				isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var grpname = $('#grpname').val();
           var grpdesc = $('#grpdesc').val();
           var grpnodes = $('#grpnodes').val();
           var postUrl;
           if(isEdit==1){
                postUrl = "/changenodegrp/"+editId;           //修改路径
           }else{
                postUrl = "/addnodegrp";          //添加路径
           }

           $.post(postUrl,{grpname:grpname,grpdesc:grpdesc,grpnodes:grpnodes},function(data){
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

<script src="/assets/bootstrap-select/bootstrap-select.min.js"></script>
