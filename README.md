# tex-hyphen

[![CI](https://github.com/hyphenation/tex-hyphen/actions/workflows/ci.yml/badge.svg)](https://github.com/hyphenation/tex-hyphen/actions)

The central repository for TeX hyphenation patterns, encoded in UTF-8. These patterns are used by the TeX typesetting system (TeX Live, MiKTeX, W32TeX) and can also be consumed as a Ruby gem via the `tex-hyphen-language` package.

## Project structure

```
tex-hyphen/
├── hyph-utf8/
│   ├── source/generic/hyph-utf8/   # Ruby library, generators, specs
│   ├── tex/generic/hyph-utf8/      # Generated output
│   │   ├── conversions/            # UTF-8 ↔ 8-bit encoding converters
│   │   ├── loadhyph/               # Engine-aware pattern loaders
│   │   └── patterns/
│   │       ├── tex/                # hyph-*.tex (86+ languages, YAML headers)
│   │       ├── ptex/               # pTeX-compatible patterns
│   │       ├── txt/                # Plain-text patterns & exceptions
│   │       └── quote/              # Apostrophe quote files
│   └── doc/                        # Documentation
├── TL/                             # TeX Live integration (.tlpsrc, language.dat)
├── lib/tex/hyphen/                 # Ruby library (packaged as gem)
├── source/                         # Upstream pattern sources (af, indic, tr, …)
├── tests/                          # Cucumber integration tests
├── tools/
│   ├── yaml/validate-header.rb     # YAML header validator
│   └── make_CTAN_zip.sh           # CTAN release packager
├── Rakefile                        # Build tasks
└── tex-hyphen-language.gemspec     # Gem specification
```

## Ruby library

The core class is `TeX::Hyphen::Language`, located in `hyph-utf8/source/generic/hyph-utf8/lib/tex/hyphen/language.rb`. It reads `hyph-*.tex` files, parses their YAML metadata headers, extracts patterns and exceptions, and can hyphenate words using the [Hydra](https://github.com/hyphenation/hydra) gem.

```ruby
require 'tex/hyphen'

lang = TeX::Hyphen::Language.new('en-us')
lang.hyphenate('hyphenation')  # => ["hyp", "hen", "ation"]
```

Key modules:

- **`TeX::Hyphen::Language`** — core class: metadata, patterns, exceptions, hyphenation
- **`TeX::Hyphen::Converter`** — reads encoding `.dat` files, converts 8-bit patterns to UTF-8
- **`TeX::Hyphen::TeXLive::Loader`** — generates `loadhyph-*.tex` content (engine detection, lccodes)
- **`TeX::Hyphen::TeXLive::Package`** — groups languages into TeX Live packages, generates `.tlpsrc`
- **`TeX::Hyphen::Path`** — path constants for all output directories

## Generators

All generators live in `hyph-utf8/source/generic/hyph-utf8/` and read from the `.tex` pattern sources.

| Generator | Output | Rake task |
|-----------|--------|-----------|
| `generate-converters.rb` | `conversions/conv-utf8-*.tex` | `rake converters` |
| `generate-pattern-loaders.rb` | `loadhyph/loadhyph-*.tex` | `rake loaders` |
| `generate-ptex-patterns.rb` | `patterns/ptex/hyph-*.<enc>.tex` | `rake ptex` |
| `generate-tl-files.rb` | `TL/tlpkg/*.tlpsrc`, `TL/…/language.dat` | `rake texlive` |
| `generate-plain-patterns.rb` | `patterns/txt/hyph-*.pat.txt`, `patterns/quote/hyph-quote-*.tex` | `rake plain` |

Run everything at once:

```sh
bundle exec rake build    # all generators + CTAN zip
bundle exec rake          # validate → spec → build
```

## Adding a new language

1. Create a `hyph-<lang>.tex` file in `hyph-utf8/tex/generic/hyph-utf8/patterns/tex/` with a YAML header and pattern body. See existing files for the format.
2. Run `rake validate` to verify the YAML header.
3. Run `bundle exec rake build` to regenerate all derived files.
4. Run `bundle exec rake spec` to ensure nothing is broken.
5. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

## Testing

```sh
bundle install
bundle exec rake          # validate + specs + full build
bundle exec rspec         # specs only
```

RSpec tests live in `hyph-utf8/source/generic/hyph-utf8/spec/`. Cucumber integration tests live in `tests/features/`.

## Licensing

Unless otherwise noted, all files are under the [MIT licence](https://opensource.org/licenses/mit). Pattern files (`hyph-*.tex`) may carry individual licence declarations in their YAML headers; these vary per language and are not necessarily MIT.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding or updating patterns.

Contact: [tex-hyphen mailing list](http://tug.org/mailman/listinfo/tex-hyphen) · [hyphenation.org](http://www.hyphenation.org/tex)
