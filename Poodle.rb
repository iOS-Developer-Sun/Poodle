def PoodleCommonConfigurate(s)
    s.module_name = "Poodle"
    s.version = "0.0.1"
    s.summary = "Lots of fun."
    s.description = <<-DESC
    Poodle, really lots of fun.
    DESC
    s.homepage = "https://github.com/iOS-Developer-Sun/Poodle"
    s.license = "MIT"
    s.author = { "Poodle" => "250764090@qq.com" }
    s.source = { :git => "https://github.com/iOS-Developer-Sun/Poodle.git", :tag => "#{s.version}" }
end

def PoodleSubspec(s, name, platform)
    support_osx = platform.key?(:osx)
    support_ios = platform.key?(:ios)
    hash = s.pdl_hash
    base = hash[:base]
    is_library = hash[:is_library]
    is_macos = hash[:is_macos]
    source_files = hash[:source_files]
    header_files = hash[:header_files]
    preserve_paths = hash[:preserve_paths]
    library_files = hash[:library_files]
    toolkit_osx = hash[:toolkit_osx]
    toolkit_ios = hash[:toolkit_ios]

    if is_library
        return if (!support_osx && is_macos) || (!support_ios && !is_macos)
    end

    ss = s.subspec name do |ss|
        ss.frameworks = 'Foundation'
        ss.preserve_paths = preserve_paths
        ss.exclude_files = base + '/' + name + '/exclude/' + '**/' + '*'
        #ss.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }
        if is_library
            ss.source_files = base + '/' + name + '/' + '**/' + source_files
            if is_macos
                ss.osx.deployment_target = platform[:osx]
                ss.vendored_library = base + '/' + name + '/macos/' + library_files
            else
                ss.ios.deployment_target = platform[:ios]
                ss.vendored_library = base + '/' + name + '/ios/' + library_files
            end
        else
            ss.osx.deployment_target = platform[:osx] if support_osx
            ss.ios.deployment_target = platform[:ios] if support_ios
            ss.source_files = base + '/' + name + '/' + '**/' + source_files
            ss.private_header_files = base + '/' + name + '/private/' + '**/' + header_files

            if is_macos
                ss.vendored_library = base + '/' + name + '/lib/macos/**/' + library_files
            else
                ss.vendored_library = base + '/' + name + '/lib/ios/**/' + library_files
            end
        end
        hash[:toolkit_osx].append name if support_osx
        hash[:toolkit_ios].append name if support_ios

        yield(ss) if block_given?
    end
end

