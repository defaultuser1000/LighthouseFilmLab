let scannerName;
let yearOfProduction;
let shortInfo;

let editing = false;
function edit() {
    if(!editing) {
        editing = true;
        let buttons = document.getElementById("detailButtons");

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

        buttons.insertBefore(cancelButton, buttons.firstChild);
        buttons.insertBefore(saveButton, buttons.firstChild);

        scannerName = document.getElementById("scannerName").getAttribute("value");

        yearOfProduction = document.getElementById("yearOfProduction").getAttribute("value");

        shortInfo = document.getElementById("shortInfo").textContent;

        document.getElementById("scannerName").removeAttribute("disabled");
        document.getElementById("yearOfProduction").removeAttribute("disabled");
        document.getElementById("shortInfo").removeAttribute("disabled");
        // buttons.appendChild(saveButton);
    }
}

function cancelEdit() {
    editing = false;
    document.getElementById("saveButton").remove();
    document.getElementById("cancelButton").remove();

    document.getElementById("scannerName").value = scannerName;
    document.getElementById("scannerName").setAttribute("disabled","");

    document.getElementById("yearOfProduction").value = yearOfProduction;
    document.getElementById("yearOfProduction").setAttribute("disabled","");

    document.getElementById("shortInfo").value = shortInfo;
    document.getElementById("shortInfo").setAttribute("disabled","");

    // orderButtons.appendChild(saveButton);
}