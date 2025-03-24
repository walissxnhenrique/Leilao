let currentAuction = null;
let notificationInterval = null;
let cordenadas = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    switch (data.type) {
        case 'showUI':
            document.body.style.display = 'block';
         
            document.getElementById("container").style.display = "flex" ;
            document.getElementById("container").style.animation = "popUp 0.3s ease-out forwards"; // Aplica a animação de entrada
    
            break;
        case 'hideUI':
            // document.body.style.display = 'none';
            document.getElementById("container").style.animation = "popOut 0.3s ease-out forwards"; // Aplica a animação de saída
            setTimeout(() => {
                document.getElementById("container").style.display = "none" ;
                document.getElementById("container2").style.display = "none" ;
            }, 300);
         
            break;
        case 'updateAuction':
            document.body.style.display = 'block';
            updateAuctionData(data.auction);
       
            
            break;
        case 'showToast':
            document.body.style.display = 'block';
            showToast(data.message, data.status);
            break;
        case 'StarNotificacao':
            document.body.style.display = 'block';
            updateAuctionData(data.auction);
            setupNotificationSystem(data.auction);
            document.getElementById('Command').textContent = `/${data.auction.command}`;
            break;
        case 'StopSorteio':
            // document.body.style.display = 'none';
            // document.getElementById("container").style.display = "none" ;
            notificationInterval = null
            currentAuction = null
            const notification = document.getElementById('auctionNotification');
            notification.style.display = 'none';
            document.getElementById("container2").style.display = "none" ;
            break;
        case 'showUICad':
            document.body.style.display = 'block';
            document.getElementById("container2").style.display = "flex" ;
            atualizarOpcoes(data.typesLeilao); 
            
            // document.getElementById("StartLeilao").style.display = "flex" ;
            // document.getElementById("container").style.animation = "popUp 0.3s ease-out forwards"; // Aplica a animação de entrada
    
         break;

        case 'UPDATE_PENDING_LOC':
         document.body.style.display = 'block';
         cordenadas = data.coords

         let timerSection = document.querySelector("#btnIniciarLoc"); // Seleciona o elemento pelo CSS

        timerSection.style.background = "#047857"; // Muda a cor para amarelo quando faltar menos de 4 minutos
        document.getElementById('tooltip').textContent = ` Localização Marcada`;
  
   

        break;
        

        

                
            
     
    }
});

function updateAuctionData(auction) {
    currentAuction = auction;
    
    // Update main UI
    document.getElementById('itemName').textContent = auction.itemName;
    document.getElementById('currentBid').textContent = auction.currentBid.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    document.getElementById('auctionStatus').textContent = auction.status;
    if (auction.remainingTime < 1) {
       
        document.getElementById('remainingTime').textContent = `Menos de um minuto`;
        document.getElementById('notifRemainingTime').textContent = `Menos de um minuto`;
    } else if (auction.remainingTime < 2) {
        document.getElementById('remainingTime').textContent = `${auction.remainingTime} minuto`;
        document.getElementById('notifRemainingTime').textContent = `${auction.remainingTime} minuto`;
    } else {
        document.getElementById('remainingTime').textContent = `${auction.remainingTime} minutos`;
        document.getElementById('notifRemainingTime').textContent = `${auction.remainingTime} minutos`;
    }

    if (auction.remainingTime < 2) {
  
  
        let timerSection = document.querySelector(".timer-section"); // Seleciona o elemento pelo CSS

    timerSection.style.background = "#ec0404"; // Muda a cor para amarelo quando faltar menos de 4 minutos
    timerSection.style.animation = "pulse 1s infinite"; // Faz a animação repetir infinitamente
    } else if (auction.remainingTime < 4) {

        let timerSection2 = document.querySelector(".timer-section"); // Seleciona o elemento pelo CSS
        timerSection2.style.animation = "pulse 1s infinite"; // Faz a animação repetir infinitamente
        timerSection2.style.background = "#fae502"; // Muda a cor para amarelo quando faltar menos de 4 minutos
  
    } else {
        let timerSection2 = document.querySelector(".timer-section"); // Seleciona o elemento pelo CSS

        timerSection2.style.background = "#047857"; // Muda a cor para amarelo quando faltar menos de 4 minutos
        timerSection2.style.animation = "none"; // Para a animação após 60s
    }
  
    
    if (auction.highestBidder) {
        document.getElementById('highestBidder').textContent = `Maior lance: ${auction.highestBidder}`;
        document.getElementById('winnerName').textContent = `${auction.winnerId} - ${auction.highestBidder}`;
   
    }

    document.getElementById('bidInput').min = auction.currentBid + 1;
    
    // Update notification UI
    document.getElementById('notifItemName').textContent = auction.itemName;
    document.getElementById('notifCurrentBid').textContent = auction.currentBid.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    document.getElementById('notifHighestBidder').textContent = auction.highestBidder || '-';

 
}

