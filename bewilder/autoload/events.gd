extends Node

signal kill_plane_touched(body: PhysicsBody3D)
signal flag_reached

var unlocked_blueprints : Array[String]
