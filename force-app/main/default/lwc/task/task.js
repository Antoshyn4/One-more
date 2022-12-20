import { LightningElement } from 'lwc';

export default class Task extends LightningElement {
    arr = [];
    connectedCallback(){
        let map = new Map();
        map.set("a",11);
        map.set("b",2);
        map.set("c",5);
        console.log("Check");
        for (const key in map.keys()) {
            console.log("Test");
            console.log(key);
        }
    }
}