import { LightningElement } from 'lwc';

export default class Augmentor extends LightningElement {
    maximizer = 1000000;
    startCounter = 0;
    handleStartChange(event) {
      this.startCounter = parseInt(event.target.value);
    }
    handleMaximizeCounter() {
        this.template.querySelector('c-numerator').maximizeCounter(this.maximizer);
      }
    handleMaxChange(event){
        this.maximizer = event.target.value;
    }
    handler(event){
        alert("Test");
    }
}