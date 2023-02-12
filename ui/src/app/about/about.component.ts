import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-about',
  templateUrl: './about.component.html',
  styleUrls: ['./about.component.scss']
})
export class AboutComponent implements OnInit {

  pageType:String = 'detailed';
  constructor(private route: ActivatedRoute) { 
    this.route.params.subscribe(params => {
      if (params['type']) {
        this.pageType = params['type'];
      }
    });
  }

  ngOnInit() {
  }

}
