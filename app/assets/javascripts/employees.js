function validateEmployeeForm() {

  var name            = document.getElementById("name");
  var identification  = document.getElementById("identification");
  var selectRole      = document.getElementById("selectRole");
  var stalls          = document.getElementById("stalls");
  var payment_method  = document.getElementById("payment_method");
  var bank            = document.getElementById("bank");
  var account         = document.getElementById("account");
  var social_security = document.getElementById("social_security");
  var sub_service     = document.getElementById("sub_service");

  var result    = true

  if (name.value == "") {
    errorHandler(name, "name_error", "Campo obligatorio");
    result = false;
  }
  if (identification.value == "") {
    errorHandler(identification, "identification_error", "Campo obligatorio");
    result = false;
  }
  else{
    identification.value = identification.value.replace(/-/g,'');
  }
  if (selectRole.value == "") {
    errorHandler(selectRole, "selectRole_error", "Campo obligatorio");
    result = false;
  }
  if (stalls.value == "") {
    errorHandler(stalls, "stalls_error", "Campo obligatorio");
    result = false;
  }
  if (payment_method.value == "") {
    errorHandler(payment_method, "payment_method_error", "Campo obligatorio");
    result = false;
  }
  if (bank.value == "") {
    errorHandler(bank, "bank_error", "Campo obligatorio");
    result = false;
  }
  else{
    account.value = account.value.replace(/-/g,'');
  }
  if (social_security.value == "") {
    errorHandler(social_security, "social_security_error", "Campo obligatorio");
    result = false;
  }
  if (sub_service.value == "") {
    errorHandler(sub_service, "sub_service_error", "Campo obligatorio");
    result = false;
  }
  return result;
}

function filterEmployee(){
  var employees = JSON.parse(document.querySelector('#employee').dataset.employees);
  var search = $('#employee').val().toUpperCase();
  var ids = [0];
  employees.forEach(function(employee) {
    if (employee.name.toUpperCase().includes(search) || employee.identification.includes(search)) {
      ids.push(employee.id);
    }
  });
  $.ajax({
    type: "GET",
    url: "/admin/employees/",
    data:
    {
      utf8: "✓",
      ids: ids
    }
  });
}

function filterInactiveEmployee(){
  var employees = JSON.parse(document.querySelector('#employee').dataset.employees);
  var search = $('#employee').val().toUpperCase();
  var ids = [0];
  employees.forEach(function(employee) {
    if (employee.name.toUpperCase().includes(search) || employee.identification.includes(search)) {
      ids.push(employee.id);
    }
  });
  $.ajax({
    type: "GET",
    url: "/admin/inactive/employees/",
    data:
    {
      utf8: "✓",
      ids: ids
    }
  });
}

function generatePDFFile(element, entryDate, departure_date){

  var lineCode          = $(element).next().attr('name').split(']')[1].replace('[', '');
  var employee          = JSON.parse(document.querySelector('#nested-fields').dataset.employee);
  var start_date        = $("input[name*='employee[vacations_attributes]["+lineCode+"][start_date]']");
  var end_date          = $("input[name*='employee[vacations_attributes]["+lineCode+"][end_date]']");
  var requested_days    = $("input[name*='employee[vacations_attributes]["+lineCode+"][requested_days]']");
  var included_freedays = $("input[name*='employee[vacations_attributes]["+lineCode+"][included_freedays]']"); 
  var period            = $("input[name*='employee[vacations_attributes]["+lineCode+"][period]']");
  var today             = $("input[name*='employee[vacations_attributes]["+lineCode+"][date]']"); 
  var total_days        = $("#total_days_th");
  var used_days         = $("#used_days_th");
  var avalaible_days    = $("#available_days_th");

  var url = "https://www.pasecocr.com/admin/employees/"+employee.id+"/vacations/file.pdf";
  var params = "?start_date=" + start_date.val() + "&requested_days=" + requested_days.val() + "&end_date=" + end_date.val() +
               "&included_freedays=" + included_freedays.val() + "&total_days=" + total_days.text() + "&used_days=" + used_days.text() +
               "&avalaible_days=" + avalaible_days.text() + "&employee_name=" + employee.name + "&employee_identification=" +
               employee.identification + "&date=" + today.val() + "&entry_date=" + entryDate + "&departure_date=" + departure_date + "&stall=" + employee.stalls[0].name +
               "&area=" + employee.positions[0].area.name + "&period=" + period.val();

  window.open(url+params, '_blank');

}

function registerEmployee(employeeID){

    var form_data = $("form").serialize() + '&id=' + employeeID; //Encode form elements for submission

    $.ajax({
      type: "PATCH",
      url: "/",
      data: form_data
    });
  }

function inactiveEmployeeAlert(){
  alert("Si desea desactivar a este colaborador, por favor recuerde no dejar movimientos automáticos, periodos de contratación ó incapacidades sin fecha de fin, ya que en caso de activar nuevamente este colaborador en el futuro, estos podrian ser tomados en cuenta nuevamente por el sistema.");
}



