require 'fastlane_core/ui/ui'
require 'fileutils'

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
        provisioning_profile = params[:provisioning_profile] || Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH]

        raise "You must supply an :ipa (can be omitted if using 'ipa')" unless ipa
        raise 'You must supply a :flavors directory of .plist files.' unless flavors
        raise 'You must supply a :target_plist to be replaced in the :ipa.' unless flavors
        raise 'You must supply a :signing_identity' unless signing_identity
        raise "You must supply a :provisioning_profile (can be omitted if using 'sigh')" unless provisioning_profile

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
    end
  end
end
