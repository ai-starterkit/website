# AI Starter Kit website

The public website for the AI Starter Kit at **ai-starterkit.org**: plain files in this repository, built by [Jekyll](https://jekyllrb.com/) and served by GitHub Pages. There is no database, server or third-party host.

- **Changing words, cards, links or images:** read [CONTRIBUTING.md](CONTRIBUTING.md). Everything happens in GitHub; there is nothing to install.
- **AI coding agents (Claude Code, Codex):** read [AGENTS.md](AGENTS.md).

## How a change reaches the site

```
edit a file  ->  pull request  ->  checks + preview link  ->  merge  ->  live within minutes
```

1. Someone edits a file on github.com (or a coding agent does) and proposes the change. GitHub opens a pull request.
2. **Checks** run (`.github/workflows/checks.yml`): Jekyll builds the site, which first checks every content file against `_schema.yml`, then HTMLProofer checks internal links, images and alt text. A problem stops the pull request with a message naming the file.
3. **A preview link** appears as a comment on the pull request (`.github/workflows/preview.yml`), at `ai-starterkit.org/pr-preview/pr-<number>/`.
4. The editor opens the preview and checks the change. Anyone can be asked for a second look, but no approval is required.
5. **Merging publishes** (`.github/workflows/publish.yml`): the site is built and pushed to the `gh-pages` branch, which GitHub Pages serves. GitHub documents up to 10 minutes.

Undo a change with the "Revert" button on its merged pull request, which opens a new pull request that restores the previous version.

## What lives where

| Content | Where | Edited by |
|---|---|---|
| Page text: hero, introductions, section headings, calls to action | `_pages/<page>.md`, an ordered list of sections | Content owners |
| Resource cards on the assessment, policy, architecture and teaching pages | `_resources/<id>.md`, placed by `page`, `section` and `order` | Content owners |
| Home kit cards, About timeline, "How we work" | In the home and about pages' sections | Content owners |
| Teaching & Learning framework, tasks and comparison | `_data/teaching_learning.yml` | Content owners |
| Prompt & Skill Library entries | `_library/<id>.md` | Content owners |
| Site name, footer, menu, contact form | `_data/site.yml` | Content owners |
| UNC System Office case study | `_case_studies/unc.md` | Content owners |
| Images and logos | `assets/img/` | Content owners (upload in GitHub) |
| Digital Education Council use cases, reproduced as published | `_use_cases/<id>.html`, `_includes/dec-collection.html` | Maintainers only |
| Layout, components, styles, scripts, the architecture diagram | `_layouts/`, `_includes/`, `assets/` | Maintainers |
| The content schema and the site's only custom code | `_schema.yml`, `_plugins/starterkit.rb` | Maintainers |
| Site settings, build and publishing | `_config.yml`, `Gemfile`, `.github/` | Maintainers |

**A file's name is its ID.** `_pages/policy.md` is the page `policy` at `/policy/`; links anywhere on the site can say `policy`. Titles, headings and order can change freely; only renaming a file changes an ID, and the checks catch any reference left behind.

## Working on the site locally (maintainers)

Needs Ruby 3.3 and Bundler.

```sh
bundle install
bundle exec jekyll serve           # http://localhost:4000, rebuilds on save
bundle exec jekyll build           # build into _site/ (runs the content check)
bundle exec htmlproofer _site --disable-external --no-enforce-https
```

## Hosting

- **Repository:** this one, `ai-starterkit/website`, public, on GitHub's free plan, which publishes public repositories with GitHub Pages at no cost. Anyone can view the files; only invited people can change them.
- **Pages:** Settings > Pages, source "Deploy from a branch", branch `gh-pages`, folder `/`. The custom domain `ai-starterkit.org` is set there; "Enforce HTTPS" on.
- **Domain:** DNS for ai-starterkit.org is in AXIM's Cloudflare account. The apex points to GitHub Pages and `www` is a CNAME to `ai-starterkit.github.io`, with Cloudflare's proxy on. Verify the domain for the organization (Settings > Pages in the organization) so no other account can claim it.
- **Rules on `main`:** a ruleset requires a pull request and a passing "Build and check" (no approval needed), applies to administrators too, and blocks force pushes and deletion.
- **Previews:** public but not indexed by search engines; removed when the pull request closes.
- **Weekly link check:** `.github/workflows/links.yml` opens an issue when a resource link dies or moves.
- **Updates:** Dependabot proposes updates to the pinned Actions and gems monthly, as ordinary pull requests.

## History

Until launch, the site was built from a Google Doc by a custom Node script and hosted on Vercel. At launch the Doc's content was converted once into the files here, and the Doc, its sync and the Vercel project were retired; their record stays in L&A's archived build repository.
