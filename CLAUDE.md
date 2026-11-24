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
(branch `design-v2`; see "Branches"), and on 2026-11-25 simplified on the owner's feedback ("it
was just quite a lot"): on desktop the sticky nav bar is the top of the page and About opens with
his name in tracked capitals (the second line gold), credentials, role and subtitle, beside the
scrub photo; below desktop a short navy intro (monogram, the same name block, a gold button) comes
before the nav bar, then the photo, then About. Then the bio's last paragraph as a pull quote,
a moving band of affiliation logos; four service tiles on a cream band; and a navy contact section. Jost headings, Inter body
text, navy, gold and maroon. **Much of the copy is still bracketed placeholders**, and
the privacy policy is still the old practice's text with the names taken out: see "Not done yet".

Its remote is `Matt-Stretton/Matt-stretton.github.io` on GitHub (public, since 2026-11-17), and a
push to `main` builds and publishes it to GitHub Pages (`.github/workflows/pages.yml`). See "Branches" for what is on which. Within SFE it sits at
`sfe/matt-stretton.github.io/`, untracked by SFE like every product. The folder name suggests a
GitHub Pages user site, which it now is: https://matt-stretton.github.io/.

No JavaScript build, no `package.json`, no database, no server-side code. The page loads Alpine.js
from unpkg (unversioned; it drives the phone menu), Lineicons and animate.css from CDNs, the two
Google Fonts (from the stylesheet's `@import`), and Static Contact's botbuster script with the form. There
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
                          for the JSON-LD) and address lines, the phone (E.164 and as written),
                          email and maps_url), menus
