//
//  EnginePrimitives.m
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "EnginePrimitives.h"

static NSSize canvas;

static int16_t pixelWidth;
static float virtualWidth;
static float virtualHeight;

// notification to stop actions due to error
static BOOL pauseFlag;
static int16_t *depthBuffer;

// Triangle helper structs
static LPPoint DTB; // calculating Top-Bottom
static LPPoint DTM; // calculating Top-Middle
static LPPoint DMB; // calculating Middle-Bottom

static int16_t DMaxTM;
static int16_t DMaxTB;
static int16_t DMaxMB;

static int16_t remainingSteps;

static LPPoint STB; // calculating Top-Bottom
static LPPoint STM; // calculating Top-Middle
static LPPoint SMB; // calculating Middle-Bottom

// error calculation
static LPPoint ETB; // calculating Top-Bottom Error
static LPPoint ETM; // calculating Top-Middle Error
static LPPoint EMB; // calculating Middle-Bottom Error

// temp error holder for comparisons
static int16_t E2L;
static int16_t E2R;

static LPPoint top;
static LPPoint middle;
static LPPoint bottom;

static int16_t YL,YR, XL, XR, ZL, ZR;
static int16_t setup_time;
static int16_t draw_time;

static vector_float4 color;

LPPoint LPPointMake(int16_t x, int16_t y, int16_t z) {
    LPPoint newPoint;
    newPoint.x = x;
    newPoint.y = y;
    newPoint.z = z;
    return newPoint;
}

LPTriangle LPTriangleMake(LPPoint p1, LPPoint p2, LPPoint p3) {
    LPTriangle tempTriangle;
    tempTriangle.p1 = p1;
    tempTriangle.p2 = p2;
    tempTriangle.p3 = p3;
    return tempTriangle;

}

@implementation EnginePrimitives

- (void) clearVertices {
    if (_vertexData != nil) {
        memset(_vertexData, 0, sizeof(Vertex) * _vertexDataSize);
        _vertexDataSize = 0;
    }
}

- (Vertex *)addVertex:(Vertex)vertex To:(Vertex*)source OfSize:(NSInteger*)sourceSize {
    static NSInteger multiplier = 0;
    static const NSInteger sizeIncreaseMargin = 300000;
    Vertex *tempSource;
    if (source == nil) {
        NSLog(@"Initial Allocation");
        source = malloc(sizeof(Vertex) * sizeIncreaseMargin * (multiplier+1));
        multiplier++;
    } else if (*sourceSize >= (sizeIncreaseMargin * multiplier)) {
        tempSource = malloc(sizeof(Vertex) * sizeIncreaseMargin * (multiplier + 1));
        memcpy(tempSource, source, *sourceSize * sizeof(Vertex));
        free(source);
        source = tempSource;
        multiplier++;
        NSLog(@"source size %li",(long)*sourceSize);
    }
    memcpy(&source[*sourceSize], &vertex, sizeof(Vertex));

    
    (*sourceSize)++;
    return source;
}

+ (id) sharedManager {
    static EnginePrimitives *sharedEnginePrimitives = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnginePrimitives = [[self alloc] init];
    });
    return sharedEnginePrimitives;
}

- (id) init {
    self = [super init];
    self.vertexData = nil;
    self.vertexDataSize = 0;
    [self resetDepthBuffer];
    
    return self;
}

