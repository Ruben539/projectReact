//
//  ExtranjeroViewController.m
//  congreso-roemmers
//
//  Created by Mambo on 7/3/16.
//  Copyright © 2016 Mambo. All rights reserved.
//

#import "ExtranjeroViewController.h"

@interface ExtranjeroViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nombresTextField;
@property (strong, nonatomic) IBOutlet UITextField *apellidosTextField;
@property (strong, nonatomic) IBOutlet UITextField *paisTextField;
@property (strong, nonatomic) IBOutlet UITextField *numeroPasaporteTextField;
@property (strong, nonatomic) IBOutlet UITextField *mailTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *inputs;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *inputsLabels;
@end

@implementation ExtranjeroViewController {
    NSString *serverURL;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Style inputs
    for (UITextField *input in self.inputs) {
        // White border bottom
        CALayer *border = [CALayer layer];
        CGFloat borderWidth = 2;
        border.borderColor = [UIColor whiteColor].CGColor;
        border.frame = CGRectMake(0, input.frame.size.height - borderWidth, input.frame.size.width, input.frame.size.height);
        border.borderWidth = borderWidth;
        [input.layer addSublayer:border];
        input.layer.masksToBounds = YES;
        
        // Padding left
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        input.leftView = paddingView;
        input.leftViewMode = UITextFieldViewModeAlways;
    }
    
    // Padding left on labels
    for (UILabel *label in self.inputsLabels) {
        label.text = [NSString stringWithFormat:@" %@", label.text];
//        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
//        label.leftView = paddingView;
//        label.leftViewMode = UITextFieldViewModeAlways;
    }
    
    serverURL = @"http://raiden.mambo.com.py/medicos_quimfa";
//    serverURL = @"http://192.168.1.4/medicos_quimfa";
//    serverURL = @"http://192.168.120.118";
//    serverURL = @"http://192.168.1.176";
//    serverURL = @"http://192.168.0.28/medicos_quimfa";
}

- (IBAction)continuar:(id)sender {
    if (![self.nombresTextField.text isEqualToString:@""] && ![self.apellidosTextField.text isEqualToString:@""] && ![self.paisTextField.text isEqualToString:@""] && ![self.mailTextField.text isEqualToString:@""]) {
        [self performSelectorInBackground:@selector(guardarExtranjero) withObject:nil];
    } else {
        UIAlertView *emptyFields = [[UIAlertView alloc] initWithTitle:@"Campos vacíos"
                                                              message:@"Debes completar todos los campos para el registro"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil, nil];
        [emptyFields show];
    }
}

-(void)guardarExtranjero {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity setAlpha:1.0];
        [self.activity startAnimating];
    });
    
    NSString *post = [NSString stringWithFormat:@"evento_id=%d&nombre=%@&apellido=%@&pais=%@&numero_pasaporte=%@&mail=%@", self.evento_id, self.nombresTextField.text, self.apellidosTextField.text, self.paisTextField.text, self.numeroPasaporteTextField.text, self.mailTextField.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/personas_pg/save_with_nombre", serverURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *requestResponse;
    NSError *error = nil;
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [responseData appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error]];
    
    NSString *responseString;
    NSString *titleString = @"";
    NSString *messageString = @"";
    BOOL clear = NO;
    if (error) {
        messageString = @"Debe conectarse a la red del congreso";
        NSLog(@"Error al guardar persona: %@", error.localizedDescription);
    } else {
        responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if ([responseString isEqualToString:@"Guardado"]) {
            titleString = @"Agregado";
            clear = YES;
        } else {
            titleString = @"Error";
            messageString = [NSString stringWithFormat:@"Ocurrió un error al guardar nuevo asistente: %@", responseString];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *success = [[UIAlertView alloc] initWithTitle:titleString
                                                          message:messageString
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil, nil];
        [success show];
        [self.activity setAlpha:0.0];
        [self.activity stopAnimating];
        
        if (![messageString isEqualToString:@"Debe conectarse a la red del congreso"]) {
            if (clear) {
                [self.nombresTextField setText:@""];
                [self.apellidosTextField setText:@""];
                [self.paisTextField setText:@""];
                [self.mailTextField setText:@""];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (IBAction)volver:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.nombresTextField]) {
        [self.apellidosTextField becomeFirstResponder];
    } else if ([textField isEqual:self.apellidosTextField]) {
        [self.paisTextField becomeFirstResponder];
    } else if ([textField isEqual:self.paisTextField]) {
        [self.numeroPasaporteTextField becomeFirstResponder];
    } else if ([textField isEqual:self.numeroPasaporteTextField]) {
        [self.mailTextField becomeFirstResponder];
    } else if ([textField isEqual:self.mailTextField]) {
        [textField resignFirstResponder];
        [self continuar:textField];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
