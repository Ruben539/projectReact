//
//  ViewController.m
//  congreso-roemmers
//
//  Created by Mambo on 7/3/16.
//  Copyright © 2016 Mambo. All rights reserved.
//

#import "ViewController.h"
#import "ExtranjeroViewController.h"
#import "ComboBoxButton.h"
#import "PCAngularActivityIndicatorView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *ciTextField;
@property (strong, nonatomic) IBOutlet UILabel *nombreApellidoLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *eventosPickerView;
@property (strong, nonatomic) IBOutlet UIButton *buscarButton;
@property (strong, nonatomic) PCAngularActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *extranjeroButton;
@property (strong, nonatomic) IBOutlet UIButton *continuarButton;
@property (strong, nonatomic) IBOutlet ComboBoxButton *myComboBox;
@property (strong, nonatomic) IBOutlet UIView *esUstedView;
@property (strong, nonatomic) IBOutlet UIView *bienvenidoView;
@property (strong, nonatomic) IBOutlet UILabel *nombreApellidoFinalLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation ViewController {
    NSString *serverURL;
    int evento_id;
    ComboBoxButton *anotherOne;
    NSTimer *finalTimer;
}
NSArray *eventos;

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    Código para listar fuentes de tipografía disponible en le app
//    for (NSString *familyName in [UIFont familyNames]){
//        NSLog(@"Family name: %@", familyName);
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
//            NSLog(@"--Font name: %@", fontName);
//        }
//    }
    
    // Do any additional setup after loading the view, typically from a nib.
    serverURL = @"http://raiden.mambo.com.py/medicos_quimfa";
//    serverURL = @"http://192.168.1.111/medicos";
//    serverURL = @"http://192.168.120.118";
//    serverURL = @"http://192.168.1.4/medicos_quimfa";
//    serverURL = @"http://192.168.0.28/medicos_quimfa";
    
    // Debug views by adding border