- (void) drawPixelAtX:(NSInteger)x Y:(NSInteger)y {
    
    // just adds pixel vertex to vertex_data for 2 triangles
    static Vertex upperLeft;
    static Vertex upperRight;
    static Vertex lowerLeft;
    static Vertex lowerRight;
    
    
    upperLeft.position  = (vector_float4){  ((( x * pixelWidth )/  canvas.width) * 2) - 1.0,
                                            ((( y * pixelWidth )/ canvas.height) * 2) - 1.0,
                                                                            0,
                                                                          1.0};
    
    upperRight.position = (vector_float4){ (((( x * pixelWidth ) + pixelWidth ) /  canvas.width) * 2) - 1.0,
                                                            (((y * pixelWidth ) / canvas.height) * 2) - 1.0,
                                                                                            0,
                                                                                          1.0};
    
    lowerLeft.position  = (vector_float4){  ((( x * pixelWidth ) /  canvas.width) * 2) - 1.0,
                            ((( ( y * pixelWidth ) + pixelWidth) / canvas.height) * 2) - 1.0,
                                                                             0,
                                                                           1.0};
    
    lowerRight.position = (vector_float4){ (((( x * pixelWidth ) + pixelWidth) / canvas.width) * 2) - 1.0,
                                          (((( y * pixelWidth ) + pixelWidth )/ canvas.height) * 2) - 1.0,
                                                                                          0,
                                                                                        1.0};
    
    upperLeft.color     = color;
    upperRight.color    = color;
    lowerLeft.color     = color;
    lowerRight.color    = color;
    
    // Upper Left Tiangle
    self.vertexData = [self addVertex:upperLeft To:self.vertexData OfSize:&_vertexDataSize];
    self.vertexData = [self addVertex:upperRight To:self.vertexData OfSize:&_vertexDataSize];
    self.vertexData = [self addVertex:lowerLeft To:self.vertexData OfSize:&_vertexDataSize];

    // Lower Right Triangle
    self.vertexData = [self addVertex:lowerRight To:self.vertexData OfSize:&_vertexDataSize];
    self.vertexData = [self addVertex:upperRight To:self.vertexData OfSize:&_vertexDataSize];
    self.vertexData = [self addVertex:lowerLeft To:self.vertexData OfSize:&_vertexDataSize];
}

- (void) setColorWithRed:(NSInteger)red Green: (NSInteger) green Blue:(NSInteger)blue {
    color = (vector_float4){(float)red/255.0f,(float)green/255.0f,(float)blue/255.0f,1.0};
    
}

- (CGSize) canvasSize {
    return canvas;
}

- (void) setPixelWidth:(NSInteger)pxWidth {
    pixelWidth = pxWidth;
}

- (void) setVirtualWidth:(NSInteger)width {
    canvas.width = width * pixelWidth;
    virtualWidth = width;
}

- (void) setVirtualHeight:(NSInteger) height {
    canvas.height = height * pixelWidth;
    virtualHeight = height;
}

- (float) virtualWidth {
    return virtualWidth;
}

- (float) virtualHeight {
    return virtualHeight;
}

- (void) resetDepthBuffer {
    depthBuffer = (int16_t *)malloc(virtualWidth * virtualHeight * sizeof(int16_t));
    memset(depthBuffer, 0x80, virtualWidth * virtualHeight * sizeof(int16_t));
}

- (void) drawHorizontalLineAtLeftPoint:(LPPoint) leftPoint RightPoint:(LPPoint)rightPoint {
    
}

- (void) drawHorizontalLineAtLeftX:(NSInteger)leftX LeftY:(NSInteger)leftY  RightX:(NSInteger)rightX  RightY:(NSInteger)rightY {
    
}



