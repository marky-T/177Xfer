import { Component, OnDestroy, OnInit} from '@angular/core';
import { FormBuilder, ReactiveFormsModule} from '@angular/forms';
import { Router} from "@angular/router";
import {A11yModule} from '@angular/cdk/a11y';
import {
  CommunicationService, FormBase, FormField, MessageService, NavigationStateService
} from '@avanade-ltcoe/components-ng-base';
import {SecurityService, AutoTabDirective} from '@avanade-ltcoe/common-frontend-angular';
import {ComponentsNgIbmModule} from "@avanade-ltcoe/components-ng-ibm";
import { <CLASS_NAME>Data} from "./<FORM_NAME>-data";

@Component({
  selector:'app-<FORM_NAME>',
  templateUrl: './<FORM_NAME>.component.html',
  styleUrls: ['./<FORM_NAME>.component.scss'],
  imports: [A11yModule, ReactiveFormsModule, ComponentsNgIbmModule, AutoTabDirective],
  standalone: true
})

export class <CLASS_NAME>Component extends FormBase <<CLASS_NAME>Data> implements OnInit, OnDestroy {
  data!: <CLASS_NAME>Data;
  fkObservableRef!: any;
  <COMP_NAME>Group!: any;

  constructor(private readonly fb: FormBuilder, protected router: Router,
              protected navigationStateService: NavigationStateService,
              protected communicationService: CommunicationService,
              protected messageService: MessageService, securityService: SecurityService) {
    super (router, navigationStateService, communicationService, messageService, securityService);
    this.<COMP_NAME>Group = this.fb.group({
    <FORM_ITEMS>
    });
    this.fkObservableRef = this.communicationService.onKeyPressed().subscribe((key: string) => {
      super.functionKeyPressed(key, this.<COMP_NAME>Group.value as <CLASS_NAME>Data);
    });
  }

  ngOnInit () : void {
    super.ngOnInit();
    this.<COMP_NAME>Group.patchValue(super.getFieldData());
    this.data = super.getFieldData();
  }

  onSubmit () {
    super.transmitTransaction(this.<COMP_NAME>Group.value as <CLASS_NAME>Data);
  }

  ngOnDestroy() {
    this.fkObservableRef.unsubscribe();
  }
}
