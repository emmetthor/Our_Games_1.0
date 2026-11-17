# player

本文件對應 [`game/player/player.gd`](../../game/player/player.gd) 的 `Player` 類別，以及 [`game/player/player.tscn`](../../game/player/player.tscn)。遊戲的 `world.tscn` 使用此玩家場景。

## 架構

### 節點架構

目前 `player.tscn` 下的架構如圖：

![玩家節點架構](../img/玩家節點架構.png)

每個部件的功能如下：

| 節點 | 意義 |
| --- | --- |
| `player` | `Node2D` 根節點 |
| `CharacterBody2D` | 玩家本體，掛載 `Player` 腳本；`motion_mode = 1`（Floating） |
| `Sprite2D` | 玩家造型 |
| `Camera2D` | 跟隨玩家的視角 |
| `CollisionShape2D` | 玩家碰撞箱 |

### 資料流

```mermaid
flowchart TD
    physics["_physics_process(delta)"] --> get_vector["get_movement_input()"]
    get_vector --> update["update_movement(direction, delta)：先遞減冷卻"]
    update --> is_dashing{"is_dashing?"}
    is_dashing -->|yes| velocity_dash["velocity = dash_direction * dash_speed"]
    velocity_dash --> timer["遞減 dash_timer；到期清除 is_dashing"]
    is_dashing -->|no| get_sprint{"get_sprint_input() 且冷卻結束？"}
    get_sprint -->|yes| start_dash["start_dash(direction)：非零方向才啟動"]
    get_sprint -->|no| velocity_normal["velocity = target_velocity + (velocity - target_velocity) * exp(-water_drag * delta)"]
    timer --> move_and_slide["move_and_slide()"]
    start_dash --> move_and_slide
    velocity_normal --> move_and_slide
    move_and_slide --> World["物理世界（CharacterBody2D）"]
```

- `get_movement_input()` 每個物理幀讀取移動輸入，輸出長度不超過 `1` 的 `Vector2`，斜向移動不會因此加速。
- `update_movement()` 根據是否衝刺計算速度：
  - 衝刺中：直接設定為 `dash_direction * dash_speed`
  - 非衝刺：使用水中阻力模型計算速度
- `move_and_slide()` 將速度應用到物理世界

### 部件依賴

| 依賴 | 說明 |
| --- | --- |
| `Input.get_vector()` | 讀取 `move_left`、`move_right`、`move_up`、`move_down` 並轉為方向向量 |
| `Input.is_action_just_pressed()` | 檢測單次按鍵按下事件（用於 dash） |
| `CharacterBody2D` | 提供 `velocity`、`move_and_slide()` 等移動相關 API |

## 機制

### 機制 1：水中移動

#### 目的

利用 `W`, `A`, `S`, `D` 與方向鍵控制玩家在水中的移動，並模擬水的阻力感。

#### 行為

- 按下按鍵時，玩家逐漸加速至預期終端速度；鬆開按鍵時，則逐漸減速至零。
- 移動手感模擬水中阻力，具有平滑的加減速過渡。

#### 實做

為模擬水中阻力，使用線性的阻力將按下按鍵時的加速度寫成：

$$
\frac{d\vec{v}}{dt} = \vec{a} - k\vec{v}
$$

其中 $\frac{d\vec{v}}{dt}$ 為玩家的加速度；$\vec{a}$ 為輸入方向乘上 `acceleration` 得到的驅動加速度；$k$ 為模擬的水中阻力，$\vec{v}$ 則是現在的速度。

因此，解出微分方程後，$\vec{v}(t)$ 可以寫成：

$$
\vec{v}(t) = \frac{\vec{a}}{k} + \left(\vec{v}_0 - \frac{\vec{a}}{k}\right)e^{-kt}
$$

其中 $\vec{v}_0$ 為初速。當 $t \to \infty$ 時，$\vec{v}(t) \to \dfrac{\vec{a}}{k}$（終端速度）。

#### 證明

可以使用積分因子法：對於 $y'(x) + a(x)y(x) = b(x)$，令積分因子為：

$$
\mu(x) = e^{\int a(x)\ dx}
$$

則 $y(x)$ 可以表示成：

$$
y(x) = \frac{1}{\mu(x)} \left(\int \mu(x) b(x)\ dx + C\right)
$$

