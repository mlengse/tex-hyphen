require 'psych'

class OldLanguage
  @@language_data = Psych::safe_load(
    File.read(File.expand_path('language-data.yml', __dir__))
  )
end
