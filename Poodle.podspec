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
    Lib = Base + 'lib/'
    Utils = Base + 'utils/'
    Dynamic = Base + 'Dynamic/'
    Asm = Base + 'asm/'

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

    s.subspec 'NSLockExtension' do |ss|
        ss.source_files = Foundation + 'NSLock+PDLExtension/' + Files
        ss.frameworks = 'Foundation'
        ss.requires_arc = false
    end

    s.subspec 'NSThreadExtension' do |ss|
        ss.source_files = Foundation + 'NSThread+PDLExtension/' + Files
        ss.frameworks = 'Foundation'
        ss.dependency 'Poodle/pthread'
        ss.dependency 'Poodle/mach'
        ss.dependency 'Poodle/NSObjectExtension'
        ss.dependency 'Poodle/mach_o_symbols'
    end

    s.subspec 'NSCharacterSetExtension' do |ss|
        ss.source_files = Foundation + 'NSCharacterSet+PDLExtension/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'CAAnimationExtension' do |ss|
        ss.source_files = CoreAnimation + 'CAAnimation+PDLExtension/' + Files
        ss.frameworks = 'UIKit'
    end

    s.subspec 'CADisplayLinkExtension' do |ss|
        ss.source_files = CoreAnimation + 'CADisplayLink+PDLExtension/' + Files
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

    s.subspec 'UIScreenExtension' do |ss|
        ss.source_files = UIKit + 'UIScreen+PDLExtension/' + Files
        ss.frameworks = 'UIKit'
    end

    s.subspec 'ResizableImageView' do |ss|
        ss.source_files = UIKit + 'PDLResizableImageView/' + Files
        ss.frameworks = 'UIKit'
    end

    s.subspec 'KeyboardNotificationObserver' do |ss|
        ss.source_files = UIKit + 'PDLKeyboardNotificationObserver/' + Files
        ss.frameworks = 'UIKit'
    end

    s.subspec 'die' do |ss|
        ss.source_files = Lib + 'die/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'systemcall' do |ss|
        ss.source_files = Lib + 'systemcall/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'mach_object' do |ss|
        ss.source_files = Lib + 'mach_object/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'mach' do |ss|
        ss.source_files = Lib + 'mach/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'os' do |ss|
        ss.source_files = Lib + 'os/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'utils' do |ss|
        ss.source_files = Utils + Files
    end

    s.subspec 'mach_o_symbols' do |ss|
        ss.source_files = Lib + 'mach_o_symbols/' + Files
        ss.frameworks = 'Foundation'
        ss.libraries = 'c++'
        ss.dependency 'Poodle/mach_object'
    end

    s.subspec 'pthread' do |ss|
        ss.source_files = Lib + 'pthread/' + Files
        ss.frameworks = 'Foundation'
        ss.dependency 'Poodle/mach_o_symbols'
    end

    s.subspec 'asm' do |ss|
        ss.source_files = Asm + Files
    end

    s.subspec 'objc_message' do |ss|
        ss.source_files = Dynamic + 'objc_message/' + Files
        ss.frameworks = 'Foundation'
        ss.dependency 'Poodle/asm'
        ss.dependency 'Poodle/Private'
    end

    s.subspec 'lock_tracer' do |ss|
        ss.source_files = Dynamic + 'lock_tracer/' + Files
        ss.frameworks = 'Foundation'
        ss.dependency 'Poodle/utils'
    end

    s.subspec 'malloc' do |ss|
        ss.source_files = Lib + 'malloc/' + Files
        ss.frameworks = 'Foundation'
    end

    s.subspec 'CollectionViewFlowLayout' do |ss|
        ss.source_files = UIKit + 'PDLCollectionViewFlowLayout/' + Files
        ss.frameworks = 'UIKit'
    end

end

