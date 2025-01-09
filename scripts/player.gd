extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -340.0
const DASH_SPEED = 400.0
const GRAVITY = 980  # 定义重力常量

@onready var animation_player = $AnimatedSprite2D
@onready var sprite = $Sprite2D

# 状态控制
var is_dashing: bool = false
var can_dash: bool = true
var facing_right: bool = true

func _physics_process(delta: float) -> void:
	# 添加重力效果
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# 处理跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
	
	# 处理左右移动
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		animation_player.play("run")
		
		# 处理朝向
		if direction > 0 and not facing_right:
			flip_character(true)
		elif direction < 0 and facing_right:
			flip_character(false)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animation_player.play("default")
	
	# 处理翻滚和空中攻击（使用同一个按键）
	if Input.is_action_just_pressed("roll"):
		if is_on_floor():
			# 在地面上触发翻滚
			animation_player.play("roll")
		else:
			# 在空中触发攻击
			animation_player.play("hit_down")
	
	# 处理冲刺
	if Input.is_action_just_pressed("dash") and can_dash:
		perform_dash()
	
	move_and_slide()

# 翻转角色朝向
func flip_character(face_right: bool) -> void:
	facing_right = face_right
	animation_player.flip_h = !face_right

# 执行冲刺
func perform_dash() -> void:
	is_dashing = true
	can_dash = false
	animation_player.play("jump_dash")
	
	# 根据朝向决定冲刺方向
	var dash_direction = 1 if facing_right else -1
	velocity.x = DASH_SPEED * dash_direction
	
	# 创建一个计时器来结束冲刺状态
	await get_tree().create_timer(0.3).timeout
	is_dashing = false
	
	# 冲刺冷却
	await get_tree().create_timer(1.0).timeout
	can_dash = true 
