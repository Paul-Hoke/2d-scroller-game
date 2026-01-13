from PIL import Image
import os

def remove_background(path):
    print(f"Processing {path}...")
    try:
        img = Image.open(path).convert("RGBA")
        datas = img.getdata()
        
        newData = []
        
        # We will assume the background is white or light grey/checkerboard.
        # Let's sample the top-left pixel to find the "primary" background color.
        bg_color = img.getpixel((0, 0))
        
        # Heuristic: If it's a checkerboard, we might have two main background colors.
        # Let's look at a few pixels to find a secondary background color if it exists.
        # We'll check the first 20 pixels.
        bg_colors = set()
        width, height = img.size
        
        # Sample the border to find background colors
        for x in range(min(50, width)):
             bg_colors.add(img.getpixel((x, 0)))
        for y in range(min(50, height)):
             bg_colors.add(img.getpixel((0, y)))
             
        # Filter for only light colors (checkerboards are usually white/grey)
        target_colors = []
        for c in bg_colors:
            # Check brightness. (r+g+b)/3
            brightness = sum(c[:3]) / 3
            if brightness > 200: # Only remove light colors
                target_colors.append(c)
        
        print(f"Targeting colors for removal: {target_colors}")

        tolerance = 30 
        
        for item in datas:
            is_bg = False
            for target in target_colors:
                # Euclidean distance or simple abs diff
                diff = sum([abs(item[i] - target[i]) for i in range(3)])
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

remove_background("assets/player_spritesheet.png")
remove_background("assets/enemy_turtle.png")
