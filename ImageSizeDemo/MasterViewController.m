//
//  MasterViewController.m
//  ImageSizeDemo
//
//  Created by javen on 12-11-12.
//  Copyright (c) 2012年 yuezo.com. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"FileSize", @"FileSize");
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)takePicture:(id)sender{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Take picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Library", nil];
    [sheet showInView:self.tableView];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController * pickerVC = [[UIImagePickerController alloc] init];
    pickerVC.delegate = self;
    
    if (buttonIndex == 0) {
        // camera
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"Camera is Unavailable");
            return;
        }
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:pickerVC animated:YES];
    }else if(buttonIndex == 1){
        // library
        pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:pickerVC animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{    
    UIImage* image = nil;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // from camera
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (![assetURL isEqual:[NSNull null]]) {
            
                [assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset)
                 {
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     Byte *buffer = (Byte*)malloc(rep.size);
                     NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                     NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];   //this is NSData may be what you want
                     //         [data writeToFile:photoFile atomically:YES];//you can save image later
                     
                     NSString * filesizeString = [NSString stringWithFormat:@"filesize %u",[data length]];
                     
                     NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:image,@"image",
                                            filesizeString,@"filesize",
                                            assetURL,@"picURL",nil];
                     UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"File Size" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     
                     alert.message = filesizeString;
                     [alert show];
                     
                     if (!_objects) {
                         _objects = [[NSMutableArray alloc] init];
                     }
                     
                     [_objects insertObject:dict atIndex:0];
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                     [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                     
                 }
                             failureBlock:^(NSError *err) {
                                 NSLog(@"Error: %@",[err localizedDescription]);
                             }];
                
            }else{
                NSLog(@"error %@",[error localizedDescription]);
            }
        }];
        [assetLibrary release];
    }else{
        // from library
        
        NSURL *picURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (![picURL isEqual:[NSNull null]]) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"File Size" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
            [assetLibrary assetForURL:picURL resultBlock:^(ALAsset *asset)
             {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 Byte *buffer = (Byte*)malloc(rep.size);
                 NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                 NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];   //this is NSData may be what you want
                 //         [data writeToFile:photoFile atomically:YES];//you can save image later
                 
                 NSString * filesizeString = [NSString stringWithFormat:@"filesize %u",[data length]];
                 
                 NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:image,@"image",
                                        filesizeString,@"filesize",
                                        picURL,@"picURL",nil];
                 
                 alert.message = filesizeString;
                 [alert show];
                 
                 if (!_objects) {
                     _objects = [[NSMutableArray alloc] init];
                 }
                 
                 [_objects insertObject:dict atIndex:0];
                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                 
             }
                         failureBlock:^(NSError *err) {
                             NSLog(@"Error: %@",[err localizedDescription]);
                         }];
            [assetLibrary release];
        }
    }
    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary * dict = [_objects objectAtIndex:indexPath.row];
    NSURL * picURL = [dict objectForKey:@"picURL"];
    UIImage * image = [dict objectForKey:@"image"];
    
    cell.imageView.image  = image;
    cell.textLabel.text = [dict objectForKey:@"filesize"];
    cell.detailTextLabel.text = picURL.absoluteString;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    }
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