def PoodleSpec(name, path: nil, is_library: false, is_macos: false, default_subspec: nil)
    Pod::Spec.new do |s|
        path = name if path == nil
        base = path

        # constants
        source_files = '*.{h,hpp,c,cc,cpp,m,mm,s,S,o}'.freeze
        header_files = '*.{h,hpp}'.freeze
        preserve_paths = '*.{md,sh,py,rb,plist}'.freeze
        library_files = '*.a'.freeze
        osx_version = '11.0'.freeze
        ios_version = '11.0'.freeze

        # extra storage
        class << s
            attr_accessor :pdl_hash
        end
        s.pdl_hash = {
            :base => base,
            :is_library => is_library,
            :is_macos => is_macos,
            :source_files => source_files,
            :header_files => header_files,
            :preserve_paths => preserve_paths,
            :library_files => library_files,
        }

        s.name = name
        s.default_subspec = default_subspec
        s.osx.deployment_target = osx_version
        s.ios.deployment_target = ios_version

        PoodleCommonConfigurate(s)

        if is_library
            s.pod_target_xcconfig = {
                'OTHER_LDFLAGS' => '$(inherited) -ObjC'
            }
            s.user_target_xcconfig = {
                'OTHER_LDFLAGS' => '$(inherited) -ObjC'
            }
        else
            s.pod_target_xcconfig = {
                'OTHER_LDFLAGS' => '$(inherited) -ObjC'
            }
        end

        # varirables for subspec
        pod_name = name
        platform_osx = { :osx => osx_version }
        platform_ios = { :ios => ios_version }
        platform_universal = { :osx => osx_version, :ios => ios_version }

        s.pdl_hash[:toolkit_ios] = []
        s.pdl_hash[:toolkit_osx] = []

        PoodleSubspec(s, 'PDLSwiftModule', platform_universal)

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

        PoodleSubspec(s, 'NSData+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSDate+PDLExtension', platform_universal)

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

        PoodleSubspec(s, 'NSObject+PDLImplementationInterceptor', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_pac'
        end

        PoodleSubspec(s, 'NSObject+PDLMethod', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_thread_storage'
            ss.dependency pod_name + '/pdl_trampoline'
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

        PoodleSubspec(s, 'NSString+PDLExtension', platform_universal)

        PoodleSubspec(s, 'NSThread+PDLExtension', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_pthread'
            ss.dependency pod_name + '/pdl_mach'
            ss.dependency pod_name + '/NSObject+PDLExtension'
        end

        PoodleSubspec(s, 'NSUserDefaults+PDLExtension', platform_universal)

        PoodleSubspec(s, 'pdl_asm', platform_universal) do |ss|
            ss.public_header_files = base + '/' + 'pdl_asm' + '/' + '**/' + header_files
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

        PoodleSubspec(s, 'pdl_dispatch', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_hook'
        end

        PoodleSubspec(s, 'pdl_dispatch_backtrace', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_backtrace'
        end

        PoodleSubspec(s, 'pdl_dynamic', platform_universal)

        PoodleSubspec(s, 'pdl_hook', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/pdl_pac'
            ss.dependency pod_name + '/pdl_vm'
        end

        PoodleSubspec(s, 'pdl_lldb_hook', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_vm'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_pac'
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
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/pdl_objc_message'
            ss.dependency pod_name + '/PDLPrivate'
        end

        PoodleSubspec(s, 'pdl_objc_runtime', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_pac'
            ss.dependency pod_name + '/pdl_vm'
        end

        PoodleSubspec(s, 'pdl_os', platform_universal)

        PoodleSubspec(s, 'pdl_pac', platform_universal)

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

        PoodleSubspec(s, 'pdl_swift', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_hook'
            ss.dependency pod_name + '/pdl_utils'
        end

        PoodleSubspec(s, 'pdl_system_leak', platform_ios) do |ss|
            ss.dependency pod_name + '/pdl_thread'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'pdl_systemcall', platform_universal)

        PoodleSubspec(s, 'pdl_thread', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_pac'
        end

        PoodleSubspec(s, 'pdl_thread_storage', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_spinlock'
        end

        PoodleSubspec(s, 'pdl_trampoline', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_vm'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_pac'
            ss.dependency pod_name + '/pdl_thread_storage'
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
            ss.dependency pod_name + '/pdl_pac'
            ss.dependency pod_name + '/pdl_vm'
        end

        PoodleSubspec(s, 'PDLCollectionViewFlowLayout', platform_ios)

        PoodleSubspec(s, 'PDLColor', platform_ios)

        PoodleSubspec(s, 'PDLCrash', platform_universal) do |ss|
            ss.dependency pod_name + '/PDLSystemImage'
            ss.dependency pod_name + '/PDLSharedCache'
        end

        PoodleSubspec(s, 'PDLDeadLockObserver', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_hook'
            ss.dependency pod_name + '/pdl_dispatch'
            ss.dependency pod_name + '/pdl_thread_storage'
            ss.dependency pod_name + '/PDLProcessInfo'
            ss.dependency pod_name + '/PDLBacktrace'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        PoodleSubspec(s, 'PDLDebug', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_security'
            ss.dependency pod_name + '/NSObject+PDLMethod'
        end

        PoodleSubspec(s, 'PDLDSym', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
        end

        PoodleSubspec(s, 'PDLDatabase', platform_universal)

        PoodleSubspec(s, 'PDLFileSystem', platform_universal) do |ss|
            ss.dependency pod_name + '/NSData+PDLExtension'
        end

        PoodleSubspec(s, 'PDLFileSystemViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLFileSystem'
            ss.dependency pod_name + '/PDLDatabase'
            ss.dependency pod_name + '/PDLViewController'
            ss.dependency pod_name + '/PDLCrash'
            ss.dependency pod_name + '/PDLColor'
            ss.dependency pod_name + '/PDLFormView'
            ss.dependency pod_name + '/PDLImageListViewController'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/NSDate+PDLExtension'
        end

        PoodleSubspec(s, 'PDLFontViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLFormView', platform_ios) do |ss|
            ss.dependency pod_name + '/NSMapTable+PDLExtension'
        end

        PoodleSubspec(s, 'PDLGeometry', platform_ios)

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
            ss.dependency pod_name + '/pdl_pac'
            ss.dependency pod_name + '/pdl_vm'
        end

        PoodleSubspec(s, 'PDLKeyboardNotificationObserver', platform_ios)

        PoodleSubspec(s, 'PDLLoad', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_objc_runtime'
        end

        PoodleSubspec(s, 'PDLMachObject', platform_universal) do |ss|
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_block'
        end

        PoodleSubspec(s, 'PDLMemoryQueryViewController', platform_ios) do |ss|
            ss.dependency pod_name + '/pdl_malloc'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        PoodleSubspec(s, 'PDLMemoryTracer', platform_universal) do |ss|
            ss.requires_arc = false
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_utils'
        end

        PoodleSubspec(s, 'PDLNonThreadSafeObserver', platform_universal) do |ss|
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSObject+PDLDebug'
            ss.dependency pod_name + '/PDLPrivate'
            ss.dependency pod_name + '/PDLProcessInfo'
            ss.dependency pod_name + '/PDLBacktrace'
            ss.dependency pod_name + '/PDLCrash'
            ss.dependency pod_name + '/pdl_dispatch'
            ss.dependency pod_name + '/pdl_swift'
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_thread_storage'
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

        # tool kit
        PoodleSubspec(s, 'PDLToolKit_iOS', platform_ios) do |ss|
            s.pdl_hash[:toolkit_ios].each do |each_name|
                ss.dependency pod_name + '/' + each_name if each_name != 'PDLToolKit_iOS'
            end
        end

        PoodleSubspec(s, 'PDLToolKit_macOS', platform_osx) do |ss|
            s.pdl_hash[:toolkit_osx].each do |each_name|
                ss.dependency pod_name + '/' + each_name if each_name != 'PDLToolKit_macOS'
            end
        end
    end
end
