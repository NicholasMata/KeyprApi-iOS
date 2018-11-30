# KeyprApi

[![CI Status](https://travis-ci.com/MataDesigns/KeyprApi-iOS.svg)](https://travis-ci.org/MataDesigns/KeyprApi)
[![Version](https://img.shields.io/cocoapods/v/KeyprApi.svg)](http://cocoapods.org/pods/KeyprApi)
[![License](https://img.shields.io/cocoapods/l/KeyprApi.svg)](http://cocoapods.org/pods/KeyprApi)
[![Platform](https://img.shields.io/cocoapods/p/KeyprApi.svg)](http://cocoapods.org/pods/KeyprApi)

KeyprApi is wrapper for Keypr endpoints.

- [Features](#features)
- [Usage](#usage)
    - **Intro Federated -** [Understanding JWT](#understanding-jwt), [Getting Started](#getting-started),[Checking In/Out of Reservation](#checking-inout-of-reservation)

## Requirements
- iOS 9.0+

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
  contactYourServerForJWT() { response in
    gotJWT(response.jwt)
  }
}

...

let api = KeyprApi(jwtGenerator: self.getJWTFromServer, environment: .staging)

```

#### Checking In/Out of Reservation

##### All in One Solution

This solution performs a keypr async task for you, with a timeout.

i.e. Calls /async_(check_in or check_out) then calls task/(taskId from /async call) until a success, failure, or timeout happens.

```swift
let api = KeyprApi(jwtGenerator: self.getJWTFromServer, environment: .staging)
let reservationId = // use api to get reservation

api.perform(task: .checkIn, reservationId: reservationId, timeout: 10) { (successful, task, error) in
    print(successful)
}
```

##### Start async task process
**Unless you know what you are doing use the "All in One Solution" ABOVE ⬆️**

This will only start a check-in/check-out this **will not** inform you if the process has completed successful or not. You will have to check that will the check(taskId:) function.

```swift
let api = KeyprApi(jwtGenerator: self.getJWTFromServer, environment: .staging)
let reservationId = // use api to get reservation.

api.start(task: .checkIn, reservationId: reservationId) { (task, error) in
    print("TaskId: \(task.id)")
}
```

##### Check async task
**Unless you know what you are doing use the "All in One Solution" ABOVE ⬆️**

This is used to check on an async task using taskId gotten from start(task:) function.

```swift
let taskId = // Some task id.

api.check(taskId: taskId) { (task, error) in
    if task.attributes.successful {
        print("Woohoo Checked In!!")
    }
    if task.attributes.failed {
        print("Oops something went wrong...")
    }
    if task.attributes.status == "PENDING" {
        // check again
    }
}
```


## More Documentation to come ... 

(Look at tests for now)

## Author

Nicholas Mata, nicholas@matadesigns.net

## License

KeyprApi is available under the MIT license. See the LICENSE file for more info.
