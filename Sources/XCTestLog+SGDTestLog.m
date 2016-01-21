//
//  XCTestLog+SGDTestLog.m
//  SGDTestLog
//
//  Created by Sangen on 1/21/16.
//  Copyright © 2016 Sangen. All rights reserved.
//

#import "XCTestLog+SGDTestLog.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <stdarg.h>

#define CLR_BEG "\033[fg"
#define CLR_END "\033[;"
#define CLR_WHT "239,239,239"
#define CLR_GRY "150,150,150"
#define CLR_WOW "241,196,15"
#define CLR_GRN "46,204,113"
#define CLR_RED "211,84,0"

NSString *const kRGTestCaseFormat = @"%@: %s (%.3fs)";
NSString *const kXCTestCaseFormat = @"Test Case '%@' %s (%.3f seconds).\n";
NSString *const kXCTestSuiteStartFormat = @"Test Suite '%@' started at %@\n";
NSString *const kXCTestSuiteFinishFormat  = @"Test Suite '%@' finished at %@.\n";
//*const kXCTestSuiteFinishLongFormat	= @"Test Suite '%@' finished at %@.\n"
//"Executed %ld test%s, with %ld failure%s (%ld unexpected) in %.3f (%.3f) seconds\n";
NSString *const kXCTestSuiteFinishLongFormat = @"Test Suite '%@' %s at %@.\n\t Executed %lu test%s, with %lu failure%s (%lu unexpected) in %.3f (%.3f) seconds";
//= @"Test Suite '%@' %s at %@.\nExecuted %lu test%s, with %lu failure%s (%lu unexpected) in %.3f (%.3f) seconds\n";
NSString *const kXCTestErrorFormat = @"%@:%lu: error: %@ : %@\n";
NSString *const kXCTestCaseArgsFormat = @"%@|%s|%.5f";
NSString *const kXCTestErrorArgsFormat = @"%@|%lu|%@|%@";
NSString *const kRGArgsSeparator = @"|";

NSString *const kXCTestPassed   = @"PASSED";
NSString *const kXCTTestFailed  = @"FAILED";
NSString *const kXCTTestPending = @"PENDING";
NSString *const kRGTestCaseXCOutputFormat 	= @"" CLR_BEG "%@;%@:" 		 CLR_END CLR_BEG CLR_GRY ";%@ " 		CLR_END
CLR_BEG CLR_WHT ";%@" CLR_END CLR_BEG CLR_GRY ";] (%@s)" CLR_END "\n";
NSString *const kRGTestCaseOutputFormat 		= @"%@: %@ (%@s)\n";
NSString *const kRGTestErrorXCOutputFormat 	= @"\t\033[fg%@;Line %@: %@\033[;\n";
NSString *const kRGTestErrorOutputFormat 		= @"\tLine %@: %@\n";


@implementation XCTestCase (SGDTestLog)
- (void)Pending:(NSString *)message {
    XCTAssertTrue(true, @"Pending: %@", message);
}
@end


// Suppress `deprecated` warnings begin
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation XCTestLog (SGDTestLog)
#pragma clang diagnostic pop
// end

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(testLogWithFormat:)),
                                   class_getInstanceMethod(self, @selector(testLogWithColorFormat:)));
}

+ (NSMutableArray *)errors {
    static dispatch_once_t pred;
    static NSMutableArray *_errors = nil;

    dispatch_once(&pred, ^{ _errors = NSMutableArray.new; });
    return _errors;
}

+ (NSString *)updatedOutputFormat:(NSString*)fmt {
    return [fmt isEqualToString:kXCTestCaseFormat] ? kRGTestCaseFormat : fmt;
}

+ (BOOL)isXcodeColorsEnabled {
    return YES;
}

- (void)testLogWithColorFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {

    va_list arguments;
    va_start(arguments, format);

    if ([format isEqualToString: kXCTestCaseFormat]) {
        NSArray *args = [[NSString.alloc initWithFormat:kXCTestCaseArgsFormat arguments:arguments] componentsSeparatedByString:kRGArgsSeparator];
        NSArray *methodParts = [args[0] componentsSeparatedByString:@" "];
        NSString *log = args[1];
        NSString *time = args[2];
        NSString *color = [NSString stringWithUTF8String:[log.uppercaseString isEqualToString:kXCTestPassed] ? CLR_GRN : CLR_RED];
        NSString *messenger = methodParts[0];
        NSString *method = [methodParts[1] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSString *output = [self.class isXcodeColorsEnabled]
        ? [NSString stringWithFormat:kRGTestCaseXCOutputFormat, color, log.uppercaseString, messenger, method, time]
        : [NSString stringWithFormat:kRGTestCaseOutputFormat, log.uppercaseString, args[0], time];

        printf("%s", output.UTF8String);

        if (!self.class.errors.count) return;

        [self.class.errors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { printf("%s\n", [obj UTF8String]); }];
        [self.class.errors removeAllObjects];

    } else if ([format isEqualToString:kXCTestErrorFormat]){
        NSArray *args = [[NSString.alloc initWithFormat:kXCTestErrorArgsFormat arguments:arguments] componentsSeparatedByString:kRGArgsSeparator];

        [self.class.errors addObject: ![self.class isXcodeColorsEnabled] ? [NSString stringWithFormat:kRGTestErrorOutputFormat, args[1], args[3]] : ^{
            NSInteger failureLoc;
            if ((failureLoc = [args[3] rangeOfString:@"failed"].location) == NSNotFound) {
                return [NSString stringWithFormat:kRGTestErrorXCOutputFormat,[NSString stringWithUTF8String:CLR_RED], args[1], args[3]];
            }

            NSString *problem = [args[3] substringToIndex:failureLoc];
            NSString *reason = [args[3] substringFromIndex:failureLoc + @"failed ".length];

            return [NSString stringWithFormat:@"%@%@%@",
                    [NSString stringWithFormat:@"" CLR_BEG CLR_WOW ";#%@" CLR_END, @(self.class.errors.count+1).stringValue],
                    [NSString stringWithFormat:@"%@" CLR_BEG CLR_GRY ";@%@" CLR_END, self.class.errors.count < 10 ? @" ":@"", args[1]],
                    [NSString stringWithFormat:@"" CLR_BEG CLR_WHT ";  %@ "CLR_END CLR_BEG CLR_RED ";%@" CLR_END, problem, reason]];
        }()];
    }
    va_end(arguments);
}

@end
