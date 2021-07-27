# Poodle

## CAAnimation+PDLExtension

block实现delegate，delegate会被更改

## CADisplayLink+PDLExtension

block实现

## CAMediaTimingFunction+PDLExtension

公开私有方法，计算曲率

## NSCache+PDLExtension

语法糖

##  NSCharacterSet+PDLExtension

附加业务

## NSDictionary+PDLObjectForKey

带类型判断的dictionary取值

##  NSJSONSerialization+PDLExtension

json转换

## NSLock+PDLExtension

NSLock及其子类的pthread成员公开

## NSMapTable+PDLExtension

语法糖

## NSObject+PDLAssociation

objcAssociation的封装和weak实现

## NSObject+PDLDebug

封装runtime的c接口，提供arc下的内存接口

## NSObject+PDLExtension

method swizzling，ivar偏移量获取

## NSObject+PDLImplementationInterceptor

多对一的method hook

利用block的跳板特性，将Method的IMP换成block的implementation，block中存储Method信息、类和自定义信息，编译后的block函数第一个参数是block，第二个参数是self，将block的实现改成汇编实现的总入口，该总入口函数会将block和self参数互换位置，并调用自定义hook函数，自定义函数需要使用宏来恢复_cmd以及提供其他局部变量

## NSObject+PDLMethod

为一个类的所有实例方法提供方法调用前后的回调

使用NSObject+PDLImplementationInterceptor将所有方法hook为统一入口，该入口保存寄存器组、调用beforeAction保存原跳转地址（lr）、恢复寄存器组、调用原有IMP，保存寄存器组、调用afterAction得到原跳转地址（lr）、恢复寄存器组、返回lr

## NSObject+PDLSelectorProxy

子类化一个对象并进行method的hook，不建议使用

## NSObject+PDLThreadSafetifyMethod

使一个类的所有实例方法变得线程安全

封装NSObject+PDLMethod，在前后回调中加锁，性能影响比较大，适合第三方库无源码使用频率很低的类的crash防护

## NSObject+PDLThreadSafetifyProperty

hook一个属性的setter/getter到总setter/getter入口，入口内根据self进行加递归锁操作，使属性线程安全

## NSObject+PDLWeakifyUnsafeUnretainedProperty

使一个unsafe_unretained属性变成weak

hook该属性的setter/getter到总setter/getter入口，getter入口内调用loadWeak取值，setter入口内调用storeWeak存值并添加一个关联对象做destroyWeak操作。因为操作完全重写，所以仅适用于没有自定义实现的属性。

## NSThread+PDLExtension

私用成员公开

## NSUserDefaults+PDLExtension

语法糖

## pdl_allocation

像Malloc stack logging一样，提供对象的的live、free信息

## pdl_asm

提供c环境下的汇编宏，目前提供nop和函数跳转操作，用于禁止编译优化、汇编学习和naked函数编写等

## pdl_backtrace

封装pdl_thread提供线程调用栈的记录、展示、以指定栈信息执行等功能

## pdl_block

提供rewrite后的block结构体信息

## pdl_die

清空所有寄存器数据并以传入参数崩溃的函数

## pdl_dispatch

提供create函数，做identifier记录并实现当前queue获取、queue宽度获取功能

## pdl_dispatch_backtrace

基于pdl_backtrace，追溯dispatch_async和dispatch_after

## pdl_hook

对一个image的external函数做hook

插桩的动态版，类似于fishhook但不做observer且只替换lazy_symbol，做dyld_stub_binder的动作

## pdl_lldb_hook

基于指令替换的lldb函数hook工具，不受符号类型限制，只受指令类型限制，仅支持arm64

完成一个void *类型的跳转，需要5（4）条指令，前4（3）条使用立即数拼void *数据，最后一条br指令做跳转，lldb对代码区有写权限，所以可以更改指令，替换掉符合指令类型的函数指令，跳转到指定入口函数，入口函数保留有5条nop指令用于被替换，然后跳转到指定自定义函数

## pdl_mach

获取所有mach线程

## pdl_mach_o_const_symbols

公开系统image的stub和sect类型的symbol，为其他组件提供支持

## pdl_mach_o_symbol_pointer

提供指定名称的symbol偏移量，先在加载的image中查找，然后在dyld_shared_cache中查找

## pdl_mach_o_symbols

mach-o symbol相关工具

## pdl_mach_object

mach-o文件解析工具

## pdl_malloc

查询指定地址的堆内存header地址、分配大小信息的功能

## pdl_objc_message

提供带beforeAction和afterAction行为的objc_message类函数

## pdl_objc_message_hook

封装pdl_objc_message_hook，提供动态库的函数头文件

## pdl_objc_runtime

查看image获取category信息

## pdl_os

查看os_unfair_lock_t的持锁线程

### os_unfair_lock锁，包含iOS 10以后的objc_sync_lock

__unlock_wait的系统调用，查看_os_unfair_lock_lock_slow的frame，寄存器查找os_unfair_lock锁结构体指针

(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$r12) // x86_64

(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$x21) // arm64

得到mach线程id

## pdl_pthread

查看pthread的持锁线程

### pthread_mutex_t锁，包含iOS 10以前的objc_sync_lock

__psynch_mutexwait的系统调用，查看_pthread_mutex_lock_wait的frame，寄存器查找pthread_mutex_t锁结构体指针

(lldb) p pdl_pthread_mutex_locked_tid((pthread_mutex_t *)$r14) // x86_64

(lldb) p pdl_pthread_mutex_locked_tid((pthread_mutex_t *)$x20) // arm64

得到线程pid

