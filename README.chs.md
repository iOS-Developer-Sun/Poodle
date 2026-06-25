# Poodle

一个功能全面的 iOS/macOS 工具库，提供运行时 Hook、内存分析、系统级调试和 UI 检查等模块化工具。所有子模块均可通过 CocoaPods 独立集成。

## 环境要求

- iOS 11.0+ / macOS 11.0+
- Xcode 13+
- CocoaPods

## 安装

```ruby
# 集成单个子模块
pod 'Poodle/pdl_backtrace'
pod 'Poodle/NSObject+PDLImplementationInterceptor'

# 集成全部模块
# iOS:
pod 'Poodle/PDLToolKit_iOS'
# macOS:
pod 'Poodle/PDLToolKit_macOS'
```

---

## Foundation 扩展

### CAAnimation+PDLExtension

用 block 实现 CAAnimation 的 delegate，内部会替换原有 delegate。

### CADisplayLink+PDLExtension

用 block 创建 CADisplayLink。

### CAMediaTimingFunction+PDLExtension

公开 CAMediaTimingFunction 的私有曲率计算方法。

### NSCache+PDLExtension

NSCache 的语法糖封装。

### NSCharacterSet+PDLExtension

附加业务场景所需的字符集工具方法。

### NSData+PDLExtension

数据工具：十六进制字符串转换、MD5/CRC32 哈希、AES 加解密。

### NSDate+PDLExtension

日期格式化工具，提供可复用的 `ymdhms` 格式化器及对应字符串转换方法。

### NSDictionary+PDLObjectForKey

带类型判断的字典取值：当值类型与预期类型不符时返回 `nil`，而不是抛出异常或返回错误类型。

### NSJSONSerialization+PDLExtension

JSON 序列化与反序列化的便捷封装。

### NSLock+PDLExtension

公开 NSLock 及其子类的内部 pthread 成员。

### NSMapTable+PDLExtension

NSMapTable 的语法糖封装。

### NSMutableDictionary+PDLThreadSafety

调用 `-pdl_threadSafetify` 即可将一个 NSMutableDictionary 实例改造为线程安全版本。

### NSObject+PDLAssociation

`objc_setAssociatedObject`/`objc_getAssociatedObject` 的封装，额外支持 weak 关联（Objective-C runtime 原生不支持 weak 关联）。

### NSObject+PDLDebug

将 runtime C 接口封装为 ARC 友好的 Objective-C 接口，提供 ivar、方法、属性列表及类层级查看功能。

### NSObject+PDLDescription

为 NSObject 添加 `pdl_description` 属性，提供类型安全、不崩溃的描述字符串。

### NSObject+PDLExtension

method swizzling 工具及 ivar 字节偏移量查找。

### NSObject+PDLImplementationInterceptor

多对一的 method hook。

原理：利用 block 的跳板特性，将 Method 的 IMP 替换为 block 的 implementation 函数，block 内存储 Method 信息、目标类和自定义数据。通过汇编实现的统一入口函数交换 block 与 self 的参数位置，并调用用户自定义 hook 函数。需要使用配套宏恢复 `_cmd` 并访问局部变量。

### NSObject+PDLMethod

为一个类的所有实例方法提供调用前/后的回调。

通过 `NSObject+PDLImplementationInterceptor` 将所有方法 hook 至统一入口：入口保存寄存器组 → 调用 `beforeAction`（保存 lr）→ 恢复寄存器组 → 调用原 IMP → 保存寄存器组 → 调用 `afterAction`（取回 lr）→ 恢复寄存器组 → 返回 lr。

### NSObject+PDLSelectorProxy

通过对目标对象进行子类化并 hook 方法。**已废弃**，推荐使用 `NSObject+PDLImplementationInterceptor`。

### NSObject+PDLThreadSafetifyMethod

使一个类的所有实例方法变得线程安全（每个方法调用前后加锁）。性能影响较大，适合对无源码、调用频率很低的第三方库类进行 crash 防护。

### NSObject+PDLThreadSafetifyProperty

将指定属性的 setter/getter hook 至统一入口，入口内对 self 加递归锁，无需自定义实现即可使属性线程安全。

### NSObject+PDLWeakifyUnsafeUnretainedProperty

将 `unsafe_unretained` 属性改造为 `weak` 属性。

原理：将 setter/getter 重定向至 `storeWeak`/`loadWeak`，并添加一个关联对象在 dealloc 时执行 `destroyWeak`。因完全重写读写操作，仅适用于没有自定义 setter/getter 实现的属性。

### NSString+PDLExtension

字符串工具：去空白字符串（`pdl_trimmedString`）和纯文本提取（`pdl_plainText`）。

