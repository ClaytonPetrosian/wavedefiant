# WaveDefiant ⚔️
> 灵感来源：微信小游戏《不服来通关》
> 画风参考：《球比伦战记》《Vampire Survivors》像素风格
> 目标平台：Steam PC / Nintendo Switch

## 🎮 游戏特色
- **极简操作**：WASD 移动，自动攻击，单摇杆即可畅玩
- **Roguelike 升级**：12 种升级选项，每次升级随机三选一
- **主动技能**：空格释放强力技能（火焰新星/冰霜冲击/闪电打击）
- **无尽波次**：敌人一波比一波强，Boss 每 5 波出现，带冲锋技能
- **5 种敌人**：史莱姆、蝙蝠、骷髅、恶魔、Boss
- **连击系统**：连续击杀获得分数加成，UI 实时显示
- **成就系统**：10 个成就，滑入式弹窗通知，持久保存
- **打击感**：伤害飘字、击杀粒子、屏幕震动、无敌帧、波次播报

## 🕹️ 操作
| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 空格 | 主动技能 |
| ESC | 暂停 |

## 🛠️ 开发环境
- **引擎**：Godot 4.3+
- **语言**：GDScript
- **状态**：Phase 1-4 完成 🎉

## 📁 项目结构
```
wavedefiant/
├── project.godot              # 项目配置
├── export_presets.cfg         # 4平台导出 (Linux/Win/macOS/Switch)
├── scenes/
│   ├── levels/                # 游戏关卡
│   ├── menus/                 # 主菜单
│   └── battle/                # 战斗场景
├── scripts/
│   ├── core/                  # 核心系统
│   │   ├── game_manager.gd    # 游戏状态/分数/存档
│   │   ├── player.gd          # 玩家控制/自动攻击/护甲
│   │   ├── game_scene.gd      # 主场景组装所有系统
│   │   ├── effects_manager.gd # 伤害飘字+粒子+震屏
│   │   ├── upgrade_manager.gd # 12种升级
│   │   ├── skill_manager.gd   # 主动技能系统
│   │   └── sound_manager.gd   # 音效管理
│   ├── entities/              # 游戏实体
│   │   ├── enemy.gd           # 5种敌人AI + Boss冲锋
│   │   ├── projectile.gd      # 追踪弹道+暴击
│   │   └── xp_drop.gd         # 经验值掉落
│   ├── systems/               # 子系统
│   │   ├── wave_manager.gd    # 波次生成+难度递增
│   │   ├── wave_announcer.gd  # 波次播报动画
│   │   ├── combo_manager.gd   # 连击系统
│   │   ├── achievement_mgr.gd # 10个成就
│   │   └── object_pool.gd     # 对象池优化
│   ├── ui/                    # UI
│   │   ├── hud.gd             # 游戏内HUD
│   │   ├── main_menu.gd       # 动画主菜单
│   │   ├── level_up_ui.gd     # 升级选择
│   │   └── game_over_ui.gd    # 游戏结束
│   └── data/
│       └── shared_data.gd     # 共享常量/敌人配置
├── assets/                    # 美术资源
└── docs/                      # 设计文档
    ├── DEVELOPMENT_PLAN.md    # 开发计划
    └── GAME_DESIGN.md         # 完整GDD
```

## 🚀 本地运行
1. 安装 [Godot 4.3+](https://godotengine.org/download/)
2. 打开 Godot，导入 `project.godot`
3. 按 F5 运行

## 📝 开发进度
### Phase 1 ✅ 项目骨架
- [x] GameManager 状态管理 + 存档系统
- [x] 玩家 WASD 移动 + 自动攻击
- [x] 5种敌人 AI（追逐+碰撞）
- [x] 波次生成系统（难度递增）
- [x] 升级系统（6种→12种）
- [x] HUD + 主菜单 + 游戏结束

### Phase 2 ✅ 游戏手感
- [x] 伤害数字飘字
- [x] 击杀粒子特效
- [x] 玩家无敌帧 + 受伤闪烁
- [x] 竞技场边界 + 网格背景
- [x] 追踪弹道 + 暴击系统
- [x] 暂停菜单
- [x] 屏幕震动

### Phase 3 ✅ 内容丰富
- [x] 连击系统（ComboManager + HUD显示）
- [x] 成就系统（10个成就 + 弹窗通知 + 持久化）
- [x] Boss 特殊技能（冲锋攻击）
- [x] 升级到 12 种（含暴击、护甲、恢复等）
- [x] 护甲减伤（每层15%）
- [x] 生命恢复机制

### Phase 4 ✅ 平台准备
- [x] PC 导出配置（Linux/Windows/macOS）
- [x] Nintendo Switch 导出配置
- [x] 对象池系统
- [x] 主动技能系统（3种技能+冷却条）
- [x] 波次播报动画
- [x] 主菜单动画
- [x] 完整 GDD 文档
- [x] 最终集成 + 清理

## 📊 统计
| 指标 | 数值 |
|------|------|
| 文件数 | 32+ |
| 代码行数 | 2,200+ 行 GDScript |
| Commits | 8 |
| 开发天数 | 2 |
| 平台支持 | Linux / Windows / macOS / Switch |

## 📄 License
MIT
