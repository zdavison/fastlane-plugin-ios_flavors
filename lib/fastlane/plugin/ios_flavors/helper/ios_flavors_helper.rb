require 'fastlane_core/ui/ui'
require 'fileutils'
require 'ipa_utilities'
require 'digest'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class IOSFlavorsHelper
      def self.verify_dependencies
        raise 'fastlane-plugin-act is required.' unless defined?(Fastlane::Actions::ActAction)
      end

      def self.locate_installed_provisioning_profile_for_ipa(path)

        working_directory = Dir.pwd
        ipa = IpaParser.new(path)
        embedded_profile_path = File.expand_path(ipa.provision_profile.provision_path)
        Dir.chdir(working_directory) # IpaParser changes directory while doing its work.

        installed_profiles_dir = File.expand_path('~/Library/MobileDevice/Provisioning Profiles/')
        desired_profile = Dir["#{installed_profiles_dir}/*.mobileprovision"].detect do |installed_profile|
          embedded_data = File.read(embedded_profile_path)
          installed_data = File.read(installed_profile)
          Digest::MD5.hexdigest(embedded_data) == Digest::MD5.hexdigest(installed_data)
        end

        UI.important "Located provisioning profile used to sign .ipa: #{desired_profile}"

        return desired_profile
      end
    end
  end
end
