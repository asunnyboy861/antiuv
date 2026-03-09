# AntiUV iOS App - 完整配置与部署指南

## 📋 配置清单

### 必需的配置步骤

在运行应用之前，需要完成以下配置:

---

## 1. Apple Developer 账户配置

### 1.1 创建 App ID

1. 登录 [Apple Developer](https://developer.apple.com/account)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → **App IDs**
4. 点击 **+** 创建新的 App ID
5. 填写信息:
   - **Description**: AntiUV
   - **Bundle ID**: com.yourcompany.antiuv (使用你的域名)
   - **Capabilities**: 勾选以下服务

### 1.2 必需的能力 (Capabilities)

勾选以下服务:

- ✅ **WeatherKit** - UV 数据获取
- ✅ **Push Notifications** - 通知提醒
- ✅ **HealthKit** - 健康数据集成
- ✅ **App Groups** (可选) - Widget 数据共享
- ✅ **Background Modes**:
  - ✅ Background fetch
  - ✅ Remote notifications

### 1.3 创建证书

1. 进入 **Certificates**
2. 点击 **+**
3. 选择:
   - **Development**: `iOS App Development`
   - **Distribution**: `iOS App Store and Ad Hoc`
4. 按照指引创建并下载证书
5. 双击安装到钥匙串

### 1.4 创建 Provisioning Profile

#### Development Profile:
1. 进入 **Profiles** → **+**
2. 选择 **iOS App Development**
3. 选择你的 App ID
4. 选择开发证书
5. 选择测试设备
6. 下载并安装

#### Distribution Profile:
1. 进入 **Profiles** → **+**
2. 选择 **App Store**
3. 选择你的 App ID
4. 选择分发证书
5. 下载备用

---

## 2. Xcode 项目配置

### 2.1 打开项目

```bash
open /Volumes/Untitled/app/20260309/antiuv/antiuv/antiuv.xcodeproj
```

### 2.2 配置 Team

1. 选择项目导航器中的 **antiuv** 项目
2. 选择 **antiuv** Target
3. 在 **Signing & Capabilities** 标签:
   - 勾选 **Automatically manage signing**
   - 选择你的 **Team**
   - 确认 **Bundle Identifier** 与 App ID 一致

### 2.3 添加 Capabilities

在 **Signing & Capabilities** → **+ Capability**:

#### 必需添加:

1. **WeatherKit**
   - Xcode 会自动配置

2. **Push Notifications**
   - Xcode 会自动配置

3. **HealthKit**
   - 手动添加 HealthKit 权限描述

4. **Background Modes**
   - ✅ Background fetch
   - ✅ Remote notifications

5. **App Groups** (Widget 需要)
   - 创建 Group: `group.com.yourcompany.antiuv`

---

## 3. Info.plist 配置

### 3.1 位置权限描述

在 `Info.plist` 中添加:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide accurate UV index data for your area.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to send you location-based UV alerts and reminders.</string>
```

### 3.2 HealthKit 权限描述

```xml
<key>NSHealthShareUsageDescription</key>
<string>We will sync your UV exposure data with Apple Health for comprehensive health tracking.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>We will record your UV exposure sessions to Apple Health for better health insights.</string>
```

### 3.3 通知权限

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3.4 Widget 配置

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.antiuv</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>antiuv</string>
        </array>
    </dict>
</array>
```

---

## 4. WeatherKit 配置详解

### 4.1 启用 WeatherKit

1. 登录 [Apple Developer](https://developer.apple.com/account/resources/identifiers/list)
2. 选择你的 App ID
3. 勾选 **WeatherKit**
4. 保存并下载配置文件

### 4.2 验证 WeatherKit

在代码中测试:

```swift
import WeatherKit

let weatherService = WeatherService()
Task {
    do {
        let weather = try await weatherService.weather(for: CLLocation(latitude: 37.7749, longitude: -122.4194))
        print("WeatherKit works! UV Index: \(weather.currentWeather.uvIndex)")
    } catch {
        print("WeatherKit error: \(error)")
    }
}
```

### 4.3 WeatherKit 限制

- **免费额度**: 500,000 次调用/月
- **超出后**: $2.50 / 10,000 次调用
- **建议**: 实现缓存策略减少调用

---

## 5. HealthKit 配置详解

### 5.1 添加 HealthKit Capability

1. 在 Xcode 中选择项目
2. **Signing & Capabilities** → **+ Capability**
3. 搜索并添加 **HealthKit**

### 5.2 配置权限

在 `Info.plist` 中添加使用描述 (见上方 3.2)

### 5.3 测试 HealthKit

```swift
let healthKitService = HealthKitService()

if healthKitService.checkAvailability() {
    print("HealthKit is available")
    
    Task {
        do {
            let authorized = try await healthKitService.requestAuthorization()
            print("HealthKit authorized: \(authorized)")
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }
}
```

---

## 6. Widget 配置

### 6.1 添加 Widget Extension

项目已包含 Widget 文件，需要配置:

1. 在 Xcode 中选择 **antiuvWidget** Target
2. 配置 **Signing & Capabilities** (与主应用相同 Team)
3. 确认 **Bundle Identifier**: `com.yourcompany.antiuvWidget`

### 6.2 配置 App Group

1. 主应用 Target:
   - 添加 **App Groups** Capability
   - 创建 Group: `group.com.yourcompany.antiuv`

2. Widget Target:
   - 添加相同的 **App Groups**
   - 勾选相同的 Group

### 6.3 测试 Widget

1. 运行 **antiuvWidget** scheme
2. 在模拟器或真机查看
3. 真机需要添加到主屏幕

---

## 7. Siri Shortcuts 配置

### 7.1 自动配置

Siri Shortcuts 代码已包含，Xcode 会自动配置 App Intents

### 7.2 测试 Siri 指令

1. 运行应用一次 (注册 intents)
2. 说 "Hey Siri, check UV index"
3. 或 "Hey Siri, start sunscreen timer"

### 7.3 自定义短语

在代码中修改 `AppShortcutsProvider`:

```swift
AppShortcut(
    intent: GetCurrentUVIndexIntent(),
    phrases: [
        "Check UV with AntiUV",
        "UV Index now"
    ],
    shortTitle: "UV Index",
    systemImageName: "sun.max"
)
```

---

## 8. 通知配置

### 8.1 请求权限

已在 `antiuvApp.swift` 中自动请求

### 8.2 测试通知

```swift
// 在代码中触发测试通知
Task {
    try? await NotificationService.shared.scheduleReapplyReminder(
        timeInterval: 1, // 1 分钟
        uvIndex: 5.0,
        spfValue: 50
    )
}
```

### 8.3 通知类型

- ✅ Reapply Reminder (补涂提醒)
- ✅ UV Peak Alert (UV 峰值警告)
- ✅ Morning Briefing (每日晨报)

---

## 9. 构建与运行

### 9.1 在模拟器运行

1. 选择模拟器设备 (iPhone 15 Pro)
2. 按 **Cmd + R**
3. 允许位置权限 (模拟器会弹窗)

### 9.2 在真机运行

1. 用 USB 连接 iPhone
2. 选择设备
3. 按 **Cmd + R**
4. 在 iPhone 上信任开发者:
   - 设置 → 通用 → VPN 与设备管理
   - 信任你的开发者证书

### 9.3 解决常见问题

#### 问题 1: "No provisioning profiles found"
**解决**: 
- 重新下载并安装配置文件
- 在 Xcode: Preferences → Accounts → Download Manual Profiles

#### 问题 2: "WeatherKit authorization failed"
**解决**:
- 确认 App ID 启用了 WeatherKit
- 确认配置文件已更新
- 清理项目: Product → Clean Build Folder

#### 问题 3: "HealthKit not available"
**解决**:
- 在真机测试 (模拟器不支持完整 HealthKit)
- 确认 Info.plist 有使用描述

#### 问题 4: Widget 不显示数据
**解决**:
- 确认 App Group 配置正确
- 运行主应用至少一次
- 重新添加 Widget 到主屏幕

---

## 10. App Store 提交准备

### 10.1 创建 App Store Connect 记录

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **My Apps** → **+** → **New App**
3. 填写信息:
   - **Name**: AntiUV - UV Index Monitor
   - **Primary Language**: English
   - **Bundle ID**: 选择你的 Bundle ID
   - **SKU**: antiuv-001
   - **User Access**: Full Access

### 10.2 准备元数据

#### 应用描述:
```
AntiUV - Your Personal UV Index Monitor

Stay safe in the sun with real-time UV index tracking and smart sunscreen reminders!

KEY FEATURES:
✓ Real-time UV index from Apple WeatherKit
✓ Personalized sunscreen reapplication reminders
✓ Smart safety timer with countdown
✓ Fitzpatrick skin type support (I-VI)
✓ Activity-based recommendations
✓ iOS Widget for quick access
✓ HealthKit integration
✓ Siri Shortcuts support

PROTECT YOUR SKIN:
- Get accurate UV index for your location
- Receive timely reminders to reapply sunscreen
- Learn about sun safety and skin cancer prevention
- Track your UV exposure over time

PERFECT FOR:
- Outdoor enthusiasts
- Beach goers
- Athletes and runners
- Parents protecting their children
- Anyone concerned about skin health

PRIVACY:
- Your location data is used only for UV calculations
- No data is shared with third parties
- HealthKit data sync is optional

Download AntiUV today and take control of your sun safety!
```

#### 关键词:
```
UV index, sunscreen, sun protection, skin cancer, vitamin D, weather, health, fitness, outdoor, SPF
```

#### 截图尺寸要求:
- **6.7" (iPhone 14 Plus/14 Pro Max)**: 1290 x 2796 px
- **6.5" (iPhone 11/12/13/14 Pro)**: 1284 x 2778 px
- **5.5" (iPhone 8 Plus)**: 1242 x 2208 px

### 10.3 隐私标签

准备以下信息:

- **Data Used to Track You**: None
- **Data Linked to You**: 
  - Location (用于 UV 计算)
  - Health & Fitness (可选，HealthKit 同步)
- **Data Not Linked to You**: None

### 10.4 年龄分级

- **4+**: 无医疗建议，仅提供信息
- 或 **12+**: 如果包含皮肤癌信息

### 10.5 构建版本上传

1. 在 Xcode 中选择 **Any iOS Device**
2. **Product** → **Archive**
3. 在 Organizer 中点击 **Distribute App**
4. 选择 **App Store Connect**
5. 选择 **Upload**
6. 等待上传完成

### 10.6 提交审核

1. 在 App Store Connect 选择你的 App
2. 进入 **App Store** 标签
3. 选择刚上传的构建版本
4. 填写审核信息:
   - **Privacy Policy URL**: (需要提供)
   - **Support URL**: (需要提供)
5. 点击 **Add for Review**
6. 点击 **Submit to Review**

---

## 11. 测试清单

### 11.1 功能测试

- [ ] UV 指数正确显示
- [ ] 位置权限工作正常
- [ ] 通知权限工作正常
- [ ] 补涂提醒准时触发
- [ ] 定时器准确倒计时
- [ ] Profile 设置保存成功
- [ ] Widget 显示正确数据
- [ ] 教育内容可滚动查看
- [ ] 触觉反馈工作 (真机)

### 11.2 边界测试

- [ ] 无网络时显示错误
- [ ] 位置被拒绝时显示提示
- [ ] UV=0 (夜间) 显示正确
- [ ] UV>11 显示 Extreme
- [ ] 时区变化后通知调整
- [ ] 后台通知正常触发

### 11.3 性能测试

- [ ] 冷启动 < 2 秒
- [ ] UV 数据加载 < 3 秒
- [ ] 内存占用 < 100MB
- [ ] 电池消耗正常

### 11.4 设备兼容性

- [ ] iPhone 12 (iOS 17)
- [ ] iPhone 13 (iOS 17)
- [ ] iPhone 14 (iOS 17)
- [ ] iPhone 15 (iOS 17)
- [ ] 各种屏幕尺寸适配

---

## 12. 发布后维护

### 12.1 监控指标

- **崩溃率**: < 1%
- **用户评分**: 目标 4.5+
- **日活跃用户**: 跟踪增长
- **Widget 使用率**: 跟踪参与度

### 12.2 用户反馈

- 及时回复 App Store 评论
- 收集功能建议
- 修复报告的 bug

### 12.3 更新计划

- **每月**: 小修复和优化
- **每季度**: 新功能更新
- **每年**: 适配新 iOS 版本

---

## 📞 需要帮助？

### 官方文档

- [WeatherKit Documentation](https://developer.apple.com/documentation/weatherkit)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### 项目文档

- [us.md](us.md) - 完整技术指南
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - 项目总结
- [QUICKSTART.md](QUICKSTART.md) - 快速启动
- [PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md) - Phase 2 总结

---

**最后更新**: 2026-03-09  
**版本**: 1.0  
**状态**: ✅ 准备发布
