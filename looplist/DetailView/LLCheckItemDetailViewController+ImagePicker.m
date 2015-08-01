//
//  LLCheckItemDetailViewController+ImagePicker.m
//  looplist
//
//  Created by Yoshio Nose on 2015/06/11.
//  Copyright (c) 2015年 Yoshio Nose. All rights reserved.
//

//#import "LLCheckItemDetailViewController+ImagePicker.h"
#import "LLCheckItemDetailViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface LLCheckItemDetailViewController (ImagePicker) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation LLCheckItemDetailViewController (ImagePicker)

#pragma mark 画像選択ボタン
- (IBAction)pickImage:(id)sender {

    [self launchPhotoLibraryOrCamera];
}

-(void)launchPhotoLibraryOrCamera
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) ||
        self.attachImage != nil) {

        // カメラもフォトライブラリも両方使用可能な場合、
        // または画像が設定済みの場合はアクションシートで選択する
        [self chooseImageSourceType];

    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {

        // 写真を選択
        [self launchImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

-(void)chooseImageSourceType
{
    // アクションシートを表示
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    // キャンセルボタン
    [actionSheet addAction:[UIAlertAction actionWithTitle:LSTR(@"actionCancel")
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];

    // カメラを起動
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:LSTR(@"actionCamera")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self launchImagePicker:UIImagePickerControllerSourceTypeCamera];
                                                      }]];
    }

    // フォトライブラリを起動
    [actionSheet addAction:[UIAlertAction actionWithTitle:LSTR(@"actionPhoto")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [self launchImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                                                  }]];

    // 画像を削除
    if (self.attachImage) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:LSTR(@"actionRemovePhoto")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self removeImage];
                                                      }]];
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)launchImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    // フォトライブラリのみ使用可能な場合はフォトライブラリを表示する(アクションシートは表示しない)
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;

    // 写真のみを指定(ムービーを除く)
    imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];

    // 写真の移動と拡大縮小、トリミングのためのコントロールを表示しない(必ずトリミングされてしまうので使用しない)
    imagePickerController.allowsEditing = NO;

    // iPhoneのカメラ、フォトライブラリ、またはiPadのカメラはモーダル表示
    [self presentViewController:imagePickerController animated:YES completion:nil];

}

-(void)removeImage
{
    // 画像をフェードアウトした後に
    // ビュー位置を調整するアニメーション
    NSTimeInterval animationDuration = 0.3; // 秒
    [UIView animateWithDuration:animationDuration animations:^{
        self.attachImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.attachImage = nil;
        self.attachImageView.image = nil;
        self.attachImageView.alpha = 1;
        [self makeShadow];  // ドロップシャドウ

        [UIView animateWithDuration:animationDuration animations:^{
            [self resetScrollViewContentInset:self.view.frame.size];
        }];
    }];

}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *editedImage, *imageToUse;

    // iPhoneの場合カメラを起動した後はステータスバーが消えてしまったままになるので強制的に表示を戻す
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    // フォトアルバルまたはカメラから写真が選択された
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        if (editedImage) {
            // 編集済み写真
            imageToUse = editedImage;
        } else {
            // オリジナル写真
            imageToUse = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        }

        self.attachImage = imageToUse;
        self.attachImageView.image = imageToUse;

        // ドロップシャドウ
        [self makeShadow];

        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
