//
//  EnginePrimitives.m
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LPEnginePrimitives.h"

static CGSize canvas;

static int16_t pixelWidth;
static float virtualWidth;
static float virtualHeight;

static vector_float4 color;
static float pointSize = 10;
static int16_t *depthBuffer;
static NSInteger vertexMemoryAllocationSize=0;

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

NSString *NSStringFromLPPoint(LPPoint point) {
    NSString *newString = [NSString stringWithFormat:@"{ %0.2f, %0.2f, %0.2f }",point.x,point.y,point.z];
    return newString;
}

LPPoint pointSubtract(LPPoint p1, LPPoint p2) {
    LPPoint temp = {};
    temp.x = p1.x - p2.x;
    temp.y = p1.y - p2.y;
    temp.z = p1.z - p2.z;
    return temp;
    
}

LPPoint pointCrossProduct(LPPoint p1, LPPoint p2) {
    LPPoint result;
    
    result.x = p1.y * p2.z - p1.z * p2.y;
    result.y = p1.z * p2.x - p1.x * p2.z;
    result.z = p1.x * p2.y - p1.y * p2.x;
    
    return result;
}

float pointDotProduct(LPPoint p1, LPPoint p2) {
    float result;
    
    result = p1.x * p2.x + p1.y * p2.y + p1.z * p2.z;
    
    return result;
}

LPPoint normalize(LPPoint point) {
    
    float absX = fabsf(point.x);
    float absY = fabsf(point.y);
    float absZ = fabsf(point.z);
    
    float max = (absX > absY) ? (absZ > absX) ? absZ : absX : (absZ > absY) ? absZ : absY;
//    NSLog(@"max %0.2f",max);
    point.x = point.x / max;
    point.y = point.y / max;
    point.z = point.z / max;
    
    return point;
}

static Vertex *vertexData;
static NSInteger vertexDataSize;

void* AllocateVirtualMemory(size_t size)
{
    char*          data;
    kern_return_t   err;
    
    // In debug builds, check that we have
    // correct VM page alignment
    check(size != 0);
    check((size % 4096) == 0);
    
    // Allocate directly from VM
    err = vm_allocate(  (vm_map_t) mach_task_self(),
                      (vm_address_t*) &data,
                      size,
                      VM_FLAGS_ANYWHERE);
//    err = posix_memalign((void**)&data, 4096, size);

    // Check errors
    check(err == KERN_SUCCESS);
    if(err != KERN_SUCCESS)
    {
        data = NULL;
    }
    
    return data;
}

NSInteger getVertexMemoryAllocationSize() {
    return vertexMemoryAllocationSize;
}


NS_INLINE Vertex *addVertex(Vertex vertex,Vertex *source,NSInteger *sourceSize) {
    static NSInteger multiplier = 0;
    static const NSInteger sizeIncreaseMargin = 4096*60;
    Vertex *tempSource;
    if (source == nil) {
        NSLog(@"Initial Allocation");
        source = AllocateVirtualMemory(sizeof(Vertex) * sizeIncreaseMargin * (multiplier+1));
        vertexMemoryAllocationSize = sizeof(Vertex) * sizeIncreaseMargin * (multiplier+1);
        multiplier++;
    } else if (*sourceSize >= (sizeIncreaseMargin * multiplier)) {
        tempSource = malloc(sizeof(Vertex) * sizeIncreaseMargin * (multiplier + 1));
        memcpy(tempSource, source, *sourceSize * sizeof(Vertex));
//        free(source);
        vm_deallocate(mach_task_self(),(unsigned int)source, *sourceSize * sizeof(Vertex));
        vertexMemoryAllocationSize = sizeof(Vertex) * sizeIncreaseMargin * (multiplier + 1);
        source = tempSource;
        multiplier++;
        NSLog(@"source size %li",(long)*sourceSize);
    }
    vertex.pointsize = pointSize;
    memcpy(&source[*sourceSize], &vertex, sizeof(Vertex));
    
    
    (*sourceSize)++;
    return source;
}

