%rebase base position='故障记录',managetopli="assetconf"

<link rel="stylesheet" href="/assets/bootstrap-select/bootstrap-select.min.css">
<link href="/assets/css/charisma-app.css" rel="stylesheet" type="text/css" />
<script src="/assets/js/uploadFile.js"></script>

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">故障记录</span>
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
                            <a id="addfaultrecords" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus-square-o"></i>新增故障记录
                            </a>
                            <a id="changefaultrecords" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改记录信息
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
           <span class="widget-caption themeprimary" id="modalTitle">新增故障信息</span>
        </div>

         <div class="modal-body">
            <div>
            <form id="modalForm" enctype="multipart/form-data" >
               <div class="form-group">
                  <label class="control-label" style="padding-top:5px;width:10%;height:30px;" for="inputSuccess1">故障类型:</label>
                  <select id="fttype" style="width:38.5%;height:30px;" name="fttype">
                    <option value='Network'>网络故障</option>
                    <option value='Hardware'>硬件故障</option>
                    <option value='System'>系统故障</option>
                    <option value='Other'>其它故障</option>
                  </select>
                  <label class="control-label" style="width:10%;height:30px;padding-top:5px;" for="inputSuccess1">故障等级:</label>
                  <select id="ftlevel" style="width:38.5%;height:30px;" name="ftlevel">
                    <option value='I'>轻微</option>
                    <option value='II'>中等</option>
                    <option value='III'>严重</option>
                  </select>
               </div>
               <div class="form-group">
                  <label class="control-label" style="width:10%;height:30px;padding-top:5px;" for="inputSuccess1">发生日期:</label>
                  <input type="date" style="width:38.5%;height:30px;" id="startdate" name="startdate" require>
                  <label class="control-label" style="width:10%;height:30px;padding-top:5px;" for="inputSuccess1">解决日期:</label>
                  <input type="date" style="width:38.5%;height:30px;" id="stopdate" name="stopdate" require>
               </div>
               <div class="form-group" id="ftobject">
                    <label class="control-label" style="width:10%;height:30px;padding-top:5px;" for="inputSuccess1">故障对象:</label>
                    <select type="text" class="selectpicker show-tick form-control" multiple style="height:30px;" id="ftobjectA" name="ftobjectA" data-live-search="true" data-live-search-placeholder="搜索故障对象">
                            %for name in hardlist:
                                <option value='{{name.get('id')}}'>{{name.get('hdname')}}</option>
                            %end
                    </select>
                    <select type="text" class="selectpicker show-tick form-control" multiple style="height:30px;" id="ftobjectB" name="ftobjectB" data-live-search="true" data-live-search-placeholder="搜索故障对象">
                            %for name in hostlist:
                                <option value='{{name.get('id')}}'>{{name.get('hostname')}}</option>
                            %end
                    </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">处理过程:</label>
                  <textarea id="comment" name="comment" style="height:90px;width:100%;line-height:1.5;resize:vertical;">故障描述:&#13;&#10;应急措施:&#13;&#10;解决方案:&#13;&#10;记录人员:</textarea>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">记录相关文件(空表示不更新):</label>
                        <div class="form-control">
                          <div class="upload-block" id="selectUploadFile">
                          <form id="fileForm" class="" enctype="multipart/form-data" method="post" name="fileinfo">
                          <input type="file" accept=".jpg,.bmp,.txt,.zip,.rar,.xls,.xlsx,.doc,.docx,.pdf" id="upload" name="upload" draggable="true"/>
                          <input type="hidden" name="filepath" value="" />
                          <div id="progress" class="progress"></div>
                          </form>
                          </div>
                        </div>
               </div>
        	   <div class="form-group">
                  <input type="hidden" id="hidInput" value="">
                  <button type="button" id="subBtn" class="btn btn-primary  btn-sm">提交</button>
                  <button type="button" class="btn btn-warning btn-sm" id="Closebtn" data-dismiss="modal">关闭</button> 
	           </div>
             </form>
            </div>
         </div>
      </div>
   </div>
