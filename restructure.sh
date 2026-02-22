#!/bin/bash
# ============================================================
#  Run this from inside your local 'hits' repo root.
#  It reorganises everything into a clean structure
#  and prepares it for GitHub Pages hosting.
#
#  BEFORE running: make sure you've committed or backed up
#  your current state so nothing is lost.
#
#  Usage:
#    cd /path/to/hits
#    bash restructure.sh
# ============================================================

set -e

echo "==> Creating directory structure..."
mkdir -p images/vista
mkdir -p css

# -----------------------------------------------------------
#  Move Vista gallery photos into images/vista/
# -----------------------------------------------------------
echo "==> Moving Vista photos..."
for f in IMG_3257.JPG IMG_3258.JPG IMG_3259.JPG IMG_3262.JPG IMG_3263.JPG \
         IMG_3302.JPG IMG_3303.JPG IMG_3304.JPG IMG_3325.JPG IMG_3330.JPG \
         IMG_3331.JPG IMG_3332.JPG IMG_3360.JPG IMG_3363.JPG IMG_3374.JPG \
         IMG_3409.JPG IMG_3410.JPG IMG_3413.JPG IMG_3414.JPG IMG_3415.JPG \
         IMG_3820.JPG IMG_3821.JPG IMG_3822.JPG IMG_3954.JPG IMG_3976.JPG \
         IMG_4107.JPEG IMG_4108.JPEG IMG_4117.JPEG IMG_4209.JPEG \
         IMG_4228.JPEG IMG_4241.JPEG IMG_4267.JPEG IMG_4421.JPEG \
         IMG_4438.JPEG IMG_4679.JPEG IMG_4693.JPEG IMG_4639.JPEG \
         kodachadri.jpg; do
    [ -f "$f" ] && git mv "$f" images/vista/ && echo "   moved $f"
done

# -----------------------------------------------------------
#  Move profile photo
# -----------------------------------------------------------
echo "==> Moving profile photo..."
[ -f "IMG_-77er7q-01.JPEG" ] && git mv "IMG_-77er7q-01.JPEG" images/profile.jpeg && echo "   moved profile photo"

# -----------------------------------------------------------
#  Move CSS
# -----------------------------------------------------------
echo "==> Moving CSS..."
[ -f "ahh.css" ] && git mv ahh.css css/style.css && echo "   moved ahh.css -> css/style.css"

# -----------------------------------------------------------
#  Remove files that don't belong
# -----------------------------------------------------------
echo "==> Removing junk files..."
[ -f "main.py" ] && git rm main.py && echo "   removed main.py"
[ -f "photo_collage_1.html" ] && git rm photo_collage_1.html && echo "   removed photo_collage_1.html"
[ -f "test_python.png" ] && git rm test_python.png && echo "   removed test_python.png"
[ -d ".idea" ] && git rm -r .idea && echo "   removed .idea/"

echo ""
echo "==> Done moving files."
echo ""
echo "==> Updating file references..."

# Fix CSS path in index.html
sed -i 's|href="ahh.css"|href="css/style.css"|g' index.html
echo "   updated CSS path in index.html"

# Fix profile image path in index.html (if it exists)
sed -i 's|src="IMG_-77er7q-01.JPEG"|src="images/profile.jpeg"|g' index.html
echo "   updated profile image path in index.html"

# Fix all image paths in vista.html
sed -i 's|src: "IMG_|src: "images/vista/IMG_|g' vista.html
sed -i 's|src: "kodachadri.jpg"|src: "images/vista/kodachadri.jpg"|g' vista.html
echo "   updated all image paths in vista.html"

echo ""
echo "==> All done. Review the changes, then:"
echo "       git add -A"
echo "       git commit -m 'restructure: clean directory layout'"
echo "       git push origin main"
echo ""
echo "==> To host on GitHub Pages:"
echo "       Go to repo Settings > Pages > Source: Deploy from branch > main / root"
echo "       Your site will be live at: https://ro-hits.github.io/hits/"
