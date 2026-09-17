// postgresDatabase.bicep
@description('Codice ambiente usato nel nome del server, es. stg2 (staging), qa, prod. Stesso envCode di storageAccount.bicep')
param envCode string

@description('Codice cliente, es. ago23 (stesso valore passato a clientName in storageAccount.bicep / appConfiguration.bicep). Usato anche come nome del database')
param clientName string

@description('Charset del database')
param charset string = 'UTF8'

@description('Collation del database')
param collation string = 'en_US.utf8'

// es. provisus-postgres-stg2-nit-001, provisus-postgres-qa-nit-001, provisus-postgres-prod-nit-001
var postgresServerName = 'provisus-postgres-${envCode}-nit-001'

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing = {
  name: postgresServerName
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  parent: postgresServer
  name: clientName
  properties: {
    charset: charset
    collation: collation
  }
}

output databaseName string = database.name
output postgresServerName string = postgresServer.name
