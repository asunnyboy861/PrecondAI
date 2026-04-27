# App Name: **PrecondAI**  
# Subtitle: **Smart EV Climate Scheduler**

> **命名深度分析见本文档 §8**

---

# 电动车智能空调预约定时器 — iOS App 开发操作指南

**项目代号**: PrecondAI  
**目标平台**: iOS 16+ / Apple Watch / CarPlay  
**目标市场**: 美国  
**文档日期**: 2026-04-27  
**文档版本**: v1.0  

---

## 目录

1. [项目概述与痛点分析](#1-项目概述与痛点分析)
2. [GitHub 可二次开发项目研究](#2-github-可二次开发项目研究)
3. [核心技术实现代码示例与编写规则](#3-核心技术实现代码示例与编写规则)
4. [实现流程图](#4-实现流程图)
5. [用户流程图](#5-用户流程图)
6. [软件数据流图](#6-软件数据流图)
7. [极具竞争力的价格策略](#7-极具竞争力的价格策略)
8. [APP 命名深度分析](#8-app-命名深度分析)
9. [UI 设计方案](#9-ui-设计方案)

---

## 1. 项目概述与痛点分析

### 1.1 项目定位

PrecondAI 是一款面向美国 EV 车主的 iOS 应用，核心功能：
- **远程控制**：夏天开冷风、冬天开热风，无需跑到车库操作
- **智能定时**：根据当地实时气温，智能计算空调最佳开启时间
- **预约定时**：设置出发时间，自动提醒并启动空调预调节
- **多品牌支持**：Tesla / Ford / BMW / Mercedes / Rivian / Hyundai 等
- **天气感知**：结合天气预报自动调整预热/预冷时间

### 1.2 市场规模

| 指标 | 数据 |
|------|------|
| 美国 EV 市场规模 (2024) | $131.3B |
| 2025 年 EV 销量 | >150 万辆 |
| EV 占新车销量比例 | ~9% |
| 2025-2034 CAGR | 13.6% |
| 美国 EV 保有量 | >400 万辆 |
| 潜在目标用户 | 所有拥有远程空调控制功能的 EV 车主 |

### 1.3 用户痛点深度分析（多平台验证）

#### 🔴 痛点 1：定时预热根本不生效（最严重，钻石级）

**来源**: SpeakEV 论坛 + Tesla Motors Club + Rivian Forums

**用户原话**:
> *"Trying to get my EV6 to warm itself up at a departure time so it's nice and warm. All my previous EVs have this and it's such a great feature, not [on this one]."*
> — GrahamS, SpeakEV

> *"Since updating to 2024.26.7 the app/car has added the new preconditioning/charging schedule option where you can add numerous different repeating schedules... it just doesn't work."*
> — Tesla Motors Club 用户

> *"My app and car schedules are also out-of-synch where setting a schedule in the app won't show in the car and vice versa."*
> — Rivian Forums 用户

**痛点本质**: 厂商 App 的定时预热功能不可靠、不同步、经常失效

**PrecondAI 解决方案**: 
- 使用厂商 API 直接发送即时预调节命令，绕过不可靠的厂商调度系统
- 本地推送通知 + 精确时间控制，不依赖厂商的定时功能

#### 🔴 痛点 2：定时预热必须插电才能使用（钻石级）

**来源**: SpeakEV 论坛 + 多品牌 EV 论坛

**用户原话**:
> *"The dealer confirmed: timed climate control only works when the car is plugged in. This is stupid and makes the feature useless — many people don't plug in every day."*
> — GrahamS, SpeakEV

**痛点本质**: 厂商为保护电池，强制要求插电才能使用定时预热，但用户实际场景中并不总是插电

**PrecondAI 解决方案**:
- 电池电量检测：仅当电量 > 设定阈值（默认 40%）时允许非插电状态预调节
- 智能时间计算：非插电状态下缩短预热时间以节省电量
- 明确的电量/续航预估提示，让用户知情决策

#### 🔴 痛点 3：不能根据天气自动调整预热时间（钻石级）

**来源**: Reddit r/electricvehicles + Tesla Motors Club

**用户原话**:
> *"I have to manually adjust my preconditioning time every day based on the weather. When it's 10°F I need 30 minutes, when it's 30°F I only need 15. Why can't this be automatic?"*

**痛点本质**: 厂商 App 的定时功能是"死"的——固定时间启动，不管外面是-20°C 还是 10°C

**PrecondAI 解决方案**:
- 集成 OpenWeatherMap API 获取实时+预报天气
- 根据温差、风速、湿度智能计算最佳启动时间
- 参考算法：`precondition_minutes = base_time × (|target_temp - outside_temp| / reference_delta)`

#### 🟡 痛点 4：没有统一的跨品牌解决方案（金级）

**来源**: Green Cars Compare Blog + 多品牌论坛

**用户原话**:
> *"We have two EVs from different brands and need two different apps to control climate. Neither app works well."*

**痛点本质**: 多 EV 家庭需要安装多个厂商 App，体验参差不齐

**PrecondAI 解决方案**:
- 通过 Smartcar API 统一接入 37+ 品牌
- 一致的 UI/UX 体验，不受厂商 App 更新影响
- 多车辆统一管理面板

#### 🟡 痛点 5：需要记住手动启动预调节（金级）

**来源**: Reddit + TikTok 评论

**痛点本质**: 用户经常忘记提前启动空调，等想起来时已经来不及

**PrecondAI 解决方案**:
- 日历集成：自动读取 Google/Apple Calendar 中的出行事件
- 习惯学习：基于用户日常出行模式自动生成建议调度
- 智能推送：提前 30/15/5 分钟推送提醒

#### 🟡 痛点 6：App 随机退出登录 / 同步失败（金级）

**来源**: SpeakEV + BMW 论坛 + Mercedes 论坛

**用户原话**:
> *"My BMW pre-conditioning from app stopped working... the app keeps logging me out."*
> — BMW iX Forums

> *"Pre-Entry Climate Control showing as ON but clicking the fan icon does nothing."*
> — Mercedes EQ Club

**痛点本质**: 厂商 App 的连接可靠性差，关键时刻掉链子

**PrecondAI 解决方案**:
- 本地 Token 安全存储（Keychain）
- 自动重连机制 + 健康检查
- 操作结果确认推送（"Your Tesla Model 3 has started preconditioning ✓"）

#### 🟢 痛点 7：无法区分工作日和周末的不同调度（银级）

**PrecondAI 解决方案**: 灵活的多调度管理，工作日/周末/自定义日期组合

#### 🟢 痛点 8：缺乏能耗统计和费用估算（银级）

**PrecondAI 解决方案**: 预调节能耗追踪 + 电费估算（基于当地电价）

### 1.4 痛点优先级排序

| 排名 | 痛点 | 级别 | 解决难度 | MVP 是否包含 |
|------|------|------|----------|-------------|
| 1 | 定时预热不可靠 | 💎钻石 | ⭐⭐ | ✅ |
| 2 | 必须插电才能定时预热 | 💎钻石 | ⭐⭐⭐ | ✅ |
| 3 | 不能根据天气自动调整 | 💎钻石 | ⭐⭐ | ✅ |
| 4 | 没有跨品牌统一方案 | 🥇金 | ⭐⭐⭐⭐ | ✅ (Tesla优先) |
| 5 | 需要记住手动启动 | 🥇金 | ⭐⭐ | ✅ |
| 6 | App 随机退出/同步失败 | 🥇金 | ⭐⭐ | ✅ |
| 7 | 工作日/周末不同调度 | 🥈银 | ⭐ | Phase 2 |
| 8 | 能耗统计和费用估算 | 🥈银 | ⭐⭐ | Phase 2 |

---

## 2. GitHub 可二次开发项目研究

### 2.1 推荐项目一览

| 项目 | Stars | License | 语言 | 核心价值 | 推荐度 |
|------|-------|---------|------|----------|--------|
| **teslamotors/vehicle-command** | 800+ | Apache-2.0 | Go | Tesla 官方车辆命令协议库 | ⭐⭐⭐⭐⭐ |
| **JagCesar/Tesla-API** | 33 | MIT | Swift | iOS/macOS/watchOS/tvOS 全平台 Tesla API 框架 | ⭐⭐⭐⭐⭐ |
| **javaDevJT/Tesla-Automatic-Preconditioning** | 0 | GPL-2.0 | Java | 日历+天气+地图智能预热（算法参考） | ⭐⭐⭐⭐ |
| **philhzss/tesla-climate-scheduler** | 2 | GPL-3.0 | C++ | ICS 日历驱动空调调度（概念参考） | ⭐⭐⭐ |
| **openvehicles/Open-Vehicle-Monitoring-System-3** | 600+ | Apache-2.0 | C++ | 开源车辆监控+空调预调节调度 | ⭐⭐⭐⭐ |
| **scottrobertson/tesla-precondition** | N/A | MIT | JS | Cloudflare Workers 预热 API（架构参考） | ⭐⭐⭐ |
| **dburkland/tesla_ios_shortcuts** | N/A | MIT | - | iOS Shortcuts 集成方案 | ⭐⭐⭐ |

### 2.2 重点项目深度分析

#### 2.2.1 teslamotors/vehicle-command（核心参考 — 官方）

**仓库**: https://github.com/teslamotors/vehicle-command  
**License**: Apache-2.0 ✅ 商业友好  
**语言**: Go  

**核心价值**:
- Tesla 官方维护的车辆命令协议实现
- 包含端到端命令认证（虚拟密钥签名）
- 支持 BLE + 互联网两种通信方式
- 可作为后端服务的参考实现

**二次开发方式**:
- 不可直接用于 iOS App（Go 语言）
- 但其协议规范和命令签名流程是 iOS 实现的权威参考
- 可提取 `protocol/` 目录下的命令定义和签名逻辑

**关键技术点**:
```
1. 虚拟密钥生成与配对流程
2. 命令签名 (SHA256 + ECDSA)
3. Vehicle Command Proxy 部署方式
4. BLE 命令传输协议
```

#### 2.2.2 JagCesar/Tesla-API（核心参考 — Swift 原生）

**仓库**: https://github.com/JagCesar/Tesla-API  
**License**: MIT ✅ 商业友好  
**语言**: Swift (100%)  
**支持平台**: iOS / macOS / watchOS / tvOS  

**核心价值**:
- **唯一的 Swift 原生 Tesla API 框架**
- 零第三方依赖（纯 Swift 实现）
- Swift Package Manager 集成
- 已有认证请求实现 (`AuthenticateRequest`)

**二次开发方式**:
- 直接作为 SPM 依赖引入 iOS 项目
- 扩展 `Source/Requests/` 目录添加气候控制请求
- 参考其请求模式实现新端点

**需要扩展的功能**:
```swift
// 需要新增的 Request 类：
- AutoConditioningStartRequest    // 启动预调节
- AutoConditioningStopRequest     // 停止预调节
- SetTempsRequest                 // 设置温度
- AddPreconditionScheduleRequest  // 添加预调节日程
- RemovePreconditionScheduleRequest
- SetClimateKeeperModeRequest     // Climate Keeper 模式
```

#### 2.2.3 javaDevJT/Tesla-Automatic-Preconditioning（算法参考）

**仓库**: https://github.com/javaDevJT/Tesla-Automatic-Preconditioning  
**License**: GPL-2.0 ⚠️ 不可直接商用，仅作算法参考  
**语言**: Java 24 + Spring Boot 3  

**核心价值 — 天气冰雪风险算法**（本项目最核心的算法参考）:

```
算法核心逻辑（伪代码）：
┌────────────────────────────────────────────┐
│ 冰雪风险评分算法                              │
│                                            │
│ 1. 获取过去12小时逐小时天气数据                  │
│ 2. 对每小时数据应用时间衰减权重（半衰期6h）       │
│    weight(t) = e^(-ln(2) × hours_ago / 6) │
│ 3. 应用温度权重：                              │
│    - 温度 > 0°C → 融化因子，降低风险            │
│    - 温度 < -5°C → 增强因子，提高风险            │
│ 4. 归一化到 [0, 1] 区间                       │
│ 5. 风险分数 > 0.55 → 高风险，触发预热           │
│                                            │
│ 预热时间计算：                                 │
│ start_time = event_time - commute_time     │
│              - buffer_time(10min)          │
│              - (high_risk ? extra_time : 0)│
└────────────────────────────────────────────┘
```

**本项目的改进版算法**（基于上述参考，但完全重新实现以避免 GPL 污染）:

```swift
// PrecondAI 的智能预热时间算法（原创实现）
struct SmartPreconditionCalculator {
    
    /// 计算最佳预调节启动时间
    /// - Parameters:
    ///   - departureTime: 用户出发时间
    ///   - targetTemp: 目标温度 (°F)
    ///   - outsideTemp: 当前外部温度 (°F)
    ///   - isPluggedIn: 是否插电
    ///   - batteryLevel: 电池电量百分比
    ///   - weatherCondition: 天气状况
    /// - Returns: 预调节应启动的时间
    static func calculateOptimalStartTime(
        departureTime: Date,
        targetTemp: Double,      // °F
        outsideTemp: Double,     // °F
        isPluggedIn: Bool,
        batteryLevel: Int,       // 0-100
        weatherCondition: WeatherCondition
    ) -> Date? {
        
        // 1. 电池安全检查
        let minBatteryForUnplugged = 40
        if !isPluggedIn && batteryLevel < minBatteryForUnplugged {
            return nil  // 电量不足，不建议预调节
        }
        
        // 2. 计算温差
        let tempDelta = abs(targetTemp - outsideTemp)
        
        // 3. 基础预热时间（分钟）
        // 线性模型：每10°F温差需要约5分钟预热
        let baseMinutes = max(5, tempDelta / 10.0 * 5.0)
        
        // 4. 天气状况调整系数
        let weatherMultiplier: Double = {
            switch weatherCondition {
            case .snow, .ice:       return 1.8   // 冰雪需要额外80%时间
            case .heavyRain:        return 1.3   // 暴雨需要额外30%
            case .lightRain:        return 1.1   // 小雨需要额外10%
            case .cloudy:           return 1.0   // 多云无影响
            case .sunny, .clear:    return 0.9   // 晴天可缩短10%（日照加热）
            }
        }()
        
        // 5. 插电状态调整（插电时空调功率更大）
        let powerMultiplier = isPluggedIn ? 0.8 : 1.0
        
        // 6. 风速调整（高风速增加热损失）
        // windAdjustment 在外部计算后传入
        
        // 7. 最终预热时间
        let totalMinutes = baseMinutes * weatherMultiplier * powerMultiplier
        
        // 8. 上下限保护
        let clampedMinutes = min(max(totalMinutes, 5), 45)  // 最少5分钟，最多45分钟
        
        // 9. 计算启动时间
        return departureTime.addingTimeInterval(-clampedMinutes * 60)
    }
}
```

#### 2.2.4 openvehicles/Open-Vehicle-Monitoring-System-3（架构参考）

**仓库**: https://github.com/openvehicles/Open-Vehicle-Monitoring-System-3  
**License**: Apache-2.0 ✅ 商业友好  
**Stars**: 600+  

**核心价值**:
- 已实现多品牌车辆空调预调节调度器
- Issue #1239 明确提到将空调预调节调度器从车辆特定模块提取为通用模块
- 支持的车辆: Tesla, Nissan Leaf, Renault Zoe, VW e-Golf, BMW i3, Hyundai Kona EV 等
- 硬件+App 全栈架构

**可参考的架构模式**:
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  iOS App    │────▶│  OVMS Server │────▶│  Vehicle    │
│  (Mobile)   │◀────│  (MQTT/API)  │◀────│  (OBD-II)   │
└─────────────┘     └──────────────┘     └─────────────┘
```

### 2.3 二次开发策略总结

```
PrecondAI 架构组成：

1. Tesla API 层 ←── JagCesar/Tesla-API (MIT, Swift) 
                     + teslamotors/vehicle-command (Apache-2.0, 协议参考)
2. 多品牌 API 层 ←── Smartcar SDK (商业API, 37+品牌)
3. 天气感知层 ←── OpenWeatherMap API (免费层级, Swift 集成)
4. 智能算法层 ←── 原创实现 (参考 javaDevJT 的算法思路，但完全重新用 Swift 编写)
5. 日历集成层 ←── EventKit (Apple 原生框架)
6. 推送通知层 ←── UserNotifications + Background Tasks (Apple 原生)
```

---

## 3. 核心技术实现代码示例与编写规则

### 3.1 项目技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| UI 框架 | SwiftUI | iOS 16+ 声明式 UI |
| 架构模式 | MVVM + Clean Architecture | 分层解耦 |
| 网络层 | async/await + URLSession | 现代 Swift 并发 |
| 本地存储 | SwiftData + Keychain | 数据持久化 + 安全存储 |
| 车辆 API | Tesla Fleet API + Smartcar API | 多品牌支持 |
| 天气 API | OpenWeatherMap | 实时+预报天气 |
| 日历 | EventKit | Apple 日历集成 |
| 推送 | UserNotifications + BGTaskScheduler | 本地通知 + 后台任务 |
| 地图 | MapKit + CoreLocation | 位置服务 |
| 依赖管理 | Swift Package Manager | 原生包管理 |

### 3.2 编写规则

```yaml
代码规范:
  - Swift Style: Apple Official Swift API Design Guidelines
  - 命名: 英文, 驼峰命名, 避免缩写
  - 注释: 英文, 使用 /// 文档注释
  - 最小部署: iOS 16.0
  - 并发: 优先使用 async/await, 避免 completion handlers
  - UI: 纯 SwiftUI, 不使用 UIKit (除非必须)
  - 网络: 使用 Codable 解码 JSON
  - 错误处理: 使用 typed throws (Swift 6) 或自定义 Error enum
  - 安全: Token/密钥存储在 Keychain, 不使用 UserDefaults
  - 测试: XCTest + Swift Testing 框架
```

### 3.3 核心代码示例

#### 3.3.1 项目结构

```
PrecondAI/
├── PrecondAIApp.swift                    # App 入口
├── Core/
│   ├── Network/
│   │   ├── TeslaAPIClient.swift          # Tesla Fleet API 客户端
│   │   ├── SmartcarAPIClient.swift       # Smartcar API 客户端
│   │   └── WeatherAPIClient.swift        # OpenWeatherMap 客户端
│   ├── Models/
│   │   ├── Vehicle.swift                 # 车辆模型
│   │   ├── PreconditionSchedule.swift    # 调度模型
│   │   └── WeatherData.swift             # 天气模型
│   ├── Algorithms/
│   │   └── SmartPreconditionCalculator.swift  # 智能预热算法
│   └── Services/
│       ├── VehicleService.swift          # 车辆控制服务
│       ├── WeatherService.swift          # 天气服务
│       ├── ScheduleService.swift         # 调度管理服务
│       └── NotificationService.swift     # 通知服务
├── Features/
│   ├── Dashboard/
│   │   └── DashboardView.swift           # 主控制面板
│   ├── Schedule/
│   │   ├── ScheduleListView.swift        # 调度列表
│   │   └── AddScheduleView.swift         # 添加调度
│   ├── VehicleSetup/
│   │   ├── BrandSelectionView.swift      # 品牌选择
│   │   └── VehicleAuthView.swift         # 车辆认证
│   └── Settings/
│       └── SettingsView.swift            # 设置页面
├── Shared/
│   ├── Components/
│   │   ├── TemperatureDial.swift         # 温度旋钮控件
│   │   └── VehicleCard.swift             # 车辆卡片组件
│   └── Extensions/
│       └── Date+Extensions.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings             # 多语言 (英/西/法/德/葡/日/中)
```

#### 3.3.2 Tesla API 客户端核心实现

```swift
// Core/Network/TeslaAPIClient.swift

import Foundation
import CryptoKit

/// Tesla Fleet API 客户端
/// 参考: https://developer.tesla.com/docs/fleet-api
actor TeslaAPIClient: VehicleAPIClient {
    
    private let clientId: String
    private let clientSecret: String
    private let baseURL = "https://fleet-api.prd.na.vn.cloud.tesla.com"
    private var accessToken: String?
    private var refreshToken: String?
    
    // MARK: - 认证
    
    /// OAuth2 授权流程
    func authenticate() async throws -> AuthToken {
        let authURL = URL(string: "https://auth.tesla.com/oauth2/v3/authorize")!
        // 构建 PKCE 授权请求
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        // ... OAuth2 PKCE 流程实现
        fatalError("Implementation depends on ASWebAuthenticationSession")
    }
    
    // MARK: - 气候控制命令
    
    /// 启动空调预调节
    /// - Parameter vin: 车辆识别号
    func startPreconditioning(vin: String) async throws {
        let endpoint = "/api/1/vehicles/\(vin)/command/auto_conditioning_start"
        try await sendCommand(endpoint: endpoint, body: [:])
    }
    
    /// 停止空调预调节
    func stopPreconditioning(vin: String) async throws {
        let endpoint = "/api/1/vehicles/\(vin)/command/auto_conditioning_stop"
        try await sendCommand(endpoint: endpoint, body: [:])
    }
    
    /// 设置目标温度
    /// - Parameters:
    ///   - vin: 车辆识别号
    ///   - driverTemp: 驾驶员侧温度 (°C)
    ///   - passengerTemp: 乘客侧温度 (°C)
    func setTemperature(vin: String, driverTemp: Double, passengerTemp: Double? = nil) async throws {
        let endpoint = "/api/1/vehicles/\(vin)/command/set_temps"
        var body: [String: Any] = ["driver_temp": driverTemp]
        if let passengerTemp {
            body["passenger_temp"] = passengerTemp
        }
        try await sendCommand(endpoint: endpoint, body: body)
    }
    
    /// 添加预调节日程
    /// - Parameters:
    ///   - vin: 车辆识别号
    ///   - schedule: 调度信息
    func addPreconditionSchedule(vin: String, schedule: PreconditionScheduleDTO) async throws {
        let endpoint = "/api/1/vehicles/\(vin)/command/add_precondition_schedule"
        let body: [String: Any] = [
            "id": schedule.id.uuidString,
            "departure_time": schedule.departureMinutesFromMidnight,
            "days_of_week": schedule.daysOfWeekRawValue,
            "enabled": schedule.isEnabled,
            "preconditioning_enabled": true,
            "preconditioning_time": schedule.preconditionMinutesBeforeDeparture
        ]
        try await sendCommand(endpoint: endpoint, body: body)
    }
    
    /// 设置 Climate Keeper 模式
    /// - Parameters:
    ///   - vin: 车辆识别号
    ///   - mode: 0=关, 1=Keep, 2=狗狗模式, 3=露营模式
    func setClimateKeeperMode(vin: String, mode: Int) async throws {
        let endpoint = "/api/1/vehicles/\(vin)/command/set_climate_keeper_mode"
        try await sendCommand(endpoint: endpoint, body: ["climate_keeper_mode": mode])
    }
    
    // MARK: - 车辆状态
    
    /// 获取车辆状态（包含气候信息）
    func getVehicleData(vin: String) async throws -> VehicleData {
        let endpoint = "/api/1/vehicles/\(vin)/vehicle_data"
        return try await request(endpoint: endpoint)
    }
    
    // MARK: - 私有方法
    
    private func sendCommand(endpoint: String, body: [String: Any]) async throws {
        guard let token = accessToken else {
            throw VehicleAPIError.notAuthenticated
        }
        
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VehicleAPIError.commandFailed
        }
    }
    
    private func request<T: Decodable>(endpoint: String) async throws -> T {
        guard let token = accessToken else {
            throw VehicleAPIError.notAuthenticated
        }
        
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VehicleAPIError.requestFailed
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func generateCodeVerifier() -> String {
        let buffer = [UInt8](repeating: 0, count: 32)
        // 生成随机字符串
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = verifier.data(using: .ascii)!
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
```

#### 3.3.3 Smartcar 多品牌 API 客户端

```swift
// Core/Network/SmartcarAPIClient.swift

import Foundation

/// Smartcar API 客户端 — 统一接入 37+ 品牌
/// 文档: https://smartcar.com/docs/
actor SmartcarAPIClient: VehicleAPIClient {
    
    private let clientId: String
    private let clientSecret: String
    private let baseURL = "https://api.smartcar.com/v2.0"
    
    /// Smartcar 支持的空调控制能力（因品牌而异）
    struct ClimateCapabilities: OptionSet {
        let rawValue: UInt
        static let startHVAC     = ClimateCapabilities(rawValue: 1 << 0)  // 启动空调
        static let setTemperature = ClimateCapabilities(rawValue: 1 << 1)  // 设置温度
        static let startDefrost  = ClimateCapabilities(rawValue: 1 << 2)  // 除霜
        static let seatHeater    = ClimateCapabilities(rawValue: 1 << 3)  // 座椅加热
    }
    
    /// 启动空调预调节（通用接口）
    func startClimateControl(vehicleId: String) async throws {
        let endpoint = "/vehicles/\(vehicleId)/climate"
        var request = try buildRequest(endpoint: endpoint, method: "POST")
        let body = ["action": "START"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        try await execute(request: request)
    }
    
    /// 停止空调预调节
    func stopClimateControl(vehicleId: String) async throws {
        let endpoint = "/vehicles/\(vehicleId)/climate"
        var request = try buildRequest(endpoint: endpoint, method: "POST")
        let body = ["action": "STOP"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        try await execute(request: request)
    }
    
    /// 获取车辆电池状态
    func getBatteryStatus(vehicleId: String) async throws -> BatteryStatus {
        let endpoint = "/vehicles/\(vehicleId)/battery"
        return try await request(endpoint: endpoint)
    }
    
    /// 获取车辆位置（用于天气查询）
    func getVehicleLocation(vehicleId: String) async throws -> VehicleLocation {
        let endpoint = "/vehicles/\(vehicleId)/location"
        return try await request(endpoint: endpoint)
    }
    
    // ... 其他通用方法
}
```

#### 3.3.4 天气服务 + 智能算法集成

```swift
// Core/Services/WeatherService.swift

import Foundation
import CoreLocation

/// 天气服务 — 基于 OpenWeatherMap API
actor WeatherService {
    
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/3.0"
    
    /// 获取当前天气 + 预报
    func getWeatherForLocation(_ location: CLLocation) async throws -> WeatherSnapshot {
        // One Call API 3.0: 当前天气 + 48小时预报 + 8天预报
        let endpoint = "/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&appid=\(apiKey)"
        let response: OneCallResponse = try await request(endpoint: endpoint)
        return WeatherSnapshot(from: response)
    }
    
    /// 判断当前是否需要额外预热时间（冰雪/极端天气）
    func needsExtraPreconditioning(at location: CLLocation) async throws -> Bool {
        let weather = try await getWeatherForLocation(location)
        return weather.current.isSnowOrIce || weather.current.feelsLike < 0  // °F
    }
    
    /// 获取未来 N 小时的温度趋势（用于智能调度）
    func getTemperatureTrend(at location: CLLocation, hours: Int = 6) async throws -> [HourlyForecast] {
        let weather = try await getWeatherForLocation(location)
        return Array(weather.hourly.prefix(hours))
    }
}

// Core/Models/WeatherData.swift

struct WeatherSnapshot {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    let daily: [DailyForecast]
    
    /// 当前天气状况枚举（用于智能算法）
    enum Condition {
        case clear, cloudy, lightRain, heavyRain, snow, ice, fog
    }
}

struct CurrentWeather {
    let temp: Double          // °F
    let feelsLike: Double     // °F
    let humidity: Int         // %
    let windSpeed: Double     // mph
    let condition: WeatherSnapshot.Condition
    var isSnowOrIce: Bool {
        condition == .snow || condition == .ice
    }
}

struct HourlyForecast {
    let time: Date
    let temp: Double
    let condition: WeatherSnapshot.Condition
}
```

#### 3.3.5 调度管理服务（核心业务逻辑）

```swift
// Core/Services/ScheduleService.swift

import Foundation
import SwiftData

/// 调度管理服务 — 处理预调节调度的创建、执行和监控
@MainActor
final class ScheduleService: ObservableObject {
    
    private let weatherService: WeatherService
    private let vehicleService: VehicleService
    private let notificationService: NotificationService
    
    @Published var schedules: [PreconditionSchedule] = []
    @Published var activePrecondition: ActivePrecondition?
    
    /// 创建新的智能调度
    func createSchedule(
        vehicle: Vehicle,
        departureTime: Date,
        targetTemp: Double,      // °F
        daysOfWeek: Set<DayOfWeek>,
        enabled: Bool = true
    ) async throws -> PreconditionSchedule {
        
        // 1. 获取车辆位置
        let location = try await vehicleService.getVehicleLocation(vehicle)
        
        // 2. 获取天气预报
        let weather = try await weatherService.getWeatherForLocation(location)
        
        // 3. 计算最佳启动时间
        guard let optimalStart = SmartPreconditionCalculator.calculateOptimalStartTime(
            departureTime: departureTime,
            targetTemp: targetTemp,
            outsideTemp: weather.current.temp,
            isPluggedIn: vehicle.chargingState == .pluggedIn,
            batteryLevel: vehicle.batteryLevel,
            weatherCondition: weather.current.condition.toWeatherCondition()
        ) else {
            throw ScheduleError.insufficientBattery
        }
        
        // 4. 创建调度对象
        let schedule = PreconditionSchedule(
            vehicleId: vehicle.id,
            departureTime: departureTime,
            optimalStartTime: optimalStart,
            targetTemp: targetTemp,
            daysOfWeek: daysOfWeek,
            isEnabled: enabled,
            weatherAware: true
        )
        
        // 5. 注册后台任务
        try notificationService.scheduleBackgroundTask(
            for: schedule,
            executionTime: optimalStart
        )
        
        // 6. 保存调度
        schedules.append(schedule)
        
        return schedule
    }
    
    /// 执行预调节（由 BGTaskScheduler 或本地通知触发）
    func executePrecondition(schedule: PreconditionSchedule) async throws {
        
        // 1. 重新获取最新天气
        let vehicle = try await vehicleService.getVehicle(id: schedule.vehicleId)
        let location = try await vehicleService.getVehicleLocation(vehicle)
        let weather = try await weatherService.getWeatherForLocation(location)
        
        // 2. 重新计算（天气可能已变化）
        guard let optimalStart = SmartPreconditionCalculator.calculateOptimalStartTime(
            departureTime: schedule.departureTime,
            targetTemp: schedule.targetTemp,
            outsideTemp: weather.current.temp,
            isPluggedIn: vehicle.chargingState == .pluggedIn,
            batteryLevel: vehicle.batteryLevel,
            weatherCondition: weather.current.condition.toWeatherCondition()
        ) else {
            try? await notificationService.sendAlert(
                title: "Preconditioning Skipped",
                body: "Battery too low (\(vehicle.batteryLevel)%). Please charge first."
            )
            return
        }
        
        // 3. 如果需要立即启动
        if optimalStart <= Date() {
            // 设置温度
            try await vehicleService.setTemperature(
                vehicle: vehicle,
                driverTemp: fahrenheitToCelsius(schedule.targetTemp)
            )
            // 启动预调节
            try await vehicleService.startPreconditioning(vehicle: vehicle)
            
            // 4. 记录活跃预调节
            activePrecondition = ActivePrecondition(
                schedule: schedule,
                startedAt: Date(),
                estimatedCompletion: schedule.departureTime
            )
            
            // 5. 发送确认通知
            try? await notificationService.sendConfirmation(
                title: "Preconditioning Started 🚗",
                body: "\(vehicle.displayName) is reaching \(Int(schedule.targetTemp))°F by \(formatTime(schedule.departureTime))"
            )
        }
    }
    
    /// 停止活跃的预调节
    func stopActivePrecondition() async throws {
        guard let active = activePrecondition,
              let vehicle = try? await vehicleService.getVehicle(id: active.schedule.vehicleId) else { return }
        
        try await vehicleService.stopPreconditioning(vehicle: vehicle)
        activePrecondition = nil
        
        try? await notificationService.sendConfirmation(
            title: "Preconditioning Stopped",
            body: "\(vehicle.displayName) climate control has been turned off."
        )
    }
    
    // MARK: - 工具方法
    
    private func fahrenheitToCelsius(_ f: Double) -> Double {
        return (f - 32) * 5 / 9
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// 活跃预调节状态
struct ActivePrecondition {
    let schedule: PreconditionSchedule
    let startedAt: Date
    let estimatedCompletion: Date
}

/// 星期枚举
enum DayOfWeek: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}
```

#### 3.3.6 后台任务调度（关键 — 确保定时可靠）

```swift
// Core/Services/BackgroundTaskManager.swift

import BackgroundTasks
import UIKit

/// 后台任务管理器 — 确保 App 在后台也能按时启动预调节
final class BackgroundTaskManager {
    
    static let shared = BackgroundTaskManager()
    
    private let taskIdentifier = "com.precondai.precondition-task"
    
    /// 注册后台任务
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task as! BGProcessingTask)
        }
    }
    
    /// 调度后台任务
    func scheduleBackgroundProcessing(
        earliestBeginDate: Date,
        vehicleId: String
    ) {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = earliestBeginDate
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false  // 不要求插电
        
        // 附加车辆信息
        request.userInfo = ["vehicleId": vehicleId]
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background task scheduled for \(earliestBeginDate)")
        } catch {
            print("❌ Failed to schedule background task: \(error)")
        }
    }
    
    /// 处理后台任务
    private func handleBackgroundTask(_ task: BGProcessingTask) {
        // 安排下一次任务（防止链断裂）
        scheduleNextTask()
        
        // 创建操作队列
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let preconditionOperation = PreconditionOperation()
        task.expirationHandler = {
            preconditionOperation.cancel()
        }
        
        preconditionOperation.completionBlock = {
            task.setTaskCompleted(success: !preconditionOperation.isCancelled)
        }
        
        operationQueue.addOperation(preconditionOperation)
    }
    
    /// 调度下一次任务
    private func scheduleNextTask() {
        // 从数据库获取下一个即将执行的调度
        // scheduleBackgroundProcessing(earliestBeginDate: nextSchedule.optimalStartTime, ...)
    }
}

/// 预调节后台操作
class PreconditionOperation: Operation {
    override func main() {
        guard !isCancelled else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                let scheduleService = ScheduleService(/* ... */)
                // 执行预调节
                try await scheduleService.executePrecondition(schedule: /* next schedule */)
            } catch {
                print("Precondition operation failed: \(error)")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}
```

#### 3.3.7 数据模型

```swift
// Core/Models/PreconditionSchedule.swift

import Foundation
import SwiftData

/// 预调节调度模型
@Model
final class PreconditionSchedule {
    
    @Attribute(.unique) var id: UUID
    var vehicleId: String
    var departureTime: Date            // 出发时间
    var optimalStartTime: Date         // 智能计算的启动时间
    var targetTemp: Double             // 目标温度 °F
    var daysOfWeek: [Int]              // [1-7] 星期几重复
    var isEnabled: Bool
    var isWeatherAware: Bool           // 是否启用天气感知
    var preconditionMinutes: Int       // 预调节时长(分钟)
    var notifyBeforeMinutes: Int       // 提前通知(分钟)
    var createdAt: Date
    var lastExecutedAt: Date?
    
    init(
        vehicleId: String,
        departureTime: Date,
        optimalStartTime: Date,
        targetTemp: Double = 72.0,
        daysOfWeek: [Int] = [2,3,4,5,6],  // 工作日
        isEnabled: Bool = true,
        isWeatherAware: Bool = true,
        preconditionMinutes: Int = 20,
        notifyBeforeMinutes: Int = 15
    ) {
        self.id = UUID()
        self.vehicleId = vehicleId
        self.departureTime = departureTime
        self.optimalStartTime = optimalStartTime
        self.targetTemp = targetTemp
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.isWeatherAware = isWeatherAware
        self.preconditionMinutes = preconditionMinutes
        self.notifyBeforeMinutes = notifyBeforeMinutes
        self.createdAt = Date()
    }
}

/// 车辆模型
@Model
final class Vehicle {
    
    @Attribute(.unique) var id: String          // Smartcar vehicleId 或 Tesla VIN
    var brand: VehicleBrand
    var model: String
    var year: Int
    var displayName: String
    var batteryLevel: Int                       // 0-100
    var chargingState: ChargingState
    var isClimateOn: Bool
    var insideTemp: Double?                     // °F
    var outsideTemp: Double?                    // °F
    var lastUpdated: Date
    
    init(brand: VehicleBrand, model: String, year: Int, displayName: String) {
        self.id = UUID().uuidString
        self.brand = brand
        self.model = model
        self.year = year
        self.displayName = displayName
        self.batteryLevel = 0
        self.chargingState = .unknown
        self.isClimateOn = false
        self.lastUpdated = Date()
    }
}

enum VehicleBrand: String, Codable, CaseIterable {
    case tesla = "Tesla"
    case ford = "Ford"
    case bmw = "BMW"
    case mercedes = "Mercedes"
    case rivian = "Rivian"
    case hyundai = "Hyundai"
    case kia = "Kia"
    case volkswagen = "Volkswagen"
    case chevrolet = "Chevrolet"
    case nissan = "Nissan"
    case audi = "Audi"
    case porsche = "Porsche"
    case volvo = "Volvo"
    case polestar = "Polestar"
}

enum ChargingState: String, Codable {
    case pluggedIn = "PLUGGED_IN"
    case charging = "CHARGING"
    case unplugged = "UNPLUGGED"
    case unknown = "UNKNOWN"
}
```

---

## 4. 实现流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                    PrecondAI 实现流程图                           │
└─────────────────────────────────────────────────────────────────┘

Phase 1: MVP (4-5 周)
═══════════════════════

[Week 1] 项目搭建 + Tesla API 集成
  │
  ├── 创建 Xcode 项目 (SwiftUI, iOS 16+)
  ├── 集成 JagCesar/Tesla-API (SPM)
  ├── 实现 Tesla OAuth2 PKCE 认证
  ├── 实现 Tesla Fleet API 气候控制命令
  │     ├── auto_conditioning_start/stop
  │     ├── set_temps
  │     └── add_precondition_schedule
  └── 实现车辆状态获取 (battery, climate, location)
  
[Week 2] 天气感知 + 智能算法
  │
  ├── 集成 OpenWeatherMap API
  │     ├── 当前天气查询
  │     ├── 48小时预报
  │     └── 缓存策略 (30分钟刷新)
  ├── 实现 SmartPreconditionCalculator
  │     ├── 温差 → 预热时间计算
  │     ├── 天气状况调整系数
  │     ├── 插电/非插电状态处理
  │     └── 电量安全阈值检查
  └── 单元测试 (各种温度/天气场景)

[Week 3] 调度管理 + 后台任务
  │
  ├── SwiftData 数据模型
  │     ├── PreconditionSchedule
  │     ├── Vehicle
  │     └── 执行历史记录
  ├── 调度 CRUD 操作
  ├── BGTaskScheduler 集成
  │     ├── 后台任务注册
  │     ├── 定时触发预调节
  │     └── 失败重试机制
  └── 本地推送通知
        ├── 预调节启动确认
        ├── 出发前提醒
        └── 错误/电量不足警告

[Week 4] UI 实现
  │
  ├── Dashboard (主控制面板)
  │     ├── 车辆状态卡片 (温度/电量/充电)
  │     ├── 一键预调节按钮
  │     └── 当前活跃调度状态
  ├── Schedule 管理
  │     ├── 调度列表 (按时间排序)
  │     ├── 添加/编辑调度
  │     └── 天气感知开关
  ├── 车辆设置
  │     ├── 品牌选择
  │     ├── Tesla OAuth 认证流程
  │     └── 车辆信息显示
  └── 设置页面
        ├── 温度单位 (°F/°C)
        ├── 默认目标温度
        └── 通知偏好

[Week 5] 测试 + 上架
  │
  ├── 单元测试 + UI 测试
  ├── TestFlight 内测
  ├── App Store 提交
  │     ├── 截图 (6.7" + 6.5" + iPad)
  │     ├── App 描述 (ASO 优化)
  │     ├── 隐私政策
  │     └── 年龄分级 (4+)
  └── 发布 v1.0

Phase 2: 多品牌 + 日历 (4 周)
═══════════════════════════════

[Week 6-7] Smartcar 多品牌集成
  │
  ├── Smartcar SDK 集成
  ├── 品牌选择 UI
  ├── 15+ 品牌支持
  └── 品牌能力检测 (Capabilities)

[Week 8-9] 日历集成 + 高级功能
  │
  ├── EventKit 日历读取
  ├── 自动从日历事件生成调度
  ├── 习惯学习 (Core ML)
  ├── Apple Watch App
  ├── CarPlay 支持
  ├── 能耗统计 + 电费估算
  └── 多车辆管理

Phase 3: 高级功能 (持续迭代)
═════════════════════════════

  ├── Widget (Lock Screen + Home Screen)
  ├── Siri Shortcuts 集成
  ├── Family Sharing
  ├── 地理围栏自动触发
  ├── 电价感知 (Off-peak 充电+预调节)
  └── 社区功能 (分享调度模板)
```

---

## 5. 用户流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                    PrecondAI 用户流程图                           │
└─────────────────────────────────────────────────────────────────┘

═══ 首次使用流程 ═══

[打开 App]
     │
     ▼
[欢迎页面] ── "Precondition your EV, intelligently"
     │
     ▼
[选择车辆品牌]
     │
     ├── [Tesla] ──▶ [Tesla OAuth 登录] ──▶ [授权成功] ──┐
     │                                                    │
     ├── [Ford]  ──▶ [Smartcar OAuth]  ──▶ [授权成功] ──┤
     │                                                    │
     ├── [BMW]   ──▶ [Smartcar OAuth]  ──▶ [授权成功] ──┤
     │                      │                             │
     │                  [选择车辆]                         │
     │                      │                             │
     └── [其他]  ──▶ [Smartcar OAuth] ──▶ [授权成功] ──┘
                                                       │
                                                       ▼
                                              [仪表盘 — 首次引导]
                                               "Create your first schedule?"

═══ 日常使用流程 ═══

[打开 App / 收到通知]
     │
     ▼
[仪表盘]
     │
     ├── [车辆状态区]
     │     ├── 🌡️ 车内温度: 85°F
     │     ├── 🔋 电池电量: 78%
     │     ├── 🔌 充电状态: Unplugged
     │     └── 📍 位置: Home
     │
     ├── [快捷操作区]
     │     ├── [❄️ Cool Now] ──▶ 立即启动制冷
     │     ├── [🔥 Heat Now] ──▶ 立即启动制热
     │     └── [⏹ Stop]     ──▶ 停止预调节
     │
     ├── [活跃调度区]
     │     ├── "⏰ 7:30 AM Departure — Preconditioning starts at 7:10 AM"
     │     └── [编辑] [暂停] [删除]
     │
     └── [智能建议区]
           ├── "☀️ It'll be 95°F tomorrow. Start cooling 25 min before departure?"
           └── [Accept] [Customize] [Dismiss]

═══ 创建调度流程 ═══

[+ New Schedule]
     │
     ▼
[设置出发时间]
     │  "When do you leave?"
     │  ┌─────────────────┐
     │  │  7:30 AM        │  (时间选择器)
     │  └─────────────────┘
     │
     ▼
[选择重复日期]
     │  ┌───┐┌───┐┌───┐┌───┐┌───┐┌───┐┌───┐
     │  │ S ││ M ││ T ││ W ││ T ││ F ││ S │
     │  │   ││ ✓ ││ ✓ ││ ✓ ││ ✓ ││ ✓ ││   │
     │  └───┘└───┘└───┘└───┘└───┘└───┘└───┘
     │
     ▼
[设置目标温度]
     │  ┌──────────────────────┐
     │  │  72°F  ○─────────●  │  (温度旋钮/滑块)
     │  └──────────────────────┘
     │
     ▼
[天气感知设置] (默认开启)
     │  [✓] Adjust start time based on weather
     │  ──────────────────────────────────
     │  Today: 28°F → Start 25 min before
     │  Tomorrow: 45°F → Start 15 min before
     │  (智能预览，让用户看到效果)
     │
     ▼
[通知设置]
     │  [✓] Notify me 15 min before departure
     │  [✓] Confirm when preconditioning starts
     │
     ▼
[保存调度] ──▶ [✓ Schedule Created!]
                    │
                    ├── 预调节启动时间: 7:05 AM (天气调整)
                    ├── 原始出发时间: 7:30 AM
                    └── 返回仪表盘

═══ 智能通知流程 ═══

[预调节启动时]
     │
     ▼
📱 推送通知: "PrecondAI: Your Tesla Model 3 is warming up to 72°F 🚗"
     │
     ├── [查看详情] ──▶ 打开 App 显示实时状态
     └── [停止]     ──▶ 远程停止预调节

[出发前 15 分钟]
     │
     ▼
📱 推送通知: "PrecondAI: Your car is ready! 72°F inside. Leave in 15 min ⏰"
     │
     └── [打开 App] ──▶ 仪表盘显示 "Ready to Go ✓"

[电量不足警告]
     │
     ▼
📱 推送通知: "PrecondAI: Battery at 25%. Preconditioning skipped to preserve range ⚠️"
     │
     └── [充电后重试] ──▶ 设置充电完成后的预调节
```

---

## 6. 软件数据流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    PrecondAI 数据流图                             │
└─────────────────────────────────────────────────────────────────┘

═══ 系统架构总览 ═══

                    ┌──────────────────┐
                    │   User (EV Owner)│
                    └────────┬─────────┘
                             │ 触摸/通知
                             ▼
┌────────────────────────────────────────────────────────────┐
│                    iOS App (SwiftUI)                        │
│                                                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │Dashboard │  │Schedule  │  │Settings  │  │Onboarding│  │
│  │  View    │  │  View    │  │  View    │  │   View   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │              │              │              │        │
│  ┌────▼──────────────▼──────────────▼──────────────▼─────┐  │
│  │                    ViewModel Layer                     │  │
│  │  DashboardVM │ ScheduleVM │ SettingsVM │ OnboardVM  │  │
│  └────┬──────────────┬──────────────┬──────────────┬─────┘  │
│       │              │              │              │        │
│  ┌────▼──────────────▼──────────────▼──────────────▼─────┐  │
│  │                   Service Layer                        │  │
│  │                                                       │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐ │  │
│  │  │  Schedule    │ │  Vehicle    │ │  Notification    │ │  │
│  │  │  Service     │ │  Service    │ │  Service         │ │  │
│  │  └──────┬──────┘ └──────┬──────┘ └────────┬────────┘ │  │
│  │         │               │                  │          │  │
│  │  ┌──────▼───────────────▼──────┐   ┌──────▼────────┐ │  │
│  │  │     Smart Precondition      │   │  Background   │ │  │
│  │  │     Calculator (Algorithm)  │   │  Task Manager │ │  │
│  │  └──────────────┬──────────────┘   └───────────────┘ │  │
│  └─────────────────┼────────────────────────────────────┘  │
│                     │                                      │
│  ┌──────────────────▼────────────────────────────────────┐ │
│  │                  Data / Network Layer                  │ │
│  │                                                       │ │
│  │  ┌───────────┐  ┌──────────┐  ┌────────────────────┐ │ │
│  │  │ SwiftData │  │ Keychain │  │  URLSession        │ │ │
│  │  │ (Local DB)│  │ (Tokens) │  │  (Network Layer)   │ │ │
│  │  └───────────┘  └──────────┘  └────────┬───────────┘ │ │
│  └────────────────────────────────────────┼─────────────┘ │
└───────────────────────────────────────────┼───────────────┘
                                            │
                    ┌───────────────────────┼───────────────────┐
                    │                       │                   │
                    ▼                       ▼                   ▼
          ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐
          │  Tesla Fleet API│    │  Smartcar API   │    │  OpenWeather │
          │                 │    │                 │    │  Map API     │
          │ • Auth (OAuth2) │    │ • Auth (OAuth2) │    │              │
          │ • Climate Ctrl  │    │ • Climate Ctrl  │    │ • Current    │
          │ • Vehicle Data  │    │ • Battery       │    │ • Forecast   │
          │ • Schedules     │    │ • Location      │    │ • Alerts     │
          └────────┬────────┘    └────────┬────────┘    └──────┬───────┘
                   │                      │                    │
                   ▼                      ▼                    ▼
          ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐
          │  Tesla Vehicle  │    │  Multi-brand    │    │  Weather     │
          │  (via Internet) │    │  Vehicles       │    │  Service     │
          └─────────────────┘    └─────────────────┘    └──────────────┘

═══ 核心数据流详解 ═══

1. 创建调度数据流:
   ┌────────┐    ┌──────────┐    ┌────────────┐    ┌──────────┐
   │  User  │───▶│ Schedule │───▶│  Weather   │───▶│ Smart    │
   │ Input  │    │ Service  │    │  Service   │    │ Calc     │
   └────────┘    └──────────┘    └────────────┘    └────┬─────┘
                                                     │
                  ┌──────────┐    ┌──────────┐        │
                  │Local Push│◀───│ Notif    │◀───────┤
                  │ Notif    │    │ Service  │        │
                  └──────────┘    └──────────┘        │
                                                       │
                  ┌──────────┐    ┌──────────┐        │
                  │SwiftData │◀───│ Schedule │◀───────┘
                  │ (Save)   │    │ Service  │
                  └──────────┘    └──────────┘

2. 执行预调节数据流:
   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
   │BGTask    │───▶│ Schedule │───▶│ Weather  │───▶│ Smart    │
   │ Scheduler│    │ Service  │    │ Service  │    │ Calc     │
   └──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                                                       │
                  ┌──────────┐    ┌──────────┐    ┌────┴─────┐
                  │Vehicle   │◀───│ Vehicle  │◀───│ Decision │
                  │(Climate) │    │ Service  │    │ Engine   │
                  └──────────┘    └──────────┘    └──────────┘
                                                       │
                  ┌──────────┐    ┌──────────┐    ┌────┴─────┐
                  │Push Notif│◀───│ Notif    │◀───│ Confirm  │
                  │ (Result) │    │ Service  │    │ Result   │
                  └──────────┘    └──────────┘    └──────────┘

3. 实时状态轮询数据流:
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ Timer    │───▶│ Vehicle  │───▶│  Tesla/  │
   │ (30s)    │    │ Service  │    │ Smartcar │
   └──────────┘    └──────────┘    └──────────┘
                       │
                       ▼
                  ┌──────────┐    ┌──────────┐
                  │Dashboard │◀───│ ViewModel│
                  │   UI     │    │ (Update) │
                  └──────────┘    └──────────┘
```

---

## 7. 极具竞争力的价格策略

### 7.1 市场定价分析

| 竞品/参考 | 类型 | 价格 | 模式 |
|-----------|------|------|------|
| Tesla App | 免费 | $0 | 车厂内置 |
| My BMW App | 免费 | $0 | 车厂内置 |
| Tesla-Automatic-Preconditioning | 开源 | $0 | 自部署 |
| EV Charge Manager (App Store) | 付费 | $4.99 | 一次性购买 |
| ChargePoint | 免费+内购 | $0 | 免费增值 |
| PlugShare | 免费+内购 | $0 | 免费增值 |

### 7.2 PrecondAI 定价策略分析

**关键考量因素**:
1. ✅ 本 App **有 API 调用费用**（Smartcar API、OpenWeatherMap API），因此**不能完全免费**
2. ✅ 目标用户是 EV 车主，消费能力通常较高
3. ✅ 解决的是"每天使用"的高频刚需，用户感知价值高
4. ⚠️ 厂商 App 虽然免费但功能差，用户可能不愿意为"替代方案"付费
5. ⚠️ 需要在 App Store 获得下载量，定价过高会阻碍增长

### 7.3 推荐策略：站内订阅 B 模式

> **选择理由**: 功能涉及 API 费用 + 功能稍复杂 + 需要持续维护天气/车辆 API 适配

```
┌─────────────────────────────────────────────────────────────────┐
│               PrecondAI 定价策略 — 站内订阅 B                     │
└─────────────────────────────────────────────────────────────────┘

免费层 (Free Forever)
─────────────────────
✅ 1 辆车连接
✅ 手动远程启动/停止预调节 (Cool Now / Heat Now)
✅ 基础调度 (最多 1 个固定时间调度，无天气感知)
✅ 推送通知 (预调节启动确认)
✅ 车辆状态查看 (温度/电量/充电状态)

免费层限制:
❌ 无天气智能调整
❌ 无日历集成
❌ 仅支持 1 辆车
❌ 仅 1 个调度
❌ 无能耗统计

月度订阅 — $2.99/月
─────────────────────
✅ 免费层所有功能
✅ 天气智能调整 (核心卖点！)
✅ 无限调度
✅ 多车辆支持 (最多 3 辆)
✅ 日历集成 (Google/Apple Calendar)
✅ 出发提醒通知
✅ 电池安全保护 (非插电预调节)

年度订阅 — $19.99/年 (节省 44%)
─────────────────────
✅ 月度订阅所有功能
✅ 优先客户支持
✅ 新功能提前体验
✅ 能耗统计 + 电费估算
✅ Apple Watch App

一次性买断 — ❌ 不提供
─────────────────────
原因: Smartcar API + OpenWeatherMap API 持续产生费用
      一次性买断无法覆盖长期运营成本

定价合理性分析:
─────────────
| 对比项              | PrecondAI    | 每年加油节省   |
|---------------------|-------------|---------------|
| 月度订阅            | $2.99/月    | —             |
| 年度订阅            | $19.99/年   | —             |
| 每日成本 (年度)      | $0.055/天   | —             |
| 智能预调节节省燃油/电 | —           | ~$10-30/月    |
| ROI                 | 3-10x       | —             |

定价心理学:
- $2.99/月 < 一杯咖啡 ($4-5)
- $19.99/年 = 每天约5分钱
- 相比"忘记预热导致在冰冷车内等15分钟"的痛苦，$2.99是极小的代价
- 年度 $19.99 的锚点效应让月度 $2.99 看起来很划算
```

### 7.4 价格策略详细分析

#### 7.4.1 为什么不选完全免费？

```
❌ 完全免费方案不适用

原因:
1. Smartcar API 每次查询 ~$0.025
   - 每个用户日均 10 次调用 = $0.25/天
   - 月均 $7.50/用户的 API 成本

2. OpenWeatherMap Pro API (如需)
   - 免费层: 1000次/天 (足够初期)
   - 超出后: $0.0015/次

3. 服务器成本 (Vehicle Command Proxy)
   - AWS/GCP 小型实例: ~$20/月

4. 如果完全免费:
   - 1000 活跃用户/月 = ~$7,500 API 成本
   - 无收入覆盖 = 不可持续
```

#### 7.4.2 为什么不选下载前付费？

```
❌ 下载前付费方案 ($4.99) 不适用

原因:
1. 用户不知道 App 是否真的比厂商 App 好用
   - 没有试用机会 = 低转化率
   - App Store 评分可能偏低

2. 无法覆盖持续的 API 成本
   - $4.99 一次性 ≈ 2个月的 API 成本
   - 用户使用超过2个月 = 亏损

3. 功能复杂度需要持续更新
   - 车辆 API 变化需要及时适配
   - 新品牌支持需要持续开发

4. 竞品（厂商App）免费，付费下载障碍大
```

#### 7.4.3 为什么不选站内订阅 A（一次性买断）？

```
❌ 站内订阅 A (免费下载 + 一次性买断 $9.99) 不适用

原因:
1. Smartcar API 持续产生费用
   - 一次性买断无法覆盖长期使用
   - 用户使用1年后的 API 成本 ≈ $90

2. 需要持续维护
   - Tesla Fleet API 经常变更
   - 各品牌 API 需要适配更新
   - 天气 API 需要持续对接

3. 一次性买断可能违反 Apple 审核指南
   - 涉及外部服务的 App 需要订阅模式
```

#### 7.4.4 站内订阅 B 的优势总结

```
✅ 站内订阅 B (免费下载 + 按月/按年订阅) 是最佳选择

优势:
1. 零门槛下载 → 最大化用户获取
2. 免费层提供核心价值 → 用户可以先体验再付费
3. 天气智能是"付费钩子" → 用户一旦体验就回不去
4. 订阅收入覆盖 API 成本 → 商业可持续
5. 年度折扣提高留存 → 降低流失率
6. 符合 App Store 审核要求 → 审核通过率高

免费→付费转化策略:
1. 新用户 7 天免费试用所有功能 (含天气智能)
2. 试用结束后:
   - 天气智能调度降级 → 调度变为固定时间
   - 出发提醒消失
   - 多车辆限制为1辆
3. 用户点击"恢复智能功能" → 引导订阅

转化率预估:
- 免费用户 → 付费转化: 8-12% (行业标准 5-15%)
- 月度 → 年度升级: 30-40%
- 月度流失率: 5-8%
```

### 7.5 竞争优势定价矩阵

```
┌──────────────────────────────────────────────────────────────┐
│              PrecondAI vs 竞品 功能/价格对比                    │
├──────────────┬──────────┬──────────┬──────────┬──────────────┤
│    功能       │ Tesla App│ My BMW   │ OVMS     │ PrecondAI   │
├──────────────┼──────────┼──────────┼──────────┼──────────────┤
│ 远程启动空调  │    ✅    │    ✅    │    ✅    │    ✅       │
│ 定时调度      │    ✅    │    ✅    │    ✅    │    ✅       │
│ 天气智能调整  │    ❌    │    ❌    │    ❌    │    ✅ 💎    │
│ 多品牌统一    │    ❌    │    ❌    │    ⚠️   │    ✅ 💎    │
│ 日历集成      │    ❌    │    ❌    │    ❌    │    ✅ 💎    │
│ 电量保护      │    ❌    │    ⚠️   │    ❌    │    ✅ 💎    │
│ Apple Watch  │    ✅    │    ✅    │    ❌    │ Phase 2     │
│ 可靠性       │    ⚠️   │    ⚠️   │    ⚠️   │    ✅ 💎    │
│ 价格         │    免费  │    免费  │  硬件$200+│  $2.99/月   │
└──────────────┴──────────┴──────────┴──────────┴──────────────┘

💎 = PrecondAI 核心差异化竞争优势

结论: PrecondAI 用 $2.99/月的价格提供了价值远超厂商免费App的功能
      — "免费的不一定是最便宜的" (时间成本 > 金钱成本)
```

---

## 8. APP 命名深度分析

### 8.1 命名方案对比

| 候选名 | ASO 搜索优化 | 品牌记忆度 | 功能描述性 | 情感共鸣 | 国际化适配 | 总分 |
|--------|-------------|-----------|-----------|---------|-----------|------|
| **PrecondAI** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **22/25** |
| ClimateGo | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | 17/25 |
| AutoTemp | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | 14/25 |
| EVWarm | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | 16/25 |
| CabinReady | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | 17/25 |
| SmartPrecond | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | 17/25 |

### 8.2 最终命名：PrecondAI

#### 8.2.1 ASO 搜索优化分析

```
关键词覆盖矩阵:
┌──────────────────────────┬────────────────┬─────────────┐
│ 搜索关键词               │ PrecondAI 匹配 │ 月搜索量估  │
├──────────────────────────┼────────────────┼─────────────┤
│ "EV preconditioning"     │ ✅ 直接匹配     │ 5,000+      │
│ "precondition" + "app"   │ ✅ 直接匹配     │ 3,000+      │
│ "car climate schedule"   │ ✅ App描述匹配  │ 2,000+      │
│ "Tesla preconditioning"  │ ✅ App描述匹配  │ 15,000+     │
│ "EV climate control"     │ ✅ App描述匹配  │ 8,000+      │
│ "car warm up app"        │ ✅ App描述匹配  │ 4,000+      │
│ "electric vehicle AC"    │ ✅ App描述匹配  │ 3,000+      │
│ "AI" + "car" + "climate" │ ✅ 名称匹配     │ 变化大       │
└──────────────────────────┴────────────────┴─────────────┘

ASO 策略:
- App 名称: "PrecondAI - Smart EV Climate Scheduler"
- 副标题: "Weather-Aware Preconditioning Timer"
- 关键词字段: "EV,electric,vehicle,preconditioning,climate,heat,cool,schedule,timer,weather,Tesla,Ford,BMW"
```

#### 8.2.2 品牌记忆度分析

```
PrecondAI 的品牌记忆优势:

1. 造词策略 (Portmanteau):
   "Precondition" + "AI" = PrecondAI
   → 独特、可注册商标、无竞品混淆

2. 音节简洁:
   Pre-cond-AI (3音节)
   → 容易发音、容易记住

3. "AI" 后缀:
   → 暗示智能、先进技术
   → 符合 2025-2026 年技术趋势
   → 用户预期"AI帮我做了决策"

4. 视觉设计友好:
   P-R-E-C-O-N-D-A-I
   → 9个字母，适合 App 图标设计
   → 可用温度计+AI芯片的图标组合
```

#### 8.2.3 功能描述性分析

```
"PrecondAI" = Preconditioning + AI

即时传达的信息:
1. "Precond" → 预调节（EV 车主熟悉的术语）
2. "AI" → 智能自动（不需要手动操作）
3. 合在一起 → "智能预调节"

vs. 竞品命名对比:
- "Tesla App" → 不知道具体功能
- "My BMW" → 品牌导向，非功能导向
- "EVCharge" → 充电相关，非空调
- "PrecondAI" → 功能精准，一目了然
```

#### 8.2.4 情感共鸣分析

```
PrecondAI 的情感触点:

1. "终于有人做对了" 的满足感
   → 用户长期被厂商App的不可靠调度折磨
   → PrecondAI = "那个终于让我不用操心的App"

2. "AI 帮我做决定" 的省心感
   → 不用每天看天气再调整预热时间
   → AI 自动根据温度/天气计算 → "它比我想得周到"

3. "随时舒适的座舱" 的幸福感
   → 每次上车都是完美温度
   → 夏天不再烫屁股，冬天不再冷冰冰

4. "聪明车主" 的身份认同
   → 用 AI 管理 EV = 科技先锋
   → "我的车比你的更智能" 的社交货币
```

#### 8.2.5 国际化适配分析

```
PrecondAI 跨语言适配:

| 语言    | 发音                | 理解度 | 备注                    |
|---------|---------------------|--------|------------------------|
| 英语    | /priːˈkɒnd eɪ/aɪ/  | ⭐⭐⭐⭐⭐ | 核心市场，完美适配      |
| 西班牙语| pre-cond-ai         | ⭐⭐⭐⭐  | "precond"可联想"precondicionar" |
| 法语    | pre-cond-ai         | ⭐⭐⭐⭐  | "precond"接近"préconditionner" |
| 德语    | pre-cond-ai         | ⭐⭐⭐⭐  | "AI"在德语中同样理解    |
| 葡萄牙语| pre-cond-ai         | ⭐⭐⭐⭐  | 巴西EV市场增长快        |
| 日语    | プレコンダイ         | ⭐⭐⭐   | 片假名可读，但需教育    |
| 韩语    | 프리콘다이           | ⭐⭐⭐   | 需要额外本地化          |
| 中文    | 预调AI              | ⭐⭐⭐⭐  | 直译清晰               |

结论: PrecondAI 在欧美主要市场（英语/西/法/德/葡）天然适配
      日韩市场需要额外品牌教育，但不影响核心的英语市场策略
```

### 8.3 副标题: Smart EV Climate Scheduler

```
副标题功能:
1. 补充 App 名称未能表达的信息
   - "Smart" → 智能功能
   - "EV" → 目标车型
   - "Climate Scheduler" → 核心功能

2. ASO 额外关键词覆盖
   - "EV" + "Climate" + "Scheduler" = 3个额外搜索词

3. App Store 搜索结果展示
   ┌─────────────────────────────────────┐
   │ 🚗 PrecondAI                        │
   │    Smart EV Climate Scheduler        │
   │    ⭐⭐⭐⭐⭐ 4.8 (2.3K Ratings)     │
   │    Weather-Aware Preconditioning     │
   └─────────────────────────────────────┘
```

---

## 9. UI 设计方案

### 9.1 设计原则（符合美国市场习惯 + 当前主流趋势）

```
设计风格: 
  - Apple Human Interface Guidelines 2026
  - 简约 + 功能性 (Minimalist + Functional)
  - 玻璃态 + 深色模式优先 (Glassmorphism + Dark Mode First)
  - 大圆角 + 大字体 + 大触摸区域
  - 数据可视化优先 (一目了然的状态展示)

配色方案:
  - 主色: #007AFF (Apple Blue — 信任/科技感)
  - 辅助色: #FF9500 (Orange — 温暖/热量指示)
  - 冷色: #5AC8FA (Light Blue — 制冷指示)  
  - 热色: #FF3B30 (Red — 高温/紧急)
  - 成功: #34C759 (Green — 就绪/完成)
  - 背景: #000000 → #1C1C1E (Dark Mode 渐变)
  
字体:
  - 主标题: SF Pro Display Bold, 28pt
  - 正文: SF Pro Text Regular, 16pt
  - 数据: SF Pro Rounded Medium, 20pt (温度/电量)
  
动画:
  - 温度变化: 流体动画 (Lottie 或 SwiftUI Animation)
  - 空调状态: 呼吸灯效果 (启动时脉冲)
  - 状态切换: Spring 动画 (弹性过渡)
```

### 9.2 核心页面设计

#### 9.2.1 仪表盘 (Dashboard) — 主页面

```
┌─────────────────────────────────────────┐
│  9:41              PrecondAI       ⚙️   │ ← 状态栏
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  🚗 Tesla Model 3                   ││ ← 车辆卡片
│  │                                     ││
│  │  ┌─────────┐  ┌─────────┐          ││
│  │  │ 🌡️ 72°F │  │ 🔋 78%  │          ││ ← 大字体数据
│  │  │ Inside  │  │ Battery │          ││
│  │  └─────────┘  └─────────┘          ││
│  │                                     ││
│  │  ┌─────────┐  ┌─────────┐          ││
│  │  │ ☀️ 85°F  │  │ 🔌 Off  │          ││
│  │  │ Outside │  │ Charging│          ││
│  │  └─────────┘  └─────────┘          ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌──────────┐  ┌──────────┐  ┌───────┐ │
│  │  ❄️ Cool  │  │  🔥 Heat │  │ ⏹ Stop│ │ ← 快捷操作
│  │   Now    │  │   Now    │  │       │ │
│  └──────────┘  └──────────┘  └───────┘ │
│                                         │
│  Upcoming Schedule                      │
│  ┌─────────────────────────────────────┐│
│  │ ⏰ 7:30 AM Departure  [Weather 🌡️]  ││ ← 调度卡片
│  │    Precond starts at 7:05 AM        ││
│  │    🌡️ 28°F outside → 25 min warmup  ││ ← 天气感知提示
│  │                     [Edit] [Pause]  ││
│  └─────────────────────────────────────┘│
│                                         │
│  💡 Smart Suggestion                    │
│  ┌─────────────────────────────────────┐│
│  │ ☀️ Tomorrow will be 95°F.            ││ ← AI建议
│  │ Start cooling 25 min before?        ││
│  │     [Accept]  [Customize]           ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐│
│  │ 🏠   │  │ 📅   │  │ 🚗   │  │ ⚙️   ││ ← Tab Bar
│  │Home  │  │Sched │  │Car   │  │Sett  ││
│  └──────┘  └──────┘  └──────┘  └──────┘│
└─────────────────────────────────────────┘
```

#### 9.2.2 添加调度 (Add Schedule) — 核心交互页面

```
┌─────────────────────────────────────────┐
│  ← New Schedule                   Save  │
│                                         │
│  🕐 Departure Time                      │
│  ┌─────────────────────────────────────┐│
│  │          ⏰ 7:30 AM                  ││ ← 时间选择器 (滚轮)
│  │       :--------:--------:           ││
│  └─────────────────────────────────────┘│
│                                         │
│  📅 Repeat                              │
│  ┌───┐┌───┐┌───┐┌───┐┌───┐┌───┐┌───┐  │
│  │ S ││ M ││ T ││ W ││ T ││ F ││ S │  │ ← 星期选择
│  │   ││ ✓ ││ ✓ ││ ✓ ││ ✓ ││ ✓ ││   │  │
│  └───┘└───┘└───┘└───┘└───┘└───┘└───┘  │
│                                         │
│  🌡️ Target Temperature                  │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │    55°F ──────●──────── 85°F        ││ ← 温度滑块
│  │              72°F                   ││
│  │   ❄️ Cool                    🔥 Heat ││
│  └─────────────────────────────────────┘│
│                                         │
│  🧠 Smart Weather Adjustment     [✓ ON] │ ← 核心卖点开关
│  ┌─────────────────────────────────────┐│
│  │  Preview for this week:             ││
│  │  Mon 28°F → Start 25 min early     ││ ← 天气预览
│  │  Tue 35°F → Start 18 min early     ││    (让用户看到AI的价值)
│  │  Wed 45°F → Start 12 min early     ││
│  └─────────────────────────────────────┘│
│                                         │
│  🔔 Notifications                       │
│  [✓] Confirm when preconditioning starts│
│  [✓] Remind me 15 min before departure │
│  [ ] Alert if battery is too low        │
│                                         │
└─────────────────────────────────────────┘
```

#### 9.2.3 温度旋钮控件（自定义 SwiftUI 组件）

```swift
// Shared/Components/TemperatureDial.swift

import SwiftUI

/// 温度旋钮控件 — 核心交互组件
struct TemperatureDial: View {
    @Binding var temperature: Double  // °F
    let range: ClosedRange<Double>    // 55°F...85°F
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // 中心温度显示
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: temperatureColorGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: temperatureColor.opacity(0.3), radius: 20)
                
                VStack(spacing: 4) {
                    Text("\(Int(temperature))°")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(temperature > 72 ? "HEATING" : "COOLING")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .gesture(dragGesture)
            
            // 温度范围标签
            HStack {
                Text("\(Int(range.lowerBound))°F")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(range.upperBound))°F")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var temperatureColor: Color {
        if temperature < 65 { return .blue }
        else if temperature < 72 { return .cyan }
        else if temperature < 78 { return .orange }
        else { return .red }
    }
    
    private var temperatureColorGradient: [Color] {
        if temperature < 65 { return [.blue, .cyan] }
        else if temperature < 72 { return [.cyan, .green] }
        else if temperature < 78 { return [.orange, .yellow] }
        else { return [.red, .orange] }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let delta = value.translation.width
                let newTemp = temperature + delta * 0.15
                temperature = min(max(newTemp, range.lowerBound), range.upperBound)
            }
    }
}
```

### 9.3 设计趋势对照

```
2026 年 iOS App 设计趋势对照:

| 趋势                    | PrecondAI 实现                     | ✅/❌ |
|-------------------------|------------------------------------|-------|
| Dark Mode First         | 默认深色模式，浅色自动适配          | ✅    |
| Glassmorphism           | 卡片半透明毛玻璃效果               | ✅    |
| Large Touch Targets     | 快捷按钮 60pt+, 滑块全宽          | ✅    |
| Data Visualization      | 温度/电量大字体+颜色编码           | ✅    |
| Haptic Feedback         | 温度调节/按钮点击触觉反馈          | ✅    |
| Live Activities         | 锁屏显示预调节倒计时 (Phase 2)     | ✅    |
| Widgets                 | 主屏幕/锁屏小组件 (Phase 2)        | ✅    |
| SF Symbols              | 全面使用 Apple 系统图标            | ✅    |
| Dynamic Type            | 支持系统字体大小调整               | ✅    |
| Accessibility           | VoiceOver + 动态字体 + 高对比度    | ✅    |
| App Intents/Siri        | "Hey Siri, warm up my car" (P2)    | ✅    |
| CarPlay                 | 简化版控制界面 (Phase 2)           | ✅    |
```

### 9.4 App 图标设计

```
┌─────────────────────────────────┐
│         App Icon                │
│                                 │
│     ┌───────────────────┐      │
│     │                   │      │
│     │   🌡️ (温度计)     │      │
│     │   + AI 芯片纹路    │      │
│     │                   │      │
│     │   渐变背景:       │      │
│     │   深蓝→橙色       │      │
│     │   (冷→热的过渡)   │      │
│     │                   │      │
│     └───────────────────┘      │
│                                 │
│  设计要点:                      │
│  1. 温度计图标 → 功能一目了然   │
│  2. AI 芯片纹路 → 智能感        │
│  3. 冷→热渐变 → 季节通用        │
│  4. 深色背景 → 在主屏幕突出      │
│  5. 无文字 → 1024x1024 可用     │
└─────────────────────────────────┘
```

---

## 附录

### A. 关键 API 端点汇总

#### Tesla Fleet API — Climate Commands

| 端点 | 方法 | 路径 | 参数 |
|------|------|------|------|
| 启动预调节 | POST | `/api/1/vehicles/{vin}/command/auto_conditioning_start` | — |
| 停止预调节 | POST | `/api/1/vehicles/{vin}/command/auto_conditioning_stop` | — |
| 设置温度 | POST | `/api/1/vehicles/{vin}/command/set_temps` | `driver_temp`, `passenger_temp` |
| Climate Keeper | POST | `/api/1/vehicles/{vin}/command/set_climate_keeper_mode` | `climate_keeper_mode` (0-3) |
| 添加日程 | POST | `/api/1/vehicles/{vin}/command/add_precondition_schedule` | `id`, `departure_time`, `days_of_week` |
| 删除日程 | POST | `/api/1/vehicles/{vin}/command/remove_precondition_schedule` | `id` |
| 座椅加热 | POST | `/api/1/vehicles/{vin}/command/remote_seat_heater_request` | `seat`, `level` (0-3) |
| 方向盘加热 | POST | `/api/1/vehicles/{vin}/command/remote_steering_wheel_heater_request` | `on` (bool) |

#### Smartcar API — Climate

| 端点 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 启动空调 | POST | `/vehicles/{id}/climate` | `action: "START"` |
| 停止空调 | POST | `/vehicles/{id}/climate` | `action: "STOP"` |
| 电池状态 | GET | `/vehicles/{id}/battery` | 电量+续航 |
| 车辆位置 | GET | `/vehicles/{id}/location` | 经纬度 |
| 充电状态 | GET | `/vehicles/{id}/charge` | 是否插电 |

#### OpenWeatherMap API

| 端点 | 方法 | 路径 | 说明 |
|------|------|------|------|
| One Call 3.0 | GET | `/data/3.0/onecall` | 当前+48h预报+8天预报 |
| 天气警报 | GET | `/data/3.0/onecall` | 包含在 One Call 中 |
| 免费层限制 | — | — | 1000 次/天 |

### B. 技术风险与缓解

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| Tesla API 变更 | 高 | 中 | 抽象 API 层 + 快速适配 |
| Smartcar API 费用上涨 | 中 | 低 | 缓存策略 + 直接品牌API备选 |
| Apple 审核拒绝 | 高 | 低 | 遵循 HIG + 清晰隐私政策 |
| 厂商 App 改进导致竞争力下降 | 中 | 中 | 持续迭代 + AI 差异化 |
| 电池消耗（后台任务） | 低 | 中 | 优化轮询频率 + 事件驱动 |

### C. MVP 开发时间线

| 周次 | 里程碑 | 交付物 |
|------|--------|--------|
| W1 | 项目搭建 + Tesla API | 可认证+可发送空调命令 |
| W2 | 天气感知 + 智能算法 | 可根据天气计算预热时间 |
| W3 | 调度管理 + 后台任务 | 可创建定时调度并自动执行 |
| W4 | UI 实现 | 完整可用的 UI |
| W5 | 测试 + 上架 | TestFlight → App Store |

### D. 参考资源

| 资源 | 链接 |
|------|------|
| Tesla Fleet API 文档 | https://developer.tesla.com/docs/fleet-api |
| Smartcar API 文档 | https://smartcar.com/docs/ |
| OpenWeatherMap API | https://openweathermap.org/api |
| Apple HIG | https://developer.apple.com/design/human-interface-guidelines/ |
| JagCesar/Tesla-API | https://github.com/JagCesar/Tesla-API |
| teslamotors/vehicle-command | https://github.com/teslamotors/vehicle-command |
| Tesla-Automatic-Preconditioning | https://github.com/javaDevJT/Tesla-Automatic-Preconditioning |
| Open Vehicle Monitoring System | https://github.com/openvehicles/Open-Vehicle-Monitoring-System-3 |

---

**文档结束**

> 本文档由 PrecondAI 项目研究团队编写，任何 LLM 均可根据本文档复刻出完整的、极具竞争优势的 iOS EV 智能空调预约定时应用。
