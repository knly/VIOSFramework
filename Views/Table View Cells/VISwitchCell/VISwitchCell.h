//
//  VISwitchCell.h
//  card
//
//  Created by Nils Fischer on 16.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

@import UIKit;

@protocol VISwitchCellDelegate;

@interface VISwitchCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *switchControl;

@property (weak, nonatomic) IBOutlet id <VISwitchCellDelegate> delegate;

@property (strong, nonatomic) id object;

@end

@protocol VISwitchCellDelegate

- (void)switchCellDidChangeValue:(VISwitchCell *)cell;

@end