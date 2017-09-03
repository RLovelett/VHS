#
# Be sure to run `pod lib lint VHS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VHS'
  s.version          = '0.1.0'
  s.summary          = 'HTTP Mock Library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Record your test suite's HTTP interactions and replay them during future test runs for fast,
deterministic, accurate tests.
                       DESC

  s.homepage         = 'https://github.com/RLovelett/VHS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ryan Lovelett' => 'ryan@lovelett.me' }
  s.source           = { :git => 'https://github.com/RLovelett/VHS.git', :tag => s.version.to_s }

  s.osx.deployment_target  = '10.10.0'
  s.ios.deployment_target  = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'VHS/**/*'
  
  # s.resource_bundles = {
  #   'VHS' => ['VHS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Argo', '~> 4.1.0'
  s.dependency 'Curry', '~> 3.0.0'
end
