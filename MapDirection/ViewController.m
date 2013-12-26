//
//  ViewController.m
//  MapDirection
//
//  Created by Vishal Sharma on 26/12/13.
//  Copyright (c) 2013 Vishal Sharma. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    
    NSMutableArray *coordinates;
    DrawingRoute *drawingRouteObject;
}

@end

@implementation ViewController
@synthesize mapView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    coordinates = [[NSMutableArray alloc]init];
    drawingRouteObject = [[DrawingRoute alloc]init];

}

- (IBAction)showDirectionTapped:(id)sender {
    
    [mapView removeOverlays: mapView.overlays];

    //Lat & long for Ahmedabad and Tamil Nadu- Modify them to your own values
    
    float myLatDest  =13.0900;
    float myLongDest =80.2700;
    float myLatOrigin  =23.0300;
    float myLongOrigin =72.5800;
    
    coordinates = [drawingRouteObject getParceLocationFromGoogleWithOriginLatitude:myLatOrigin andLongitude:myLongOrigin destinationLatitude:myLatDest DestinationLongitude:myLongDest];
    
    [drawingRouteObject drawRoute:coordinates forMap:mapView];
    [drawingRouteObject zoomInOnRoute:mapView];

}

//Method For iOS 4,5,6
- (MKOverlayView *)mapView:(MKMapView *)mapView_local viewForOverlay:(id <MKOverlay>)overlay
{
    return [drawingRouteObject overLayForiOS4_6:overlay];
}

//For iOS 7
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView_local rendererForOverlay:(id<MKOverlay>)overlay
{
    
    return [drawingRouteObject overLayForiOS7_Later:overlay];
}

@end
