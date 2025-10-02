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
  $if(title)$ title: [$title$], $endif$
  // TODO: use Quarto's normalized metadata.
  $if(poster-authors)$ authors: [$poster-authors$], $endif$
  $if(departments)$ departments: [$departments$], $endif$
  $if(size)$ size: "$size$", $endif$

  // Institution logo.
  $if(univ-logo)$ univ-logo: "$univ-logo$", $endif$

  // Institution image.
  $if(univ-image)$ univ-image: "$univ-image$", $endif$
  
  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
  $if(footer-text)$ footer-text: [$footer-text$], $endif$

  // Any URL, like a link to the conference website.
  $if(footer-url)$ footer-url: [$footer-url$], $endif$

  // Emails of the authors.
  $if(footer-emails)$ footer-email-ids: [$footer-emails$], $endif$

  // Color of the header.
  $if(header-color)$ header-color: "$header-color$", $endif$
  
  // Color of the footer.
  $if(footer-color)$ footer-color: "$footer-color$", $endif$

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
  $if(keywords)$ keywords: ($for(keywords)$"$it$"$sep$, $endfor$), $endif$

  // Number of columns in the poster.
  $if(num-columns)$ num_columns: $num-columns$, $endif$

  // University logo's scale (in %).
  $if(univ-logo-scale)$ univ_logo_scale: $univ-logo-scale$, $endif$

  // University logo's column size (in in).
  $if(univ-logo-column-size)$ univ_logo_column_size: $univ-logo-column-size$, $endif$

  // University image's scale (in %).
  $if(univ-image-scale)$ univ_image_scale: $univ-image-scale$, $endif$
  
    // University image's column size (in in).
  $if(univ-image-column-size)$ univ_image_column_size: $univ-image-column-size$, $endif$
  
  // Title and authors' column size (in in).
  $if(title-column-size)$ title_column_size: $title-column-size$, $endif$

  // Poster title's font size (in pt).
  $if(title_font_size)$ title_font_size: $title_font_size$, $endif$
  $if(title_font_color)$ title_font_color: $title_font_color$, $endif$

  // Authors' font size (in pt).
  $if(authors_font_size)$ authors_font_size: $authors_font_size$, $endif$
  $if(authors-font-color)$ authors_font_color: $authors-font-color$, $endif$

  // Footer's URL and email font size (in pt).
  $if(footer-url-font-size)$ footer_url_font_size: $footer-url-font-size$, $endif$

  // Footer's text font size (in pt).
  $if(footer-text-font-size)$ footer_text_font_size: [$footer-text-font-size$], $endif$

  doc,
)
