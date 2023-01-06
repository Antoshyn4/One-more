({
    check : function(Arr, component, find) {
        let index = 0;
        for (const key in Arr) {
            if (Arr[key].label == find) {
                return index;
            }
            index++;
        }
        return -1;
    }
})
