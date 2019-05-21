let userId;
let scanner;
let skinTones;
let contrast;
let bwContrast;
let expressScanning;
let special;
let invoiceContent;

let editing = false;
function editOrder() {
    if(!editing) {
        editing = true;
        let orderButtons = document.getElementById("orderDetailButtons");

        const saveButton = document.createElement('button');
        saveButton.setAttribute('type', 'button');
        saveButton.setAttribute('class', 'btn btn-success');
        saveButton.setAttribute('data-toggle', 'modal');
        saveButton.setAttribute('data-target', '#saveModal');
        saveButton.setAttribute('id', 'saveButton');
        const saveIcon = document.createElement('i');
        saveIcon.setAttribute('class', 'material-icons save-button');
        saveIcon.innerText = 'save';

        saveButton.appendChild(saveIcon);

        const cancelButton = document.createElement('button');
        cancelButton.setAttribute('type', 'button');
        cancelButton.setAttribute('class', 'btn btn-secondary');
        //cancelButton.setAttribute('onclick','cancelEditOrder()');
        cancelButton.setAttribute('id','cancelButton');
        cancelButton.setAttribute('data-toggle', 'modal');
        cancelButton.setAttribute('data-target', '#cancelModal');
        const cancelIcon = document.createElement('i');
        cancelIcon.setAttribute('class', 'material-icons cancel-button');
        cancelIcon.innerText = 'cancel';
        cancelButton.appendChild(cancelIcon);
        // cancelButton.innerText = "Cancel";

        orderButtons.insertBefore(cancelButton, orderButtons.firstChild);
        orderButtons.insertBefore(saveButton, orderButtons.firstChild);

        userId = document.getElementById("userIdFormControlInput").getAttribute("value");

        let scannerOptions = document.getElementById("scannerFormControlSelect").children;
        for(i = 0; i < scannerOptions.length; i++) {
            if(scannerOptions[i].hasAttribute("selected")){
                scanner = scannerOptions[i].textContent;
                break;
            }
        }

        let skinTonesOptions = document.getElementById("skinTonesFormControlSelect").children;
        for(i = 0; i < skinTonesOptions.length; i++) {
            if(skinTonesOptions[i].hasAttribute("selected")){
                skinTones = skinTonesOptions[i].textContent;
                break;
            }
        }

        let contrastOptions = document.getElementById("contrastFormControlSelect").children;
        for(i = 0; i < contrastOptions.length; i++) {
            if(contrastOptions[i].hasAttribute("selected")){
                contrast = contrastOptions[i].textContent;
                break;
            }
        }

        let bwContrastOptions = document.getElementById("bwContrastFormControlSelect").children;
        for(i = 0; i < bwContrastOptions.length; i++) {
            if(bwContrastOptions[i].hasAttribute("selected")){
                bwContrast = bwContrastOptions[i].textContent;
                break;
            }
        }

        let expressScanningOptions = document.getElementById("expressScanningFormControlSelect").children;
        for(i = 0; i < expressScanningOptions.length; i++) {
            if(expressScanningOptions[i].hasAttribute("selected")){
                expressScanning = expressScanningOptions[i].textContent;
                break;
            }
        }

        special = document.getElementById("specialFormControlTextarea").textContent;

        document.getElementById("userIdFormControlInput").removeAttribute("disabled");
        document.getElementById("scannerFormControlSelect").removeAttribute("disabled");
        document.getElementById("skinTonesFormControlSelect").removeAttribute("disabled");
        document.getElementById("contrastFormControlSelect").removeAttribute("disabled");
        document.getElementById("bwContrastFormControlSelect").removeAttribute("disabled");
        document.getElementById("expressScanningFormControlSelect").removeAttribute("disabled");
        document.getElementById("specialFormControlTextarea").removeAttribute("disabled");
        // orderButtons.appendChild(saveButton);
    }
}

