@description('Resources location')
param location string = resourceGroup().location

@description('Resources location')
param env string = resourceGroup().tags.env

//----------- Storage Account Parameters ------------
@description('Function Storage Account name')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Function Storage Account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string 

@description('Function App Plan operating system')
@allowed([
  'Windows'
  'Linux'
])
param planOS string

//----------- Application Insights Parameters ------------
@description('Application Insights name')
param applicationInsightsName string

//----------- Function App Parameters ------------
@description('Function App Plan name')
param planName string

@description('Function App name')
param functionAppName string

@description('Function App runtime')
@allowed([
  'dotnet'
  'node'
  'java'
  'powershell'
])
param functionAppRuntime string

//----------- Key Vault Parameters ------------
@description('Key Vault name')
param keyVaultName string

@description('Key Vault SKU')
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'


var buildNumber = uniqueString(resourceGroup().id)

//----------- Storage Account Deployment ------------
module storageAccountModule './StorageAccount.bicep' = {
  name: 'stvmdeploy-${buildNumber}'
  params: {
    name: storageAccountName
    sku: storageAccountSku
    location: location
    env: env
  }
}

//----------- Application Insights Deployment ------------
module applicationInsightsModule './appinsights.bicep' = {
  name: 'appideploy-${buildNumber}'
  params: {
    name: applicationInsightsName
    location: location
    env:env
  }
}

//----------- App Service Plan Deployment ------------
module appServicePlan './appServicePlan.bicep' = {
  name: 'plandeploy-${buildNumber}'
  params: {
    name: planName
    location: location
    os: planOS
    env:env
  }
}

//----------- Function App Deployment ------------
module functionAppModule 'functionApp.bicep' = {
  name: 'funcdeploy-${buildNumber}'
  params: {
    name: functionAppName
    location: location
    planId: appServicePlan.outputs.planId
    env:env
  }
  dependsOn: [
    storageAccountModule
    applicationInsightsModule
    appServicePlan
  ]
}

//----------- Key Vault Deployment ------------
module keyVaultModule './keyVault.bicep' = {
  name: 'kvdeploy-${buildNumber}'
  params: {
    name: keyVaultName
    location: location
    sku: keyVaultSku
    funcTenantId: functionAppModule.outputs.tenantId
    funcPrincipalId: functionAppModule.outputs.principalId
    env:env
  }
  dependsOn: [
    functionAppModule
  ]
}

//----------- Function App Settings Deployment ------------
module functionAppSettingsModule './functionAppSetting.bicep' = {
  name: 'siteconf-${buildNumber}'
  params: {
    applicationInsightsKey: applicationInsightsModule.outputs.applicationInsightsKey
    functionAppName: functionAppModule.outputs.functionAppName
    functionAppRuntime: functionAppRuntime
    storageAccountConnectionString: storageAccountModule.outputs.storageAccountConnectionString
  }
  dependsOn: [
    functionAppModule
  ]
}
