# Poodle

A comprehensive iOS/macOS utility library providing modular tools for runtime hooking, memory profiling, system-level debugging, and UI inspection. Any submodule can be integrated independently via CocoaPods.

## Requirements

- iOS 11.0+ / macOS 11.0+
- Xcode 13+
- CocoaPods

## Installation

```ruby
# Single submodule
pod 'Poodle/pdl_backtrace'
pod 'Poodle/NSObject+PDLImplementationInterceptor'

# All modules
# iOS:
pod 'Poodle/PDLToolKit_iOS'
# macOS:
pod 'Poodle/PDLToolKit_macOS'
```

## Modules

### Foundation Extensions

**CAAnimation+PDLExtension**
Block-based delegate implementation for `CAAnimation`. The delegate property is replaced internally.

**CADisplayLink+PDLExtension**
Block-based `CADisplayLink` creation.

**CAMediaTimingFunction+PDLExtension**
Exposes private curvature calculation methods on `CAMediaTimingFunction`.

**NSCache+PDLExtension**
Convenience syntax for `NSCache`.

**NSCharacterSet+PDLExtension**
Additional character set utilities.

**NSData+PDLExtension**
Data utilities: hex string conversion, MD5/CRC32 hashing, and AES encryption/decryption.

**NSDate+PDLExtension**
Date formatting helpers including a reusable `ymdhms` date formatter.

**NSDictionary+PDLObjectForKey**
Type-checked dictionary access — returns `nil` instead of crashing when the value type does not match the expected class.

**NSJSONSerialization+PDLExtension**
Convenience wrappers for JSON serialization and deserialization.

**NSLock+PDLExtension**
Exposes the underlying `pthread` member of `NSLock` and its subclasses.

**NSMapTable+PDLExtension**
Convenience syntax for `NSMapTable`.

**NSMutableDictionary+PDLThreadSafety**
Makes an `NSMutableDictionary` instance thread-safe on demand via `-pdl_threadSafetify`.

**NSObject+PDLAssociation**
Wrapper for associated objects with support for weak associations (not natively provided by the Objective-C runtime).

**NSObject+PDLDebug**
Wraps runtime C APIs for ARC-compatible introspection: ivars, methods, properties, and class hierarchy.

**NSObject+PDLDescription**
Adds a `pdl_description` property that returns a type-safe, non-crashing description string.

**NSObject+PDLExtension**
Method swizzling utilities and ivar byte-offset lookup.

**NSObject+PDLImplementationInterceptor**
Many-to-one method hook. Replaces a method's IMP with a block's implementation function, injects an assembly entry point that swaps block/self argument order, and dispatches to a user-supplied hook. Macros are provided to restore `_cmd` and access local variables.

**NSObject+PDLMethod**
Installs before/after callbacks on every instance method of a class. The shared entry point saves all registers, calls `beforeAction` (preserving `lr`), restores registers, invokes the original IMP, then calls `afterAction` to retrieve the return address.

**NSObject+PDLSelectorProxy**
Hooks methods by subclassing the target object at runtime. Deprecated — prefer `NSObject+PDLImplementationInterceptor`.

**NSObject+PDLThreadSafetifyMethod**
Wraps every instance method of a class with a lock. High performance overhead; best suited for protecting rarely-called third-party classes where source is unavailable.

**NSObject+PDLThreadSafetifyProperty**
Hooks a property's setter and getter through a shared entry point that applies a per-instance recursive lock, making the property thread-safe without a custom implementation.

**NSObject+PDLWeakifyUnsafeUnretainedProperty**
Converts an `unsafe_unretained` property to a `weak` one. Redirects setter/getter to `storeWeak`/`loadWeak` and adds an associated object to call `destroyWeak` on dealloc. Works only on properties with no custom accessor implementation.

**NSString+PDLExtension**
String utilities: trimmed string and plain-text extraction.

**NSThread+PDLExtension**
Exposes private `NSThread` members.

