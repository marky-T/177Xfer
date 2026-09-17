
import { APP_INITIALIZER, NgModule } from '@angular/core';
import { BrowserModule, Title } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { AmtRouteReuseStrategy, ComponentsNgBaseModule } from '@avanade-ltcoe/components-ng-base';
import { ComponentsNgIbmModule } from '@avanade-ltcoe/components-ng-ibm';
import { OidcConfig, CommonFrontendAngularModule, OAuthInterceptor, HttpErrorInterceptor, InternalErrorService } from "@avanade-ltcoe/common-frontend-angular"
import { HTTP_INTERCEPTORS, HttpClientModule } from "@angular/common/http";
import { ReactiveFormsModule } from '@angular/forms';
import { RouteReuseStrategy } from "@angular/router";
import { MatListModule } from "@angular/material/list";
import { MatIconModule } from "@angular/material/icon";
import { MatExpansionModule } from "@angular/material/expansion";
import { MatSidenavModule } from "@angular/material/sidenav";
import { MatToolbarModule } from "@angular/material/toolbar";
import { MatSlideToggleModule } from "@angular/material/slide-toggle";
import { MatMenuModule } from "@angular/material/menu";
import { MatButtonModule } from "@angular/material/button";
import { OAuthModule, OAuthStorage } from "angular-oauth2-oidc";

export function initializeApp(oidcConfig: OidcConfig) {
  return () => oidcConfig.readConfiguration("assets/oidcconfig.json");
}

export function storageFactory(): OAuthStorage {
  return localStorage;
}

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    CommonFrontendAngularModule,
    ComponentsNgIbmModule,
    ComponentsNgBaseModule,
    HttpClientModule,
    ReactiveFormsModule,
    MatListModule,
    MatIconModule,
    MatExpansionModule,
    MatSidenavModule,
    MatToolbarModule,
    MatSlideToggleModule,
    MatMenuModule,
    MatButtonModule,
    OAuthModule.forRoot({
      resourceServer: {
        allowedUrls: ["http://localhost:10000/api"],
        sendAccessToken: true
      }
    }),
  ],
  providers: [
    OidcConfig,
    Title,
    {
      provide: APP_INITIALIZER,
      useFactory: initializeApp,
      deps: [OidcConfig],
      multi: true
    },
    { provide: HTTP_INTERCEPTORS, useClass: HttpErrorInterceptor, multi: true, deps: [InternalErrorService] },
    { provide: HTTP_INTERCEPTORS, useClass: OAuthInterceptor, multi: true },
    { provide: OAuthStorage, useFactory: storageFactory },
    { provide: RouteReuseStrategy, useClass: AmtRouteReuseStrategy }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
