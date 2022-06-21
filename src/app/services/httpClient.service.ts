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

  getData(): Observable<any> {
    const url = `${this.apiurl}/module`;
    return this.httpClient
      .get<any>(url, this.httpOptions);
  }




  
}