NS_INLINE void drawPixelAt(NSInteger x, NSInteger y) {
    // just adds pixel vertex to vertex_data for 2 triangles
    static Vertex point;
    
    point.position = (vector_float4){((( (x * pixelWidth) + (pixelWidth>>1) )/  canvas.width) * 2) - 1.0,((( (y * pixelWidth)  + (pixelWidth>>1)  )/ canvas.height) * 2) - 1.0, 0, 1.0};
    point.color = color;
    point.pointsize = pointSize;
    vertexData = addVertex(point, vertexData, &vertexDataSize);

}

NS_INLINE void drawScanLine(int32_t leftX, int32_t rightX, int32_t leftZ, int32_t rightZ, int32_t y) {
    
    //- (void) drawScanLineAtLeftX:(NSInteger)leftX RightX:(NSInteger)rightX LeftZ:(NSInteger)leftZ RightZ:(NSInteger)rightZ Y:(NSInteger)y {
    
    static int32_t DeltaX;
    static int32_t DeltaZ;
    static int32_t StepX = 1; // No need to calculate since always from left to right
    static int32_t StepZ;
    static int32_t DeltaMax;
    static int32_t ErrorX;
    static int32_t ErrorZ;
    static long int depthBufferIndex; // needs to be a huge number. uint16_t might be enough i havent done the calculations. but int16_t definitely isnt
    
    if (leftX > rightX) {
        leftX = rightX;
    }
    DeltaX = rightX - leftX;
    DeltaZ = abs(rightZ - leftZ);
    
    StepZ = leftZ < rightZ ? 1 : -1;
    
    DeltaMax = DeltaX < DeltaZ ? DeltaZ : DeltaX;
    
    ErrorX = DeltaMax >> 1;
    ErrorZ = DeltaMax >> 1;
    //    ErrorX = 0;
    //    ErrorZ = 0;
    
    
    for(;;) {
        
        depthBufferIndex = leftX + (y * virtualWidth);
        
        
        if (leftX >= 0 && leftX < virtualWidth && y >= 0 && y < virtualHeight && leftZ >= depthBuffer[depthBufferIndex] && leftZ <= 0) {
            drawPixelAt(leftX, y);
            depthBuffer[depthBufferIndex] = leftZ;
        }
        
        if(leftX == rightX) {
            break;
        }
        
        ErrorX -= DeltaX; if (ErrorX < 0) { ErrorX += DeltaMax; leftX += StepX;}
        ErrorZ -= DeltaZ; if (ErrorZ < 0) { ErrorZ += DeltaMax; leftZ += StepZ;}
        
        
    }
}



@implementation LPEnginePrimitives

- (void) clearVertices {
    if (vertexData != NULL) {
        memset(vertexData, 0, sizeof(Vertex) * vertexDataSize);
        vertexDataSize = 0;
    }
}

//- (Vertex *)addVertex:(Vertex)vertex To:(Vertex*)source OfSize:(NSInteger*)sourceSize {
//    static NSInteger multiplier = 0;
//    static const NSInteger sizeIncreaseMargin = 300000;
//    Vertex *tempSource;
//    if (source == nil) {
//        NSLog(@"Initial Allocation");
//        source = malloc(sizeof(Vertex) * sizeIncreaseMargin * (multiplier+1));
//        multiplier++;
//    } else if (*sourceSize >= (sizeIncreaseMargin * multiplier)) {
//        tempSource = malloc(sizeof(Vertex) * sizeIncreaseMargin * (multiplier + 1));
//        memcpy(tempSource, source, *sourceSize * sizeof(Vertex));
//        free(source);
//        source = tempSource;
//        multiplier++;
//        NSLog(@"source size %li",(long)*sourceSize);
//    }
//    vertex.pointsize = pointSize;
//    memcpy(&source[*sourceSize], &vertex, sizeof(Vertex));
//
//    
//    (*sourceSize)++;
//    return source;
//}

- (Vertex *)vertexData {
    return vertexData;
}

