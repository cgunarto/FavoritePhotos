//
//  InstagramPhotos.m
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "InstagramPhotos.h"

@implementation InstagramPhotos

- (instancetype) initWithDictionary: (NSDictionary *)photoDictionary
{
    self = [super init];

    //Set photoID for checking favorites
    self.photoID = photoDictionary[@"id"];

    //Getting the standard Resolution URL from Instagram JSON dictionary and storing it as DATA
    NSDictionary *images = photoDictionary[@"images"];
    NSDictionary *standardResolution = images[@"standard_resolution"];
    NSString *imageURLString = standardResolution[@"url"];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];

    self.standardResolutionPhotoData = [NSData dataWithContentsOfURL:imageURL];


    //Check if the location is available (if it's a dictionary) and get the lat long
//    if ([photoDictionary[@"location"] isKindOfClass:[NSDictionary class]])
//    {
//        NSDictionary *location = photoDictionary[@"location"];
//        self.latitude = location[@"latitude"];
//        self.longitude = location[@"longitude"];
//    }

    return self;
}


@end
