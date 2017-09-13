//
//  LPEngineTransformState.m
//  low_poly_engine
//
//  Created by DEV on 9/6/17.
//  Copyright © 2017 DEV. All rights reserved.
//



#import "LPEngineTransformState.h"
#import "LPEnginePrimitives.h"

@implementation LPEngineTransformState

- (NSString *)string {
    return [NSString stringWithFormat:@"Tran  %@\nRot   %@\nScale %@",NSStringFromLPPoint(_translation), NSStringFromLPPoint(_rotation), NSStringFromLPPoint(_scale)];
}

@end

