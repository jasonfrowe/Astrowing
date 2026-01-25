from PIL import Image
import os
import math

def generate_sprites():
    source_path = "src/graphics/sprite_spaceship1.png"
    output_dir = "src/graphics"
    
    if not os.path.exists(source_path):
        print(f"Error: {source_path} not found.")
        return

    # Load source
    # Keep original for palette application later
    orig = Image.open(source_path)
    im = orig.convert("RGBA")
    
    # Target Pivot in original 16x16 image: (7, 8)
    # Note: Pixel coordinates. Center of pixel 7,8 is 7.5, 8.5?
    # User said "center placed at 7,8". 
    # Usually this means the pixel at x=7, y=8 is the axis.
    pivot_x = 7
    pivot_y = 8
    
    # 7800 Res: Wide Pixels (2x1 ratio).
    # To rotate correctly, we stretch width by 2x.
    # New dimensions: 32x16.
    # New Pivot: x=14, y=8.
    
    # Scale width x2 (Nearest Neighbor to preserve pixel art)
    im_stretched = im.resize((32, 16), Image.NEAREST)
    
    
    # 7800 Res: Wide Pixels (2x1 ratio).
    # To fix pivot drift, we need to rotate around correct sub-pixel center.
    # Scale width x4, Height x2.
    # Source Pixel 7 (Width) -> 4 pixels [28,29,30,31]. Center vertex 30.0.
    # Source Pixel 8 (Height) -> 2 pixels [16,17]. Center vertex 17.0.
    # This allows rotation around (30.0, 17.0).
    im_stretched = im.resize((64, 32), Image.NEAREST)
    
    # Canvas with Vertex Center (Even size)
    canvas_size = 128
    canvas_center = canvas_size // 2 # 64.0
    
    # Paste offset:
    # Canvas Center (64,64) aligns with Image Pivot (30,17).
    # Paste X = 64 - 30 = 34
    # Paste Y = 64 - 17 = 47
    
    for i in range(2, 17):
        angle = -22.5 * (i - 1)
        
        # Create canvas
        canvas = Image.new("RGBA", (canvas_size, canvas_size), (0,0,0,0))
        canvas.paste(im_stretched, (34, 47))
        
        result_rgb = Image.new("RGB", (canvas_size, canvas_size), (0, 0, 0))
        result_rgb.paste(canvas, mask=canvas.split()[3])
        
        # Rotate (Bicubic gives better anti-aliasing but Nearest protects palette)
        # Using Nearest for strict palette compliance
        rotated = result_rgb.rotate(angle, resample=Image.NEAREST)
        
        # Crop back
        # Size 64x32 centered at 64,64.
        # Left: 64 - 32 = 32
        # Top: 64 - 16 = 48
        # Right: 64 + 32 = 96
        # Bottom: 64 + 16 = 80
        result_cropped = rotated.crop((32, 48, 96, 80))
        
        # Scale Down
        result = result_cropped.resize((16, 16), Image.NEAREST)
        
        # Convert back to Indexed Color (P) using original palette
        result_indexed = result.quantize(palette=orig, dither=0)
        
        # Save
        filename = f"sprite_spaceship{i}.png"
        result_indexed.save(os.path.join(output_dir, filename))
        print(f"Generated {filename}")

if __name__ == "__main__":
    generate_sprites()
