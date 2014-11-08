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

    //If it's an image or video
    if ([photoDictionary[@"image"] isEqualToString:@"image"])
    {
        self.isImage = YES;
    }

    //Getting the standard Resolution URL from Instagram JSON dictionary
    NSDictionary *images = photoDictionary[@"images"];
    NSDictionary *standardResolution = images[@"standard_resolution"];
    self.StandardResolutionPhotoURL = standardResolution[@"url"];

    return self;
}


@end
