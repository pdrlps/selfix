//
//  LOPPhotosViewController.h
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOPPhotoCell.h"
#import <SimpleAuth/SimpleAuth.h>
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>

@interface LOPPhotosViewController : UICollectionViewController

@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSArray *photos;

@end
