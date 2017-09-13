//
//  LPEngineTransformState.h
//  low_poly_engine
//
//  Created by DEV on 9/6/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef LPENGINETRANSFORMSTATE_H
#define LPENGINETRANSFORMSTATE_H

#import <Foundation/Foundation.h>
#import "LPEnginePrimitives.h"

@interface LPEngineTransformState : NSObject

@property (nonatomic, assign) LPPoint rotation;
@property (nonatomic, assign) LPPoint translation;
@property (nonatomic, assign) LPPoint scale;


- (NSString *)string;

@end

#endif
