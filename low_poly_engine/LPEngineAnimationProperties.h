//
//  LPEngineAnimationProperties.h
//  low_poly_engine
//
//  Created by James Granthamon 9/2/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef LPENGINEANIMATIONPROPERTIES_H
#define LPENGINEANIMATIONPROPERTIES_H

#import <Foundation/Foundation.h>

@interface LPEngineAnimationProperties : NSObject

@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger startValue;
@property (nonatomic, assign) NSInteger endValue;
@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, assign) NSInteger output;
@property (nonatomic, assign) BOOL complete;

@end

#endif
