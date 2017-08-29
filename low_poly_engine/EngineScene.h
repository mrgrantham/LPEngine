//
//  EngineScene.h
//  low_poly_engine
//
//  Created by DEV on 8/21/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineModel.h"

typedef NS_ENUM(NSInteger, LPEngineModelTransform) {
    LPEngineModelTransformRotate,
    LPEngineModelTransformScale,
    LPEngineModelTransformTranslate
};


@interface EngineScene : NSObject

- (NSInteger)addModel:(EngineModel *)model;
- (void)transformModelWithID:(NSInteger)modelID
              Transformation:(LPEngineModelTransform)transformation;


@end
