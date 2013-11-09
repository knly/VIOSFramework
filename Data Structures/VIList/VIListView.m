//
//  VIListView.m
//  21
//
//  Created by Nils Fischer on 23.06.13.
//
//

#import "VIListView.h"

@interface VIListView ()

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation VIListView

- (void)awakeFromNib {
	
	[super awakeFromNib];

	_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	_scrollView.pagingEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.delegate = self;
	[self addSubview:_scrollView];

	[self setNeedsLayout];
	
}

#pragma mark - Drawing Cards

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	if (_scrollView.contentOffset.x>=_scrollView.bounds.size.width*2||_scrollView.contentOffset.x<=0) {
        
        if (_scrollView.contentOffset.x<=0) [_list stepPrev];
		else [_list stepNext];
				
		_scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);

		[self setNeedsLayout];
		
		[_delegate listView:self didSelectElement:_list.currentElement];

    }
}

#pragma mark - Layout and View updates

- (void)setList:(VIList *)list {
	_list = list;
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*3, _scrollView.frame.size.height);
	_scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
	
	CGFloat slotWidth = _scrollView.frame.size.width;

	VIListElement *cu = _list.currentElement.prev;
	for (int i=0; i<3; i++) {
		UIView *elementView = (UIView *)cu.object;
		elementView.center = CGPointMake(i*slotWidth+slotWidth/2, _scrollView.frame.size.height/2);
		[_scrollView addSubview:elementView];
		cu = cu.next;
	}

}

@end
