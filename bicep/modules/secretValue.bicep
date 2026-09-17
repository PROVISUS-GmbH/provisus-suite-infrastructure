// secretValue.bicep
param keyVaultName string

@description('Codice cliente, es. ago23 (stesso valore passato a clientName in storageAccount.bicep / appConfiguration.bicep). Usato per costruire i nomi dei secret')
param clientName string

@secure()
param dbAdminPassword string
@secure()
param appUserPassword string

var dbAdminPasswordSecretName = 'database-${clientName}-migrator-password'
var appUserPasswordSecretName = 'database-${clientName}-password'

resource kv 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource dbPwd 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: dbAdminPasswordSecretName
  properties: { value: dbAdminPassword }
}

resource appPwd 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: appUserPasswordSecretName
  properties: { value: appUserPassword }
}

output dbAdminPasswordSecretName string = dbAdminPasswordSecretName
output appUserPasswordSecretName string = appUserPasswordSecretName
