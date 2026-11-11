# Editing the AI Starter Kit website

Every word on the site is in a file in this repository. You change a file on github.com, check your change on a preview link, and merge it. The change is live within minutes, and automatic checks stop a broken page from publishing. Nothing to install.

## Make a change

1. **Open the file** on github.com (the table below says which) and select the pencil icon.
2. **Edit and propose.** Change the text, then select "Commit changes…", choose "Create a new branch" and "Propose changes". GitHub opens a pull request.
3. **Checks run.** Within a few minutes a comment on the pull request gives the preview link. If a check fails, its message names the file and the problem; fix it in the same pull request.
4. **Look at the preview.** Open the link and check every page you changed, on a laptop and a phone. For a second opinion, ask a colleague to comment on the pull request.
5. **Merge.** Once the checks pass, select "Merge". The site updates within minutes and the preview is removed.

To undo a merged change, open its pull request and select "Revert"; that opens a new pull request to check and merge as usual. For a bigger change (a new section, a restructured page), you can ask a coding agent such as Claude Code or Codex; it follows `AGENTS.md` and opens a pull request for you to review.

## Where things are

| To change | Edit |
|---|---|
| Words on a page: hero, introductions, headings, buttons, the "Join" box | `_pages/<page>.md` |
| A resource card (title, publisher, license, link, description) | `_resources/<card>.md` |
| Home page kit cards, About timeline and "How we work" | `_pages/home.md`, `_pages/about.md` |
| Teaching & Learning model, task cards and comparison | `_data/teaching_learning.yml` |
| A Prompt & Skill Library entry | `_library/<entry>.md` |
| Menu labels, footer, contact form labels and topics | `_data/site.yml` |
| The UNC System Office case study | `_case_studies/unc.md` |
| An image or logo | `assets/img/` (Add file > Upload files) |

The page files are `home`, `readiness` (AI Maturity Assessment), `policy`, `architecture`, `teaching-learning`, `advising`, `ai-in-practice`, `about` and `contact`. The Digital Education Council use cases are reproduced as published; ask a maintainer about those.

## How the files work

The part between the two `---` lines at the top of a file is a list of named fields, one per line, written `field: value`. Change the text after the colon; keep the field name as it is.

- **File names are IDs.** A page or card is known by its file name, so you can change any title, heading or order without breaking anything. Ask a maintainer before renaming a file.
- **Links** take a page ID (`policy`, `readiness`, `contact`…), a web address starting `https://`, or an email address. A blank link (`link: ""`) shows its button switched off.
- **Formatting in text:** `**bold**`, `*italics*` and `[link text](policy)` work in any text field. Longer text uses `|-` and continues on indented lines below; leave a blank line between paragraphs.
- **Quotes:** if a value contains a colon followed by a space, or starts with a quote mark, a number, `[`, `{`, `*` or `-`, wrap the whole value in double quotes. The checks tell you if one is needed.
- **Hiding keeps the text.** `show: false` takes a section, card or entry off the site without deleting it. Remove the line, or set it to `true`, to show it again.
- **Everything here is public.** The files, the pull requests and their comments, the preview links and the website can all be seen by anyone. Keep internal notes and open questions in email or AXIM's own channels.

### A resource card

```yaml
---
title: Higher Education Generative AI Readiness Assessment
page: readiness              # the page it appears on
section: assess-overall      # the section ID on that page
order: 3                     # its place among that section's cards
tag: Self-assessment
publisher: EDUCAUSE, with AWS
license: Free · CC BY-NC-ND · 2024
link: https://library.educause.edu/resources/2024/4/higher-education-generative-ai-readiness-assessment
---
A fillable self-assessment on strategy and governance, technology and data, workforce,
teaching and learning, and ethics.
```

The description goes below the second `---`. To add a card, copy an existing card file, give the copy a new file name and change its fields. Optional fields: `button` (instead of the section's default label), `part_tag` (Teaching & Learning only) and `show`.

### A page

A page file has a `browser_title`, a search engine `description`, and `sections`: the page from top to bottom. Each section starts with `- type:` and has an `id`. To add, remove or reorder sections, move whole blocks (each from its `- type:` line to the next one), keeping the indentation.

| Type | What it shows | Main fields |
|---|---|---|
| `hero` | The top of the page | `kicker`, `badge`, `heading`, `lead`, `body`; also `credit`, `share_label`, `share_text`, `box_label`, `box_text` |
| `text` | A heading and paragraphs | `heading`, `subheading`, `badge`, `body`, `points` (a bulleted list), `source`, `link_text`, `link`; `style: plain` for paragraphs without a box |
| `cards` | A set of cards | `heading`, `subheading`, `body`, `style`, and `items` for the card styles below |
| `cta` | A call to action box | `kicker`, `heading`, `body`, `button`, `link`, `points`; `style: join`, `band` or `panel` |
| `bot` | A bot and its button | `heading`, `credit`, `body`, `steps`, `outputs_heading`, `outputs`, `button`, `link` |
| `callout` | A highlighted question to readers | `label`, `heading`, `body` |
| `form` | The contact form (words in `_data/site.yml`) | none |

Card styles: `kit` (home), `criteria` and `timeline` (About), `split` (AI Advising), `learn` and `resource` (Teaching & Learning), `community` (AI in Practice) list their cards under `items`. The `source`, `context` and `resource` styles show the resource cards from `_resources/` whose `page` and `section` match.

A few sections belong to one page and draw on their own files: `license_key` and `case_studies` (AI Maturity Assessment), `examples` (Technology Architecture), `framework`, `try_it` and `library` (Teaching & Learning), `use_cases` (AI in Practice) and `partners` (About). Edit their words in place; ask a maintainer before adding one elsewhere.

### Teaching & Learning

The model always has four parts, in order: the three corners of the triangle, then the improvement loop. Each part's `short_name` is the label on the library filters and task cards, and every task's and library entry's `part` must match one of them. In `use_on_this_page`, a link to `try-it`, `library`, `learn-more` or `resources` jumps to that part of the page; `library` also filters the library. The "On this page" links come from each section's `on_this_page` line.

A library entry is a `prompt` (its text under `prompt: |-`) or a `skill` (its numbered `steps`):

```yaml
---
title: Objective checker
kind: skill
part: Outcomes
order: 2
description: Reviews a list of objectives and returns fixes.
steps:
  - Read each objective and flag vague verbs
  - Check the level matches the course (intro vs. advanced)
---
```

## Copy style

Plain executive prose, sentence case, warm but professional. No em dashes. Avoid the contrastive "not X, but Y" construction. Give every image alt text that says what it shows.

## Asking for a second look

No approval is needed to publish, so for a large or sensitive change, ask a colleague to open the preview link and comment on the pull request before you merge. They look at every page the change touches at desktop and phone width and check that it reads well and the links work.
