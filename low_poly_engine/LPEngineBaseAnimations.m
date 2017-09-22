//
//  LPEngineBaseAnimations.m
//  low_poly_engine
//
//  Created by James Granthamon 9/2/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "LPEngineBaseAnimations.h"
#import "LPEngineAnimationProperties.h"

@implementation LPEngineBaseAnimations

+ (id) sharedManager {
    static LPEngineBaseAnimations *sharedEngineBaseAnimations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngineBaseAnimations = [[self alloc] init];
    });
    return sharedEngineBaseAnimations;
}

- (id)init {
    
    if (self = [super init]) {
        
        _animation1 = ^(LPEngineAnimationProperties *properties) {
            properties.output = 5.0f * sin(properties.progress);
            if (properties.progress != properties.duration) {
                properties.progress++;
            }
        };
        
        _animation2 = ^(LPEngineAnimationProperties *properties) {
            static float anim_percent;
            static float base_anim;
            static float p = 0.2f;
            anim_percent = (float)properties.progress/(float)properties.duration;
            base_anim = pow(2,-10.0f * anim_percent) * sin((anim_percent-p/4.0f)*(2.0f * M_PI)/p) + 1.0f;
            properties.output  = properties.startValue + base_anim * ( properties.endValue - properties.startValue );
            if (properties.progress < properties.duration) {
                properties.progress++;
            }
        };
        
        // cubic ease in and out
        _animation3 = ^(LPEngineAnimationProperties *properties) {
            static float anim_percent;
            static float base_anim;
            
            anim_percent = (float)properties.progress/(float)properties.duration;
            if (anim_percent < 0.5f) {
                base_anim = (pow(anim_percent*2.0f,3.0f)/2.0f);
            } else {
                base_anim = 1.0f - (pow((1.0f-anim_percent)*2.0f,3.0f)/2.0f);
            }
            
            properties.output  = properties.startValue + base_anim * ( properties.endValue - properties.startValue );
            if (properties.progress < properties.duration) {
                properties.progress++;
            }
        };
        
        // cubic ease in
        _animation4 = ^(LPEngineAnimationProperties *properties) {
            static float anim_percent;
            static float base_anim;
            
            anim_percent = (float)properties.progress/(float)properties.duration;
            base_anim = pow(anim_percent,3.0f);
            properties.output  = properties.startValue + base_anim * ( properties.endValue - properties.startValue );
            if (properties.progress < properties.duration) {
                properties.progress++;
            }
        };
        
        // cubic ease out
        _animation5 = ^(LPEngineAnimationProperties *properties) {
            static float anim_percent;
            static float base_anim;
            
            anim_percent = (float)properties.progress/(float)properties.duration;
            base_anim = 1.0f - pow(1.0f-anim_percent,3.0f);
            properties.output  = properties.startValue + base_anim * ( properties.endValue - properties.startValue );
            if (properties.progress < properties.duration) {
                properties.progress++;
            }
        };
        
    }

    return self;
}





@end
