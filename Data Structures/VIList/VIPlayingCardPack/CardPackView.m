//
//  CardPackView.m
//  21
//
//  Created by Nils Fischer on 21.06.13.
//
//

#import "CardPackView.h"

#define kCardSpacing 30
#define kCardWidth 250
#define kCardHeight 390

@interface CardPackView ()

@property (strong, nonatomic) VIList *staticCardImageViews;
@property (strong, nonatomic) VIList *scrollingCardImageViews;

@property (strong, nonatomic) UIView *staticCardsView;
@property (strong, nonatomic) UIView *scrollingCardsView;

@property (strong, nonatomic) UIScrollView *scrollView;

- (void)updateCardImages;
- (UIImage *)imageForCard:(VIPlayingCard *)aCard;

@end

@implementation CardPackView

- (void)awakeFromNib {
	[super awakeFromNib];

	self.staticCardsView = [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:_staticCardsView];

	self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.delegate = self;
	[self addSubview:self.scrollView];
	
	self.scrollingCardsView = [[UIView alloc] init];
	[self.scrollView addSubview:self.scrollingCardsView];
	
	self.displayCardNumber = 1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packDidChange:) name:VIPackDidChangeNotification object:nil];

	[self setNeedsLayout];
	
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Drawing Cards

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	if (self.scrollView.contentOffset.x>=self.scrollView.bounds.size.width*2||self.scrollView.contentOffset.x<=0) {
        
		if (self.reverse) [self.pack remit:self.displayCardNumber];
        else [self.pack draw:self.displayCardNumber];

        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
        
    }
}

- (void)packDidChange:(NSNotification *)notification {
    [self updateCardImages];
}

#pragma mark - Accessors

- (void)setPack:(VIPlayingCardPack *)pack {
	_pack = pack;
	[self updateCardImages];
}

- (void)setDisplayCardNumber:(int)displayCardNumber {
	_displayCardNumber = displayCardNumber;
	
	if (!self.staticCardImageViews) self.staticCardImageViews = [[VIList alloc] init];
	if (!self.scrollingCardImageViews) self.scrollingCardImageViews = [[VIList alloc] init];
	while ([self.staticCardImageViews count]<self.displayCardNumber) {
		UIImageView *staticCard = [[UIImageView alloc] init];
		VIListElement *cu = [VIListElement elementWithObject:staticCard];
		[self.staticCardImageViews appendElement:cu];
		[self.staticCardsView addSubview:staticCard];
	}
	while ([self.staticCardImageViews count]>self.displayCardNumber) {
		UIImageView *cardImageView = [self.staticCardImageViews lastElement].object;
		[cardImageView removeFromSuperview];
		[self.staticCardImageViews removeObject:cardImageView];
	}
	while ([self.scrollingCardImageViews count]<self.displayCardNumber) {
		UIImageView *scrollingCard = [[UIImageView alloc] init];
		VIListElement *cu = [VIListElement elementWithObject:scrollingCard];
		[self.scrollingCardImageViews appendElement:cu];
		[self.scrollingCardsView addSubview:scrollingCard];
	}
	while ([self.scrollingCardImageViews count]>self.displayCardNumber) {
		UIImageView *cardImageView = [self.scrollingCardImageViews lastElement].object;
		[cardImageView removeFromSuperview];
		[self.scrollingCardImageViews removeObject:cardImageView];
	}
    
	[self setNeedsLayout];
	[self updateCardImages];
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kCardWidth*self.displayCardNumber+kCardSpacing*(self.displayCardNumber-1), kCardHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat cardLayoutRatio = MIN(self.frame.size.width/self.intrinsicContentSize.width, self.frame.size.height/self.intrinsicContentSize.height);
    cardLayoutRatio = MIN(1, cardLayoutRatio);
    
    CGSize cardLayoutSize = CGSizeMake(self.intrinsicContentSize.width*cardLayoutRatio, self.intrinsicContentSize.height*cardLayoutRatio);
    
    CGSize cardSize = CGSizeMake(kCardWidth*cardLayoutRatio, kCardHeight*cardLayoutRatio);
	
    self.scrollView.frame = self.bounds;
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*3, self.scrollView.frame.size.height);
	self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
	self.staticCardsView.frame = self.bounds;
    self.scrollingCardsView.frame = CGRectOffset(self.bounds, self.scrollView.frame.size.width, 0);
	
	VIListElement *cuStatic = self.staticCardImageViews.firstElement;
	VIListElement *cuScroll = self.scrollingCardImageViews.firstElement;
	int i=0;
	while (cuStatic||cuScroll) {
		CGRect frame = CGRectMake((self.scrollingCardsView.bounds.size.width-cardLayoutSize.width)/2+cardLayoutSize.width/self.displayCardNumber*i, self.scrollingCardsView.bounds.size.height/2-cardSize.height/2, cardSize.width, cardSize.height);
		[cuStatic.object setFrame:frame];
		[cuScroll.object setFrame:frame];
		cuStatic = cuStatic.next;
		cuScroll = cuScroll.next;
		i++;
	}
    
}

