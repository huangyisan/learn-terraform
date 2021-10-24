1. tf providers通过tf和云厂商的api交互进行云资源的管理, 所以如果云厂商的api有变动,或者新增了功能,则对应的provider的维护者需要更新对应的代码.
2. 当多个用户或自动化工具运行相同的Terraform配置时，它们都应该使用所需提供商的相同版本. 有两种方法可以在配置中指定provider的版本
    * 在配置文件中的terraform层级块中定义
    * 使用dependency lock file
3. 如果没有指定的provider版本,则tf会下载最新的版本,这可能会导致一些未知的基础设施代码变化.所以指定provider版本,并且使用dependency lock file有助于tf使用合理的版本来执行配置.
4. 一般可以将main.tf中的 terraform模块独立出来, 放入versions.tf中.

## 观察versions.tf
```shell
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }

  required_version = ">= 0.14"
}
```
1. 可以看到provider是两个, 一个是hashicorp/random, 本地名称为random, 版本为固定为3.0.0, 另一个hashicorp/aws, 本地名称aws, 版本最低2.0.0.
2. 最后一条required_version = ">= 0.14"表示tf可执行二进制版本必须大于等于0.14. 如果这条>=改成~>, 则表示可以是0.14.x, x为任何子版本的二进制文件.

## 观察.terraform.lock.hcl
```shell
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "2.50.0"
  constraints = ">= 2.0.0"
  hashes = [
    "h1:aKw4NLrMEAflsl1OXCCz6Ewo4ay9dpgSpkNHujRXXO8=",
    ## ...
    "zh:fdeaf059f86d0ab59cf68ece2e8cec522b506c47e2cfca7ba6125b1cd06b8680",
  ]
}

provider "registry.terraform.io/hashicorp/random" {
  version     = "3.0.0"
  constraints = "3.0.0"
  hashes = [
    "h1:yhHJpb4IfQQfuio7qjUXuUFTU/s+ensuEpm23A+VWz0=",
    ## ...
    "zh:fbdd0684e62563d3ac33425b0ac9439d543a3942465f4b26582bcfabcb149515",
  ]
}

```
1. tf二进制文件版本大于0.14, 则当第一次执行初始化工作的时候,会根据版本需求,下载最新的符合需求的版本,并且生成.terraform.lock.hcl, 后面如果多次执行初始化,在不清理掉该文件之前,都会根据文件中的版本进行下载对应的provider.
2. 这个文件描述了, 当前真真实实使用的provider版本.
3. 这个文件应该被提交到版本仓库,这样可以确保团队直接使用脚本,可以对齐版本号.
4. 千万不要手工修改lock file.

## Upgrade the AWS provider version
1. 如果后期出了符合需求版本的新的版本,可以使用`terraform init -upgrade`命令进行更新. 更新完成后,会将新版本写入至`.terraform.lock.hcl`
2. 如果修改了terraform层级块的版本,使其比原先低,则也可以通过`-upgrade`参数进行降级.


