# WaveDefiant
> 灵感来源：微信小游戏《不服来通关》
> 画风参考：《球比伦战记》《Vampire Survivors》像素风格
> 目标平台：Steam PC / Nintendo Switch

## 🎮 游戏特色
- **极简操作**：WASD 移动，自动攻击，单摇杆即可畅玩
- **Roguelike 升级**：每次升级随机三选一，每局体验都不同
- **无尽波次**：敌人一波比一波强，Boss 每 5 波出现
- **多类型敌人**：史莱姆、蝙蝠、骷髅、恶魔、Boss

## 🕹️ 操作
| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 空格 | 主动技能 |
| ESC / E | 暂停 |

## 🛠️ 开发环境
- **引擎**：Godot 4.3+
- **语言**：GDScript
- **状态**：Phase 1 - 原型开发中

## 📁 项目结构
```
wavedefiant/
├── project.godot          # 项目配置
├── scenes/
│   ├── levels/            # 游戏关卡场景
│   ├── menus/             # 主菜单、设置等
│   └── battle/            # 战斗相关场景
├── scripts/
│   ├── core/              # 核心逻辑（GameManager, Player）
│   ├── entities/          # 实体（Enemy, XP Drop）
│   ├── systems/           # 系统（WaveManager）
│   └── ui/                # UI（HUD, 升级界面）
├── assets/
│   ├── graphics/          # 像素素材
│   ├── music/             # 音乐
│   └── sfx/               # 音效
└── docs/                  # 设计文档
```

## 🚀 本地运行
1. 安装 [Godot 4.3+](https://godotengine.org/download/)
2. 打开 Godot，导入 `project.godot`
3. 按 F5 运行

## 📝 开发进度
- [x] 项目骨架搭建
- [x] 核心 GameManager
- [x] 玩家移动 + 自动攻击
- [x] 敌人 AI + 多种类型
- [x] 波次生成系统
- [x] 升级选择 UI
- [x] HUD（HP/XP/波次/分数）
- [ ] 像素美术素材替换
- [ ] 音效/BGM
- [ ] 数值平衡
- [ ] Switch 适配
- [ ] Steam 集成
