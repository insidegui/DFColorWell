//
//  DFColorSelectorView.m
//  DFColorSelector
//
//  Created by Daniel Farrell on 18/01/2015.
//  Copyright (c) 2015 Daniel Farrell. All rights reserved.
//

#import "DFColorWell.h"
#import "DFColorGridViewController.h"
#import "DFColorGridView.h"

#define INTRINSIC_WIDTH 65.0
#define INTRINSIC_HEIGHT 21.0
#define BUTTON_SIDE_LENGTH 21.0
#define MOUSE_OVER_INDICATOR_SIDE_LENGTH 13.0
#define MOUSE_OVER_INDICATOR_PADDING 4.0
#define MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH 3.0

#define COLOR_DRAG_RECT_SIDE_LENGTH 18.0

@interface DFColorWell ()

@property BOOL shouldDrawMouseOverIndicator;

@property BOOL shouldDrawDarkerButtonRegion;

@property BOOL shouldDrawButtonRegionWithSelectedColor;

@property BOOL shouldDrawFocusRing;

@property NSTrackingArea *trackingArea;

@property DFColorGridViewController *colorGridViewController;

@property NSPopover *popover;

@end

@implementation DFColorWell


- (void) awakeFromNib {
    [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
    [self registerForDraggedTypes:@[NSPasteboardTypeColor]];
    
    if (_trackingArea == nil) {
        
        NSTrackingAreaOptions options = (NSTrackingActiveAlways |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        
        _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        
        [self addTrackingArea:_trackingArea];
    }
    
    if (self.color == nil) {
        self.color = [NSColor whiteColor];
    }
}


#pragma mark - Custom drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self _drawColorRegion];
    [self _drawButtonRegion];
    [self _strokeBorderOfControl];
    [self _drawSeparatorLine];
    
    if (_shouldDrawFocusRing) {
//        NSSetFocusRingStyle(NSFocusRingOnly);
//        NSRectFill([self _colorAreaRect]);
        [self _drawFocusRingIndicator];
    }
    
    //[[NSBezierPath bezierPathWithRect:[self bounds]] stroke];
}

- (void) _drawFocusRingIndicator {
    
    //[NSGraphicsContext saveGraphicsState];
    
    NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:[NSColor alternateSelectedControlColor] endingColor:[[NSColor alternateSelectedControlColor] blendedColorWithFraction:0.4 ofColor:[NSColor whiteColor]]];
    
    CGFloat padding = 4.0;
    NSRect cutRect = NSInsetRect([self _colorAreaRect], padding, padding);
    NSBezierPath *cutPath = [NSBezierPath bezierPathWithRoundedRect:cutRect
                                                            xRadius:0.0
                                                            yRadius:0.0];
    
    NSBezierPath *outPath = [NSBezierPath bezierPathWithRoundedRect:[self _colorAreaRect]
                                                            xRadius:padding
                                                            yRadius:padding];
    
    cutPath = [cutPath bezierPathByReversingPath];
    [outPath appendBezierPath:cutPath];
    [[NSColor alternateSelectedControlColor] setFill];
    //[outPath fill];
    [gradientFill drawInBezierPath:outPath angle:90.0];
    
    // Fill over the left edge
    NSRect rect1 = NSMakeRect(NSMaxX([self _colorAreaRect]) - 4.0,
                              NSMinY([self _colorAreaRect]),
                              4.0,
                              NSHeight([self _colorAreaRect]));
    //[[NSBezierPath bezierPathWithRect:rect1] fill];
    [gradientFill drawInBezierPath:[NSBezierPath bezierPathWithRect:rect1] angle:90.0];
    
    // Fill the rounded corner on the right hand side
    
    
}

- (NSRect) _frameForMouseOverIndicator {
    
    NSRect colorRect = [self _colorAreaRect];
    NSRect basicRect = NSMakeRect(NSMaxX(colorRect) - MOUSE_OVER_INDICATOR_SIDE_LENGTH, 0.5 * (INTRINSIC_HEIGHT - MOUSE_OVER_INDICATOR_SIDE_LENGTH), MOUSE_OVER_INDICATOR_SIDE_LENGTH, MOUSE_OVER_INDICATOR_SIDE_LENGTH);
    return NSOffsetRect(basicRect, -MOUSE_OVER_INDICATOR_PADDING, 0.0);
}

