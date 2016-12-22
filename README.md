# Web
HTTP/HTTPS agent for building type-safe web API requests and get response as JSON, written in Swift

simple and easy to use http client library based on native URLSession

# How to use

* simple RAW Object request/response

      Web.create(method: "GET", serverUrl: "https://github.com/fluidicon.png")
                .onError({ (error) -> Void in
                    print("Image Error!")
                    print(error)
                })
                .request{ (raw, response) -> Void in
                    if raw != nil{
                        let image =  self.resizeImage(image: UIImage(data: raw! as Data)!, targetSize: CGSize(width: 32, height: 32))
                        self.FavImage.image = image
                    }
             
            }



* simple GET Request and response as JSONObject

        Web.create(method: "GET", serverUrl: "http://127.0.0.1/request/test/get?user=sumit")
                .onError({ (error) -> Void in
                    print("Error!")
                    print(error)
                })
                .execute{ (json, response) -> Void in
                    if json != nil{
                    var value = json.get(key)
                    var user = json.get("Username")
                    var isAdmin = json.getBool("isAdmin")
                    }
             
            }
            
            
 or response as String 

      Web.create(method: "GET", serverUrl: "http://127.0.0.1/request/test/get?user=sumit")
                .onError({ (error) -> Void in
                    print("Error!")
                    print(error)
                })
                .executeString{ (string, response) -> Void in
                    print(string)
             
            }


* POST Request 
  add parameters as easy

         Web.create(method: "POST", serverUrl: "http://127.0.0.1/request/test/post")
            .add("Username", username.text!)
            .add("Password", pwd)
            .add("Key", Value)
            .onError({ (error) -> Void in
              print(error)
             })
            .execute{ (json, response) -> Void in
                
             if json != nil{
                    var value = json.get(key)
                    var user = json.get("Username")
                    var isAdmin = json.getBool("isAdmin")
                    }
            }




* you can set base URL somewhere in app and than use as 

    WebManager.baseUrl = "http://127.0.0.1/request/"

         Web.with("test/post")
            .add("Username", username.text!)
            .add("Password", pwd)
            .add("Key", Value)
            .onError({ (error) -> Void in
              print(error)
             })
            .execute{ (json, response) -> Void in
                
             if json != nil{
                    var value = json.get(key)
                    var user = json.get("Username")
                    var isAdmin = json.getBool("isAdmin")
                    }
            }
            
 GET    
            
            Web.with(method: "GET", serverUrl: "test/get")
            .onError({ (error) -> Void in
              print(error)
             })
            .execute{ (json, response) -> Void in
                
             if json != nil{
                    var value = json.get(key)
                    var user = json.get("Username")
                    var isAdmin = json.getBool("isAdmin")
                    }
            }
            

also you can use any HTTP Method GET/POST/PUT/DELETE

if response comes as JSONArray than get first object as json.getJsonObject().get(key)

* for response in JSONArray than parse array as 

         if let array = json.array() {               
             // loop jsonObjects i Array/collection
           for jsonObject in array {
             print(jsonObject)
           }
      
           }


# For Installation 
 * just add both file to your project Web.swift and JSON.swift

* for [android](https://github.com/sumeet21/net) 

# Requirements
 swift 3.0 or later
 

# Contributing
* We would love you to contribute to Web
  . If you have found a bug, open an issue
  . If you have a feature request, open an issue
  . If you want to contribute, submit a pull request;
  . If you have an idea on how to improve please contact me
  
# Author
 [Sumeet Kumar](https://github.com/sumeet21/net) 





