# KeyprApi

[![CI Status](https://travis-ci.com/MataDesigns/KeyprApi-iOS.svg)](https://travis-ci.org/MataDesigns/EasyJSON)
[![Version](https://img.shields.io/cocoapods/v/KeyprApi.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![License](https://img.shields.io/cocoapods/l/KeyprApi.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![Platform](https://img.shields.io/cocoapods/p/KeyprApi.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)

KeyprApi is wrapper for Keypr endpoints.

- [Features](#features)
- [Usage](#usage)
    - **Intro Federated -** [Understanding JWT](#understanding-jwt), [Getting Started](#getting-started)

## Requirements
- iOS 9.0+
- Xcode 8.0+

## Installation

### Cocoapods
KeyprApi is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KeyprApi"
```

### Carthage
 To install it, simple add the following line to your Cartfile
```ruby
github "MataDesigns/KeyprApi-iOS"
```

## Features

- Support Authentication Flows
  - ✅ Federated Id
   - ✅ Automatic handling of expired JWT and access token.
  - 🚫 OAuth
- ✅ Get Reservations for user
- ✅ Check-in/out of a reservation
- ✅ Lookup Reservation by Id
- 🚫 Lookup Reservation by confirmation code and last name

## Usage

### Important !!! currently only class are supported (if you use structs this will not work)

### Intro (Federated)

#### Understanding JWT
JWT or JSON Web Token is a compact and self-contained way for securely transmitting information between parties as a JSON object. 
This information can be verified and trusted because it is digitally signed. 

In the case of Keypr's federated flow it is used if you want to use a 3rd party system as an identity provider.

Keypr requires JWT to use the RS256 algorithm for signing.

JWT payload must contain at least the following:
 - **iss**         - this field identifies what system JWT is generated by. Public key is associated with this URI.
 - **exp**         - a token expiration time in NumericDate format. This is a JSON numeric value representing the number of seconds from 1970-01-01T00:00:00Z UTC until the specified UTC date/time, ignoring leap seconds.
 - **given_name**  - user's first name
 - **family_name** - user's last name
 - **email**       - user's email address
 
Learn more about JWTs [here](jwt.io)

#### Getting Started

JWT should be generated server side, because of this a required constructor parameter is a JWTGenerator.
The generator will be called when jwt is empty or when it is expired so this should always result in a valid JWT.

Keypr currently has two environments staging and production.

```swift
import KeyprApi

func getJWTFromServer(gotJWT: (String)-> Void)) {
  someAsyncNetworkRequest() { response in
    gotJWT(response.jwt)
  }
}

...

let api = KeyprApi(jwtGenerator: self.getJWTFromServer, environment: .staging)

```

## More Documentation to come ... 

(Look at tests for now)

## Author

Nicholas Mata, nicholas@matadesigns.net

## License

KeyprApi is available under the MIT license. See the LICENSE file for more info.