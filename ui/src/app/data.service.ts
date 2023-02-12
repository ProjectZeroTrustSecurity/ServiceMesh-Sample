import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';

@Injectable()
export class DataService {

  private expressions = new BehaviorSubject<any>([]);
  expression = this.expressions.asObservable();

  constructor() { }

  changeExpression(expression) {
    this.expressions.next(expression);
  }
}
