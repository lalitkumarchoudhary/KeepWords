//
//  TableViewCell.m
//  MyColorNote
//
//  Created by Lalit Choudhary on 23/04/15.
//  Copyright (c) 2015 Lalit Choudhary. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width-70, self.frame.size.height)];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.textColor = [UIColor blueColor];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width-5, self.frame.size.height)];
        self.time.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.time];
        
    }
    return self;
}
@end