**NSUserDefaults+PDLExtension**
Convenience syntax for `NSUserDefaults`.

---

### Low-Level System (`pdl_*`)

**pdl_allocation**
Per-object allocation tracker similar to Malloc Stack Logging. Records live and free events for every Objective-C object.

**pdl_asm**
Assembly macros for C/Objective-C: NOP, unconditional branch (`GOTO`), and instruction repetition. Useful for disabling compiler optimizations, writing naked functions, and assembly experimentation.

**pdl_backtrace**
Thread call-stack capture, display, and execution-with-given-stack-frame. Built on `pdl_thread`.

**pdl_block**
Exposes the internal Clang-rewritten block structure (`Block_layout`): invoke pointer, descriptor, and captured variables.

**pdl_die**
Clears all CPU registers and crashes with a caller-supplied value — intended for security-hardened abort paths that cannot be intercepted.

**pdl_dispatch**
Creates GCD queues with identifier tracking and exposes APIs to query the current queue and queue width.

**pdl_dispatch_backtrace**
Traces call stacks across `dispatch_async` and `dispatch_after` boundaries. Built on `pdl_backtrace`.

**pdl_dynamic**
Provides the `PDL_DYLD_INTERPOSE` macro — a compile-time alternative to fishhook for replacing C symbols via the `__DATA,__interpose` section.

**pdl_hook**
Runtime hook for external functions in a Mach-O image. Like fishhook but targets only lazy symbols and performs a one-time replacement (no observer). Replicates `dyld_stub_binder` behavior.

**pdl_lldb_hook**
Instruction-replacement hook for LLDB. Overwrites up to 5 ARM64 instructions in the code segment with a branch to an entry stub that contains 5 NOP slots, then jumps to the user function. Not restricted by symbol type; ARM64 only.

**pdl_mach**
Enumerates all Mach threads in the current process.

**pdl_mach_o_const_symbols**
Exposes stub and section symbols from system images for use by other Poodle components.

**pdl_mach_o_symbol_pointer**
Resolves the file offset of a named symbol — searches loaded images first, then falls back to `dyld_shared_cache`.

**pdl_mach_o_symbols**
Mach-O symbol table utilities: parse, iterate, and query symbols.

**pdl_mach_object**
Mach-O binary parser: segments, sections, load commands, and their contents.

**pdl_malloc**
Given a heap address, returns the malloc block header address and allocated size.

**pdl_objc_message**
Provides `objc_msgSend`-style functions that invoke before/after actions around message dispatch.

**pdl_objc_message_hook**
Header-only API for hooking `objc_msgSend` in a dynamic library, wrapping the internal `pdl_objc_message_hook` implementation.

**pdl_objc_runtime**
Queries loaded images for Objective-C category information.

**pdl_os**
Identifies the owning thread of an `os_unfair_lock_t`. LLDB usage:
```
(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$x21)   // arm64
(lldb) p pdl_os_unfair_lock_owner((os_unfair_lock_t)$r12)   // x86_64
```

**pdl_os_unfair_lock_tracer**
Records and logs `os_unfair_lock` acquisition/release events; prints the current lock ownership map on demand.

**pdl_pac**
Pointer Authentication Code (PAC) helpers for ARM64e: strip, sign, and authenticate function and data pointers.

**pdl_pthread**
Identifies the owning thread of `pthread_mutex_t` and `pthread_rwlock_t` locks. LLDB usage:
```
(lldb) p pdl_pthread_mutex_locked_tid((pthread_mutex_t *)$x20)    // arm64
(lldb) p pdl_pthread_rwlock_locked_tid((pthread_rwlock_t *)$x19)  // arm64, writers only
(lldb) p pdl_pthread_rwlock_lockers((pthread_rwlock_t *)$x19)     // lock-related thread count
```

**pdl_pthread_backtrace**
Traces call stacks across `pthread_create` boundaries. Built on `pdl_backtrace`.

