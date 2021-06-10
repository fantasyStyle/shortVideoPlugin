#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint short_video_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'short_video_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'AliyunVideoSDKBasic','3.16.0'
  s.dependency 'QuCore-ThirdParty','3.15.0'
  s.dependency 'AlivcConan', '1.0.3'
  s.dependency 'MBProgressHUD'
  s.static_framework = true
  s.prefix_header_contents = '#import <UIKit/UIKit.h>', '#import <Foundation/Foundation.h>','#import "AlivcMacro.h"','#import "AliyunVideoSDK.h"','#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>','#import "AliyunBaseSDK-PrefixHeader.pch"'
#  s.ios.resource_bundle ={'QPSDK'=>'short_video_plugin/ios/Assets/*'}
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
