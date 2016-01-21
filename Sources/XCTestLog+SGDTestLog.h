//
//  XCTestLog+SGDTestLog.h
//  SGDTestLog
//
//  Created by Sangen on 1/21/16.
//  Copyright © 2016 Sangen. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestLog (SGDTestLog)
- (void)testLogWithColorFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
@end

@interface XCTestCase (SGDLogger)
- (void)Pending:(NSString *)message;
@end
