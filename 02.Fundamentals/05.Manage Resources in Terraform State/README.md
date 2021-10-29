1. tf会将状态信息存储在一个状态文件中,这文件追踪了资源在被创建后映射到真实资源的情况.
2. tf存放状态的文件为terraform.tfstate
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