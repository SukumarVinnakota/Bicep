@description('Key Vault name')
param name string

@description('Key vault location')
param location string

@description('Key Vault SKU')
@allowed([
  'standard'
  'premium'
])
param sku string

@description('Function App principal id')
param funcPrincipalId string

@description('Function App tenant id')
param funcTenantId string

@description('Key Vault tag')
param env string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'kv-${name}-${env}'
  location: location
  tags: {
    env: env
  }
  properties: {
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: true
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: [
      {
        objectId: funcPrincipalId
        tenantId: funcTenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: '08bb4185-fb0b-4e0d-bf5d-1e26bfb76f5a'
        permissions: {
          keys: ['all']
          secrets: ['all']
        }
      }
    ]
  }
}
