import { LightningElement, track, wire } from 'lwc';
import getAllCount from '@salesforce/apex/ComponentCustomSettings.getAllCount';
import getColumnsCount from '@salesforce/apex/ComponentCustomSettings.getColumnsCount';
import getPageElementsCount from '@salesforce/apex/ComponentCustomSettings.getPageElementsCount';

export default class MyPage extends LightningElement {

    @wire(getColumnsCount)
    countOfColumns;
    @wire(getAllCount)
    countOfAllElements;
    @wire(getPageElementsCount)
    countOfPageElements;

    pageNum = 1;

    countOfPages;

    reDraw(event){
        this.countOfPages = Math.ceil(this.countOfAllElements.data/this.countOfPageElements.data);
        this.pageNum = event.detail;
        this.template.querySelector('c-list-of-items').setpgNum(this.pageNum);
    }
}