function setupNotificationSystem(auction) {
    if (!auction) {
        if (notificationInterval) {
            clearInterval(notificationInterval);
            notificationInterval = null;
        }
        return;
    }

    // Clear existing interval if any
    if (notificationInterval) {
        clearInterval(notificationInterval);
    }

    // Show notification immediately
    showNotification();

    // Set up 5-minute interval
    notificationInterval = setInterval(showNotification, auction.timeaviso * 1000);
}

function showNotification() {
    if (!currentAuction) return;

    const notification = document.getElementById('auctionNotification');
    notification.style.display = 'block';

    // Hide notification after 10 seconds
    setTimeout(() => {
        notification.style.display = 'none';
    }, 10000);
}

document.getElementById("bidInput").addEventListener("input", function(e) {
    let value = e.target.value.replace(/\D/g, ""); // Remove tudo que não for número
    if (value === "") {
        e.target.value = "";
        return;
    }

    let formattedValue = new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(value / 100); // Divide por 100 para manter os centavos

    e.target.value = formattedValue; // Atualiza o input
});

document.getElementById("itemLanceLeilao").addEventListener("input", function(e) {
    let value = e.target.value.replace(/\D/g, ""); // Remove tudo que não for número
    if (value === "") {
        e.target.value = "";
        return;
    }

    let formattedValue = new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(value / 100); // Divide por 100 para manter os centavos

    e.target.value = formattedValue; // Atualiza o input
});

// ✅ Captura e envia o valor corretamente no submit
document.getElementById('bidForm').addEventListener('submit', function(e) {
    e.preventDefault();

    // Captura o valor do input e converte para número
    let input = document.getElementById("bidInput").value;
    let bidAmount = Number(input.replace(/\D/g, "")) / 100; // Remove tudo que não for número e divide por 100

   

    if (!bidAmount || bidAmount <= currentAuction.currentBid) {
        showToast('O lance deve ser maior que o lance atual!', 'error');
        return;
    }

    fetch(`https://${GetParentResourceName()}/placeBid`, {
        method: 'POST',
        body: JSON.stringify({
            amount: bidAmount
        })
    });

    document.getElementById('bidInput').value = ''; // Limpa o campo após o envio
});


function showToast(message, status) {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${status}`;
    toast.style.display = 'block';
    toast.classList.add('show');

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
            toast.style.display = 'none';
        }, 300);
    }, 10000);
}

// Close NUI on escape key
document.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST'
        });
    }
});



document.getElementById('ButtonStartleilao').addEventListener('submit', function(e) {
    e.preventDefault();

    // Captura o valor do input e converte para número
    let inputname = document.getElementById("itemNameLeilao").value;
    let inputvalori = document.getElementById("itemLanceLeilao").value;
    let inputtime = document.getElementById("itemTimeLeilao").value;
    let inputvalorinteiro = Number(inputvalori.replace(/\D/g, "")) / 100; // Remove tudo que não for número e divide por 100

    const participante = document.getElementById('participantes').value;

    if (!inputname) {
        showToast('Preencha o nome do item!', 'error');
        return;
    }
    if (!inputvalori) {
        showToast('Preencha o valor inicial!', 'error');
        return;
    }
    if (!inputtime) {
        showToast('Preencha o tempo!', 'error');
        return;
    }

    if (!cordenadas) {
        showToast("Por favor, marque a localização.", 'error');
        return;
    }
    if (participante === "") {
        showToast("Por favor, marque quem pode participar.", 'error');
        return;
    }

    fetch(`https://${GetParentResourceName()}/StartLeilao`, {
        method: 'POST',
        body: JSON.stringify({
            name: inputname,
            valor: inputvalorinteiro,
            time: Number(inputtime),
            coords: cordenadas,
            type: participante
        })
    });

    document.getElementById('itemNameLeilao').value = ''; // Limpa o campo após o envio
    document.getElementById('itemLanceLeilao').value = ''; // Limpa o campo após o envio
    document.getElementById('itemTimeLeilao').value = ''; // Limpa o campo após o envio
    document.getElementById("container2").style.display = "none" ;
});

function markLocationOnRegisterLeilao() {

    document.body.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/markActionLocationOnRegisterLeilao`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ })
    });
}
const selectParticipantes = document.getElementById('participantes');
function atualizarOpcoes(typesSorteios) {
    // Limpar selects antes de adicionar novos dados
    selectParticipantes.innerHTML = '<option value="">Selecione um tipo</option>';


    // Preencher os participantes
    Object.keys(typesSorteios).forEach(tipo => {
        selectParticipantes.innerHTML += `<option value="${tipo}">${tipo}</option>`;
    });

  
}