- (NSInteger)vertexDataSize {
    return vertexDataSize;
}

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
        depthBuffer = NULL;
        vertexData = NULL;
        vertexDataSize = 0;
        virtualWidth = 0;
        virtualHeight = 0;
        [self resetDepthBuffer];
    }
    return self;
}

//- (void) drawPixelAtX:(NSInteger)x Y:(NSInteger)y {
//    
//    // just adds pixel vertex to vertex_data for 2 triangles
//    static Vertex upperLeft;
//    static Vertex upperRight;
//    static Vertex lowerLeft;
//    static Vertex lowerRight;
//    
//    
//    upperLeft.position  = (vector_float4){  ((( x * pixelWidth )/  canvas.width) * 2) - 1.0,
//                                            ((( y * pixelWidth )/ canvas.height) * 2) - 1.0,
//                                                                            0,
//                                                                          1.0};
//    
//    upperRight.position = (vector_float4){ (((( x * pixelWidth ) + pixelWidth ) /  canvas.width) * 2) - 1.0,
//                                                            (((y * pixelWidth ) / canvas.height) * 2) - 1.0,
//                                                                                            0,
//                                                                                          1.0};
//    
//    lowerLeft.position  = (vector_float4){  ((( x * pixelWidth ) /  canvas.width) * 2) - 1.0,
//                            ((( ( y * pixelWidth ) + pixelWidth) / canvas.height) * 2) - 1.0,
//                                                                             0,
//                                                                           1.0};
//    
//    lowerRight.position = (vector_float4){ (((( x * pixelWidth ) + pixelWidth) / canvas.width) * 2) - 1.0,
//                                          (((( y * pixelWidth ) + pixelWidth )/ canvas.height) * 2) - 1.0,
//                                                                                          0,
//                                                                                        1.0};
//    
//    upperLeft.color     = color;
//    upperRight.color    = color;
//    lowerLeft.color     = color;
//    lowerRight.color    = color;
//    
//    // Upper Left Tiangle
//    vertexData = addVertex(upperLeft, vertexData, &vertexDataSize);
//    vertexData = addVertex(upperRight, vertexData, &vertexDataSize);
//    vertexData = addVertex(lowerLeft, vertexData, &vertexDataSize);
//
//    // Lower Right Triangle
//    vertexData = addVertex(lowerRight, vertexData, &vertexDataSize);
//    vertexData = addVertex(upperRight, vertexData, &vertexDataSize);
//    vertexData = addVertex(lowerLeft, vertexData, &vertexDataSize);
//}
//
- (void) setColorWithRed:(NSInteger)red Green: (NSInteger) green Blue:(NSInteger)blue {
    color = (vector_float4){(float)red/255.0f,(float)green/255.0f,(float)blue/255.0f,1.0};
    
}

- (CGSize) canvasSize {
    return canvas;
}

- (void) setPixelWidth:(NSInteger)pxWidth {
    pixelWidth = pxWidth;
    float scaleFactor;
    scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
    NSLog(@"Scale Factor: %0.2f",scaleFactor);
    
    pointSize = ((canvas.height*scaleFactor)/virtualHeight);
}

- (void) setVirtualWidth:(NSInteger)width {
    canvas.width = width * pixelWidth;
    virtualWidth = width;
    float scaleFactor;
    scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
    NSLog(@"Scale Factor: %0.2f",scaleFactor);
    
    pointSize = ((canvas.height*scaleFactor)/virtualHeight);
}

- (void) setVirtualHeight:(NSInteger) height {
    canvas.height = height * pixelWidth;
    virtualHeight = height;
    
//    NSScreen *screen = [NSScreen mainScreen];
//    NSDictionary *description = [screen deviceDescription];
//    CGSize displayPixelSize = [[description objectForKey:NSDeviceSize] sizeValue];
//    CGSize displayPhysicalSize = CGDisplayScreenSize([[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
//    NSLog(@"displayPhysicalSize: %@ \n displayPixelSize: %@",NSStringFromSize(displayPhysicalSize),NSStringFromSize(displayPixelSize));
//    NSLog(@"DPI is %0.2f",(displayPixelSize.width / displayPhysicalSize.width) * 25.4f);
    
    float scaleFactor;
    scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
    NSLog(@"Scale Factor: %0.2f",scaleFactor);
    
    pointSize = ((canvas.height*scaleFactor)/virtualHeight);

}

