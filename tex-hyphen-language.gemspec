Gem::Specification.new do |s|
  s.name = 'tex-hyphen-language'
  s.version = '0.12.0'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'TeX hyphenation patterns as a gem'
  s.description = 'Hyphenation patterns for Ruby, as used by the TeX typesetting system.'
  s.authors = ["mLengse (medotsys@gmail.com)"]
  s.email = "medotsys@gmail.com"
  s.files = Dir.glob('hyph-utf8/source/generic/hyph-utf8/lib/tex/hyphen/*') +
    Dir.glob('hyph-utf8/source/generic/hyph-utf8/lib/tex/hyphen/texlive/*') +
    Dir.glob('hyph-utf8/tex/generic/hyph-utf8/patterns/tex/*')
  s.homepage = 'https://www.hyphenation.org/tex'
  s.add_dependency 'hydra'
end
