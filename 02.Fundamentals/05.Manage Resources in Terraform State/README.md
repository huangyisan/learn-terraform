1. tf会将状态信息存储在一个状态文件中,这文件追踪了资源在被创建后映射到真实资源的情况.
2. tf存放状态的文件为terraform.tfstate, **不要手动去修改该文件.**
3. 观察terraform.tfstate,可以发现他是由json构成的.
```json
    "resources": [
    {
        "mode": "data",
        "type": "aws_ami",
        "name": "ubuntu",
        "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
        "instances": [
            {
            "schema_version": 0,
            "attributes": {
                "architecture": "x86_64",
                "arn": "arn:aws:ec2:us-east-1::image/ami-0b287e7832eb862f8",
        ##...
        },
        ##...
    ]
```
4. 文件中"mode"有且仅有两种类型,一种是"data",另外一种是"managed", "type"字段表示了对应的aws provider里面对应的资源. "instances"内"attributes"定义了资源的属性.
5. "instances"资源里面还有"dependencies"字段定义了资源之间的依赖关系,如果改变了"dependencies"里面的内容,则对应依赖的资源也会变更.
6. 可以通过`terraform show`命令使用人类已读的方式展现资源详情.
7. 使用`terraform state list`命令仅列出资源.
8. 已经存在的资源可以通过`-replace`命令进行重建指定资源.有时候出现异常,或者人为上了控制台修改了东西后.比如如下方法就可以重建aws_instance.example资源.
```shell
$ terraform state list
data.aws_ami.ubuntu
aws_instance.example
aws_security_group.sg_8080

$ terraform plan -replace="aws_instance.example"

$ terraform apply -replace="aws_instance.example"

```
9. 使用带-replace标志的terraform apply命令是hashicorp推荐的管理资源的过程，无需手动编辑状态文件.

## Move a resource to a different state file
1. `terraform state mv`命令,可以将资源状态迁移到另外一个状态文件中.
2. 当您希望组合来自其他状态的模块或资源，但又不想破坏和重新创建基础设施时，移动资源是很有用的.
3. 比如当前目录new_state路径下面有一个aws_instance.example_new资源. 将主目录的terraform.tfvars复制到里面,然后进行`terraform init`操作, `terraform apply`, 此时新的状态写入了state文件中.
4. 使用命令`terraform state mv -state-out=../terraform.tfstate aws_instance.example_new aws_instance.example_new` 将新创建的资源移动的老的state文件中. 注意移动进去的资源, 必须先前是不存在同名的.
5. 返回上一层,发现资源已经被添加进去了
```shell
$ terrform state list
data.aws_ami.ubuntu
aws_instance.example
aws_instance.example_new
aws_security_group.sg_8080
```