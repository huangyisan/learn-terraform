1. output中的value可以允许你导出创建资源后的数据.
2. 这些数据可以用于自动工具上,或者作为另外tf workspace的数据源, 或者从子模块将数据分享给根模块.
3. output的定义内容一般约定俗成的在outputs.tf里.
4. output.tf里面的定义,也是可以使用函数,或者进行字符串中插入变量.
5. 修改完output.tf后,执行terraform apply,就能得到输出.
6. 使用terraform output可以得到最近一次terraform apply的输出. terraform output后面指定字段,则可以得到该字段在输出中的value. 如果是字符串的value,默认会添加上双引号,可以加上-raw参数, 自动去除双引号.
7. output的数据还支持脱敏,只需要在output内容里面定义sensitive = true字段,则当terraform output输出的时候,该字段的value会被标记为<sensitive>.
8. 需要注意的是,如果使用terraform output 指定字段输出的方式,则标记为敏感数据的值还是会显示. 
9. 使用terraform output -json就可以以json的方式输出, 该种输出方式可以作为数据源对接到自动化工具里面,所以对敏感信息不会进行脱敏.