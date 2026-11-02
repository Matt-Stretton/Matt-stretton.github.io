# CLAUDE.md

Guidance for Claude Code (and people) working in this repository. Everything here was checked
against the repository or by running it on 2026-10-29. If something you find contradicts it, say so
rather than guessing which is right.

## What this is

Dr Matt Stretton's site, to be served at **aklent.co.nz**, as a **first draft**. It started as a copy
of the necksurgery.co.nz site (Dr Nick Lilic's practice) taken on 2026-10-29 from
`sfe/necksurgery.co.nz/nicklilic.github.io/`, without that repository's git history or its
`.github/` deploy workflow. The design, copy structure, images and identity have since been
replaced with Matt's (2026-10-29), and on 2026-10-30 redesigned after a reference Paul supplied
(branch `design-v2`; see "Branches"): a full-height navy hero with the "MS" monogram, his name in
large tracked capitals (the second line gold) and a gold button; a sticky nav bar under it; About
on navy with the headshot on studio grey running to the right edge; a moving band of affiliation
logos; four service tiles on a cream band; and a navy contact section. Jost headings, Inter body
text, navy, gold and maroon. **Much of the copy is still bracketed placeholders**, and
the privacy policy is still the old practice's text with the names taken out: see "Not done yet".

It is a local git repository with **no remote**. See "Branches" for what is on which. Within SFE it sits at
`sfe/matt-stretton.github.io/`, untracked by SFE like every product. The folder name suggests a
GitHub Pages user site; nothing has been created on GitHub.

No JavaScript build, no `package.json`, no database, no server-side code. The page loads Alpine.js
from unpkg (unversioned; it drives the phone menu), Lineicons and animate.css from CDNs, the two
Google Fonts (from the stylesheet's `@import`), and Google's reCAPTCHA script with the form. There
is no analytics tag.

`.doncheckin/` (gitignored) holds what the client sent: the headshot original, his reference
screenshot of the icon style, and two files from another surgeon's site (`ZM-logo_65px.png`,
`apple-touch-icon.png`) that are reference only and must not be used.

## Branches

- **`main`** (commit `df6937c`, also branch and tag `design-v1`): the first draft's design. Kept
  as the backup of that design; do not commit the redesign onto it.
- **`design-v2`**: the redesign after Paul's reference (hero, sticky nav, dark/cream rhythm). Not
  merged into `main`.

## Where it runs, and the commands

On the host. No container: SFE's rule is that Hugo sites run on the machine.

```bash
make setup        # once: downloads the pinned Hugo into .tools/ and checks make will use it
make check        # changes nothing; fails if the Hugo make uses is not the pin
make serve        # live reload, drafts + future pages, http://127.0.0.1:1313/  (PORT=… to move it)
make preview      # the production build exactly, as plain files, http://127.0.0.1:1314/
make test         # production build into .test/ + site checks, excusing scripts/known-defects.txt
make test-strict  # the same with no baseline
make build        # production build into public/ (hugo --gc --minify)
make status       # pin, Hugo in use, what is listening, git remote
```

**Use `scripts/hugo.sh`, never bare `hugo`.** The pin is **Hugo 0.168.0 extended**, written once, as
`HUGO_PIN` in `scripts/lib.sh`. `make setup` downloads it into `.tools/hugo-0.168.0/` (gitignored,
checksum-verified against Hugo's published checksums, nothing system-wide). The snap `hugo` on this
machine is also 0.168.0 today; that is a coincidence, and the snap updates itself.

Why 0.168.0: it is the newest release and builds the theme. The old deploy used 0.162.1. Both
deprecation warnings this site produces (below) say they began in 0.153.0 and 0.158.0, so 0.162.1
would print them too; there was nothing to gain by pinning older. 0.162.1 itself was not run.

**`make serve` polls** (`--poll 500ms`). On this machine the inotify watches are exhausted by other
projects, and Hugo's file watcher then silently misses edits. Port 1313 is often taken by another
SFE site's server: leave it and use `make serve PORT=1315`.

`make build` and `make test` use the old workflow's flags (`--gc --minify`) and
`HUGO_ENVIRONMENT=production`, but not its `--baseURL`, which came from the Pages deployment. So the
build uses `config.toml`'s `baseURL`, `https://aklent.co.nz/`.

### What `make test` checks

`scripts/check-site.py`, copied from hunterinthewoods so SFE's Hugo sites report the same way, over a
build in `.test/public`: every Hugo `WARN`/`ERROR` line (Hugo exits 0 on warnings), title,
description and `lang` on every page, every internal link, anchor, image and CSS `url()`, mixed
content, `sitemap.xml`, `robots.txt`, drafts or future pages leaking, template placeholder text, and
one check of its own, **`inherited`**: Nick's name, domain, Google Ads id and contact-form endpoint
anywhere in the build. It takes about 0.3 seconds.

`scripts/known-defects.txt` excuses what came with the copy: the two deprecation warnings and the
bare 404 page. The `inherited` entries are gone: the build no longer contains any of Nick's name,
domain, ad id or form endpoint, so `inherited` must stay clean. An entry that stops matching fails
the run as STALE; delete its line. Never add a line to make a new failure go away.

The `placeholders` check looks for template filler (`lorem ipsum`, `example.com`, `yourname`), not
for this site's own `[square bracket]` placeholders, so those pass the test on purpose. Nothing
mechanical stops them going live: "Not done yet" is the list to clear.

## Layout

```
config.toml               title, baseURL, [params] (description, keywords, legal_title, the
                          contact hours (display line plus hours_days / hours_open / hours_close
                          for the JSON-LD) and address lines, and the still empty phone /
                          phone_display / email / maps_url the templates fall back from), menus
content/
  privacy-policy.html     /privacy-policy/  (the old practice's policy, names replaced by placeholders)
  thankyou.html           /thankyou/  (the contact form's landing page)
data/services.yaml        the four service groups and their items, in Matt's words; each names its icon
static/imgs/
  matt-stretton.webp      the headshot (512x512, the only photo so far)
  logo_college_of_surgens.png, logo-acc.jpeg, logo-southen-cross.svg, logo-anzhncs.svg, logo-nib.svg
                          affiliation logos (logo-nib.svg is unused: the marquee inlines nib's path)
  social.png              1200x630 OG/Twitter card; favicon-32.png, favicon-16.png,
                          apple-touch-icon.png (gold "MS" on navy). All four generated with PIL.
themes/necksurgery/       the theme, tracked here, not a submodule
  layouts/_default/baseof.html   every page's <head>: meta, canonical, OG/Twitter, favicons, CSS;
                          in <body>, a "hero" block (filled only by the home page), then the nav
  layouts/index.html      the home page: the hero's words and fullImage (the "hero" block), then
                          partials/home.html
  layouts/partials/
    home.html             below the hero: About, the marquee, Services
    header.html           the sticky navy nav bar: monogram + wordmark, links, phone link, maroon
                          Enquire button, Alpine burger for phones
    mark.html             the gold "MS" diamond monogram (hero top and nav): swap this one file
                          for the logo
    wordmark.html         the "Dr Matt Stretton" text beside the monogram in the nav
    components/hero.html  the full-height centred hero: monogram, two-line name, credentials and
                          role, one-line subtitle, gold button; a designed navy background, or the
                          fullImage photo under a navy overlay
    marquee-logos.html    one set of affiliation logos; home.html renders it twice to loop
    icons/*.html          the four service icons (neck, thyroid, nose, child): a gold line
                          drawing in two weights (thick outline, thin detail) inside the
                          monogram's double diamond; classes in components/_sections.scss
                          (.diamond-icon). Earlier drafts are kept in .doncheckin/icons-v1/
                          (line), v2/ (outline + maroon organ) and v3/ (flat figures); the white
                          line on a gold disc is in git at c4fc35e.
    footer.html           the Contact section (details + enquiry form) and the footer bar
    schema.html           JSON-LD (Physician), home page only, built from data/services.yaml
  layouts/robots.txt      robots.txt (enableRobotsTXT = true)
  assets/scss/            the stylesheet, compiled by Hugo's toCSS. _var.scss holds the fonts,
                          palette and header heights; components/ has header (nav, monogram,
                          wordmark), hero (and the gold button), marquee, sections (headings,
                          About, Services, icons, legal pages) and footer
archetypes/default.md     front matter for `scripts/hugo.sh new`
scripts/                  setup, serve, preview, test, check-site.py, known-defects.txt
```

There is no `content/_index.md`, no services or contact page: Services (`/#services`) and About
(`/#about`) are sections of `partials/home.html`, and Contact (`#contact`) is the footer, so it is on
every page. The nav bar is `position: sticky` at a fixed `$header-height` (80px, 64px on phones):
on the home page it follows the hero and sticks once scrolled to; on other pages it is first, so
it takes its own space and nothing pads for it. `html` has `scroll-padding-top` of the same height,
so anchors land below it.

### The hero photo

The landscape photo is due the week of 2026-11-02. Until then the hero shows a designed background
(layered navy gradients, a faint blue and gold glow behind the heading, a vignette and a fine SVG
grain, all in `components/_hero.scss`). To put the photo in:

1. Supply a landscape **JPEG, 2400x1500 (16:10), under 400 KB**, with the subject or the quiet
   part of the picture in the middle third: the heading sits centred over it, and the sides crop
   away on phones (`background-size: cover`, centred).
2. Save it as **`static/imgs/hero.jpg`**.
3. In **`themes/necksurgery/layouts/index.html`**, set `"fullImage" "/imgs/hero.jpg"`.

The hero then shows the photo under a navy overlay (`.hero--photo`); darken the overlay's three
stops there if the photo is bright. Nothing else changes.

## Traps that do not announce themselves

- **Content is raw HTML.** The two `content/*.html` files are HTML fragments with YAML front matter,
  written against the theme's classes (`page legal`, `container content-narrow`, `btn--maroon`). Edit them
  as HTML. They build only because `config.toml` has
  `[security] allowContent = ['^text/markdown$', '^text/html$']`; remove `text/html` and the build
  stops on the policy.
- **`markup.goldmark.renderer.unsafe = true`**: raw HTML inside Markdown is passed through as-is,
  scripts included. Nothing here is Markdown today, so it changes no output; it matters the moment
  Markdown content or a CMS is added.
- **Most of the home page is template, not content.** The hero words are in `layouts/index.html`,
  the About heading and placeholders in `partials/home.html`, the logos in `partials/marquee-logos.html`, the contact placeholders in
  `partials/footer.html`. Only the services list is data (`data/services.yaml`).
- **The `<head>` ignores the page.** `baseof.html` writes the site `description`, `keywords` and
  title into every page's meta description and OG/Twitter tags; the social image is `/imgs/social.png`.
- **The marquee's logos are recoloured by CSS, not edited.** `filter: brightness(0) invert(1)` turns
  every opaque pixel white, which is why the ANZHNCS SVG's unfilled (black) paths show too. ACC is a
  blue square JPEG: it is cropped to the letters by a fixed box and blended with `screen` against
  the marquee band's own colour (`$marquee-bg`) on its wrapper. Change its height and the crop numbers in
  `_marquee.scss` must change with it.
- **The SCSS goes through LibSass.** `toCSS` with no `transpiler` is LibSass, which needs the extended
  edition and which Hugo deprecated in 0.153.0 (a warning every build). The old workflow installed
  Dart Sass, but nothing asked for it, so it was never used. LibSass also tries to evaluate CSS
  `min()`/`max()` itself; wrap modern CSS functions in `unquote("…")`, as the hero's `clamp()` is.
- **`languageCode = 'en-nz'`** is deprecated since Hugo 0.158.0 (use `locale`). The theme writes
  `<html lang="en-NZ">` by hand, so it does not change pages.
- **The menus in `config.toml` render nowhere.** No template reads `.Site.Menus`; the visible nav is
  hard-coded in `header.html` and the privacy link in `footer.html`. Change those, not the menus.
- **`/404.html` is bare.** `layouts/404.html` puts its `<h2>` outside any `define` block, so the page
  has no `<html>`, head, title or styles.
- **`static/js/scripts.js` (theme) defines a global `scrollTo(elementId)`**, which replaces
  `window.scrollTo`: calling `window.scrollTo(0, y)` throws. It came with the copy; nothing on the
  site calls it. Use `window.scroll(…)` in scripts and headless-browser checks.
- **The hero's grain is an inline SVG `data:` URI** in `_hero.scss`. Its filter reference is
  written `url%28%23n%29`, not `url(#n)`: `make test` scans every `url(` in the CSS and would report
  `#n` as a missing file.
- **Wide tracking pushes centred text left.** Letter-spacing adds space after the last letter of
  each line, so centred tracked headings (hero, Services) are padded on the left by the same amount.
  Change one and change the other.
- **The Hugo snap cannot see `/tmp`.** Build into a directory under the checkout (`make test` uses
  `.test/`), never `/tmp`.
- `themes/necksurgery/theme.toml` and `LICENSE` are template leftovers ("SandersonHowe",
  `example.com`, "Copyright (c) 2020 YOUR_NAME_HERE"); they are not built.
- `.vscode/settings.json` came with the copy (`"twiggy.framework": "ignore"`).

## Not done yet

All of this must be done **before the site is published, pushed to a public repository, or shown
to anyone as finished**. Matt has seen nothing of it yet.

**Placeholders on the page** (every one is in `[square brackets]` so it cannot pass for fact):

| Where | Placeholder |
|---|---|
| hero (`layouts/index.html`) | `[MBChB FRACS]` (credentials), `[Otolaryngologist, Head and Neck Surgeon]` (role) |
| About (`partials/home.html`) | four `[Bio to come from Matt: …]` paragraphs |
| Services (`partials/home.html`) | `[Intro to come from Matt: …]` |
| header and Contact | `[Phone number]` (set `params.phone` and `phone_display` in `config.toml`), `[Email address]` (`params.email`) |
| Contact (`partials/footer.html`) | `Suite [X]`, the suite number in the address (`params.address` in `config.toml`; replace `[X]` there); the Directions button beside the address goes nowhere until `params.maps_url` is set |
| footer bar | `[Dr Matt Stretton]` as the legal name (`params.legal_title`): his own name, or a company's? |
| `config.toml` | `info = "[Otolaryngologist, Head and Neck Surgeon]"` (unused by the templates today) |
| `content/privacy-policy.html` | `[Company name]` (twice), `[practice email address]`, `[date]`, and a visible note that the policy must be replaced or reviewed |

**Still Nick's, or unconfirmed:**

1. **The privacy policy's text and structure** are Neck Surgery Limited's with the names removed.
   It needs Matt's own policy (or a reviewed one) for his practice.
2. **The affiliation logos** (Royal Australasian College of Surgeons, ACC, Southern Cross, nib) are
   the files that came with Nick's site, and the ANZHNCS logo is the society's own SVG from
   anzhncs.org. Matt named all five bodies; whether he holds each membership or provider status is
   not confirmed, and each links to the body's home page, not a profile of his.
3. **No logo.** The hero and nav show a made-up gold "MS" diamond monogram
   (`partials/mark.html`) and the nav a text wordmark (`partials/wordmark.html`); the favicons and
   social card are a generated "MS" and name.
4. **No landscape hero photo.** It arrives next week (owner, 2026-10-29). The hero shows a designed
   navy background meanwhile; see "The hero photo" for the file, size and the one line to change.
   The About section uses the 512px headshot, shown no larger than 480px so it stays sharp.
5. **The contact form goes nowhere.** `action="#"` and an empty reCAPTCHA `data-sitekey`; it needs
   Matt's own Static Contact endpoint and key. The map was removed (it was Nick's clinic and key);
   add one back only for Matt's address.
6. **The JSON-LD** has his name, the URL, the services and the opening hours (from `params.hours_days`,
   `hours_open`, `hours_close`). Telephone and email are added automatically once `params.phone` /
   `params.email` / `params.maps_url` are set. The address is not wired up: it waits on the suite
   number, since structured data must not carry the `[X]` placeholder (see `partials/schema.html`).
7. **No git remote.** The commits are local only (see "Branches").
8. **No deploy, and aklent.co.nz is not pointed anywhere.** The source's `.github/workflows/hugo.yml`
   was left out on purpose. Its shape, for reference: on push to `main` (and by hand), install Hugo
   **0.162.1** extended from the release `.deb`, `snap install dart-sass` (unused, see above),
   `actions/configure-pages`, `hugo --gc --minify --baseURL <pages url>` with
   `HUGO_ENVIRONMENT=production`, then `actions/upload-pages-artifact` and **`actions/deploy-pages`**.
   A new workflow should install Hugo with `make setup` and run `make test`, not name a version of
   its own; `make check` fails if it does.

`make test` cannot see any of the above: the placeholders are deliberately not a pattern it flags.

## Conventions

- **Commits**: one plain imperative sentence, capitalised, no prefix, as the
  other SFE sites do. A body says *why* when it is not obvious. No AI attribution.
- Comments in the scripts and Makefile say *why*, not what. Keep that up.
- Run `make test` before committing.
