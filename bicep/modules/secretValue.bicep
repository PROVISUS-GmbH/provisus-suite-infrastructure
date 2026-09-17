// secretValue.bicep
param keyVaultName string

@secure()
param dbAdminPassword string
@secure()
param appUserPassword string

resource kv 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource dbPwd 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: 'db-admin-password'
  properties: { value: dbAdminPassword }
}

resource appPwd 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: 'app-user-password'
  properties: { value: appUserPassword }
}
