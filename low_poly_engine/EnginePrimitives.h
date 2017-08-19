//
//  EnginePrimitives.h
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EnginePrimitives_h
#define EnginePrimitives_h
#include <MetalKit/MetalKit.h>
#include <Metal/Metal.h>

typedef struct LPPoint{
    int16_t x;
    int16_t y;
    int16_t z;
} LPPoint;

typedef struct LPTriangle{
    LPPoint p1;
    LPPoint p2;
    LPPoint p3;

} LPTriangle;


typedef struct Vertex {
    vector_float4 position;
    vector_float4 color;
} Vertex;

LPTriangle LPTriangleMake(LPPoint p1, LPPoint p2, LPPoint p3) ;

LPPoint LPPointMake(int16_t x, int16_t y, int16_t z) ;
@interface EnginePrimitives : NSObject

@property (nonatomic) Vertex *vertexData;
@property (nonatomic) NSInteger vertexDataSize;



- (void) clearVertices;
- (Vertex *)addVertex:(Vertex)vertex To:(Vertex*)source OfSize:(NSInteger*)sourceSize;

+ (id) sharedManager;

- (void) drawPixelAtX:(NSInteger)x Y:(NSInteger)y;
- (void) setColorWithRed:(NSInteger)red Green: (NSInteger) green Blue:(NSInteger)blue ;

- (CGSize) canvasSize;
- (void) setPixelWidth:(NSInteger)pxWidth;
- (void) setVirtualWidth:(NSInteger)width;
- (void) setVirtualHeight:(NSInteger) height;
- (float) virtualWidth;
- (float) virtualHeight;
- (void) resetDepthBuffer;

- (void) drawHorizontalLineAtLeftPoint:(LPPoint) leftPoint RightPoint:(LPPoint)rightPoint;
- (void) drawHorizontalLineAtLeftX:(NSInteger)leftX LeftY:(NSInteger)leftY  RightX:(NSInteger)rightX  RightY:(NSInteger)rightY;
    
    
    
- (void) drawTriangleAtPoint1:(LPPoint*) p1 Point2:(LPPoint*) p2 Point3:(LPPoint*) p3;
- (void) drawTriangleAtCopiedPoint1:(LPPoint) p1 Point2:(LPPoint) p2 Point3:(LPPoint) p3;
- (void) drawTriangleAtX1:(NSInteger)x1 Y1:(NSInteger)y1 X2:(NSInteger)x2 Y2:(NSInteger)y2 X3:(NSInteger)x3 Y3:(NSInteger)y3;
- (void) drawTriangle:(LPTriangle*) triangle;
- (void) drawScanLineAtLeftX:(NSInteger)leftX RightX:(NSInteger)rightX LeftZ:(NSInteger)leftZ RightZ:(NSInteger)rightZ Y:(NSInteger)y;

@end

#endif /* EnginePrimitives_h */
