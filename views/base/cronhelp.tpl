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
            &nbsp;&nbsp;&nbsp;&nbsp;Cron表达式是一个字符串，字符串以空格隔开，分为5或6个域，每一个域代表一个含义，系统支持的表达式格式如下:<br/>
            <pre>
            <b>Seconds Minutes Hours DayofMonth Month [DayofWeek]</b>
            其中 DayofWeek 为可选域.
            </pre>
            <pre>
            每一个域可出现的字符如下： 
            <b>Seconds:</b> 可出现"* / , -"四个字符，有效范围为0-59的整数
            <b>Minutes:</b> 可出现"* / , -"四个字符，有效范围为0-59的整数
            <b>Hours:</b> 可出现"* / , -"四个字符，有效范围为0-23的整数
            <b>DayofMonth:</b> 可出现"* / , -"字符，有效范围为0-31的整数 
            <b>Month:</b> 可出现", - * /"四个字符，有效范围为1-12的整数或JAN-DEC 
            <b><font color='red'>DayofWeek:</b> 可出现"* / , -"字符，有效范围为0-6的整数或Mon-SUN两个范围。0表示星期一，1表示星期二， 依次类推</font>
            各个字符的含义如下：
              * 表示匹配该域的任意值，假如在Minutes域使用*, 即表示每分钟都会触发事件。
              ? 字符仅被用于天（月）和天（星期）两个子表达式，表示不指定值，当子表达式其一被指定了值以后，为了避免冲突，需要将另一表达式的值设为?。
              - 表示范围，例如在Minutes域使用5-20，表示从5分到20分钟每分钟触发一次。
              / 表示起始时间开始触发，然后每隔固定时间触发一次，例如在Minutes域使用5/20,则意味着5分钟触发一次，而25，45等分别触发一次。
              , 表示列出枚举值值。例如：在Minutes域使用5,20，则意味着在5和20分每分钟触发一次。
            </pre>
            <pre>
            一些例子：
            0 0 10,14,16 * * 每天上午10点，下午2点，4点触发 
            0 0/30 9-17 * * 朝九晚五工作时间内每半小时触发  
            0 0 12 ? * WED 表示每个星期三中午12点触发  
            0 0 12 * * 每天中午12点触发 
            0 15 10 * * 每天上午10:15触发 
            0 15 10 * * 每天上午10:15触发 
            0 15 10 * * * 每天上午10:15触发 
            0 * 14 * * 在每天下午2点到下午2:59期间的每1分钟触发 
            0 0/5 14 * * 在每天下午2点到下午2:55期间的每5分钟触发 
            0 0/5 14,18 * * 在每天下午2点到2:55期间和下午6点到6:55期间的每5分钟触发 
            0 0-5 14 * * 在每天下午2点到下午2:05期间的每1分钟触发 
            0 15 10 15 * * 每月15日上午10:15触发 
            </pre>
            </p>
          
            </div> 
          </div> 
        </div>
    </div>
</div>
