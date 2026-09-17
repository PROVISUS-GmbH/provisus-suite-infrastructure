// main.bicep
// Orchestratore: crea le risorse per un nuovo cliente nell'ordine
// 1. Database Postgres  2. Storage Account  3. Secret in Key Vault  4. App Configuration

@description('Codice ambiente, es. stg2, qa, prod')
param envCode string

@description('Codice cliente, es. rothoblaas (solo minuscole e numeri)')
@minLength(3)
param clientName string

@description('Location Azure per le risorse regionali (storage account).')
param location string = 'italynorth'

@description('Nome del Key Vault esistente dove salvare i secret.')
param keyVaultName string

@description('Nome della App Configuration esistente dove scrivere le entry.')
param appConfigName string

@description('Password dell\'utente admin/migrator del database.')
@secure()
param dbAdminPassword string

@description('Password dell\'utente applicativo del database.')
@secure()
param appUserPassword string

@description('Charset del database.')
param charset string = 'UTF8'

@description('Collation del database.')
param collation string = 'en_US.utf8'

// 1. Database
module database 'modules/postgresDatabase.bicep' = {
  name: 'deploy-database-${clientName}'
  params: {
    envCode: envCode
    clientName: clientName
    charset: charset
    collation: collation
  }
}

// 2. Storage Account
module storage 'modules/storageAccount.bicep' = {
  name: 'deploy-storage-${clientName}'
  params: {
    clientName: clientName
    envCode: envCode
    location: location
  }
  dependsOn: [
    database
  ]
}

// 3. Secret in Key Vault
module secrets 'modules/secretValue.bicep' = {
  name: 'deploy-secrets-${clientName}'
  params: {
    keyVaultName: keyVaultName
    clientName: clientName
    dbAdminPassword: dbAdminPassword
    appUserPassword: appUserPassword
  }
  dependsOn: [
    storage
  ]
}

// 4. App Configuration
module appConfiguration 'modules/appConfiguration.bicep' = {
  name: 'deploy-appconfig-${clientName}'
  params: {
    appConfigName: appConfigName
    keyVaultName: keyVaultName
    clientName: clientName
  }
  dependsOn: [
    secrets
  ]
}

output databaseName string = database.outputs.databaseName
output postgresServerName string = database.outputs.postgresServerName
output storageAccountName string = storage.outputs.storageAccountName
