//
//  LPEngineTransformState.h
//  low_poly_engine
//
//  Created by James Granthamon 9/6/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef LPENGINETRANSFORMSTATE_H
#define LPENGINETRANSFORMSTATE_H

#import <Foundation/Foundation.h>
#import "LPEnginePrimitives.h"

@interface LPEngineTransformState : NSObject

@property (nonatomic, assign) LPPoint rotation;
@property (nonatomic, assign) LPPoint translation;
@property (nonatomic, assign) LPPoint scale;

- (id)init;

@end

#endif
