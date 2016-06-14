//
//  ViewController.m
//  SubtitlePlayer
//
//  Created by HongSeungho on 6/8/16.
//  Copyright © 2016 INISoft. All rights reserved.
//

#import "ViewController.h"
#import "SubtitlePlayer.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *webvttView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSString *documents;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSDictionary *types;

@property (nonatomic, strong) SubtitlePlayer *subtitlePlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.types = @{@"srt":@"application/x-subrip", @"smi":@"application/smil+xml", @"ass":@"application/x-ass", @"ttml":@"application/ttml+xml", @"webvtt":@"text/vtt"};
    self.items = [NSMutableArray array];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    self.documents = [paths objectAtIndex:0];
    NSLog(@"%@", self.documents);

    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(reloadTableView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];

    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;

    self.subtitlePlayer = [[SubtitlePlayer alloc] init];
    self.subtitlePlayer.titleLabel = self.titleLabel;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preparationNoti:) name:SubtitlePlayerPreparationNotificaition object:self.subtitlePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorNoti:) name:SubtitlePlayerErrorNotification object:self.subtitlePlayer];

    for (UIView *view in self.playerView.subviews) {
        view.hidden = YES;
    }
    [self loadItems];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SubtitlePlayerPreparationNotificaition object:self.subtitlePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SubtitlePlayerErrorNotification object:self.subtitlePlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadItems {
    [self.items removeAllObjects];
    NSArray *files = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:self.documents error:nil];
    [self.items addObjectsFromArray:files];
    [self.tableView reloadData];
}

- (void)reloadTableView:(UIRefreshControl *)refreshControl {
    [self loadItems];
    [refreshControl endRefreshing];
}

- (void)preparationNoti:(NSNotification *)notification {
    NSLog(@"===== prepared");
    CMTime duration = self.subtitlePlayer.duration;
    self.timeSlider.maximumValue = CMTimeGetSeconds(duration);

    __weak ViewController *_self = self;
    [self.subtitlePlayer addPeriodicTimeObserveForInterval:CMTimeMake(300, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float position = CMTimeGetSeconds(time);
        _self.timeSlider.value = position;
        _self.timeLabel.text = [NSString stringWithFormat:@"%.2f", position];
    }];

    for (UIView *view in self.playerView.subviews) {
        view.hidden = NO;
    }
}

- (void)errorNoti:(NSNotification *)notification {
    NSLog(@"===== error occurred.");
}

- (IBAction)play:(id)sender {
    if (self.subtitlePlayer.rate == 0.0f) {
        [self.subtitlePlayer play];
        [self.playButton setImage:[UIImage imageNamed:@"ic_pause_white_36pt"] forState:UIControlStateNormal];
    } else {
        [self.subtitlePlayer pause];
        [self.playButton setImage:[UIImage imageNamed:@"ic_play_arrow_white_36pt"] forState:UIControlStateNormal];
    }
}

- (IBAction)generateWebvtt:(id)sender {
    NSArray *webvtts = [self.subtitlePlayer generateWebVTT];
    self.textView.text = [webvtts componentsJoinedByString:@"\n"];
    self.webvttView.hidden = NO;
}

- (IBAction)hideWebvttView:(id)sender {
    self.webvttView.hidden = YES;
    self.textView.text = @"";
}

// MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    return cell;
}

// MARK: UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [self.items objectAtIndex:indexPath.row];
    NSString *file = [self.documents stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", item]];
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSLog(@"%@, %@", item, item.pathExtension);
    [self.subtitlePlayer prepare:data mimetype:[self.types objectForKey:item.pathExtension]];
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.1];
}

- (void)deselect {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

@end