### NSThread+PDLExtension

公开 NSThread 的私有成员。

### NSUserDefaults+PDLExtension

NSUserDefaults 的语法糖封装。

---

## 底层系统模块（`pdl_*`）

### pdl_allocation

类似 Malloc Stack Logging，对所有 Objective-C 对象的分配进行 live/free 追踪记录。

### pdl_asm

C 环境下的汇编宏：NOP、无条件跳转（`GOTO`）、指令重复。可用于禁止编译器优化、编写 naked 函数和汇编学习。

### pdl_backtrace

封装 `pdl_thread`，提供线程调用栈的记录、展示，以及以指定栈帧信息执行函数等功能。

### pdl_block

公开 Clang rewrite 后的 block 内部结构体（`Block_layout`），包括 invoke 指针、descriptor 和捕获变量。

### pdl_die

清空所有 CPU 寄存器并以传入参数触发 crash，设计用于无法被拦截的安全硬终止路径。

### pdl_dispatch

提供带 identifier 记录的 GCD queue 创建函数，以及当前 queue 获取、queue 宽度查询功能。

### pdl_dispatch_backtrace

基于 `pdl_backtrace`，跨越 `dispatch_async` 和 `dispatch_after` 边界追溯调用栈。

### pdl_dynamic

提供 `PDL_DYLD_INTERPOSE` 宏——通过 `__DATA,__interpose` section 在编译期替换 C 函数符号，是 fishhook 的编译时替代方案。

### pdl_hook

对指定 image 的外部函数做运行时 hook。

类似 fishhook 的动态版，但仅替换 lazy symbol（不注册 observer），复现 `dyld_stub_binder` 的动作，完成一次性符号替换。

### pdl_lldb_hook

基于指令替换的 LLDB hook 工具，不受符号类型限制，仅受指令类型限制，**仅支持 ARM64**。

原理：完成一次 `void *` 跳转需要 5（或 4）条指令，前几条用立即数拼出目标地址，最后一条 `br` 执行跳转。LLDB 对代码段有写权限，因此可以将符合条件的函数头部指令替换为跳转到入口函数（入口函数预留 5 条 NOP 用于被替换），再跳转到用户自定义函数。

### pdl_mach

获取当前进程的所有 Mach 线程列表。

### pdl_mach_o_const_symbols

公开系统 image 中 stub 和 section 类型的 symbol，为其他 Poodle 组件提供底层支持。

### pdl_mach_o_symbol_pointer

查找指定名称 symbol 的文件偏移量：先在已加载的 image 中查找，再从 `dyld_shared_cache` 中查找。

### pdl_mach_o_symbols

Mach-O symbol table 相关工具：解析、遍历和查询符号。

### pdl_mach_object

Mach-O 文件解析工具：segments、sections、load commands 及其内容。

### pdl_malloc

查询指定堆地址的 malloc block header 地址和分配大小。

### pdl_objc_message

提供带 `beforeAction`/`afterAction` 回调行为的 `objc_msgSend` 类函数。

### pdl_objc_message_hook

封装 `pdl_objc_message_hook` 内部实现，以头文件形式对外暴露动态库中 `objc_msgSend` 的 hook 接口。

### pdl_objc_runtime

通过扫描已加载 image 获取 Objective-C category 信息。

### pdl_os

查看 `os_unfair_lock_t` 的持锁线程（包含 iOS 10 及以后的 `objc_sync_lock`）。

原理：通过 `__unlock_wait` 系统调用，在 `_os_unfair_lock_lock_slow` 的栈帧中通过寄存器找到锁结构体指针，读取持有者 mach thread id。

LLDB 调试用法：
```
(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$x21)   // arm64
(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$r12)   // x86_64
```

### pdl_os_unfair_lock_tracer

记录并日志输出 `os_unfair_lock` 的加锁/解锁事件，支持按需打印当前锁持有情况映射。

### pdl_pac

ARM64e 指针认证码（PAC）工具：对函数指针和数据指针进行 strip、sign 和 authenticate 操作。

### pdl_pthread

查看 `pthread_mutex_t` 和 `pthread_rwlock_t` 的持锁线程。

- **pthread_mutex_t**（包含 iOS 10 以前的 `objc_sync_lock`）：通过 `__psynch_mutexwait` 系统调用，在 `_pthread_mutex_lock_wait` 栈帧中找到锁结构体指针，读取线程 pid。
- **pthread_rwlock_t**（只能查写者，读者无法获取）：通过 `__psynch_rw_wrlock` 系统调用，在 `_pthread_rwlock_lock_wait` 栈帧中找到锁结构体指针。

