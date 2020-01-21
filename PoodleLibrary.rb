def PoodleLibrarySpec(name, is_library)
    pod_name = name
    Pod::Spec.new do |s|
        s.name         = pod_name
        s.version      = "0.0.1"
        s.summary      = "Lots of fun."

        s.description  = <<-DESC
        PoodleLibrary
        DESC

        s.homepage     = "https://github.com/iOS-Developer-Sun/Poodle"
        s.license      = "MIT"

        s.author       = { "Poodle" => "250764090@qq.com" }

#        s.platform     = { :ios => "9.0", :osx => "10.10" }
#        s.platform     = :ios, "9.0"
#        s.static_framework = true

        s.source       = { :git => "https://github.com/iOS-Developer-Sun/Poodle", :tag => "#{s.version}" }

        source_files = '**/*.{h,c,cpp,hpp,m,mm,s,S,o}'
        header_files = '**/*.{h}'
        librariy_files = '**/*.{a}'

        base = 'Poodle/'
        asm = base + 'asm/'
        coreanimation = base + 'CoreAnimation/'
        dev = base + 'dev/'
        dynamic = base + 'Dynamic/'
        foundation = base + 'Foundation/'
        lib = base + 'lib/'
        lldb = base + 'lldb/'
        private = base + 'Private/'
        uikit = base + 'UIKit/'
        utils = base + 'utils/'

        if is_library
            source_files = header_files

            base = 'PoodleLibrary/'
            asm = base
            coreanimation
            dev = base
            dynamic = base
            foundation = base
            lib = base
            lldb = base
            private = base
            uikit = base
            utils = base
        end

        platform_osx = :osx, "10.10"
        platform_ios = :ios, "9.0"
        platform_universal = { :osx => "10.10", :ios => "9.0" }

        s.ios.deployment_target  = '9.0'
        s.osx.deployment_target  = '10.10'

        # asm
        s.subspec 'asm' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = asm + 'pdl_asm/' + source_files
            ss.vendored_library = asm + 'pdl_asm/' + librariy_files
        end

        s.subspec 'Private' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = private + 'PDLPrivate/' + source_files
            ss.vendored_library = private + 'PDLPrivate/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObjectExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObjectDebug' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLDebug/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLDebug/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.requires_arc = false
            ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLDebug.m']
        end

        s.subspec 'ImplementationInterceptor' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLImplementationInterceptor/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLImplementationInterceptor/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'SelectorProxy' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLSelectorProxy/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLSelectorProxy/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/ImplementationInterceptor'
        end

        s.subspec 'SafeOperation' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'PDLSafeOperation/' + source_files
            ss.vendored_library = foundation + 'PDLSafeOperation/' + librariy_files
            ss.requires_arc = false
            ss.dependency pod_name + '/ImplementationInterceptor'
        end

        s.subspec 'NSCacheExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSCache+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSCache+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSMapTableExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSMapTable+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSMapTable+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSUserDefaultsExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSUserDefaults+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSUserDefaults+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'ObjectForKey' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSDictionary+PDLObjectForKey/' + source_files
            ss.vendored_library = foundation + 'NSDictionary+PDLObjectForKey/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'JSONSerialization' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'PDLJSONSerialization/' + source_files
            ss.vendored_library = foundation + 'PDLJSONSerialization/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'WeakifyUnsafeUnretainedProperty' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLWeakifyUnsafeUnretainedProperty/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLWeakifyUnsafeUnretainedProperty/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'ThreadSafetifyProperty' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSObject+PDLThreadSafetifyProperty/' + source_files
            ss.vendored_library = foundation + 'NSObject+PDLThreadSafetifyProperty/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/ImplementationInterceptor'
            ss.dependency pod_name + '/Private'
        end

        s.subspec 'NSLockExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSLock+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSLock+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.requires_arc = false
        end

        s.subspec 'NSThreadExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSThread+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSThread+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pthread'
            ss.dependency pod_name + '/mach'
            ss.dependency pod_name + '/NSObjectExtension'
        end

        s.subspec 'NSCharacterSetExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'NSCharacterSet+PDLExtension/' + source_files
            ss.vendored_library = foundation + 'NSCharacterSet+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'CAAnimationExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = coreanimation + 'CAAnimation+PDLExtension/' + source_files
            ss.vendored_library = coreanimation + 'CAAnimation+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'CADisplayLinkExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = coreanimation + 'CADisplayLink+PDLExtension/' + source_files
            ss.vendored_library = coreanimation + 'CADisplayLink+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'CAMediaTimingFunctionExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = coreanimation + 'CAMediaTimingFunction+PDLExtension/' + source_files
            ss.vendored_library = coreanimation + 'CAMediaTimingFunction+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'UIViewControllerNavigationBar' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'UIViewController+PDLNavigationBar/' + source_files
            ss.vendored_library = uikit + 'UIViewController+PDLNavigationBar/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'UIViewControllerTrasitionAnimation' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'UIViewController+PDLTrasitionAnimation/' + source_files
            ss.vendored_library = uikit + 'UIViewController+PDLTrasitionAnimation/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'UIScreenExtension' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'UIScreen+PDLExtension/' + source_files
            ss.vendored_library = uikit + 'UIScreen+PDLExtension/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'ResizableImageView' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLResizableImageView/' + source_files
            ss.vendored_library = uikit + 'PDLResizableImageView/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'KeyboardNotificationObserver' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLKeyboardNotificationObserver/' + source_files
            ss.vendored_library = uikit + 'PDLKeyboardNotificationObserver/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'die' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_die/' + source_files
            ss.vendored_library = lib + 'pdl_die/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'systemcall' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_systemcall/' + source_files
            ss.vendored_library = lib + 'pdl_systemcall/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'mach_object' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_mach_object/' + source_files
            ss.vendored_library = lib + 'pdl_mach_object/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'mach' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_mach/' + source_files
            ss.vendored_library = lib + 'pdl_mach/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'os' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_os/' + source_files
            ss.vendored_library = lib + 'pdl_os/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'spinlock' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_spinlock/' + source_files
            ss.vendored_library = lib + 'pdl_spinlock/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'utils' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_utils/' + source_files
            ss.vendored_library = base + 'pdl_utils/' + librariy_files
        end

        s.subspec 'mach_o_symbols' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_mach_o_symbols/' + source_files
            ss.vendored_library = lib + 'pdl_mach_o_symbols/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/mach_object'
        end

        s.subspec 'mach_o_const_symbols' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_mach_o_const_symbols/' + source_files
            ss.vendored_library = lib + 'pdl_mach_o_const_symbols/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.libraries = 'c++'
            ss.dependency pod_name + '/mach_object'
            ss.dependency pod_name + '/mach_o_symbols'
        end

        s.subspec 'mach_o_symbol_pointer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_mach_o_symbol_pointer/' + source_files
            ss.vendored_library = lib + 'pdl_mach_o_symbol_pointer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/mach_object'
            ss.dependency pod_name + '/mach_o_symbols'
            ss.dependency pod_name + '/mach_o_const_symbols'
        end

        s.subspec 'pthread' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_pthread/' + source_files
            ss.vendored_library = lib + 'pdl_pthread/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/mach_o_symbols'
        end

        s.subspec 'dynamic' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = dynamic + 'pdl_dynamic/' + source_files
            ss.vendored_library = dynamic + 'pdl_dynamic/' + librariy_files
        end

        s.subspec 'objc_message' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = dynamic + 'pdl_objc_message/' + source_files
            ss.vendored_library = dynamic + 'pdl_objc_message/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/dynamic'
            ss.dependency pod_name + '/asm'
            ss.dependency pod_name + '/Private'
        end

        s.subspec 'os_unfair_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = dynamic + 'pdl_os_unfair_lock_tracer/' + source_files
            ss.vendored_library = dynamic + 'pdl_os_unfair_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/dynamic'
            ss.dependency pod_name + '/utils'
        end

        s.subspec 'pthread_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = dynamic + 'pdl_pthread_lock_tracer/' + source_files
            ss.vendored_library = dynamic + 'pdl_pthread_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/dynamic'
            ss.dependency pod_name + '/utils'
        end

        s.subspec 'malloc' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lib + 'pdl_malloc/' + source_files
            ss.vendored_library = lib + 'pdl_malloc/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'CollectionViewFlowLayout' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLCollectionViewFlowLayout/' + source_files
            ss.vendored_library = uikit + 'PDLCollectionViewFlowLayout/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'SystemImage' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'PDLSystemImage/' + source_files
            ss.vendored_library = foundation + 'PDLSystemImage/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/mach_object'
        end

        s.subspec 'PageControl' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLPageControl/' + source_files
            ss.vendored_library = uikit + 'PDLPageControl/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'FormView' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLFormView/' + source_files
            ss.vendored_library = uikit + 'PDLFormView/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'PDLViewController/' + source_files
            ss.vendored_library = uikit + 'PDLViewController/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'LongPressPop' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = uikit + 'UINavigationController+PDLLongPressPop/' + source_files
            ss.vendored_library = uikit + 'UINavigationController+PDLLongPressPop/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'ImageListViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLImageListViewController/' + source_files
            ss.vendored_library = base + 'PDLImageListViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'FileSystemViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFileSystemViewController/' + source_files
            ss.vendored_library = base + 'PDLFileSystemViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/Database'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'AddressQueryViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLAddressQueryViewController/' + source_files
            ss.vendored_library = base + 'PDLAddressQueryViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'MemoryQueryViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLMemoryQueryViewController/' + source_files
            ss.vendored_library = base + 'PDLMemoryQueryViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/malloc'
            ss.dependency pod_name + '/KeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'FontViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFontViewController/' + source_files
            ss.vendored_library = base + 'PDLFontViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'OpenUrlViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLOpenUrlViewController/' + source_files
            ss.vendored_library = base + 'PDLOpenUrlViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/KeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'ScreenDebugger' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLScreenDebugger/' + source_files
            ss.vendored_library = base + 'PDLScreenDebugger/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'Database' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = foundation + 'PDLDatabase/' + source_files
            ss.vendored_library = foundation + 'PDLDatabase/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'lldb_hook' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = lldb + 'pdl_lldb_hook/' + source_files
            ss.vendored_library = lldb + 'pdl_lldb_hook/' + librariy_files
        end

        s.subspec 'NonThreadSafePropertyObserver' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLNonThreadSafePropertyObserver/' + source_files
            ss.vendored_library = base + 'PDLNonThreadSafePropertyObserver/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/ImplementationInterceptor'
            ss.dependency pod_name + '/NSObjectDebug'
            ss.dependency pod_name + '/Private'
        end
    end
end
