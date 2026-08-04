export enum ErrorHandlerScenarioCategory {
  NETWORK = 'NETWORK',
  SECURITY = 'SECURITY',
  AUTH = 'AUTH',
  CUSTOM = 'CUSTOM'
}

export enum ErrorHandlerScenarioMode {
  MOCK = 'MOCK',
  LIVE = 'LIVE',
  BOTH = 'BOTH'
}

export interface ErrorHandlerScenario {
  id: string
  title: string
  shortTitle: string
  category: ErrorHandlerScenarioCategory
  mode: ErrorHandlerScenarioMode
  description: string
  testUrl: string
  supportsRetry: boolean
}

export const ERROR_HANDLER_SCENARIOS: ErrorHandlerScenario[] = [
  {
    id: 'RESOURCE_ERROR',
    title: 'Resource Error',
    shortTitle: 'Resource Error',
    category: ErrorHandlerScenarioCategory.NETWORK,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Captures network and resource loading errors.',
    testUrl: 'xxxxxx', //add your test url
    supportsRetry: true
  },
  {
    id: 'REQUEST_DETAILS',
    title: 'Request Details',
    shortTitle: 'Request Details',
    category: ErrorHandlerScenarioCategory.NETWORK,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Displays URL, method, redirect, and main frame information.',
    testUrl: 'xxxxxxx', //add your test url
    supportsRetry: false
  },
  {
    id: 'SSL_ERROR',
    title: 'SSL Error',
    shortTitle: 'SSL Error',
    category: ErrorHandlerScenarioCategory.SECURITY,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Demonstrates certificate validation decisions.',
    testUrl: 'xxxxxxx', //add your test url
    supportsRetry: false
  },
  {
    id: 'HTTP_AUTH',
    title: 'HTTP Authentication',
    shortTitle: 'HTTP Auth',
    category: ErrorHandlerScenarioCategory.AUTH,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Demonstrates Basic and Digest authentication handling.',
    testUrl: 'xxxxxxx', //add your test url
    supportsRetry: false
  },
  {
    id: 'CLIENT_AUTH',
    title: 'Client Authentication',
    shortTitle: 'Client Auth',
    category: ErrorHandlerScenarioCategory.AUTH,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Demonstrates mutual TLS certificate selection.',
    testUrl: 'xxxxxxx', //add your test url
    supportsRetry: false
  },
  {
    id: 'CUSTOM_HANDLER',
    title: 'Custom Resource Handler',
    shortTitle: 'Custom Handler',
    category: ErrorHandlerScenarioCategory.CUSTOM,
    mode: ErrorHandlerScenarioMode.BOTH,
    description: 'Demonstrates intercepted custom scheme responses.',
    testUrl: 'xxxxxxx', //add your test url
    supportsRetry: false
  }
]