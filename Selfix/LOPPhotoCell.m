//
//  LOPPhotoCell.m
//  Selfix
//
//  Created by Pedro Lopes on 27/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPhotoCell.h"

@implementation LOPPhotoCell

@synthesize photo = _photo;

# pragma mark - Accessors
-(void)setPhoto:(NSDictionary *)photo {
    if(!_photo) {
        _photo = photo;
        
        NSURL *url = [[NSURL alloc] initWithString:_photo[@"images"][@"thumbnail"][@"url"]];
        
        [self downloadPhotoFromURL:url];
    }
}

# pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
}

# pragma mark - Actions
-(void)downloadPhotoFromURL:(NSURL *)url {
    NSString *key = [[NSString alloc] initWithFormat:@"%@-thumbnail",self.photo[@"id"]];
    UIImage *photo = [[SAMCache sharedCache] imageForKey:key];
    if (photo) {
        self.imageView.image = photo;
        return;
    } else {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            [[SAMCache sharedCache] setImage:image forKey:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }];
        
        [task resume];
    }
}

@end
