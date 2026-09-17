
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import {ErrorPageComponent, LoginComponent} from "@avanade-ltcoe/common-frontend-angular";
import { InitialFormComponent } from "@avanade-ltcoe/components-ng-base"
<FORM_IMPORTS>


const applicationName: string = '<APP_NAME>';

const routes: Routes = [
  {
    path: "login",
    component: LoginComponent,
    title: `${applicationName} - Login`
  },
  {
    path: "error/:message",
    component: ErrorPageComponent,
    title: `${applicationName} - Error`
  },
  {
    path: "app",
    children: [
      {
        path: "dashboard",
        component: InitialFormComponent,
        title: `${applicationName} - Dashboard`,
      },
      {
        path: "form",
        children: [
<FORM_ROUTES>
        ]
      }
    ]
  }];


@NgModule({
  imports: [RouterModule.forRoot(routes, {
    onSameUrlNavigation: 'reload'
  })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
