//
//  DrawingRoute.m
//
//  Created by Vishal Sharma on 20/12/13.


#import "DrawingRoute.h"

@interface DrawingRoute(){
    
    MKPolyline* copy_routeLine;

}

@end


@implementation DrawingRoute

-(NSMutableArray *)getParceLocationFromGoogleWithOriginLatitude :(float)originLatitude andLongitude:(float)originLongitude destinationLatitude:(float)destinationLatitude DestinationLongitude :(float)destinationLongitude
{
    
    NSMutableArray *coordinates = [[NSMutableArray alloc]init];
    @try
    {
        NSString *URL =nil;
      
     
        
        NSString *originsLatLong =[NSString stringWithFormat:@"%f,%f",originLatitude,originLongitude];
        NSString *originsLatLongdest =[NSString stringWithFormat:@"%f,%f",destinationLatitude,destinationLongitude];
        
        
        // Driving Points
        URL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&waypoints=optimize:true&sensor=false&avoid=highways&mode=%@",[self encodeUrl:originsLatLong],[self encodeUrl:originsLatLongdest],[self encodeUrl:@"driving"]];
        
        NSError *error;
        NSString *responsString =  [NSString stringWithContentsOfURL:[NSURL URLWithString: URL] encoding:NSUTF8StringEncoding error:&error];
        
        NSError *e;
        
        NSMutableDictionary  *googleDict =     [NSJSONSerialization JSONObjectWithData: [responsString dataUsingEncoding:NSUTF8StringEncoding]
                                                                               options: NSJSONReadingMutableContainers
                                                                                 error: &e];
        
        NSMutableArray *arraymap;
        
        if([[googleDict objectForKey:@"status"] isEqual: @"OK"])
        {
            if(arraymap != nil)
            {
                arraymap = nil;
            }
            arraymap = [[NSMutableArray alloc] initWithArray:[googleDict objectForKey:@"routes"]];
            
            
            
            NSMutableArray *arrayMapPoints;
            
            if(arrayMapPoints != nil)
            {
                arrayMapPoints = nil;
            }
            
            arrayMapPoints = [[NSMutableArray alloc] initWithArray:[self decodePolyLine:[[[arraymap valueForKey:@"overview_polyline"] valueForKey:@"points"]objectAtIndex:0]]];
            
            
            for (int i = 0; i < arrayMapPoints.count ; i++)
            {
                CLLocation* current = [arrayMapPoints objectAtIndex:i];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:current.coordinate.latitude longitude:current.coordinate.longitude ];
                [coordinates addObject:location];
            }
            
            return coordinates;
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception generated While getting Coordinates");
    }
    
    
}

-(NSString *) encodeUrl: (NSString *) str
{
    NSString *encodedURL= (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(" |!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8)) ;
    return encodedURL;
}


-(NSMutableArray * )decodePolyLine: (NSString*)encodedStr
{
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init] ;
    NSInteger lat=0;
    NSInteger lng=0;
    
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }while (b >= 0x20);
        
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }while (b >= 0x20);
        
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5] ;
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5] ;
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    
    encoded = nil;
    return array;
}

- (void)drawRoute:(NSMutableArray *)arrRoutePoints forMap:(MKMapView *)mapView
{
    MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * arrRoutePoints.count);
    
    @try
    {
        int numPoints = [arrRoutePoints count];
        CLLocationCoordinate2D* coords;
        if (numPoints > 1)
        {
            coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
            for (int i = 0; i < numPoints; i++)
            {
                CLLocation* current = [arrRoutePoints objectAtIndex:i];
                coords[i] = current.coordinate;
                MKMapPoint point = MKMapPointForCoordinate(coords[i]);
                
                if (i == 0) {
                    northEastPoint = point;
                    southWestPoint = point;
                }
                else
                {
                    if (point.x > northEastPoint.x)
                        northEastPoint.x = point.x;
                    if(point.y > northEastPoint.y)
                        northEastPoint.y = point.y;
                    if (point.x < southWestPoint.x)
                        southWestPoint.x = point.x;
                    if (point.y < southWestPoint.y)
                        southWestPoint.y = point.y;
                }
                
                pointArr[i] = point;
                
            }
            
            
            for (MKPolyline *tmp in mapView.overlays)
            {
                if ([tmp.title isEqualToString:@"Directions"])
                {
                    [mapView removeOverlay:tmp];
                    break;
                }
            }
            
            
            _routeLine = [MKPolyline polylineWithPoints:pointArr count:numPoints];
           
           // [mapView removeOverlay:copy_routeLine];
           
            _routeLine.title = @"Directions";

            [mapView addOverlay:_routeLine];
            
            copy_routeLine = _routeLine;

            [mapView  setNeedsDisplay];
            free(coords);
            
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",exception);
    }
    
       
    _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y );
}

-(void) zoomInOnRoute :(MKMapView *)mapView
{
	[mapView setVisibleMapRect:_routeRect];
}


-(MKOverlayView *)overLayForiOS4_6:(id <MKOverlay>)overlay{
    
    MKOverlayView* overlayView = nil;
	
    
	if(overlay == _routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
		if(nil == _routeLineView)
		{
			_routeLineView = [[MKPolylineView alloc] initWithPolyline:_routeLine];
			_routeLineView.fillColor = [UIColor redColor];
			_routeLineView.strokeColor = [UIColor redColor];
			_routeLineView.lineWidth = 3;
		}
		
		overlayView = _routeLineView;
		_routeLineView = nil;
        _routeLine = nil;
	}
	
	return overlayView;

}

-(MKOverlayRenderer *)overLayForiOS7_Later:(id <MKOverlay>)overlay{

    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:_routeLine];
        
        renderer.fillColor   = [[UIColor redColor] colorWithAlphaComponent:0.2];
        renderer.strokeColor = [[UIColor  redColor] colorWithAlphaComponent:0.7];
        renderer.lineWidth   = 3;
        
        return renderer;
    }
    
    return nil;
}

@end
