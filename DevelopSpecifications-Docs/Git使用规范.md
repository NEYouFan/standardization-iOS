# 一、Git仓库分支管理规范

项目应包含以下分支：
1. master
   
   该分支为项目主分支，此分支只作为稳定版本发布使用，不允许在此分支上修改 bug ，开发功能等。并且该分支每次发布时需根据项目的版本号打上 tag ，例如 v1.0.0。
  
1. dev

   该分支为各开发人员的开发合并分支，各开发人员在各自开发分支/功能分支/bug分支上开发/调试代码，完成相关工作后即可合并到 dev 分支，不允许各位在此分支上直接开发。此分支无需打 tag 。

1. qa-test

   该分支是交由 QA 进行测试的分支，每次交由 QA 测试时，从 dev 分支合并到该分支，合并的最后一次 commit 需要打 tag ，例如 v1.0.0-test-num，num 为 1.0.0 版本提交测试的序号。QA 测试稳定后，merge 到 master 并打上 tag，待发布。

1. dev_hzxxx

   每个开发人员的开发分支，此分支用于个人开发负责的相关模块的代码。此分支可以选择不推送到远程仓库。

1. feture_xxx

   该分支用于开发新功能，比如新版本迭代时，有一个较大的功能模块，可以不在 dev_hzxxx 分支开发，相关开发同学可在此类分支上开发，有两个优点：(1)可以多人协同 (2)可以防止模块较大时导致原来代码混乱。

1. issue_xxx

   该分支用于解决 jira 上 bug，修改完成并验证后合并到 dev 分支，等待 QA 验证。

说明：关于以上 feature_xxx 和 issue_xxx 分支的使用说明可以根据实际情况进行参考，不是规定死的，在开发过程中有疑问可以跟大家讨论。


# 二、commit规范

1. 保证每次 commit 只做一件事情。例如：当前有两个模块需要修改，修改完其中一个之后建议进行一次commit(Xcode自带 commit 功能，比较方便)。

1. commit 日志需要规范化：
   
   关于 commit message，一定要充分说明此次 commit 的目的。目前已有一些规范的 commit message 的写法，鉴于目前排期较紧张，且各位同学对于 git 的熟练程度，目前暂不做要求(后续会补充相关规范)，但注意不要胡乱 commit。

1. 当 feture_xxx、issue_xxx 分支合并到 dev 时，使用 rebase，只保留有用 commit 信息，而不是使用 merge 一并合并，导致混乱。当然，dev_hzxxx分支也可采用 rebase。

   有人写过他们项目所有将要合并到远程分支的东西都不允许用 merge，这个目前我们应该还没这么强烈需求，但考虑到 feture_xxx、issue_xxx 分支可能含有较多无用 commit 信息，暂时这两个分支要求使用rebase。后期有需求再对其他分支进行要求。
   
1. 如果刚 commit 完成之后，发现有个小地方改错了，比如改个字母大小写，然后又需要提交一次，可以使用`git commit --amend`,来与前面一次提交合并


# 三、tag规范

1. master 分支的 tag 应与项目的发布版本相关，目前我们版本 建议采用语义化版本号进行管理(即 x.x.x)，打 tag 时可使用如下格式：v1.0.0，此外，tag的说明应该包含此次版本发布的日志列表。如：(1)更新了xxx功能 (2)优化了界面 (3)添加了xxx功能 等。

1. 交由 qa 测试的 commit 也需要打 tag，这样可以追踪不同测试版本的差异
    

# 四、参考
1. [git工作流规范](https://github.com/xirong/my-git/blob/master/git-workflow-tutorial.md#开发者克隆自己fork出来的仓库)

1. [Gitflow有害论-Thounghtworks洞见](http://insights.thoughtworkers.org/gitflow-consider-harmful/?mkt_tok=eyJpIjoiT0RJd05qQmtOV0UwWVRrMCIsInQiOiJvN0dQOXFPdVpkUmtRVEZHYUZCMjRiZm1MTUFWTEl0SUFsNlU1djhTNm02cXRHSXFIdXJ3QnpWUnErNG00Z0x1NjJYQWVFSkpOcXVYaW1tZmxXRXB4SFwvT3dZOHBnNG5rNGxNb2NJMEdhSUk9In0%3D) 