LLDB 调试用法：
```
(lldb) p pdl_pthread_mutex_locked_tid((pthread_mutex_t *)$x20)    // arm64
(lldb) p pdl_pthread_mutex_locked_tid((pthread_mutex_t *)$r14)    // x86_64

(lldb) p pdl_pthread_rwlock_locked_tid((pthread_rwlock_t *)$x19)  // arm64，仅写者
(lldb) p pdl_pthread_rwlock_locked_tid((pthread_rwlock_t *)$r14)  // x86_64，仅写者

(lldb) p pdl_pthread_rwlock_lockers((pthread_rwlock_t *)$x19)     // 锁相关线程数
```

### pdl_pthread_backtrace

基于 `pdl_backtrace`，跨越 `pthread_create` 边界追溯调用栈。

### pdl_pthread_lock_tracer

记录并日志输出 pthread 读写锁的加锁/解锁事件，支持按需打印当前锁映射。

### pdl_security

反调试支持及当前调试器附加状态检测。基于 `pdl_systemcall` 和 `pdl_die` 实现，攻击者难以拦截。

### pdl_spinlock

基于原子操作封装的自旋锁。

### pdl_swift

Hook Swift 运行时内部接口：对象分配、独占访问（exclusive access）的 begin/end，以及 Dictionary 的 getter/setter。提供 `pdl_swift_validate_object` 用于校验一个地址是否为合法的 Swift 对象。

### pdl_system_leak

检测已知系统内存泄漏——`CNCopyCurrentNetworkInfo` 和 `NEHotspotNetwork` 的泄漏问题。依赖对 `calloc` 和 `CNCopyCurrentNetworkInfo` 的 hook，仅在 Debug 模式下使用。

### pdl_systemcall

通过内联汇编直接发起 syscall，无法被用户态 hook 拦截。

### pdl_thread

封装编译器 builtin 函数，获取任意调用层级的 `fp`（帧指针）和 `lr`（链接寄存器），并支持以指定栈帧信息执行指定函数。

### pdl_thread_storage

线程本地存储（TLS/TSD），使用单个 `pthread_key_t` 配合 C 字典实现多 key 支持。

### pdl_trampoline

为任意函数包装 before/after 回调，将原函数指针、栈指针和用户数据传递给各回调。

### pdl_utils

C 语言实现的基础数据结构：字典、数组、链表。

### pdl_vm

查询指定内存地址的读/写/执行权限，并提供安全写入指定地址的功能（内部处理页保护）。

### pdl_zombie

Zombie 对象支持：在 `-dealloc` 后延迟实际释放一段可配置的时间，使 use-after-free 崩溃能显示对象的原始类型。

---

## 调试 UI 工具

### PDLAddressQueryViewController

基于 `dladdr` 的地址查询界面：输入十六进制地址，显示对应的符号名和所属 image。

### PDLFileSystemViewController

应用内文件系统浏览器：浏览目录、查看文件内容、打开 SQLite 数据库、查看 crash 日志。

### PDLFontViewController

按字体家族分组显示设备上所有可用字体。

### PDLImageListViewController

运行时列出所有已加载 Mach-O image、Objective-C 类和 protocol。

### PDLMemoryQueryViewController

交互式界面，用于执行 Objective-C 方法调用并查看返回值。

### PDLOpenUrlViewController

在 App 内触发 `openURL:` 调用的 UI 工具。

### PDLScreenDebugger

视图和图层的可视化调试覆盖层，可实时修改 frame、hidden、alpha/opacity、backgroundColor 等属性，无需重新编译。

### PDLViewControllerListViewController

列出运行中 App 内所有存活的 `UIViewController` 实例。

---

## 工具类

### PDLApplication

扩展 UIApplication 能力：优雅退出、摇一摇触发、屏幕点击反馈覆盖层、open URL 后门、安全模式。

### PDLBacktrace

`pdl_backtrace` 的 Objective-C 封装。

### PDLBacktraceRecorder

以约 60Hz 的频率对所有线程进行调用栈采样，使用 `thread_suspend`/`thread_resume` 实现。

### PDLBacktraceRecordsItem

对 `PDLBacktraceRecorder` 的采样结果进行后处理和聚合。

### PDLBlock

检测哪些 block 持有了指定类的对象。

原理：hook 所有 image 中 block 的 copy 函数并记录 TLS 状态，同时 hook 目标类的 `retain` 方法，判断是否在 block copy 过程中触发，用于循环引用检查。

### PDLCollectionViewFlowLayout

`UICollectionViewFlowLayout` 子类，支持以指定对齐方式布局 cell。

### PDLColor

支持 Dark Mode 的工具颜色及随机颜色生成。

### PDLCrash