以 $y = \vec{v}$、$a(t) = k$、$b(t) = \vec{a}$ 帶入，先求積分因子 $\mu(t)$：

$$
\mu(t) = e^{\int k\ dt} = e^{kt}
$$

將 $\mu(t)$ 代入通解公式：

$$
\begin{aligned}
\vec{v}(t) &= e^{-kt} \left(\int e^{kt} \cdot \vec{a}\ dt + C\right) \\
&= e^{-kt} \left(\frac{\vec{a}}{k} e^{kt} + C\right) \\
&= \frac{\vec{a}}{k} + Ce^{-kt}
\end{aligned}
$$

若令初速 $\vec{v}_0 = \vec{v}(0)$，則可以解出 $C$：

$$
\begin{aligned}
\vec{v}_0 &= \frac{\vec{a}}{k} + C \\
C &= \vec{v}_0 - \frac{\vec{a}}{k}
\end{aligned}
$$

帶回可得：

$$
\vec{v}(t) = \frac{\vec{a}}{k} + \left(\vec{v}_0 - \frac{\vec{a}}{k}\right)e^{-kt}
$$

#### 程式碼

```gdscript
func update_movement(direction: Vector2, delta: float) -> void:
    # ...（省略 dash 邏輯）...

    var target_velocity := direction * acceleration / water_drag
    velocity = target_velocity + (velocity - target_velocity) * exp(-water_drag * delta)
```

| 變數 | 意義 |
| --- | --- |
| `direction * acceleration` | $\vec{a}$ |
| `water_drag` | $k$ |
| `target_velocity` | $\frac{\vec{a}}{k}$ |
| `velocity` | $\vec{v}(t), \vec{v}_0$ |
| `delta` | $t$ |

由於此函式會計算出下一時刻的速度，所以 `velocity` 同時是 $\vec{v}(t)$ 與 $\vec{v}_0$。

#### 參數

可以調整的參數如下：

| 參數 | 意義 |
| --- | --- |
| `acceleration` | 加速度（`@export`，預設 `800.0`） |
| `water_drag` | 水中模擬阻力（`@export`，預設 `4.0`） |

#### 限制

- 移動方向依賴於 Godot 專案設定中的輸入映射（`move_left`, `move_right`, `move_up`, `move_down`），而非直接綁定特定按鍵。
- `water_drag` 必須大於零；目前程式未檢查此條件，設為零會使終端速度計算發生除以零。
- 未處理碰撞後的反饋行為（例如推動、反彈等）。

### 衝刺

#### 目的

提供玩家在短時間內快速移動的能力，增加操作深度與逃生/追擊的策略性。

#### 行為

- 在未衝刺且冷卻結束時，按下 `dash`（目前映射為 `Shift`）會朝當前輸入方向以 `dash_speed` 的速度進行衝刺；持續按住不會自動重複觸發。
- 衝刺啟動時設定 `dash_timer = dash_duration`；後續物理幀遞減計時，到期時清除衝刺狀態。到期當幀仍設定衝刺速度，下一物理幀才進入一般移動分支，以水阻力公式平滑調整速度。
- 冷卻從衝刺啟動時開始，與衝刺同時倒數；使用預設時長時，衝刺結束後約還有 `0.85` 秒冷卻，實際時點受物理幀間隔影響。
- 若無移動輸入（方向為零向量），則不觸發衝刺。

#### 實做

```gdscript
func update_movement(direction: Vector2, delta: float) -> void:

    # update dash cooldown
    cooldown_timer = maxf(cooldown_timer - delta, 0.0)

    if is_dashing:
        dash_timer -= delta

        velocity = dash_direction * dash_speed

        if dash_timer <= 0.0:
            is_dashing = false
        
        return

    if get_sprint_input() and cooldown_timer <= 0.0:
        start_dash(direction)
        return

    # ...（省略 water_drag <= 0.0 邏輯）...

    var target_velocity := direction * acceleration / water_drag
    velocity = target_velocity + (velocity - target_velocity) * exp(-water_drag * delta)
```

狀態追蹤變數：

| 變數 | 類型 | 意義 |
| --- | --- | --- |
| `is_dashing` | `bool` | 是否處於衝刺狀態 |
| `dash_timer` | `float` | 衝刺剩餘時間 |
| `cooldown_timer` | `float` | 冷卻倒數計時 |
| `dash_direction` | `Vector2` | 衝刺方向（已正規化） |

