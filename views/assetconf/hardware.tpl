%rebase base position='硬件管理',managetopli="assetconf"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">硬件列表</span>
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
                            <a id="addhdware" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增硬件
                            </a>
                            <a id="changehdware" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>数据更新
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
           <span class="widget-caption themeprimary" id="modalTitle">新增硬件</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">硬件编号：</label>
                  <input type="text" class="form-control" id="hdnumber" name="hdnumber" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">硬件名称：</label>
                  <input type="text" class="form-control" id="hdname" name="hdname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">硬件品牌：</label>
                  <input type="text" class="form-control" id="hdbrand" name="hdbrand" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">所在机房：</label>
                  <select id="roomid" style="width:100%;" name="roomid">
                    <option value=''>请选择机房</option>
                    %for name in roomlist:
                        <option 
                        %if name.get('id',''): 
                                    selected 
                        %end
                        value='{{name.get('id','')}}'>{{name.get('roomname','')}}
                        </option>
                    %end
                 </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">购买日期：</label>
                  <input type="date" class="form-control" id="hddate" name="hddate" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">供应商信息：</label>
                  <input type="text" class="form-control" id="supplier" name="supplier" require>
               </div>
		       <div class="form-group">
                  <label class="control-label" for="inputSuccess1">详细信息：</label>
                  <textarea id="comment" name="comment" style="height:120px;width:100%;line-height:1.5;resize:vertical;">CPU型号:&#13;&#10;DISK容量:&#13;&#10;内存容量:&#13;&#10;其它配置:&#13;&#10;故障联络人:</textarea>
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
          url: '/api/gethdwareinfo',
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
              field: 'hdnumber',
              title: '硬件编号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'hdname',
              title: '硬件名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'hdbrand',
              title: '硬件品牌',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'roomname',
              title: '所在机房',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'hddate',
              title: '购买日期',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'supplier',
              title: '供应商信息',
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
            var style_del = '&nbsp;<a href="/delhdware/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
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

	$('#addhdware').click(function(){
        $('#modalTitle').html('新增硬件');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changehdware').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changehdware').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changehdware').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changehdware').popover('hide');
                $('#hdnumber').val(result[0]['hdnumber']);
                $('#hdname').val(result[0]['hdname']);
                $('#hdbrand').val(result[0]['hdbrand']);
                $('#roomid').val(result[0]['roomid']);
                $('#hddate').val(result[0]['hddate']);
                $('#comment').val(result[0]['comment']);
                $('#modalTitle').html('硬件更新');     //头部修改
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
           var hdnumber = $('#hdnumber').val();
           var hdname = $('#hdname').val();
           var hdbrand = $('#hdbrand').val(); 
           var roomid = $('#roomid').val();
           var supplier = $('#supplier').val();
           var comment = $('#comment').val(); 
           var hddate = $('#hddate').val(); 
           var postUrl;
           if(isEdit==1){
                postUrl = "/changehdware/"+editId;           //修改路径
           }else{
                postUrl = "/addhdware";          //添加路径
           }

           $.post(postUrl,{hdnumber:hdnumber,hdname:hdname,hdbrand:hdbrand,roomid:roomid,supplier:supplier,comment:comment,hddate:hddate},function(data){
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
