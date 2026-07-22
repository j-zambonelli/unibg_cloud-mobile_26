const String amplifyConfig = '''{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_Zn72cTcDl",
            "AppClientId": "49usdd52m1rvdpg77dt62f7kqr",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "us-east-1zn72ctcdl.auth.us-east-1.amazoncognito.com",
              "AppClientId": "49usdd52m1rvdpg77dt62f7kqr",
              "SignInRedirectURI": "http://localhost:49273/,tedxplore://callback",
              "SignOutRedirectURI": "http://localhost:49273/,tedxplore://signout",
              "Scopes": ["openid", "email"]
            },
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        }
      }
    }
  }
}''';