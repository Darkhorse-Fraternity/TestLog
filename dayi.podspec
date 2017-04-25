# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
Pod::Spec.new do |s|
  s.name             = "dayi"
  s.version          = "0.1.0"
  s.summary          = "The Frist Public Classes of dayi iOS"
  s.description      = <<-DESC
                      The Frist Public Classes of dayi iOS`.
                       DESC
  s.homepage         = "http://www.dayi.im"
  s.license          = 'MIT'
  s.author           = { "TonyYo" => "lintong320@gmail.com" }
  s.source           = { :git => "git@test.dayi.im:yl/dayi.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.1'
  s.requires_arc     = true
  s.module_name      = "dayi"
  s.frameworks       = 'UIKit', 'Foundation'

  s.subspec 'Base' do |cs|
    cs.source_files = "ServerLog/**/*.{h,m,mm}"
    cs.public_header_files = "ServerLog/**/*.h"
    cs.libraries  = "c++"
    cs.dependency 'GCDWebServer', '~> 3.0'
  end

  s.subspec 'All' do |cs|
    cs.dependency 'dayi/Base'
  end

  s.default_subspecs = 'All'

end
