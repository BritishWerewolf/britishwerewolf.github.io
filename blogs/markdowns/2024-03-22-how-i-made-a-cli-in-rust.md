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

### Meta section
Enter: the meta section. I really didn't know what to call this section, but I guess this makes sense, maybe? Here I knew I needed to create a start and end tag, then some key-value storage within.

There are a few parsers at play here: one to parse keys, another for values, another for key-value pairs (combining the previous two!), another to parse comments, and finally another to parse the entire meta section (combining a bit of everything prior).

#### Comments
Let's start with the easiest one: parsing comments (and a bonus parser too!).

```rust
fn parse_until_eol(input: Span) -> IResult<Span, Span> {
    terminated(
        // Return any character until a newline.
        alt((take_until("\n"), rest)),
        // Consume, but don't return, the newline.
        alt((tag("\n"), tag(""))),
    )(input)
}

fn parse_meta_comment(input: Span) -> IResult<Span, Span> {
    preceded(
        // All comments start with either a `#` or `//` followed by a space(s).
        tuple((alt((tag("#"), tag("//"))), space0)),
        // Then return the rest of that line.
        parse_until_eol,
    )(input)
}
```
Comments can start with either `#` or `//`, and the rest of the comment will be simply the rest of the line. If you're wondering why I chose these two tags, it's simply because I come from a PHP background and where [the comments there](https://www.php.net/manual/en/language.basic-syntax.comments.php) have the same syntax.

#### Keys and values
Our next parser is actually three parsers working together. Let's look at parsing keys, values and the key-value pairs.
```rust
fn parse_variable_name(input: Span) -> IResult<Span, Span> {
    // Recognise will convert the tuple into a str / Span.
    recognize(tuple((
        // Check that the first character is alphabetic.
        take_while_m_n(1, 1, is_alphabetic),
        // Then accept any alphanumeric characters, hyphens and underscores.
        many0(alt((alphanumeric1, tag("-"), tag("_")))),
    )))(input)
}

fn parse_meta_key(input: Span) -> IResult<Span, Span> {
    preceded(
        opt(tag("£")),
        parse_variable_name
    )(input)
}

fn parse_meta_value(input: Span) -> IResult<Span, Span> {
    // The value of the variable, everything after the equals sign.
    // Continue to a newline or the end of the string.
    parse_until_eol(input)
}

// Putting it all together!
fn parse_meta_key_value(input: Span) -> IResult<Span, Meta> {
    // Separate our two parses by an equal, with optional spaces eiter side.
    separated_pair(
        parse_meta_key,
        recognize(tuple((space0, tag("="), space0))),
        parse_meta_value
    )(input)
    // Make use of nom::Parser to `map` the output into our predefined struct.
    // This is instead of storing in a variable and mapping ourselves.
    .map(|(input, (key, value))| {
        (input, Meta {
            key: key.trim().to_string(),
            value: value.trim().to_string()
        })
    })
}
```
In the meta section, we can optionally use a `£` before a variable. The meta value is _anything_ until the end of the line.

We put this all together into a single parser, which returns a `Meta` struct.  
This is done by using the `key` and `value` parsers, and checking that there is a `=` in between them. If we match here, then we will move onto the `map` function. I find it handy to write my parsers this way, rather than creating variables and using the `?` operator and then building a struct.  
This feels more idiomatic and makes the flow a bit easier to read in my opinion.

As mentioned above, I wanted to continue my homage to PHP by prefixing variables with a symbol; I chose the `£` because it's similar to PHP's dollar symbol, but with that classic twist, because, you know, I'm the _British_ Werewolf...!

The pattern for variable names was chosen (somewhat) arbitrarily, but really just because I was practicing nom and wanted to test my skills. It may well change in future; I'm undecided.  
I say "somewhat" because it was inspired by HTML IDs that must start with a letter first.

One thing on my todo list is multi line arguments, that'll be a fun thing to introduce!

#### Piecing it all together

Our section to parse the entire meta section simply looks for a start and end tag, then a parser to parse a line.

```rust
fn parse_meta_line(input: Span) -> IResult<Span, Option<Meta>> {
    // A line can have whitespace before it, but we don't want to store this.
    let (input, _) = space0(input)?;
    // Then a line can be either a comment or a key-value pair.
    let (input, res) = alt((
        // Discard comments.
        parse_meta_comment.map(|_| None),
        // Keep key-value pairs.
        parse_meta_key_value.map(Some),
    ))(input)?;
    // Finally remove trailing whitespace and newlines.
    let (input, _) = multispace0(input)?;
    Ok((input, res))
}

pub fn parse_meta_section(input: Span) -> IResult<Span, Vec<Option<Meta>>> {
    delimited(
        // Here we accept either a :meta or <meta>.
        tuple((multispace0, alt((tag(":meta"), tag("<meta>"))), multispace0)),
        // Now parse at least one set of key-value pairs.
        // This will get stored within a Vec<Meta> - handy!
        many1(parse_meta_line),
        // Finally, look for our closing tags.
        tuple((multispace0, alt((tag(":meta"), tag("</meta>"))), multispace0)),
    )(input)
}
```
Something I learnt here was just simply passing `Some` or `|_| None` to the map function, rather than passing a full closure.  
This is because the `alt` parser will discard any `None` values, so doing this means our Vector will only contain the key-value pairs.

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
