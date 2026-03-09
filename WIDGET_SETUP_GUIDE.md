# AntiUV iOS App - Widget 配置完整指南

## 📋 Widget 配置步骤

### 第一步：添加 Capabilities (主应用)

在 Xcode 中选择 **antiuv** Target → **Signing & Capabilities**:

#### 需要添加的 Capabilities:

1. **Push Notifications**
   - 点击 **+ Capability**
   - 搜索 "Push Notifications"
   - 添加

2. **HealthKit**
   - 点击 **+ Capability**
   - 搜索 "HealthKit"
   - 添加

3. **Background Modes**
   - 点击 **+ Capability**
   - 搜索 "Background Modes"
   - 添加后勾选:
     - ✅ Background fetch
     - ✅ Remote notifications

4. **App Groups** (Widget 数据共享)
   - 点击 **+ Capability**
   - 搜索 "App Groups"
   - 添加
   - 点击 **+** 创建 Group
   - 输入：`group.com.zzsutuo.antiuv`
   - 勾选创建的 Group

---

### 第二步：配置 Widget Target

#### 2.1 选择 Widget Target

1. 在 Xcode 左侧选择 **antiuvWidget** Target
2. 进入 **Signing & Capabilities** 标签

#### 2.2 配置 Signing

- **Automatically manage signing**: ✅ 勾选
- **Team**: 选择与主应用相同的 Team
- **Bundle Identifier**: `com.zzsutuo.antiuvWidget`

#### 2.3 添加 App Groups

1. 点击 **+ Capability**
2. 搜索 "App Groups"
3. 添加
4. **重要**: 勾选与主应用相同的 Group:
   - ✅ `group.com.zzsutuo.antiuv`

---

### 第三步：验证配置

#### 3.1 检查主应用

主应用的 **Signing & Capabilities** 应该包含:

```
✅ WeatherKit
✅ Push Notifications
✅ HealthKit
✅ Background Modes
   - Background fetch
   - Remote notifications
✅ App Groups
   - group.com.zzsutuo.antiuv
```

#### 3.2 检查 Widget

Widget 的 **Signing & Capabilities** 应该包含:

```
✅ App Groups
   - group.com.zzsutuo.antiuv
```

#### 3.3 检查 Info.plist

主应用的 Info.plist 应包含:

```xml
<!-- Location Permissions -->
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription

<!-- HealthKit Permissions -->
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription

<!-- Background Modes -->
UIBackgroundModes: [fetch, remote-notification]
```

---

### 第四步：测试 Widget

#### 4.1 运行 Widget

1. 在 Xcode 顶部选择 Scheme: **antiuvWidget**
2. 选择目标设备 (iPhone 16 Pro)
3. 按 **Cmd + R** 运行

#### 4.2 添加到主屏幕

**在真机上**:
1. 长按主屏幕空白处
2. 点击左上角 **+** 按钮
3. 搜索 "AntiUV"
4. 选择 Widget 尺寸
5. 点击 **Add Widget**
6. 点击 **Done**

**在模拟器上**:
- Widget 可能不显示实时数据
- 建议使用真机测试

---

### 第五步：数据共享配置

#### 5.1 主应用保存数据到 App Group

在 `WeatherKitService.swift` 或 `UVDataService.swift` 中添加:

```swift
import Foundation

class DataSharingService {
    static let shared = DataSharingService()
    
    private let userDefaults: UserDefaults
    
    init() {
        guard let groupUserDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv") else {
            fatalError("Unable to access App Group UserDefaults")
        }
        userDefaults = groupUserDefaults
    }
    
    func saveUVData(uvIndex: Double, uvLevel: String, location: String) {
        userDefaults.set(uvIndex, forKey: "uvIndex")
        userDefaults.set(uvLevel, forKey: "uvLevel")
        userDefaults.set(location, forKey: "location")
        userDefaults.set(Date(), forKey: "lastUpdated")
    }
    
    func getUVData() -> (uvIndex: Double, uvLevel: String, location: String)? {
        guard let uvIndex = userDefaults.double(forKey: "uvIndex") as Double?,
              let uvLevel = userDefaults.string(forKey: "uvLevel"),
              let location = userDefaults.string(forKey: "location") else {
            return nil
        }
        return (uvIndex, uvLevel, location)
    }
}
```

