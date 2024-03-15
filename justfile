# List all available tasks.
default:
    just --list

# Purge unused CSS, and minify result.
build-css: purge-css minify-css

# Extract critical CSS.
# https://github.com/addyosmani/critical/blob/master/README.md#cli
[private]
extract-critical-css:
    cat index.html | critical --inline > index.critical.html

# Purge unused CSS.
[private]
purge-css:
    npx purgecss --safelist :where --css css/pico.pumpkin.css --content index.html blogs/*.html --output css/pico.pumpkin.min.css
    npx purgecss --safelist :where --css css/stylesheet.css --content index.html blogs/*.html --output css/stylesheet.min.css

# Minify CSS.
[private]
minify-css:
    npx clean-css-cli -O2 specialComments:none css/pico.pumpkin.min.css -o css/pico.pumpkin.min.css
    npx clean-css-cli -O2 specialComments:none css/stylesheet.min.css -o css/stylesheet.min.css
