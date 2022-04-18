//
//  OCPerson.h
//  Interview-iOS
//
//  Created by HF on 2022/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPerson : NSObject

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *idNum;

- (void)testA;
- (void)testB;

@end

NS_ASSUME_NONNULL_END
