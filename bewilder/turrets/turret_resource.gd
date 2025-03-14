class_name turret_resource extends Resource

@export var name : String
@export var model : PackedScene

@export var shoot_sound : AudioStream
@export var reload_sound : AudioStream


var ray_cast

@export_group("Stats")
@export var max_health : float = 100.0

#Rotação 
@export_group("Rotation")
# movement rates in degrees
@export var elevation_speed_deg: float = 5.0
@export var rotation_speed_deg: float = 5.0
# elevation constraints in degrees
@export var min_elevation_deg: float = 0.0
@export var max_elevation_deg: float = 60.0

### Weapon Logic
@export_group("Projectile")
@export var projectile_damage : float = 10.0
@export var projectile_speed: float = 5.0
@export_range(1, 50, 1, "suffix:unidade(s)") var projectile_pen : int = 1
@export_range(5.0, 100.0, 5.0, "suffix:segundo(s)") var projectile_life_time := 5.0
@export var knockbackForce : int = 5


@export var current_ammo := INF
@export var magazine_capacity := INF
@export var one_shot : bool = false
@export var auto_fire : bool = false
@export var max_fire_rate_ms : float = 50

const RAYCAST_DIST : float = 9999
