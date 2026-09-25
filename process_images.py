from PIL import Image
import os

source_img = r'c:\Users\kevin\Documents\Arma 3\missions\takistanRestored.takistan\Images\20260621111605_1.jpg'
dest_dir = r'c:\Users\kevin\Documents\Arma 3\missions\takistanRestored.takistan'

print(f'Processing {source_img}...')
img = Image.open(source_img)
w, h = img.size

# 1. preview.jpg (Square, < 1MB)
# Crop center square
min_dim = min(w, h)
left = (w - min_dim) / 2
top = (h - min_dim) / 2
right = (w + min_dim) / 2
bottom = (h + min_dim) / 2
img_sq = img.crop((left, top, right, bottom))
img_sq = img_sq.resize((512, 512), Image.Resampling.LANCZOS)
img_sq.save(os.path.join(dest_dir, 'preview.jpg'), quality=90)
print('Created preview.jpg')

# 2. loadScreen.jpg (2:1 ratio)
# Crop center 2:1
target_w = w
target_h = w // 2
if target_h > h:
    target_h = h
    target_w = h * 2

left = (w - target_w) / 2
top = (h - target_h) / 2
right = (w + target_w) / 2
bottom = (h + target_h) / 2
img_2_1 = img.crop((left, top, right, bottom))
img_2_1 = img_2_1.resize((1024, 512), Image.Resampling.LANCZOS)
img_2_1.save(os.path.join(dest_dir, 'loadScreen.jpg'), quality=90)
print('Created loadScreen.jpg')

# 3. overviewPicture.jpg (2:1 ratio)
# We can use the same 2:1 image
img_2_1.save(os.path.join(dest_dir, 'overviewPicture.jpg'), quality=90)
print('Created overviewPicture.jpg')
