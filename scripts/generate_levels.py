import os
import random

def generate_level(level_num):
    next_level = f"res://scenes/levels/Level{level_num + 1}.tscn" if level_num < 20 else "res://scenes/ui/Victory.tscn"
    
    # Difficulty parameters
    length = 3000 + (level_num * 200)
    gap_max = 200 + (level_num * 10) # Max gap between platforms
    if gap_max > 400: gap_max = 400
    
    # Resources
    content = """[gd_scene load_steps=16 format=3]

[ext_resource type="PackedScene" path="res://scenes/actors/Player.tscn" id="1_player"]
[ext_resource type="PackedScene" path="res://scenes/levels/ParallaxBackground.tscn" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/actors/Enemy.tscn" id="3_enemy"]
[ext_resource type="PackedScene" path="res://scenes/ui/HUD.tscn" id="4_hud"]
[ext_resource type="PackedScene" path="res://scenes/objects/Coin.tscn" id="5_coin"]
[ext_resource type="PackedScene" path="res://scenes/objects/Goal.tscn" id="6_goal"]
[ext_resource type="PackedScene" path="res://scenes/actors/EnemyFlying.tscn" id="7_bat"]
[ext_resource type="PackedScene" path="res://scenes/actors/EnemyMushroom.tscn" id="8_mush"]
[ext_resource type="PackedScene" path="res://scenes/actors/EnemyFlyingTurtle.tscn" id="9_flyt"]
[ext_resource type="PackedScene" path="res://scenes/ui/PauseMenu.tscn" id="10_pause"]
[ext_resource type="Script" path="res://scripts/LevelLogic.gd" id="11_logic"]
[ext_resource type="PackedScene" path="res://scenes/objects/Key.tscn" id="12_key"]
[ext_resource type="PackedScene" path="res://scenes/objects/Door.tscn" id="13_door"]
[ext_resource type="PackedScene" path="res://scenes/objects/Powerup.tscn" id="14_powerup"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_floor"]
size = Vector2(800, 100)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_plat"]
size = Vector2(200, 20)

[node name=\"Level{0}\" type=\"Node2D\"]
script = ExtResource(\"11_logic\")

[node name=\"HUD\" parent=\".\" instance=ExtResource(\"4_hud\")]
[node name=\"PauseMenu\" parent=\".\" instance=ExtResource(\"10_pause\")]

[node name=\"ParallaxBackground\" parent=\".\" instance=ExtResource(\"2_bg\")]

[node name=\"LevelGeometry\" type=\"Node\" parent=\".\"]
""".format(level_num)

    # Start Floor
    content += """
[node name="StartFloor" type="StaticBody2D" parent="LevelGeometry"]
position = Vector2(400, 600)

[node name="CollisionShape2D" type="CollisionShape2D" parent="LevelGeometry/StartFloor"]
shape = SubResource("RectangleShape2D_floor")

[node name="ColorRect" type="ColorRect" parent="LevelGeometry/StartFloor"]
offset_left = -400.0
offset_top = -50.0
offset_right = 400.0
offset_bottom = 50.0
color = Color(0.27, 0.50, 0.27, 1)
"""

    # Procedural Platforms
    current_x = 800
    current_y = 500
    plat_index = 0
    
    enemies_content = """[node name="Enemies" type="Node" parent="."]
"""
    collectibles_content = """[node name="Collectibles" type="Node" parent="."]
"""
    geometry_extras = ""
    
    enemy_types = [
        {"id": "3_enemy", "name": "Turtle", "y_offset": 0},
        {"id": "7_bat", "name": "Bat", "y_offset": -150},
        {"id": "8_mush", "name": "Mush", "y_offset": 0},
        {"id": "9_flyt", "name": "FlyTurtle", "y_offset": -100},
    ]

    # Metroidvania Planning
    # Key usually around 40-60% of the way
    # Door usually around 80-90% of the way
    total_platforms_est = int((length - 800) / 250)
    key_plat_idx = random.randint(int(total_platforms_est * 0.4), int(total_platforms_est * 0.6))
    door_plat_idx = random.randint(int(total_platforms_est * 0.8), int(total_platforms_est * 0.9))
    
    # Powerup: Double Jump in Level 2
    powerup_plat_idx = -1
    if level_num == 2:
        powerup_plat_idx = 3 # Early in level 2

    while current_x < length:
        # Platform
        plat_index += 1
        gap = random.randint(150, gap_max)
        y_change = random.randint(-100, 100)
        
        # Force key platform high
        if plat_index == key_plat_idx:
            current_y = 250 # High up
            y_change = 0
            
        current_x += gap
        current_y += y_change
        
        # Clamp Y
        if current_y < 200: current_y = 200
        if current_y > 550: current_y = 550
        
        content += """
[node name=\"Plat{0}\" type=\"StaticBody2D\" parent=\"LevelGeometry\"]
position = Vector2({1}, {2})

[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"LevelGeometry/Plat{0}\"]
shape = SubResource(\"RectangleShape2D_plat\")

[node name=\"ColorRect\" type=\"ColorRect\" parent=\"LevelGeometry/Plat{0}\"]
offset_left = -100.0
offset_top = -10.0
offset_right = 100.0
offset_bottom = 10.0
color = Color(0.42, 0.36, 0.25, 1)
""".format(plat_index, int(current_x), int(current_y))

        # Metroidvania Elements
        if plat_index == key_plat_idx:
             collectibles_content += """
[node name="Key" parent="Collectibles" instance=ExtResource("12_key")]
position = Vector2({0}, {1})
""".format(int(current_x), int(current_y) - 50)
        
        elif plat_index == door_plat_idx:
            # Door sits on the platform
            geometry_extras += """
[node name="Door" parent="LevelGeometry" instance=ExtResource("13_door")]
position = Vector2({0}, {1})
""".format(int(current_x), int(current_y) - 42) # Adjust for door size (64px high, origin center)
        
        elif plat_index == powerup_plat_idx:
             collectibles_content += """
[node name="Powerup" parent="Collectibles" instance=ExtResource("14_powerup")]
position = Vector2({0}, {1})
""".format(int(current_x), int(current_y) - 50)

        # Standard Spawns (Enemies/Coins) - Don't spawn on special platforms to avoid clutter
        elif plat_index != key_plat_idx and plat_index != door_plat_idx:
            # Chance for enemy
            if random.random() < 0.4 + (level_num * 0.01):
                enemy = random.choice(enemy_types)
                enemies_content += """
[node name="{0}{1}" parent="Enemies" instance=ExtResource("{2}")]
position = Vector2({3}, {4})
""".format(enemy["name"], plat_index, enemy["id"], int(current_x), int(current_y) + enemy["y_offset"])

            # Chance for coin
            if random.random() < 0.5:
                 collectibles_content += """
[node name="Coin{0}" parent="Collectibles" instance=ExtResource("5_coin")]
position = Vector2({1}, {2})
""".format(plat_index, int(current_x), int(current_y) - 50)
             
        current_x += 100 # Platform width buffer

    # Final Floor
    final_x = current_x + 400
    content += """
[node name=\"EndFloor\" type=\"StaticBody2D\" parent=\"LevelGeometry\"]
position = Vector2({0}, 600)

[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"LevelGeometry/EndFloor\"]
shape = SubResource(\"RectangleShape2D_floor\")

[node name=\"ColorRect\" type=\"ColorRect\" parent=\"LevelGeometry/EndFloor\"]
offset_left = -400.0
offset_top = -50.0
offset_right = 400.0
offset_bottom = 50.0
color = Color(0.27, 0.50, 0.27, 1)
""".format(int(final_x))

    content += geometry_extras
    content += enemies_content
    content += collectibles_content

    # Goal
    content += """
[node name=\"Goal\" parent=\".\" instance=ExtResource(\"6_goal\")]
position = Vector2({0}, 500)
next_level_path = \"{1}\"

[node name=\"Player\" parent=\".\" instance=ExtResource(\"1_player\")]
position = Vector2(100, 500)
""".format(int(final_x + 200), next_level)

    return content

if __name__ == "__main__":
    # Generate Levels 2-20 (Level 1/Main is manual)
    for i in range(2, 21):
        fname = f"scenes/levels/Level{i}.tscn"
        print(f"Generating {fname}...")
        data = generate_level(i)
        with open(fname, "w") as f:
            f.write(data)
    print("Done.")
