({
    changePageNumber : function(component) {
        let pageNum = component.get("v.currentPageNum");
        let event = component.getEvent("changePage");
        event.setParams({"PageNumber": pageNum});
        event.fire();
    }
})