#### 5.2 Widget 读取数据

在 `antiuvWidget.swift` 的 `getSnapshot` 和 `getTimeline` 中:

```swift
func getTimeline(for context: Context, completion: @escaping (Timeline<UVWidgetEntry>) -> Void) {
    var entries: [UVWidgetEntry] = []
    
    let currentDate = Date()
    
    // 从 App Group 读取数据
    let userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv")
    let uvIndex = userDefaults?.double(forKey: "uvIndex") ?? 0.0
    let uvLevel = userDefaults?.string(forKey: "uvLevel") ?? "Unknown"
    let location = userDefaults?.string(forKey: "location") ?? "Loading..."
    
    let entry = UVWidgetEntry(
        date: currentDate,
        uvIndex: uvIndex,
        uvLevel: uvLevel,
        location: location
    )
    
    entries.append(entry)
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
}
```

---

### 第六步：更新主应用代码

#### 6.1 在 DashboardViewModel 中保存数据

修改 `DashboardViewModel.swift`:

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    // ... 现有代码 ...
    
    func refresh() async {
        do {
            let data = try await uvDataService.fetchUVData()
            await MainActor.run {
                self.uvData = data
                self.isLoading = false
                
                // 保存数据到 App Group (供 Widget 使用)
                DataSharingService.shared.saveUVData(
                    uvIndex: data.uvIndex,
                    uvLevel: data.uvLevel,
                    location: data.location
                )
            }
        } catch {
            // ... 错误处理 ...
        }
    }
}
```

---

### 第七步：测试清单

#### 功能测试
- [ ] 主应用能正常获取 UV 数据
- [ ] Widget 显示正确的 UV 指数
- [ ] Widget 颜色编码正确 (根据 UV 等级)
- [ ] Widget 显示位置信息
- [ ] 数据更新后 Widget 同步更新

#### 配置测试
- [ ] 主应用和 Widget 使用相同的 App Group
- [ ] Info.plist 权限配置完整
- [ ] Background Modes 已启用
- [ ] 真机测试 Widget

---

### 常见问题

#### ❌ Widget 不显示数据
**原因**: App Group 配置不正确
**解决**:
1. 检查主应用和 Widget 的 App Group 是否一致
2. 确认 Group 名称：`group.com.zzsutuo.antiuv`
3. 重新运行主应用和 Widget

#### ❌ Widget 显示 "No Data"
**原因**: 主应用未保存数据
**解决**:
1. 运行主应用至少一次
2. 确保 UV 数据获取成功
3. 检查 `DataSharingService` 是否调用

#### ❌ Widget 颜色不对
**原因**: UV 等级判断逻辑问题
**解决**: 检查 `antiuvWidget.swift` 中的颜色判断代码

#### ❌ 编译错误 "App Group not found"
**原因**: App Group 未创建
**解决**:
1. 在 Apple Developer 网站创建 App Group
2. 下载最新的 Provisioning Profile
3. 在 Xcode 重新选择 Team

---

### 完整配置截图

#### 主应用 Capabilities:
```
Signing & Capabilities:
├─ Signing
│  ├─ Automatically manage signing: ✅
│  └─ Team: he zhou
├─ WeatherKit
├─ Push Notifications
├─ HealthKit
├─ Background Modes
│  ├─ Background fetch: ✅
│  └─ Remote notifications: ✅
└─ App Groups
   └─ group.com.zzsutuo.antiuv: ✅
```

#### Widget Capabilities:
```
Signing & Capabilities:
├─ Signing
│  ├─ Automatically manage signing: ✅
│  └─ Team: he zhou
└─ App Groups
   └─ group.com.zzsutuo.antiuv: ✅
```

---

### 下一步

完成配置后:

1. ✅ 运行主应用 (Cmd+R)
2. ✅ 允许所有权限 (位置、通知、HealthKit)
3. ✅ 运行 Widget (选择 antiuvWidget scheme)
4. ✅ 在真机上添加 Widget 到主屏幕
5. ✅ 测试数据同步

---

**配置完成！现在可以开始测试 Widget 了！🎉**
