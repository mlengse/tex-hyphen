require_relative '../../spec_helper'

describe String do
  describe '#superstrip' do
    it "calls String#strip" do
      str = " foo bar "
      expect(str).to receive(:strip).and_return "foo bar"
      str.superstrip
    end

    it "strips TeX comments" do
      expect("foo % bar".superstrip).to eq "foo "
    end
  end

  describe '#supersplit' do
    it "calls String#strip" do
      str = "foo  bar "
      expect(str).to receive(:strip).and_return "foo  bar"
      str.supersplit
    end

    it "splits across whitespace ranges" do
      expect("foo  bar".supersplit).to eq ["foo", "bar"]
    end
  end

  describe '#safe' do
    it "strips hyphens" do
      expect("foo-bar".safe).to eq "foobar"
    end

    it "strips spaces" do
      expect("ancient greek".safe).to eq "ancientgreek"
    end
  end

  describe '#titlecase' do
    it "capitalises each word" do
      expect("modern greek".titlecase).to eq "Modern Greek"
    end
  end
end

# TODO?  Spec out PATH module

describe TeX::Hyphen::Author do
  describe 'Class methods' do
    describe '.authors' do
      it "returns a hash of authors" do
        expect(TeX::Hyphen::Author.authors).to be_a Hash
      end
    end

    describe '.all' do
      it "returns the array of authors" do
        expect(TeX::Hyphen::Author.all).to be_an Array
      end
    end

    describe '.[]' do
      it "returns the author for the key" do
        expect(TeX::Hyphen::Author['donald_knuth']).to be_an TeX::Hyphen::Author
      end
    end
  end

  describe 'Instance methods' do
    let(:dek) { TeX::Hyphen::Author['donald_knuth'] }

    describe '#name' do
      it "returns the author’s name" do
        expect(dek.name).to eq 'Donald'
      end
    end

    describe '#surname' do
      it "returns the author’s surname" do
        expect(dek.surname).to eq 'Knuth'
      end
    end

    describe '#email' do
      it "returns the email" do
        expect(dek.email).to be_nil
      end
    end
  end
end

describe TeX::Hyphen::Language do
  describe 'Class variables' do
    it "has an end-of-header marker" do
      expect(TeX::Hyphen::Language.class_variable_get :@@eohmarker).to match /^\={42}$/
    end
  end

  describe '.new' do
    it "creates a new TeX::Hyphen::Language instance" do
      expect(TeX::Hyphen::Language.new).to be_a TeX::Hyphen::Language
    end

    it "takes an optional BCP47 tag as argument" do
      language = TeX::Hyphen::Language.new('ro')
      expect(language.instance_variable_get :@bcp47).to eq 'ro'
    end

