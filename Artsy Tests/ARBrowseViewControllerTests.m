#import "ARBrowseViewController.h"

@interface ARBrowseViewController (Tests)
@property (nonatomic, assign, readwrite) BOOL shouldAnimate;
@property (nonatomic, strong, readonly) NSArray *menuLinks;
- (void)fetchMenuItems;
@end

SpecBegin(ARBrowseViewController)

__block ARBrowseViewController *viewController;

before(^{
    // used to find the sets called "Featured Categories", but really these are featured genes
    [OHHTTPStubs stubJSONResponseAtPath:@"/api/v1/sets"
                             withParams:@{ @"key" : @"eigen-browse:menu-items", @"mobile" : @"true", @"published" : @"true", @"sort" : @"key" }
                           withResponse:@[ @{ @"id" : @"browse-menu-items", @"name" : @"", @"item_type" : @"FeaturedLink" } ]
     ];

    // items inside a featured category, a collection of featured links
    [OHHTTPStubs stubJSONResponseAtPath:@"/api/v1/set/browse-menu-items/items"
                           withResponse:@[@{ @"id" : @"s1", @"title" : @"S1", @"href" : @"/link1" },
                                          @{ @"id" : @"s2", @"title" : @"S2", @"href" : @"/link2" },
                                          @{ @"id" : @"s3", @"title" : @"S3", @"href" : @"/link3" },
                                          @{ @"id" : @"s4", @"title" : @"S4", @"href" : @"/link4" },
                                          @{ @"id" : @"s5", @"title" : @"S5", @"href" : @"/link5" },
                                          @{ @"id" : @"s6", @"title" : @"S6", @"href" : @"/link6" }]
     ];

    viewController = [[ARBrowseViewController alloc] init];
    viewController.shouldAnimate = NO;
});

it(@"sets its menu items", ^{
    [viewController fetchMenuItems];
    expect(viewController.menuLinks.count).will.equal(6);
});

itHasSnapshotsForDevices(@"looks correct", ^{
    id mock = [OCMockObject partialMockForObject:viewController];
    NSArray *items = @[[FeaturedLink modelWithJSON:@{@"title": @"Link 1"}],
                       [FeaturedLink modelWithJSON:@{@"title": @"Link 2"}],
                       [FeaturedLink modelWithJSON:@{@"title": @"Link 3"}],
                       [FeaturedLink modelWithJSON:@{@"title": @"Link 4"}],
                       [FeaturedLink modelWithJSON:@{@"title": @"Link 5"}]
                       ];
    [[[mock stub] andReturn:items] menuLinks];
    return mock;
});

SpecEnd
