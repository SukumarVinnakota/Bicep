@description('Application Insights name')
param name string

@description('Application Insights location')
param location string

@description('Application Insights tag')
param env string

var kind = 'web'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${name}-${env}'
  location: location
  kind: kind
  tags: {
    env: env
  }
  properties: {
    Application_Type: kind
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output applicationInsightsKey string = reference(applicationInsights.id, applicationInsights.apiVersion).InstrumentationKey
