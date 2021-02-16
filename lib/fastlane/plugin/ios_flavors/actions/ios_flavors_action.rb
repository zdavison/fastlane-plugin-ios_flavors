require 'fastlane/action'
require_relative '../helper/ios_flavors_helper'

module Fastlane
  module Actions
    class IosFlavorsAction < Action
      def self.run(params)
        UI.message("The ios_flavors plugin is working!")
      end

      def self.description
        "Create multiple build flavors of an iOS .ipa file using a directory of .plist files."
      end

      def self.authors
        ["Zachary Davison"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Create multiple build flavors of an iOS .ipa file using a directory of .plist files."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "IOS_FLAVORS_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
