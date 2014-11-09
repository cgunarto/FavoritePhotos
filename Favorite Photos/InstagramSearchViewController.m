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
@property (strong, nonatomic) NSMutableArray *imageDataArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapImageGesture;
@property (strong, nonatomic) NSMutableArray *favoritedPhotosDataArray;



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
    PhotoCollectionViewCell *photoCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell"
                                                                                        forIndexPath:indexPath];
    InstagramPhotos *instagramPhoto = self.allPhotosArray[indexPath.row];
    photoCell.imageView.image = [UIImage imageWithData:instagramPhoto.standardResolutionPhotoData];

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
            [UIView animateWithDuration:1
                             animations:^{
                instaCell.heartImageView.image = [UIImage imageNamed:@"solid_gray_heart"];
                instaCell.heartImageView.alpha =0.0f;
            }];

            //Check if the photo is already in the array
           InstagramPhotos *favInstagramPhoto = self.allPhotosArray[indexPath.item];
           [self checkAndAddToFavoritedPhotosArray:favInstagramPhoto];

        }
    }
}

//Check if photo is double tapped photo is already in the array, if not, add it in the favorite Photos array
- (void)checkAndAddToFavoritedPhotosArray:(InstagramPhotos *)favoritedPhoto
{
    BOOL photoIsFavorited = NO;

    for (NSData *favoritedPhotoData in self.favoritedPhotosDataArray)
    {
        if ([favoritedPhoto.standardResolutionPhotoData isEqualToData:favoritedPhotoData])
        {
            photoIsFavorited = YES;
        }
    }

    if (photoIsFavorited == NO)
    {
        NSLog(@"Photo added to array");
        NSData *favoritedPhotoData = favoritedPhoto.standardResolutionPhotoData;
        [self.favoritedPhotosDataArray addObject:favoritedPhotoData];
        [self save];
    }
}

#pragma mark Save and Load Methods

- (void)save
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    [self.favoritedPhotosDataArray writeToURL:plistURL atomically:YES];
}

- (void)load
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    self.favoritedPhotosDataArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    if (self.favoritedPhotosDataArray == nil)
    {
        self.favoritedPhotosDataArray = [@[]mutableCopy];
    }
}

- (NSURL*) documentsDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}


@end
