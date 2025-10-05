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
