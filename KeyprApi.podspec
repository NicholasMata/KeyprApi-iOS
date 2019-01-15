#
# Be sure to run `pod lib lint KeyprApi.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeyprApi'
  s.version          = '0.9'
  s.summary          = 'A wrapper for KEYPR Api'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A wrapper for KEYPR Api for things like looking up reservations, check-in, and check-out.
                       DESC

  s.homepage         = 'https://github.com/MataDesigns/KeyprApi-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nicholas Mata' => 'nicholas@matadesigns.net' }
  s.source           = { :git => 'https://github.com/MataDesigns/KeyprApi-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'KeyprApi/**/*'
  s.exclude_files = 'KeyprApi/*.plist'

  s.frameworks =  'Foundation'
end
