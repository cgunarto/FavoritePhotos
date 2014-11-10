//
//  InstagramSearchViewController.m
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "InstagramSearchViewController.h"
#import "InstagramPhotos.h"
#import "PhotoCollectionViewCell.h"
#import "RootViewController.h"

#define kURLSearchTag @"https://api.instagram.com/v1/tags/%@/media/recent?count=10&client_id=c0ee42e28f254733b9d1a1dbdb75fd23"

@interface InstagramSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSMutableArray *allPhotosArray;

@property (strong, nonatomic) NSMutableArray *favoritedPhotosDataArray;
@property (strong, nonatomic) NSMutableArray *favoritedPhotosLatitudeArray;
@property (strong, nonatomic) NSMutableArray *favoritedPhotosLongitudeArray;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapImageGesture;

@end

@implementation InstagramSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
    [self setRequiredTapGestureForFavorite];

    self.collectionView.pagingEnabled = YES;
    self.tabBarController.delegate = self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *textResult = searchBar.text;

    //makes sure there is no empty spaces when it's appended into the instaURLString
    textResult = [textResult stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *instaURLString = [NSString stringWithFormat:kURLSearchTag,textResult];

    [self.view endEditing:YES];
    [self loadInstagramURLRequest:instaURLString];
}


- (void)loadInstagramURLRequest:(NSString *)urlString
{
    self.allPhotosArray = [@[]mutableCopy];

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
                                    NSDictionary *allPhotosDataDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:0 error:nil];
                                    NSArray *allDataArray = allPhotosDataDictionary[@"data"];

                                     for (NSDictionary *photoDictionary in allDataArray)
                                     {
                                         InstagramPhotos *instagramPhoto = [[InstagramPhotos alloc]initWithDictionary:photoDictionary];
                                         [self.allPhotosArray addObject:instagramPhoto];
                                     }

                                   [self.collectionView reloadData];
                                 }
                            }];
}

#pragma mark Collection View Delegate Method

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *photoCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];

    InstagramPhotos *instagramPhoto = self.allPhotosArray[indexPath.item];
    photoCell.imageView.image = [UIImage imageWithData:instagramPhoto.standardResolutionPhotoData];

    //check if photo has been favorited before -- if yes, load it with a small red heart
    for (NSData *imageData in self.favoritedPhotosDataArray)
    {
        if ([instagramPhoto.standardResolutionPhotoData isEqualToData:imageData])
        {
            instagramPhoto.isFavorited = YES;
        }
    }

    if (instagramPhoto.isFavorited == YES)
    {

        [UIView animateWithDuration:0.5
                         animations:^{
                             photoCell.heartImageView.image = [UIImage imageNamed:@"solid_gray_heart"];
                             photoCell.heartImageView.alpha =1.0f;
                             photoCell.heartImageView.alpha =0.0f;
                         }];

        photoCell.smallHeartView.image = [UIImage imageNamed:@"solid_red_heart"];


    }

    else if (instagramPhoto.isFavorited == NO)
    {
        photoCell.smallHeartView.image = nil;
    }

    return photoCell;
}

#pragma mark Tap Gesture

- (void)setRequiredTapGestureForFavorite
{
    [self.doubleTapImageGesture setNumberOfTapsRequired:2];
    [self.doubleTapImageGesture setNumberOfTouchesRequired:1];
}

- (IBAction)OnDoubleTapAddToFavorite:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [gesture locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        //if image is tapped twice, a heart shape will appear to indicate it was favorited
        //TODO:this feature is still buggy
        if (indexPath)
        {
            NSLog(@"Image at %li was double tapped",indexPath.item);

            //Check if the photo is already in the array
           InstagramPhotos *favoritedPhoto = self.allPhotosArray[indexPath.item];
           [self checkAndAddToFavoritedPhotosArray:favoritedPhoto];
        }
    }
}

//Check if double tapped photo is already in the favorited array, if not, add it in the favorite Photos array
- (void)checkAndAddToFavoritedPhotosArray:(InstagramPhotos *)favoritedPhoto
{
    //IF Photo is already favorited, set isFavorited value to YES, but don't add it again to the array
    for (NSData *favoritedPhotoData in self.favoritedPhotosDataArray)
    {
        if ([favoritedPhotoData isEqualToData:favoritedPhoto.standardResolutionPhotoData])
        {
            favoritedPhoto.isFavorited = YES;
        }
    }

    //IF photo is not already favorited, add it to the array, add location as well
    if (favoritedPhoto.isFavorited == NO)
    {
        NSLog(@"Photo added to array");
        NSData *favoritedPhotoData = favoritedPhoto.standardResolutionPhotoData;

        NSNumber *favoritedPhotoLatitude = favoritedPhoto.latitude;
        NSNumber *favoritedPhotoLongitude = favoritedPhoto.longitude;

        //if location is null or nil, then add a 0 so the array can have the same index
        if (favoritedPhoto.latitude == nil || favoritedPhoto.longitude == nil)
        {
            favoritedPhotoLatitude = 0;
            favoritedPhotoLongitude = 0;
        }

        [self.favoritedPhotosDataArray addObject:favoritedPhotoData];
//        [self.favoritedPhotosLatitudeArray addObject:favoritedPhotoLatitude];
//        [self.favoritedPhotosLongitudeArray addObject:favoritedPhotoLongitude];

        favoritedPhoto.isFavorited = YES;
    }

    [self.collectionView reloadData];
    [self save];
}

#pragma mark Save and Load Methods

- (void)save
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    [self.favoritedPhotosDataArray writeToURL:plistURL atomically:YES];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLatitude.plist"];
    [self.favoritedPhotosLatitudeArray writeToURL:plistURL atomically:YES];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLongitude.plist"];
    [self.favoritedPhotosLongitudeArray writeToURL:plistURL atomically:YES];
}

- (void)load
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    self.favoritedPhotosDataArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLatitude.plist"];
    self.favoritedPhotosLatitudeArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLongitude.plist"];
    self.favoritedPhotosLongitudeArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    if (self.favoritedPhotosDataArray == nil)
    {
        self.favoritedPhotosDataArray = [@[]mutableCopy];
        self.favoritedPhotosLatitudeArray = [@[]mutableCopy];
        self.favoritedPhotosLongitudeArray = [@[]mutableCopy];
    }

}

- (NSURL*)documentsDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}


@end
