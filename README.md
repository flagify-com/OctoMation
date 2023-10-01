- [OctoMation章鱼编排自动化](#octomation章鱼编排自动化)
- [应用场景](#应用场景)
  - [网络安全编排自动化与响应](#网络安全编排自动化与响应)
    - [一键全局IP封禁](#一键全局ip封禁)
  - [运维网络故障诊断](#运维网络故障诊断)
  - [IT服务入职离职账号启停](#it服务入职离职账号启停)
- [技术知识](#技术知识)
  - [架构图](#架构图)
  - [应用对接](#应用对接)
- [安装部署](#安装部署)
- [用户交流](#用户交流)
  - [参与GitHub Discussions互动交流（优先方式）](#参与github-discussions互动交流优先方式)
  - [参与微信群聊](#参与微信群聊)
  - [提交GitHub Issue](#提交github-issue)
- [其它](#其它)
  - [OctoMation编排自动化社区免费版与企业版的区别](#octomation编排自动化社区免费版与企业版的区别)
  - [备注](#备注)

# OctoMation章鱼编排自动化

**OctoMation章鱼编排自动化**（Octopus Orchestration & Automation）是上海雾帜智能科技有限公司HoneyGuide SOAR产品的社区免费版，是中国企业市场领先的编排和自动化（Orchestration & Automation， O&A）产品。

OctoMation支持用户通过**可视化、低代码甚至无代码**的方式拖拽生成剧本（Playbook），连接网络设备、安全产品、IT系统和SaaS服务等基础能力，实现各类流程的可视化编排和自动化执行，可用于网络安全编排自动化与响应，运维自动化，IT服务自动化甚至是客服、风控等场景，有无限的想象空间。

# 应用场景

> 当生产力不是问题，剩下的就是想象力！

## 网络安全编排自动化与响应

### 一键全局IP封禁

> 态势感知/SOC/SIEM发现攻击者IP，需要第一时间进行IP封禁。封禁和解封本身也有特定的逻辑，需要注意。

<img src="images/playbook-ip-block.png" alt="一键全局IP封禁" />

OctoMation实战效果：
- 1个人1分钟内完成全局处置（原本可能多人，多设备，数十分钟完成）
- 规则明确情况下，可实现7x24小时自动化处置
- 全自动完成多项协作任务：识别封禁对象、判断黑白名单、判断CDN、判断业务IP、决策封禁设备、下发封禁指令、延迟自动解封、维护封禁列表
- 快速、高效、精准、免人工干预

## 运维网络故障诊断

> 企业办公网或生产网发生网络故障，需要快速定位问题，排除故障，恢复网络。

<img src="images/playbook-network-diagnosis-and-recovery.png" alt="网络故障诊断，调查与恢复" />

OctoMation实战效果：
- 一键获取多设备、系统的第一现场数据
- 基于专家剧本快速开展排障调查
- 智能决策网络优化或恢复策略
- 人工审批后通过仿真环境或真实环境批量下发策略
- 完成快速诊断和网络恢复

## IT服务入职离职账号启停

> 人员离职、转岗涉及到大量审计和配置工作，如：近期内部DLP系统告警、近期员工账号异常活跃告警、内部各类系统的权限撤销、公司身份认证系统账号的禁用等等。

<img src="images/playbook-it-employee-dimission.png" alt="IT服务过程中人员离职审查" />

OctoMation实战效果：
- 5分钟完成原本需要50分钟完成的审查工作
- 绝大多数场景无需人工干预，只有在审计发现风险时才会人工干预
- 入离职高峰期大幅降低审计人员的工作压力（这类工作因为敏感性，通常不适合委托）

# 技术知识
## 架构图

- OctoMation支持通过Kafka、Syslog、API等方式接收上游的信息输入，根据与编排的剧本，开展自动化的流程执行。
- OctoMation支持通过HTTP/HTTPS、SSH、Telnet、Restful API等方式联动调度下游基础产品能力。

<img src="images/OctoMation-Design-Overview.png" alt="OctoMation编排自动化交流微信群" width="80%" />


## 应用对接


# 安装部署

# 用户交流

## 参与GitHub Discussions互动交流（优先方式）

您可以在[GitHub Discussions](https://github.com/orgs/flagify-com/discussions)与我们互动，提交您的想法、玩法和需求，与社区成员进行思想碰撞。我们也将不定期在Discussions上做活动，帮助更多用户快速用上和用好OctoMation编排自动化产品。

## 参与微信群聊

微信扫码，参与社区微信群聊互动。

<!-- ![OctoMation编排自动化交流微信群](images/wechat-group-qrcode.png) -->

<img src="images/wechat-group-qrcode.png" alt="OctoMation编排自动化交流微信群" width="200" />

## 提交GitHub Issue

欢迎通过[GitHub Issue](https://github.com/flagify-com/OctoMation/issues)界面向我们提交Bug、问题。


# 其它
## OctoMation编排自动化社区免费版与企业版的区别

## 备注
- [上海雾帜智能科技有限公司](https://flagify.com)正式成立于2019年4月，创始团队来华为、唯品会、千寻位置和小米等对安全运营有极高要求的企业。
- 智能风险决策系统HoneyGuide SOAR是雾帜智能于2019年8月正式发布的一款基于AI+SOAR的产品，旨在帮助客户“加速安全响应 ，智能安全运营”，是大量客户在智能安全运营领域的首选品牌（嘶吼安全产业研究院《安全编排自动化与响应(SOAR)市场研究报告》，2023.06）。