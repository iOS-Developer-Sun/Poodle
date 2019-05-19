Pod::Spec.new do |s|
  s.name         = "Poodle"
  s.version      = "0.0.1"
  s.summary      = "Lots of fun."

  s.description  = <<-DESC
		  Poodle
                   DESC

  s.homepage     = "https://github.com/iOS-Developer-Sun/Poodle"
  s.license      = "MIT"

  s.author             = { "sun" => "250764090@qq.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/iOS-Developer-Sun/Poodle", :tag => "#{s.version}" }

  s.subspec 'Private' do |ss|
    ss.source_files = 'Private/**/*.{h,m}'
  end

  s.subspec 'NSObjectExtension' do |ss|
    ss.source_files = 'NSObject+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSObjectDebug' do |ss|
    ss.source_files = 'NSObject+PDLDebug/**/*.{h,m}'
    ss.frameworks = 'Foundation'
    ss.requires_arc = false
    ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLDebug.m']
  end

  s.subspec 'ImplementationInterceptor' do |ss|
    ss.source_files = 'ImplementationInterceptor/**/*.{h,m,s}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'SafeOperation' do |ss|
    ss.source_files = 'SafeOperation/**/*.{h,m}'
    ss.requires_arc = false
    ss.dependency 'Poodle/ImplementationInterceptor'
  end

  s.subspec 'NSCacheExtension' do |ss|
    ss.source_files = 'NSCache+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSMapTableExtension' do |ss|
    ss.source_files = 'NSMapTable+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSUserDefaultsExtension' do |ss|
    ss.source_files = 'NSUserDefaults+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'ObjectForKey' do |ss|
    ss.source_files = 'NSDictionary+PDLObjectForKey/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'JSONSerialization' do |ss|
    ss.source_files = 'JSONSerialization/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'WeakifyUnsafeUnretainedProperty' do |ss|
    ss.source_files = 'NSObject+PDLWeakifyUnsafeUnretainedProperty/**/*.{h,m}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'CAAnimationExtension' do |ss|
    ss.source_files = 'CAAnimation+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'UIKit'
  end

  s.subspec 'CAMediaTimingFunctionExtension' do |ss|
    ss.source_files = 'CAMediaTimingFunction+PDLExtension/**/*.{h,m}'
    ss.frameworks = 'UIKit'
  end

  s.subspec 'UIViewControllerNavigationBar' do |ss|
    ss.source_files = 'UIViewController+PDLNavigationBar/**/*.{h,m}'
    ss.frameworks = 'UIKit'
  end

  s.subspec 'UIViewControllerTrasitionAnimation' do |ss|
    ss.source_files = 'UIViewController+PDLTrasitionAnimation/**/*.{h,m}'
    ss.frameworks = 'UIKit'
  end

  s.subspec 'die' do |ss|
    ss.source_files = 'os/die/**/*.{h,c,s}'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'systemcall' do |ss|
    ss.source_files = 'os/systemcall/**/*.{h,c,s}'
    ss.frameworks = 'Foundation'
  end

end
