:meta
description = Pico CSS is a lightweight, (almost) classless CSS framework.
publish_date = 2024-02-19
:meta
# Why Pico CSS might be my favourite framework

This week the Pico team released version 2 of their lightweight, (almost) classless CSS framework.

## What is Pico CSS?

In a world of pre built components, or utility class frameworks, Pico was a breath of fresh air.

Pico has just a handful of classes (unless you opt for the classless version!), but is built on the premise that you write semantic HTML and the rest is handled for you.

Rather than styling based on IDs or classes, Pico applies styles to the elements themselves.

It's this philosophy that is the reason I chose it for my personal blog site here.

No need to worry about which class to use, just write the HTML and that's it - a focus purely on content.

## Who's Pico for?

As you can tell, the limited customisations will be a huge negative for most people, but it's not a complete write off.

I chose Pico because of its focus on content.

Out the box, Pico makes all elements responsive and comes with dark mode!

Seriously!

Right away I was able to just start writing content and have it styled effectively; the only learning comes for things like [cards](https://picocss.com/docs/card) knowing that they are the `article` tag, and can have accompanying `header` and `footer` elements.

The docs are so short, you could read them cover to cover in 30 mins.

## So, what's new?

Truthfully, not much.

If you were using version 1, the upgrade process was as simple as swapping the minified CSS to version 2.

In my case, I also had to update my CSS vars to be prefaced with `pico-`.

Additionally there is a new component to group elements for horizontal stacking, overflow auto support, conditional styling if you want to use Pico in combination with another framework and only style certain elements, a suite of new colour classes, and finally some breaking changes to things like button widths and accordions drop downs.

## But why do _you_ love it?

It's true, a framework this light on features feels like it shouldn't even be considered in this modern world of feature rich, “does it all” frameworks; I honestly think we've lost touch a little bit.

It's sad to see that many devs - junior or senior, new or seasoned - will reach for a framework *from the start*, regardless of the project scope or requirements.

Don't get me wrong, PurgeCSS is great, and Tailwind benefits hugely from it, but we don't always have to reach for these tools.

When I started this site, I knew it would be static and I didn't really want to worry about any build steps if I could help it, so I just started writing CSS; and this worked fine.

My instinct was to set up Tailwind, it is probably my favourite framework and I am very familiar with it.

However, I had heard of Pico and thought it might save me some time and give my site some consistency, so I set it up.

I'm glad I did.

Even with Tailwind I have to think about the styles I need, but with Pico I don't have to ever think of the CSS, just type out my HTML and have the site styled as I go.

Perfect!

## So, we should all use Pico now?

Of course not.

If that's the message that I've delivered, then I've failed with this article.

If I could pick two frameworks, they'd be: Pico and Tailwind.

And I'd probably start every project as a Pico project.

Pico is too lightweight at scale, and doesn't allow for complex views using something like CSS grid for instance.

In these cases I'd probably switch over to Tailwind and use its utility classes going forward.

<hr>

I hope you at least read the Pico docs and let me know your opinions.

And if you are impressed by it, I'd love to see what you made!

I'm in no way affiliated with Pico, but if you want to reach me and show me what you think or made, I'm usually quite active on [Twitter](https://twitter.com/BritWerewolf).