//    for (UIView *firstView in self.view.subviews) {
//        for (UIView *secondView in firstView.subviews) {
//            for (UIView *thirdView in secondView.subviews) {
//                for (UIView *fourthView in thirdView.subviews) {
//                    for (UIView *fifthView in fourthView.subviews) {
//                        fifthView.layer.borderWidth = 10.0f;
//                        fifthView.layer.borderColor = [UIColor blackColor].CGColor;
//                    }
//                    fourthView.layer.borderWidth = 10.0f;
//                    fourthView.layer.borderColor = [UIColor blackColor].CGColor;
//                }
//                thirdView.layer.borderWidth = 10.0f;
//                thirdView.layer.borderColor = [UIColor blackColor].CGColor;
//            }
//            secondView.layer.borderWidth = 10.0f;
//            secondView.layer.borderColor = [UIColor blackColor].CGColor;
//        }
//        firstView.layer.borderWidth = 10.0f;
//        firstView.layer.borderColor = [UIColor blackColor].CGColor;
//    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEventoSelected:) name:@"customButtonPressed" object:nil];
    
    // activity indicator config
    self.activityIndicator = [[PCAngularActivityIndicatorView alloc] initWithActivityIndicatorStyle:PCAngularActivityIndicatorViewStyleLarge];
    self.activityIndicator.color = [UIColor orangeColor];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    float sWidth = screen.size.width;
    float sHeight = screen.size.height;
    float xPos = (sWidth / 2) - (self.activityIndicator.frame.size.width / 2);
    float yPos = (sHeight / 2) - (self.activityIndicator.frame.size.height / 2);
    self.activityIndicator.frame = CGRectMake(xPos, yPos, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height);
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator setUserInteractionEnabled:NO];
    [self handleStop:self];
    
    [[self.buscarButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.extranjeroButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.continuarButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    _myComboBox.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _myComboBox.titleLabel.numberOfLines = 3; // if you want unlimited number of lines put 0
    
    [self performSelectorInBackground:@selector(obtenerEventos) withObject:nil];
    
//    anotherOne = [[ComboBoxButton alloc] initWithData:eventos andTableHeight:200.0 andFrame:CGRectMake(20, 20, 231, 50)];
//    [anotherOne setFrame:CGRectMake(20, 20, 200, 50)];
//    [anotherOne setTitle:@"jajaja" forState:UIControlStateNormal];
//    [self.view addSubview:anotherOne];
}

- (void)handleStart:(id)sender {
    [self.activityIndicator startAnimating];
}

- (void)handleStop:(id)sender {
    [self.activityIndicator stopAnimating];
}

-(void)handleEventoSelected:(NSNotification *)dict {
    NSDictionary *selected = [dict valueForKey:@"object"];
//    NSLog(@"selected name: %@, selected id: %@", [selected objectForKey:@"nombre"], [selected objectForKey:@"evento_id"]);
    evento_id = [[selected objectForKey:@"evento_id"] intValue];
    [[NSUserDefaults standardUserDefaults] setObject:[selected objectForKey:@"evento_id"] forKey:@"selected_evento_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.myComboBox setTitle:[selected objectForKey:@"nombre"] forState:UIControlStateNormal];
}

-(void)obtenerEventos {
    NSString *post = @"";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/eventos", serverURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *requestResponse;
    NSError *error = nil;
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [responseData appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error]];
    
    NSString *responseString;
    
    responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Debe conectarse a la red del congreso."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [error show];
        });
        NSLog(@"Error al obtener eventos: %@", error.localizedDescription);
    } else {
        if (![responseString isEqualToString:@"No data"]) {
            
            NSMutableArray *eventosJSON = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if ([eventosJSON count] <= 0) {
                NSLog(@"No hay datos");
                return;
            }
            
            eventos = eventosJSON;
            evento_id = [[[eventos lastObject] objectForKey:@"evento_id"] intValue];
            self.myComboBox.data = eventos;
            self.myComboBox.tableHeight = 200.0;
            
            NSLog(@"evento_id: %d", evento_id);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myComboBox setTitle:[[eventos lastObject] objectForKey:@"nombre"] forState:UIControlStateNormal];
                [self.myComboBox addOptionsTable];
                [self.myComboBox.myOptionsTable reloadData];
                [anotherOne.myOptionsTable reloadData];
                [self.eventosPickerView reloadAllComponents];
                
                
                int correct_index = (int)([eventos count]-1);
                for (int i = 0; i < [eventos count]; i++) {
                    int selected_evento_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected_evento_id"] intValue];
                    int current_evento_id = [[[eventos objectAtIndex:i] objectForKey:@"evento_id"] intValue];
                    
                    if (selected_evento_id == current_evento_id) {
                        correct_index = i;
                    }
                }
                
                NSLog(@"Defaults: %d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected_evento_id"] intValue]);
                NSLog(@"correct_index: %d", correct_index);
                NSLog(@"Evento ID en ese index: %@", [[eventos objectAtIndex:correct_index] objectForKey:@"evento_id"]);
                
                evento_id = [[[eventos objectAtIndex:correct_index] objectForKey:@"evento_id"] intValue];
                [self.myComboBox setTitle:[[eventos objectAtIndex:correct_index] objectForKey:@"nombre"] forState:UIControlStateNormal];
                
//                [self.eventosPickerView selectRow:correct_index inComponent:0 animated:YES];
//                [anotherOne.myOptionsTable selectRowAtIndexPath:[NSIndexPath indexPathWithIndex:correct_index] animated:YES scrollPosition:UITableViewScrollPositionTop];
                [self.myComboBox.myOptionsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:correct_index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            });
        } else {
            UIAlertView *noData = [[UIAlertView alloc] initWithTitle:@"No hay datos"
                                                             message:@"No hay eventos cargados"
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil, nil];
            [noData show];
        }
    }
}

-(IBAction)numberPressed:(UIButton *)sender {
    [self.ciTextField setText:[self.ciTextField.text stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)[sender tag]]]];
}

-(IBAction)clear:(id)sender {
    self.ciTextField.text = @"";
}

-(IBAction)delete:(id)sender {
    if (self.ciTextField.text.length > 0)
        self.ciTextField.text = [self.ciTextField.text substringToIndex:[self.ciTextField.text length] - 1];
}

