import { Component, Input, OnDestroy, OnInit, Output } from '@angular/core';
import { Observable, of, Subscription, throwError, timer } from 'rxjs';
import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { catchError, filter, switchMap } from "rxjs/operators";

@Component({
  selector: 'app-data-emitter',
  templateUrl: './data-emitter.component.html',
  styleUrls: ['./data-emitter.component.scss']
})
export class DataEmitterComponent implements OnInit, OnDestroy {
  @Output() data: any;

  private apiurl = 'http://103.179.190.233:8888/api';
  private httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      // 'charset': 'utf-8',
      // Authorization: 'my-auth-token'
    })
  }

  second: number = 1;
  subscription: Subscription = new Subscription;

  constructor(private httpClient: HttpClient) {}

  ngOnInit() {
    this.subscription = timer(0, this.second * 1000)
      .pipe(
        switchMap(() => {
          return this.getData()
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
        // console.log(this.data);
      });
  }

  ngOnDestroy() {
    this.subscription.unsubscribe();
  }

  getData() {
    const url = `${this.apiurl}/DHT11`;
    return this.httpClient
      .get<any>(url, this.httpOptions);
  }

  private handleError(err: HttpErrorResponse): Observable<never> {
    // in a real world app, we may send the server to some remote logging infrastructure
    // instead of just logging it to the console
    let errorMessage: string;
    if (err.error instanceof ErrorEvent) {
      // A client-side or network error occurred. Handle it accordingly.
      errorMessage = `An error occurred: ${err.error.message}`;
    } else {
      // The backend returned an unsuccessful response code.
      // The response body may contain clues as to what went wrong,
      errorMessage = `Backend returned code ${err.status}: ${err.message}`;
    }
    console.error(err);
    return throwError(() => errorMessage);
  }
}
