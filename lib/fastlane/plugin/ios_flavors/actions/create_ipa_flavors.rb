require 'fastlane/action'
require_relative '../helper/ios_flavors_helper'

module Fastlane
  module Actions   
    module SharedValues
      IOS_FLAVORS_INPUT = :IOS_FLAVORS_INPUT
      IOS_FLAVORS_OUTPUT = :IOS_FLAVORS_OUTPUT
      IOS_FLAVORS_SIGNING_IDENTITY = :IOS_FLAVORS_SIGNING_IDENTITY
      IOS_FLAVORS_PROVISIONING_PROFILE = :IOS_FLAVORS_PROVISIONING_PROFILE
    end

    class CreateIpaFlavorsAction < Action
      def self.run(params)
        Helper::IOSFlavorsHelper.verify_dependencies
        params = Helper::IOSFlavorsHelper.parse_params(params)
        create_flavors_from(ipa: params[:ipa], target_plist: params[:target_plist])
      end
      
      def self.description
        "Create multiple build flavors of an iOS .ipa file using a directory of .plist files"
      end
      
      def self.authors
        ["Zachary Davison"]
      end
      
      def self.output
        [
          ['IOS_FLAVORS_INPUT', 'The input .ipa file'],
          ['IOS_FLAVORS_OUTPUT', 'The output directory containing flavors'],
          ['IOS_FLAVORS_SIGNING_IDENTITY', 'The signing identity used to sign flavors'],
          ['IOS_FLAVORS_PROVISIONING_PROFILE', 'The provisioning profile used to sign flavors']
        ]
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
            env_name: "IOS_FLAVORS_IPA",
            description: "The .ipa file to use as a basis for creating your flavors. Can be omitted if using `gym`",
            optional: true,
            type: String),

          FastlaneCore::ConfigItem.new(key: :flavors,
            env_name: "IOS_FLAVORS_INPUT",
            description: "The directory containing .plist files to use to create your flavors",
            default_value: "fastlane/flavors",
            optional: true,
            type: String),

          FastlaneCore::ConfigItem.new(key: :output_directory,
            env_name: "IOS_FLAVORS_OUTPUT",
            description: "The output flavors directory",
            default_value: "fastlane/build_output/flavors",
            optional: true,
            type: String),

          FastlaneCore::ConfigItem.new(key: :target_plist,
            env_name: "IOS_FLAVORS_TARGET_PLIST",
            description: "The name of the .plist file to overwrite with your flavor .plist",
            default_value: "Info.plist",
            optional: true,
            type: String),

          FastlaneCore::ConfigItem.new(key: :signing_identity,
            env_name: "IOS_FLAVORS_SIGNING_IDENTITY",
            description: "The signing identity to use for signing flavors, e.g. 'Apple Distribution: Gem Technologies Limited (XXXXXXXXXXX)'",
            optional: false,
            type: String),

          FastlaneCore::ConfigItem.new(key: :provisioning_profile,
            env_name: "IOS_FLAVORS_PROVISIONING_PROFILE",
            description: "The provisioning profile to use for signing flavors. Can be omitted if using `sigh`",
            optional: true,
            type: String),
          ]
        end
        
        def self.is_supported?(platform)
          [:ios].include?(platform)
        end

        def self.create_flavors_from(ipa:, target_plist:)
          input_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_INPUT]
          output_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_OUTPUT]
  
          FileUtils.mkdir_p(output_directory)
  
          Dir["#{input_directory}/*.plist"].each do |flavor|
            self.create_flavor_ipa(ipa: ipa, plist: flavor, target_plist: target_plist)
          end
        end
  
        def self.create_flavor_ipa(ipa:, plist:, target_plist:)
          output_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_OUTPUT]
          signing_identity = Actions.lane_context[SharedValues::IOS_FLAVORS_SIGNING_IDENTITY]
          provisioning_profile = Actions.lane_context[SharedValues::IOS_FLAVORS_PROVISIONING_PROFILE]
  
          expanded = {
            plist: File.expand_path(plist)
          }
  
          output_filename = File.basename(plist, '.plist')
          output_ipa = "#{output_directory}/#{output_filename}.ipa"

          UI.header "Flavor: #{output_filename}"
          
          UI.message "Copying #{ipa} to #{output_ipa}"
          FileUtils.cp(ipa, output_ipa)
  
          UI.message "Replacing #{target_plist} with #{plist}"
          other_action.act(
            archive_path: output_ipa,
            replace_files: {
              target_plist => expanded[:plist]
            }
          )

          UI.important "Resigning IPA: #{output_ipa}"
          UI.important "Certificate: #{signing_identity}"
          UI.important "Provisioning Profile: #{provisioning_profile}"
          other_action.resign(ipa: output_ipa, signing_identity: signing_identity, provisioning_profile: provisioning_profile)
        end
      end
    end
  end
  