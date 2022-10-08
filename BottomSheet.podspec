Pod::Spec.new do |spec|
  spec.name         = "BottomSheet"
  spec.version      = "2.0.1"
  spec.summary      = "Bottom Sheet for iOS"
  spec.homepage     = "https://medium.com/joomtech/bottom-sheet-shall-we-drop-the-formalities-400515255829"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "Joom"
  spec.ios.deployment_target = "12.0"
  spec.source       = { 
    :git => "https://github.com/joomcode/BottomSheet.git", 
    :tag => "#{spec.version}",
    :submodules => true
  }

  spec.swift_versions = '5.7'
  spec.source_files = 'Sources/**/*{h,m,swift}'
  spec.exclude_files = 'Sources/BottomSheetUtils/BottomSheetUtils.h'
end
