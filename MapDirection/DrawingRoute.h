//
//  DrawingRoute.h
//  Created by Vishal Sharma on 20/12/13.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface DrawingRoute : NSObject
{
    MKPolyline* _routeLine;
	MKPolylineView* _routeLineView;
	MKMapRect _routeRect;

}

-(NSMutableArray *)getParceLocationFromGoogleWithOriginLatitude :(float)originLatitude andLongitude:(float)originLongitude destinationLatitude:(float)destinationLatitude DestinationLongitude :(float)destinationLongitude;
-(void)drawRoute:(NSMutableArray *)arrRoutePoints forMap:(MKMapView *)mapView;
-(void) zoomInOnRoute :(MKMapView *)mapView;
-(MKOverlayView *)overLayForiOS4_6:(id <MKOverlay>)overlay;
-(MKOverlayRenderer *)overLayForiOS7_Later:(id <MKOverlay>)overlay;

@end
