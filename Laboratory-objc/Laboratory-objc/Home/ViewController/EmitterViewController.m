//
//  EmitterViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/24.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "EmitterViewController.h"

@interface EmitterViewController ()
@property (nonatomic, retain) CAEmitterLayer *emitterLayer;
@end

@implementation EmitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)lab_addSubViews {
    UIImageView *starImageView = [UIImageView lab_initFrame:CGRectMake(10, 0, 50, 50) backgourndColor:[UIColor clearColor] cornerRadius:0];
    [self.view addSubview:starImageView];
    starImageView.center = self.view.center;
    
    NSMutableArray *cellArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i ++) {
        float randomPercent = (float)arc4random_uniform(100 + 10) / 100;
        CAEmitterCell *cell = [[CAEmitterCell alloc] init];
        cell.velocity = 20 + 10 * randomPercent;
        cell.birthRate = 1;
        cell.lifetime = 1;
        cell.alphaRange = .2;
        cell.alphaSpeed = -.3;
        cell.scale = .06;
        cell.scaleSpeed = .02 * randomPercent * (i + 1);
        cell.emissionLatitude = 10 * (i + 1);
        cell.emissionLongitude = -10 * (i + 1);
        if (i > 2) {
            cell.emissionLatitude = -10 * (i + 1);
            cell.emissionLongitude = -10 * (i + 1);
        }
        cell.color = [UIColor yellowColor].CGColor;
        cell.contents = (id)[UIImage imageNamed:@"emitterIcon"].CGImage;
        [cellArray addObject:cell];
    }
    
    _emitterLayer = [[CAEmitterLayer alloc] init];
    _emitterLayer.emitterCells = [cellArray copy];
    _emitterLayer.emitterPosition = CGPointMake(starImageView.labWidth / 2, starImageView.labHeight / 2);
    _emitterLayer.emitterSize = starImageView.bounds.size;
    _emitterLayer.emitterMode = kCAEmitterLayerOutline;
    [starImageView.layer addSublayer:_emitterLayer];
    
    _emitterLayer.beginTime = CACurrentMediaTime();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_emitterLayer removeAllAnimations];
}

@end
