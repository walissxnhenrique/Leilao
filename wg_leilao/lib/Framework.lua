Framework = {}

Framework.Proxy = module('vrp','lib/Proxy')
Framework.Tunnel = module('vrp','lib/Tunnel')
Framework.vFunc = {}
Framework.Tunnel.bindInterface("wg_leilao", Framework.vFunc)

Framework.vRP = Framework.Proxy.getInterface('vRP')

Framework.vRPclient = Framework.Tunnel.getInterface('vRP')

Framework.Functions = {
  GetUserId = function(self, source)
    return Framework.vRP.getUserId(source)
  end,



  GetUserName = function(self, user_id)
    local identity = Framework.vRP.getUserIdentity(user_id)
    return identity.name..' '..identity.firstname
  end,  

  VerifyPermission = function(self, user_id, perm)
    return Framework.vRP.hasPermission(user_id, perm)
  end,

  NotifyError = function(self, source, message)
    TriggerClientEvent("Notify", source, "negado", message, 15000)
  end,

  NotifySuccess = function(self, source, message)
    TriggerClientEvent("Notify", source, "sucesso", message, 15500)
  end,

  Query = function(self, query,valores)
    if valores then
      return Framework.vRP.query(query,valores)
    else  
      return Framework.vRP.query(query)
    end
  end,

  execute = function(self, query,valores)
    if valores then
      return Framework.vRP.execute(query,valores)
    else  
      return Framework.vRP.execute(query)
    end
  end,
  
  Prompt = function(self,source, text)
    return Framework.vRP.prompt(source,text,"")
  end,

  getUData = function(self,user_id, text)
    return Framework.vRP.getUData(user_id,text)
  end,

  
  setUData = function(self,user_id, text,text2)
    return  Framework.vRP.setUData(user_id,text,text2)
  end,

  getCustomization = function(self,source)
    return  Framework.vRPclient.getCustomization(source)
  end,

  getNearestPlayer = function(self,source)
    return  Framework.vRPclient.getNearestPlayer(source,4)
  end,

  setHealth = function(self,source,vida)
    return  Framework.vRPclient.setHealth(source,vida)
  end,

  setCustomization = function(self,source,roupas)
    return  Framework.vRPclient._setCustomization(source,roupas)
  end,

  getBankMoney = function(self, user_id)

    return Framework.vRP.getBankMoney(user_id)
  end, 
  
  getMoney = function(self, user_id)

    return Framework.vRP.getMoney(user_id)
  end, 
  
  tryFullPayment = function(self, user_id,valor)

    return Framework.vRP.tryFullPayment(user_id,valor)
  end, 
  getUsersByPermission = function(permissao)
    return Framework.vRP.getUsersByPermission(permissao)
  end,
  getUserSource = function(id)
    return Framework.vRP.getUserSource(id)
  end,

}

Framework.vRP.prepare("WG/CreateTableClothes", "CREATE TABLE IF NOT EXISTS `wg_saveclothes` (`user_id` int(11) DEFAULT NULL, `slot` varchar(100) DEFAULT NULL, `clothessave` varchar(100) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=latin1")
Framework.vRP.prepare("WG/getUserWGClothes", "SELECT `clothessave` FROM `wg_saveclothes` WHERE `user_id` = @user_id AND `slot` = @slot ")
Framework.vRP.prepare("WG/setUserWGClothes", "REPLACE INTO `wg_saveclothes`(`user_id`,`slot`,`clothessave`) VALUES(@user_id,@slot,@clothes)")
-- Framework.vRP.prepare("WG/CreateTableClothes","CREATE TABLE IF NOT EXISTS `wg_saveclothes` (`user_id` int(11) DEFAULT NULL,`nome` varchar(50) DEFAULT NULL,`sobrenome` varchar(50) DEFAULT NULL,`reward` varchar(50) DEFAULT NULL,`raridade` varchar(50) DEFAULT NULL, `hora` varchar(50) DEFAULT curtime(),`data` varchar(50) DEFAULT curdate()) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;")
Framework.vRP.prepare("WG/presets_delete", "DELETE FROM wg_saveclothes WHERE user_id = @user_id AND slot = @slot")
