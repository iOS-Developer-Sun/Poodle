SOURCE_FILES = '*.{h,hpp,c,cc,cpp,m,mm,s,S,o}'.freeze
HEADER_FILES = '*.{h,hpp}'.freeze
LIRBARY_FILES = 'lib*.a'.freeze
OSX_VERSION = '10.10'.freeze
IOS_VERSION = '9.0'.freeze

def PoodleCommonConfigurate(s)
    s.version = "0.0.1"
    s.summary = "Lots of fun."
    s.description = <<-DESC
    Poodle, really lots of fun.
    DESC
    s.homepage = "https://github.com/iOS-Developer-Sun/Poodle"
    s.license = "MIT"
    s.author = { "Poodle" => "250764090@qq.com" }
    s.source = { :git => "https://github.com/iOS-Developer-Sun/Poodle.git", :tag => "#{s.version}" }
    s.osx.deployment_target = OSX_VERSION
    s.ios.deployment_target = IOS_VERSION
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end

def PoodleSubspec(s, name, platform)
    support_osx = platform.key?(:osx)
    support_ios = platform.key?(:osx)
    is_library = s.is_library
    is_macos = s.is_macos

    if is_library
        return if (!support_osx && is_macos) || (!support_ios && !is_macos)
    end

    ss = s.subspec name do |ss|
        base = s.base

        ss.frameworks = 'Foundation'
        if s.is_library
            ss.source_files = base + name + '/' + '**/' + HEADER_FILES
            if s.is_macos
                ss.osx.deployment_target = platform[:osx]
                ss.vendored_library = base + name + '/macos/' + LIRBARY_FILES
            else
                ss.ios.deployment_target = platform[:ios]
                ss.vendored_library = base + name + '/ios/' + LIRBARY_FILES
            end
        else
            ss.osx.deployment_target = platform[:osx] if support_osx
            ss.ios.deployment_target = platform[:ios] if support_ios
            ss.source_files = base + name + '/' + '**/' + SOURCE_FILES
        end
        yield(ss) if block_given?
    end
end

