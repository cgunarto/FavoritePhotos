//
//  InstagramSearchViewController.m
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "InstagramSearchViewController.h"
#import "InstagramPhotos.h"

#define kURLPopularTag @"https://api.instagram.com/v1/media/popular?q=dogs"

@interface InstagramSearchViewController ()
@property (strong, nonatomic) NSMutableArray *allInstagramPhotosArray;

@end

@implementation InstagramSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadInstagramURLRequest:kURLPopularTag];


}

- (void)loadInstagramURLRequest:(NSString *)urlString
{
    self.allInstagramPhotosArray = [@[]mutableCopy];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
                            {
                                 if (connectionError)
                                 {
                                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NETWORK ERROR"
                                                                                                    message:connectionError.localizedDescription
                                                                                             preferredStyle:UIAlertControllerStyleAlert];

                                     UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                                        style:UIAlertActionStyleDefault
                                                                                      handler:nil];
                                     [alert addAction:okButton];
                                     [self presentViewController:alert
                                                        animated:YES
                                                      completion:nil];

                                 }

                                 else
                                 {
                                    NSDictionary *allPhotosDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                    NSArray *allDataArray = allPhotosDataDictionary[@"data"];

                                     for (NSDictionary *photo in allDataArray)
                                     {
                                         InstagramPhotos *instaPhotos = [[InstagramPhotos alloc]initWithDictionary:photo];
                                         [self.allInstagramPhotosArray addObject:instaPhotos];

                                     }

//                                   [self.tableView reloadData]; //TODO:REPLACE THIS WITH COLLECTIONVIEW RELOAD DATA EQUIVALENT
                                 }
                            }];
}


@end
