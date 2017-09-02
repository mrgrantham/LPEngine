//
//  EngineScene.h
//  low_poly_engine
//
//  Created by DEV on 8/21/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPEngineModel.h"

typedef NS_ENUM(NSInteger, LPEngineModelTransform) {
    LPEngineModelTransformRotate,
    LPEngineModelTransformScale,
    LPEngineModelTransformTranslate
};


@interface EngineScene : NSObject

- (NSInteger)addModel:(LPEngineModel *)model;
- (void)transformModelWithID:(NSInteger)modelID
              Transformation:(LPEngineModelTransform)transformation;


@end