#pragma mark - Display

- (void)updateCardImages {
	VIPlayingCard *cu = self.pack.top;
    if (self.reverse) {
        if (!cu) cu = (VIPlayingCard *)[self.pack lastElement];
        else cu = (VIPlayingCard *)cu.prev;
        [self.scrollingCardImageViews moveToLast];
    } else [self.scrollingCardImageViews moveToFirst];

	for (int i=0; i<self.displayCardNumber; i++) {
        UIImage *cardImage = (!self.reverse&&self.pack.showCover) ? [self coverImage] :[self imageForCard:cu];
		[(UIImageView *)self.scrollingCardImageViews.currentElement.object setImage:cardImage];
		if (self.reverse) cu = (VIPlayingCard *)cu.prev;
        else if (!self.pack.showCover) cu = (VIPlayingCard *)cu.next;
		if (self.reverse) [self.scrollingCardImageViews stepPrev];
        else [self.scrollingCardImageViews stepNext];
	}
	if (self.reverse) [self.staticCardImageViews moveToLast];
    else [self.staticCardImageViews moveToFirst];
	for (int i=0; i<self.displayCardNumber; i++) {
		[(UIImageView *)self.staticCardImageViews.currentElement.object setImage:[self imageForCard:cu]];
		cu = (self.reverse) ? (VIPlayingCard *)cu.prev : (VIPlayingCard *)cu.next;
		if (self.reverse) [self.staticCardImageViews stepPrev];
        else [self.staticCardImageViews stepNext];
	}
}


#pragma mark - Image Supply

- (UIImage *)imageForCard:(VIPlayingCard *)card {
	if (!card) return nil;
    // suit
    NSString *suitString = nil;
    switch (card.suit) {
        case kSuitDiamonds:
            suitString = @"diamonds";
            break;
        case kSuitHearts:
            suitString = @"hearts";
            break;
        case kSuitClubs:
            suitString = @"clubs";
            break;
        case kSuitSpades:
            suitString = @"spades";
            break;
        default:
            break;
    }
    // rank
    NSString *rankString = nil;
    switch (card.rank) {
        case kRank2:
            rankString = @"2";
            break;
        case kRank3:
            rankString = @"3";
            break;
        case kRank4:
            rankString = @"4";
            break;
        case kRank5:
            rankString = @"5";
            break;
        case kRank6:
            rankString = @"6";
            break;
        case kRank7:
            rankString = @"7";
            break;
        case kRank8:
            rankString = @"8";
            break;
        case kRank9:
            rankString = @"9";
            break;
        case kRank10:
            rankString = @"10";
            break;
        case kRankJack:
            rankString = @"jack";
            break;
        case kRankQueen:
            rankString = @"queen";
            break;
        case kRankKing:
            rankString = @"king";
            break;
        case kRankAce:
            rankString = @"ace";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@_%@", suitString, rankString, [self langString]]];
}

- (NSString *)langString {
    NSString *theLangString = @"en";
    NSString *savedLangString = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyLangString];
    if ([savedLangString isEqualToString:@"de"]||[savedLangString isEqualToString:@"en"]) {
        theLangString = savedLangString;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:theLangString forKey:kUDKeyLangString];
    }
    return theLangString;
}

- (UIImage *)coverImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"pack_cover_%@",[self langString]]];
}

@end
