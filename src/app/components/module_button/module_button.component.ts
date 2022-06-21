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


  second: number = 1;
  subscription: Subscription = new Subscription;

  constructor(private httpClient: HttpClientService) {}

  ngOnInit() {
    
    this.subscription = timer(0, this.second * 500)    
      .pipe(
        switchMap(() => {
          return this.httpClient.getData()
            .pipe(catchError(err => {
              // Handle errors
              console.error(err);
              return of(undefined);
            }));
        }),
        filter(data => data !== undefined)
      )
      .subscribe(data => {
        this.data = data;
      });
  }

  ngOnDestroy() {
    this.subscription.unsubscribe();
  }

  
}
