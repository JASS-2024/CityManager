//
//  AvatarService.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 29.03.24.
//

import Foundation


let decoderAvatar = JSONDecoder()
let API_key = "YWxla3NhbmRyYS5pLnRvcGFsb3ZhQGdtYWlsLmNvbQ:_64-a6toSY5zVA4BXLQNQ"

struct VideoResponse: Codable {
    var id: String
    var status: String
    var result_url: String?
}

struct AvatarService {
    
    static func generateVideo(prompt: String, avatarURL: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.d-id.com/talks") else {
            completion(nil)
            return
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.d-id.com/talks")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        /*request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(API_key)", forHTTPHeaderField: "Authorization")*/
        let headers = [
          "accept": "application/json",
          "content-type": "application/json",
          "authorization": "Bearer \(API_key)"
        ]
        
        let voiceId = "en-US-JennyNeural"
        let payload = [
          "script": [
            "type": "text",
            "subtitles": "false",
            "provider": [
              "type": "microsoft",
              "voice_id": "en-US-JennyNeural"
            ]
          ],
          "config": [
            "fluent": "false",
            "pad_audio": "0.0"
          ]
        ] as [String : Any]
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            // Convert jsonData to a String and print it
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON String: \(jsonString)")
            }
            request.httpBody = jsonData
        } catch {
            print("Error serializing payload: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("Response status code: \(httpResponse.statusCode)")
                
                do {
                    let videoResponse = try decoderAvatar.decode(VideoResponse.self, from: data)
                    checkVideoStatus(id: videoResponse.id, completion: completion)
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Video generation error or bad response")
                completion(nil)
            }
        }
        task.resume()
    }

    static func checkVideoStatus(id: String, retryCount: Int = 0, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.d-id.com/talks/\(id)") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(API_key)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let videoStatusResponse = try decoderAvatar.decode(VideoResponse.self, from: data)
                    switch videoStatusResponse.status {
                    case "done":
                        if let videoURL = videoStatusResponse.result_url {
                            completion(videoURL)
                        } else {
                            completion(nil)
                        }
                    case "created":
                        // If status is still "created", retry after 0.5 seconds, with a maximum of 3 retries
                        if retryCount < 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                checkVideoStatus(id: id, retryCount: retryCount + 1, completion: completion)
                            }
                        } else {
                            // Max retries reached, complete with nil
                            completion(nil)
                        }
                    default:
                        // Handle other statuses if needed
                        completion(nil)
                    }
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Error checking video status")
                completion(nil)
            }
        }
        task.resume()
    }

    
    /*func generateVideo(prompt: String, avatar_url: String) async -> String {
     
     let url = URL(string:  "https://api.d-id.com/talks")!
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.addValue("Bearer \(API_key)", forHTTPHeaderField: "Authorization")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
     let parameters: [String: Any] =  [
     "script": [
     "type": "text",
     "subtitles": "false",
     "provider": [
     "type": "microsoft",
     "voice_id": "en-US-JennyNeural"
     ],
     "ssml": "false",
     "input": prompt
     ],
     "config": [
     "fluent": "false",
     "pad_audio": "0.0"
     ],
     "source_url": avatar_url
     ]
     
     guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
     return "Error: Could not encode parameters."
     }
     
     request.httpBody = httpBody
     
     do {
     let (data, _) = try await URLSession.shared.data(for: request)
     if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
     let id = jsonResponse["id"] as? [[String: Any]],
     
     var status = "created"
     while status == "created" {
     getresponse =  requests.get("\(url)/\(id)", headers=headers)
     print(getresponse)
     if getresponse.status_code == 200:
     status = res["status"]
     res = getresponse.json()
     print(res)
     if res["status"] == "done":
     video_url =  res["result_url"]
     else:
     time.sleep(10)
     else:
     status = "error"
     video_url = "error"
     
     if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
     let choices = jsonResponse["choices"] as? [[String: Any]],
     let message = choices.first?["message"] as? [String: Any],
     let content = message["content"] as? String {
     return content
     } else {
     return "Error: Invalid response format."
     }
     } catch {
     return "Error: \(error.localizedDescription)"
     }
     }
     */
    
    /*
     def generate_video(prompt, avatar_url, gender):
     url = "https://api.d-id.com/talks"
     headers = {
     "accept": "application/json",
     "content-type": "application/json",
     "Authorization" : os.getenv("API_KEY_DID")
     }
     if gender == "Female":
     payload = {
     "script": {
     "type": "text",
     "subtitles": "false",
     "provider": {
     "type": "microsoft",
     "voice_id": "en-US-JennyNeural"
     },
     "ssml": "false",
     "input":prompt
     },
     "config": {
     "fluent": "false",
     "pad_audio": "0.0"
     },
     "source_url": avatar_url
     }
     
     if gender == "Male":
     payload = {
     "script": {
     "type": "text",
     "subtitles": "false",
     "provider": {
     "type": "microsoft",
     "voice_id": "en-US-BrandonNeural"
     },
     "ssml": "false",
     "input":prompt
     },
     "config": {
     "fluent": "false",
     "pad_audio": "0.0"
     },
     "source_url": avatar_url
     }
     
     try:
     response = requests.post(url, json=payload, headers=headers)
     if response.status_code == 201:
     print(response.text)
     res = response.json()
     id = res["id"]
     
     status = "created"
     while status == "created":
     getresponse =  requests.get(f"{url}/{id}", headers=headers)
     print(getresponse)
     if getresponse.status_code == 200:
     status = res["status"]
     res = getresponse.json()
     print(res)
     if res["status"] == "done":
     video_url =  res["result_url"]
     else:
     time.sleep(10)
     else:
     status = "error"
     video_url = "error"
     else:
     video_url = "error"
     except Exception as e:
     print(e)
     video_url = "error"
     
     return video_url
     */
}
