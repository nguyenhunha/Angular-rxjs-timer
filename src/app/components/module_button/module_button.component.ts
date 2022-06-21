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
  @Output() data: any;

  @Output() status: any;


  second: number = 1;
  subscription_Button_list: Subscription = new Subscription;
  subscription_Status: Subscription = new Subscription;

  constructor(private httpClient: HttpClientService) {}

  ngOnInit() {
    
    this.subscription_Button_list = timer(0, this.second * 1000)    
      .pipe(
        switchMap(() => {
          return this.httpClient.getModule_Button_List()
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(dataFromService => dataFromService !== undefined)
      )
      .subscribe(dataFromService => {
        this.data = dataFromService;
      });

    this.subscription_Button_list = timer(0, this.second * 1000)    
      .pipe(
        switchMap(() => {
          return this.httpClient.getModule_Status()
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(dataFromService => dataFromService !== undefined)
      )
      .subscribe(dataFromService => {
        this.status = dataFromService;
      });
  }

  ngOnDestroy() {
    this.subscription_Button_list.unsubscribe();

    this.subscription_Status.unsubscribe();

    

  }

  
}
