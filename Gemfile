source('https://rubygems.org')

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# Until this MR is merged: https://github.com/nsomar/ipa_utilities/pull/1
gem "ipa_utilities", git: 'https://github.com/zdavison/ipa_utilities'