**pdl_pthread_lock_tracer**
Records and logs pthread read-write lock acquisition/release events; prints the current lock map on demand.

**pdl_security**
Anti-debugging support and detection of whether a debugger is attached. Built on `pdl_systemcall` and `pdl_die` to resist interception.

**pdl_spinlock**
Spinlock implemented with atomic operations.

**pdl_swift**
Hooks Swift runtime internals: allocation, exclusive-access begin/end, and Dictionary getter/setter. Provides `pdl_swift_validate_object` to check whether an address is a valid Swift object.

**pdl_system_leak**
Detects known system memory leaks in `CNCopyCurrentNetworkInfo` and `NEHotspotNetwork`. Requires hooking `calloc` and `CNCopyCurrentNetworkInfo`. Debug builds only.

**pdl_systemcall**
Issues raw syscalls via inline assembly, bypassing any user-space hooks.

**pdl_thread**
Reads frame pointer (`fp`) and link register (`lr`) at arbitrary call-stack depths using compiler builtins. Also supports executing a function with a given stack frame context.

**pdl_thread_storage**
Thread-local storage (TLS/TSD) implemented with a single `pthread_key_t` and a C dictionary.

**pdl_trampoline**
Wraps any function with before/after callbacks, passing the original function pointer, stack pointer, and caller data to each callback.

**pdl_utils**
Minimal C data structures: dictionary, array, and linked list.

**pdl_vm**
Queries read/write/execute permissions for a memory address and provides a safe write to arbitrary memory locations (handles page protection internally).

**pdl_zombie**
Deferred-deallocation zombie support. Delays actual deallocation for a configurable duration after `-dealloc`, so use-after-free crashes report the object's original type.

---

### Debugging UI

**PDLAddressQueryViewController**
Address lookup UI backed by `dladdr` — enter a hex address, see the symbol name and image.

**PDLFileSystemViewController**
In-app file system browser: navigate directories, view file contents, open SQLite databases, and read crash logs.

**PDLFontViewController**
Lists all fonts available on the device, grouped by family.

**PDLImageListViewController**
Lists all loaded Mach-O images, Objective-C classes, and protocols at runtime.

**PDLMemoryQueryViewController**
Interactive UI for executing Objective-C methods and inspecting return values.

**PDLOpenUrlViewController**
UI tool for triggering `openURL:` calls from within the app.

**PDLScreenDebugger**
Visual overlay for inspecting and live-editing view/layer properties — frame, hidden, alpha/opacity, backgroundColor — without rebuilding.

**PDLViewControllerListViewController**
Lists all live `UIViewController` instances in the running app.

---

### Utility Classes

**PDLApplication**
Extends `UIApplication`: graceful exit, shake-to-trigger actions, tap-feedback overlay, open-URL backdoor, and safe mode.

**PDLBacktrace**
Objective-C wrapper around `pdl_backtrace`.

**PDLBacktraceRecorder**
Samples call stacks of all threads at ~60 Hz using `thread_suspend`/`thread_resume`.

**PDLBacktraceRecordsItem**
Post-processes and aggregates `PDLBacktraceRecorder` results.

**PDLBlock**
Detects which blocks retain instances of a given class. Hooks all block copy functions to record TLS context, then hooks `retain` on the target class to detect retention inside block copies — useful for tracking retain cycles.

**PDLCollectionViewFlowLayout**
`UICollectionViewFlowLayout` subclass that aligns cells using a configurable alignment mode.

**PDLColor**
Utility colors with Dark Mode support and random color generation.

**PDLCrash**
In-app crash log parser: reads a crash file, matches against bundle identifier, image UUIDs, and `dyld_shared_cache`, and symbolizes addresses automatically.

**PDLDatabase**
Objective-C wrappers around FMDB for SQLite access.

**PDLDeadLockObserver**
Detects suspicious deadlock conditions by observing lock acquisition order. Supports real-time monitoring and on-demand checking.

**PDLDebug**
Miscellaneous debugging utility functions.

