window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "open") {
        document.getElementById('app').style.display = 'flex';
        const garageNameElem = document.getElementById('garage-name');
        if (garageNameElem) garageNameElem.innerText = data.garage;
        renderVehicles(data.vehicles, data.garage, false);
    } else if (data.action === "openImpound") {
        document.getElementById('app').style.display = 'flex';
        const garageNameElem = document.getElementById('garage-name');
        if (garageNameElem) garageNameElem.innerText = "FOURRIÈRE";
        renderVehicles(data.vehicles, "Fourrière", true, data.price);
    }
});

function renderVehicles(vehicles, garageName, isImpound, price) {
    const container = document.getElementById('vehicle-list');
    container.innerHTML = '';

    if (!vehicles || vehicles.length === 0) {
        container.innerHTML = '<div class="no-vehicles">Aucun véhicule trouvé</div>';
        return;
    }

    vehicles.forEach((vehicle, index) => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.style.animationDelay = `${index * 0.05}s`;

        // Use custom image if defined, otherwise try model name, otherwise default
        const imgSrc = vehicle.image !== "default.png" ? `img/${vehicle.image}` : `img/${vehicle.name.toLowerCase()}.png`;

        let actionButtons = '';
        if (isImpound) {
            actionButtons = `
                <button class="btn btn-primary" onclick="payImpound('${vehicle.plate}', ${price})">
                    <i class="fa-solid fa-money-bill-wave"></i> RÉCUPÉRER ($${price})
                </button>
            `;
        } else {
            actionButtons = `
                <button class="btn btn-primary" onclick="spawnVehicle('${vehicle.plate}', '${garageName}')">
                    <i class="fa-solid fa-car"></i> Sortir
                </button>
                <button class="btn btn-secondary" onclick="transferVehicle('${vehicle.plate}')">
                    <i class="fa-solid fa-arrow-right-arrow-left"></i>
                </button>
            `;
        }

        card.innerHTML = `
            <img src="${imgSrc}" class="vehicle-img" onerror="this.src='img/default.png'">
            <div class="vehicle-name">${vehicle.name || 'Véhicule'}</div>
            <div class="vehicle-plate"><span>${vehicle.plate}</span></div>
            <div class="vehicle-actions">
                ${actionButtons}
            </div>
        `;
        container.appendChild(card);
    });
}

function closeUI() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function payImpound(plate, price) {
    fetch(`https://${GetParentResourceName()}/payImpound`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            plate: plate,
            price: price
        })
    }).then(() => closeUI());
}

function spawnVehicle(plate, garage) {
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        body: JSON.stringify({ plate, garage })
    });
    document.getElementById('app').style.display = 'none';
}

let currentTransferPlate = null;
let allGarageNames = ["Main", "Sandy Shores", "Paleto Bay", "Vinewood", "South LS"];

function transferVehicle(plate) {
    currentTransferPlate = plate;
    const container = document.getElementById('garage-options');
    container.innerHTML = '';

    // Get current garage name from the header
    const currentGarage = document.getElementById('garage-name').innerText;

    allGarageNames.forEach(name => {
        if (name !== currentGarage) {
            const btn = document.createElement('div');
            btn.className = 'garage-option';
            btn.innerText = name;
            btn.onclick = () => confirmTransfer(name);
            container.appendChild(btn);
        }
    });

    document.getElementById('transfer-modal').style.display = 'flex';
}

function confirmTransfer(target) {
    fetch(`https://${GetParentResourceName()}/transferVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            plate: currentTransferPlate,
            target: target
        })
    }).then(() => {
        closeTransferModal();
        closeUI();
    });
}

function closeTransferModal() {
    document.getElementById('transfer-modal').style.display = 'none';
    currentTransferPlate = null;
}

document.onkeydown = (e) => {
    if (e.key === "Escape") {
        closeUI();
    }
};
