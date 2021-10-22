1. 使用变量可以让terraform更加灵活
2. 和其他语言中的变量不同,terraform的变量不会在terraform运行,更新,销毁的时候改变.他允许用户在执行之前传入不同的变量,而不是手动编辑配置文件,从而使得更加安全.
3. tf的变量可以写入variables.tf文件中.
4. 一个变量的定义一般包含三个部分
    * Description 对变量的描述
    * Type 变量的类型
    * Default 变量默认的值
5. 在main.tf中调用变量,只需要var.变量名 即可.
6. 变量存在多种类型, string, number, bool, list, map, set等.
    * list类型写法, list(type), 例如list(string),表示是一个以字符串组成的list. map亦如此, 例如map(string)
7. 在控制台输入terraform console可以进入控制台, 使用var.变量名 可以查看变量, 还可以配合函数使用,比如slice(数组,起始位,步进)来获取指定长度的数组.
8. 如果一个变量定义的时候没有指定default, 并且也没有传入变量,则在terraform apply阶段会提示让你输入对应的变量具体的值, 如果不想每次都输入,而且在不定义default的情况下,可以在目录创建一个terraform.tfvars的文件,则每次执行apply命令的时候,如果碰到没有赋值的变量,则会从这里面去寻找. terrform会从路径下名为terraform.tfvars或者*.auto.tfvars文件中进行寻找.
9. tf支持在字符串中插入变量, 使用${}获取变量,比如${var.resource_tags["project"]}-${var.resource_tags["environment"]}
10. variables.tf和terraform.tfvars的区别, 前者可以看成是对变量的声明,同时可以选择附带默认值,后者则是对变量的具体赋值,如果有若干不同的项目要使用,则不同的项目可以定义不同的terraform.tfvars来应对不同的环境.
11. tf支持对变量的验证, 可以在valiable层级内编写validation块,就可以在里面定义变量的验证方式.
12. valiable层级内的error_message信息, 需要以首字母大写开始, 结尾得有标点符号. 一个valiable块中,可以有多个validation块.