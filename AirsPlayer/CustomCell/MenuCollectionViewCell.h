//
//  MenuCollectionViewCell.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/10.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypeLocalFile,
    TypeNetworkFile,
    TypeWifiMode,
    TypeSettings,
    TypeAbout
} CellImageType;

@interface MenuCollectionViewCell : UICollectionViewCell

-(void)settingCellWithCellImageType:(CellImageType)type;

@end
