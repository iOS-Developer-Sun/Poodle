import lldb;
import re;

pdl_debug = False;

def pdl_print(str):
    if pdl_debug:
        print(str);

def pdl_isSuccess(error):
    # When evaluating a `void` expression, the returned value will indicate an
    # error. This error is named: kNoResult. This error value does *not* mean
    # there was a problem. This logic follows what the builtin `expression`
    # command does. See: https://git.io/vwpjl (UserExpression.h)
    kNoResult = 0x1001
    return error.success or error.value == kNoResult

def pdl_evaluateExpressionValue(expression, printErrors=True, language=lldb.eLanguageTypeObjC_plus_plus, tryAllThreads=False):
    frame = lldb.debugger.GetSelectedTarget().GetProcess().GetSelectedThread().GetSelectedFrame()
    options = lldb.SBExpressionOptions()
    options.SetLanguage(language)

    options.SetTrapExceptions(False)
    options.SetTimeoutInMicroSeconds(5000000)
    options.SetTryAllThreads(tryAllThreads)

    value = frame.EvaluateExpression(expression, options)
    error = value.GetError()

    if printErrors and not pdl_isSuccess(error):
        print(expression + ':');
        print('[' + str(error.GetError()) +  ']' + error.GetCString())
        return None

    return value

def pdl_getAddr(string):
    loadAddr = 0;

    try:
        loadAddr = int(string);
    except ValueError:
        pass;
    else:
        pass;
    if loadAddr:
        return loadAddr;

    try:
        loadAddr = int(string, 16);
    except ValueError:
        pass;
    else:
        pass;
    if loadAddr:
        return loadAddr;

    target = lldb.debugger.GetSelectedTarget();
    strings = string.split('`');
    functionString = string;
    moduleString = None;
    if len(strings) == 2:
        moduleString = strings[0];
        functionString = strings[1];
    hookedListFound = target.FindFunctions(functionString, lldb.eFunctionNameTypeFull);
    if not hookedListFound.IsValid():
        print('Invalid name' + functionString);
        return None;
    if hookedListFound.GetSize() == 0:
        print('No function found with name ' + functionString);
        return None;
    context = hookedListFound.GetContextAtIndex(0);
    if moduleString:
        contextFound = None;
        for i in range(0, hookedListFound.GetSize()):
            context = hookedListFound.GetContextAtIndex(i);
            module = context.GetModule();
            fileSpec = module.GetFileSpec();
            filename = fileSpec.GetFilename();
            if filename == moduleString:
                contextFound = context;
                break;
        if not contextFound:
            print('No function found with name ' + string);
            return;

    pdl_print('context:');
    pdl_print(context);
    function = context.GetFunction();
    if function:
        pdl_print('function:');
        pdl_print(function);
        startAddr = function.GetStartAddress();
        pdl_print('startAddr:');
        pdl_print(startAddr);
        loadAddr = startAddr.GetLoadAddress(target);
        pdl_print('loadAddr:');
        pdl_print(loadAddr);
        return loadAddr;
    symbol = context.GetSymbol();
    if symbol:
        pdl_print('symbol:');
        pdl_print(symbol);
        startAddr = symbol.GetStartAddress();
        pdl_print('startAddr:');
        pdl_print(startAddr);
        loadAddr = startAddr.GetLoadAddress(target);
        pdl_print('loadAddr:');
        pdl_print(loadAddr);
        return loadAddr;
    return None;

def pdl_hook(debugger, command, result, dict):
    args = command.split(' ');
    while '' in args:
        args.remove('');
    if len(args) != 2:
        print('usage: pdl_hook [hooked function] [custom function]');
        return;

    hookedFunction = args[0];
    customFunction = args[1];

    hookedFunctionAddr = pdl_getAddr(hookedFunction)
    if not hookedFunctionAddr:
        return;

    customFunctionAddr = pdl_getAddr(customFunction)
    if not customFunctionAddr:
        return;

    # pdl_lldb_hook
    cmd = 'pdl_lldb_hook((IMP)' + hex(hookedFunctionAddr) + ', (IMP)' + hex(customFunctionAddr) + ')';
    pdl_print(cmd);
    value = pdl_evaluateExpressionValue(cmd);
    if not value:
        return;

    ret = value.GetValueAsSigned();
    if not ret:
        print(cmd + ' returns false');
        return;

    # pdl_lldb_command
    cmd = 'pdl_lldb_command()';
    pdl_print(cmd);
    value = pdl_evaluateExpressionValue(cmd);
    if not value:
        return;

    ret = value.GetValueAsUnsigned();
    if not ret:
        print(cmd + ' returns null');
        return;

    process = lldb.debugger.GetSelectedTarget().GetProcess();
    error = lldb.SBError();
    if error:
        print(error);
        return;

    memoryWriteCommandsString = process.ReadCStringFromMemory(ret, 1024, error);
    pdl_print(memoryWriteCommandsString);

    # memory write
    memoryWriteCommands = memoryWriteCommandsString.split('\n');
    while '' in memoryWriteCommands:
        memoryWriteCommands.remove('');

    for memoryWriteCommand in memoryWriteCommands:
        interpreter = lldb.debugger.GetCommandInterpreter();
        returnObject = lldb.SBCommandReturnObject();
        interpreter.HandleCommand(memoryWriteCommand, returnObject);
        pdl_print(returnObject);
        error = returnObject.GetError();
        if error:
            print(error);
            return;
    print('pdl_hook ' + hookedFunction + '(' + hex(hookedFunctionAddr) + ') with ' + customFunction + '(' + hex(customFunctionAddr) + ') succeeded');
    return;

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add pdl_hook -f pdl_lldb_hook.pdl_hook')
    print('The "pdl_hook" python command has been installed and is ready for use.')
