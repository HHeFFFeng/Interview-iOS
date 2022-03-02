//
//  RTPerson.h
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTPerson : NSObject

- (void)setTall:(BOOL)tall;
- (void)setRich:(BOOL)rich;
- (void)setHandsome:(BOOL)handsome;

- (BOOL)isTall;
- (BOOL)isRich;
- (BOOL)isHandsome;

@end

NS_ASSUME_NONNULL_END