- (void) _drawColorRegion {
    /* Draw the color area */
    
    NSBezierPath *colorPath = [NSBezierPath bezierPathWithRoundedRect:[self _colorAreaRect] xRadius:4.0 yRadius:4.0];
    [_color setFill];
    [colorPath fill];
    
    // Fill over the left edge
    NSRect rect1 = NSMakeRect(NSMaxX([self _colorAreaRect]) - 4.0,
                              NSMinY([self _colorAreaRect]),
                              4.0,
                              NSHeight([self _colorAreaRect]));
    [[NSBezierPath bezierPathWithRect:rect1] fill];
    
    if (_shouldDrawMouseOverIndicator) {
        [self _drawMouseOverIndicator];
        [self _drawMouseOverIndicatorTick];
    }
    
}

- (void) _drawButtonRegion {
 
    /* Draw the color area */
    NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRoundedRect:[self _buttonAreaRect] xRadius:4.0 yRadius:4.0];
    
    NSColor *color = [NSColor controlColor];
    if (_shouldDrawButtonRegionWithSelectedColor) {
        color = [NSColor alternateSelectedControlColor];
    } else if (_shouldDrawDarkerButtonRegion) {
        color = [NSColor colorWithCalibratedWhite:0.825 alpha:1.0];
    }
    [color setFill];
    [buttonPath fill];
    
    // Fill over the right edge
    NSRect rect2 = NSMakeRect(NSMinX([self _buttonAreaRect]),
                              NSMinY([self _buttonAreaRect]),
                              4.0,
                              NSHeight([self _buttonAreaRect]));
    [[NSBezierPath bezierPathWithRect:rect2] fill];
    
    
    // Draw the image centre in this region
    NSImage *image = [NSImage imageNamed:@"DFColorWheel2"];
    [image drawInRect:NSInsetRect([self _buttonAreaRect], 3.0, 3.0)];
    
}

- (void) _strokeBorderOfControl {
    
    /* Stroke the border */
    NSRect fullRect = NSUnionRect([self _colorAreaRect], [self _buttonAreaRect]);
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] setStroke];
    NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:fullRect xRadius:4.0 yRadius:4.0];
    [border setLineWidth:0.5];
    [border stroke];
    
}

- (void) _drawSeparatorLine {
    NSPoint startPoint = NSMakePoint(NSMaxX([self _colorAreaRect]), NSMaxY([self _colorAreaRect]));
    NSPoint endPoint = NSMakePoint(NSMaxX([self _colorAreaRect]), NSMinY([self _colorAreaRect]));
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] setStroke];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:startPoint];
    [line lineToPoint:endPoint];
    [line setLineWidth:0.5];
    [line stroke];
}

- (void) _drawMouseOverIndicator {
    
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect:[self _frameForMouseOverIndicator]];
    NSColor* color = [NSColor colorWithCalibratedWhite:0.4 alpha:0.4];
    [color setFill];
    [ovalPath fill];
}


- (void) _drawMouseOverIndicatorTick {
    
    
    /* This is the white "tick" or chevron that appears in the circle to 
     indicated that the popover can be launched by clicking the color segment.*/
    NSRect frame = [self _frameForMouseOverIndicator];
    NSPoint mid = NSMakePoint(NSMidX(frame), NSMidY(frame));
    NSPoint secondPoint = NSMakePoint(mid.x, mid.y - MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH * 0.5);
    NSPoint firstPoint = NSMakePoint(secondPoint.x - MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH, secondPoint.y + MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH);
    NSPoint thridPoint = NSMakePoint(secondPoint.x + MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH, secondPoint.y + MOUSE_OVER_INDICATOR_TIC_UNIT_LENGTH);
    
    NSBezierPath *tickPath = [NSBezierPath bezierPath];
    [tickPath moveToPoint:firstPoint];
    [tickPath lineToPoint:secondPoint];
    [tickPath lineToPoint:thridPoint];
    [tickPath setLineWidth:1.0];
    [[NSColor whiteColor] setStroke];
    [tickPath stroke];
    
}

- (NSRect) _colorAreaRect {
    return NSMakeRect(0.25, 0.25, INTRINSIC_WIDTH  - BUTTON_SIDE_LENGTH, INTRINSIC_HEIGHT);
}

