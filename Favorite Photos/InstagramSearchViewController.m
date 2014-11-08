//
//  InstagramSearchViewController.m
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "InstagramSearchViewController.h"
#import "InstagramPhotos.h"
#import "InstaSearchCollectionViewCell.h"

#define kURLSearchTag @"https://api.instagram.com/v1/tags/dogs/media/recent?count=10&client_id=c0ee42e28f254733b9d1a1dbdb75fd23"

@interface InstagramSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
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
    InstaSearchCollectionViewCell *instaCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];
    InstagramPhotos *instaPhoto = self.allInstagramPhotosArray[indexPath.row];

    instaCell.imageView.image = [UIImage imageWithData:instaPhoto.StandardResolutionPhotoData];

    return instaCell;

}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"I've been tapped!");
//}

#pragma mark Tap Gesture

- (void)setRequiredTapGestureForFavorite
{
    [self.doubleTapImageGesture setNumberOfTapsRequired:2];
    [self.doubleTapImageGesture setNumberOfTouchesRequired:1];
}

- (IBAction)onDoubleTappingImage:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        //if image is tapped twice, a heart shape will appear to indicate it was favorited
        if (indexPath)
        {
            NSLog(@"Image at %li was double tapped",indexPath.item);
            InstaSearchCollectionViewCell *instaCell = (InstaSearchCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];

            [UIView animateWithDuration:1 animations:^{
                instaCell.heartImageView.image = [UIImage imageNamed:@"solid_gray_heart"];
                instaCell.heartImageView.alpha =0.0f;
            }];

        }
        
        else
        {

        }
    }
}




@end
