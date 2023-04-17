//
//  MenuCollectionViewCell.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/10.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "MenuCollectionViewCell.h"

@interface MenuCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;

@end

@implementation MenuCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)settingCellWithCellImageType:(CellImageType)type
{
    switch (type) {
        case TypeAbout:
            self.titleLabel.text = @"About";
            self.itemImage.image = [UIImage imageNamed:@"snapchat"];
            break;
        case TypeWifiMode:
            self.titleLabel.text = @"Wifi";
            self.itemImage.image = [UIImage imageNamed:@"spotify"];
            break;
        case TypeNetworkFile:
            self.titleLabel.text = @"Network File";
            self.itemImage.image = [UIImage imageNamed:@"television"];
            break;
        case TypeLocalFile:
            self.titleLabel.text = @"Local File";
            self.itemImage.image = [UIImage imageNamed:@"house"];
            break;
        case TypeSettings:
            self.titleLabel.text = @"Level Setting";
            self.itemImage.image = [UIImage imageNamed:@"settings"];
            break;
        default:
            break;
    }
}

@end
