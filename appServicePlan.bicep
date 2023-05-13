@description('App Service Plan name')
param name string

@description('App Service Plan location')
param location string

@description('App Service Plan tag')
param env string

@description('App Service Plan operating system')
@allowed([
  'Windows'
  'Linux'
])
param os string

var reserved = os == 'Linux' ? true : false

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'app-${name}-${env}'
  location: location
  kind: 'functionapp'
  tags: {
    env: env
  }
  sku: {
    name: 'Y1'
  }
  properties: {
    reserved: reserved
  }
}

output planId string = appServicePlan.id
