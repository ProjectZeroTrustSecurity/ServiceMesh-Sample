import { Component, OnInit } from '@angular/core';
import { trigger, style, transition, animate, keyframes, query, stagger } from '@angular/animations';

import { DataService } from '../data.service';
import { Observable } from 'rxjs/Rx';

import { environment } from '../../environments/environment';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';

const httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss'],
  animations: [
    trigger('expressions', [
      transition('* => *', [
        query(':enter', style({ opacity: 0 }), {optional: true}),

        query(':enter', stagger('300ms', [
          animate('.6s ease-in', keyframes([
            style({opacity: 0, transform: 'translateY(-75%)', offset: 0}),
            style({opacity: .5, transform: 'translateY(35px)', offset: .3}),
            style({opacity: 1, transform: 'translateY(0)', offset: 1}),
          ]))
        ]), {optional: true})
      ])
    ])
  ]
})

export class HomeComponent implements OnInit {
  exprtoprocess = '{ "x1": "10 + 5", "x2": "10 - 5", "x3": "10 * 5", "x4": "10 / 5" }';
  expressions = [];

  constructor(private _data: DataService, public http: HttpClient) { }

  ngOnInit() {
    this._data.expression.subscribe(res => this.expressions = res);
    this._data.changeExpression(this.expressions);
  }

  submitExpressions() {
    this.http.post<any>(environment.processorUrl, this.exprtoprocess, {headers: httpOptions.headers}).subscribe( data => {
      for (const result of data.results) {
        this.expressions.push(result);
        this._data.changeExpression(this.expressions);
      }
    });
  }

  clearResults() {
    const exprCount = this.expressions.length;
    if (exprCount >= 1) {
      this.expressions.splice(0, exprCount);
      this._data.changeExpression(this.expressions);
    }
  }
}