- (void) drawTriangleAtPoint1:(LPPoint*) p1 Point2:(LPPoint*) p2 Point3:(LPPoint*) p3 {
    //setup_time = millis();
    
    if(p1->y < p2->y) {
        top = *p1;
        middle = *p2;
    } else {
        top = *p2;
        middle = *p1;
    }
    
    if(p3->y <= top.y) {
        bottom = middle;
        middle = top;
        top = *p3;
    } else if(p3->y < middle.y) {
        bottom = middle;
        middle = *p3;
    } else {
        bottom = *p3;
    }
    //printf(  "TOP (" << nfs(top.x,3) << "," << nfs(top.y,3) << "," << nfs(top.z,3) <<
    //        ") MID (" << nfs(middle.x,3) << "," << nfs(middle.y,3) << "," << nfs(middle.z,3) <<
    //        ") BOT (" << nfs(bottom.x,3) << "," << nfs(bottom.y,3) << "," << nfs(bottom.z,3) << ") ");
    
    
    
    int16_t edge = (middle.x - top.x) * (bottom.y - top.y) - (middle.y-top.y) * (bottom.x - top.x);
    
    
    DTM.x = top.x > middle.x ? top.x - middle.x : middle.x - top.x;
    DTM.y = middle.y - top.y;
    DTM.z = top.x > middle.z ? top.z - middle.z : middle.z - top.z;
    
    DTB.x = top.x > bottom.x ? top.x - bottom.x : bottom.x - top.x;
    DTB.y = bottom.y-top.y;
    DTB.z = top.z > bottom.z ? top.z - bottom.z : bottom.z - top.z;
    
    DMB.x = middle.x > bottom.x ? middle.x - bottom.x : bottom.x - middle.x;
    DMB.y = bottom.y - middle.y;
    DMB.z = middle.z > bottom.z ? middle.z - bottom.z : bottom.z - middle.z;
    
    DMaxTM = DTM.x > DTM.y ? (DTM.x > DTM.z ? DTM.x : DTM.z) : (DTM.y > DTM.z ? DTM.y : DTM.z);
    DMaxTB = DTB.x > DTB.y ? (DTB.x > DTB.z ? DTB.x : DTB.z) : (DTB.y > DTB.z ? DTB.y : DTB.z);
    DMaxMB = DMB.x > DMB.y ? (DMB.x > DMB.z ? DMB.x : DMB.z) : (DMB.y > DMB.z ? DMB.y : DMB.z);
    
    // Calculate steps from start to destination
    
    STM.x = (top.x < middle.x) ? 1 : -1;
    STM.y = 1;
    STM.z = (top.z < middle.z) ? 1 : -1;
    
    STB.x = (top.x < bottom.x) ? 1 : -1;
    STB.y = 1;
    STB.z = (top.z < bottom.z) ? 1 : -1;
    
    SMB.x = (middle.x < bottom.x) ? 1 : -1;
    SMB.y = 1;
    SMB.z = (middle.z < bottom.z) ? 1 : -1;
    
    
    // calculate starting error
    // initiale error is half of which ever metrics x, y or z
    // contributes most greatly to the slope
    ETM.x = DMaxTM >> 1;
    ETM.y = DMaxTM >> 1;
    ETM.z = DMaxTM >> 1;
    
    ETB.x = DMaxTB >> 1;
    ETB.y = DMaxTB >> 1;
    ETB.z = DMaxTB >> 1;
    
    EMB.x = DMaxMB >> 1;
    EMB.y = DMaxMB >> 1;
    EMB.z = DMaxMB >> 1;
    
    // triangle always starts at a single point regardless of direction
    YL = top.y;
    YR = top.y;
    XL = top.x;
    XR = top.x;
    ZL = top.z;
    ZR = top.z;
    //text("SETUP TIME: " + (millis() - setup_time), 850,60);
    //draw_time = millis();
    
    if(edge > 0) {  // right pointing triangle
        
        // top half of triangle
        for(;;){
            if(YL == YR) {
                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                if (YL >= middle.y) break;
            }
            if(YL <= YR) {        // if the left line < right increment only left
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; }
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XR += STM.x; }
                ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YR += STM.y; }
                ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZR += STM.z; }
            }
        }
        // bottom half of triangle
        YR = middle.y;
        XR = middle.x;
        ZR = middle.z;
        
        for(;;){
            if(YL == YR) {
                // cout << "RIGHT BOTTOM XL " << XL << " XR " << XR << " ZL " << ZL << " ZR " << ZR << " Y " << YL << endl;
                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];

                if (YL >= bottom.y) break;
            }
            if(YL <= YR) {        // if the left line < right increment only left
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; }
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XR += SMB.x; }
                EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YR += SMB.y; }
                EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZR += SMB.z; }
            }
        }
    }
    else { // Case with middle point on left side of triangle
        // top half of triangle
        for(;;){
            if(YL == YR) {
                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                if (YR >= middle.y) break;
            }
            if(YL <= YR) {        // if the left line < right increment only left
                ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XL += STM.x; }
                ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YL += STM.y; }
                ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZL += STM.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y; }
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
            }
        }
        // bottom half of triangle
        YL = middle.y;
        XL = middle.x;
        ZL = middle.z;
        for(;;){
            if(YL == YR) {
                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                if (YR >= bottom.y) break;
            }
            if(YL <= YR) {        // if the left line < right increment only left
                EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XL += SMB.x; }
                EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YL += SMB.y; }
                EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZL += SMB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y; }
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
            }
        }
    }
    //text("DRAW TIME: " + (millis() - draw_time), 850,80);
}
- (void) drawTriangleAtCopiedPoint1:(LPPoint) p1 Point2:(LPPoint) p2 Point3:(LPPoint) p3 {
    [self drawTriangleAtPoint1:&p1 Point2:&p2 Point3:&p3];
}

