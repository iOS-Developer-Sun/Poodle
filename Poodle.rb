def PoodleCommonConfigurate(s)
    s.version = "0.0.1"
    s.summary = "Lots of fun."
    s.description = <<-DESC
    Poodle
    DESC
    s.homepage = "https://github.com/iOS-Developer-Sun/Poodle"
    s.license = "MIT"
    s.author = { "Poodle" => "250764090@qq.com" }
    s.source = { :git => "https://github.com/iOS-Developer-Sun/Poodle", :tag => "#{s.version}" }

#    s.platform     = { :ios => "9.0", :osx => "10.10" }
#    s.platform     = :ios, "9.0"
#    s.static_framework = true
end

def PoodleSpec(name, path: nil, is_library: false, default_subspec: nil)
    pod_name = name
    Pod::Spec.new do |s|
        s.name = pod_name

        PoodleCommonConfigurate(s)

        source_files = '**/*.{h,hpp,c,cc,cpp,m,mm,s,S,o}'
        header_files = '**/*.{h,hpp}'
        librariy_files = '**/*.{a}'

        if path == nil
            path = name
        end

        if is_library
            source_files = header_files
        end

        if default_subspec
            s.default_subspec = default_subspec
        end

        base = path + '/'

        platform_osx = :osx, "10.10"
        platform_ios = :ios, "9.0"
        platform_universal = { :osx => "10.10", :ios => "9.0" }

        s.ios.deployment_target  = '9.0'
        s.osx.deployment_target  = '10.10'

        s.subspec 'CAAnimation+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'CAAnimation+PDLExtension/' + source_files
            ss.vendored_library = base + 'CAAnimation+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'CADisplayLink+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'CADisplayLink+PDLExtension/' + source_files
            ss.vendored_library = base + 'CADisplayLink+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'CAMediaTimingFunction+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'CAMediaTimingFunction+PDLExtension/' + source_files
            ss.vendored_library = base + 'CAMediaTimingFunction+PDLExtension/' + librariy_files
            ss.frameworks = 'QuartzCore'
        end

        s.subspec 'NSCache+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSCache+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSCache+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSCharacterSet+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSCharacterSet+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSCharacterSet+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSDictionary+PDLObjectForKey' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSDictionary+PDLObjectForKey/' + source_files
            ss.vendored_library = base + 'NSDictionary+PDLObjectForKey/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSJSONSerialization+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSJSONSerialization+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSJSONSerialization+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSLock+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSLock+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSLock+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.requires_arc = false
        end

        s.subspec 'NSMapTable+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSMapTable+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSMapTable+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObject+PDLAssociation' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLAssociation/' + source_files
            ss.vendored_library = base + 'NSObject+PDLAssociation/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObject+PDLDebug' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLDebug/' + source_files
            ss.vendored_library = base + 'NSObject+PDLDebug/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.requires_arc = false
            ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLDebug.m']
        end

        s.subspec 'NSObject+PDLDescription' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLDescription/' + source_files
            ss.vendored_library = base + 'NSObject+PDLDescription/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObject+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSObject+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObject+PDLImplementationInterceptor' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLImplementationInterceptor/' + source_files
            ss.vendored_library = base + 'NSObject+PDLImplementationInterceptor/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'NSObject+PDLMethod' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLMethod/' + source_files
            ss.vendored_library = base + 'NSObject+PDLMethod/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_utils'
            ss.dependency pod_name + '/pdl_thread_storage'
        end

        s.subspec 'NSObject+PDLSelectorProxy' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLSelectorProxy/' + source_files
            ss.vendored_library = base + 'NSObject+PDLSelectorProxy/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'NSObject+PDLThreadSafetifyMethod' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLThreadSafetifyMethod/' + source_files
            ss.vendored_library = base + 'NSObject+PDLThreadSafetifyMethod/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLMethod'
        end

        s.subspec 'NSObject+PDLThreadSafetifyProperty' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLThreadSafetifyProperty/' + source_files
            ss.vendored_library = base + 'NSObject+PDLThreadSafetifyProperty/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLPrivate'
        end

        s.subspec 'NSObject+PDLWeakifyUnsafeUnretainedProperty' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSObject+PDLWeakifyUnsafeUnretainedProperty/' + source_files
            ss.vendored_library = base + 'NSObject+PDLWeakifyUnsafeUnretainedProperty/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'NSThread+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSThread+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSThread+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_pthread'
            ss.dependency pod_name + '/pdl_mach'
            ss.dependency pod_name + '/NSObject+PDLExtension'
        end

        s.subspec 'NSUserDefaults+PDLExtension' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'NSUserDefaults+PDLExtension/' + source_files
            ss.vendored_library = base + 'NSUserDefaults+PDLExtension/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_asm' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_asm/' + source_files
            ss.vendored_library = base + 'pdl_asm/' + librariy_files
        end

        s.subspec 'pdl_allocation' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_allocation/' + source_files
            ss.vendored_library = base + 'pdl_allocation/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.requires_arc = false
            ss.requires_arc = ['NSObject+PDLDebug/NSObject+PDLAllocation.m']
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/pdl_backtrace'
        end

        s.subspec 'pdl_backtrace' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_backtrace/' + source_files
            ss.vendored_library = base + 'pdl_backtrace/' + librariy_files
            ss.dependency pod_name + '/pdl_thread'
        end

        s.subspec 'pdl_block' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_block/' + source_files
            ss.vendored_library = base + 'pdl_block/' + librariy_files
        end

        s.subspec 'pdl_die' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_die/' + source_files
            ss.vendored_library = base + 'pdl_die/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_dispatch' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_dispatch/' + source_files
            ss.vendored_library = base + 'pdl_dispatch/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_dispatch_backtrace' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_dispatch_backtrace/' + source_files
            ss.vendored_library = base + 'pdl_dispatch_backtrace/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_backtrace'
        end

        s.subspec 'pdl_dynamic' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_dynamic/' + source_files
            ss.vendored_library = base + 'pdl_dynamic/' + librariy_files
        end

        s.subspec 'pdl_hook' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_hook/' + source_files
            ss.vendored_library = base + 'pdl_hook/' + librariy_files
        end

        s.subspec 'pdl_lldb_hook' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_lldb_hook/' + source_files
            ss.vendored_library = base + 'pdl_lldb_hook/' + librariy_files
            ss.dependency pod_name + '/pdl_vm'
            ss.dependency pod_name + '/PDLSystemImage'
        end

        s.subspec 'pdl_mach' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_mach/' + source_files
            ss.vendored_library = base + 'pdl_mach/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_mach_o_const_symbols' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_mach_o_const_symbols/' + source_files
            ss.vendored_library = base + 'pdl_mach_o_const_symbols/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
            ss.dependency pod_name + '/PDLSharedCache'
        end

        s.subspec 'pdl_mach_o_symbol_pointer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_mach_o_symbol_pointer/' + source_files
            ss.vendored_library = base + 'pdl_mach_o_symbol_pointer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_mach_object'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
            ss.dependency pod_name + '/pdl_mach_o_const_symbols'
        end

        s.subspec 'pdl_mach_o_symbols' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_mach_o_symbols/' + source_files
            ss.vendored_library = base + 'pdl_mach_o_symbols/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_mach_object'
        end

        s.subspec 'pdl_mach_object' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_mach_object/' + source_files
            ss.vendored_library = base + 'pdl_mach_object/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_malloc' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_malloc/' + source_files
            ss.vendored_library = base + 'pdl_malloc/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_objc_message' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_objc_message/' + source_files
            ss.vendored_library = base + 'pdl_objc_message/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/PDLPrivate'
        end

        s.subspec 'pdl_objc_message_hook' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_objc_message_hook/' + source_files
            ss.vendored_library = base + 'pdl_objc_message_hook/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_asm'
            ss.dependency pod_name + '/pdl_objc_message'
            ss.dependency pod_name + '/PDLPrivate'
        end

        s.subspec 'pdl_objc_runtime' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_objc_runtime/' + source_files
            ss.vendored_library = base + 'pdl_objc_runtime/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_os' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_os/' + source_files
            ss.vendored_library = base + 'pdl_os/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_os_unfair_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_os_unfair_lock_tracer/' + source_files
            ss.vendored_library = base + 'pdl_os_unfair_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency pod_name + '/pdl_utils'
        end

        s.subspec 'pdl_pthread' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_pthread/' + source_files
            ss.vendored_library = base + 'pdl_pthread/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_mach_o_symbols'
        end

        s.subspec 'pdl_pthread_backtrace' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_pthread_backtrace/' + source_files
            ss.vendored_library = base + 'pdl_pthread_backtrace/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_backtrace'
            ss.dependency pod_name + '/pdl_thread_storage'
        end

        s.subspec 'pdl_pthread_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_pthread_lock_tracer/' + source_files
            ss.vendored_library = base + 'pdl_pthread_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency pod_name + '/pdl_utils'
        end

        s.subspec 'pdl_security' do |ss|
            ss.platform = platform_ios
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_security/' + source_files
            ss.vendored_library = base + 'pdl_security/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_systemcall'
            ss.dependency pod_name + '/pdl_die'
        end

        s.subspec 'pdl_spinlock' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_spinlock/' + source_files
            ss.vendored_library = base + 'pdl_spinlock/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_system_leak' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_system_leak/' + source_files
            ss.vendored_library = base + 'pdl_system_leak/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_thread'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'pdl_systemcall' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_systemcall/' + source_files
            ss.vendored_library = base + 'pdl_systemcall/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'pdl_thread' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_thread/' + source_files
            ss.vendored_library = base + 'pdl_thread/' + librariy_files
        end

        s.subspec 'pdl_thread_storage' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_thread_storage/' + source_files
            ss.vendored_library = base + 'pdl_thread_storage/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_utils'
        end

        s.subspec 'pdl_utils' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_utils/' + source_files
            ss.vendored_library = base + 'pdl_utils/' + librariy_files
        end

        s.subspec 'pdl_vm' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_vm/' + source_files
            ss.vendored_library = base + 'pdl_vm/' + librariy_files
        end

        s.subspec 'PDLAddressQueryViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLAddressQueryViewController/' + source_files
            ss.vendored_library = base + 'PDLAddressQueryViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'PDLApplication' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLApplication/' + source_files
            ss.vendored_library = base + 'PDLApplication/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'PDLBacktrace' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLBacktrace/' + source_files
            ss.vendored_library = base + 'PDLBacktrace/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_backtrace'
        end

        s.subspec 'PDLBacktraceRecorder' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLBacktraceRecorder/' + source_files
            ss.vendored_library = base + 'PDLBacktraceRecorder/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/PDLBacktrace'
        end

        s.subspec 'PDLBacktraceRecordsItem' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLBacktraceRecordsItem/' + source_files
            ss.vendored_library = base + 'PDLBacktraceRecordsItem/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/PDLBacktraceRecorder'
        end

        s.subspec 'PDLBlock' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLBlock/' + source_files
            ss.vendored_library = base + 'PDLBlock/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'PDLCollectionViewFlowLayout' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLCollectionViewFlowLayout/' + source_files
            ss.vendored_library = base + 'PDLCollectionViewFlowLayout/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLColor' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLColor/' + source_files
            ss.vendored_library = base + 'PDLColor/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLCrash' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLCrash/' + source_files
            ss.vendored_library = base + 'PDLCrash/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/PDLSystemImage'
        end

        s.subspec 'PDLDebug' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLDebug/' + source_files
            ss.vendored_library = base + 'PDLDebug/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_security'
            ss.dependency pod_name + '/NSObject+PDLMethod'
        end

        s.subspec 'PDLDatabase' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLDatabase/' + source_files
            ss.vendored_library = base + 'PDLDatabase/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLFileSystem' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFileSystem/' + source_files
            ss.vendored_library = base + 'PDLFileSystem/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLFileSystemViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFileSystemViewController/' + source_files
            ss.vendored_library = base + 'PDLFileSystemViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLFileSystem'
            ss.dependency pod_name + '/PDLDatabase'
            ss.dependency pod_name + '/PDLViewController'
            ss.dependency pod_name + '/PDLCrash'
            ss.dependency pod_name + '/PDLColor'
        end

        s.subspec 'PDLFontViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFontViewController/' + source_files
            ss.vendored_library = base + 'PDLFontViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'PDLFormView' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLFormView/' + source_files
            ss.vendored_library = base + 'PDLFormView/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLImageListViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLImageListViewController/' + source_files
            ss.vendored_library = base + 'PDLImageListViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'PDLInitialization' do |ss|
            ss.platform = platform_ios
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLInitialization/' + source_files
            ss.vendored_library = base + 'PDLInitialization/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLDebug'
        end

        s.subspec 'PDLKeyboardNotificationObserver' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLKeyboardNotificationObserver/' + source_files
            ss.vendored_library = base + 'PDLKeyboardNotificationObserver/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLLoad' do |ss|
            ss.platform = platform_ios
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLLoad/' + source_files
            ss.vendored_library = base + 'PDLLoad/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_objc_runtime'
        end

        s.subspec 'PDLMemoryQueryViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLMemoryQueryViewController/' + source_files
            ss.vendored_library = base + 'PDLMemoryQueryViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/pdl_malloc'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'PDLNonThreadSafePropertyObserver' do |ss|
            ss.platform = platform_ios
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLNonThreadSafePropertyObserver/' + source_files
            ss.vendored_library = base + 'PDLNonThreadSafePropertyObserver/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSObject+PDLDebug'
            ss.dependency pod_name + '/PDLPrivate'
            ss.dependency pod_name + '/PDLProcessInfo'
        end

        s.subspec 'PDLOpenUrlViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLOpenUrlViewController/' + source_files
            ss.vendored_library = base + 'PDLOpenUrlViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLKeyboardNotificationObserver'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'PDLOverlayWindow' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLOverlayWindow/' + source_files
            ss.vendored_library = base + 'PDLOverlayWindow/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLPageControl' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLPageControl/' + source_files
            ss.vendored_library = base + 'PDLPageControl/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLPageController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLPageController/' + source_files
            ss.vendored_library = base + 'PDLPageController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLFormView'
        end

        s.subspec 'PDLPageView' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLPageView/' + source_files
            ss.vendored_library = base + 'PDLPageView/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLPageController'
        end

        s.subspec 'PDLPageViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLPageViewController/' + source_files
            ss.vendored_library = base + 'PDLPageViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLPageController'
        end

        s.subspec 'PDLProcessInfo' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLProcessInfo/' + source_files
            ss.vendored_library = base + 'PDLProcessInfo/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLPrivate' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLPrivate/' + source_files
            ss.vendored_library = base + 'PDLPrivate/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLResizableImageView' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLResizableImageView/' + source_files
            ss.vendored_library = base + 'PDLResizableImageView/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLReuseItemManager' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLReuseItemManager/' + source_files
            ss.vendored_library = base + 'PDLReuseItemManager/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLRunLoopObserver' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLRunLoopObserver/' + source_files
            ss.vendored_library = base + 'PDLRunLoopObserver/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLSafeOperation' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLSafeOperation/' + source_files
            ss.vendored_library = base + 'PDLSafeOperation/' + librariy_files
            ss.requires_arc = false
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'PDLScreenDebugger' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLScreenDebugger/' + source_files
            ss.vendored_library = base + 'PDLScreenDebugger/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLScrollPageViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLScrollPageViewController/' + source_files
            ss.vendored_library = base + 'PDLScrollPageViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLReuseItemManager'
        end

        s.subspec 'PDLSessionTaskStatisticsManager' do |ss|
            ss.platform = platform_ios
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLSessionTaskStatisticsManager/' + source_files
            ss.vendored_library = base + 'PDLSessionTaskStatisticsManager/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/PDLProcessInfo'
        end

        s.subspec 'PDLSharedCache' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLSharedCache/' + source_files
            ss.vendored_library = base + 'PDLSharedCache/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.libraries = 'c++'
            ss.dependency pod_name + '/pdl_mach_object'
        end

        s.subspec 'PDLSystemImage' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLSystemImage/' + source_files
            ss.vendored_library = base + 'PDLSystemImage/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_mach_object'
        end

        s.subspec 'PDLTaskManager' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLTaskManager/' + source_files
            ss.vendored_library = base + 'PDLTaskManager/' + librariy_files
            ss.frameworks = 'Foundation'
        end

        s.subspec 'PDLViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLViewController/' + source_files
            ss.vendored_library = base + 'PDLViewController/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'PDLViewControllerListViewController' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'PDLViewControllerListViewController/' + source_files
            ss.vendored_library = base + 'PDLViewControllerListViewController/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/PDLViewController'
        end

        s.subspec 'UINavigationController+PDLLongPressPop' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UINavigationController+PDLLongPressPop/' + source_files
            ss.vendored_library = base + 'UINavigationController+PDLLongPressPop/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'UIScreen+PDLExtension' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UIScreen+PDLExtension/' + source_files
            ss.vendored_library = base + 'UIScreen+PDLExtension/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'UIView+PDLDebug' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UIView+PDLDebug/' + source_files
            ss.vendored_library = base + 'UIView+PDLDebug/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
            ss.dependency pod_name + '/NSObject+PDLExtension'
        end

        s.subspec 'UIViewController+PDLExtension' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UIViewController+PDLExtension/' + source_files
            ss.vendored_library = base + 'UIViewController+PDLExtension/' + librariy_files
            ss.frameworks = 'UIKit'
            ss.dependency pod_name + '/NSObject+PDLImplementationInterceptor'
        end

        s.subspec 'UIViewController+PDLNavigationBar' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UIViewController+PDLNavigationBar/' + source_files
            ss.vendored_library = base + 'UIViewController+PDLNavigationBar/' + librariy_files
            ss.frameworks = 'UIKit'
        end

        s.subspec 'UIViewController+PDLTransitionAnimation' do |ss|
            ss.platform = platform_ios
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'UIViewController+PDLTransitionAnimation/' + source_files
            ss.vendored_library = base + 'UIViewController+PDLTransitionAnimation/' + librariy_files
            ss.frameworks = 'UIKit'
        end
    end
