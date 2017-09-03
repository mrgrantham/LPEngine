//
//  EngineModel.h
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineModel_h
#define EngineModel_h

#import "LPEnginePrimitives.h"
#import "LPEngineModelInterface.h"

typedef NS_ENUM(NSInteger, LPEngineDrawStyle) {
    LPEngineDrawSolid,
    LPEngineDrawWireframe
};

@interface LPEngineModel : NSObject

@property (nonatomic, assign) vector_float4 *drawableVerticesSolid;
@property (nonatomic, assign) vector_float4 *drawableVerticesWireframe;
@property (nonatomic, readonly) LPEngineModelInterface *engineModelProperties;


@property (nonatomic, readonly) LPPoint *vertices;
@property (nonatomic, readonly) LPPoint *faces;
@property (nonatomic, readonly) LPPoint *normals;
@property (nonatomic, readonly) float *lightFactors;
@property (nonatomic, readonly) NSInteger vertexCount;
@property (nonatomic, readonly) NSInteger faceCount;

@property (nonatomic, assign) LPPoint *transformedVertices;
@property (nonatomic, assign) LPPoint *transformedNormals;
@property (nonatomic, assign) LPPoint translation;
@property (nonatomic, assign) LPPoint scale;
@property (nonatomic, assign) LPPoint rotation;
@property (nonatomic, assign) LPPoint rotationAxis;
@property (nonatomic, assign) LPPoint lightSource;
@property (nonatomic, assign) LPPoint center;
@property (nonatomic, assign) BOOL centerChanged;




- (id)init NS_UNAVAILABLE;
- (id)initWithProperties:(LPEngineModelInterface *)engineModelProperties NS_DESIGNATED_INITIALIZER;

- (void)draw:(LPEngineDrawStyle)drawStyle;

- (void)findVertexCenter;

- (void)rotateWithVector:(LPPoint)rotationVector;
- (void)translateWithVector:(LPPoint)translationVector;
- (void)scaleWithVector:(LPPoint)scaleVector;

- (void)transformVertices;
- (float)findLightFactor:(LPPoint)normal;
- (void)resetTransforms;

- (void)printVertex;
- (void)printFaces;
- (void)printNormals;
- (void)printLightFactors;

@end

#endif /* EngineModel_h */
