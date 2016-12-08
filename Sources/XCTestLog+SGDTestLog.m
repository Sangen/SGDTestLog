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

NSString *const kRGTestCaseFormat = @"%@: %s (%.3fs)";
NSString *const kXCTestCaseFormat = @"Test Case '%@' %s (%.3f seconds).\n";
NSString *const kXCTestSuiteStartFormat = @"Test Suite '%@' started at %@\n";
NSString *const kXCTestSuiteFinishFormat  = @"Test Suite '%@' finished at %@.\n";
NSString *const kXCTestSuiteFinishLongFormat = @"Test Suite '%@' %s at %@.\n\t Executed %lu test%s, with %lu failure%s (%lu unexpected) in %.3f (%.3f) seconds";
NSString *const kXCTestErrorFormat = @"%@:%lu: error: %@ : %@\n";
NSString *const kXCTestCaseArgsFormat = @"%@|%s|%.5f";
NSString *const kXCTestErrorArgsFormat = @"%@|%lu|%@|%@";
NSString *const kRGArgsSeparator = @"|";

NSString *const kXCTestPassed   = @"PASSED";
NSString *const kXCTTestFailed  = @"FAILED";
NSString *const kXCTTestPending = @"PENDING";

NSString *const kPassedIcon = @"✅";
NSString *const kFailedIcon = @"❌";
NSString *const kFailedLineIcon = @"🚩";
NSString *const kSeparatorIcon = @" ‣ ";
NSString *const kTestRowFormat = @"%@ %@]  %@ (%@s)\n";
NSString *const kFailedFormat = @"\t%@Line %@: %@\n";


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
        NSString *icon = [log.uppercaseString isEqualToString:kXCTestPassed] ? kPassedIcon : kFailedIcon;
        NSString *messenger = methodParts[0];
        NSString *methodWithUScore = [methodParts[1] stringByReplacingOccurrencesOfString: @"]" withString: @""];
        NSString *mLevel1 = [methodWithUScore stringByReplacingOccurrencesOfString: @"____" withString: kSeparatorIcon];
        NSString *mLevel2 = [mLevel1 stringByReplacingOccurrencesOfString: @"___" withString: kSeparatorIcon];
        NSString *mLevel3 = [mLevel2 stringByReplacingOccurrencesOfString: @"__" withString: kSeparatorIcon];
        NSString *method = [mLevel3 stringByReplacingOccurrencesOfString: @"_" withString: @" "];
        NSString *output = [NSString stringWithFormat: kTestRowFormat, icon, messenger, method, time];

        printf("%s", output.UTF8String);

        if (!self.class.errors.count) return;

        [self.class.errors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { printf("%s\n", [obj UTF8String]); }];
        [self.class.errors removeAllObjects];

    } else if ([format isEqualToString:kXCTestErrorFormat]) {
        NSArray *args = [[NSString.alloc initWithFormat:kXCTestErrorArgsFormat arguments:arguments] componentsSeparatedByString:kRGArgsSeparator];

        NSString *output = [NSString stringWithFormat:kFailedFormat, kFailedLineIcon, args[1], args[3]];
        [self.class.errors addObject: output];
    }
    va_end(arguments);
}

@end
