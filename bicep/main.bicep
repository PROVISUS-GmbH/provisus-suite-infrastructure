// Parametri
@description('Nome dello Storage Account. Deve essere globale, minuscolo, senza trattini, 3-24 caratteri.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Location Azure dove creare lo Storage Account.')
param location string = resourceGroup().location

@description('Tipo di replica dello Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param skuName string = 'Standard_ZRS'

// Risorsa: Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }

  // Per gli storage account usare sempre StorageV2 perché è la versione attuale.
  kind: 'StorageV2'

  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

output storageAccountName string = storageAccount.name
output storageAccountSku string = skuName
