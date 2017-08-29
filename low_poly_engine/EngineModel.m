//
//  EngineModel.m
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineModel.h"
#import "EnginePrimitives.h"
#import "EngineTransforms.h"

@implementation EngineModel

- (id)initWithProperties:(EngineModelInterface *)engineModelProperties {

    if (self = [super init]) {
        _engineModelProperties = engineModelProperties;
        _faces = malloc(sizeof(LPPoint) * engineModelProperties.faceCount);
        _vertices = malloc(sizeof(LPPoint) * engineModelProperties.vertexCount);
        memset(_faces,0,sizeof(LPPoint) * engineModelProperties.faceCount);
        memset(_vertices,0,sizeof(LPPoint) * engineModelProperties.vertexCount);
        _vertexCount = engineModelProperties.vertexCount;
        _faceCount = engineModelProperties.faceCount;
        
        LPPoint translation = {.x=0, .y=0, .z=0};
        LPPoint scale = {.x=1.0, .y=1.0, .z=1.0};
        LPPoint rotation = {.x=0, .y=0, .z=0};
        _translation = translation;
        _scale = scale;
        _rotation = rotation;

        _transformedVertices = malloc(sizeof(LPPoint) * engineModelProperties.vertexCount);
        NSLog(@"Face Count: %i Vertex Count: %i",engineModelProperties.faceCount,engineModelProperties.vertexCount);
        
        for (int vertex = 0; vertex < engineModelProperties.vertexCount; vertex++) {
            _vertices[vertex] = LPPointMake(engineModelProperties.vertices[(vertex * 3)+ 0],
                                engineModelProperties.vertices[(vertex * 3) + 1],
                                engineModelProperties.vertices[(vertex * 3) + 2]);
            _transformedVertices[vertex] = LPPointMake(engineModelProperties.vertices[(vertex * 3)+ 0],
                                            engineModelProperties.vertices[(vertex * 3) + 1],
                                            engineModelProperties.vertices[(vertex * 3) + 2]);
        }
        
        for (int face = 0; face < engineModelProperties.faceCount; face++) {
            _faces[face] = LPPointMake(engineModelProperties.faces[(face * 3) + 0],
                                      engineModelProperties.faces[(face * 3) + 1],
                                      engineModelProperties.faces[(face * 3) + 2]);
        }
        
        [self printVertex];
        [self printFaces];
        [self findVertexCenter];
        
    }
    
    return self;
}

- (void)draw:(LPEngineDrawStyle)drawStyle {
    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    if (drawStyle == LPEngineDrawSolid) {
//        NSLog(@"==STARTING FRAME==");
        for(int face = 0; face < self.engineModelProperties.faceCount; face++) {
            float *point = (float*)&self.faces[face];
            [prim drawTriangleAtPoint1:&self.transformedVertices[(NSInteger)*(point + 0)]
                                Point2:&self.transformedVertices[(NSInteger)*(point + 1)]
                                Point3:&self.transformedVertices[(NSInteger)*(point + 2)]];
            
//            NSLog(@"Face[%i] X1 %0.0f Y1 %0.0f Z1 %0.0f X2 %0.0f Y2 %0.0f Z2 %0.0f X3 %0.0f  Y3 %0.0f Z3 %0.0f",
//                  face,
//                  self.transformedVertices[(NSInteger)*(point + 0)].x,
//                  self.transformedVertices[(NSInteger)*(point + 0)].y,
//                  self.transformedVertices[(NSInteger)*(point + 0)].z,
//                  self.transformedVertices[(NSInteger)*(point + 1)].x,
//                  self.transformedVertices[(NSInteger)*(point + 1)].y,
//                  self.transformedVertices[(NSInteger)*(point + 1)].z,
//                  self.transformedVertices[(NSInteger)*(point + 2)].x,
//                  self.transformedVertices[(NSInteger)*(point + 2)].y,
//                  self.transformedVertices[(NSInteger)*(point + 2)].z
//                  );
        }
    } else {
    }
}


- (void)findVertexCenter {
    static LPPoint vertexCheck = {};
    if (vertexCheck.x != self.translation.x || vertexCheck.y != self.translation.y || vertexCheck.z != self.translation.z) {
        [self transformVertices];
        LPPoint center = {};
        
        for (int vertex = 0; vertex < self.vertexCount; vertex++) {
            center.x += self.vertices[vertex].x;
            center.y += self.vertices[vertex].y;
            center.z += self.vertices[vertex].z;
        }
        center.x = center.x / (float)self.vertexCount;
        center.y = center.y / (float)self.vertexCount;
        center.z = center.z / (float)self.vertexCount;
        
        center.x += self.translation.x;
        center.y += self.translation.y;
        center.z += self.translation.z;
        
        
        NSLog(@"Vertex Center at x: %0.2f y: %0.2f x: %0.2f",center.x,center.y,center.z);
        
        vertexCheck = self.translation;
        
        self.center = center;
    }

}

- (void)transformVertices {
    for (int vertex = 0; vertex < self.vertexCount; vertex++) {
        LPPoint temp = self.vertices[vertex];
        //EnginePrimitives *primitives = [EnginePrimitives sharedManager];
        temp = [EngineTransforms translatePoint:temp WithVector:self.translation];
        temp = [EngineTransforms scalePoint:temp WithVector:self.scale];
        temp = [EngineTransforms rotateAtXAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.x];
        temp = [EngineTransforms rotateAtYAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.y];
        temp = [EngineTransforms rotateAtZAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.z];
        self.transformedVertices[vertex] = temp;
    }
    
}

- (void)resetTransforms {
    LPPoint point = {.x=0, .y=0, .z=0};
    self.translation = point;
    self.rotation = point;
    self.rotationAxis = point;
    self.scale = point;
    
}



- (void)printVertex {
    NSLog(@"--VERTICES-- [vertex count: %i]",self.engineModelProperties.vertexCount);
    for (int vertex = 0; vertex < self.engineModelProperties.vertexCount; vertex++) {
        NSLog(@"{ %f, %f, %f }",self.vertices[vertex].x,self.vertices[vertex].y,self.vertices[vertex].z);
    }
}
- (void)printFaces {
    NSLog(@"--FACES-- [face count: %i]",self.engineModelProperties.faceCount);
    for (int face = 0; face < self.engineModelProperties.faceCount; face++) {
        NSLog(@"{ %f, %f, %f }",self.faces[face].x,self.faces[face].y,self.faces[face].z);
    }
}

@end
