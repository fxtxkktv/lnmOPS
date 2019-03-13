%rebase base position='软件管理',managetopli="assetconf"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">软件列表</span>
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
                            <a id="addsoftware" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>新增软件授权
                            </a>
                            <a id="changesoftware" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改软件信息
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
           <span class="widget-caption themeprimary" id="modalTitle">新增软件信息</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm" enctype="multipart/form-data" >
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">软件编号：</label>
                  <input type="text" class="form-control" id="softnumber" name="softnumber" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">软件名称：</label>
                  <input type="text" class="form-control" id="softname" name="softname" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">软件版本号：</label>
                  <input type="text" class="form-control" id="softversion" name="softversion" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">购买日期：</label>
                  <input type="date" class="form-control" id="softdate" name="softdate" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">供应商信息：</label>
                  <input type="text" class="form-control" id="supplier" name="supplier" require>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">授权相关文件(空表示不更新)：</label>
                        <div class="form-control">
                             <input type="file" accept=".txt,.zip,.rar,.xls,.xlsx,.doc,.docx,.pdf" id="upload" name="upload"/>
                        </div>
               </div>
		       <div class="form-group">
                  <label class="control-label" for="inputSuccess1">详细信息：</label>
                  <textarea id="comment" name="comment" style="height:80px;width:100%;line-height:1.5;resize:vertical;">技术支持:&#13;&#10;相关账户:&#13;&#10;登录链接:</textarea>
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
          url: '/api/getsoftwareinfo',
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
              field: 'softnumber',
              title: '软件编号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'softname',
              title: '软件名称',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'softversion',
              title: '软件版本号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'supplier',
              title: '供应商信息',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'softdate',
              title: '购买日期',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'filename',
              title: '关联文件名',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'comment',
              title: '备注信息',
              align: 'center',
              valign: 'middle',
              visible: false,
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
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_edit = '<a href="/downsoftfile/'+rowobj['id']+'" class="btn-sm btn-info" >';
        }else{
            var style_edit = '<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delsoftware/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_edit,
                '<i class="fa fa-edit"> 下载关联文件</i>',
            '</a>', 

           style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }



    /**
    *添加弹出框
    */

	$('#addsoftware').click(function(){
        $('#modalTitle').html('新增软件信息');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changesoftware').popover({
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
                $('#changesoftware').popover('hide');
                $('#softnumber').val(result[0]['softnumber']);
                $('#softname').val(result[0]['softname']);
                $('#softversion').val(result[0]['softversion']);
                $('#softdate').val(result[0]['softdate']);
                $('#supplier').val(result[0]['supplier']);
                $('#comment').val(result[0]['comment']);
                $('#modalTitle').html('软件更新');     //头部修改
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
           var softnumber = $('#softnumber').val();
           var softname = $('#softname').val();
           var softversion = $('#softversion').val(); 
           var supplier = $('#supplier').val();
           var comment = $('#comment').val(); 
           var softdate = $('#softdate').val(); 
           var ufile = document.getElementById("upload").files[0];
           //console.log(ufileobj);
           //console.log(document.getElementById('upload').value);
           
           try {
               var fname = ufile.name;
               var fsize = ufile.size;
               var fdesc = window.readbinstr
               var ftype = (fname.substr(fname.lastIndexOf("."))).toLowerCase();
               if ( fsize > 10485760 ){
                  alert("文件不应该大于10M，请压缩后重新上传");
                  return false;
               }
               /*if( ftype != ".txt" && ftype != ".rar" && ftype != ".zip" && ftype != ".doc" && ftype != ".docx" && ftype != ".xls" && ftype != ".xlsx" && ftype != ".pdf" ){
                alert("您上传文件类型不符合(.txt|.rar|.zip|.pdf|.doc(x)|.xls(x))");
                return false;
              }*/
           } catch (e){
               var fname = '';
               var fsize = '';
               var ftype = '';
               var fdesc = '';
           }

           var postUrl;
           if(isEdit==1){
                postUrl = "/changesoftware/"+editId;           //修改路径
           }else{
                postUrl = "/addsoftware";          //添加路径
           }
           $.post(postUrl,{softnumber:softnumber,softname:softname,softversion:softversion,supplier:supplier,comment:comment,softdate:softdate,fname:fname,fdesc:fdesc},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    // 成功后，请掉文件缓存
                    $("#upload").replaceWith('<input type="file" id="upload" name="upload" accept="*.txt,.zip,.rar,.xls,.xlsx,.doc,.docx,.pdf" />');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else{
                        message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            },'html');
       });

})


window.onload=function(){
       var f = document.getElementById("upload");  
              
       //this.files即获取input中上传的file对象 是个数组   
       f.onchange = function(){  
         //获取文件对象  
         var file = this.files[0];  
         //使用fileReader对文件对象进行操作  
         var reader = new FileReader();  
         //将文件读取为arrayBuffer  
         //reader.readAsArrayBuffer(file);  
         //reader.onload = function(){  
         //  console.log(reader.result);  
         //  window.readbinstr = reader.result ;  
         //}  
                  
        reader.readAsBinaryString(file);  
        reader.onload = function(){  
            console.log(reader.result);
            window.readbinstr = reader.result ;  
        }  
                  
       //用于图片显示不需要传入后台，reader.result的结果是base64编码数据，直接放入img的src中即可  
       //reader.readAsDataURL(file);  
       //reader.onload = function(){  
       //    console.log(reader.result);  
       //}  
       //}  
               
    }  
}
</script>
