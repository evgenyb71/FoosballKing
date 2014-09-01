//
//  Utils.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/31/14.
//
//

#import "Utils.h"

@implementation Utils

+ (void)showSimpleError:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil] show];
}

@end