#     it "calls .languages" do
#       expect(TeX::Hyphen::Language).to receive(:languages).and_return({ 'pa' => nil })
#       TeX::Hyphen::Language.new('pa')
#     end
  end

  describe '.languages' do
    it "sets the @@languages class variable" do
      TeX::Hyphen::Language.languages
      expect(TeX::Hyphen::Language.class_variable_get :@@languages).to be_a Hash
    end

    it "lists all languages" do
      expect(TeX::Hyphen::Language.languages.count).to be > 80
    end
  end

  describe '.all' do
    it "returns the list of languages as an array" do
      expect(TeX::Hyphen::Language.all).to be_an Array
    end

    it "returns 86 languages" do # That’s all of them except for [sr-cyrl]
      expect(TeX::Hyphen::Language.all.count).to be > 80
    end
  end

  describe '.all_by_iso639' do
    it "returns a hash of arrays" do
      expect(TeX::Hyphen::Language.all_by_iso639).to be_a Hash
      expect(TeX::Hyphen::Language.all_by_iso639.values.map(&:class).uniq).to eq [Array]
    end

    it "groups languages by ISO 639 code elements" do
      expect(TeX::Hyphen::Language.all_by_iso639['en'].count).to eq 2
    end
  end

  describe '.find_by_bcp47' do
    it "finds the language for that BCP47 tag" do
      language = TeX::Hyphen::Language.find_by_bcp47 'bn'
      expect(language).to be_a TeX::Hyphen::Language
    end

    it "calls .languages first" do
      expect(TeX::Hyphen::Language).to receive(:languages).and_return({ 'cy' => TeX::Hyphen::Language.new('cy') })
      TeX::Hyphen::Language.find_by_bcp47('cy')
    end
  end

  describe '#bcp47' do # TODO Add #8bitenc
    it "returns the BCP47 tag of the language" do
      language = TeX::Hyphen::Language.new('oc')
      expect(language.bcp47).to eq 'oc'
    end
  end

  describe '#iso639' do
    it "returns the ISO 639 primary tag" do
      expect(TeX::Hyphen::Language.new('en-gb').iso639).to eq 'en'
    end

    it "works on 3-character tags" do
      expect(TeX::Hyphen::Language.new('grc-x-ibycus').iso639).to eq 'grc'
    end
  end

  describe '#babelname' do
    it "returns the Babel name" do
      expect(TeX::Hyphen::Language.new('de-1996').babelname).to eq 'ngerman'
    end

    it "calls #extract_metadata first" do
      german_CH = TeX::Hyphen::Language.new('de-ch-1901')
      expect(german_CH).to receive :extract_metadata
      german_CH.babelname
    end
  end

  describe '#licences' do
    let(:church_slavonic) { TeX::Hyphen::Language.new('cu') }

    it "returns the licences as an array" do
      expect(church_slavonic.licences).to eq ['MIT']
    end

    it "call #extract_metadata first if necessary" do
      expect(church_slavonic).to receive(:extract_metadata)
      church_slavonic.licences
    end

    it "doesn’t call #extract_metadata if @licences is already set" do
      church_slavonic.instance_variable_set :@licences, ['MIT licence']
      expect(church_slavonic).not_to receive :extract_metadata
      church_slavonic.licences
    end

    it "raises an exception if @licences is nil or empty" do
      nolicence = TeX::Hyphen::Language.new('qnl')
      allow(File).to receive(:read).and_return("code: qnl\nauthors:\n  - me")
      expect { nolicence.licences }.to raise_exception TeX::Hyphen::NoLicence
    end
  end

  describe '#lefthyphenmin' do
    let(:swiss_spelling_german) { TeX::Hyphen::Language.new('de-ch-1901') }

    it "returns the left hyphenmin value for typesetting" do
      expect(swiss_spelling_german.lefthyphenmin).to eq 2
    end

    it "calls #extract_metadata first if necessary" do
      expect(swiss_spelling_german).to receive :extract_metadata
      swiss_spelling_german.lefthyphenmin
    end

    it "doesn’t call #extract_metadata if @lefthyphenmin is already set" do
      swiss_spelling_german.instance_variable_set :@lefthyphenmin, 1
      expect(swiss_spelling_german).not_to receive :extract_metadata
      swiss_spelling_german.lefthyphenmin
    end

    it "uses the generation value if typesetting is missing" do
      ethiopic = TeX::Hyphen::Language.new('mul-ethi')
      expect(ethiopic.lefthyphenmin).to eq 1
    end
  end

  describe '#righthyphenmin' do
    let(:french) { TeX::Hyphen::Language.new('fr') }

    it "returns the right hyphenmin value for typesetting" do
      expect(french.righthyphenmin).to eq 2
    end

    it "call #extract_metadata first if necessary" do
      expect(french).to receive :extract_metadata
      french.righthyphenmin
    end

    it "doesn’t call #extract_metadata if @righthyphenmin is already set" do
      french.instance_variable_set :@righthyphenmin, 2
      expect(french).not_to receive :extract_metadata
      french.righthyphenmin
    end

    it "uses the generation value if typesetting is missing" do
      ethiopic = TeX::Hyphen::Language.new('mul-ethi')
      expect(ethiopic.righthyphenmin).to eq 1
    end
  end

  describe '#authors' do
    let(:traditional_orthography_german) { TeX::Hyphen::Language.new('de-1901') }

    it "returns the authors as an array" do
      expect(traditional_orthography_german.authors).to eq ['Deutschsprachige Trennmustermannschaft']
    end

    it "calls #extract_metadata first if necessary" do
      expect(traditional_orthography_german).to receive(:extract_metadata).and_return({ authors: ['Werner Lemberg', 'others'] })
      traditional_orthography_german.authors
    end

    it "doesn’t call #extract_metadata if @authors is already set" do
      traditional_orthography_german.instance_variable_set :@authors, ['German hyphenation patterns team']
      expect(traditional_orthography_german).not_to receive :extract_metadata
      traditional_orthography_german.authors
    end
  end

  describe '#synonyms' do
    it "returns the synonyms as an array" do
      expect(TeX::Hyphen::Language.new('sl').synonyms).to eq ['slovene']
    end

    it "returns an empty array instead of nil if there are no synonyms" do
      expect(TeX::Hyphen::Language.new('sk').synonyms).to eq []
    end
  end

  describe '#encoding' do
    it "returns the encoding" do
      expect(TeX::Hyphen::Language.new('sh-cyrl').encoding).to eq 't2a'
    end

    it "returns “ascii” if applicable" do
      expect(TeX::Hyphen::Language.new('pms').encoding).to eq 'ascii'
    end

    it "can also return something else" do
      expect(TeX::Hyphen::Language.new('fur').encoding).to eq 'ec'
    end

    it "returns nil if patterns are Unicode-only" do
      expect(TeX::Hyphen::Language.new('sa').encoding).to be_nil
    end
  end

  describe '#github_link' do
    it "returns the GitHub link" do
      upper_sorbian = TeX::Hyphen::Language.new('hsb')
      expect(upper_sorbian.github_link).to eq 'https://github.com/hyphenation/tex-hyphen/tree/master/hyph-utf8/tex/generic/hyph-utf8/patterns/tex/hyph-hsb.tex'
    end
  end

  describe '#<=>' do
    it "uses BCP47 codes if names are not available" do
      expect(TeX::Hyphen::Language.new('zh-latn-pinyin') <=> TeX::Hyphen::Language.new('cu')).to eq 1
    end
  end

  describe '#readtexfile' do
    let(:basque) { TeX::Hyphen::Language.new('eu') }

    it "reads the TeX file" do
      expect(File).to receive(:read)
      basque.readtexfile
    end

    it "stores the contents into the @@texfile class variable" do
      basque.readtexfile
      expect(TeX::Hyphen::Language.class_variable_get(:@@texfile)['eu']).to match /1ba.*1ko.*1t2xe.*su2b2r/m
    end

    it "recovers gracefully from nonexistent files" do
      expect { TeX::Hyphen::Language.new('kl').readtexfile }.not_to raise_exception
    end
  end

  describe '#patterns' do
    it "returns the patterns" do
      danish = TeX::Hyphen::Language.new('da')
      expect(['.ae3', '.an3k', '.an1s'].all? { |p| danish.patterns.include? p }).to be_truthy
    end

    it "loads the patterns" do
      language = TeX::Hyphen::Language.new('fi')
      expect(language.patterns[151..154]).to eq ['uu1a2', 'uu1e2', 'uu1o2', 'uu1i2']
    end

    it "doesn’t crash on inexistent patterns" do
      expect { TeX::Hyphen::Language.new('zu').patterns }.not_to raise_exception
    end

    it "caches the list of patterns" do
      language = TeX::Hyphen::Language.new('ru')
      language.patterns
      expect(language.instance_variable_get(:@patterns)[0..2]).to eq ['.аб1р', '.аг1ро', '.ади2']
    end

    it "uses the [no] patterns for [nb]" do
      expect(TeX::Hyphen::Language.new('nb').patterns).to eq TeX::Hyphen::Language.new('no').patterns
    end

    it "expands the Esperanto patterns" do
      esperanto = TeX::Hyphen::Language.new('eo')
      expect(['.di3s2a.', '.di3s2aj.', '.di3s2ajn.', '.di3s2an.', '.di3s2e.'].any? { |p| esperanto.patterns.include? p }).to be_truthy
    end
  end

  describe '#exceptions' do
    it "returns the hyphenation exceptions" do
      language = TeX::Hyphen::Language.new('ga')
      expect(language.exceptions[0..2]).to eq ['bhrachtaí', 'mbrachtaí', 'cháintí']
    end

    it "loads the exceptions" do
      language = TeX::Hyphen::Language.new('is')
      expect(File).to receive(:read).and_return("alc-un alc-u-nis-si-me alc-un-men-te")
      language.patterns
    end

    it "doesn’t crash on inexistent patterns" do
      expect { TeX::Hyphen::Language.new('iu').exceptions}.not_to raise_exception
    end

    it "caches the exceptions" do
      language = TeX::Hyphen::Language.new('sk')
      language.exceptions
      expect(language.instance_variable_get(:@exceptions)[0..2]).to match ['dosť', 'me-tó-da', 'me-tó-dy']
    end

    it "hashes the exceptions" do
      language = TeX::Hyphen::Language.new('en-gb')
      language.exceptions
      hyphenation = language.instance_variable_get :@hyphenation
      expect(hyphenation.count).to eq 8
      expect(hyphenation['however']).to eq 'how-ever'
    end
  end

  describe '#hyphenate' do
    it "hyphenates with the appropriate patterns" do
      czech = TeX::Hyphen::Language.new('cs')
      expect(czech.hyphenate('ubrousek')).to eq 'ubrou-sek'
    end

    it "takes hyphenmins in account if available" do
      language = TeX::Hyphen::Language.new('de-1996')
      expect(language.hyphenate('Zwangsvollstreckungsmaßnahme')).to eq 'zwangs-voll-stre-ckungs-maß-nah-me'
    end

    it "takes exceptions in account if available" do
      american_english = TeX::Hyphen::Language.new('en-us')
      expect(american_english.hyphenate('project')).to eq 'project'
    end

    it "initialises the hydra if needed" do
      language = TeX::Hyphen::Language.new('de-1901')
      language.hyphenate('Zwangsvollstreckungsmaßnahme')
      expect(language.instance_variable_get(:@hydra)).to be_a Hydra
    end

    it "calls #exceptions" do
      esperanto = TeX::Hyphen::Language.new('eo')
      expect(esperanto).to receive(:exceptions)
      esperanto.instance_variable_set :@hyphenation, { 'ŝtatregosciencon' => 'ŝta-tre-go-scien-con' }
      esperanto.hyphenate('ŝtatregosciencon')
    end
  end

  describe '#private_use?' do
    it "returns true for languages with private use BCP 47 tags" do
      expect(TeX::Hyphen::Language.new('qls').private_use?).to be_truthy
    end

    it "returns false for non-q-prefixed tags" do
      expect(TeX::Hyphen::Language.new('qyz').private_use?).to be_falsey
    end

    it "doesn’t crash on two-letter tags" do
      expect { TeX::Hyphen::Language.new('qa').private_use? }.not_to raise_exception
    end

    it "returns false on two-letter tags" do
      expect(TeX::Hyphen::Language.new('qt').private_use?).to be_falsey
    end

    it "works correctly on four-letter tags" do
      expect(TeX::Hyphen::Language.new('qaaa').private_use?).to be_falsey
    end

    it "works correctly in the presence of subtags" do
      expect(TeX::Hyphen::Language.new('qtz-GB').private_use?).to be_truthy
    end
  end

  describe '#extract_metadata' do
    it "returns a hash with the metadata" do
      language = TeX::Hyphen::Language.new('bg')
      expect(language.extract_metadata).to be_a Hash
    end

    it "raises an exception if the metadata is just a string" do
      language = TeX::Hyphen::Language.new('qls')
      allow(File).to receive(:read).and_return("just a string")
      expect { language.extract_metadata }.to raise_exception TeX::Hyphen::InvalidMetadata
    end

    it "raises an exception if the licence is missing" do
      language = TeX::Hyphen::Language.new('qlv')
      allow(File).to receive(:read).and_return("name: language virtual\ncode: qlv")
      expect { language.extract_metadata }.to raise_exception TeX::Hyphen::InvalidMetadata
    end

    it "raises an exception if @authors is nil or empty" do
      not_church_slavonic = TeX::Hyphen::Language.new('qcu')
      allow(File).to receive(:read).and_return "code: qcu\nlicence:\n  name:\n    MIT"
      expect { not_church_slavonic.authors }.to raise_exception TeX::Hyphen::NoAuthor
    end

    it "doesn’t crash on invalid licence entries" do
      syntax_error = TeX::Hyphen::Language.new('qse')
      allow(File).to receive(:read).and_return "foo:\nbar"
      expect { syntax_error.extract_metadata }.not_to raise_exception Psych::SyntaxError
    end

    it "sets the language name" do
      language = TeX::Hyphen::Language.new('th')
      language.extract_metadata
      expect(language.instance_variable_get :@name).to eq 'Thai'
    end

    it "sets the licence list" do
      language = TeX::Hyphen::Language.new('la')
      language.extract_metadata
      expect(language.instance_variable_get :@licences).to eq ['MIT', 'LPPL']
    end

    it "sets lefthyphenmin" do
      pali = TeX::Hyphen::Language.new('pi')
      pali.extract_metadata
      expect(pali.instance_variable_get :@lefthyphenmin).to eq 1
    end

    it "sets righthyphenmin" do
      german = TeX::Hyphen::Language.new('de-1996')
      german.extract_metadata
      expect(german.instance_variable_get :@righthyphenmin).to eq 2
    end

    it "sets the list of authors" do
      liturgical_latin = TeX::Hyphen::Language.new('la-x-liturgic')
      liturgical_latin.extract_metadata
      expect(liturgical_latin.instance_variable_get :@authors).to eq ['Claudio Beccari', 'Monastery of Solesmes', 'Élie Roux']
    end

    context "With Swedish as an example" do
      let(:swedish) { TeX::Hyphen::Language.new('sv') }

      it "sets the message" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@message).to eq "Swedish hyphenation patterns"
      end

      it "sets the old pattern file name" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@legacy_patterns).to eq "svhyph.tex"
      end

      it "leaves @use_old_loader to nil in most cases" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@use_old_loader).to be_nil
      end

      it "sets the @use_old_loader boolean to true if applicable" do
        norwegian = TeX::Hyphen::Language.new('no')
        norwegian.extract_metadata
        expect(norwegian.instance_variable_get :@use_old_loader).to be_truthy
      end

      it "leaves @use_old_patterns_comment to nil in most cases" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@use_old_patterns_comment).to be_nil
      end

      it "sets the @use_old_patterns_comment to string if applicable" do
        german_AR = TeX::Hyphen::Language.new('de-1901')
        german_AR.extract_metadata
        expect(german_AR.instance_variable_get :@use_old_patterns_comment).to eq "Kept for the sake of backward compatibility, but newer and better patterns by WL are available."
      end

      it "sets the long description" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@description).to eq "Hyphenation patterns for Swedish in T1/EC and UTF-8 encodings."
      end

      it "sets the Babel name" do
        swedish.extract_metadata
        expect(swedish.instance_variable_get :@babelname).to eq "swedish"
      end

      it "sets the Babel name even if it is slightly silly ;-)" do
        german_NR = TeX::Hyphen::Language.new('de-1996')
        german_NR.extract_metadata
        expect(german_NR.instance_variable_get :@babelname).to eq "ngerman"
      end

      it "sets @package to nil in most cases" do
        expect(swedish.instance_variable_get :@package).to be_nil
      end

      it "sets @package for a few languages" do
        gujarati = TeX::Hyphen::Language.new('gu')
        gujarati.extract_metadata
        expect(gujarati.instance_variable_get :@package).to eq 'indic'
      end
    end
  end

  describe '#has_apostrophes?' do
    it "returns if patterns have apostrophes" do
      expect(TeX::Hyphen::Language.new('be').has_apostrophes?).to be_truthy
    end

    it "returns false otherwise" do
      expect(TeX::Hyphen::Language.new('bn').has_apostrophes?).to be_falsey
    end
  end

  describe '#has_hyphens?' do
    it "returns true if patterns have dashes" do
      expect(TeX::Hyphen::Language.new('uk').has_hyphens?).to be_truthy
    end

    it "returns false otherwise" do
      expect(TeX::Hyphen::Language.new('tr').has_hyphens?).to be_falsey
    end
  end

  describe '#isgreek?' do
    it "returns true if language is Greek (sort of)" do
      expect(TeX::Hyphen::Language.new('grc').isgreek?).to be_truthy
    end

    it "returns false if not" do
      expect(TeX::Hyphen::Language.new('la').isgreek?).to be_falsey
    end

    it "now returns true for Ibycus too" do
      expect(TeX::Hyphen::Language.new('grc-x-ibycus').isgreek?).to be_truthy
    end
  end

  describe '#message' do
    it "returns the message to be displayed on the terminal" do
      expect(TeX::Hyphen::Language.new('af').message).to eq 'Afrikaans hyphenation patterns'
    end
  end

  describe '#known_bugs' do
    it "returns the known bugs" do
      american_english = TeX::Hyphen::Language.new('en-us')
      expect(american_english.known_bugs.keys).to eq ['de-mo-c-rat']
    end
  end

  describe TeX::Hyphen::TeXLive do
    describe '#loadhyph' do
      it "returns the name of the pattern loader file" do
        expect(TeX::Hyphen::Language.new('cy').loadhyph).to eq 'loadhyph-cy.tex'
      end

      it "replaces the main sh subtag by sr" do
        expect(TeX::Hyphen::Language.new('sh-latn').loadhyph).to eq 'loadhyph-sr-latn.tex'
      end

      it "returns the old loader name if applicable" do
        expect(TeX::Hyphen::Language.new('grc-x-ibycus').loadhyph).to eq 'ibyhyph.tex'
      end
    end

    describe '#list_loader' do
      it "returns the tlpsrc line with the loader" do
        expect(TeX::Hyphen::Language.new('hr').list_loader).to eq 'file=loadhyph-hr.tex'
      end

      it "no longer includes an empty line for Arabic and Farsi" do
        expect(TeX::Hyphen::Language.new('ar').list_loader).to eq "file=hyph-ar.tex" # was "file=hyph-ar.tex \\\n\tfile_patterns="
      end

      it "includes a Lua special line for Ibycus" do
        expect(TeX::Hyphen::Language.new('grc-x-ibycus').list_loader).to eq "file=ibyhyph.tex \\\n\tluaspecial=\"disabled:8-bit only\""
      end
    end

    describe '#list_run_files' do
      it "returns the list of TeX file" do
        # pending "Something changed" # ... and changed back
        expect(TeX::Hyphen::Language.new('ka').list_run_files).to eq ['tex/generic/hyph-utf8/loadhyph/loadhyph-ka.tex',
          'tex/generic/hyph-utf8/patterns/tex/hyph-ka.tex',
          'tex/generic/hyph-utf8/patterns/ptex/hyph-ka.t8m.tex',
          'tex/generic/hyph-utf8/patterns/txt/hyph-ka.pat.txt']
      end

      it "works correctly" do
        expect(TeX::Hyphen::Language.new('zh-latn-pinyin').list_run_files).to eq [
          'tex/generic/hyph-utf8/loadhyph/loadhyph-zh-latn-pinyin.tex',
          'tex/generic/hyph-utf8/patterns/tex/hyph-zh-latn-pinyin.tex',
          'tex/generic/hyph-utf8/patterns/tex-8bit/hyph-zh-latn-pinyin.ec.tex',
          'tex/generic/hyph-utf8/patterns/txt/hyph-zh-latn-pinyin.pat.txt']
      end
    end

    describe '#patterns_line' do
      it "returns the patterns line for TLPSRC" do
        expect(TeX::Hyphen::Language.new('tk').patterns_line).to eq "file_patterns=hyph-tk.pat.txt"
      end

      it "returns two files for Serbian" do
        expect(TeX::Hyphen::Language.new('sh-cyrl').patterns_line).to eq "file_patterns=hyph-sh-latn.pat.txt,hyph-sh-cyrl.pat.txt"
      end
    end

    describe '#exceptions_line' do
      it "returns the exceptions line for TLPSRC" do
        expect(TeX::Hyphen::Language.new('nn').exceptions_line).to eq "file_exceptions=hyph-nn.hyp.txt"
      end

      it "returns two files for Serbian" do
        expect(TeX::Hyphen::Language.new('sh-latn').exceptions_line).to eq "file_exceptions=hyph-sh-latn.hyp.txt,hyph-sh-cyrl.hyp.txt"
      end
    end

    describe '#extract_apostrophes' do
      it "returns the list of patterns with apostrophes" do
        expect(TeX::Hyphen::Language.new('af').extract_apostrophes[:with_apostrophe]).to eq ['.af6ro’', '.a7fro’s', '.l’7etji', '.m’7etji', '.r’7etji', 's’9ie.', 'x’9ie.']
      end

      it "returns nil otherwise" do
        expect(TeX::Hyphen::Language.new('nl').extract_apostrophes[:with_apostrophe]).to be_nil
      end
    end

    describe '#extract_characters' do
      it "extracts the list of characters with in lowercase and uppercase" do
        expect(TeX::Hyphen::Language.new('id').extract_characters).to eq ('a'..'z').map { |c| c + c.upcase }
      end
    end

    describe '#comments_and_licence' do
      it "extracts the header" do
        expect(TeX::Hyphen::Language.new('kmr').comments_and_licence).to match /^% title: Hyphenation patterns for Kurmanji \(Northern Kurdish\).*The patterns are generated by patgen from a word list of approx\. 2500\n% hyphenated words provided by Medeni Shemdê$/m
      end
    end

    describe '#list_synonyms' do
      it "returns a list of synonyms" do
        expect(TeX::Hyphen::Language.new('es').list_synonyms).to eq ' synonyms=espanol'
      end
    end

    describe '#list_hyphenmins' do
      it "returns the hyphenmins" do
        expect(TeX::Hyphen::Language.new('gl').list_hyphenmins).to eq "lefthyphenmin=2 \\\n\trighthyphenmin=2"
      end
    end

    describe '#message' do
      it "returns the message to be displayed to TeX users" do
        expect(TeX::Hyphen::Language.new('de-1996').message).to eq 'German hyphenation patterns (reformed orthography)'
      end
    end

    describe '#legacy_patterns' do
      it "returns the file name of the legacy patterns" do
        expect(TeX::Hyphen::Language.new('de-1996').legacy_patterns).to eq 'dehyphn.tex'
      end
    end

    describe '#use_old_loader' do
      it "says whether to use old loader or not" do
        expect(TeX::Hyphen::Language.new('de-1996').use_old_loader).to be_nil
      end

      it "returns true if applicable" do
        # pending "Refactor in progress"
        expect(TeX::Hyphen::Language.new('no').use_old_loader).to be_truthy
      end
    end

    describe '#use_old_patterns_comment' do
      it "returns true if language uses old patterns" do
        expect(TeX::Hyphen::Language.new('de-1996').use_old_patterns_comment).to be_truthy
      end

      it "returns nil otherwise" do
        expect(TeX::Hyphen::Language.new('no').use_old_patterns_comment).to be_nil
      end

      it "is a string" do
        expect(TeX::Hyphen::Language.new('cop').use_old_patterns_comment).to be_a String
      end
    end

    describe '#luaspecial' do
      it "returns the Lua special comment" do
        expect(TeX::Hyphen::Language.new('mn-cyrl-x-lmc').luaspecial).to be == 'disabled:only for 8bit montex with lmc encoding'
      end

      it "returns nil otherwise" do
        expect(TeX::Hyphen::Language.new('mn-cyrl').luaspecial).to be_nil
      end
    end

    describe '#description' do
      it "returns the long description" do
        text = <<-EOD
          Hyphenation patterns for Dutch in T1/EC and UTF-8 encodings.
          These patterns don't handle cases like 'menuutje' > 'menu-tje',
          and don't hyphenate words that have different hyphenations according
          to their meaning.
        EOD
        description = text.split("\n").map(&:strip).join("\n")
        expect(TeX::Hyphen::Language.new('nl').description).to eq description
      end

      it "returns nil for new spelling German, for some reason" do
        expect(TeX::Hyphen::Language.new('de-1996').description).to be_nil
      end
    end

    describe '#package' do
      it "returns the package name if applicable" do
        expect(TeX::Hyphen::Language.new('bn').package).to eq 'indic'
      end

      it "returns nil in most cases" do
        expect(TeX::Hyphen::Language.new('bg').package).to be_nil
      end

      it "calls #extract_metadata first" do
        hindi = TeX::Hyphen::Language.new('hi')
        expect(hindi).to receive :extract_metadata
        hindi.package
      end
    end
  end
