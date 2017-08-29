//
//  EngineModelInterface.h
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnginePrimitives.h"

@interface EngineModelInterface : NSObject

@property (nonatomic, assign) int16_t *vertices;
@property (nonatomic, assign) int16_t vertexCount;
@property (nonatomic, assign) int16_t *faces;
@property (nonatomic, assign) int16_t faceCount;
@property (nonatomic, assign) int16_t *normals;
@property (nonatomic, assign) int16_t normalCount;
@property (nonatomic, assign) int16_t color;
@property (nonatomic, assign) LPPoint lightSource;


@end
