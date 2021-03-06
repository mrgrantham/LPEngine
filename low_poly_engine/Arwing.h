//
//  Arwing.h
//  low_poly_engine
//
//  Created by James Granthamon 8/20/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef Arwing_h
#define Arwing_h

#include <stdint.h>


// ARWING MODEL
int16_t arwingVertices[][3] = {
    {100, 124, -73},
    {282, 81, -268},
    {60, 152, 150},
    {39, 152, -50},
    {172, 152, -73},
    {83, 152, -50},
    {39, 152, -50},
    {60, 242, -250},
    {39, 152, -50},
    {-100, 124, -73},
    {-282, 81, -268},
    {-60, 152, 150},
    {-39, 152, -50},
    {0, 174, -100},
    {0, 150, 365},
    {-172, 152, -73},
    {-83, 152, -50},
    {0, 193, -54},
    {-39, 152, -50},
    {-60, 242, -250},
    {-39, 152, -50},
    {0, 152, -50}};

int16_t arwingFaces[][3] = {
    {6, 2, 7},
    {2, 6, 5},
    {0, 4, 8}, // wing peice
    {6, 13, 17},
    {4, 1, 8}, // wing peice
    {14, 6, 17},
    {2, 5, 7},
    {4, 0, 1}, // wing peice
    {5, 6, 7},
    {8, 21, 17},
    {21, 8, 14},
    {0, 8, 1}, // wing peice
    {18, 19, 11},
    {11, 16, 18},
    {9, 20, 15},
    {18, 17, 13},
    {15, 20, 10},
    {14, 17, 18},
    {11, 19, 16},
    {15, 10, 9},
    {16, 19, 18},
    {20, 17, 21},
    {21, 14, 20},
    {9, 10, 20}
};

int16_t arwingWireframe[][2] =   {
    {0,1},
    {2,3},
    {4,5},
    {6,7},
    {7,3},
    {6,2},
    {5,1},
    {0,2},
    {1,3},
    {4,6},
    {5,7},
    {0,4}};

#endif /* Arwing_h */