def PoodleSpec(name, path: nil, is_library: false, is_macos: false, default_subspec: nil)
    Pod::Spec.new do |s|
        path = name if path == nil

        class << s
            attr_accessor :base, :is_library, :is_macos
        end
        s.base = path + '/'
        s.is_library = is_library
        s.is_macos = is_macos

        s.name = name
        s.default_subspec = default_subspec

        pod_name = name

        PoodleCommonConfigurate(s)

        platform_osx = { :osx => OSX_VERSION }
        platform_ios = { :ios => IOS_VERSION }
        platform_universal = { :osx => OSX_VERSION, :ios => IOS_VERSION }

        PoodleSubspec(s, 'CAAnimation+PDLExtension', platform_universal) do |ss|
            ss.frameworks = 'QuartzCore'
        end

        PoodleSubspec(s, 'CADisplayLink+PDLExtension', platform_ios) do |ss|
            ss.frameworks = 'QuartzCore'
        end

        PoodleSubspec(s, 'CAMediaTimingFunction+PDLExtension', platform_universal) do |ss|
            ss.frameworks = 'QuartzCore'
        end

        PoodleSubspec(s, 'NSCache+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSCharacterSet+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSDictionary+PDLObjectForKey', platform_universal)

        PoodleSubspec(s, 'NSJSONSerialization+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSLock+PDLExtension', platform_universal) do |ss|
            ss.requires_arc = false
        end

        PoodleSubspec(s, 'NSMapTable+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSMutableDictionary+PDLThreadSafety', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'NSObject+PDLAssociation', platform_universal)

        PoodleSubspec(s, 'NSObject+PDLDebug', platform_universal) do |ss|
            ss.requires_arc = false
            ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLDebug.m']
        end

        PoodleSubspec(s, 'NSObject+PDLDescription', platform_universal)

        PoodleSubspec(s, 'NSObject+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSObject+PDLImplementationInterceptor', platform_universal)

        PoodleSubspec(s, 'NSObject+PDLMethod', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_thread_storage'
        end

        PoodleSubspec(s, 'NSObject+PDLSelectorProxy', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'NSObject+PDLThreadSafetifyMethod', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLMethod'
        end

        PoodleSubspec(s, 'NSObject+PDLThreadSafetifyProperty', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLPrivate'
        end

        PoodleSubspec(s, 'NSObject+PDLWeakifyUnsafeUnretainedProperty', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'NSThread+PDLExtension', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_pthread'
            ss.dependency pod_name + '/pdl_mach'
            ss.dependency pod_name + '/NSObject+PDLExtension'
        end

        PoodleSubspec(s, 'NSUserDefaults+PDLExtension', platform_universal)

        PoodleSubspec(s, 'pdl_asm', platform_universal) do |ss|
            ss.public_header_files = s.base + 'pdl_asm/' + 'pdl_asm.h'
        end

        PoodleSubspec(s, 'pdl_allocation', platform_universal) do |ss|
            ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLAllocation.m']
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_backtrace'
            ss.dependency pod_name + '/pdl_utils'
        end


        PoodleSubspec(s, 'pdl_backtrace', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_thread'
        end

        PoodleSubspec(s, 'pdl_block', platform_universal)

        PoodleSubspec(s, 'pdl_die', platform_universal)

        PoodleSubspec(s, 'pdl_dispatch', platform_universal)

        PoodleSubspec(s, 'pdl_dispatch_backtrace', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_backtrace'
        end

        PoodleSubspec(s, 'pdl_dynamic', platform_universal)

        PoodleSubspec(s, 'pdl_hook', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/pdl_vm'
        end

        PoodleSubspec(s, 'pdl_lldb_hook', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_vm'
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/pdl_utils'
        end

        PoodleSubspec(s, 'pdl_mach', platform_universal)

        PoodleSubspec(s, 'pdl_mach_o_const_symbols', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
            ss.dependency pod_name + '/PDLSharedCache'
        end

        PoodleSubspec(s, 'pdl_mach_o_symbol_pointer', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
            ss.dependency pod_name + '/pdl_mach_o_const_symbols'
        end

        PoodleSubspec(s, 'pdl_mach_o_symbols', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
        end

        PoodleSubspec(s, 'pdl_mach_object', platform_universal)

        PoodleSubspec(s, 'pdl_malloc', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_backtrace'
            ss.dependency pod_name + '/pdl_utils'
        end

        PoodleSubspec(s, 'pdl_objc_message', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/PDLPrivate'
            ss.dependency pod_name + '/pdl_thread_storage'
        end

        PoodleSubspec(s, 'pdl_objc_message_hook', platform_universal) do |ss|
            ss.public_header_files = s.base + 'pdl_objc_message_hook/' + 'pdl_objc_message_hook.h'
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/pdl_objc_message'
            ss.dependency pod_name + '/PDLPrivate'
        end

        PoodleSubspec(s, 'pdl_objc_runtime', platform_universal)

        PoodleSubspec(s, 'pdl_os', platform_universal)

        PoodleSubspec(s, 'pdl_pthread', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_o_symbols'
        end

        PoodleSubspec(s, 'pdl_pthread_backtrace', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_backtrace'
            ss.dependency pod_name + '/pdl_thread_storage'
        end

        PoodleSubspec(s, 'pdl_security', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_systemcall'
            ss.dependency pod_name + '/pdl_die'
        end

        PoodleSubspec(s, 'pdl_spinlock', platform_universal)

        PoodleSubspec(s, 'pdl_system_leak', platform_ios) do |ss|
            ss.dependency pod_name + '/pdl_thread'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'pdl_systemcall', platform_universal)

        PoodleSubspec(s, 'pdl_thread', platform_universal)

        PoodleSubspec(s, 'pdl_thread_storage', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_utils'
        end

        PoodleSubspec(s, 'pdl_utils', platform_universal)

        PoodleSubspec(s, 'pdl_vm', platform_universal)

        PoodleSubspec(s, 'pdl_zombie', platform_universal) do |ss|
            ss.requires_arc = false
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'PDLAddressQueryViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLApplication', platform_ios) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
            ss.dependency pod_name + '/CAAnimation+PDLExtension'
        end

        PoodleSubspec(s, 'PDLBacktrace', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_backtrace'
            ss.dependency pod_name + '/PDLCrash'
        end

        PoodleSubspec(s, 'PDLBacktraceRecorder', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLBacktrace'
        end

        PoodleSubspec(s, 'PDLBacktraceRecordsItem', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLBacktraceRecorder'
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'PDLBlock', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/PDLBacktrace'
            ss.dependency pod_name + '/NSObject+PDLDebug'
            ss.dependency pod_name + '/pdl_thread_storage'
            ss.dependency pod_name + '/pdl_block'
        end

        PoodleSubspec(s, 'PDLCollectionViewFlowLayout', platform_ios)

        PoodleSubspec(s, 'PDLColor', platform_ios)

        PoodleSubspec(s, 'PDLCrash', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/PDLSharedCache'
        end

        PoodleSubspec(s, 'PDLDebug', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_security'
            ss.dependency pod_name + '/NSObject+PDLMethod'
        end

        PoodleSubspec(s, 'PDLDatabase', platform_universal) do |ss|
            ss.source_files = s.base + 'PDLDatabase/' + SOURCE_FILES
            ss.public_header_files = s.base + 'PDLDatabase/' + '*.h'
        end

        PoodleSubspec(s, 'PDLFileSystem', platform_universal)

        PoodleSubspec(s, 'PDLFileSystemViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLFileSystem'
            ss.dependency pod_name + '/PDLDatabase'
            ss.dependency pod_name + '/PDLViewController'
            ss.dependency pod_name + '/PDLCrash'
            ss.dependency pod_name + '/PDLColor'
            ss.dependency pod_name + '/PDLFormView'
        end

        PoodleSubspec(s, 'PDLFontViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLFormView', platform_ios) do |ss|
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'PDLImageListViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLViewController'
            ss.dependency pod_name + '/NSObject+PDLDebug'
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
        end

        PoodleSubspec(s, 'PDLInitialization', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLDebug'
            ss.dependency pod_name + '/pdl_objc_runtime'
        end

        PoodleSubspec(s, 'PDLKeyboardNotificationObserver', platform_ios)

        PoodleSubspec(s, 'PDLLoad', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_objc_runtime'
        end

        PoodleSubspec(s, 'PDLMemoryQueryViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/pdl_malloc'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLNonThreadSafeObserver', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSObject+PDLDebug'
            ss.dependency pod_name + '/PDLPrivate'
            ss.dependency pod_name + '/PDLProcessInfo'
            ss.dependency pod_name + '/PDLBacktrace'
            ss.dependency pod_name + '/PDLCrash'
            ss.dependency pod_name + '/pdl_dispatch'
        end

        PoodleSubspec(s, 'PDLOpenUrlViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLOverlayWindow', platform_ios)

        PoodleSubspec(s, 'PDLPageControl', platform_ios)

        PoodleSubspec(s, 'PDLPageController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLFormView'
        end

        PoodleSubspec(s, 'PDLPageView', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLPageController'
        end

        PoodleSubspec(s, 'PDLPageViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLPageController'
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'PDLProcessInfo', platform_universal)

        PoodleSubspec(s, 'PDLPrivate', platform_universal)

        PoodleSubspec(s, 'PDLPudding', platform_universal)

        PoodleSubspec(s, 'PDLResizableImageView', platform_ios)

        PoodleSubspec(s, 'PDLReuseItemManager', platform_universal) do |ss|
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'PDLRunLoopObserver', platform_universal)

        PoodleSubspec(s, 'PDLSafeOperation', platform_universal) do |ss|
            ss.requires_arc = false
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'PDLScreenDebugger', platform_ios)

        PoodleSubspec(s, 'PDLScrollPageViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLReuseItemManager'
        end

        PoodleSubspec(s, 'PDLSessionTaskStatisticsManager', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLProcessInfo'
        end

        PoodleSubspec(s, 'PDLSharedCache', platform_universal) do |ss|
            ss.public_header_files = s.base + 'PDLSharedCache/' + '**/*.h'
            ss.libraries = 'c++'
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
        end

        PoodleSubspec(s, 'PDLSystemImage', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
        end

        PoodleSubspec(s, 'PDLTaskManager', platform_universal)

        PoodleSubspec(s, 'PDLViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLColor'
        end

        PoodleSubspec(s, 'PDLViewControllerListViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'UINavigationController+PDLLongPressPop', platform_ios)

        PoodleSubspec(s, 'UIScreen+PDLExtension', platform_ios)

        PoodleSubspec(s, 'UIView+PDLDebug', platform_ios) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSObject+PDLExtension'
        end

        PoodleSubspec(s, 'UIViewController+PDLExtension', platform_ios) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'UIViewController+PDLNavigationBar', platform_ios)

        PoodleSubspec(s, 'UIViewController+PDLTransitionAnimation', platform_ios)
    end
end

def PoodleDynamicSpec(name, path: nil, is_library: false, base_pod_name: nil, default_subspec: nil)
    Pod::Spec.new do |s|
        path = name if path == nil

        class << s
            attr_accessor :base, :is_library
        end
        s.base = path + '/'
        s.is_library = is_library

        s.name = name
        s.default_subspec = default_subspec

        pod_name = name

        PoodleCommonConfigurate(s)

        platform_osx = { :osx => "10.10" }
        platform_ios = { :ios => "9.0" }
        platform_universal = { :osx => "10.10", :ios => "9.0" }

        PoodleSubspec(s, 'pdl_dynamic', platform_universal)

        PoodleSubspec(s, 'pdl_os_unfair_lock_tracer', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency base_pod_name + '/pdl_utils'
            ss.dependency base_pod_name + '/pdl_spinlock'
        end

        PoodleSubspec(s, 'pdl_pthread_lock_tracer', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency base_pod_name + '/pdl_utils'
            ss.dependency base_pod_name + '/pdl_spinlock'
        end
    end
end
