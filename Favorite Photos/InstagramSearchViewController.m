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

#define kURLSearchTag @"https://api.instagram.com/v1/tags/dogs/media/recent?count=10&client_id=c0ee42e28f254733b9d1a1dbdb75fd23"

@interface InstagramSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) NSMutableArray *allInstagramPhotosArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapImageGesture;


@end

@implementation InstagramSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setRequiredTapGestureForFavorite];
    [self loadInstagramURLRequest:kURLSearchTag];

    self.collectionView.pagingEnabled = YES;
    self.tabBarController.delegate = self;

    self.favoritedPhotosArray = [@[]mutableCopy];
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

                                     for (NSDictionary *photoDictionary in allDataArray)
                                     {
                                         InstagramPhotos *instaPhotos = [[InstagramPhotos alloc]initWithDictionary:photoDictionary];
                                         [self.allInstagramPhotosArray addObject:instaPhotos];

                                     }

                                   [self.collectionView reloadData];
                                 }
                            }];
}

#pragma mark Collection View Delegate Method

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allInstagramPhotosArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *photoCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];
    InstagramPhotos *instaPhoto = self.allInstagramPhotosArray[indexPath.row];

    photoCell.imageView.image = [UIImage imageWithData:instaPhoto.StandardResolutionPhotoData];

    return photoCell;

}

#pragma mark Tap Gesture

- (void)setRequiredTapGestureForFavorite
{
    [self.doubleTapImageGesture setNumberOfTapsRequired:2];
    [self.doubleTapImageGesture setNumberOfTouchesRequired:1];
}

- (IBAction)OnDoubleTapAddToFavorite:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        //if image is tapped twice, a heart shape will appear to indicate it was favorited
        if (indexPath)
        {
            NSLog(@"Image at %li was double tapped",indexPath.item);

            PhotoCollectionViewCell *instaCell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            [UIView animateWithDuration:1 animations:^{
                instaCell.heartImageView.image = [UIImage imageNamed:@"solid_gray_heart"];
                instaCell.heartImageView.alpha =0.0f;
            }];

            //Check if the photo is already in the array
            InstagramPhotos *favoritedPhoto = self.allInstagramPhotosArray[indexPath.item];
            [self checkAndAddToFavoritedPhotosArray:favoritedPhoto];

        }

        else
        {

        }
    }
}

//Check if photo is double tapped photo is already in the array, if not, add it in the favorite Photos array
- (void)checkAndAddToFavoritedPhotosArray:(InstagramPhotos *)favoritedPhoto
{
    BOOL photoIsFavorited = NO;
    for (InstagramPhotos *photo in self.favoritedPhotosArray)
    {
        if (favoritedPhoto.photoID == photo.photoID)
        {
            photoIsFavorited = YES;
        }
    }

    if (photoIsFavorited == NO)
    {
        [self.favoritedPhotosArray addObject:favoritedPhoto];
        NSLog(@"Photo added to array");
    }
}


#pragma mark Tab Bar Methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:0])
    {
        NSLog(@"Fav Photo View Controller have been tapped");
        RootViewController *rootVC = (RootViewController *)viewController;
        rootVC.favoritePhotosArray = self.favoritedPhotosArray;
    }
}



@end
