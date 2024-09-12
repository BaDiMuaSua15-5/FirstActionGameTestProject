@tool
extends Area2D
class_name UpgradePickup

@export var sprite: Sprite2D
@export var upgrade_label: Label
@export var upgrade_resource: BaseUpgrade:
	set(new_resource):
		upgrade_resource = new_resource
		needs_update = true

var needs_update: bool = false
var default_texture := preload("res://icon.svg") as Texture2D
var default_label_text := "Upgrade Text"
var picked_up: bool = false


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if needs_update:
			sprite.texture = upgrade_resource.texture if upgrade_resource.texture else default_texture
			upgrade_label.text = upgrade_resource.upgrade_name
			needs_update = false
			var check := upgrade_resource
			#if check == null:
				#sprite.texture = default_texture
				#upgrade_label.text = default_label_text
	else:
		if !upgrade_resource:
			sprite.texture = default_texture
			upgrade_label.text = default_label_text


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerObj && !picked_up:
		if upgrade_resource is HealthHealUpgrade:
			upgrade_resource.apply_upgrade_(body)
			on_pick_up()
		else:
			var upgrades_container := (body.Upgrades as UpgradesComponent).upgrades_container
			upgrades_container.append(upgrade_resource)
			on_pick_up()


func on_pick_up() -> void:
	picked_up = true
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
