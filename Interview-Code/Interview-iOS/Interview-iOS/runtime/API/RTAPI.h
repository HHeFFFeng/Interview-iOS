//
//  RTAPI.h
//  Interview-iOS
//
//  Created by HF on 2022/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTAPI : NSObject

- (void)run;

- (void)testCreateClass;
- (void)testChangeISAClass;
- (void)testObjectIsClass;
- (void)testGetInstanceVariable;
- (void)testCopyIvarList;

@end

NS_ASSUME_NONNULL_END