- (IBAction)no:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.esUstedView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.ciTextField.text = @"";
    }];
}

- (IBAction)buscar:(id)sender {
    if ([self.ciTextField.text isEqualToString:@""]) {
        UIAlertView *emptyFields = [[UIAlertView alloc] initWithTitle:@"Ingrese CI"
                                                              message:@"Debe ingresar una cédula para registrar su llegada"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil, nil];
        [emptyFields show];
        return;
    }
    
    [self performSelectorInBackground:@selector(buscarPorCI) withObject:nil];
}

-(void)buscarPorCI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleStart:self];
    });
    
    NSString *ci = [self.ciTextField text];
    
    // Send a synchronous request
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/personas_pg/get_with_ci?ci=%@", serverURL, ci]]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    NSString *responseString;
    NSString *messageString = @"";
    if (error == nil) {
        // Parse data here
        responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseString: %@", responseString);
        if ([responseString isEqualToString:@""]) {
            [self.nombreApellidoLabel setText:@"Sin resultados"];
        } else {
            messageString = responseString;
            NSMutableDictionary *persona = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nombreApellidoLabel setText:[NSString stringWithFormat:@"%@ %@?", [persona objectForKey:@"nombres"], [persona objectForKey:@"apellidos"]]];
                [self.nombreApellidoFinalLabel setText:[NSString stringWithFormat:@"%@ %@", [persona objectForKey:@"nombres"], [persona objectForKey:@"apellidos"]]];
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.esUstedView.alpha = 1.0f;
                }];
            });
        }
    } else {
        NSLog(@"Error en request: %@", error.localizedDescription);
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleStop:self];
        
        if ([messageString isEqualToString:@""]) {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Debe conectarse a la red del congreso"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [error show];
        }
    });
}


- (IBAction)continuar:(id)sender {
    if ([self.nombreApellidoLabel.text isEqualToString:@""] || [self.ciTextField.text isEqualToString:@""]) {
        UIAlertView *emptyFields = [[UIAlertView alloc] initWithTitle:@"Ingrese CI"
                                                              message:@"Debe ingresar una cédula para registrar su llegada"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil, nil];
        [emptyFields show];
    } else {
        if (evento_id <= 0) {
            UIAlertView *emptyFields = [[UIAlertView alloc] initWithTitle:@""
                                                                  message:@"Debe conectarse a la red del congreso"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles:nil, nil];
            [emptyFields show];
            return;
        }
        [self performSelectorInBackground:@selector(set_llamado) withObject:nil];
    }
}

-(void)set_llamado {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleStart:self];
    });
    NSString *post = [NSString stringWithFormat:@"evento_id=%d&ci=%@", evento_id, self.ciTextField.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/personas_pg/save_with_ci", serverURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *requestResponse;
    NSError *error = nil;
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [responseData appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error]];
    
    NSString *responseString;
    NSString *messageString = @"Debe conectarse a la red del congreso";
    
    responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if (error) {
        
        NSLog(@"Error al obtener eventos: %@", error.localizedDescription);
    }
    if (![responseString isEqualToString:@""]) {
        messageString = responseString;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Respuesta"
//                                                          message:messageString
//                                                         delegate:nil
//                                                cancelButtonTitle:@"Ok"
//                                                otherButtonTitles:nil, nil];
//        [message show];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.bienvenidoView.alpha = 1.0f;
            finalTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(volverInicio:) userInfo:nil repeats:NO]; 
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.esUstedView.alpha = 0.0f;
            }];
        }];
        
        [self handleStop:self];
        
        if (![messageString isEqualToString:@"Debe conectarse a la red del congreso"]) {
            [self.ciTextField setText:@""];
            [self.nombreApellidoLabel setText:@""];
        }
    });
}

-(IBAction)volverInicio:(id)sender {
    [finalTimer invalidate];
    finalTimer = nil;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.bienvenidoView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.ciTextField.text = @"";
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Do something before segue
    ExtranjeroViewController *destionation = segue.destinationViewController;
    destionation.evento_id = evento_id;
}

@end
