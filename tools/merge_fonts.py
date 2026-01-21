from PIL import Image
import os

# Paths
gfx_dir = "src/graphics"
alpha_path = os.path.join(gfx_dir, "alphabet_8_wide.png")
score_path = os.path.join(gfx_dir, "scoredigits_8_wide.png")
target_path = os.path.join(gfx_dir, "unified_font.png")

# Verify inputs
if not os.path.exists(alpha_path) or not os.path.exists(score_path):
    print("Error: Source files not found.")
    exit(1)

try:
    img_alpha = Image.open(alpha_path)
    img_score = Image.open(score_path)
    
    # Dimensions
    # Height: Keep original 17px
    TARGET_H = 17
    
    # 1. Space: Alpha (0, 8)
    # 2. 0-9: Score (0, 80)
    # 3. A-Z: Alpha (8, 216)
    # 4. Punct: Alpha (216, 288) -> . ! ? , " $ ( ) :
    # 5. Prizes: Score (80, 128) -> A B C D E F (Remapped to * + - / < >)
    
    # Extract Crops
    # Define boxes as (left, upper, right, lower)
    
    # Space
    c_space = img_alpha.crop((0, 0, 8, TARGET_H))
    
    # Numbers 0-9
    c_nums = img_score.crop((0, 0, 80, TARGET_H))
    
    # Letters A-Z
    c_letters = img_alpha.crop((8, 0, 216, TARGET_H))
    
    # Punctuation
    c_punct = img_alpha.crop((216, 0, 288, TARGET_H))
    
    # Prizes (A-F from scoredigits)
    c_prizes = img_score.crop((80, 0, 128, TARGET_H))
    
    # Assembly
    # Order: Space + Nums + Letters + Punct + Prizes
    total_width = 8 + 80 + 208 + 72 + 48
    print(f"Total Width: {total_width}") # Should be 416
    
    unified = Image.new("P", (total_width, TARGET_H))
    
    # Paste
    x = 0
    
    unified.paste(c_space, (x, 0)); x += 8
    unified.paste(c_nums, (x, 0)); x += 80
    unified.paste(c_letters, (x, 0)); x += 208
    unified.paste(c_punct, (x, 0)); x += 72
    unified.paste(c_prizes, (x, 0)); x += 48
    
    # Copy palette from source (assume alphabet has correct palette)
    unified.putpalette(img_alpha.getpalette())
    
    unified.save(target_path)
    print(f"Successfully created {target_path} ({total_width}x{TARGET_H})")

except Exception as e:
    print(f"Error merging fonts: {e}")
    exit(1)
