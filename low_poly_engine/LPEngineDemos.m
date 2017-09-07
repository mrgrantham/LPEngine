
//  EngineDemos.m
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPEnginePrimitives.h"
#import "LPEngineTransforms.h"
#import "LPEngineDemos.h"
#import "LPEngineModel.h"
#import "LPEngineModelInterface.h"
#import "Arwing.h"

@implementation LPEngineDemos

+ (id) sharedManager {
    static LPEnginePrimitives *sharedEnginePrimitives = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnginePrimitives = [[self alloc] init];
    });
    return sharedEnginePrimitives;
}

- (id) init {
    if (self = [super init]) {
        if (_demoScene == nil) {
            // Configure model
            LPEngineModelInterface *modelProperties = [[LPEngineModelInterface alloc] init];
            modelProperties.vertices = (int16_t*)arwingVertices;
            modelProperties.vertexCount = sizeof(arwingVertices) / (sizeof(int16_t) * 3);
            modelProperties.faces = (int16_t*)arwingFaces;
            modelProperties.faceCount = sizeof(arwingFaces) / (sizeof(int16_t) * 3);
            NSLog(@"light source: %@", NSStringFromLPPoint(modelProperties.lightSource));
            LPEngineModel *arwing = [[LPEngineModel alloc] initWithProperties:modelProperties];
            
            //Create scene
            _demoScene = [[LPEngineScene alloc] init];
            LPPoint lightSource = {.x=0.5, .y=0.8, .z=0.5};
            _demoScene.lightSource = lightSource;
            
            // Place Model in Scene
            _arwingID = [_demoScene addModel:arwing];
            
            NSInteger otherArwingID = [_demoScene addModel:arwing];

            LPEnginePrimitives *prim = [LPEnginePrimitives sharedManager];

            // Position model in scene
            LPPoint translation = {};
            translation.x = prim.virtualWidth / 2;
            translation.y = prim.virtualHeight / 4;
            translation.z = -1500;
            _demoScene.models[_arwingID].transformState.translation = translation;
            LPPoint scale = {.x=1.0, .y=1.0, .z=1.0};
            _demoScene.models[_arwingID].model.scale = scale;
            _demoScene.models[_arwingID].model.centerChanged = YES;
            [_demoScene.models[_arwingID].model findVertexCenter];
            
            translation.x = prim.virtualWidth / 3;
            translation.y = prim.virtualHeight / 5;
            translation.z = -2000;
            _demoScene.models[otherArwingID].transformState.translation = translation;
            
            
            _rotateContinuous = NO;
            
            
            
            
            // break in to separate method later
            LPPoint rotateVector = {};
            rotateVector.y = 3*M_PI/4;
            [self resetArwing];
            [self resetFlight];
            [_demoScene.models[_arwingID].model rotateWithVector:rotateVector];
            
//            _rotationRadians = {};
//            _translationRadians = {};
//            _scaleRadians = {};
        }
    }
    return self;
}

- (void)triangleDemo {
    LPEnginePrimitives *prim = [LPEnginePrimitives sharedManager];
    
    static LPPoint _2Daxis;
    static float currentRadian = 0.0;
    static LPTriangle testTriangle;
    testTriangle = LPTriangleMake(LPPointMake(40,40,0), LPPointMake(120,60,0), LPPointMake(90,120,0));
    _2Daxis.x = [prim virtualWidth] / 2;
    _2Daxis.y = [prim virtualHeight] / 2;


    static LPTriangle tempTriangle = {0};
    
    tempTriangle.p1 = [LPEngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p1
                                               AtAngle:currentRadian];
    tempTriangle.p2 = [LPEngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p2
                                               AtAngle:currentRadian];
    tempTriangle.p3 = [LPEngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p3
                                               AtAngle:currentRadian];

    [prim setColorWithRed:255 Green:0 Blue:255];
    [prim drawTriangle:&tempTriangle];
    
    currentRadian += 0.01;
    currentRadian = currentRadian >= (M_PI * 2) ? currentRadian - (M_PI * 2): currentRadian;
}

