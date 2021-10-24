1. tf也支持从非tf创建的资源导入到tf中, 大概步骤如下
  * 定义将要被导入的,已经存在的资源
  * 将资源导入到tf state中
  * 编写tf配置文件来适配这些资源
  * 使用plan来确认当前tf配置是否适配了期望的状态和资源
  * 将这些配置应用到tf state中

## 以导入docker运行为例子
1. 首先启动一个名为`hashicorp-learn`为名称的容器
```shell 
docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest
```

2. 创建docker.tf文件, 里面定义名为"web"的docker_container资源,内容暂时为空. main.tf里面创建"docker"的provider.
```shell
resource "docker_container" "web" {}
```

```shell
# main.tf
provider "docker" {
  # host    = "npipe:////.//pipe//docker_engine"
}
```

3. 使用terraform import命令进行导入. 每一种资源有不同的导入方式,这个需要参考不同资源的导入文档, 比如docker的资源,则将其容器ID导入即可. 通过`docker inspect --format="{{.ID}}" hashicorp-learn`获取到容器id, 然后使用`terraform import 资源类型.名称 $ID`进行导入, 这个导入会将内容先导入到**tf的工作区状态中**, 其中资源类型.名称为第二步中定义的容器资源.
```shell
terraform import docker_container.web $(docker inspect --format="{{.ID}}" hashicorp-learn)
docker_container.web: Importing from ID "d45091b7121266f0c0e69dd9985acdefd110a66bcedbd03797e3606fb0a7d7ee"...
docker_container.web: Import prepared!
  Prepared docker_container for import
docker_container.web: Refreshing state... [id=d45091b7121266f0c0e69dd9985acdefd110a66bcedbd03797e3606fb0a7d7ee]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

4. 导入完后,可以通过`terraform show`查看到导入的内容, 这个内容的显示是从**tf的工作区状态**中获取的,此时在docker.tf中还没有生成对应的资源定义配置.

5. 创建导入资源的配置有两种方式,**全量创建**和**选择性创建**,两者各有优缺点.
  * 全量创建, 则将`terraform show`的内容全部导入到docker.tf中, `terraform show -no-color > docker.tf`,这样非常方便,但同时会导入大量冗余的,或者是在运行时刻才会生成的配置属性
  * 选择性创建, 则以手工的方式,将`terraform show`出来的内容,根据甄别, 将需要的内容复制粘贴到docker.tf里面, 这样可以避免数据的冗余,但比较费时费力.
  * **哪些属性需要,哪些属性可以省略,具体可以查看对应导入资源的文档.**

6. 导入完后,使用`terraform plan`命令查看, 如果有提示说某些字段无法被set, 因为有些字段的生成是在运行时刻生成,在运行之前无法指定,所以我们需要将这些字段移除掉. 比如docker资源, 有这么几项是需要移除的, `ip_prefix_length`, `ip_address`等.

7. 再次使用`terraform plan`命令查看, 看资源计划的结论,是否会重新创建资源, **我们导入的时候当然是希望不需要重新创建资源,应该是和现有环境对齐**, 所以如下可以看到, 我们导入的时候缺少了env的配置参数,导致要重新创建资源. 
```shell 
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

## ...

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      + attach            = false
      + bridge            = (known after apply)
      ## ...

      + env               = (known after apply) # forces replacement

      ## ...

      - ports { # forces replacement
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.

## ...
```

8. 接着将env字段添加到docker.tf中,再次运行`terraform plan`, 能发现不会删除重建了.

9. 最终优化后(需要根据对应资源的文档手册查阅,哪些字段可以删除)得到最小化的docker.tf其实只有如下
```shell
resource "docker_container" "web" {
    image = "sha256::602e111c06b6934013578ad80554a074049c59441d9bcd963cb4a7feccede7a5"
    name  = "hashicorp-learn"

    ports {
      external = 8080
      internal = 80
    }
}
```

10. 此时docker.tf中有了资源的定义, 如果要清空**tf的工作区状态**, 可以使用`terraform state rm "docker_container.web"`命令.

11. 在第九步中, image资源可以被单独定义出来, 目前这种方式使用sha256, 无法知道具体的image是什么.所以我们可以在docker.tf中定义一个image的资源,然后在之前container的资源的image中引用image定义的内容. 

12. 首先我们通过命令查看这个sha256的镜像名称和标签信息.
```shell
docker image inspect sha256:4392e5dad77dbaf6a573650b0fe1e282b57c5fba6e6cea00a27c7d4b68539b81 -f {{.RepoTags}}
[nginx:latest]
```

13. 接着在docker.tf中创建一个新的名为"nginx"的"docker_image"资源. 并且用`terraform apply`将镜像资源信息录入到tf的state中.
```shell
resource "docker_image" "nginx" {
  name         = "nginx:latest"
}

terraform apply
docker_container.web: Refreshing state... [id=023afc10768ab8eeaf646d6a3ac47b52a15af764367ded41702ef9cf5b91a976]

## ...

Terraform will perform the following actions:

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id     = (known after apply)
      + latest = (known after apply)
      + name   = "nginx:latest"
    }

## ...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed!
```

14. 接着修改docker_container资源中的image字段定义.
```shell 
resource "docker_container" "web" {
  name  = "hashicorp-learn"
  image = docker_image.nginx.latest
  ## ...
}
Copy

```

15. 最后使用`terraform apply`命令,查看是否需要重新创建资源,理论是不需要创建.

16. 此时tf的state已经和docker容器同步了,所以我们修改docker.tf的配置, 再使用`terraform apply`就可以让tf正常管理docker了.比如修改端口,然后进行`terraform apply`就可以发现容器被重建,并且端口变了.