`start_dash()` 本身只檢查方向是否為零；是否正在衝刺、是否冷卻結束的限制由 `update_movement()` 處理。

觸發邏輯：

```gdscript
func start_dash(direction: Vector2) -> void:
    if direction == Vector2.ZERO:
        return

    is_dashing = true
    dash_direction = direction.normalized()
    dash_timer = dash_duration
    cooldown_timer = dash_cooldown

    velocity = dash_direction * dash_speed
```

#### 參數

| 參數 | 意義 | 腳本預設值 | `player.tscn` 使用值 |
| --- | --- | --- | --- |
| `dash_speed` | 衝刺速度（每秒移動像素） | `420.0` | `500.0`（場景覆寫） |
| `dash_duration` | 衝刺持續時間（秒） | `0.15` | `0.15` |
| `dash_cooldown` | 從衝刺啟動起算的冷卻時間（秒） | `1.0` | `1.0` |

單元測試以 `Player.new()` 建立玩家，使用腳本預設值，因此測試中的衝刺速度為 `420.0`。

#### 限制

- 衝刺方向在啟動時記錄，期間改變移動輸入不會轉向；目前沒有蓄力機制。
- 衝刺期間每幀設定固定的衝刺速度，不套用水中阻力；實際移動仍受 `move_and_slide()` 的碰撞處理影響。
- 零方向觸發時，`start_dash()` 直接返回；該幀不執行一般移動的水阻力計算，既有速度會保留到 `move_and_slide()`。
- 冷卻系統依賴記憶體計時器，未持久化（遊戲重新載入後重置）。

### 設計決策

| 決策 | 原因 |
| --- | --- |
| 使用微分方程模擬水中移動的加減速 | 提供平滑的水中阻力感；`acceleration` 與 `water_drag` 共同決定終端速度 `acceleration / water_drag`，`water_drag` 也決定速度收斂快慢 |
| 衝刺使用獨立狀態機（`is_dashing`）而非插值過渡 | 簡單明確，避免多狀態交疊造成的行為衝突；`0.15s` 時長夠短，瞬間切換不會突兀 |
| `@export` 所有可調參數 | 方便不寫程式的情況下快速測試不同手感數值 |
| `start_dash()` 內判斷 `direction == Vector2.ZERO` 並返回 | 避免無意間朝任意方向衝刺，提升操作明確性 |
| `update_movement()` 內判斷 `water_drag <= 0.0` | 定義 `water_drag` 為零或負數情況時，統一為無水中阻力的情況 |

### 測試

現有 [`test_player.gd`](../../game/tests/unit/test_player.gd) 包含以下九項單元測試：

| 測試函式 | 驗證內容 |
| --- | --- |
| `test_dash_without_direction` | 零方向不啟動衝刺、不設定冷卻 |
| `test_dash_speed` | 腳本預設衝刺速度為 `420.0` |
| `test_diagonal_dash` | 斜向衝刺速度正規化 |
| `test_dash_initialization` | 初始化衝刺狀態、方向與兩個計時器 |
| `test_dash_movement` | 衝刺期間維持原方向與速度，並遞減衝刺計時 |
| `test_dash_ends` | 衝刺計時到期後清除狀態 |
| `test_water_drag` | 無輸入時速度依指數衰減 |
| `test_acceleration` | 有輸入時速度依公式接近終端速度 |
| `test_cooldown` | 冷卻計時不會小於零 |
| `test_zero_water_drag` | `water_drag` 為零應無水中阻力 |
| `test_negative_water_drag` | `water_drag` 為負數應無水中阻力 |

待補充驗證：

- [ ] 實際按鍵輸入與八方向移動
- [ ] 水中加減速手感與碰撞行為
- [ ] 透過輸入觸發衝刺，以及冷卻期間無法再次觸發

執行方式請參考 [測試文件](../測試.md)。

### 未來開發

- [ ] 加入視覺特效（衝刺殘影、粒子效果等）
- [ ] 支援蓄力衝刺（按越久衝越遠）
- [ ] 支援多次衝刺儲存與充能恢復（目前為單一冷卻倒數，會自動遞減）
- [ ] 添加移動音效與碰撞反饋
