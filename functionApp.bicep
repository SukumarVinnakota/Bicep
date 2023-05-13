@description('Function App name')
param name string

@description('Function App location')
param location string

@description('App Service Plan Id')
param planId string

@description('Function App tag')
param env string

var kind = 'functionapp'

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'func-${name}-${env}'
  location: location
  kind: kind
  tags: {
    env: env
  }
  properties: {
    serverFarmId: planId
  }
  identity: {
    type: 'SystemAssigned'
  }
}


output functionAppName string = functionApp.name
output principalId string = functionApp.identity.principalId
output tenantId string = functionApp.identity.tenantId
