%rebase base position='CRON表达式说明', managetopli="help"
<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">帮助文档</span>
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
            <p>
            <br/>
            &nbsp;&nbsp;&nbsp;&nbsp;API是以webservice方式把系统中通过指令传参形式转化为URL传参。<br /> 
            <pre>
            传参转换格式：_^_^_ [一级分割符] _^_ [二级分割符]
            例子: uid_^_lnmos_^_^_number_^_13688888888_^_^_name_^_5Lit5paH_^_^_
            </pre>
            </p>
            <pre>
            Shell接参实例:
            &nbsp;&nbsp;#处理接收到的参数
            &nbsp;&nbsp;for i in $(echo $1|sed 's/_^_^_/\n/g');do
            &nbsp;&nbsp;    opts=$(echo $i|sed 's/_^_/=/g')
            &nbsp;&nbsp;    export $opts
            &nbsp;&nbsp;done 
            &nbsp;&nbsp;#参数base64中文解码 
            &nbsp;&nbsp;echo "$name"|base64 -d >/dev/null 2>&1 && name=$(echo "$name"|base64 -d) 
            </pre>
            <pre>
            Python接参实例:
            &nbsp;&nbsp;#coding=utf-8
            &nbsp;&nbsp;import sys,base64,json
            &nbsp;&nbsp;optdict={}
            &nbsp;&nbsp;for i in sys.argv[1].split('_^_^_'):
            &nbsp;&nbsp;    if i != "":
            &nbsp;&nbsp;       # 指定参数base64中文解码
            &nbsp;&nbsp;       if i.split('_^_')[0]=="name":
            &nbsp;&nbsp;          try:
            &nbsp;&nbsp;            newstr=base64.b64decode(i.split('_^_')[1])
            &nbsp;&nbsp;          except:
            &nbsp;&nbsp;            newstr=i.split('_^_')[1]
            &nbsp;&nbsp;       else:
            &nbsp;&nbsp;          newstr=i.split('_^_')[1]
            &nbsp;&nbsp;       optdict[i.split('_^_')[0]]=newstr
            &nbsp;&nbsp;print json.dumps(optdict,ensure_ascii=False)
            </pre>
            </p>
            </div> 
          </div> 
        </div>
    </div>
</div>
