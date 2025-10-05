// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

#import "@preview/meander:0.2.2"

#set table(
   inset: 6pt,
   stroke: none
)

#let poster(
  // The poster's size.
  size: "'36x24' or '48x36' or '72x30'",

  // The poster's title.
  title: "Paper Title",

  // A string of author names.
  authors: "Author Names (separated by commas)",

  // Department name.
  departments: "Department Name",

  // University logo.
  univ-logo: "Logo Path",
  
  // University image.
  univ-image: "Image Path",

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
  footer-text: "Footer Text",

  // Any URL, like a link to the conference website.
  footer-url: "Footer URL",

  // Email IDs of the authors.
  footer-email-ids: "Email IDs (separated by commas)",

  // Color of the header & footer.
  header-color: "Hex Color Code",
  footer-color: "Hex Color Code",

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, 72in x 30in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  keywords: (),

  // Number of columns in the poster.
  num_columns: "3",

  // University logo's scale (in %).
  univ_logo_scale: "30",
  
  // University image's scale (in %).
  univ_image_scale: "100",

  // University logo's column size (in in).
  univ_logo_column_size: "8",

  // Title and authors' column size (in in).
  title_column_size: "50",
  
  // University image's column size (in in).
  univ_image_column_size: "8",

  // Poster title's font size (in pt).
  title_font_size: 102,
  title_font_color: "FFFFFF",

  // Authors' font size (in pt).
  authors_font_size: "36",
  authors_font_color: "FFFFFF",

  // Footer's URL and email font size (in pt).
  footer_url_font_size: "36",

  // Footer's text font size (in pt).
  footer_text_font_size: "36",
  footer_text_font_color: "FFFFFF",

  // The poster's content.
  science
) = {
  // Set the body font. Use a Google Font you like. Set size. Here we used Open Sans.
  set text(font: "Open Sans", size: 32pt) // Can change to 12pt for small size
  let sizes = size.split("x")
  let width = int(sizes.at(0)) * 1in
  let height = int(sizes.at(1)) * 1in
  univ_logo_scale = int(univ_logo_scale) * 1%
  univ_image_scale = int(univ_image_scale) * 1%
  title_font_size = int(title_font_size) * 1pt
  authors_font_size = int(authors_font_size) * 1pt
  num_columns = int(num_columns)
  univ_logo_column_size = int(univ_logo_column_size) * 1in
  univ_image_column_size = int(univ_image_column_size) * 1in
  title_column_size = int(title_column_size) * 1in
  footer_url_font_size = int(footer_url_font_size) * 1pt
  footer_text_font_size = int(footer_text_font_size) * 1pt

  // Configure the page.
  // This poster is based on a default of 36in x 24in
  // below are commands from raw typst
  // lots of options to configure the page can be
  // found at https://typst.app/docs 
  
  set page(
    width: width,
    height: height,
    margin: 
      (top: 1in, left: 1in, right: 1in, bottom: 1in),
    footer: [
      #set align(center)
      #set text(32pt) // altered for 72 x 30
      #block(
        fill: rgb(footer-color),
        width: 100%,
        inset: 20pt,
        radius: 10pt,
    // note fonts modifiable in the footer
        [
          #text(size: footer_text_font_size, smallcaps(footer-text), fill: rgb(footer_text_font_color)) 
          #h(1fr) 
          #text(font: "Open Sans", size: footer_url_font_size, footer-url, fill: rgb(footer_text_font_color)) 
          #h(1fr) 
          #text(font: "Open Sans", size:  footer_url_font_size, footer-email-ids, fill: rgb(footer_text_font_color))
        ]
      )
    ]
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  // modify indents as desired
  set enum(indent: 30pt, body-indent: 9pt) 
  set list(indent: 30pt, body-indent: 9pt)

  // Configure headings.
  // modify numbering as desired, if any
  // to enable section numbering, change 'none' to something like "I.A.1."
  set heading(numbering: none )
  show heading: it => context {
    let loc = here()

    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(40pt, weight: 700)
    if it.level == 1 [
      // First-level headings are left-aligned numbered but not in (smallcaps) - perhaps this font does not do smallcaps.
      #set align(left)
      #set text({ 44pt })
      #show: smallcaps
      #v(50pt, weak: true)
      #if it.numbering != none {
        numbering("1.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(35.75pt, weak: true)
      #line(length: 100%)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      // italic, 32 pt, numbered w/letters
      #set text(style: "italic", weight: 600)
      #v(32pt, weak: true)
      #if it.numbering != none {
        // removed numbering from subheadings
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering("1)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  }

  // extra line break "\n" added to authors to separate from title
  // emph() causes italics
  //inset pads around the text, radius rounds the corners
 align(center,
 block(
  fill: rgb(header-color),
  inset: 30pt,
  radius: 15pt,
    grid(
      rows: 1,
      columns: ( 500pt, 1fr, 450pt ),
      column-gutter: 0em,
      row-gutter: 5pt,

      align(horizon,
      image(univ-logo, width: 415pt)),

      align(horizon,
      text(title_font_size, title + "\n", 
            fill: rgb(title_font_color)) + 
            text(authors_font_size, emph("\n" + authors) + 
            "\n" + departments, fill: rgb(authors_font_color))),

      image(univ-image, width: univ_image_scale)
    )
  ))

  block( below: 0pt )

  set par(justify: true, first-line-indent: 0em)
  set text(hyphenate: true)
  show par: set par(spacing: 0.65em)

  // Display the poster's contents.
  meander.reflow({
    import meander: *

    container(width: 26%, height: 85%)
    container(align: center, width: 45%, height: 85%)
    container(align: right, width: 26%, height: 85%)

    content[
      #text(science)
    ]

  })
}

// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// This file calls the 'poster' function defined in the 'typst-template.typ' file to render your poster to PDF when you press the Render button.
// Make any edits to the template in the typst-template.typ file
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => poster(
   title: [Listeners do not need an F1/F2 target to perceive vowel quality #emph[or] regional accentedness], 
  // TODO: use Quarto's normalized metadata.
   authors: [Kevin B. McGowan, Stella Takvoryan], 
   departments: [Department of Linguistics, University of Kentucky], 
   size: "48x36", 

  // Institution logo.
   univ-logo: "./images/Department-of-Linguistics-white.png", 

  // Institution image.
   univ-image: "./images/speech-is-social.png", 
  
  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
   footer-text: [Midphon 30], 

  // Any URL, like a link to the conference website.
   footer-url: [Download this poster from: https:\/\/phonetics.as.uky.edu/research/asc/midphon30/], 

  // Emails of the authors.
   footer-email-ids: [kbmcgowan\@uky.edu, stakvoryan\@uky.edu], 

  // Color of the header.
   header-color: "265CA4", 
  
  // Color of the footer.
   footer-color: "265CA4", 

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // Typical medical meeting posters are 60 or 72 in wide x 30 or 36 in tall
  // in the US
  // Or 100 cm wide by 189 cm tall  in Europe.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  

  // Number of columns in the poster.
  

  // University logo's scale (in %).
  

  // University logo's column size (in in).
  

  // University image's scale (in %).
  
  
    // University image's column size (in in).
  
  
  // Title and authors' column size (in in).
  

  // Poster title's font size (in pt).
   title_font_size: 80, 
  

  // Authors' font size (in pt).
   authors_font_size: 38, 
  

  // Footer's URL and email font size (in pt).
  

  // Footer's text font size (in pt).
  

  doc,
)

= Background
<background>
Silent centers (SC): listeners can identify vowel quality in a CVC syllable even with 65% of tense vowels and 50% of lax vowels removed (Strange & Jenkins, 2013). However, listeners may still require vowel centers to hear social information. Three complementary ideas in the literature suggest that social information in vowel centers may be #emph[essential];:

\
1. #strong[Primacy of F1/F2 at the vowel midpoint];, sometimes taken along with duration, e.g., sociophonetics, sound change, second language acquisition, etc. (Kelley & Tucker, 2020; Labov et al., 1972; Nycz & Hall-Lew, 2013; Thomas, 2014)

+ #strong[Hybrid silent centers] (Rakerd & Verbrugge, 1987; Verbrugge & Rakerd, 1986): pairing SC syllable edges from different talkers does not undermine vowel perception so argue vowel edges do not carry social information

+ #strong[Vowel normalization] (Johnson, 2005; Johnson & Sjerps, 2021) assumes that variation is problematic for listeners so models typically operate on vowel centers where contextual variation is least \[c.f. (Barreda, 2025; Fruehwald, 2024)\]

= Methodology
<methodology>
- #strong[Talkers];: Three non-Southern talkers from the Wildcat corpus (Van Engen et al., 2010) and two Southern talkers (KY)

- #strong[Stimuli];: BVT syllables with \[i, ɪ, e, ɛ, æ, u, ʊ, o, ʌ, ɔ, a\]; #strong[middle 50% for lax vowels] & #strong[middle 65% for tense vowels] (Strange et al., 1983) excised with a custom Praat script (see #ref(<fig-worms>, supplement: [Figure]))

- #strong[Procedure];: 2AFC; listeners heard a CVC word and answered either "what did you hear?" with a pair of words or "who did you hear?" and the maps in #ref(<fig-maps>, supplement: [Figure]). "What?" trials displayed a map congruent with the talker; "Who?" task trials displayed the word that was being spoken.

\

#figure([
#box(image("./images/maps.png", width: 80.0%))
], caption: figure.caption(
position: bottom, 
[
"Non-Southern" and "Southern" stimuli
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-maps>


\

- #strong[Participants];: 60 US participants recruited via Prolific

- #strong[Analysis];: BRMS logistic regression in R (Bürkner, 2017), NHST with bayestestR (Arel-Bundock et al., 2024; Makowski et al., 2019)

- Many studies have found that listeners perform poorly when asked to label regional accents (Campbell-Kibler, 2025; Clopper & Pisoni, 2004; Milroy & McClenaghan, 1977). Our simplified maps are intended to represent Clopper & Pisoni's "dialect clusters"

- While it is clear that listeners do not need vowel centers to perceive vowel quality accurately, it is not yet known whether listeners can perceive, for example, regional accent without the vowel center.

\
\

#grid(
columns: (1fr, 1fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
= Predictions
<predictions>
#figure([
#box(image("./images/ASC-SDT.png", width: 95.0%))
], caption: figure.caption(
position: bottom, 
[
Predictions under two assumptions about social information
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-predictions>


],
  rect(stroke: none, width: 100%)[
= Silent Centers Visualized
<silent-centers-visualized>
#figure([
#box(image("ASC-Midphon30_files/figure-typst/fig-worms-1.svg", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
Vowel stimuli unnormed F1/F2 DCTS with excised portions indicated
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-worms>


],
)
= Results
<results>
#figure([
#box(image("ASC-Midphon30_files/figure-typst/fig-model-predictions-1.svg", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
'What?' (top left) and 'Who?' (bottom left) model predictions (95% HDI) and Accuracy differences for responses to Non-Southern (top row) and Southern (bottom row) talkers
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-model-predictions>


#figure([
#box(image("ASC-Midphon30_files/figure-typst/fig-coefficients-1.svg", width: 100.0%))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-coefficients>


= Discussion
<discussion>
- #strong[Listeners do not need the vowel center to perceive vowel quality (replicated)];: Listener accuracy on the 'what?' trials is a straightforward, successful replication of the silent centers effect (Strange et al., 1983; Strange & Jenkins, 2013)
- #strong[Listeners do not need the vowel center to perceive regional accentedness];: Contra hybrid silent-centers work that paired incongruous syllable edges(Rakerd & Verbrugge, 1987; Verbrugge & Rakerd, 1986), listeners to the 'who?' trials can, indeed, perceive regional accent from SC vowels
- #strong[Regional differences for tense and lax vowel qualities];: different vowel qualities encode regional variation differently; some of this variation is captured by the tense/lax distinction

= Conclusions & Future Work
<conclusions-future-work>
- Social perception is more sensitive to SC than vowel quality. Centers may be more useful to listeners as a source of social information, but they are not essential.

- Researchers who use a single point measure to characterize the vowels of a talker or of a community are missing a great deal of information that listeners themselves use in perception.

- But even formant tracks or multiple points of measurement per vowel are only measuring vowel centers if they begin at 20% (or later) and end at 80% of V duration as the standard SC manipulation removes from 17.5% of a tense vowel to 82.5%

- Tense/Lax: it may be that listeners need a greater percentage of a more dynamic vowel quality to perceive regional variation or this may be due to varying levels of awareness/stereotypicallity of vowels (Babel, 2025) \
  \
  \

#grid(
columns: (40fr, 60fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
= References
<references>
#box(image("ASC-Midphon30_files/figure-typst/unnamed-chunk-1-1.svg"))

],
  rect(stroke: none, width: 100%)[
= Acknowledgements
<acknowledgements>
We are grateful to Josef Fruehwald, Jennifer Cramer, Kyler Laycock, Kendal Smith, Austin Coleman, and Shane O'Nan for their invaluable assistance with this project.

],
)



