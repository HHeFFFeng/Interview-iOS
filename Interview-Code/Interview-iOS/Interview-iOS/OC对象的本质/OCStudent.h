//
//  OCStudent.h
//  Interview-iOS
//
//  Created by HF on 2022/2/24.
//

#import <Foundation/Foundation.h>
#import "OCPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCStudent: OCPerson
{
    @public
    NSString *_name;
    int _age;
}

+ (void)read;
- (void)testA;
- (void)testB;
@end

NS_ASSUME_NONNULL_END
