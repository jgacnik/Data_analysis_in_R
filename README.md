# Data Analysis in R

This repository contains materials for an introductory **Data Analysis in R** workshop. The course is organized as four Quarto Reveal.js presentations with interactive R examples powered by webR.

## Presentations

| Part | Topic | Source | Rendered slides |
| --- | --- | --- | --- |
| 1 | Introduction to R | [`R_part1.qmd`](R_part1.qmd) | [`R_part1.html`](R_part1.html) |
| 2 | Data visualization | [`R_part2.qmd`](R_part2.qmd) | [`R_part2.html`](R_part2.html) |
| 3 | Data transformation | [`R_part3.qmd`](R_part3.qmd) | [`R_part3.html`](R_part3.html) |
| 4 | Data tidying | [`R_part4.qmd`](R_part4.qmd) | [`R_part4.html`](R_part4.html) |

Open an `.html` file in a web browser to view or present the slides. Edit its `.qmd` source when changing content, then render it again to update the presentation.

## Rendering

Install [R 4.6.0 or later](https://cran.r-project.org/) (the slides use the base-R `penguins` dataset), [Quarto](https://quarto.org/), and the R packages used by the slides, including `tidyverse` and `knitr`. Render a presentation from the repository root with:

```sh
quarto render R_part4.qmd
```

Replace `R_part4.qmd` with the presentation you want to render.

## Supporting files

- `styles.css` contains the shared presentation styling.
- `figures/` contains images and graphics used by the slides.
- `R_partN_files/` contains generated Reveal.js and web assets for the matching presentation.
- `_extensions/` contains the Quarto extensions used by the presentations.

When sharing a rendered presentation, keep its `.html` file together with the matching `R_partN_files/` folder, `figures/`, `styles.css`, and `_extensions/`. The presentation may not display or run correctly without these supporting assets.
