//
//  EngineModel.m
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPEngineModel.h"
#import "LPEnginePrimitives.h"
#import "LPEngineTransforms.h"
#import <simd/simd.h>

@implementation LPEngineModel

- (id)initWithProperties:(LPEngineModelInterface *)engineModelProperties {

    if (self = [super init]) {
        _engineModelProperties = engineModelProperties;
        _faces = malloc(sizeof(LPPoint) * engineModelProperties.faceCount);
        _normals = malloc(sizeof(LPPoint) * engineModelProperties.faceCount);
        _transformedNormals = malloc(sizeof(LPPoint) * engineModelProperties.faceCount);
        _lightFactors = malloc(sizeof(float) * engineModelProperties.faceCount);
        _vertices = malloc(sizeof(LPPoint) * engineModelProperties.vertexCount);
        memset(_faces,0,sizeof(LPPoint) * engineModelProperties.faceCount);
        memset(_normals,0,sizeof(LPPoint) * engineModelProperties.faceCount);
        memset(_transformedNormals,0,sizeof(LPPoint) * engineModelProperties.faceCount);
        memset(_lightFactors,0,sizeof(float) * engineModelProperties.faceCount);
        memset(_vertices,0,sizeof(LPPoint) * engineModelProperties.vertexCount);
        _vertexCount = engineModelProperties.vertexCount;
        _faceCount = engineModelProperties.faceCount;
        
        LPPoint translation = {.x=0, .y=0, .z=0};
        LPPoint scale = {.x=1.0, .y=1.0, .z=1.0};
        LPPoint rotation = {.x=0, .y=0, .z=0};
        
        _translation = translation;
        _scale = scale;
        _rotation = rotation;
        _lightSource = engineModelProperties.lightSource;

        NSLog(@"light source: %@", NSStringFromLPPoint(self.lightSource));
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
            float faceIndex1 =engineModelProperties.faces[(face * 3) + 0];
            float faceIndex2 =engineModelProperties.faces[(face * 3) + 1];
            float faceIndex3 =engineModelProperties.faces[(face * 3) + 2];

            _faces[face] = LPPointMake(faceIndex1,
                                      faceIndex2,
                                      faceIndex3);
            _normals[face] = [LPEngineTransforms calculateSurfaceNormalWithPlane:LPTriangleMake(_vertices[(NSInteger)faceIndex1], _vertices[(NSInteger)faceIndex2], _vertices[(NSInteger)faceIndex3])];
        }
        
        [self printVertex];
        [self printFaces];
        [self printNormals];
        _centerChanged = YES;
        [self findVertexCenter];
        
    }
    
    return self;
}

- (void)draw:(LPEngineDrawStyle)drawStyle {
    LPEnginePrimitives *prim = [LPEnginePrimitives sharedManager];
    if (drawStyle == LPEngineDrawSolid) {
//        NSLog(@"==STARTING FRAME==");
        for(int face = 0; face < self.engineModelProperties.faceCount; face++) {
            static NSInteger red;
            static NSInteger green;
            static NSInteger blue;
            red = (NSInteger)(self.lightFactors[face] * 40.0 + 150);
            green = (NSInteger)((self.lightFactors[face] * 40.0) + 150);
            blue = (NSInteger)((self.lightFactors[face] * 40.0) + 150);
            red = red > 255? 255 : red;
            green = green > 255 ? 255 : green;
            blue = blue > 255 ? 255 : blue;
//            NSLog(@"color for face with lightfactor %0.2f red: %li green: %li blue: %li",self.lightFactors[face] ,red,green,blue);
            [prim setColorWithRed:red Green:green Blue:blue];
            float *point = (float*)&self.faces[face];
            [prim drawTriangleAtPoint1:&self.transformedVertices[(NSInteger)*(point + 0)]
                                Point2:&self.transformedVertices[(NSInteger)*(point + 1)]
                                Point3:&self.transformedVertices[(NSInteger)*(point + 2)]];
            
        }
    } else {
    }
}


- (void)findVertexCenter {
    static LPPoint vertexCheck = {};
    if (self.centerChanged) {
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
        
        
//        NSLog(@"Vertex Center at x: %0.2f y: %0.2f x: %0.2f",center.x,center.y,center.z);
        
        vertexCheck = self.translation;
        
        self.center = center;
        self.centerChanged = NO;
    }

}

