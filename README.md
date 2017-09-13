# LPEngine
Low Polygon and Pixel Engine Built for Mac using MetalKit backed View

This engine is an exercise in using some metal features to accelerate a mostly CPU bound software rasterizer. The system uses a 3D brensenham algorithm implementation to draw out the triangle in points. These points are then drawn to screen using a MetalKit view and the Metal Point primitives.

#### Note: The current project code includes targets for demos on both macOS (10.12) and iOS (10.2)
