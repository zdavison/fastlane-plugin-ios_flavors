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

      def self.parse_params(params)
        ipa = params[:ipa] || Actions.lane_context[Actions::SharedValues::IPA_OUTPUT_PATH]
        flavors = params[:flavors] || 'flavors'
        output_directory = params[:output_directory] || 'build_output/flavors'
        target_plist = params[:target_plist] || 'Info.plist'
        signing_identity = params[:signing_identity]
        provisioning_profile = params[:provisioning_profile] || locate_installed_provisioning_profile_for_ipa(params[:ipa]) || Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH]

        raise "You must supply an :ipa (can be omitted if using 'ipa')" unless ipa
        raise 'You must supply a :flavors directory of .plist files.' unless flavors
        raise 'You must supply a :target_plist to be replaced in the :ipa.' unless flavors
        raise 'You must supply a :signing_identity' unless signing_identity
        raise "Could not locate a :provisioning_profile for the :ipa provided." unless provisioning_profile

        raise "#{ipa} not found." unless File.file?(ipa)
        raise "#{flavors} not found." unless Dir.exist?(flavors)
        # TODO: Add check for signing_identity validity?
        raise "#{provisioning_profile} not found." unless File.file?(provisioning_profile)

        Actions.lane_context[Actions::SharedValues::IOS_FLAVORS_INPUT] = File.expand_path(flavors)
        Actions.lane_context[Actions::SharedValues::IOS_FLAVORS_OUTPUT] = File.expand_path(output_directory)
        Actions.lane_context[Actions::SharedValues::IOS_FLAVORS_SIGNING_IDENTITY] = signing_identity 
        Actions.lane_context[Actions::SharedValues::IOS_FLAVORS_PROVISIONING_PROFILE] = File.expand_path(provisioning_profile)

        return {
          ipa: File.expand_path(ipa),
          flavors: flavors,
          target_plist: target_plist,
          signing_identity: signing_identity,
          provisioning_profile: provisioning_profile
        }
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
