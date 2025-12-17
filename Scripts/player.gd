extends CharacterBody2D

@onready var PlayerHitbox: Area2D = $Area2D
@onready var InvButton: TextureButton = $InvUI/InvButton
@onready var InvUI: Control = $InvUI
@onready var ScoreLabel: Label = $Control/Label

@export var StartingAbilities: Array[AbilityData] = [preload("uid://ob8a14jt6xfa")]

signal LevelUpChoiceMade(choice)

const SPEED = 120.0
const BulletSpeed = 1000
const JUMP_VELOCITY = -400.0
var MaxHealth: int = 1000
var Health: float = MaxHealth
var MouseDir: Vector2 = Vector2.ZERO
var ShootCooldown := 1.25  # seconds between shots
var LastShotTime := 0.0  # last time we fired
var level: int = 0
var score: int = 0
var InvOpen := false
var InvClosedPos: Vector2
var InvTween: Tween
var AnimSpeed = 0.125
var xp = 0
var ReqXp = 100
var WaitForLevelUpInput := false
var AbilitySlots := {"Main": null, "Secondary": null, "Utility": null}
var PassiveAbilities: Array[AbilityData] = []
var AbilityTimers := {}

signal player_spawned(player)

func _ready():
	add_to_group("Player")
	Data.register_player(self)
	player_spawned.emit(self)
	InvClosedPos = InvUI.position
	for Ability in StartingAbilities:
		RegisterAbility(Ability)

func _input(Event: InputEvent) -> void:
	if WaitForLevelUpInput:
		if Event.is_action_pressed("Select1"):
			LevelUpChoiceMade.emit(1)
		elif Event.is_action_pressed("Select2"):
			LevelUpChoiceMade.emit(2)
		elif Event.is_action_pressed("Select3"):
			LevelUpChoiceMade.emit(3)
		return # prevent normal gameplay input while paused
		
	if Event.is_action_pressed("Main"):
		print("Main pressed")
		TriggerSlot("Main")

	if Event.is_action_pressed("AbilityKey1"):
		TriggerSlot("Secondary")

	if Event.is_action_pressed("AbilityKey2"):
		TriggerSlot("Utility")

func _physics_process(_delta: float) -> void:
	MouseDir = (get_global_mouse_position() - global_position).normalized()
	#if Input.is_action_just_pressed("Fire"):
		#try_Shoot()
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
	var progress = (now - LastShotTime) / ShootCooldown
	return clamp(progress, 0.0, 1.0)

#func try_Shoot():
	#var now = Time.get_ticks_msec() / 1000.0  # convert ms → seconds
#
	#if now - LastShotTime >= Shoot_cooldown:
		#Shoot()
		#LastShotTime = now

func Shoot():
	var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	bullet.global_position = PlayerHitbox.global_position
	bullet.direction = MouseDir
	bullet.rotation = bullet.direction.angle()
	get_tree().get_current_scene().add_child(bullet)

func take_damage(amount: float):
	Health -= amount
	if Health < 0.1:
		queue_free()

func LevelUp():
	level += 1
	var AbilityTemplate = preload("uid://b7sfort6qr2pp")
	get_tree().paused = true

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
func UseAbility(Id: String) -> void:
	print("Use ability")

	if not AbilityTimers.has(Id):
		print("No id in AbilityTimers")
		return

	var Data = AbilityTimers[Id]
	var Now := Time.get_ticks_msec() / 1000.0

	if Now - Data["last_used"] < Data["cooldown"]:
		return

	Data["last_used"] = Now

	match Id:
		"Shoot":
			Shoot()
		_:
			push_warning("UseAbility: Unknown ability id -> " + Id)

func RegisterAbility(ability: AbilityData):
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

func TriggerSlot(slot_name: String):
	print("triggetslot func")
	var ability: AbilityData = AbilitySlots[slot_name]
	if not ability:
		print("Not ability")
		return
	print("ability")
	UseAbility(ability.id)
