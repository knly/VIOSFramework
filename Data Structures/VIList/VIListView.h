//
//  VIListView.h
//  21
//
//  Created by Nils Fischer on 23.06.13.
//
//

#import <UIKit/UIKit.h>

@protocol VIListViewDelegate;

@interface VIListView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet id <VIListViewDelegate> delegate;

@property (strong, nonatomic) VIList *list;

@end

@protocol VIListViewDelegate

- (void)listView:(VIListView *)listView didSelectElement:(VIListElement *)element;

@end