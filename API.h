//
//  API.h
//  iReporter
//
//  Created by Abdulrahman Alkooheji on 10/20/13.
//  Copyright (c) 2013 Marin Todorov. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"

//API call completion block with result as json
typedef void (^JSONResponseBlock)(NSDictionary* json);

@interface API : AFHTTPClient

//the authorized user
@property (strong, nonatomic) NSDictionary* user;

//check whether there's an authorized user
-(BOOL)isAuthorized;

//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;

+(API*)sharedInstance;

//+(NSSet*)acceptableContentTypes;

//in API.h
-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;



@end
