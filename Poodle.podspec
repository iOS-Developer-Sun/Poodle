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

  Files = '**/*.{h,c,cpp,hpp,m,mm,s,S,o}'

  Base = 'Poodle/'

  Private = Base + 'Private/'
  Foundation = Base + 'Foundation/'
  UIKit = Base + 'UIKit/'
  CoreAnimation = Base + 'CoreAnimation/'
  OS = Base + 'os/'
  Utils = Base + 'utils/'

  s.subspec 'Private' do |ss|
    ss.source_files = Private + Files
  end

  s.subspec 'NSObjectExtension' do |ss|
    ss.source_files = Foundation + 'NSObject+PDLExtension/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSObjectDebug' do |ss|
    ss.source_files = Foundation + 'NSObject+PDLDebug/' + Files
    ss.frameworks = 'Foundation'
    ss.requires_arc = false
    ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLDebug.m']
  end

  s.subspec 'ImplementationInterceptor' do |ss|
    ss.source_files = Foundation + 'ImplementationInterceptor/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'SafeOperation' do |ss|
    ss.source_files = Foundation + 'SafeOperation/' + Files
    ss.requires_arc = false
    ss.dependency 'Poodle/ImplementationInterceptor'
  end

  s.subspec 'NSCacheExtension' do |ss|
    ss.source_files = Foundation + 'NSCache+PDLExtension/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSMapTableExtension' do |ss|
    ss.source_files = Foundation + 'NSMapTable+PDLExtension/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'NSUserDefaultsExtension' do |ss|
    ss.source_files = Foundation + 'NSUserDefaults+PDLExtension/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'ObjectForKey' do |ss|
    ss.source_files = Foundation + 'NSDictionary+PDLObjectForKey/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'JSONSerialization' do |ss|
    ss.source_files = Foundation + 'JSONSerialization/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'WeakifyUnsafeUnretainedProperty' do |ss|
    ss.source_files = Foundation + 'NSObject+PDLWeakifyUnsafeUnretainedProperty/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'CAAnimationExtension' do |ss|
    ss.source_files = CoreAnimation + 'CAAnimation+PDLExtension/' + Files
    ss.frameworks = 'UIKit'
  end

  s.subspec 'CAMediaTimingFunctionExtension' do |ss|
    ss.source_files = CoreAnimation + 'CAMediaTimingFunction+PDLExtension/' + Files
    ss.frameworks = 'UIKit'
  end

  s.subspec 'UIViewControllerNavigationBar' do |ss|
    ss.source_files = UIKit + 'UIViewController+PDLNavigationBar/' + Files
    ss.frameworks = 'UIKit'
  end

  s.subspec 'UIViewControllerTrasitionAnimation' do |ss|
    ss.source_files = UIKit + 'UIViewController+PDLTrasitionAnimation/' + Files
    ss.frameworks = 'UIKit'
  end

  s.subspec 'PDLResizableImageView' do |ss|
    ss.source_files = UIKit + 'PDLResizableImageView/' + Files
    ss.frameworks = 'UIKit'
  end

  s.subspec 'die' do |ss|
    ss.source_files = OS + 'die/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'systemcall' do |ss|
    ss.source_files = OS + 'systemcall/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'mach_object' do |ss|
    ss.source_files = OS + 'mach_object/' + Files
    ss.frameworks = 'Foundation'
  end

  s.subspec 'utils' do |ss|
    ss.source_files = Utils + Files
  end

  s.subspec 'mach_o_symbols' do |ss|
    ss.source_files = OS + 'mach_o_symbols/' + Files
    ss.frameworks = 'Foundation'
    ss.libraries = 'c++'
  end

end
