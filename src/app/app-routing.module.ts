import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AppComponent } from './app.component';
import { DataEmitterComponent } from './data-emitter/data-emitter.component';

const routes: Routes = [
  { path: '', component: DataEmitterComponent},
  { path: 'data', component: DataEmitterComponent},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
