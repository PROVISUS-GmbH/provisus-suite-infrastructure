// appConfiguration.bicep
@description('Nome della App Configuration esistente')
param appConfigName string

@description('Nome del Key Vault esistente da cui referenziare i secret per le entry Password (stesso keyVaultName di secretValue.bicep)')
param keyVaultName string

@description('Codice cliente, es. ago23 (stesso valore passato a clientName in storageAccount.bicep)')
param clientName string

@description('Nome del secret nel Key Vault con la password dell\'utente applicativo (creato in secretValue.bicep)')
param appUserPasswordSecretName string = 'database-${clientName}-password'

@description('Nome del secret nel Key Vault con la password dell\'utente migrator/admin (creato in secretValue.bicep)')
param dbAdminPasswordSecretName string = 'database-${clientName}-migrator-password'

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appConfigName
}

resource dbUser 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: appConfig
  name: 'Database:${clientName}:User'
  properties: {
    value: 'usr_${clientName}_app'
  }
}

resource dbMigratorUser 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: appConfig
  name: 'Database:${clientName}_migrator:User'
  properties: {
    value: 'usr_${clientName}_admin'
  }
}

resource dbMigratorPassword 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: appConfig
  name: 'Database:${clientName}_migrator:Password'
  properties: {
    value: '{"uri":"${keyVault.properties.vaultUri}secrets/${dbAdminPasswordSecretName}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource dbPassword 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: appConfig
  name: 'Database:${clientName}:Password'
  properties: {
    value: '{"uri":"${keyVault.properties.vaultUri}secrets/${appUserPasswordSecretName}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}
