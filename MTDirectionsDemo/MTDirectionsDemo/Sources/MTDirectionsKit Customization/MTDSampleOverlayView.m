#import "MTDSampleOverlayView.h"

@implementation MTDSampleOverlayView

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawPath:(CGPathRef)path
         ofRoute:(MTDRoute *)route
     activeRoute:(BOOL)activeRoute
         mapRect:(MKMapRect)mapRect
       zoomScale:(MKZoomScale)zoomScale
       inContext:(CGContextRef)context {

    if (activeRoute) {
        CGFloat lineWidth = self.fullLineWidth * 10.f;
        UIColor *color = [UIColor colorWithWhite:1.f alpha:0.75f];

        // Draw environment path
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }

    [super drawPath:path ofRoute:route activeRoute:activeRoute mapRect:mapRect zoomScale:zoomScale inContext:context];
}


@end
