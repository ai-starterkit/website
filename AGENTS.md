# AGENTS.md

Operating instructions for any AI coding agent working in this repository, including Claude Code and Codex. Claude Code loads this file through `CLAUDE.md`. `README.md` explains how the site is built and published; `CONTRIBUTING.md` explains the content files to people.

## What this project is

The public website for the AI Starter Kit (ai-starterkit.org), owned by Axim Collaborative. The audience is higher education leaders and funders, so the bar is executive-grade polish and clarity.

## Architecture in one paragraph

A Jekyll 4 site, built by GitHub Actions and served by GitHub Pages from the `gh-pages` branch. Words live in content files: `_pages/<id>.md` (front matter holding an ordered list of `sections`), `_resources/`, `_library/`, `_case_studies/` and `_data/`. Each section `type` has a template in `_includes/sections/<type>.html`; `_layouts/` holds the page shell. `_plugins/starterkit.rb` is the only custom code: it gives each page its ID (the file name), adds the `sk_*` Liquid filters that render Markdown and resolve links (a page ID, a web address, an email address or blank), and checks every content file against `_schema.yml` before the build. Styles and scripts in `assets/` are plain CSS and JavaScript with no build step. Keep it that way: do not add a framework, a bundler, a Node toolchain or a new gem without a clear reason agreed with the maintainers.

## Rules

- **Never push to `main`.** Every change reaches the site through a pull request, and merging to `main` publishes. People may merge their own changes; a change made by an agent is merged only after the person who asked for it has looked at the preview and said to.
- **Content goes in content files.** Change words in `_pages/`, `_resources/`, `_library/`, `_case_studies/` or `_data/`, never in templates. A file name is an ID: do not rename one unless asked, and update every reference in the same pull request.
- **Templates and schema change together.** A new field or section type needs its template, an entry in `_schema.yml`, and a line in the section table in `CONTRIBUTING.md`. Do not loosen `_schema.yml` to get a build past a content mistake; fix the content.
- **The DEC use cases in `_use_cases/` and `_includes/dec-collection.html` are reproduced as published.** Do not edit their text.
- **Everything in this repository is public.** The files, pull requests and comments can be seen by anyone, and content files become the website. Never add internal notes, personal data or secrets to any file, pull request or comment.
- **Copy style for any user-facing text:** plain executive prose, sentence case, warm but professional. No em dashes. Avoid the contrastive "not X, but Y" construction.
- **No browser storage, no third-party trackers or analytics.** Keep the accessibility floor: keyboard operable, visible focus, reduced motion respected, alt text on every image, no horizontal scroll at phone width.
- **Leave hosting alone.** Do not change repository settings, rulesets, Pages settings, domains, DNS or secrets. Describe the change needed and stop.

## How a change gets published

1. **Branch from the latest `main`:** `git fetch origin && git checkout -b <type>/<short-topic> origin/main`, where `<type>` is `content`, `design`, `fix` or `docs`.
2. **Make the change** where the rules above point.
3. **Build and check:**
   ```sh
   bundle install
   bundle exec jekyll build
   bundle exec htmlproofer _site --disable-external --no-enforce-https
   ```
   The build stops with a list of problems, each naming its file, if any content is wrong. Fix the cause.
4. **Look at it:** `bundle exec jekyll serve` serves the site at http://localhost:4000. Check every changed page at desktop and phone widths with no console errors.
5. **Commit** with a message that says what changed on the site and why, in plain language a non-developer can follow.
6. **Open a pull request** into `main`. List the pages affected. The preview link appears as a comment within a few minutes; add it to the description.
7. **Wait for the go-ahead.** Merge only after the person who asked for the change has looked at the preview and said to.

If a merged change needs undoing, open a pull request that reverts it (`git revert -m 1 <merge-sha>`) and ask for the go-ahead as usual.

## Ask a person before you

- rename, add or remove a page, or rename any content file;
- add a section type, a dependency, a third-party script or a form endpoint;
- touch `_use_cases/`, `.github/`, `_config.yml`, `_plugins/` or anything about hosting;
- delete published content.

## Definition of done

1. `bundle exec jekyll build` and the HTMLProofer command succeed.
2. You have looked at the changed pages in a browser at desktop and phone widths with no console errors.
3. A pull request is open with the affected pages and the preview link in its description.