end

def PoodleDynamicSpec(name, path: nil, is_library: false, base_pod_name: nil, default_subspec: nil)
    pod_name = name
    Pod::Spec.new do |s|
        s.name = pod_name

        PoodleCommonConfigurate(s)

        source_files = '**/*.{h,hpp,c,cc,cpp,m,mm,s,S,o}'
        header_files = '**/*.{h,hpp}'
        librariy_files = '**/*.{a}'

        if path == nil
            path = name
        end

        if is_library
            source_files = header_files
        end

        if default_subspec
            s.default_subspec = default_subspec
        end

        if base_pod_name == nil
            base_pod_name = name
        end

        base = path + '/'

        platform_osx = :osx, "10.10"
        platform_ios = :ios, "9.0"
        platform_universal = { :osx => "10.10", :ios => "9.0" }

        s.ios.deployment_target  = '9.0'
        s.osx.deployment_target  = '10.10'

        s.subspec 'pdl_dynamic' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_dynamic/' + source_files
            ss.vendored_library = base + 'pdl_dynamic/' + librariy_files
        end

        s.subspec 'pdl_os_unfair_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_os_unfair_lock_tracer/' + source_files
            ss.vendored_library = base + 'pdl_os_unfair_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency base_pod_name + '/pdl_utils'
        end

        s.subspec 'pdl_pthread_lock_tracer' do |ss|
            ss.platform = platform_universal
            ss.osx.deployment_target  = '10.10'
            ss.ios.deployment_target  = '9.0'
            ss.source_files = base + 'pdl_pthread_lock_tracer/' + source_files
            ss.vendored_library = base + 'pdl_pthread_lock_tracer/' + librariy_files
            ss.frameworks = 'Foundation'
            ss.dependency pod_name + '/pdl_dynamic'
            ss.dependency base_pod_name + '/pdl_utils'
        end

    end
end
