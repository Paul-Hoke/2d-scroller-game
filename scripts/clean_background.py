from PIL import Image
import os

def remove_background(path):
    print(f"Processing {path}...")
    try:
        img = Image.open(path).convert("RGBA")
        datas = img.getdata()
        
        newData = []
        width, height = img.size
        
        # Sample the 4 corners to find potential background colors
        corners = [
            (0, 0),
            (width - 1, 0),
            (0, height - 1),
            (width - 1, height - 1)
        ]
        
        bg_candidates = set()
        for pos in corners:
            bg_candidates.add(img.getpixel(pos))
            
        # Also sample a bit of the top border to catch gradients/noise
        for x in range(0, width, 10):
             bg_candidates.add(img.getpixel((x, 0)))

        # Filter: Only assume it's background if it's "light" (brightness > 200)
        # unless it's a specific colored background known to be used.
        # For now, we assume whitish backgrounds for generated assets.
        target_colors = []
        for c in bg_candidates:
            brightness = sum(c[:3]) / 3
            if brightness > 150: # Increased range to catch greyish backgrounds
                target_colors.append(c)
        
        print(f"Targeting colors for removal (samples): {len(target_colors)}")

        # Tolerance for color matching (Sum of absolute differences)
        # Increased to catch compression artifacts
        tolerance = 100 
        
        for item in datas:
            # If already transparent, keep it
            if item[3] == 0:
                newData.append(item)
                continue

            is_bg = False
            for target in target_colors:
                # Compare RGB only
                diff = abs(item[0] - target[0]) + abs(item[1] - target[1]) + abs(item[2] - target[2])
                if diff < tolerance:
                    is_bg = True
                    break
            
            if is_bg:
                newData.append((255, 255, 255, 0))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(path, "PNG")
        print(f"Saved cleaned image to {path}")
        
    except Exception as e:
        print(f"Error processing {path}: {e}")

files_to_clean = [
    "assets/player_spritesheet.png",
    "assets/enemy_turtle.png",
    "assets/player_idle.png",
    "assets/player_jump.png",
    "assets/player_walk1.png",
    "assets/player_walk2.png",
    "assets/enemy_bat_fly.png",
    "assets/enemy_mushroom.png",
    "assets/enemy_flying_turtle.png"
]

for file_path in files_to_clean:
    if os.path.exists(file_path):
        remove_background(file_path)
    else:
        print(f"File not found: {file_path}")
