# SmartWin 运营推广配置文件 (PROMO-OPS-001~004)

> 本文件汇总了运营推广Phase 2和Phase 3的运营配置项。

---

## PROMO-OPS-001: 公众号开号+菜单配置+首批内容

### 公众号配置
- **公众号名称**: SmartWin AI治理
- **微信号**: smartwin-ai
- **类型**: 服务号
- **AppID**: 待申请
- **AppSecret**: 待配置

### 菜单配置
```json
{
  "button": [
    {
      "type": "view",
      "name": "产品介绍",
      "url": "https://www.smartwin.com/company/products"
    },
    {
      "type": "view",
      "name": "技术博客",
      "url": "https://www.smartwin.com/blog"
    },
    {
      "type": "view",
      "name": "免费试用",
      "url": "https://www.smartwin.com/register"
    }
  ]
}
```

### 首批内容计划
1. 《SmartWin平台正式上线——企业AI治理新选择》
2. 《AI治理最佳实践：5步构建企业AI合规体系》
3. 《大模型成本优化：Token经济学的艺术》

---

## PROMO-OPS-002: 社媒矩阵搭建

### 国内社媒
| 平台 | 账号名 | 定位 | 内容类型 | 发布频率 |
|------|--------|------|---------|---------|
| 知乎 | SmartWin AI治理 | 深度技术文章 | AI治理/数据治理/大模型 | 2篇/周 |
| 掘金 | SmartWin | 技术教程 | 前端/后端/DevOps | 3篇/周 |
| CSDN | SmartWin博客 | 技术博客同步 | 全部博客同步 | 每篇同步 |
| LinkedIn | SmartWin | 国际市场 | 英文内容/案例 | 1篇/周 |

### 国际社媒 (PROMO-OPS-004)
| 平台 | 账号名 | 定位 | 内容类型 | 发布频率 |
|------|--------|------|---------|---------|
| Twitter | @SmartWinAI | 产品更新 | 英文短内容 | 5条/周 |
| B站 | SmartWin | 视频教程 | 技术演示/产品介绍 | 1视频/周 |
| Discord | SmartWin Community | 开发者社区 | 技术讨论 | 日常 |

---

## PROMO-OPS-003: 开发者社区运营

### GitHub Discussions 配置
- **仓库**: smartwin-platform/shared-components
- **Discussion分类**:
  - 📢 Announcements (公告)
  - 💡 Ideas (功能建议)
  - ❓ Q&A (问答)
  - 🙋 Show & Tell (展示分享)
  - 🐛 Bug Reports (问题报告)

### 社区运营KPI
- M3: 100 community members
- M6: 500 community members
- M12: 2000 community members

---

## OAuth 第三方登录配置 (application.yml)

```yaml
# 企业微信 OAuth
oauth:
  wechat-work:
    corp-id: ${WECHAT_WORK_CORP_ID:}
    agent-id: ${WECHAT_WORK_AGENT_ID:}
    secret: ${WECHAT_WORK_SECRET:}
    redirect-uri: ${WECHAT_WORK_REDIRECT_URI:https://www.smartwin.com/oauth/wechat-work/callback}
  
  # 钉钉 OAuth
  dingtalk:
    app-key: ${DINGTALK_APP_KEY:}
    app-secret: ${DINGTALK_APP_SECRET:}
    redirect-uri: ${DINGTALK_REDIRECT_URI:https://www.smartwin.com/oauth/dingtalk/callback}
  
  # 飞书 OAuth
  feishu:
    app-id: ${FEISHU_APP_ID:}
    app-secret: ${FEISHU_APP_SECRET:}
    redirect-uri: ${FEISHU_REDIRECT_URI:https://www.smartwin.com/oauth/feishu/callback}

# 群机器人 Webhook
webhook:
  wechat-work:
    url: ${WECHAT_WORK_WEBHOOK_URL:}
  dingtalk:
    url: ${DINGTALK_WEBHOOK_URL:}
  feishu:
    url: ${FEISHU_WEBHOOK_URL:}

# 微信公众号
wechat:
  mp:
    app-id: ${WECHAT_MP_APP_ID:}
    app-secret: ${WECHAT_MP_APP_SECRET:}

# 邮件配置
spring:
  mail:
    host: ${MAIL_HOST:smtp.qq.com}
    port: ${MAIL_PORT:587}
    username: ${MAIL_USERNAME:noreply@smartwin.com}
    password: ${MAIL_PASSWORD:}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```