- (NSRect) _buttonAreaRect {
    NSRect colorRect = [self _colorAreaRect];
    return NSMakeRect(NSMaxX(colorRect) + 0.25, 0.25, BUTTON_SIDE_LENGTH, INTRINSIC_HEIGHT);
}


#pragma mark - Mouse tracking

- (void) mouseEntered:(NSEvent *)theEvent {
    
    /* Set visual highlight when the mouse enters the view */
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (NSPointInRect(locationInView, [self _colorAreaRect])) {
        _shouldDrawMouseOverIndicator = YES;
    } else {
        _shouldDrawMouseOverIndicator = NO;
    }
    [self setNeedsDisplay:YES];
}


- (void) mouseMoved:(NSEvent *)theEvent {
    
    /* The code here is horrible!
     
     All we are doing is checking:
        1. which part of the view are we in (color region or button region).
        2. If the state has changed since the last time the -mouseMoved: method
            was called then we need to call -setNeedsDisplay:
     
     TODO: This horrible code be avoided by having two tracking areas for the different regions.
     
     */
    BOOL needToRedraw = NO;
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // Check for mouse in color region
    if (NSPointInRect(locationInView, [self _colorAreaRect])) {
        
        if (_shouldDrawMouseOverIndicator != YES) {
            needToRedraw = YES;
        }
        _shouldDrawMouseOverIndicator = YES;
        
    } else {
        
        if (_shouldDrawMouseOverIndicator != NO) {
            needToRedraw = YES;
        }
        _shouldDrawMouseOverIndicator = NO;
    }
    
    // Check for mouse in button region
    if (NSPointInRect(locationInView, [self _buttonAreaRect]) ) {
        // Check if we did change
        if (YES != _shouldDrawDarkerButtonRegion) {
            needToRedraw = YES;
        }
        _shouldDrawDarkerButtonRegion = YES;
    } else {
        // Check if we did change
        if (NO != _shouldDrawDarkerButtonRegion) {
            needToRedraw = YES;
        }
        _shouldDrawDarkerButtonRegion = NO;
    }
    
    if (needToRedraw) {
        [self setNeedsDisplay:YES];
    }
    
}

- (void) mouseExited:(NSEvent *)theEvent {
    
    /* On mouse exit reset all highlights that indicated 
     the mouse is inside the view. */
    _shouldDrawMouseOverIndicator = NO;
    _shouldDrawDarkerButtonRegion = NO;
    [self setNeedsDisplay:YES];
}


- (void) mouseUp:(NSEvent *)theEvent {
    
    /* Mouse down either launches a popover or the color
     panel depending on the location in the view. */
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (NSPointInRect(locationInView, [self _colorAreaRect])) {
        [self _handleMouseDownInColorRect];
    } else if (NSPointInRect(locationInView, [self _buttonAreaRect])){
        [self _handleMouseDownInButtonRect];
    }
}

#pragma mark - Mouse Clicking

- (void) _handleMouseDownInColorRect {
    

    if (_colorGridViewController == nil) {
        _colorGridViewController = [[DFColorGridViewController alloc] initWithNibName:@"DFColorGridViewController" bundle:nil];
        _colorGridViewController.colorSelectorView = self;
        DFColorGridView *view = (DFColorGridView*)_colorGridViewController.view;
        view.controller = _colorGridViewController;
    }
    
    // The color grid view knows it own size, set this here
    _popover = [[NSPopover alloc] init];
    DFColorGridView *view = (DFColorGridView*)_colorGridViewController.view;
    [_popover setContentSize:[view intrinsicContentSize]];
    
    // Set up popover and show
    [_popover setContentViewController:_colorGridViewController];
    [_popover setAnimates:NO];
    [_popover setBehavior:NSPopoverBehaviorTransient];
    [_popover showRelativeToRect:[self _colorAreaRect] ofView:self preferredEdge:NSMinYEdge];
}

- (void) _handleMouseDownInButtonRect {
    
    if (_shouldDrawButtonRegionWithSelectedColor == YES) {
        
        _shouldDrawButtonRegionWithSelectedColor = NO;
        _shouldDrawDarkerButtonRegion = YES;
        NSColorPanel *panel = [NSColorPanel sharedColorPanel];
        [panel close];
        
        
    } else {
        
        _shouldDrawDarkerButtonRegion = NO;
        _shouldDrawButtonRegionWithSelectedColor = YES;
        [self setNeedsDisplay:YES];
        
        NSColorPanel *panel = [NSColorPanel sharedColorPanel];
        panel.target = self;
        panel.action = @selector(handleColorPanelColorSelectionAction:);
        [panel orderFront:nil];
        
        /* Capture the close of the color panel. */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWindowWillCloseNotification:) name:NSWindowWillCloseNotification object:panel];
        
    }

}

