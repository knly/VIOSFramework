//
//  VISwitchCell.m
//  card
//
//  Created by Nils Fischer on 16.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

#import "VISwitchCell.h"

@implementation VISwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.switchControl) {
        self.switchControl = [[UISwitch alloc] init];
        self.accessoryView = self.switchControl;
        [self.switchControl addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)switchValueDidChange:(UISwitch *)switchControl {
    [self.delegate switchCellDidChangeValue:self];
}

@end
