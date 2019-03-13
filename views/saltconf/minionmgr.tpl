%rebase base position='终端管理',managetopli="saltmgr"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">终端列表</span>
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
                            <a id="initscanminion" href="/initscanminion" class="btn  btn-primary ">
                                <i class="btn-label fa fa-refresh"></i>重新扫描终端
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

<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */
    var editId;        //定义全局操作数据变量
	var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/getminioninfo',
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
              field: 'nodeid',
              title: '节点ID',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'hostname',
              title: '节点主机名',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'OS',
              title: '操作系统',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{ 
              field: 'IP',
              title: 'IPV4地址',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'CPU',
              title: 'CPU类型',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false
          },{
              field: 'CPUS',
              title: 'CPU数量',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'Mem',
              title: '内存(GB)',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'virtual',
              title: '机器类别',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'status',
              title: '在线状态',
              align: 'center',
              valign: 'middle',
              sortable: false,
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
              width: 100,
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
            var style_del = '&nbsp;<a href="/delminion/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
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

})
</script>
