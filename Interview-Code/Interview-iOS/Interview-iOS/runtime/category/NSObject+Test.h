//
//  NSObject+Test.h
//  Interview-iOS
//
//  Created by HF on 2022/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Test)
@property (nonatomic, copy) NSString *num;

+ (void)outputMyPropertyList;

@end

NS_ASSUME_NONNULL_END
