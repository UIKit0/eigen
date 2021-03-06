#import "ARAuctionArtworkResultsViewController.h"
#import "ARAuctionArtworkTableViewCell.h"
#import "ARPageSubtitleView.h"
#import "ARFeedStatusIndicatorTableViewCell.h"

static NSString *ARAuctionTableViewCellIdentifier = @"ARAuctionTableViewCellIdentifier";
static NSString *ARAuctionTableViewHeaderIdentifier = @"ARAuctionTableViewHeaderIdentifier";

static const NSInteger ARArtworkIndex = 0;

@interface ARAuctionArtworkResultsViewController ()
@property (nonatomic, copy) NSArray *auctionResults;
@end

@implementation ARAuctionArtworkResultsViewController

- (instancetype)initWithArtwork:(Artwork *)artwork
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) { return nil; }

    _artwork = artwork;

    @weakify(self);
    [_artwork getRelatedAuctionResults:^(NSArray *auctionResults) {
        @strongify(self);
        self.auctionResults = auctionResults;
    }];

    [self.tableView registerClass:[ARAuctionArtworkTableViewCell class] forCellReuseIdentifier:ARAuctionTableViewCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = [self createWarningView];

    return self;
}

- (UIView *)createWarningView
{
    CGFloat bottomMargin = 12;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 88 + bottomMargin)];
    UILabel *warning = [[ARWarningView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 88)];
    warning.text = @"Note: Auction results are an \nexperimental feature with\n limited data.";
    [container addSubview:warning];
    [warning alignToView:container];

    return container;
}

- (void)setAuctionResults:(NSArray *)auctionResults
{
    _auctionResults = auctionResults;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = (section == ARArtworkIndex)? @"COMPARABLE AUCTION RESULTS FOR" : @"MOST SIMILAR RESULTS";
    return [[ARPageSubTitleView alloc] initWithTitle:title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ARArtworkIndex) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        return [ARAuctionArtworkTableViewCell heightWithArtwork:self.artwork withWidth:width];
    }

    if (self.auctionResults.count) {
        return [ARAuctionArtworkTableViewCell estimatedHeightWithAuctionLot:self.auctionResults[indexPath.row]];
    } else {
        return [ARFeedStatusIndicatorTableViewCell heightForFeedItemWithState:ARFeedStatusStateLoading];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (indexPath.section == ARArtworkIndex) {
        return [ARAuctionArtworkTableViewCell heightWithArtwork:self.artwork withWidth:width];
    }

    if (self.auctionResults.count) {
        return [ARAuctionArtworkTableViewCell heightWithAuctionLot:self.auctionResults[indexPath.row] withWidth:width];
    } else {
        return [ARFeedStatusIndicatorTableViewCell heightForFeedItemWithState:ARFeedStatusStateLoading];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ARArtworkIndex) {
        return 1;
    }

    return MAX(self.auctionResults.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARAuctionArtworkTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ARAuctionTableViewCellIdentifier];

    if (indexPath.section == ARArtworkIndex) {
        [cell updateWithArtwork:self.artwork];
    } else {
        if (self.auctionResults.count) {
            [cell updateWithAuctionResult:self.auctionResults[indexPath.row]];

        } else {
            return [ARFeedStatusIndicatorTableViewCell cellWithInitialState:ARFeedStatusStateLoading];
        }
    }

    return cell;
}


-(BOOL)shouldAutorotate
{
    return [UIDevice isPad];
}

@end
