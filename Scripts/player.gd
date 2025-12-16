extends CharacterBody2D

@onready var PlayerHitbox: Area2D = $Area2D
@onready var InvButton: TextureButton = $InvUI/InvButton
@onready var InvUI: Control = $InvUI
@onready var ScoreLabel: Label = $Control/Label

const SPEED = 120.0
const BulletSpeed = 1000
const JUMP_VELOCITY = -400.0
var max_health: int = 1000
var health: float = max_health
var MouseDir = 0
var shoot_cooldown := 1.25  # seconds between shots
var last_shot_time := 0.0  # last time we fired
var level: int = 0
var score: int = 0
var InvOpen := false
var InvClosedPos: Vector2
var InvTween: Tween
var AnimSpeed = 0.125
var xp = 0
var ReqXp = 100
var AbilitySlots := {"Main": null, "Secondary": null, "Utility": null}
var PassiveAbilities: Array[AbilityData] = []
var AbilityTimers := {}

signal player_spawned(player)

func _ready():
	add_to_group("Player")
	Data.register_player(self)
	player_spawned.emit(self)
	InvClosedPos = InvUI.position

func _input(event):
	if Input.is_action_pressed("Fire"):
		trigger_slot("Main")

	if Input.is_action_just_pressed("AbilityKey1"):
		trigger_slot("Secondary")

	if Input.is_action_just_pressed("AbilityKey2"):
		trigger_slot("Utility")

func _physics_process(_delta: float) -> void:
	#MouseDir = (get_global_mouse_position() - global_position).normalized()
	#if Input.is_action_just_pressed("Fire"):
		#try_shoot()
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.dd
	var direction := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2(0, 0)
		
	move_and_slide()

func get_cooldown_percent() -> float:
	var now = Time.get_ticks_msec() / 1000.0
	var progress = (now - last_shot_time) / shoot_cooldown
	return clamp(progress, 0.0, 1.0)

#func try_shoot():
	#var now = Time.get_ticks_msec() / 1000.0  # convert ms → seconds
#
	#if now - last_shot_time >= shoot_cooldown:
		#shoot()
		#last_shot_time = now

func shoot():
	var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	bullet.global_position = PlayerHitbox.global_position
	bullet.direction = MouseDir
	bullet.rotation = bullet.direction.angle()
	get_tree().get_current_scene().add_child(bullet)

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		queue_free()

func LevelUp():
	level += 1

func InvButtonPressed():
	InvOpen = !InvOpen

	# Kill existing tween if button is spammed
	if InvTween and InvTween.is_running():
		InvTween.kill()

	InvTween = create_tween()
	InvTween.set_trans(Tween.TRANS_QUAD)
	InvTween.set_ease(Tween.EASE_OUT)

	var target_pos: Vector2

	if InvOpen:
		target_pos = InvClosedPos + Vector2(138, 0)
	else:
		target_pos = InvClosedPos

	InvTween.tween_property(
		InvUI,
		"position",
		target_pos,
		AnimSpeed # animation duration (seconds)
	)
func UseAbility(AbilityID):
	match AbilityID:
		"shoot":
			shoot()

func register_ability(ability: AbilityData):
	if ability.slot == "Passive":
		PassiveAbilities.append(ability)
		return

	# Replace existing ability in the slot
	AbilitySlots[ability.slot] = ability

	# Setup cooldown tracking
	AbilityTimers[ability.id] = {
		"cooldown": ability.cooldown,
		"last_used": -999.0
	}

func trigger_slot(slot_name: String):
	var ability: AbilityData = AbilitySlots[slot_name]
	if not ability:
		return

	UseAbility(ability.id)
