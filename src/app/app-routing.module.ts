import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AppComponent } from './app.component';
import { ModuleButtonComponent } from './components/module_button/module_button.component';

const routes: Routes = [
  { path: '', component: ModuleButtonComponent},
  { path: 'data', component: ModuleButtonComponent},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
