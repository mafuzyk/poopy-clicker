extends Area2D

const GameState = preload("res://scripts/core/game_state.gd")

enum State { WALK, IDLE, SCARE, PANIC }

const PANIC_SPEED_MIN_RATIO := 2.2
const PANIC_SPEED_MAX_RATIO := 3.0
const PANIC_VY_RATIO := 0.35
const SCARE_DURATION := 0.26
const IDLE_DURATION_MIN := 0.7
const IDLE_DURATION_MAX := 1.4
const BEHAVIOR_INTERVAL_MIN := 1.8
const BEHAVIOR_INTERVAL_MAX := 2.6
const FRAME_INTERVALS := {State.IDLE: 0.15, State.WALK: 0.1, State.SCARE: 0.07, State.PANIC: 0.06}
const IDLE_CHANCE := 0.25
const IDLE_CHANCE_CHARM := 0.12
const ESCAPE_MARGIN := 80.0
const BUTTON_MARGIN := 12.0
const PUSH_CONTACT_GOOBER_SHRINK := 0.25
const PUSH_CONTACT_BUTTON_SHRINK := 0.05
const JUMP_HEIGHT := 12.0
const FRAME_BASE_SIZE := 86.0
const HEAVY_BUTTON_PUSH_PENALTY := 3.0
const HEAVY_BUTTON_PUSH_MIN := 2.0
const PANIC_SHIELD_PUSH_PENALTY := 10.0
const PANIC_SHIELD_PUSH_MIN := 12.0

signal defeated

var type_id := "normal"
var state: int = State.WALK
var velocity := Vector2.ZERO
var hp := 1
var push_normal := 6.0
var push_panic := 28.0
var speed_min := 1.0
var speed_max := 2.0
var was_pushing := false
var state_timer := 0.0
var next_behavior_at := 0.0
var escaping := false
var half_size := 0.0
var frame_timer := 0.0
var frame_interval := 0.2

var game_state: GameState
var sprite: AnimatedSprite2D
var jump_tween: Tween


func setup(shared_frames: SpriteFrames, size_px: float, type_id_value: String, data: Dictionary, state_ref: GameState) -> void:
	input_pickable = false
	game_state = state_ref
	type_id = type_id_value
	hp = int(data["hp"])
	push_normal = float(data["push_normal"])
	push_panic = float(data["push_panic"])
	speed_min = float(data["speed_min"])
	speed_max = float(data["speed_max"])
	var draw_size := size_px * float(data["scale"])
	half_size = draw_size * 0.5

	sprite = AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sprite.sprite_frames = shared_frames
	sprite.scale = Vector2.ONE * (draw_size / FRAME_BASE_SIZE)
	sprite.modulate = Color(String(data.get("color", "ffffff")))
	add_child(sprite)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(draw_size, draw_size)
	collision.shape = shape
	add_child(collision)

	velocity = Vector2(
		randf_range(speed_min, speed_max) * draw_size * (1.0 if randf() < 0.5 else -1.0),
		randf_range(speed_min, speed_max) * draw_size * 0.8 * (1.0 if randf() < 0.5 else -1.0)
	)
	apply_facing()
	set_state(State.WALK, "walk")


func update(delta: float, button: Control, bounds: Rect2) -> void:
	# TEMP: visual RGB provisório (ciclo de matiz) até a identidade visual canônica.
	if type_id == "rgb":
		sprite.modulate = Color.from_hsv(fmod(Time.get_ticks_msec() / 1000.0 * 0.5, 1.0), 0.85, 1.0)
	advance_animation(delta)
	state_timer = maxf(0.0, state_timer - delta)
	next_behavior_at = maxf(0.0, next_behavior_at - delta)

	match state:
		State.WALK:
			handle_behavior()
			move(delta)
			bounce(bounds)
		State.IDLE:
			if state_timer <= 0.0:
				set_state(State.WALK, "walk")
		State.SCARE:
			if state_timer <= 0.0:
				start_panic()
		State.PANIC:
			move(delta)
			if not bounds.grow(ESCAPE_MARGIN).has_point(position):
				escaping = true

	push_button(button, bounds, delta)


func get_rect() -> Rect2:
	return Rect2(position - Vector2(half_size, half_size), Vector2(half_size * 2.0, half_size * 2.0))


func handle_click() -> void:
	if state == State.SCARE or state == State.PANIC:
		return
	hp -= 1
	jump()
	if hp > 0:
		return
	defeated.emit()
	set_state(State.SCARE, "scare")
	state_timer = SCARE_DURATION


func wants_despawn() -> bool:
	return escaping


func handle_behavior() -> void:
	if next_behavior_at > 0.0:
		return
	next_behavior_at = randf_range(BEHAVIOR_INTERVAL_MIN, BEHAVIOR_INTERVAL_MAX)
	var idle_chance: float = IDLE_CHANCE_CHARM if game_state.goober_charm_bought else IDLE_CHANCE
	if randf() < idle_chance:
		set_state(State.IDLE, "idle")
		state_timer = randf_range(IDLE_DURATION_MIN, IDLE_DURATION_MAX)


