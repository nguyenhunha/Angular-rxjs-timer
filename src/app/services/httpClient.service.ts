import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Injectable, Input } from '@angular/core';
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

  

  viewStatusBy(data: any){
    const url = `${this.apiurl}/module/viewStatusBy`;
    return this.httpClient
      .post<any>(url, data, this.httpOptions);
  }

  viewButtonBy(data: any){
    const url = `${this.apiurl}/module/viewButtonBy`;
    return this.httpClient
      .post<any>(url, data, this.httpOptions);
  }

  viewActionBy(data: any){
    const url = `${this.apiurl}/module/viewActionBy`;
    return this.httpClient
      .post<any>(url, data, this.httpOptions);
  }

}
