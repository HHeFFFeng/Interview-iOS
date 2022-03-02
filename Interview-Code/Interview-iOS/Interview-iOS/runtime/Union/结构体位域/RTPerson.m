//
//  RTPerson.m
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import "RTPerson.h"

#define RTTallMask 1<<0
#define RTRichMask 1<<1
#define RTHandsomeMask 1<<2

@interface RTPerson()
{
    struct {
        char tall: 1;
        char rich: 1;
        char handsome: 1;
    } _tallRichHandsome;
}
@end

@implementation RTPerson

- (void)setTall:(BOOL)tall {
    _tallRichHandsome.tall = tall;
}
- (void)setRich:(BOOL)rich {
    _tallRichHandsome.rich = rich;
}
- (void)setHandsome:(BOOL)handsome {
    _tallRichHandsome.handsome = handsome;
}

- (BOOL)isTall {
    return !!(_tallRichHandsome.tall);
}
- (BOOL)isRich {
    return !!(_tallRichHandsome.rich);
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome.handsome);
}

@end
