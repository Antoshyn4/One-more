({
    closeModel: function(component, event, helper) {
       // Set isModalOpen attribute to false  
       component.set("v.isModalOpen", false);
    },
    saveResults : function(component, event, helper) {
       let a = event.getSource();
       let value = a.get("v.value");
       let field =  a.get("v.fieldName");

       let updateRecordAction = component.get("c.upsertSObject");
       let opt = component.get("v.options");
       switch (field) {
           case 'Name' :
               alert(component.get("v.ErrorMessage"));
               debugger;
               a.set("v.value", opt[helper.check(opt, component, 'Name')].value);
               //value = opt[helper.check(opt, component, 'Name')].value;
               break;
           case 'Phone':
               value = value.replace('\ ','-');
               value = value.replace(/^\-/,'-');
               if (/[a-zA-Z]/g.test(value) || /^\-/.test(value) || /(?!\-)[^\w\s]/.test(value) || /^\-{1,99}/g.test(value)) {
                  alert('Incorrect phone number');
                  
                  value = value.replace(/[a-zA-Z]/g,'');
                  value = value.replace(/^\-/,'-');
                  value = value.replace('\ ','-');
                  value = value.replace(/(?!\-)[^\w\s]/,'');
                  value = value.replace(/^\-{1,99}/g,''); 
               }
               opt[helper.check(opt, component, field)].value = value;
               updateRecordAction.setParams({
                  'fieldName' : field,
                  'newValue' : value,
                  'objectsId' : component.get("v.recordId")
               });
               component.set("v.options", opt);
               $A.enqueueAction(updateRecordAction);
               break;
           case 'Fax':  
               value = value.replace('\ ','-');
               value = value.replace(/^\-/,'-');
               if (/[a-zA-Z]/g.test(value) || /^\-/.test(value) || /(?!\-)[^\w\s]/.test(value) || /^\-{1,99}/g.test(value)) {
                  alert('Incorrect phone number');
                  
                  value = value.replace(/[a-zA-Z]/g,'');
                  value = value.replace(/^\-/,'-');
                  value = value.replace('\ ','-');
                  value = value.replace(/(?!\-)[^\w\s]/,'');
                  value = value.replace(/^\-{1,99}/g,''); 
               }
               opt[helper.check(opt, component, field)].value = value;
               updateRecordAction.setParams({
                  'fieldName' : field,
                  'newValue' : value,
                  'objectsId' : component.get("v.recordId")
               });
               component.set("v.options", opt);   
               $A.enqueueAction(updateRecordAction);
               break;
           default:
               opt[helper.check(opt, component, field)].value = value;
               updateRecordAction.setParams({
                  'fieldName' : field,
                  'newValue' : value,
                  'objectsId' : component.get("v.recordId")
               });
               component.set("v.options", opt);   
               $A.enqueueAction(updateRecordAction);
               break;
       }
    },
 })