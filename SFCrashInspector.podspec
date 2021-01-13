#
# Be sure to run `pod lib lint SFCrashInspector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SFCrashInspector'
  s.version          = '0.1.0'
  s.summary          = 'iOS开发中常见的崩溃防护方案'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  iOS开发中常见的崩溃防护方案
                       DESC

  s.homepage         = 'https://github.com/jack110530/SFCrashInspector'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jack110530' => 'jack110530@163.com' }
  s.source           = { :git => 'https://github.com/jack110530/SFCrashInspector.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SFCrashInspector/Classes/SFCrashInspector.h'
  s.public_header_files = 'SFCrashInspector/Classes/SFCrashInspector.h'
  
  # SFCrashInspector
  s.subspec 'SFCrashInspector' do |ss|
    ss.source_files = 'SFCrashInspector/Classes/SFCrashInspector/*.{h,m}'
  end
  
  # s.resource_bundles = {
  #   'SFCrashInspector' => ['SFCrashInspector/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/SFCrachInspector.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
