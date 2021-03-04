import Foundation

// JSON file structure

public struct JSONStruct: Decodable {
   let data: [ElementSpecific]?
   let view: [String]?
   
   public struct ElementSpecific: Decodable {
       let name: String?
       let data: Content?
       
       public struct Content: Decodable {
           let url: String?
           let text: String?
           let selectedId: Int?
           let variants: [Variant]?
           
           public struct Variant: Decodable {
               let id: Int?
               let text: String?
           }
       }
   }
}
