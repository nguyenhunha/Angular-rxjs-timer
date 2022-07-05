import { Component, OnDestroy, OnInit, Output } from '@angular/core';
import { of, Subscription, timer } from 'rxjs';
import { catchError, filter, switchMap } from "rxjs/operators";
import { HttpClientService } from '../../services/httpClient.service';

@Component({
  selector: 'app-data-emitter',
  templateUrl: './module_button.component.html',
  styleUrls: ['./module_button.component.scss']
})
export class ModuleButtonComponent implements OnInit, OnDestroy {
  public _chipCode = "ESP32-D0WDQ6-1-6421788";
  public _email = "nguyenhuunha@gmail.com";
  
  @Output() module_button: any;
  @Output() module_status: any;
  @Output() module_action: any;

  
  second: number = 1;
  subscription_Button_list: Subscription = new Subscription;
  subscription_Status: Subscription = new Subscription;
  subscription_Action: Subscription = new Subscription;

  constructor(private httpClient: HttpClientService) {}

  ngOnInit() {
    
    this.subscription_Button_list = timer(0, this.second * 500)    
      .pipe(
        switchMap(() => {
          const body = {chipCode: this._chipCode,
                        customerEmail : this._email};
            return this.httpClient.viewButtonBy(body)
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(dataFromHttpClientService => dataFromHttpClientService !== undefined)
      )
      .subscribe(dataFromHttpClientService => {
        this.module_button = dataFromHttpClientService[0];
      });


    this.subscription_Status = timer(0, this.second * 1000)    
      .pipe(
        switchMap(() => {
          const body = {chipCode: this._chipCode,
                        customerEmail : this._email};
          return this.httpClient.viewStatusBy(body)
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(dataFromHttpClientService => dataFromHttpClientService !== undefined)
      )
      .subscribe(dataFromHttpClientService => {
        this.module_status = dataFromHttpClientService[0];
      });

    this.subscription_Action = timer(0, this.second * 500)    
      .pipe(
        switchMap(() => {
          const body = {chipCode: this._chipCode,
                        customerEmail : this._email};
          return this.httpClient.viewActionBy(body)
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(dataFromHttpClientService => dataFromHttpClientService !== undefined)
      )
      .subscribe(dataFromHttpClientService => {
        this.module_action = dataFromHttpClientService[0];
      });
  }

  ngOnDestroy() {
    this.subscription_Button_list.unsubscribe();

    this.subscription_Status.unsubscribe();

    this.subscription_Action.unsubscribe();

  }  
}
