//
//  LPEngineTransformState.m
//  low_poly_engine
//
//  Created by James Granthamon 9/6/17.
//  Copyright © 2017 James Grantham All rights reserved.
//



#import "LPEngineTransformState.h"

@implementation LPEngineTransformState

- (id)init {
    if (self = [super init]) {
        _rotation = LPPointMake(0.0, 0.0, 0.0);
        _translation = LPPointMake(0.0, 0.0, 0.0);
        _scale = LPPointMake(1.0, 1.0, 1.0);
    }
    return self;
}

@end

