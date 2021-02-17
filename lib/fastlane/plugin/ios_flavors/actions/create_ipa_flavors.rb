require 'fastlane/action'
require_relative '../helper/ios_flavors_helper'

module Fastlane
  module Actions   
    module SharedValues
      IOS_FLAVORS_IPA_INPUT = :IOS_FLAVORS_IPA_INPUT
      IOS_FLAVORS_IPA_OUTPUT = :IOS_FLAVORS_IPA_OUTPUT
      IOS_FLAVORS_SIGNING_IDENTITY = :IOS_FLAVORS_SIGNING_IDENTITY
      IOS_FLAVORS_PROVISIONING_PROFILE = :IOS_FLAVORS_PROVISIONING_PROFILE
    end

    class CreateIpaFlavorsAction < Action
      def self.run(params)
        Helper::IOSFlavorsHelper.verify_dependencies
        params = parse_params(params)
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
          ['IOS_FLAVORS_IPA_INPUT', 'The input .ipa file'],
          ['IOS_FLAVORS_IPA_OUTPUT', 'The output directory containing flavors'],
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
            env_name: "IOS_FLAVORS_DIRECTORY",
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
            description: "The provisioning profile to use for signing flavors. Can be omitted if using `sigh`, or will automatically attempt to detect via the passed in .ipa file",
            optional: true,
            type: String),
          ]
        end
        
        def self.is_supported?(platform)
          [:ios].include?(platform)
        end

        def self.parse_params(params)
          ipa = params[:ipa] || lane_context[SharedValues::IPA_OUTPUT_PATH]
          flavors = params[:flavors] || 'flavors'
          output_directory = params[:output_directory] || 'build_output/flavors'
          target_plist = params[:target_plist] || 'Info.plist'
          signing_identity = params[:signing_identity]
          provisioning_profile = params[:provisioning_profile] || Helper::IOSFlavorsHelper.locate_installed_provisioning_profile_for_ipa(params[:ipa]) || lane_context[SharedValues::SIGH_PROFILE_PATH]
  
          raise "You must supply an :ipa (can be omitted if using 'ipa')" unless ipa
          raise 'You must supply a :flavors directory of .plist files.' unless flavors
          raise 'You must supply a :target_plist to be replaced in the :ipa.' unless target_plist
          raise 'You must supply a :signing_identity' unless signing_identity
          raise "Could not locate a :provisioning_profile for the :ipa provided." unless provisioning_profile
  
          raise "#{ipa} not found." unless File.file?(ipa)
          raise "#{flavors} not found." unless Dir.exist?(flavors)
          # TODO: Add check for signing_identity validity?
          raise "#{provisioning_profile} not found." unless File.file?(provisioning_profile)
  
          lane_context[SharedValues::IOS_FLAVORS_IPA_INPUT] = File.expand_path(flavors)
          lane_context[SharedValues::IOS_FLAVORS_IPA_OUTPUT] = File.expand_path(output_directory)
          lane_context[SharedValues::IOS_FLAVORS_SIGNING_IDENTITY] = signing_identity 
          lane_context[SharedValues::IOS_FLAVORS_PROVISIONING_PROFILE] = File.expand_path(provisioning_profile)
  
          return {
            ipa: File.expand_path(ipa),
            flavors: flavors,
            target_plist: target_plist,
            signing_identity: signing_identity,
            provisioning_profile: provisioning_profile
          }
        end

        def self.create_flavors_from(ipa:, target_plist:)
          input_directory = lane_context[SharedValues::IOS_FLAVORS_IPA_INPUT]
          output_directory = lane_context[SharedValues::IOS_FLAVORS_IPA_OUTPUT]
  
          FileUtils.mkdir_p(output_directory)
  
          Dir["#{input_directory}/*.plist"].each do |flavor|
            self.create_flavor_ipa(ipa: ipa, plist: flavor, target_plist: target_plist)
          end
        end
  
        def self.create_flavor_ipa(ipa:, plist:, target_plist:)
          output_directory = lane_context[SharedValues::IOS_FLAVORS_IPA_OUTPUT]
          signing_identity = lane_context[SharedValues::IOS_FLAVORS_SIGNING_IDENTITY]
          provisioning_profile = lane_context[SharedValues::IOS_FLAVORS_PROVISIONING_PROFILE]
  
          expanded = {
            plist: File.expand_path(plist)
          }
  
          output_filename = File.basename(plist, '.plist')
          output_ipa = "#{output_directory}/#{output_filename}.ipa"

          UI.header "Flavor: #{output_filename}"
          
          UI.message "Copying #{ipa} to #{output_ipa}"
          FileUtils.cp_r(ipa, output_ipa, remove_destination: true)
  
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
  