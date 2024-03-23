# List all available tasks.
default:
    just --list

#-------------------------------------------------------------------------------
# CSS
#

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

#-------------------------------------------------------------------------------
# Blogs
#

# Create an empty Markdown file.
create-blog slug:
    echo -e ":meta\ndescription = SEO description\npublish_date = $(date '+%Y-%m-%d')\n:meta\n# Blog Title\nWrite something awesome!" > "blogs/markdowns/$(date '+%Y-%m-%d')-{{ slug }}.md"

# Generate an HTML from Markdown.
generate-blog slug:
    blogs-md-easy -t blogs/markdowns/template.html -m blogs/markdowns/{{ slug }}.md -o blogs

# Run the generate script for all Markdowns.
regenerate-blogs:
    blogs-md-easy -t blogs/markdowns/template.html -m blogs/markdowns/*.md -o blogs
