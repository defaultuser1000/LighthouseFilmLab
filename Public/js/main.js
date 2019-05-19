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