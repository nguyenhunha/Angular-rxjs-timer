import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/internal/Observable';
import { throwError } from 'rxjs/internal/observable/throwError';

@Injectable({
  providedIn: 'root'
})
export class HttpClientService {
  private apiurl = 'http://103.179.190.233:8888/api';
  private httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json'
      // 'charset': 'utf-8',
      // Authorization: 'my-auth-token'
    })  
  }

  constructor(private httpClient: HttpClient) { }

  getData() {
    const url = `${this.apiurl}/module`;
    return this.httpClient
      .get<any>(url, this.httpOptions);
  }

  private handleError(err: HttpErrorResponse): Observable<never> {
    let errorMessage: string;
    if (err.error instanceof ErrorEvent) {
      errorMessage = `An error occurred: ${err.error.message}`;
    } else {
      errorMessage = `Backend returned code ${err.status}: ${err.message}`;
    }
    console.error(err);
    return throwError(() => errorMessage);
  }
}