- (float) virtualWidth {
    return virtualWidth;
}

- (float) virtualHeight {
    return virtualHeight;
}

- (void) resetDepthBuffer {
    if (depthBuffer == NULL && virtualHeight != 0 && virtualWidth != 0) {
        depthBuffer = (int16_t *)malloc(virtualWidth * virtualHeight * sizeof(int16_t));
    }
    if (virtualHeight != 0 && virtualWidth != 0) {
        memset(depthBuffer, 0x80, virtualWidth * virtualHeight * sizeof(int16_t));
    }
}

- (void)centerCamera {
    LPPoint camera = {};
    
    camera.x = virtualWidth / 2;
    camera.y = virtualHeight / 2;
    camera.z = 400;
    
    self.camera = camera;
}

- (void) drawHorizontalLineAtLeftPoint:(LPPoint) leftPoint RightPoint:(LPPoint)rightPoint {
    
}

- (void) drawHorizontalLineAtLeftX:(NSInteger)leftX LeftY:(NSInteger)leftY  RightX:(NSInteger)rightX  RightY:(NSInteger)rightY {
    
}



- (void) drawTriangleAtPoint1:(LPPoint*) p1 Point2:(LPPoint*) p2 Point3:(LPPoint*) p3 {
    //setup_time = millis();
    
    // Triangle helper structs
    static LPPoint DTB; // calculating Top-Bottom
    static LPPoint DTM; // calculating Top-Middle
    static LPPoint DMB; // calculating Middle-Bottom
    
    static int32_t DMaxTM;
    static int32_t DMaxTB;
    static int32_t DMaxMB;
    
    static LPPoint STB = {.x=0, .y=1, .z=0}; // calculating Top-Bottom
    static LPPoint STM = {.x=0, .y=1, .z=0}; // calculating Top-Middle
    static LPPoint SMB = {.x=0, .y=1, .z=0}; // calculating Middle-Bottom
    
    // error calculation
    static LPPoint ETB = {.x=0, .y=0, .z=0}; // calculating Top-Bottom Error
    static LPPoint ETM = {.x=0, .y=0, .z=0}; // calculating Top-Middle Error
    static LPPoint EMB = {.x=0, .y=0, .z=0}; // calculating Middle-Bottom Error
    
    static LPPoint top;
    static LPPoint middle;
    static LPPoint bottom;
    
    static int32_t YL,YR, XL, XR, ZL, ZR;
    
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
    
    
    
    float edge = (middle.x - top.x) * (bottom.y - top.y) - (middle.y-top.y) * (bottom.x - top.x);
    
    
    DTM.x = fabsf((NSInteger)(top.x - middle.x) == 0? 1 : (top.x - middle.x));
    DTM.y = fabsf((NSInteger)(middle.y - top.y) == 0? 1 : (middle.y - top.y));
    DTM.z = fabsf((NSInteger)(top.z - middle.z) == 0? 1 : (top.z - middle.z));
    
    DTB.x = fabsf((NSInteger)(top.x - bottom.x) == 0? 1 : (top.x - bottom.x));
    DTB.y = fabsf((NSInteger)(bottom.y-top.y) == 0? 1 : (bottom.y-top.y));
    DTB.z = fabsf((NSInteger)(top.z - bottom.z) == 0? 1 : (top.z - bottom.z));
    
    DMB.x = fabsf((NSInteger)(middle.x - bottom.x) == 0? 1 : (middle.x - bottom.x));
    DMB.y = fabsf((NSInteger)(bottom.y - middle.y) == 0? 1 : (bottom.y - middle.y));
    DMB.z = fabsf((NSInteger)(middle.z - bottom.z) == 0? 1 : (middle.z - bottom.z));
    
    DMaxTM = DTM.x > DTM.y ? (DTM.x > DTM.z ? DTM.x : DTM.z) : (DTM.y > DTM.z ? DTM.y : DTM.z);
    DMaxTB = DTB.x > DTB.y ? (DTB.x > DTB.z ? DTB.x : DTB.z) : (DTB.y > DTB.z ? DTB.y : DTB.z);
    DMaxMB = DMB.x > DMB.y ? (DMB.x > DMB.z ? DMB.x : DMB.z) : (DMB.y > DMB.z ? DMB.y : DMB.z);
    
//    NSLog(@"\nDTM %@\n DTB %@\n DMB %@",NSStringFromLPPoint(DTM),NSStringFromLPPoint(DTB),NSStringFromLPPoint(DMB));
    // Calculate steps from start to destination
    
    STM.x = ((NSInteger)top.x < (NSInteger)middle.x) ? 1 : -1;
    STM.z = ((NSInteger)top.z < (NSInteger)middle.z) ? 1 : -1;
    
    STB.x = ((NSInteger)top.x < (NSInteger)bottom.x) ? 1 : -1;
    STB.z = ((NSInteger)top.z < (NSInteger)bottom.z) ? 1 : -1;
    
    SMB.x = ((NSInteger)middle.x < (NSInteger)bottom.x) ? 1 : -1;
    SMB.z = ((NSInteger)middle.z < (NSInteger)bottom.z) ? 1 : -1;
    
    
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
    LPTriangle triangle = LPTriangleMake(top, middle, bottom);
    [self debugWithTriangle:triangle];
    static BOOL pointChanged = YES;
    
    if(edge > 0) {  // right pointing triangle
        
        // top half of triangle
        for(;;){
//            NSLog(@"TOP RIGHT POINTING");
//            NSLog(@"\nTop %@ \nMid %@ \nBot %@ \n LeftX %i RightX %i LeftZ %i RightZ %i YL %i YR %i",NSStringFromLPPoint(top),
//                  NSStringFromLPPoint(middle),
//                  NSStringFromLPPoint(bottom),
//                  XL,XR,ZL,ZR,YL,YR);

            if(YL == YR && pointChanged) {
//                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                drawScanLine(XL, XR, ZL, ZR, YL);
                pointChanged = NO;
            }
            if (YR >= (int32_t)middle.y || YL >= (int32_t)middle.y) break;
            if(YL <= YR) {        // if the left line < right increment only left
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; pointChanged = YES;}
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XR += STM.x; }
                ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YR += STM.y; pointChanged = YES;}
                ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZR += STM.z; }
            }
        }
        // bottom half of triangle
        YR = middle.y;
        XR = middle.x;
        ZR = middle.z;
        int bottomcount = 0;
        for(;;){
//            NSLog(@"BOTTOM RIGHT POINTING");
//            NSLog(@"\nTop %@ \nMid %@ \nBot %@ \n LeftX %i RightX %i LeftZ %i RightZ %i YL %i YR %i",NSStringFromLPPoint(top),
//                  NSStringFromLPPoint(middle),
//                  NSStringFromLPPoint(bottom),
//                  XL,XR,ZL,ZR,YL,YR);

            if((YL == YR) && pointChanged) {
                // cout << "RIGHT BOTTOM XL " << XL << " XR " << XR << " ZL " << ZL << " ZR " << ZR << " Y " << YL << endl;
//                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                drawScanLine(XL, XR, ZL, ZR, YL);
                pointChanged = NO;
            }
            if (YR >= (int32_t)bottom.y || YL >= (int32_t)bottom.y || XL == XR) break;
            if(YL <= YR) {        // if the left line < right increment only left
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; pointChanged = YES;}
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XR += SMB.x; }
                EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YR += SMB.y; pointChanged = YES;}
                EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZR += SMB.z; }
            }
            bottomcount++;
        }
        if (bottomcount < 1) {
//            NSLog(@"bottom right pointing triangle didnt draw");
        }
    }
    else { // Case with middle point on left side of triangle
        // top half of triangle
        for(;;){
//            NSLog(@"TOP LEFT POINTING");
//            NSLog(@"\nTop %@ \nMid %@ \nBot %@ \n LeftX %i RightX %i LeftZ %i RightZ %i YL %i YR %i",NSStringFromLPPoint(top),
//                  NSStringFromLPPoint(middle),
//                  NSStringFromLPPoint(bottom),
//                  XL,XR,ZL,ZR,YL,YR);
            if(YL == YR && pointChanged) {
//                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                drawScanLine(XL, XR, ZL, ZR, YL);
                pointChanged = NO;
            }
            if (YR >= (int32_t)middle.y || YL >= (int32_t)middle.y) break;
            if(YL <= YR) {        // if the left line < right increment only left
                ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XL += STM.x; }
                ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YL += STM.y;  pointChanged = YES;}
                ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZL += STM.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y;  pointChanged = YES;}
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
            }
        }
        // bottom half of triangle
        YL = middle.y;
        XL = middle.x;
        ZL = middle.z;
        int bottomcount = 0;
        for(;;){
//            NSLog(@"BOTTOM LEFT POINTING");
//            NSLog(@"\nTop %@ \nMid %@ \nBot %@ \n LeftX %i RightX %i LeftZ %i RightZ %i YL %i YR %i",NSStringFromLPPoint(top),
//                  NSStringFromLPPoint(middle),
//                  NSStringFromLPPoint(bottom),
//                  XL,XR,ZL,ZR,YL,YR);
            if(YL == YR && pointChanged) {
//                [self drawScanLineAtLeftX:XL RightX:XR LeftZ:ZL RightZ:ZR Y:YL];
                drawScanLine(XL, XR, ZL, ZR, YL);
                pointChanged = NO;
            }
            if (YR >= (int32_t)bottom.y || YL >= (int32_t)bottom.y || XL == XR) {
//                NSLog(@"bottom.z %li ZL %li ZR %li diff %li",bottom.z,ZL,ZR, (ZL - bottom.z));
                break;
            }
            if(YL <= YR) {        // if the left line < right increment only left
                EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XL += SMB.x; }
                EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YL += SMB.y;  pointChanged = YES;}
                EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZL += SMB.z; }
            }
            else if (YL > YR) {   // if the right line < left increment only
                ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
                ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y;  pointChanged = YES;}
                ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
            }
            bottomcount++;
        }
        if (bottomcount < 1) {
//            NSLog(@"bottom left pointing triangle didnt draw");
        }
    }
}

