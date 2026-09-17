
import { Component, HostListener } from '@angular/core';
import { AuthService, SettingsService, SecurityService } from "@avanade-ltcoe/common-frontend-angular";
import { FunctionKeyService } from "@avanade-ltcoe/components-ng-base";
import { MatIconRegistry } from "@angular/material/icon";
import {DomSanitizer, Title} from "@angular/platform-browser";
import {Observable} from "rxjs";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  standalone: false
})
export class AppComponent {
  userName = "";
  isDarkTheme: Observable<boolean>;

  @HostListener('window:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    this.functionKeyService.handleKey(event);
  }

  @HostListener('document:click')
  onClick() {
    this.authService.refreshTokenIfExpiresSoon();
  }

  @HostListener('document:keypress')
  handleKeyPress() {
    this.authService.refreshTokenIfExpiresSoon();
  }

  getTitle(): string {
    return this.titleService.getTitle();
  }

  constructor(
    private readonly settingsService: SettingsService,
    private readonly matIconRegistry: MatIconRegistry,
    private readonly domSanitizer: DomSanitizer,
    private readonly authService: AuthService,
    private readonly functionKeyService: FunctionKeyService,
    private readonly securityService: SecurityService,
    private readonly titleService: Title
  ) {
    this.matIconRegistry.addSvgIcon(`icon`, this.domSanitizer.bypassSecurityTrustResourceUrl(`./assets/icon.svg`));

    this.authService.checkConfiguration().then(() => {
      this.userName = this.authService.userName;
      this.securityService.getUserDataWithRedirect('/app/dashboard');
    })

    this.isDarkTheme = this.settingsService.isDarkTheme;
  }

  toggleDarkTheme(checked: boolean) {
    this.settingsService.setDarkTheme(checked);
  }

  logout(): void {
    this.authService.logoff();
  }
}
