Config = {}

-- Store URL configuration
Config.CommandStart = "cleilao" -- comando para iniciar o leilao
Config.PermStart = "ceo.permissao" -- comando para iniciar o leilao

Config.CommandParticiar = "leilao" -- comando para participar do leilao

Config.TimeAnuncio = 60 -- intevalor de aviso sobre leilao em andamento em segundos

Config.RaioSorteio = 100 -- intevalor de aviso sobre leilao em andamento em segundos

Config.typesLeilao = {

    ["Todos"] = { perm = nil },
    ["Hospital"] = { perm = "paramedico.permissao" },
    ["Policiais"] = { perm = "policia.permissao" },
    ["Mecânicos"] = { perm = "mecanico.permissao" },
    ["Legal"] = { perm = "legal.permissao" },
    ["ILegal"] = { perm = "ilegal.permissao" },
    ["Staffs"] = { perm = "chamado.permissao" },
    
  }



Config.Nomecidade = "Alto astral" -- NOME DA CIDADE PARA LOGS
Config.Logocidade = "http://131.196.198.155/imagens_logo_hud/logo512.png" -- LOGO DA CIDADE PARA LOGS
Config.Logs = {
  
    StartLeilao = "https://discord.com/api/webhooks/1301203362577911861/hfvd41tWiVf9U3wyl_TQvX8vFF8q1zMQrlryZclHK0KfbTPnzx_weXLdzgf0ILgFXqp8",
    LanceLeilao = "https://discord.com/api/webhooks/1301203362577911861/hfvd41tWiVf9U3wyl_TQvX8vFF8q1zMQrlryZclHK0KfbTPnzx_weXLdzgf0ILgFXqp8",
    WinLeilao = "https://discord.com/api/webhooks/1301203362577911861/hfvd41tWiVf9U3wyl_TQvX8vFF8q1zMQrlryZclHK0KfbTPnzx_weXLdzgf0ILgFXqp8",
    
}
  
