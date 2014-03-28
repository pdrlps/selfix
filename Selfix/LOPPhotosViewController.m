//
//  LOPPhotosViewController.m
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPhotosViewController.h"


@implementation LOPPhotosViewController

# pragma mark - UIViewController

-(instancetype)init {
    // start layout and set properties
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(106.0f, 106.0f);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    
    
    return (self = [super initWithCollectionViewLayout:layout]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Selfix";
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LOPPhotoCell class] forCellWithReuseIdentifier:@"photo"];
    
    self.accessToken = [SSKeychain passwordForService:@"instagram" account:@"user"];
                        
                        
    if(self.accessToken == nil ) {
        [SimpleAuth authorize:@"instagram" completion:^(NSDictionary *responseObject, NSError *error) {
            NSString *accessToken = responseObject[@"credentials"][@"token"];
            [SSKeychain setPassword:accessToken forService:@"instagram" account:@"user"];
        }];
    } else {
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

# pragma mark - Actions
-(void)refresh {
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
        });
    }];
    
    [task resume];

}

@end
