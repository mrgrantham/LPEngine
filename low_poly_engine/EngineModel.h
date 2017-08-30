//
//  EngineModel.h
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineModel_h
#define EngineModel_h

#import "EnginePrimitives.h"
#import "EngineModelInterface.h"

typedef NS_ENUM(NSInteger, LPEngineDrawStyle) {
    LPEngineDrawSolid,
    LPEngineDrawWireframe
};

@interface EngineModel : NSObject

@property (nonatomic, assign) vector_float4 *drawableVerticesSolid;
@property (nonatomic, assign) vector_float4 *drawableVerticesWireframe;
@property (nonatomic, readonly) EngineModelInterface *engineModelProperties;


@property (nonatomic, readonly) LPPoint *vertices;
@property (nonatomic, readonly) LPPoint *faces;
@property (nonatomic, readonly) NSInteger vertexCount;
@property (nonatomic, readonly) NSInteger faceCount;

@property (nonatomic, assign) LPPoint *transformedVertices;
@property (nonatomic, assign) LPPoint translation;
@property (nonatomic, assign) LPPoint scale;
@property (nonatomic, assign) LPPoint rotation;
@property (nonatomic, assign) LPPoint rotationAxis;
@property (nonatomic, assign) LPPoint lightSource;
@property (nonatomic, assign) LPPoint center;




- (id)init NS_UNAVAILABLE;
- (id)initWithProperties:(EngineModelInterface *)engineModelProperties NS_DESIGNATED_INITIALIZER;

- (void)draw:(LPEngineDrawStyle)drawStyle;

- (void)findVertexCenter;

- (void)rotateWithVector:(LPPoint)rotationVector;
- (void)translateWithVector:(LPPoint)translationVector;
- (void)scaleWithVector:(LPPoint)scaleVector;

- (void)transformVertices;
- (void)resetTransforms;

- (void)printVertex;
- (void)printFaces;


@end

#endif /* EngineModel_h */
