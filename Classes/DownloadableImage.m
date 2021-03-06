//
//  DownloadableImage.m
//  LazyImages
//
//  Created by Macbook on 06.10.10.
//  Copyright 2010 CleverUA. All rights reserved.
//

#import "DownloadableImage.h"
#import "DownloadHelper.h"
#import "LazyImagesAppDelegate.h"

@implementation DownloadableImage

@synthesize url, image;

- (id)initWithUrl:(NSString *)theUrl andSize:(CGSize)theSize
{
  if (self = [super init]) {
    size = theSize;
    self.url  = theUrl;
  }
  return self;
}

- (void)download
{
  NSLog(@"download  %@", self.url);
  DownloadHelper * downloader = [DELEGATE.downloaders objectForKey:self.url];
  if (downloader == nil) {
    downloader = [[DownloadHelper alloc] initWithDownloadedImage:self];    
    [DELEGATE.downloaders setObject:downloader forKey:self.url];
    
    [downloader startDownload];
    [downloader release];
  }
  
}

- (void)imageDownloaded:(NSData *)data
{  
  CFShow(@"imageDownloaded");
  UIImage *downloadedImage = [[UIImage alloc] initWithData:data];
  if (downloadedImage.size.width != size.width && downloadedImage.size.height != size.height)
  {
    CGSize itemSize = CGSizeMake(size.width, size.height);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [downloadedImage drawInRect:imageRect];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }
  else {
    self.image = downloadedImage;  
  }
  CFShow(@"imageDownloaded - 2");
  [downloadedImage release];
  CFShow(@"imageDownloaded - 3");
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ImageDownloadedNotificationName object:self];
  CFShow(@"imageDownloaded - end");
}

- (void)downloadDidFail
{
  [DELEGATE.downloaders removeObjectForKey:self.url];
}

- (void)dealloc
{
  DownloadHelper *downloader = [DELEGATE.downloaders objectForKey:self.url];
  if (downloader != nil) {
    [downloader cancel];
  }
  self.url = nil;
  self.image = nil;
  [super dealloc];
}

@end
