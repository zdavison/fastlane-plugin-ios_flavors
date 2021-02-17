require 'fastlane/action'
require_relative '../helper/ios_flavors_helper'

module Fastlane
  module Actions   
    module SharedValues
      IOS_FLAVORS_APP_INPUT = :IOS_FLAVORS_APP_INPUT
      IOS_FLAVORS_APP_OUTPUT = :IOS_FLAVORS_APP_OUTPUT
    end

    class CreateSimFlavorsAction < Action
      def self.run(params)
        Helper::IOSFlavorsHelper.verify_dependencies
        params = parse_params(params)
        create_flavors_from(app: params[:app], target_plist: params[:target_plist])
      end
      
      def self.description
        "Create multiple build flavors of an iOS .app (for the simulator) using a directory of .plist files"
      end
      
      def self.authors
        ["Zachary Davison"]
      end
      
      def self.output
        [
          ['IOS_FLAVORS_APP_INPUT', 'The input .app file'],
          ['IOS_FLAVORS_APP_OUTPUT', 'The output directory containing flavors']
        ]
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app,
            env_name: "IOS_FLAVORS_APP",
            description: "The .app file to use as a basis for creating your flavors",
            optional: false,
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
            type: String)
          ]
        end
        
        def self.is_supported?(platform)
          [:ios].include?(platform)
        end

        def self.parse_params(params)
          app = params[:app]
          flavors = params[:flavors] || 'flavors'
          output_directory = params[:output_directory] || 'build_output/flavors'
          target_plist = params[:target_plist] || 'Info.plist'

          raise "You must supply an :app." unless app
          raise 'You must supply a :flavors directory of .plist files.' unless flavors
          raise 'You must supply a :target_plist to be replaced in the :app.' unless target_plist
  
          raise "#{app} not found." unless Dir.exist?(app)
          raise "#{flavors} not found." unless Dir.exist?(flavors)
  
          lane_context[SharedValues::IOS_FLAVORS_APP_INPUT] = File.expand_path(flavors)
          lane_context[SharedValues::IOS_FLAVORS_APP_OUTPUT] = File.expand_path(output_directory)
  
          return {
            app: File.expand_path(app),
            flavors: flavors,
            target_plist: target_plist
          }
        end

        def self.create_flavors_from(app:, target_plist:)
          input_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_APP_INPUT]
          output_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_APP_OUTPUT]
  
          FileUtils.mkdir_p(output_directory)
  
          Dir["#{input_directory}/*.plist"].each do |flavor|
            self.create_flavor_app(app: app, plist: flavor, target_plist: target_plist)
          end
        end
  
        def self.create_flavor_app(app:, plist:, target_plist:)
          output_directory = Actions.lane_context[SharedValues::IOS_FLAVORS_APP_OUTPUT]
  
          expanded = {
            plist: File.expand_path(plist)
          }
  
          output_filename = File.basename(plist, '.plist')
          output_app = "#{output_directory}/#{output_filename}.app"

          UI.header "Flavor: #{output_filename}"
          
          UI.message "Copying #{app} to #{output_app}"
          FileUtils.cp_r(app, output_app, remove_destination: true)
  
          UI.message "Replacing #{output_app}/#{target_plist} with #{plist}"
          FileUtils.cp_r(expanded[:plist],"#{output_app}/#{target_plist}", remove_destination: true)
        end
      end
    end
  end
  