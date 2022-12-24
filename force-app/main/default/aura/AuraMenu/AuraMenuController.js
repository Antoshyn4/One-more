({
    drawFirstPage : function(component, event, helper) {
        component.set("v.currentPageNum", 1);
        helper.changePageNumber(component);
    },
    drawPreviousPage : function(component, event, helper) {
        component.set("v.currentPageNum", component.get("v.currentPageNum") - 1);
        helper.changePageNumber(component);
    },
    drawNextPage : function(component, event, helper) {
        component.set("v.currentPageNum", component.get("v.currentPageNum") + 1);
        helper.changePageNumber(component);
    },
    drawLastPage : function(component, event, helper) {
        component.set("v.currentPageNum", component.get("v.countOfPages"));
        helper.changePageNumber(component);
    },
    drawSomePage : function(component, event, helper) {
        let input = event.getSource();
        let number = input.get("v.value");
        if (number < 1) {
            number = 1;
        }
        else if (number > component.get("v.countOfPages")) {
            number = component.get("v.countOfPages");
        }
        component.set("v.currentPageNum", number);
        helper.changePageNumber(component);
    }
})
