// const amplifyconfig = ''' {
//     "UserAgent": "aws-amplify-cli/2.0",
//     "Version": "1.0",
//     "auth": {
//         "plugins": {
//             "awsCognitoAuthPlugin": {
//                 "CognitoUserPool": {
//                     "Default": {
//                         "PoolId": "us-east-1_2L5DbiYSt",
//                         "AppClientId": "2o1mgslcfpl69k43vvloa752uk",
//                         "Region": "us-east-1"
//                     }
//                 },
//                 "Auth": {
//                     "Default": {
//                         "OAuth": {
//                             "WebDomain": "us-east-12l5dbiyst.auth.us-east-1.amazoncognito.com",
//                             "AppClientId": "2o1mgslcfpl69k43vvloa752uk",
//                             "SignInRedirectURI": "tedxplore://callback",
//                             "SignOutRedirectURI": "tedxplore://signout",
//                             "Scopes": [
//                                 "openid",
//                                 "email",
//                                 "profile"
//                             ]
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }''';
// const String amplifyConfig = '''{
//   "version": "1",
//   "auth": {
//     "aws_region": "us-east-1",
//     "user_pool_id": "us-east-1_2L5DbiYSt",
//     "user_pool_client_id": "2o1mgslcfpl69k43vvloa752uk",
//     "oauth": {
//       "domain": "us-east-12l5dbiyst.auth.us-east-1.amazoncognito.com",
//       "scopes": [
//         "openid",
//         "email",
//         "profile"
//       ],
//       "redirect_sign_in_uri": [
//         "tedxplore://callback",
//         "http://localhost:49273/",
//         "http://localhost:49273"
//       ],
//       "redirect_sign_out_uri": [
//         "tedxplore://signout",
//         "http://localhost:49273/",
//         "http://localhost:49273"
//       ],
//       "response_type": "code",
//       "identity_providers": [
//         "LOGIN_WITH_AMAZON"
//       ]
//     }
//   }
// }''';
const String amplifyConfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_2L5DbiYSt",
            "AppClientId": "2o1mgslcfpl69k43vvloa752uk",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "us-east-12l5dbiyst.auth.us-east-1.amazoncognito.com",
              "AppClientId": "2o1mgslcfpl69k43vvloa752uk",
              "SignInRedirectURI": "http://localhost:49273/,tedxplore://callback",
              "SignOutRedirectURI": "http://localhost:49273/,tedxplore://signout",
              "Scopes": [
                "openid",
                "email",
                "profile"
              ]
            },
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        }
      }
    }
  }
}''';