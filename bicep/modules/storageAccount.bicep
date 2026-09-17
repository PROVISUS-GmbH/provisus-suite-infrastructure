// storageAccount.bicep
@description('Nome cliente, es. rothoblaas (solo minuscole e numeri)')
@minLength(3)
param clientName string

@description('Codice ambiente usato nel nome, es. stg2, qa, prod')
param envCode string

param location string = 'italynorth'

// Prod ZRS, gli altri LRS
var skuName = envCode == 'prod' ? 'Standard_ZRS' : 'Standard_LRS'

// es. stprovstg2rothoblaas (max 24 caratteri)
var storageName = toLower('stprov${envCode}${clientName}')

resource storage 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for c in [
  'documents'
  'entity-images'
]: {
  parent: blobService
  name: c
  properties: {
    publicAccess: 'None'
  }
}]

output storageAccountName string = storage.name
output storageAccountId string = storage.id
