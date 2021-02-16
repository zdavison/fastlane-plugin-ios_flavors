# ios_flavors plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-ios_flavors)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-ios_flavors`, add it to your project by running:

```bash
fastlane add_plugin ios_flavors
```

## About ios_flavors

Create multiple build flavors of an iOS .ipa file using a directory of .plist files.

## Example

```ruby
  create_ipa_flavors(
    ipa: 'My App.ipa', # Base .ipa to use as basis for flavors.
    flavors: 'path/to/flavors/', # [Optional] Directory of .plist files to use as inputs (each creates a new flavor) (default: 'fastlane/flavors')
    output_directory: 'path/to/desired/output/directory', # [Optional] Directory to place flavors in. (default: 'fastlane/build_output/flavors')
    target_plist: 'MyConfig.plist', # [Optional] .plist to replace with each flavor. (default: 'Info.plist')
    signing_identity: 'Apple Distribution: Gem Technologies Limited (XXXXXXXXXXX)', # Signing identity with which to sign your flavor .ipa's
    provisioning_profile: 'path/to/my/provisioning/profile', # [Optional if using `sigh`] Provisioning profile with which to sign your flavor .ipa's
  )
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