- (void)arwingDemo {
    static LPPoint translationVector = {};

    
    if (self.rotateContinuous) {
        static LPPoint rotationVector = {};
        rotationVector.y = 0.015;
        [self.demoScene.models[_arwingID].model rotateWithVector:rotationVector];
    }
    if (self.translateContinuous) {
        static float translationRadian = M_PI / 2;
        translationVector.x = (sin(translationRadian) * 50) ;
        [self.demoScene.models[_arwingID].model translateWithVector:translationVector];
        translationRadian += 0.1;
        translationRadian = translationRadian >= (M_PI * 2) ? translationRadian - (M_PI * 2): translationRadian;
    }
    if (self.scaleContinuous) {
        static float scaleRadian = 0.0;
        static LPPoint scaleVector = {};
        float sineValue = sin(scaleRadian);
//        NSLog(@"sineValue: %0.2f", sineValue);
        scaleVector.x = sineValue * 0.02;
        scaleVector.y = sineValue * 0.02;
        scaleVector.z = sineValue * 0.02;

        [self.demoScene.models[_arwingID].model scaleWithVector:scaleVector];
        scaleRadian += 0.1;
        scaleRadian = scaleRadian >= (M_PI * 2) ? scaleRadian - (M_PI * 2): scaleRadian;
    }
    if (self.flyContinuous) {
        static LPPoint translateVector = {};
        float sineValue = sin(self.translationRadians.y - (M_PI/2));
//        NSLog(@"Translation sineValue: %0.2f", sineValue);
        translateVector.x = 0;
        translateVector.y = sineValue * 5;
        translateVector.z = 0;
        [self.demoScene.models[_arwingID].model translateWithVector:translateVector];
        
        sineValue = sin(self.rotationRadians.x + (1.22   *M_PI));
//        NSLog(@"Rotation sineValue: %0.2f",sineValue);
        static LPPoint rotateVector = {};
        //        NSLog(@"sineValue: %0.2f", sineValue);
        rotateVector.x = sineValue * 0.17;
        rotateVector.y = self.demoScene.models[_arwingID].model.rotation.y;
        rotateVector.z = 0;
        self.demoScene.models[_arwingID].model.rotation = rotateVector;
        
        
        LPPoint temp = self.translationRadians;
        temp.y += 0.02;
        temp.y = temp.y >= (M_PI * 2) ? temp.y - (M_PI * 2): temp.y;
        self.translationRadians = temp;
        
        temp = self.rotationRadians;
        temp.x += 0.02;
        temp.x = temp.x >= (M_PI * 2) ? temp.x - (M_PI * 2): temp.x;
        self.rotationRadians = temp;
    }
    
    [[LPEnginePrimitives sharedManager] resetDepthBuffer];
    [self.demoScene.models[_arwingID].model findVertexCenter];
    self.demoScene.models[_arwingID].model.rotationAxis = self.demoScene.models[_arwingID].model.center;
    [self.demoScene.models[_arwingID].model transformVertices];
    
    [self.demoScene draw];
    
}

- (void) resetArwing {
    self.scaleContinuous = NO;
    self.rotateContinuous = NO;
    self.translateContinuous = NO;
    [self.demoScene.models[_arwingID].model resetTransforms];
    LPPoint scale = {.x=1.0, .y=1.0, .z=1.0};
    self.demoScene.models[_arwingID].model.scale = scale;
    LPPoint translation = {};
    translation.x = 0;
    translation.y = 0;
    translation.z = 0;
    self.demoScene.models[_arwingID].transformState.translation = translation;
}

- (void) resetFlight {
    LPPoint resetPoint = {};
    self.scaleRadians = resetPoint;
    
    //resetPoint.y = M_PI/8;
    self.translationRadians = resetPoint;

    resetPoint.x = M_PI/2;
    self.rotationRadians = resetPoint;
}

@end
