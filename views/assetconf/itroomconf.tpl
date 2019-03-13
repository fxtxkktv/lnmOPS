%rebase base position='机房管理',managetopli="assetconf"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">机房列表</span>
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
                            <a id="addroom" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增机房
                            </a>
                            <a id="changeroom" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>机房更新
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
           <span class="widget-caption themeprimary" id="modalTitle">新增机房</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">机房名称：</label>
                  <input type="text" class="form-control" id="roomname" name="roomname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">机房位置：</label>
                  <input type="text" class="form-control" id="roomaddr" name="roomaddr" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">机房面积：</label>
                  <input type="text" class="form-control" id="roomsize" name="roomsize" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">启用日期：</label>
                  <input type="date" class="form-control" id="startdate" name="startdate" require>
               </div>
		       <div class="form-group">
                  <label class="control-label" for="inputSuccess1">备注信息：</label>
                  <textarea id="comment" name="comment" style="height:70px;width:100%;resize:vertical;" ></textarea>
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
          url: '/api/getroominfo',
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
              field: 'roomname',
              title: '机房名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'roomaddr',
              title: '机房位置',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'roomsize',
              title: '机房面积(m<sup>2</sup>)',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'startdate',
              title: '启用日期',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'hostnum',
              title: '主机数量',
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
            var style_del = '&nbsp;<a href="/delroom/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
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

	$('#addroom').click(function(){
        $('#modalTitle').html('新增机房');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changeroom').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changeroom').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changeroom').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changeroom').popover('hide');
                $('#roomname').val(result[0]['roomname']);
                $('#roomaddr').val(result[0]['roomaddr']);
                $('#roomsize').val(result[0]['roomsize']);
                $('#comment').val(result[0]['comment']);
                $('#startdate').val(result[0]['startdate']);
                $('#modalTitle').html('机房更新');     //头部修改
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
           var roomname = $('#roomname').val();
           var roomaddr = $('#roomaddr').val();
           var roomsize = $('#roomsize').val(); 
           var comment = $('#comment').val(); 
           var startdate = $('#startdate').val(); 
           var postUrl;
           if(isEdit==1){
                postUrl = "/changeroom/"+editId;           //修改路径
           }else{
                postUrl = "/addroom";          //添加路径
           }

           $.post(postUrl,{roomname:roomname,roomaddr:roomaddr,roomsize:roomsize,comment:comment,startdate:startdate},function(data){
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
