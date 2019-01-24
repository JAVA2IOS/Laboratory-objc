//
//  HomeEditTableCell.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/24.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "HomeEditTableCell.h"

@interface HomeEditTableCell()
@property (nonatomic, retain) UIImageView *sortableImageView;
@end

@implementation HomeEditTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIImageView *)sortableImageView {
    if (!_sortableImageView) {
        _sortableImageView = [UIImageView lab_initFrame:CGRectMake(0, 0, 22, 10) cornerRadius:0];
        _sortableImageView.image = [UIImage imageNamed:LABBundleImage(LABImageBundleSourceType_Table_icon_sortable)];
        _sortableImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _sortableImageView;
}
@end
