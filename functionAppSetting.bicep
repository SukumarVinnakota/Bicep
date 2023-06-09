@description('Function App name')
param functionAppName string

@description('Function App runtime')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'powershell'
])
param functionAppRuntime string

@description('Application Insights Instrumentation Key')
@secure()
param applicationInsightsKey string

@description('Storage Account connection string')
@secure()
param storageAccountConnectionString string


var function_extension_version = '~4'

resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/appsettings'
  properties: {
    AzureWebJobsStorage: storageAccountConnectionString
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
    WEBSITE_CONTENTSHARE: toLower(functionAppName)
    FUNCTIONS_EXTENSION_VERSION: function_extension_version
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsKey
    FUNCTIONS_WORKER_RUNTIME: functionAppRuntime
    //WEBSITE_TIME_ZONE only available on windows
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: 1
  }
}