function cancelEditOrder() {
    editing = false;
    document.getElementById("saveButton").remove();
    document.getElementById("cancelButton").remove();

    document.getElementById("userIdFormControlInput").value = userId;
    document.getElementById("userIdFormControlInput").setAttribute("disabled","");

    let scannerOptions = document.getElementById("scannerFormControlSelect").children;
    let currentScannerOptions = document.getElementById("scannerFormControlSelect").children;
    for (let i = 0; i < currentScannerOptions.length; i++) {
        if (currentScannerOptions[i].hasAttribute("selected")) {
            currentScannerOptions[i].removeAttribute("selected");
            break;
        }
    }
    for(let i = 0; i < scannerOptions.length; i++) {
        if (scannerOptions[i].value === scanner) {
            scannerOptions[i].setAttribute("selected","");
            break;
        }
    }
    document.getElementById("scannerFormControlSelect").setAttribute("disabled","");

    let skinTonesOptions = document.getElementById("skinTonesFormControlSelect").children;
    let currentSkinTonesOptions = document.getElementById("skinTonesFormControlSelect").children;
    for (let i = 0; i < currentSkinTonesOptions.length; i++) {
        if (currentSkinTonesOptions[i].hasAttribute("selected")) {
            currentSkinTonesOptions[i].removeAttribute("selected");
            break;
        }
    }
    for(let i = 0; i < skinTonesOptions.length; i++) {
        if (skinTonesOptions[i].value === skinTones) {
            skinTonesOptions[i].setAttribute("selected","");
            break;
        }
    }
    document.getElementById("skinTonesFormControlSelect").setAttribute("disabled","");

    let contrastOptions = document.getElementById("contrastFormControlSelect").children;
    let currentContrastOptions = document.getElementById("contrastFormControlSelect").children;
    for (let i = 0; i < currentContrastOptions.length; i++) {
        if (currentContrastOptions[i].hasAttribute("selected")) {
            currentContrastOptions[i].removeAttribute("selected");
            break;
        }
    }
    for(let i = 0; i < contrastOptions.length; i++) {
        if (contrastOptions[i].value === contrast) {
            contrastOptions[i].setAttribute("selected","");
            break;
        }
    }
    document.getElementById("contrastFormControlSelect").setAttribute("disabled","");

    let bwContrastOptions = document.getElementById("bwContrastFormControlSelect").children;
    let currentBWContrastOptions = document.getElementById("bwContrastFormControlSelect").children;
    for (let i = 0; i < currentBWContrastOptions.length; i++) {
        if (currentBWContrastOptions[i].hasAttribute("selected")) {
            currentBWContrastOptions[i].removeAttribute("selected");
            break;
        }
    }
    for(let i = 0; i < bwContrastOptions.length; i++) {
        if (bwContrastOptions[i].value === bwContrast) {
            bwContrastOptions[i].setAttribute("selected","");
            break;
        }
    }
    document.getElementById("bwContrastFormControlSelect").setAttribute("disabled","");

    let expressScanningOptions = document.getElementById("expressScanningFormControlSelect").children;
    let currentExpressScanningOptions = document.getElementById("expressScanningFormControlSelect").children;
    for (let i = 0; i < currentExpressScanningOptions.length; i++) {
        if (currentExpressScanningOptions[i].hasAttribute("selected")) {
            currentExpressScanningOptions[i].removeAttribute("selected");
            break;
        }
    }
    for(let i = 0; i < expressScanningOptions.length; i++) {
        if (expressScanningOptions[i].value === expressScanning) {
            expressScanningOptions[i].setAttribute("selected","");
            break;
        }
    }
    document.getElementById("expressScanningFormControlSelect").setAttribute("disabled","");

    document.getElementById("specialFormControlTextarea").value = special;
    document.getElementById("specialFormControlTextarea").setAttribute("disabled","");

    // orderButtons.appendChild(saveButton);
}

function setInvoiceContent(invoiceContent1) {
    invoiceContent = invoiceContent1;
    console.log(self.invoiceContent);
}