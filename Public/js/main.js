function sideNavAction() {
    let sideNav = document.querySelector('#mySidenav');
    const sideNavComputedWidth = getComputedStyle(sideNav);
    if (sideNavComputedWidth.width !== "0px") {
        document.getElementById("mySidenav").style.width = "0";
        //document.getElementById("main-container").style.paddingLeft = "0";
        //document.getElementById("middle-header").style.marginLeft = "0";
    } else {
        document.getElementById("mySidenav").style.width = "250px";
        //document.getElementById("main-container").style.paddingLeft = "250px";
        //document.getElementById("middle-header").style.marginLeft = "260px";
    }
}

window.addEventListener('DOMContentLoaded', function(e) {

    let dateFields = document.getElementsByClassName('dateCreated');
    for (let i = 0; i < dateFields.length; i++) {
        const cellDate = dateFields.item(i).textContent;
        let date = new Date(1970, 0, 1);
        date.setSeconds(cellDate);
        const day = date.getDate();
        let month = "";
        if ((date.getMonth() + 1) < 10) {
            month = "0" + (date.getMonth() + 1);
        } else {
            month = date.getMonth() + 1;
        }
        const year = date.getFullYear();
        const hours = date.getHours();
        const minutes = date.getMinutes();
        dateFields.item(i).textContent = day + "." + month + "." + year + ", " + hours + ":" + minutes;
    }
} );

$(document).ready(function() {

    $('#orders-table tbody tr').click(function() {
        let href = $(this).find("a").attr("href");
        if(href) {
            window.location = href;
        }
    });
});