func move(delta: float) -> void:
	position += velocity * delta
	apply_facing()


func apply_facing() -> void:
	if velocity.x < 0.0:
		sprite.flip_h = true
	elif velocity.x > 0.0:
		sprite.flip_h = false


func bounce(bounds: Rect2) -> void:
	if position.x <= bounds.position.x or position.x >= bounds.end.x:
		velocity.x = -velocity.x
	if position.y <= bounds.position.y or position.y >= bounds.end.y:
		velocity.y = -velocity.y


func start_panic() -> void:
	set_state(State.PANIC, "panic")
	var direction := 1.0 if position.x < get_viewport_rect().size.x * 0.5 else -1.0
	var body_size := half_size * 2.0
	velocity = Vector2(
		direction * randf_range(PANIC_SPEED_MIN_RATIO, PANIC_SPEED_MAX_RATIO) * body_size,
		randf_range(-PANIC_VY_RATIO, PANIC_VY_RATIO) * body_size
	)
	apply_facing()


func randomize_walk() -> void:
	var body_size := half_size * 2.0
	velocity = Vector2(
		randf_range(speed_min, speed_max) * body_size * (1.0 if randf() < 0.5 else -1.0),
		randf_range(speed_min, speed_max) * body_size * 0.8 * (1.0 if randf() < 0.5 else -1.0)
	)
	apply_facing()


func turn_away(btn: Rect2) -> void:
	var away := (position - btn.get_center()).normalized()
	if away.length() < 0.1:
		away = Vector2(1.0 if randf() < 0.5 else -1.0, randf_range(-0.4, 0.4)).normalized()
	var body_size := half_size * 2.0
	velocity = away * randf_range(speed_min, speed_max) * body_size
	apply_facing()


func push_button(button: Control, bounds: Rect2, delta: float) -> void:
	if escaping or button == null:
		return
	if state != State.WALK and state != State.PANIC:
		return

	var btn := button.get_global_rect()
	var goober_rect := get_rect().grow(-half_size * PUSH_CONTACT_GOOBER_SHRINK)
	var contact_rect := btn.grow(-button.size.x * PUSH_CONTACT_BUTTON_SHRINK)
	if not goober_rect.intersects(contact_rect):
		if was_pushing:
			was_pushing = false
			if state == State.WALK:
				randomize_walk()
		return
	was_pushing = true

	var inward := Vector2.ZERO
	if velocity.x > 0.0 and position.x < btn.get_center().x:
		inward.x = 1.0
	elif velocity.x < 0.0 and position.x > btn.get_center().x:
		inward.x = -1.0
	if velocity.y > 0.0 and position.y < btn.get_center().y:
		inward.y = 1.0
	elif velocity.y < 0.0 and position.y > btn.get_center().y:
		inward.y = -1.0
	if inward == Vector2.ZERO:
		return

	# O botao sai da frente na mesma velocidade do goober: ele carrega o botao sem atravessar.
	var max_x := maxf(BUTTON_MARGIN, bounds.size.x - button.size.x - BUTTON_MARGIN)
	var max_y := maxf(BUTTON_MARGIN, bounds.size.y - button.size.y - BUTTON_MARGIN)
	var new_x := button.position.x
	var new_y := button.position.y
	if inward.x != 0.0:
		new_x = clampf(button.position.x + velocity.x * delta, BUTTON_MARGIN, max_x)
	if inward.y != 0.0:
		new_y = clampf(button.position.y + velocity.y * delta, BUTTON_MARGIN, max_y)
	var old_x := button.position.x
	var old_y := button.position.y
	button.position = Vector2(new_x, new_y)

	if state != State.PANIC:
		# Botao encostado na parede: goober desliza pela borda em vez de atravessar.
		if inward.x != 0.0 and new_x == old_x:
			velocity.x = 0.0
		if inward.y != 0.0 and new_y == old_y:
			velocity.y = 0.0
		if velocity.length() < 1.0:
			turn_away(btn)


func jump() -> void:
	if jump_tween:
		jump_tween.kill()
	sprite.position = Vector2(0.0, 0.0)
	jump_tween = create_tween()
	jump_tween.tween_property(sprite, "position:y", -JUMP_HEIGHT, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(sprite, "position:y", 0.0, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func set_state(new_state: int, animation: String) -> void:
	state = new_state
	frame_interval = FRAME_INTERVALS[new_state]
	frame_timer = frame_interval
	sprite.animation = animation
	sprite.frame = 0
	sprite.stop()


func advance_animation(delta: float) -> void:
	frame_timer -= delta
	if frame_timer > 0.0:
		return
	frame_timer = frame_interval
	var total_frames: int = sprite.sprite_frames.get_frame_count(sprite.animation)
	if total_frames <= 0:
		return
	sprite.frame = (sprite.frame + 1) % total_frames