应用内 crash 日志解析器：读取 crash 文件，根据 bundle id、image UUID、`dyld_shared_cache` 等信息自动符号化地址。封装了 `dladdr`。

### PDLDatabase

FMDB 的 Objective-C 方法封装，提供 SQLite 访问接口。

### PDLDeadLockObserver

通过观察锁获取顺序检测疑似死锁，支持实时监控和按需检查。

### PDLDebug

若干调试辅助函数。

### PDLDSym

生成 dSYM 风格符号文件：按偏移量添加函数符号和变量符号，然后 dump 到指定路径。

### PDLFileSystem

文件系统工具方法。

### PDLFormView

类 Excel 表格视图，支持单元格合并。

### PDLGeometry

UIView 的 frame 便捷属性（`pdl_left`、`pdl_right`、`pdl_top`、`pdl_bottom`、`pdl_width`、`pdl_height`、`pdl_origin`、`pdl_size`、`pdl_centerX`、`pdl_centerY`），以及像素对齐取整工具函数。

### PDLInitialization

启动耗时分析工具：hook 类的 `+load` 方法和 C initializer，统计并上报每项的执行时长。

### PDLKeyboardNotificationObserver

键盘显示/隐藏/变化通知的 block 回调封装。

### PDLLoad

禁止指定 category 的 `+load` 方法执行。

### PDLMachObject

`pdl_mach_object` 的 Objective-C 封装，支持解析 Swift 方法类型（method、init、getter、setter、modify coroutine、read coroutine、access）。

### PDLMemoryTracer

对象级内存事件追踪：对任意类或特定实例 hook `alloc`、`retain`、`release`、`autorelease`、`dealloc`，支持按对象开关日志。

### PDLNonThreadSafeObserver

非线程安全访问的动态检测工具。

hook 属性的 setter/getter，记录线程、队列、时间戳和读写方向，随后分析记录以识别竞争条件。支持 Objective-C 属性、NSArray/NSDictionary cluster 以及 Swift 对象/变量的检测。

### PDLOpenUrlViewController

应用内触发 `openURL:` 的 UI 工具。

### PDLOverlayWindow

基于私有 UIKit API 实现的悬浮窗。

### PDLPageControl

支持 Auto Layout 的自定义 `UIPageControl`。

### PDLPageController / PDLPageView / PDLPageViewController / PDLScrollPageViewController

翻页导航组件，功能类似 `UIPageViewController`。`PDLPageController` 封装 `PDLFormView`，为 `PDLPageView` 和 `PDLPageViewController` 提供基础支持。

### PDLPrivate

公开系统调试方法和编译器内部函数：description、引用计数、autorelease pool、ARC retain/release/autorelease、property 和 super 的编译器派发实现。

### PDLProcessInfo

获取 App 相对进程启动的绝对启动时间。

### PDLPudding

JSPatch 封装，带符号隐藏。

### PDLResizableImageView

田字四区域（3×3 分区）缩放的图片视图，等价于 `resizableImageWithCapInsets:`。

### PDLReuseItemManager

通用对象重用池，类似 UITableView 的 cell 重用队列。

### PDLRunLoopObserver

RunLoop 状态变化监听器。

### PDLSafeOperation

NSArray 和 NSDictionary 的崩溃防护：hook 工厂方法及所有子类的读取方法，进行越界和非空判断，不抛出异常。

### PDLSessionTaskStatisticsManager

运行时追踪 NSURLSession 任务指标：请求数量、耗时和错误信息。

### PDLSharedCache

在 iOS 系统上解析 `dyld_shared_cache`，支持按地址提取和查找符号。

### PDLSwiftModule

为其他 Poodle 组件提供 Swift 互操作桥接支持。

### PDLSystemImage

`pdl_mach_object` 的 Objective-C 封装，附带 image 加载事件 observer。

### PDLTaskManager

通用任务/操作调度管理器。

### PDLViewController

Poodle 调试 UI 的基础 `UIViewController`。

### UINavigationController+PDLLongPressPop

为导航栏返回按钮添加长按手势，支持一次性 pop 到任意祖先控制器。

### UIScreen+PDLExtension

无论当前设备方向如何，始终返回竖屏尺寸。

### UIView+PDLDebug

支持 `colorViewBounds`（彩色边框布局调试）和 `alignmentRects` 可视化，不抛出异常。

### UIViewController+PDLExtension

无侵入的生命周期回调：无需子类化即可监听 `viewDidLoad`、`viewWillAppear` 等事件。

### UIViewController+PDLNavigationBar

左右导航栏按钮的便捷设置接口。

### UIViewController+PDLTransitionAnimation

自定义转场动画的便捷配置接口。

---

## License

MIT