content/
  privacy-policy.html     /privacy-policy/  (a draft, so not built: the old practice's policy, names replaced by placeholders)
  thankyou.html           /thankyou/  (the contact form's landing page)
data/services.yaml        the four service groups and their items, in Matt's words; each names its icon
static/imgs/
  matt-stretton-scrubs.webp   the About photo ("The photo"); matt-stretton.webp is the old headshot, unused
  logo_college_of_surgens.png, logo-southen-cross.svg, logo-anzhncs.svg, logo-nib.svg
                          affiliation logos (logo-nib.svg is unused: the marquee inlines nib's path)
  social.png              1200x630 OG/Twitter card; favicon-32.png, favicon-16.png,
                          apple-touch-icon.png (gold "MS" on navy). All four generated with PIL.
themes/necksurgery/       the theme, tracked here, not a submodule
  layouts/_default/baseof.html   every page's <head>: meta, canonical, OG/Twitter, favicons, CSS;
                          in <body>, a "hero" block (filled only by the home page), then the nav
  layouts/index.html      the home page: components/hero (the "hero" block), then
                          partials/home.html
  layouts/partials/
    home.html             below the nav: About (name block on desktop, "Meet" heading below
                          it, photo), the care quote (the bio's last paragraph as a pull
                          quote, white and left-aligned beside a gold quote mark: on $navy-2 (#17304F) below desktop, navy on desktop; moved out of About so the photo sits higher on a
                          1440x900 screen), the marquee, Services
    header.html           the sticky navy nav bar: monogram + wordmark (on the home page it
                          scrolls to the top instead of reloading), Services and Contact links
                          (no About, since 2026-11-25), phone link, gold
                          "Make an enquiry" button ("Enquiry" from 600 to 900px), Alpine burger
                          for phones
    mark.html             Matt's gold "MS" logo mark, inline SVG (intro top and nav)
    wordmark.html         the "Dr Matt Stretton" lettering beside the mark in the nav, inline SVG
    components/hero.html  the intro above the nav bar, below 900px only: monogram, name block,
                          gold button, centred on plain navy, the window's height less the nav
                          bar's (so the nav is at the foot of the first screen). Hidden on desktop
    name-block.html       the two-line name, credentials, role and subtitle; the three lines
                          under the name share one font, size and colour. In the intro and
                          at the top of About; only one shows at any width
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
scripts/                  setup, serve, preview, test, check-site.py, known-defects.txt,
                          make-about-photo.py (builds the About photo; see "The photo")
```

There is no `content/_index.md`, no services or contact page: Services (`/#services`) and About
(`/#about`) are sections of `partials/home.html`, and Contact (`#contact`) is the footer, so it is on
every page. The nav bar is `position: sticky` at a fixed `$header-height` (80px, 64px on phones):
on the home page below 900px it follows the intro and sticks once scrolled to; on desktop and
on other pages it is first, so
it takes its own space and nothing pads for it. `html` has `scroll-padding-top` of the same height,
so anchors land below it.

### The photo

Matt's photos arrived on 2026-11-11 (`.doncheckin/Matt Stretton -4.jpg`, scrubs on a dark studio
backdrop, and `-5.jpg`, a suit on grey concrete, both upright). Since 2026-11-25 the site uses only
`-4`, as `static/imgs/matt-stretton-scrubs.webp`, built by `scripts/make-about-photo.py`: the
photo less its top 775px (of 3283), so about 40px shows above his head at phone width, resized to
1440x1650; the studio backdrop's light falloff evened out to one flat `$studio` (`#272D31`); then
its left 12%, right 17% and top 6% blended into that colour. On desktop About's ground is
`$studio` too, so the photo has no visible edge wherever it lands (owner, 2026-11-25: "no fade",
no hard line); below desktop About's text is on navy and the photo is a grey block above it. If
the photo changes, re-measure the backdrop and the script's numbers.

On desktop the photo is on the left and the text on the right, as the old full-screen hero had
them (owner, 2026-11-25). The photo's box is the section's left half out to the window's edge,
its full height. The image sits on the box's bottom with Matt centred in the box (his middle is
49% across the photo, so `left: 50%; translateX(-49%)`), and is as tall as the box unless that
would make him wider than the box less 100px: `height: min(100%, calc((100cqw - 100px) * 1.752))`, the box being a
size container. So a narrow desktop window shrinks him rather than cutting him off, leaving
section colour above him. The image runs on under the text (the box is `overflow: visible`, the
text `z-index: 1`, the section `overflow: hidden`) so that its own blended right edge, not the
column's edge, is where it meets the section. The text, not the photo, sets the section's
height; both are pinned to `grid-row: 1`, as the photo's columns come first. The section is at
least the window less the nav bar, with the text centred in it; from 1400px the text runs on
into the right margin (up to 780px of text), so at 1920x1080 the section is exactly one screen.
Smaller desktops scroll. Below
desktop it runs the full width straight under the nav bar, no taller than the window less the bar. The suit photo was dropped and the full-screen
photo hero (`hero-matt.jpg`, `hero-matt-portrait.jpg`, built from `-4` with made-up backdrop) went
with the hero; both are in git on `main` before that date. `static/imgs/hero.jpg` (untracked,
1.9 MB) is an earlier stand-in, unreferenced.

## Traps that do not announce themselves

- **Content is raw HTML.** The two `content/*.html` files are HTML fragments with YAML front matter,
  written against the theme's classes (`page legal`, `container content-narrow`, `btn--maroon`). Edit them
  as HTML. They build only because `config.toml` has
  `[security] allowContent = ['^text/markdown$', '^text/html$']`; remove `text/html` and the build
  stops on the policy.
- **`markup.goldmark.renderer.unsafe = true`**: raw HTML inside Markdown is passed through as-is,
  scripts included. Nothing here is Markdown today, so it changes no output; it matters the moment
  Markdown content or a CMS is added.
- **Most of the home page is template, not content.** The name, credentials and subtitle are in `partials/name-block.html`,
  the About heading and placeholders in `partials/home.html`, the logos in `partials/marquee-logos.html`, the contact placeholders in
  `partials/footer.html`. Only the services list is data (`data/services.yaml`).
- **The `<head>` ignores the page.** `baseof.html` writes the site `description`, `keywords` and
  title into every page's meta description and OG/Twitter tags; the social image is `/imgs/social.png`.
- **The marquee's logos are recoloured by CSS, not edited.** `filter: brightness(0) invert(1)` turns
  every opaque pixel white, which is why the ANZHNCS SVG's unfilled (black) paths show too.
- **The SCSS goes through LibSass.** `toCSS` with no `transpiler` is LibSass, which needs the extended
  edition and which Hugo deprecated in 0.153.0 (a warning every build). The old workflow installed
  Dart Sass, but nothing asked for it, so it was never used. LibSass also tries to evaluate CSS
  `min()`/`max()` itself; wrap modern CSS functions in `unquote("…")` (`clamp()`, `aspect-ratio`'s `960 / 1440`).
- **`languageCode = 'en-nz'`** is deprecated since Hugo 0.158.0 (use `locale`). The theme writes
  `<html lang="en-NZ">` by hand, so it does not change pages.
- **The menus in `config.toml` render nowhere.** No template reads `.Site.Menus`; the visible nav is
  hard-coded in `header.html` and the privacy link in `footer.html`. Change those, not the menus.
- **`/404.html` is bare.** `layouts/404.html` puts its `<h2>` outside any `define` block, so the page
  has no `<html>`, head, title or styles.
- **`static/js/scripts.js` (theme) defines a global `scrollTo(elementId)`**, which replaces
  `window.scrollTo`: calling `window.scrollTo(0, y)` throws. It came with the copy; nothing on the
  site calls it. Use `window.scroll(…)` in scripts and headless-browser checks.
- **`make test` scans every `url(` in the CSS** and reports what it points at as a missing file,
  so an inline SVG `data:` URI with a filter must write `url%28%23n%29`, not `url(#n)`.
- **Wide tracking pushes centred text left.** Letter-spacing adds space after the last letter of
  each line, so centred tracked headings (the intro's name, Services) are padded on the left by the same amount.
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
| `content/privacy-policy.html` | **hidden since 2026-11-17** (`draft: true`, footer link and menu entry commented out) until the text is Matt's own. Still in it: `[Company name]` (twice), `[practice email address]`, `[date]`, and a visible note that the policy must be replaced or reviewed |

The phone number (09 219 1865) came from Matt on 2026-11-25. The credentials (MBChB FRACS) and role, and the footer bar's legal name (Dr Matt Stretton),
lost their brackets on 2026-11-17 on the owner's say-so.

**Matt's copy arrived on 2026-11-11**: the About bio, the Services intro, two service-list
changes, the suite number (11) and the contact email (`admin@aklent.co.nz`; the mailbox was still
to be set up that day). The footer bar carries a small RAH Panthers logo
(`static/imgs/logo-rah-panthers.webp`), an easter egg he asked for.

**Still Nick's, or unconfirmed:**

1. **The privacy policy's text and structure** are Neck Surgery Limited's with the names removed.
   It needs Matt's own policy (or a reviewed one) for his practice.
2. **The affiliation logos** (Royal Australasian College of Surgeons, Southern Cross, nib) are
   the files that came with Nick's site, and the ANZHNCS logo is the society's own SVG from
   anzhncs.org. Matt named these bodies; whether he holds each membership or provider status is
   not confirmed, and each links to the body's home page, not a profile of his. ACC was in the
   band and was taken out (owner, 2026-11-04).
3. **The logo is in (2026-11-11), the social card is not redone.** `partials/mark.html` is the
   solid "MS" mark from the designer's mock-ups (`.doncheckin/fwdlogomockupoptions/4.svg`), in the
   site's gold, in the intro and the nav; the favicons are the same mark cut from `4.png`. Which
   mock-up option Matt prefers is not confirmed. The nav lettering (`partials/wordmark.html`) is the designer's
   own letterforms from the same file, as outlines; `social.png` is still the generated name card.
4. **The photo** is the scrub one only, since 2026-11-25. See "The photo".
   `matt-stretton.webp`, the first 512px headshot, is no longer used.
5. **The contact form posts to Static Contact** (`https://staticcontact.com/send/<Matt's form key>`,
   in `partials/footer.html`, since 2026-11-18), guarded by Static Contact's botbuster script, not
   reCAPTCHA. Not yet tested with a real submission; the form's Return URL in Static Contact should
   be the site's `/thankyou/`. The map was removed (it was Nick's clinic and key); add one back
   only for Matt's address.
6. **The JSON-LD** has his name, the URL, the services and the opening hours (from `params.hours_days`,
   `hours_open`, `hours_close`). Telephone and email are added automatically once `params.phone` /
   `params.email` / `params.maps_url` are set. The address comes from `params.postal`, which repeats
   `params.address` in parts: change both together.
7. **aklent.co.nz is not pointed anywhere.** The site is published at
   https://matt-stretton.github.io/ by `.github/workflows/pages.yml` on every push to `main`
   (since 2026-11-17): `make setup`, `make check`, `make test`, then the production build with the
   Pages base URL, `actions/upload-pages-artifact` and `actions/deploy-pages`. The workflow names
   no Hugo version; `make check` fails if it does. The custom domain is still to do: the DNS
   records, then Settings > Pages > Custom domain. The build picks the new base URL up by itself.

`make test` cannot see any of the above: the placeholders are deliberately not a pattern it flags.

## Conventions

- **Commits**: one plain imperative sentence, capitalised, no prefix, as the
  other SFE sites do. A body says *why* when it is not obvious. No AI attribution.
- Comments in the scripts and Makefile say *why*, not what. Keep that up.
- Run `make test` before committing.
