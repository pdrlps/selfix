//
//  LOPPhotosViewController.m
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPhotosViewController.h"
#import "LOPReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>


@implementation LOPPhotosViewController

# pragma mark - Accessors
- (void)setLoading:(BOOL)loading {
	_loading = loading;
}

# pragma mark - UIViewController

-(instancetype)init {
    // start layout and set properties
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(106.0f, 106.0f);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    
    self.loading = NO;
    
    return (self = [super initWithCollectionViewLayout:layout]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Selfix";
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    
    
    // right navigation goes to Instagram camera or shows camera
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera"] style:UIBarButtonItemStylePlain target:self action:@selector(showCamera)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    // left navigation signs out / changes user
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LOPPhotoCell class] forCellWithReuseIdentifier:@"photo"];
    
    // refresh on pull down
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.49 green:0.78 blue:0.69 alpha:1];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.accessToken = [SSKeychain passwordForService:@"instagram" account:@"user"];
    if(self.accessToken == nil ) {
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            self.accessToken = responseObject[@"credentials"][@"token"];
            [SSKeychain setPassword:self.accessToken forService:@"instagram" account:@"user"];
            [self showSignOutButton];
            [self refresh];
        }];
        
    } else {
        [self showSignOutButton];
        [self refresh];
    }
    
    
}

# pragma mark - UICollectionViewController

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LOPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photo" forIndexPath:indexPath];
    cell.photo = self.photos[indexPath.row];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *photo = self.photos[indexPath.row];
    
    LOPDetailViewController *detailView = [[LOPDetailViewController alloc] init];
    detailView.modalPresentationStyle = UIModalPresentationCustom;
    detailView.transitioningDelegate = self;
    detailView.photo = photo;
    
    [self presentViewController:detailView animated:YES completion:nil];
}

# pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[LOPPresentDetailTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[LOPDismissDetailTransition alloc] init];
}

# pragma mark - UIImagePickerController

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSMutableArray *sharingItems = [NSMutableArray new];
    UIImage *shareImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [sharingItems addObject:shareImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }];
}

# pragma mark - Actions
-(void)refresh {
    if([self connected]){
        if (self.loading) {
            return;
        }
        
        self.loading = YES;
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=%@",self.accessToken ];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.photos = [responseDictionary valueForKeyPath:@"data"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.refreshControl endRefreshing];
                self.loading = NO;
            });
        }];
        
        [task resume];
    }
    // no internet!
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"Check your Internet connection! You need an Internet connection to use Selfix!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

/*
 *  Redirects to Instagram or shows system Camera
 */
-(void)showCamera {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

/*
 *  User sign out (remove from keychain)
 */
-(void)signOut {
    [SSKeychain deletePasswordForService:@"instagram" account:@"user"];
    self.accessToken = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signed out!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.photos = nil;
        [self.collectionView reloadData];
        [self showSignInButton];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

-(void)signIn {
    if(self.accessToken == nil ) {
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            self.accessToken = responseObject[@"credentials"][@"token"];
            [SSKeychain setPassword:self.accessToken forService:@"instagram" account:@"user"];
            [self showSignOutButton];
            [self refresh];
        }];
        
    } else {
        [self refresh];
    }

}

-(void)showSignInButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"signin"] style:UIBarButtonItemStylePlain target:self action:@selector(signIn)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)showSignOutButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"signout"] style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

/**
 *  Check if there's an internet connection available.
 */
-(BOOL)connected {
    LOPReachability *reachability = [LOPReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


@end
