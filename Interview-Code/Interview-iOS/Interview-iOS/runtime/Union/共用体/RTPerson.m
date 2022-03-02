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
    union {
        char bits;
        // 下面这个结构体，完全为了增加可读性
        struct {
            char tall: 1;
            char rich: 1;
            char handsome: 1;
        };
    } _tallRichHandsome;
}
@end

@implementation RTPerson

- (void)setTall:(BOOL)tall {
    if (tall) {
        _tallRichHandsome.bits = RTTallMask | _tallRichHandsome.bits;
    } else {
        _tallRichHandsome.bits = ~RTTallMask & _tallRichHandsome.bits;
    }
}
- (void)setRich:(BOOL)rich {
    if (rich) {
        _tallRichHandsome.bits = RTRichMask | _tallRichHandsome.bits;
    } else {
        _tallRichHandsome.bits = ~RTRichMask & _tallRichHandsome.bits;
    }
}
- (void)setHandsome:(BOOL)handsome {
    if (handsome) {
        _tallRichHandsome.bits = RTHandsomeMask | _tallRichHandsome.bits;
    } else {
        _tallRichHandsome.bits = ~RTHandsomeMask & _tallRichHandsome.bits;
    }
}

- (BOOL)isTall {
    return !!(_tallRichHandsome.bits & RTTallMask);
}
- (BOOL)isRich {
    return !!(_tallRichHandsome.bits & RTRichMask);
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome.bits & RTHandsomeMask);
}

@end