**PDLDSym**
Generates dSYM-style symbol files: add function and variable symbols with offsets, then dump to a file path.

**PDLFileSystem**
File system utility methods.

**PDLFormView**
Spreadsheet-style grid view with merged-cell support.

**PDLGeometry**
Convenience frame properties on `UIView` (`pdl_left`, `pdl_right`, `pdl_top`, `pdl_bottom`, `pdl_width`, `pdl_height`, `pdl_origin`, `pdl_size`, `pdl_centerX`, `pdl_centerY`) plus pixel-aligned rounding helpers.

**PDLInitialization**
Startup time analyzer: hooks `+load` and C initializers to measure and report time spent in each.

**PDLKeyboardNotificationObserver**
Keyboard show/hide/change notification observer with a block-based callback API.

**PDLLoad**
Disables `+load` on specified categories.

**PDLMachObject**
Objective-C wrapper around `pdl_mach_object` with support for parsing Swift method kinds (method, init, getter, setter, modify/read coroutine, access).

**PDLMemoryTracer**
Per-object memory event tracing: hook `alloc`, `retain`, `release`, `autorelease`, and `dealloc` on any class or specific instance, with optional per-object logging.

**PDLNonThreadSafeObserver**
Dynamically detects unsafe concurrent access. Hooks setter/getter pairs to record thread, queue, timestamp, and direction, then analyzes records to identify races. Covers Objective-C properties, NSArray/NSDictionary clusters, and Swift objects/variables.

**PDLOverlayWindow**
Floating overlay window using private UIKit APIs.

**PDLPageControl**
Custom `UIPageControl` replacement with Auto Layout support.

**PDLPageController / PDLPageView / PDLPageViewController / PDLScrollPageViewController**
Components for page-based navigation and paging scroll views, similar to `UIPageViewController`.

**PDLPrivate**
Exposes system debugging methods and compiler-internal functions: description, retain count, autorelease pool, ARC retain/release/autorelease, property dispatch, and super-call internals.

**PDLProcessInfo**
Reports the app's absolute launch time relative to process start.

**PDLPudding**
JSPatch wrapper with symbol obfuscation.

**PDLResizableImageView**
Image view using nine-part (3×3 grid) resizing, equivalent to `resizableImageWithCapInsets:`.

**PDLReuseItemManager**
Generic object reuse pool, analogous to `UITableView`'s cell reuse queue.

**PDLRunLoopObserver**
Observes and reports RunLoop state transitions.

**PDLSafeOperation**
Crash guard for `NSArray` and `NSDictionary`: hooks factory methods and all subclass accessors to perform bounds/nil checking without throwing exceptions.

**PDLSessionTaskStatisticsManager**
Tracks `NSURLSession` task metrics — count, timing, and errors — at runtime.

**PDLSharedCache**
Parses `dyld_shared_cache` on iOS to extract and resolve symbols by address.

**PDLSwiftModule**
Swift interoperability module providing bridging support for other Poodle components.

**PDLSystemImage**
Objective-C wrapper around `pdl_mach_object` with image-loading observers.

**PDLTaskManager**
General-purpose task/operation scheduling manager.

**PDLViewController**
Base `UIViewController` for Poodle debugging UIs.

**UINavigationController+PDLLongPressPop**
Adds a long-press gesture on the back button to pop to an arbitrary ancestor view controller.

**UIScreen+PDLExtension**
Returns the screen size in portrait orientation regardless of current device orientation.

**UIView+PDLDebug**
Enables `colorViewBounds` (colored borders for layout debugging) and `alignmentRects` visualization without raising exceptions.

**UIViewController+PDLExtension**
Non-invasive lifecycle callbacks — observe `viewDidLoad`, `viewWillAppear`, etc. without subclassing.

**UIViewController+PDLNavigationBar**
Convenience API for setting left/right navigation bar button items.

**UIViewController+PDLTransitionAnimation**
Convenience API for configuring custom view controller transition animations.

## License

MIT
