//
//  LPEngineBaseAnimations.h
//  low_poly_engine
//
//  Created by DEV on 9/2/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef LPENGINEBASEANIMATIONS_H
#define LPENGINEBASEANIMATIONS_H

#import <Foundation/Foundation.h>
#import "LPEngineAnimationProperties.h"

@interface LPEngineBaseAnimations : NSObject

typedef void (^AnimationBlock)(LPEngineAnimationProperties*);

@property (nonatomic) AnimationBlock animation1;
@property (nonatomic) AnimationBlock animation2;
@property (nonatomic) AnimationBlock animation3;
@property (nonatomic) AnimationBlock animation4;
@property (nonatomic) AnimationBlock animation5;

+ (id) sharedManager;
- (id)init;

@end

#endif
