:meta
description = I made a simple CLI tool in Rust for my blog.
publish_date = 2024-03-22
:meta
# How I made a CLI tool in Rust for my blog
Today I released [blogs-md-easy](https://crates.io/crates/blogs-md-easy).  

A simple CLI that takes your Markdown files, and populates a predefined HTML template with the content.

## But, why?

If I use the same template every time, it might seem easier to just copy and paste that template and edit the content.

Perhaps.

Trouble is, I'm often not with my laptop (this very post is written on my phone!), so writing HTML is not favourable. It's much easier to write in a simple text format, and then copy that into HTML when I come to publish.

It was this workflow that led me to want to create a tool for this job. 

It's no secret that I've been working on my Rust skills this year, and what better way to improve that with a project. This is how I approach all learning exercises: with practical examples.

First thing I had to do was plan. I often find myself wanting to dive straight into the code - that's the fun part, right?! - but that never works out in the long run. I either end up rewriting parts of the application, or just discarding features I didn't need.

I knew I needed to do two things: parse placeholders in an HTML file, parse a Markdown file to populate these placeholders.

## Creating the parsers

Courtesy of [Advent of Code](https://adventofcode.com), I spent a lot of time learning how to write parsers in Rust.

With a huge shout out to the [nom_crate](https://crates.io/crates/nom) for such a fantastic library, and [Chris Biscardi](https://youtube.com/@chrisbiscardi) for the fantastic tutorials and walkthroughs using this crate.

I started by thinking of the best way to provide additional data to the template. This is so that I can include variables in a template and have them replaced differently for each Markdown.

Enter: the meta section. I really didn't know what to call this section, but I guess this makes sense, maybe? Here I knew I needed to create a start and end tag, then some key-value storage within.

This parser is actually two parsers together. We have one that parsers the key-value pairs, and another that parsers a delimited section of code.

Below is the parser that parsers the key-values pairs.  
This utilises a few nom parsers to achieve it's goal. The first of which removes all whitespace at the start of the line, before looking for an optional `£`.  
I used to write a lot of PHP back in the day, so this is just a homage to those days - with the obligatory twist because, you know, I'm the _British_ Werewolf...!

```rust
fn parse_meta_values(input: Span) -> IResult<Span, Meta> {
    // There might be an optional `£` at the start.
    let (input, _) = tuple((multispace0, opt(tag("£"))))(input)?;

    // Variable pattern.
    let (input, key) = recognize(tuple((
        alpha1,
        opt(many0(alt((alphanumeric1, tag("_")))))
    )))(input)?;

    let (input, _) = tuple((multispace0, tag("="), multispace0))(input)?;

    // The value of the variable, everything after the equals sign.
    // Continue to a newline or the end of the string.
    let (input, value) = alt((take_until("\n"), rest))(input)?;

    Ok((input, Meta { key: key.trim().to_string(), value: value.trim().to_string() }))
}
```

The pattern for a variable is any letter from `A` to `Z`, followed by either an alphanumeric (`A` to `Z` and `0` to `9`), or underscore character.  
This pattern was chosen arbitrarily, but really just because I was practicing nom and wanted to test my skills. It may well change in future; I'm undecided.

One thing on my todo list is multi line arguments, that'll be a fun thing to introduce!

Our section to parse the entire meta section simply looks for a start and end tag, then parsers a Vec of key-value pairs.

```rust
pub fn parse_meta_section(input: Span) -> IResult<Span, Vec<Meta>> {
    delimited(
        // Here we accept either a :meta or <meta>
        tuple((multispace0, alt((tag(":meta"), tag("<meta>"))))),
        // Now parse at least one set of key-value pairs.
        // This will get stored within a Vec<Meta> - handy!
        many1(parse_meta_values),
        // Finally, look for our closing tags.
        tuple((multispace0, alt((tag(":meta"), tag("</meta>"))))),
    )(input)
}
```

Simple. What's next?!

## Parsing placeholders

Now this, I thought, would be easy; but alas it was not.  
This is how placeholders are used in the template:

```html
<h1>{{ $title }}</h1>
<small>Published by {{ £author }}</small>
```

At this point I realised that I needed something more than nom, and fortunately my Advent of Code experience came through - again! We need [nom_locate](https://crates.io/crates/nom_locate) for this; an extension for nom that allows it to have some additional information on its matches, namely an offset of where that string is in the entire string.

I wrote some simple structs that stored a start and end position an then fleshed out the parser that used the, now, standard curly brace surroundings of a variable.

Currently we just have a variable inside the braces (prefixed with a `£`), but this approach can lead us into directives like how AngularJS works, maybe have some processing of variables somehow. No idea yet, but the thought is there.

This is the thing I spent the most time on, mainly because my initial approach didn't allow for multiple instances of the same variable in a template! I'd used a HashMap that had a key that was the same as the variable key…!

```rust
// First we parse the placeholders into (String, Vec<Placeholder>).
// String is the name of the variable.
let mut placeholders = parse_placeholder_locations(template)?;
// Reverse the order of placeholders, so that we replace from the bottom to top!
placeholders.sort_by(|a, b| b.1.span.location_offset().cmp(&a.1.span.location_offset()));
```

I then had to struggle with the offset changing when I replaced each variable. This had me stuck for a while as I wondered if I could do some replace of everything in one go - obviously not! - but then I realised the solution was incredibly simple: reverse the placeholders in reverse offset order. Replace the last instance first, and work towards the top!

## Now for some quality of life improvements

A lot of my time was spent making sure it worked. It's my philosophy to make it work first - however you achieve this - then optimise and reduce complexity in the code second.

The reason I like this approach is that I can ensure I have working tests, that use the API I envisage, but any changes I make will be reported back to me in real time.

One of the first things I added was the notification of warnings and errors during creation. There is a warning if you declare a variable in your Markdown that you don't use. There is an error if you declare a placeholder in your template and don't declare it in your Markdown.

When you make a mistake like this, you'll get the message reported to you, as well as which file is the problem. This is helpful if you have a lot of files and change the template.

## What's next?

Well, this is still a new thing to me.  

There's a lot of work to do, I think working on my documentation might be a start; making sure it is as concise, yet descriptive as possible.

I'd also like to make my code more idiomatic to the Rust ecosystem. There's a lot of concepts I'd like to employ, I try to avoid clone as much as possible too.

My current workflow is using this to create the HTML, then I have to manually create a card on my website. I am considering a better workflow for this, whether it's calling the command twice, or supporting multiple templates in the arguments. Let me know what you think?

Another great feature would be better error handling. Currently if you don't provide a value in the meta section, then no key-values are parsed and you get an error saying “Failed to parse meta section”. This is far from ideal.

Finally, I think I'd like to add a “dry run” or “changed” flags. Being able to run the command and see if there are any discrepancies between the generated HTML and the template. This could be useful if you update the template and need to keep consistency.

I'd absolutely love your feedback on my first crate, on this blog, anything really!

Find me on [Twitter](https://twitter.com/britwerewolf), I don't post much but I do tend to lurk!
