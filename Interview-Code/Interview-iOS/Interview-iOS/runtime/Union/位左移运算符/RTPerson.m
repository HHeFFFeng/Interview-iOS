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
    char _tallRichHandsome;
}
@end

@implementation RTPerson

- (void)setTall:(BOOL)tall {
    if (tall) {
        _tallRichHandsome = RTTallMask | _tallRichHandsome;
    } else {
        _tallRichHandsome = ~RTTallMask & _tallRichHandsome;
    }
}
- (void)setRich:(BOOL)rich {
    if (rich) {
        _tallRichHandsome = RTRichMask | _tallRichHandsome;
    } else {
        _tallRichHandsome = ~RTRichMask & _tallRichHandsome;
    }
}
- (void)setHandsome:(BOOL)handsome {
    if (handsome) {
        _tallRichHandsome = RTHandsomeMask | _tallRichHandsome;
    } else {
        _tallRichHandsome = ~RTHandsomeMask & _tallRichHandsome;
    }
}

- (BOOL)isTall {
    return !!(_tallRichHandsome & RTTallMask);
}
- (BOOL)isRich {
    return !!(_tallRichHandsome & RTRichMask);
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome & RTHandsomeMask);
}

@end