end

describe TeX::Hyphen::TeXLive::Package do
  let(:latin) { TeX::Hyphen::TeXLive::Package.find('latin') }
  let(:german) { TeX::Hyphen::TeXLive::Package.find('german') }
  let(:hungarian) { TeX::Hyphen::TeXLive::Package.find('hungarian') }
  let(:norwegian) { TeX::Hyphen::TeXLive::Package.find('norwegian') }

  describe "Instance variables" do
    it "has a @name" do
      expect(latin.name).to eq 'latin'
    end
  end

  describe '.new' do
    it "initialises @languages to an empty array" do
      package = TeX::Hyphen::TeXLive::Package.new('mongolian')
      expect(package.instance_variable_get :@languages).to eq []
    end
  end

  describe "#description_s" do
    it "returns the short description" do
      expect(latin.description_s).to eq 'Latin hyphenation patterns'
    end
  end

  describe "#description" do
    it "returns the long description" do
      expect(latin.description).to match /^Hyphenation patterns for.*modern spelling.*medieval spelling/m
      expect(latin.description).to match /Classical Latin/
      expect(latin.description).to match /Liturgical Latin/
    end

    it "returns the long package description" do
      text = <<-EOD
        Hyphenation patterns for German in T1/EC and UTF-8 encodings,
        for traditional and reformed spelling, including Swiss German.
        The package includes the latest patterns from dehyph-exptl
        (known to TeX under names 'german', 'ngerman' and 'swissgerman'),
        however 8-bit engines still load old versions of patterns
        for 'german' and 'ngerman' for backward-compatibility reasons.
        Swiss German patterns are suitable for Swiss Standard German
        (Hochdeutsch) not the Alemannic dialects spoken in Switzerland
        (Schwyzerduetsch).
        There are no known patterns for written Schwyzerduetsch.
      EOD
      description = text.split("\n").map(&:strip).join("\n")
      expect(TeX::Hyphen::TeXLive::Package.find('german').description).to match description
    end
  end

  describe '#add_language' do
    it "adds a language to the package" do
      package = TeX::Hyphen::TeXLive::Package.new('indic')
      assamese = TeX::Hyphen::Language.new('as')
      package.add_language(assamese)
      expect(package.instance_variable_get(:@languages).first).to eq assamese
    end
  end

  describe "#languages" do
    it "returns the list of languages" do
      expect(latin.languages.map(&:bcp47).sort).to eq ['la', 'la-x-classic', 'la-x-liturgic']
    end
  end

  describe "#has_dependency?" do
    it "returns the external dependencies" do
      expect(german.has_dependency?).to eq "dehyph"
    end

    it "returns nil for most packages" do
      expect(hungarian.has_dependency?).to be_nil
    end
  end

  describe "#list_dependencies" do
    it "lists the dependencies" do
      # FIXME Should return ['depend hyphen-base', 'depend hyph-utf8', 'depend dehyph'] or nothing
      expect(german.has_dependency?).to eq 'dehyph'
    end
  end

  describe "#list_support_files" do # FIXME? list_non_run_files
    it "lists doc and source files" do
      expect(hungarian.list_support_files('doc')).to eq ['doc/generic/hyph-utf8/languages/hu', 'doc/generic/huhyphen']
      # FIXME Should return ['texmf-dist/doc/generic/huhyphen', 'texmf-dist/doc/generic/hyph-utf8/languages/hu'] or nothing
    end
  end

  describe "#list_run_files" do
    it "lists the run-time files" do
      # pending "it crashes ;-)"
      norwegian_run = norwegian.list_run_files
      # pending "it crashes again ;-)" # Fixed now
      expect(norwegian_run.count).to eq 11
      expect(norwegian_run.select { |f| f =~ /tex\/hyph-[^\.]*\.tex$/ }).to eq ['tex/generic/hyph-utf8/patterns/tex/hyph-no.tex',
        'tex/generic/hyph-utf8/patterns/tex/hyph-nb.tex',
        'tex/generic/hyph-utf8/patterns/tex/hyph-nn.tex']
    end
  end

  describe '#<=>' do
    it "compares two TeX::Hyphen::TeXLive::Package’s" do
      # puts hungarian.class, german.class
      expect(hungarian.<=> german).to eq 1
    end
  end

  describe '#find' do
    it "returns the package with that name" do
      expect(TeX::Hyphen::TeXLive::Package.find('norwegian')).to eq norwegian
    end
  end
end

describe TeX::Hyphen::Converter do
  describe '#read' do
    it "reads the conversion data" do
      converter = TeX::Hyphen::Converter.new
      converter.read(File.join(File.expand_path(__dir__), '..', '..', '..', 'data', 'encodings', 'macedonian.dat'))
      mapping = converter.instance_variable_get(:@mapping)
      expect(mapping).to be_a Hash
      expect(mapping.count).to be_equal 42
      expect(mapping[248]).to eq('ш')
    end
  end

  describe '#convert' do
    it "runs one pass through the file" do
      converter = TeX::Hyphen::Converter.new
      converter.read(File.join(File.expand_path(__dir__), '..', '..', '..', 'data', 'encodings', 'macedonian.dat'))
      mkconv = converter.convert(File.join(File.expand_path(__dir__), '..', '..', '..', '..', '..', '..', '..', 'old', 'other', 'mk', 'mkhyphen.tex'))
      expect(mkconv.each_line.count).to eq 725
      expect(mkconv).to be =~ /1шу$/
    end
  end
end