### pthread_rwlock_t锁，只能查看写者，读者无法获取

__psynch_rw_wrlock的系统调用，查看_pthread_rwlock_lock_wait的frame，寄存器查找pthread_rwlock_t锁结构体指针

(lldb) p pdl_pthread_rwlock_locked_tid((pthread_rwlock_t *)$r14) // x86_64

(lldb) p pdl_pthread_rwlock_locked_tid((pthread_rwlock_t *)$x19) // arm64

得到线程pid

(lldb) p pdl_pthread_rwlock_lockers((pthread_rwlock_t *)$r14) // x86_64

(lldb) p pdl_pthread_rwlock_lockers((pthread_rwlock_t *)$x19) // arm64

锁相关的线程数

## pdl_pthread_backtrace

基于pdl_backtrace，追溯pthread_create

## pdl_security

反调试和获取当前是否调试

基于pdl_systemcall和pdl_die，黑客不容易拦截

## pdl_spinlock

封装原子操作的自旋锁，并不快

## pdl_system_leak

CNCopyCurrentNetworkInfo和NEHotspotNetwork的内存泄漏，依赖于calloc和CNCopyCurrentNetworkInfo的hook，debug模式使用

## pdl_systemcall

内部指令实现syscall，无法拦截

## pdl_thread

封装builtin函数，获取不同层级的fp、lr，提供以指定函数栈信息执行

## pdl_thread_storage

tls（thread local storage）/tsd（thread specific data）

使用一个pthread_key_t和c字典实现

## pdl_utils

c字典数组链表数据结构

## pdl_vm

获取指定地址的读写执行权限、安全方式写入指定地址

## pdl_zombie

zombie支持

## PDLAddressQueryViewController

封装dladdr，提供地址查询功能

## PDLApplication

封装UIApplication方法，提供优雅退出方法，注册摇一摇功能，屏幕点击反馈功能，open URL后门，安全模式

## PDLBacktrace

pdl_backtrace的oc封装

## PDLBacktraceRecorder

记录线程栈

运用thread_suspend和thread_resume以60Hz的频率对线程进行线程栈采样

## PDLBacktraceRecordsItem

PDLBacktraceRecord的结果处理

## PDLBlock

提供block引用指定类的对象的工具，用于循环引用检查

hook image的所有block的copy函数，对当前copy操作进行记录（tls），hook指定类的retain，查看是否在调用block的copy

## PDLCollectionViewFlowLayout

以某种对齐方式对UICollectionView的cell布局

## PDLColor

支持Dark模式的工具颜色、随机颜色

## PDLCrash

app内crash解析

解析crash文件，根据bundle id、image的uuid、dyld_shared_cache等信息，自动解析crash文件

封装的dladdr

## PDLDatabase

fmdb的oc方法

## PDLDebug

一些调试函数

## PDLFileSystem

文件系统的工具方法

## PDLFileSystemViewController

文件系统查看和文件打开工具

## PDLFontViewController

字体列表视图

## PDLFormView

excel表格，支持合并单元格功能

## PDLImageListViewController

image列表视图控制器，查看class、protocol列表

## PDLInitialization

启动分析工具，查看load和initializer的时长

通过hook类的load方法和c initializer，对启动耗时进行统计

## PDLKeyboardNotificationObserver

键盘事件监听封装

## PDLLoad

禁止指定categroy的load方法

## PDLMemoryQueryViewController

UI方式的方法执行工具

## PDLNonThreadSafePropertyObserver

多线程不安全属性的动态检查工具

对nonatomic strong/copy类型的property进行hook并做记录，记录线程/队列、时间、setter/getter、是否初始化等信息，随后并对记录做分析

## PDLOpenUrlViewController

openURL的UI工具

## PDLOverlayWindow

实现私有API的window，用于悬浮窗

## PDLPageControl

自定义的PageControl，支持autolayout

## PDLPageController

封装PDLFormView，为PDLPageView和PDLPageViewController提供基础组件

## PDLPageView

翻页视图

## PDLPageViewController

翻页视图控制器

## PDLPrivate

公开系统调试方法和编译函数

包含description方法、引用计数、自动释放池、strong/weak编译、property编译、super编译等函数

## PDLProcessInfo

App启动时间

## PDLPudding

jspatch的封装，符号隐藏

## PDLResizableImageView

田字四区域缩放的图片视图

## PDLReuseItemManager

重用存储组件

## PDLRunLoopObserver

runloop的状态变化监听器

## PDLSafeOperation

NSArray和NSDictionary的安全防护

hook语法糖的类方法和所有子类的读取方法，并进行越界/非空判断

## PDLScreenDebugger

视图和图层调试工具，可视化修改frame、hidden、alpha/opacity、backgroundColor等属性

## PDLScrollPageViewController

类似于UIPageViewController的视图控制器

## PDLSessionTaskStatisticsManager

网络请求统计

## PDLSharedCache

dyld_shared_cache在iOS系统中解压，并根据地址查找符号

## PDLSystemImage

封装pdl_mach_object，并提供image工具

增加observer

## PDLTaskManager

task工具

## PDLViewController

工具视图控制器基类

## PDLViewControllerListViewController

视图控制器列表视图控制器

## UINavigationController+PDLLongPressPop

UINavigationController长按返回支持

## UIScreen+PDLExtension

竖屏大小

## UIView+PDLDebug

ColorViewBounds和AlignmentRects支持

不抛异常

## UIViewController+PDLExtension

无侵入生命周期回调

## UIViewController+PDLNavigationBar

按钮便捷接口

## UIViewController+PDLTransitionAnimation

转场动画便捷接口
