// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.
function ShowError(vmsg) {
    Swal.fire({
        text: vmsg,
        icon: "error",
        buttonsStyling: false,
        confirmButtonText: "Ok",
        customClass: {
            confirmButton: "btn btn-primary",
        }
    });
}