- (void)debugWithTriangle:(LPTriangle)triangle {
    static LPPoint prevTop = {};
    static LPPoint prevMid = {};
    static LPPoint prevBot = {};
//    NSLog(@"\nPrev Triangle %@ %@ %@ \nCurr Triangle %@ %@ %@",NSStringFromLPPoint(prevTop),NSStringFromLPPoint(prevMid),NSStringFromLPPoint(prevBot),NSStringFromLPPoint(triangle.p1),NSStringFromLPPoint(triangle.p2),NSStringFromLPPoint(triangle.p3));
    prevTop = triangle.p1;
    prevMid = triangle.p2;
    prevBot = triangle.p3;
}

- (void) drawTriangleAtCopiedPoint1:(LPPoint) p1 Point2:(LPPoint) p2 Point3:(LPPoint) p3 {
    [self drawTriangleAtPoint1:&p1 Point2:&p2 Point3:&p3];
}

- (void) drawTriangleAtX1:(NSInteger)x1 Y1:(NSInteger)y1 X2:(NSInteger)x2 Y2:(NSInteger)y2 X3:(NSInteger)x3 Y3:(NSInteger)y3 {
    
}

- (void) drawTriangle:(LPTriangle*) triangle {
    [self drawTriangleAtPoint1:&triangle->p1 Point2:&triangle->p2 Point3:&triangle->p3];
}



@end