#pragma mark - Dealing with the color panel

- (void) handleWindowWillCloseNotification:(NSNotification*)notification {
    
    /* Remove the color panel notification */
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:panel];
    
    /* Reset all the color panel values */
    panel.target = nil;
    panel.action = NULL;
    _shouldDrawButtonRegionWithSelectedColor = NO;
    [self setNeedsDisplay:YES];
}

- (void) handleColorPanelColorSelectionAction:(id)sender {
    self.color = [sender color];
}

#pragma mark - Setting the color

@synthesize color = _color;

- (void) setColor:(NSColor *)color {
    _color = color;
    [self setNeedsDisplay:YES];
    
    /* Hook into the popover here and if show, close it.*/
    if (_popover) {
        if ([_popover isShown]) {
            [_popover close];
        }
    }
}

- (NSColor*) color {
    return _color;
}

#pragma mark - Autolayout

- (NSSize) intrinsicContentSize {
    
    /* The views has a fixed size, but we need an extra pixel on all 
     sizes so that that the border stroke remains fully within the view.
     For this reason we check with NSScreen the smallest possible line 
     width and add that amount to the defined intrinsic size. */
    NSScreen *screen = [NSScreen mainScreen];
    CGFloat buffer = 2.0;
    if ([screen backingScaleFactor] == 2.0) {
        buffer = 1.0;
    }
    return NSMakeSize(INTRINSIC_WIDTH + buffer, INTRINSIC_HEIGHT + buffer);
}

#pragma mark - Dragging Source



- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    
    switch(context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy | NSDragOperationMove;
            break;
            
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy | NSDragOperationMove;
            break;
    }
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint {
    //NSLog(@"%@", NSStringFromPoint(screenPoint));
}

- (void) mouseDragged:(NSEvent *)theEvent {
    
    
    id propertyListRep = [self.color pasteboardPropertyListForType:NSPasteboardTypeColor];
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] initWithPasteboardPropertyList:propertyListRep ofType:NSPasteboardTypeColor];
    NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    NSColor *dragColor = [self.color copy];
    NSImage *contentImage = [NSImage imageWithSize:NSMakeSize(COLOR_DRAG_RECT_SIDE_LENGTH, COLOR_DRAG_RECT_SIDE_LENGTH) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        
        CGFloat padding = 3.0;
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(dstRect, padding, padding) xRadius:2.0 yRadius:2.0];
        [path setLineWidth:0.5];
        [[[NSColor darkGrayColor] colorWithAlphaComponent:0.5] setStroke];
        [dragColor setFill];
        [path fill];
        [path stroke];
        return YES;
    }];
    
    [item setDraggingFrame:NSMakeRect(5.0, 0.0, COLOR_DRAG_RECT_SIDE_LENGTH, COLOR_DRAG_RECT_SIDE_LENGTH) contents:contentImage];
    id source = (id <NSDraggingSource>) self;
    [self beginDraggingSessionWithItems:@[item] event:theEvent source:source];
}


#pragma mark - Dragging Destination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Don't allow drag and drop to self
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    
    NSColor *possiblyValidColor = [NSColor colorFromPasteboard:[sender draggingPasteboard]];
    if (possiblyValidColor) {
        //NSLog(@"%@", @"Should draw highlight around view.");
        _shouldDrawFocusRing = YES;
        [self setNeedsDisplay:YES];
    }
    return NSDragOperationMove;
}


- (BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender {
    if ([NSColor colorFromPasteboard:[sender draggingPasteboard]]) {
        return YES;
    }
    return NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    if ([NSColor colorFromPasteboard:[sender draggingPasteboard]]) {
        
        NSColor *draggedColor = [NSColor colorFromPasteboard:[sender draggingPasteboard]];
        if (draggedColor) {
            self.color = draggedColor;
            _shouldDrawFocusRing = NO;
            [self setNeedsDisplay:YES];
        }
        return YES;
    }
    return NO;
}




@end