</div>
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script>
<script src="/assets/bootstrap-select/bootstrap-select.min.js"></script>
<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */
    var editId;        //定义全局操作数据变量
	var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/getftinfo',
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
              field: 'ftrank',
              title: '故障编号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'fttype',
              title: '故障类型',
              align: 'center',
              valign: 'middle',
              sortable: false,
              formatter: function(value,row,index){
              if( value == 'Hardware' ){ return '硬件故障' ;
              } else if ( value == 'System' ){ return '系统故障' ;
              } else if ( value == 'Network' ){ return '网络故障' ;
              } else { return '其它故障' ; }
              }
          },{ 
              field: 'ftlevel',
              title: '故障等级',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'ftobjectvalue',
              title: '故障对象',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'startdate',
              title: '发生日期',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'stopdate',
              title: '解决日期',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false,
          },{
              field: 'comment',
              title: '处理过程',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false,
          },{
              field: 'fname',
              title: '记录文件',
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
        if((rowobj['fname'] != '') && ({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid'])){
            var style_edit = '<a href="/downfile/ftrecords/'+rowobj['ftrank']+'" class="btn-sm btn-info" >';
        }else{
            var style_edit = '<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delftrecords/'+rowobj['ftrank']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
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

    /*点击按钮*/
    $('#fttype').click(function() {
    $("#ftobjectA").selectpicker({noneSelectedText:'搜索故障对象'}); //修改默认显示值
    $("#ftobjectB").selectpicker({noneSelectedText:'搜索故障对象'}); //修改默认显示值
    if (this.value == "Hardware") {
        $('#ftobject').show();
        $('#ftobjectA').selectpicker('show');
        $('#ftobjectB').selectpicker('hide');
    } else if (this.value == "System"){
        $('#ftobject').show();
        $('#ftobjectA').selectpicker('hide');
        $('#ftobjectB').selectpicker('show');
    } else {
      $('#ftobject').hide();
      $('#ftobjectA').selectpicker('hide');
      $('#ftobjectB').selectpicker('hide');
    }
    });
    $('#fttype').click();

    /**
    *添加弹出框
    */

	$('#addfaultrecords').click(function(){
        $('#progress').hide(); //重置进度条显示
        $('#ftobjectA').selectpicker('val','');
        $('#ftobjectB').selectpicker('val','');
        $('#modalTitle').html('新增故障记录');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changefaultrecords').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changefaultrecords').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changefaultrecords').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#progress').hide(); //重置进度条显示
                $('#changefaultrecords').popover('hide');
                $('#fttype').val(result[0]['fttype']);
                $('#ftlevel').val(result[0]['ftlevel']);
                $('#startdate').val(result[0]['startdate']);
                $('#stopdate').val(result[0]['stopdate']);
                $('#fttype').click();
                if (result[0]['fttype']="Hardware"){
                   try {
                   var arr = result[0]['ftobject'].split(',');
                   $('#ftobjectA').selectpicker('val',arr); //处理ftobjectA选择默认值
                   } catch(err) { $('#ftobjectA').selectpicker('val',''); };
                } else if (result[0]['fttype']="System"){
                   try {
                   var arr = result[0]['ftobject'].split(',');
                   $('#ftobjectB').selectpicker('val',arr); //处理ftobjectB选择默认值
                   } catch(err) { $('#ftobjectB').selectpicker('val',''); };
                }
                $('#comment').val(result[0]['comment']);
                $('#modalTitle').html('记录更新');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                editId = result[0]['ftrank'];
				isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var fttype = $('#fttype').val();
           var ftlevel = $('#ftlevel').val();
           var startdate = $('#startdate').val(); 
           var stopdate = $('#stopdate').val();
           //console.log(fttype)
           if (fttype == "Hardware"){
              var ftobject = $('#ftobjectA').val();
           } else if (fttype == "System"){
              var ftobject = $('#ftobjectB').val();
           } else {
              var ftobject = "";
           }
           var comment = $('#comment').val(); 
           var ufile = document.getElementById("upload").files[0];
           
           try {
               var fname = ufile.name;
               var fsize = ufile.size;
               var fdesc = new Blob([window.fileString]);
               var ftype = (fname.substr(fname.lastIndexOf("."))).toLowerCase();
               if ( fsize > 10485760 ){
                  alert("文件不应该大于10M，请压缩后重新上传");
                  return false;
               }
               if( ftype != ".txt" && ftype != ".rar" && ftype != ".zip" && ftype != ".doc" && ftype != ".docx" && ftype != ".xls" && ftype != ".xlsx" && ftype != ".pdf" && ftype != ".jpg" && ftype != ".bmp"){
                alert("您上传文件类型不符合(.txt|.rar|.zip|.pdf|.doc(x)|.xls(x))");
                return false;
              }
           } catch (e){
               var fname = '';
               var fsize = '';
               var ftype = '';
               var fdesc = '';
           }

           var postUrl;
           if(isEdit==1){
                postUrl = "/changefaultrecords/"+editId;           //修改路径
           }else{
                postUrl = "/addfaultrecords";          //添加路径
           }
         //ajax方式
           var fd = new FormData();
           fd.append('fttype', fttype);
           fd.append('ftlevel', ftlevel);
           fd.append('startdate', startdate);
           fd.append('stopdate', stopdate);
           fd.append('comment', comment);
           fd.append('ftobject', ftobject);
           fd.append('fname', fname);
           fd.append('fdesc', fdesc);
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

$("#Closebtn").click(function(){
   $('#modalForm')[0].reset();
});


//处理上传进度条显示
var sUploadFile = new SgyUploadFile({
uploadProgress: function(evt){
  $('#progress').show();
  if (evt.lengthComputable) {
     var percentComplete = Math.round(evt.loaded * 100 / evt.total);
     $('.progress').html("上传文件进度"+percentComplete+"%");
    }
  },
uploadError: function( result ) {
      // 上传失败关闭进度条
      $('#upload').val('');
    },
uploadSuccess:function( result ) {
      if(result.error_code == 0) {
        $('#upload').val('');
      }
    }
});

$('#upload').on( 'change', function( event ) {
 var el  = event.srcElement || event.target;
 var fileName = el.value;
 var files = el.files;
 if(files.length == 1) {
    var file = files[ 0 ];
    sUploadFile.ajaxUpload({
    formData:sUploadFile.wrapperFormDate(file, fileName),
    fileName:fileName
    });
    }
} );

window.onload=function(){
       var f = document.getElementById("upload");  
       //this.files即获取input中上传的file对象 是个数组   
       f.onchange = function(){  
           var files = $('#upload').prop('files');//获取到文件列表
           var reader = new FileReader();//新建一个FileReader
           reader.readAsArrayBuffer(files[0]); //读取文件
           //reader.readAsText(files[0],'gb2312');  //base64读取 
           reader.onload = function(evt){ //读取完文件之后会回来这里
              window.fileString = evt.target.result; // 读取文件内容
           }
       }     
}

</script>
