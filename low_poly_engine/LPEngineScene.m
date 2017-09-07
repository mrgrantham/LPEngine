//
//  EngineScene.m
//  low_poly_engine
//
//  Created by DEV on 8/21/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "LPEngineScene.h"

@implementation LPEngineScene

- (NSInteger)addModel:(LPEngineModel *)model {
    static NSInteger ID = -1;
    ID++;
    model.lightSource = self.lightSource;
    LPEngineSceneModelState *modelState = [[LPEngineSceneModelState alloc] initWithModel:model];
    [self.models addObject:modelState];
    
    return temp;
}
- (void)transformModelWithID:(NSInteger)modelID
              Transformation:(LPEngineModelTransform)transformation {
    
}

@end
