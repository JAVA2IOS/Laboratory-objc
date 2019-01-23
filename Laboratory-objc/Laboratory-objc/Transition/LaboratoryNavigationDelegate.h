//
//  LaboratoryNavigationDelegate.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/23.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LaboratoryAnimatiedTransitioning.h"

@interface LaboratoryNavigationDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic, retain) LaboratoryAnimatiedTransitioning *animatedTransitioning;

@end

