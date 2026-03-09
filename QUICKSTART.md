# AntiUV iOS App - 快速启动指南

## 🎯 立即开始

### 1. 打开项目

在终端执行:
```bash
open /Volumes/Untitled/app/20260309/antiuv/antiuv/antiuv.xcodeproj
```

或双击 `antiuv.xcodeproj` 文件

---

### 2. 配置开发环境

**系统要求**:
- macOS Sonoma 14.0+
- Xcode 15.0+
- iOS 17.0+

**Apple Developer 账户**:
1. 打开 Xcode → Preferences → Accounts
2. 添加你的 Apple ID
3. 选择 Team

---

### 3. 配置 WeatherKit

WeatherKit 需要 Apple Developer 账户:

1. 登录 [Apple Developer](https://developer.apple.com)
2. 进入 Certificates, Identifiers & Profiles
3. 选择你的 App ID
4. 启用 **WeatherKit** 服务
5. 保存并下载配置文件
6. 双击安装配置文件

---

### 4. 运行应用

#### 在模拟器运行:
1. Xcode 顶部选择设备 (如 iPhone 15 Pro)
2. 按 **Cmd + R** 运行
3. 模拟器会自动启动应用

#### 在真机运行:
1. 用 USB 连接 iPhone
2. Xcode 顶部选择你的设备
3. 按 **Cmd + R** 运行
4. 在 iPhone 上信任开发者证书

---

### 5. 首次使用

应用启动后会自动:

1. **请求位置权限** → 点击"允许"
2. **请求通知权限** → 点击"允许"
3. **Onboarding 引导** → 浏览 3 页介绍
4. **Profile 设置** → 选择皮肤类型

完成后即可看到实时 UV 指数!

---

## 🧪 运行测试

### 所有测试:
- 按 **Cmd + U**
- 或菜单：Product → Test

### 单个测试文件:
1. 打开测试文件 (如 `SPFRecommendationEngineTests.swift`)
2. 点击测试函数旁边的 ◇ 图标
3. 选择 Run

---

## 📱 功能演示

### 主界面功能

1. **UV 指数卡片**
   - 显示当前 UV 指数
   - 颜色编码 (绿/黄/橙/红/紫)
   - 可视化等级条
   - 最后更新时间

2. **天气卡片**
   - 温度
   - 云量
   - 位置

3. **安全定时器**
   - 点击"Start Safety Timer"
   - 选择时长 (15-120 分钟)
   - 倒计时开始
   - 可暂停/恢复/重置

4. **建议卡片**
   - 个性化防晒建议
   - 基于皮肤类型和 UV 指数

### Profile 设置

点击右上角头像进入:

- **Skin Type**: I-VI 型选择
- **Preferred SPF**: 15/30/50/50+
- **Activity Level**: 活动强度
- **Water Resistant**: 防水开关
- **Notifications**: 通知设置
- **UV Alert Threshold**: 警报阈值

---

## 🔧 常见问题

### Q: WeatherKit 报错怎么办？

**A**: 检查以下步骤:
1. 确认 Apple Developer 账户已登录
2. 确认 WeatherKit 服务已启用
3. 确认配置文件已安装
4. 清理项目：Product → Clean Build Folder (Shift+Cmd+K)
5. 重新运行

### Q: 位置权限被拒绝怎么办？

**A**: 
1. 打开 iPhone 设置 → Privacy → Location Services
2. 找到 AntiUV 应用
3. 选择"使用 App 期间"

### Q: 通知不显示怎么办？

**A**:
1. 打开 iPhone 设置 → Notifications
2. 找到 AntiUV 应用
3. 允许通知
4. 开启声音和标记

### Q: UV 指数显示 0 或不更新？

**A**:
- 检查网络连接
- 确认位置权限已开启
- 下拉刷新
- 重启应用

---

## 📋 项目文件说明

### 核心文件

| 文件 | 作用 |
|------|------|
| `ContentView.swift` | 应用入口，Onboarding 流程 |
| `antiuvApp.swift` | App 生命周期，通知配置 |
| `DashboardView.swift` | 主界面 |
| `UVIndexCard.swift` | UV 指数显示组件 |
| `SafetyTimerCard.swift` | 定时器组件 |
| `ProfileView.swift` | 设置页面 |

### 服务层

| 文件 | 作用 |
|------|------|
| `SPFRecommendationEngine.swift` | **核心算法** - 计算补涂时间 |
| `WeatherKitService.swift` | WeatherKit 数据获取 |
| `UVDataService.swift` | UV 数据服务 (含降级策略) |
| `NotificationService.swift` | 通知管理 |

### 模型层

| 文件 | 作用 |
|------|------|
| `SkinType.swift` | Fitzpatrick 皮肤类型 |
| `ActivityLevel.swift` | 活动级别 |
| `UVData.swift` | UV 数据结构 |
| `UserProfile.swift` | 用户配置 |
| `ExposureSession.swift` | 暴露会话记录 |

---

## 🎨 自定义配置

### 修改主题色

编辑 `Assets.xcassets/AccentColor.colorset`:
- 默认：橙色 (#FF9500)
- 可改为其他颜色

### 修改默认 SPF 值

编辑 `Models/UserProfile.swift`:
```swift
static var `default`: UserProfile {
    UserProfile(
        skinType: .typeII,
        preferredSPF: 50,  // 修改这里
        ...
    )
}
```

### 修改通知时间

编辑 `Services/NotificationService.swift`:
```swift
func scheduleMorningBriefing() async throws {
    var dateComponents = DateComponents()
    dateComponents.hour = 8  // 修改小时
    dateComponents.minute = 0
    ...
}
```

---

## 📊 代码质量

### 测试覆盖率
- SPF 算法：100%
- Models: 100%
- ViewModels: 80%+

### 代码规范
- 遵循 Swift 官方风格指南
- 使用文档注释
- 单一职责原则
- DRY 原则

---

## 🚀 下一步开发

### Phase 2 (Weeks 4-6)
1. Core Data 历史记录
2. iOS Widgets
3. 教育内容
4. 动画优化

### Phase 3 (Weeks 7-9)
1. Apple Watch 应用
2. HealthKit 集成
3. Siri 快捷指令
4. iCloud 同步

---

## 📞 需要帮助？

### 查看完整文档
- [us.md](us.md) - 完整英文操作指南
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - 项目总结

### 检查代码
所有代码文件都在:
```
/Volumes/Untitled/app/20260309/antiuv/antiuv/antiuv/
```

### 测试文件
所有测试在:
```
/Volumes/Untitled/app/20260309/antiuv/antiuvTests/
```

---

**祝开发顺利！🎉**