- (void)rotateWithVector:(LPPoint)rotationVector {
    LPPoint tempRotation = self.rotation;
    tempRotation.x += rotationVector.x;
    tempRotation.y += rotationVector.y;
    tempRotation.z += rotationVector.z;
    self.rotation = tempRotation;
//    NSLog(@"New Rotation State: x %0.2f y %0.2f z %0.2f",self.rotation.x, self.rotation.y, self.rotation.z);
    self.centerChanged = TRUE;
}

- (void)translateWithVector:(LPPoint)translationVector {
    LPPoint tempTranslation = self.translation;
    tempTranslation.x += translationVector.x;
    tempTranslation.y += translationVector.y;
    tempTranslation.z += translationVector.z;
    self.translation = tempTranslation;
    self.centerChanged = TRUE;
}

- (void)scaleWithVector:(LPPoint)scaleVector {
    LPPoint tempScale = self.scale;
    tempScale.x += scaleVector.x;
    tempScale.y += scaleVector.y;
    tempScale.z += scaleVector.z;
    if (tempScale.x <= 0.0 ||
        tempScale.y <= 0.0 ||
        tempScale.z <= 0.0) {
        NSLog(@"cannot scale below 0");
    } else {
        self.scale = tempScale;
    }
    self.centerChanged = TRUE;
}

- (void)transformVertices {
    for (int vertex = 0; vertex < self.vertexCount; vertex++) {
        static LPPoint temp;
        temp = self.vertices[vertex];
        temp = [LPEngineTransforms translatePoint:temp WithVector:self.translation];
        temp = [LPEngineTransforms scalePoint:temp fromPoint:self.center WithVector:self.scale];
        temp = [LPEngineTransforms rotateAtXAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.x];
        temp = [LPEngineTransforms rotateAtYAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.y];
        temp = [LPEngineTransforms rotateAtZAxis:self.rotationAxis ForPoint:temp AtAngle:self.rotation.z];
        self.transformedVertices[vertex] = temp;
        
    }
    // calculate light for each face before the
    for (int face = 0; face < self.faceCount; face++) {
        float faceIndex1 = self.faces[face].x;
        float faceIndex2 = self.faces[face].y;
        float faceIndex3 = self.faces[face].z;
        _transformedNormals[face] = [LPEngineTransforms calculateSurfaceNormalWithPlane:LPTriangleMake(_transformedVertices[(NSInteger)faceIndex1], _transformedVertices[(NSInteger)faceIndex2], _transformedVertices[(NSInteger)faceIndex3])];
        //        self.lightFactors[face] = [self findLightFactor:self.transformedNormals[face] ];
        self.lightFactors[face] = [self findLightFactor:_transformedNormals[face] ];

    }
//    [self printLightFactors];
    
//    for (int vertex = 0; vertex < self.vertexCount; vertex++) {
//        static LPPoint temp;
//        temp = self.transformedVertices[vertex];
//        //EnginePrimitives *primitives = [EnginePrimitives sharedManager];
//        
//        temp = [LPEngineTransforms projectionTransformWithPoint:temp withCamera:[[LPEnginePrimitives sharedManager] camera]];
//        self.transformedVertices[vertex] = temp;
//    }
    
}

- (float)findLightFactor:(LPPoint)normal {
    return pointDotProduct(normal, self.lightSource);
}

- (void)resetTransforms {
    LPPoint point = {.x=0, .y=0, .z=0};
    self.translation = point;
    self.rotation = point;
    self.rotationAxis = self.center;
    LPPoint scalePoint = {.x=1.0, .y=1.0, .z=1.0};
    self.scale = scalePoint;
    self.centerChanged = TRUE;
}



- (void)printVertex {
    NSLog(@"--VERTICES-- [vertex count: %li]",(long)self.vertexCount);
    for (int vertex = 0; vertex < self.vertexCount; vertex++) {
        NSLog(@"%@",NSStringFromLPPoint(self.vertices[vertex]));
    }
}
- (void)printFaces {
    NSLog(@"--FACES-- [face count: %li]",(long)self.faceCount);
    for (int face = 0; face < self.engineModelProperties.faceCount; face++) {
        NSLog(@"%@",NSStringFromLPPoint(self.faces[face]));
    }
}

- (void)printNormals {
    NSLog(@"--NORMALS-- [normal count: %li]",(long)self.faceCount);
    for (int face = 0; face < self.faceCount; face++) {
        NSLog(@"%@",NSStringFromLPPoint(self.normals[face]));
    }
}

- (void)printLightFactors {
    NSLog(@"--LIGHT FACTORS-- [normal count: %li]",(long)self.faceCount);
    for (int face = 0; face < self.faceCount; face++) {
        NSLog(@"%0.2f",_lightFactors[face]);
    }
}

@end