- (void) drawTriangleAtX1:(NSInteger)x1 Y1:(NSInteger)y1 X2:(NSInteger)x2 Y2:(NSInteger)y2 X3:(NSInteger)x3 Y3:(NSInteger)y3 {
    
}

- (void) drawTriangle:(LPTriangle*) triangle {
    [self drawTriangleAtPoint1:&triangle->p1 Point2:&triangle->p2 Point3:&triangle->p3];
}

- (void) drawScanLineAtLeftX:(NSInteger)leftX RightX:(NSInteger)rightX LeftZ:(NSInteger)leftZ RightZ:(NSInteger)rightZ Y:(NSInteger)y {
    
    static int16_t DeltaX;
    static int16_t DeltaZ;
    static int16_t StepX;
    static int16_t StepZ;
    static int16_t Error;
    static int16_t ErrorTmp;
    static int16_t x;
    static int16_t z;
    static long int depthBufferIndex; // needs to be a huge number. uint16_t might be enough i havent done the calculations. but int16_t definitely isnt
    
    if(leftZ < 0 || rightZ < 0) {
        pauseFlag = true;
        
        //return;
    }
    DeltaX = leftX > rightX ? leftX - rightX : rightX - leftX;
    DeltaZ = -(leftZ > rightZ ? leftZ - rightZ : rightZ - leftZ);
    
    StepX = leftX < rightX ? 1 : -1;
    StepZ = leftZ < rightZ ? 1 : -1;
    
    //Error = (DeltaX > DeltaZ ? DeltaX : -DeltaZ) >> 1;
    Error = DeltaX + DeltaZ;
    
    x=leftX;
    z=leftZ;

    
    for(;;) {
        if(z > 0) {
            //cout << "Z went negative" << endl;
            //System.exit(1);
            
            pauseFlag = true;
            break;
        }
        if (y < 0) {
            // stuff
            NSLog(@"Y is negative %li", y);
        }
        if (x < 0) {
//            NSLog(@"X is negative %i", x);
        }
        depthBufferIndex = x + (y * self.virtualWidth);

//        NSLog(@"depthBuffer[%i]: %i z: %i", depthBufferIndex, depthBuffer[depthBufferIndex], z );
        if (z >= depthBuffer[depthBufferIndex] && z <= 0 && x >= 0 && x < self.virtualWidth && y >= 0 && y < self.virtualHeight) {
            [self drawPixelAtX:x Y:y];
            depthBuffer[depthBufferIndex] = z;
        } else if ((z < depthBuffer[depthBufferIndex] && depthBuffer[depthBufferIndex] == (int16_t)0x8080) || z > 0) {
            NSLog(@"Z out of bounds");
        }
        if(x == rightX) {break;}
        ErrorTmp = 2 * Error;
        if (ErrorTmp >= DeltaZ) { Error += DeltaZ; x += StepX; }
        if (ErrorTmp <= DeltaX) { Error += DeltaX; z += StepZ; }
    }
}



@end
