# WaveDefiant ⚔️
> 灵感来源：微信小游戏《不服来通关》
> 画风参考：《球比伦战记》《Vampire Survivors》像素风格
> 目标平台：Steam PC / Nintendo Switch

## 🎮 游戏特色
- **极简操作**：WASD 移动，自动攻击，单摇杆即可畅玩
- **Roguelike 升级**：12 种升级选项，每次升级随机三选一
- **无尽波次**：敌人一波比一波强，Boss 每 5 波出现
- **5 种敌人**：史莱姆、蝙蝠、骷髅、恶魔、Boss（带冲锋技能）
- **连击系统**：连续击杀获得分数加成
- **成就系统**：10 个成就，带弹窗通知
- **打击感**：伤害飘字、击杀粒子、屏幕震动、无敌帧

## 🕹️ 操作
| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| ESC | 暂停 |

## 🛠️ 开发环境
- **引擎**：Godot 4.3+
- **语言**：GDScript
- **状态**：Phase 3 完成，Phase 4 进行中

## 📁 项目结构
```
wavedefiant/
├── project.godot              # 项目配置
├── export_presets.cfg         # 导出配置 (PC: Linux/Windows/macOS)
├── scenes/
│   ├── levels/                # 游戏关卡
│   ├── menus/                 # 主菜单
│   └── battle/                # 战斗场景
├── scripts/
│   ├── core/                  # 核心系统
│   │   ├── game_manager.gd    # 游戏状态/分数/存档
│   │   ├── player.gd          # 玩家控制/自动攻击
│   │   ├── game_scene.gd      # 主场景组装
│   │   ├── effects_manager.gd # 特效管理
│   │   ├── upgrade_manager.gd # 升级系统
│   │   └── sound_manager.gd   # 音效管理
│   ├── entities/              # 游戏实体
│   │   ├── enemy.gd           # 5种敌人AI
│   │   ├── projectile.gd      # 追踪弹道
│   │   └── xp_drop.gd         # 经验值掉落
│   ├── systems/               # 子系统
│   │   ├── wave_manager.gd    # 波次生成
│   │   ├── combo_manager.gd   # 连击系统
│   │   ├── achievement_mgr.gd # 成就系统
│   │   └── object_pool.gd     # 对象池
│   ├── ui/                    # UI组件
│   │   ├── hud.gd             # 游戏内HUD
│   │   ├── main_menu.gd       # 主菜单
│   │   ├── level_up_ui.gd     # 升级选择
│   │   └── game_over_ui.gd    # 游戏结束
│   └── data/
│       └── shared_data.gd     # 共享常量/枚举
├── assets/                    # 美术资源
└── docs/                      # 设计文档
```

## 🚀 本地运行
1. 安装 [Godot 4.3+](https://godotengine.org/download/)
2. 打开 Godot，导入 `project.godot`
3. 按 F5 运行

## 📝 开发进度
### Phase 1 ✅ 项目骨架
- [x] GameManager 状态管理
- [x] 玩家移动 + 自动攻击
- [x] 敌人 AI (5种类型)
- [x] 波次生成系统
- [x] 升级系统 (6种)
- [x] HUD + 主菜单 + 游戏结束

### Phase 2 ✅ 游戏手感
- [x] 伤害数字飘字
- [x] 击杀粒子特效
- [x] 玩家无敌帧 + 受伤闪烁
- [x] 竞技场边界 + 网格背景
- [x] 追踪弹道 + 暴击
- [x] 暂停菜单
- [x] 屏幕震动

### Phase 3 ✅ 内容丰富
- [x] 连击系统 (ComboManager)
- [x] 成就系统 (10个成就 + 弹窗)
- [x] Boss 特殊技能 (冲锋)
- [x] 12 种升级选项
- [x] 护甲减伤
- [x] 生命恢复
- [x] 暴击率/暴击伤害

### Phase 4 🔄 平台准备
- [x] PC 导出配置 (Linux/Windows/macOS)
- [ ] 对象池优化
- [ ] 音效/BGM
- [ ] Switch 适配
- [ ] 最终测试 + Bug 修复

## 📊 统计
| 指标 | 数值 |
|------|------|
| 文件数 | 27+ |
| 代码行数 | 2000+ |
| Commits | 4 |
| 开发天数 | 1 |

## 📄 License
MIT
