import { Buffer } from 'node:buffer';

// This is an example of AWS Lambda function for AWS IoT Core custom authorizer.

export const handler = (event, context, callback) => {
  console.log('Lambda function context', context);

  // get username and password from event
  const { username, password } = event.protocolData.mqtt;
  const buff = Buffer.from(password, 'base64');
  const passwordFStr = buff.toString('ascii');
  console.log('username', username);

  // validate username and password
  const user = getUser(username, passwordFStr);

  // generate AWS IoT Core policy
  const effect = user ? 'Allow' : 'Deny';
  const authResponse = generateAuthResponse(user, effect);
  console.log('authResponse', JSON.stringify(authResponse));
  callback(null, authResponse);
};

/** generate the authorization response. */
const generateAuthResponse = (user, effect) => {
  /** response must have interface of AWS IoT Core Policy */
  const baseAuthResponse = {
    isAuthenticated: true,
    principalId: 'TEST123',
    disconnectAfterInSeconds: 3600,
    refreshAfterInSeconds: 300,
    policyDocuments: [{ ...denyPolicyDocument }],
  };

  if (effect !== 'Allow') return baseAuthResponse;

  // get resources with user
  const resources = getUserAllowedResources(user);

  // generate policy document with resources
  const connectStatement = {
    Effect: effect,
    Action: ['iot:Connect'],
    Resource: [...(resources.connect ?? [])],
  };

  const publishStatement = {
    Effect: effect,
    Action: ['iot:Publish'],
    Resource: [...(resources.publish ?? [])],
  };

  const subscribeStatement = {
    Effect: effect,
    Action: ['iot:Subscribe'],
    Resource: [...(resources.subscribe ?? [])],
  };

  const receiveStatement = {
    Effect: effect,
    Action: ['iot:Receive'],
    Resource: [...(resources.receive ?? [])],
  };

  const policyDocument = {
    ...denyPolicyDocument,
    Statement: [
      connectStatement,
      publishStatement,
      subscribeStatement,
      receiveStatement,
    ],
  };

  const authResponse = {
    ...baseAuthResponse,
    policyDocuments: [{ ...policyDocument }],
  };

  return authResponse;
};

/** AWS account id */
const awsAccountId = 'DUMMY_AWS_ACCOUNT_ID';

/** AWS region */
const awsRegion = 'DUMMY_AWS_REGION';

/** prefix for MQTT client id for CloudPRNT server */
const clientIdPrefixForServer = 'cloudPrntServer';

/** MQTT password for CloudPRNT server */
const passwordForServer = 'test';

/** MQTT password for the device */
const passwordForDevice = 'test';

/** mac address for the device */
const deviceMac = 'DUMMY_MAC_ADDRESS';

/** list of users for MQTT connections */
const users = [
  /** an example of a user for CloudPRNT server to publish messages from HTTP server */
  {
    id: 1,
    isServer: true,
    deviceMac: null,
    clientId: `${clientIdPrefixForServer}_01`,
    username: `${clientIdPrefixForServer}_01`,
    password: passwordForServer,
  },
  /** an example of a user for CloudPRNT server to subscribe topic from MQTT subscriber */
  {
    id: 2,
    isServer: true,
    deviceMac: null,
    clientId: `${clientIdPrefixForServer}_02`,
    username: `${clientIdPrefixForServer}_02`,
    password: passwordForServer,
  },
  /** an example of a user for CloudPRNT server to publish messages from MQTT subscriber */
  {
    id: 3,
    isServer: true,
    deviceMac: null,
    clientId: `${clientIdPrefixForServer}_03`,
    username: `${clientIdPrefixForServer}_03`,
    password: passwordForServer,
  },
  /** an example of a user for the device to subscribe topic and publish messages */
  {
    id: 4,
    isServer: false,
    deviceMac,
    clientId: deviceMac,
    username: deviceMac,
    password: passwordForDevice,
  },
];

/** find a user by username and password in list of users */
const getUser = (username, password) =>
  users.find(
    (user) => user.username === username && user.password === password,
  );

/** topic prefix for CloudPRNT server to receive messages from MQTT message broker */
const topicPrefixForServer = 'star/cloudprnt/to-server';
/** topic prefix for the device to receive messages from MQTT message broker */
const topicPrefixForDevice = 'star/cloudprnt/to-device';

/** returns AWS resources for AWS IoT for CloudPRNT server */
const getResourcesForServer = (clientId) => ({
  connect: [
    // allow CloudPRNT server to connect to AWS IoT with a unique client id
    `arn:aws:iot:${awsRegion}:${awsAccountId}:client/${clientId}`,
  ],
  publish: [
    // allow CloudPRNT server to publish messages to devices (so topic prefix for the device is used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topic/${topicPrefixForDevice}/*`,
  ],
  subscribe: [
    // allow CloudPRNT server to subscribe topics to itself (so topic prefix for CloudPRNT server is used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topicfilter/${topicPrefixForServer}/*`,
  ],
  receive: [
    // allow CloudPRNT server to receive messages to itself (so topic prefix for CloudPRNT server is used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topic/${topicPrefixForServer}/*`,
  ],
});

/** returns AWS resources for AWS IoT for devices */
const getResourcesForDevice = (clientId, deviceMac) => ({
  connect: [
    // allow the device to connect AWS IoT with a unique client id such as mac address
    `arn:aws:iot:${awsRegion}:${awsAccountId}:client/${clientId}`,
  ],
  publish: [
    // allow the device to publish messages to CloudPRNT server (so topic prefix for CloudPRNT server and mac address for the device is used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topic/${topicPrefixForServer}/${deviceMac}/*`,
  ],
  subscribe: [
    // allow the device to subscribe topics to itself (so topic prefix and mac address for the device are used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topicfilter/${topicPrefixForDevice}/${deviceMac}/*`,
  ],
  receive: [
    // allow the device to receive messages to itself (so topic prefix and mac address for the device are used)
    `arn:aws:iot:${awsRegion}:${awsAccountId}:topic/${topicPrefixForDevice}/${deviceMac}/*`,
  ],
});

/** returns resources according to whether the user is a server or a device  */
const getUserAllowedResources = (user) => {
  if (!user) return {};

  if (user.isServer) return getResourcesForServer(user.clientId);

  return getResourcesForDevice(user.clientId, user.deviceMac);
};

/** policy document for unauthorized connection */
const denyPolicyDocument = {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: 'Deny',
      Action: ['iot:Connect'],
      Resource: ['*'],
    },
    {
      Effect: 'Deny',
      Action: ['iot:Publish'],
      Resource: ['*'],
    },
    {
      Effect: 'Deny',
      Action: ['iot:Subscribe'],
      Resource: ['*'],
    },
    {
      Effect: 'Deny',
      Action: ['iot:Receive'],
      Resource: ['*'],
    },
  ],
};
