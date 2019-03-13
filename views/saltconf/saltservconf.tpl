%rebase base position='SALT服务配置', managetopli="saltmgr"
<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">SALT服务配置</span>
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
                  <form action="" method="post">
                    %if msg.get('message'):
                      <span style="color:{{msg.get('color','')}};font-weight:bold;">&emsp;{{msg.get('message','')}}</span>
                    %end
		    <div class="modal-body">
                        <div class="input-group">
                            <span class="input-group-addon">SALT监听地址</span>
                            <input type="text" style="width:200px" class="form-control" id="" name="saltListen" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" aria-describedby="inputGroupSuccess4Status" value="{{info.get('saltListen','')}}">
                        </div>
                    </div>
		    <div class="modal-body">
                      <div class="input-group">
                        <span class="input-group-addon">消息发布端口</span>
                        <input type="text" style="width:200px" class="form-control" id="" name="smsport" onkeyup="this.value=this.value.replace(/[^\d]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d]/g,'')" aria-describedby="inputGroupSuccess4Status" value="{{info.get('smsport','')}}">
                        </div>
                    </div>
		    <div class="modal-body">
                      <div class="input-group">
                        <span class="input-group-addon">通讯服务端口</span>
                        <input type="text" style="width:200px" class="form-control" id="" name="txport" onkeyup="this.value=this.value.replace(/[^\d]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d]/g,'')" aria-describedby="inputGroupSuccess4Status" value="{{info.get('txport','')}}">
                        </div>
            </div>
            <div class="modal-body">
                 <div class="input-group">
                    <span class="input-group-addon">自动接受认证</span>
                    <select style="width:200px" class="form-control" name="autoAccept">
                                        <option 
                                        %if info.get('autoAccept','') == 'false':
                                                selected
                                        %end 
                                        value='false'>关闭</option>
                                        <option
                                        %if info.get('autoAccept','') == 'true':
                                                 selected
                                        %end 
                                        value='true'>开启</option>
                    </select>
                 </div>
            </div>
		    <div class="modal-body">
                    <div class="input-group">
                      <span class="input-group-addon">事件超时时间</span>
                      <input type="text" style="width:200px" class="form-control" id="" name="timeout" onkeyup="this.value=this.value.replace(/[^\d]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d]/g,'')" aria-describedby="inputGroupSuccess4Status" value="{{info.get('timeout','')}}">
                    </div>
                    <div class="modal-body">
                        <span style="color:#666666;" id="signc">备注<br/>1.事件超时时间间隔尽量不要过长，建议最小值为3s<br/>2.服务中端口请务必在本机放行.<br/></span>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" style="float:left" class="btn btn-primary">保存</button>
                    </div>
                </div>
              </form>
            </div>
        </div>
    </div>
</div>
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script> 
<script charset="utf-8" src="/assets/kindeditor/kindeditor.js"></script>
<script charset="utf-8" src="/assets/kindeditor/lang/zh_CN.js"></script>
