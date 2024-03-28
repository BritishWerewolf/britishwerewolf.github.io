# British Werewolf Personal Site
It's true, I don't have a domain or hosting, I figured this repo would be enough.  
And you know what? It is!

## Can I clone it?
Sure.  
Though, I don't know why you'd want to.

I have plans to make this a better static site generation (SSG) process, but in the mean time it's just a few HTML files with Pico CSS as a CSS framework.

### Just do it
This repo uses [`just`](https://github.com/casey/just) to manage various functionality.

* `build-css` - Will purge and minify the `pico.css` and `stylesheet.css` files.
* `create-blog slug` - Create a Markdown file with the given slug, in the `blogs/markdowns` folder.  
Slugs are prefixed with the date in the format `yyyy-mm-dd`.
* `generate-blog slug` - Create a new HTML file using the Markdown with that slug.
* `regenerate-blogs` - Create new HTML files for all Markdowns. Useful if you update the template.

## There's a typo!
I sure hope not, but if there is, just let me know! 🙂
