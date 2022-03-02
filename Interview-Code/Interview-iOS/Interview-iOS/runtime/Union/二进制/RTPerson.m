//
//  RTPerson.m
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import "RTPerson.h"

@interface RTPerson()
{
    char _tallRichHandsome;
}
@end

@implementation RTPerson

- (void)setTall:(BOOL)tall {
    if (tall) {
        _tallRichHandsome = 0b0001 | _tallRichHandsome;
    } else {
        _tallRichHandsome = 0b1110 & _tallRichHandsome;
    }
}
- (void)setRich:(BOOL)rich {
    if (rich) {
        _tallRichHandsome = 0b0010 | _tallRichHandsome;
    } else {
        _tallRichHandsome = 0b1101 & _tallRichHandsome;
    }
}
- (void)setHandsome:(BOOL)handsome {
    if (handsome) {
        _tallRichHandsome = 0b0100 | _tallRichHandsome;
    } else {
        _tallRichHandsome = 0b1011 & _tallRichHandsome;
    }
}

- (BOOL)isTall {
    return !!(_tallRichHandsome & 0b0001);
}
- (BOOL)isRich {
    return !!(_tallRichHandsome & 0b0010);
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome & 0b0100);
}

@end
