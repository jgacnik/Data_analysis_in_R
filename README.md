# Data Analysis in R

This repository contains the website and materials for an introductory **Data Analysis in R** workshop. The student website combines setup instructions, interactive Quarto Reveal.js presentations powered by webR, printable PDFs, and workshop downloads.

## Student website

The published course website is:

**https://jgacnik.github.io/Data_analysis_in_R/**

Students should begin with the website's **Setup** page, then use **Materials** to open the presentations and download the starter project.

## Presentations

| Part | Topic | Source | Rendered slides |
| --- | --- | --- | --- |
| 1 | Introduction to R | [`R_part1.qmd`](R_part1.qmd) | [`R_part1.html`](R_part1.html) |
| 2 | Data visualization | [`R_part2.qmd`](R_part2.qmd) | [`R_part2.html`](R_part2.html) |
| 3 | Data transformation | [`R_part3.qmd`](R_part3.qmd) | [`R_part3.html`](R_part3.html) |
| 4 | Data tidying | [`R_part4.qmd`](R_part4.qmd) | [`R_part4.html`](R_part4.html) |
| 5 | Paths, projects, and data import | [`R_part5.qmd`](R_part5.qmd) | [`R_part5.html`](R_part5.html) |

Open an `.html` file in a web browser to view or present the slides. Edit its `.qmd` source when changing content, then render it again to update the presentation.

## Website structure

- `index.qmd` is the student homepage.
- `setup.qmd` contains R, RStudio, package, and starter-project instructions.
- `materials.qmd` links all interactive presentations, PDFs, data, and downloads.
- `_quarto.yml` contains the shared website navigation and publishing configuration.
- `site.css` contains website styling; `styles.css` remains presentation-specific.

## Rendering

Install [R 4.6.0 or later](https://cran.r-project.org/) (the slides use the base-R `penguins` dataset), [Quarto](https://quarto.org/), and the R packages used by the slides, including `tidyverse` and `knitr`. Render the complete website from the repository root with:

```sh
quarto render
```

The finished site is written to `_site/`. To render only one presentation:

```sh
quarto render R_part4.qmd
```

Replace `R_part4.qmd` with the presentation you want to render.

## Supporting files

- `styles.css` contains the shared presentation styling.
- `figures/` contains images and graphics used by the slides.
- `R_partN_files/` contains generated Reveal.js and web assets for the matching presentation.
- `_extensions/` contains the Quarto extensions used by the presentations.
- `workshop/Example_project/` contains the editable source of the participant starter project.
- `downloads/Example_project.zip` is the ready-to-download participant starter project used in Part 5.

The GitHub Actions workflow in `.github/workflows/publish.yml` renders and deploys `_site/` to GitHub Pages after changes are pushed to `main`.

When sharing a rendered presentation outside the website, keep its `.html` file together with the matching `R_partN_files/` folder, `figures/`, `styles.css`, and `_extensions/`. The presentation may not display or run correctly without these supporting assets.
