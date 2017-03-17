package com.github.shumy.leffewg.raml

import org.raml.v2.api.model.v10.api.Api
import org.raml.v2.api.RamlModelBuilder
import org.slf4j.LoggerFactory
import java.util.List
import java.util.LinkedList

class RamlReader {
  static val logger = LoggerFactory.getLogger(RamlReader)
  
  static def List<Api> readAll() {
    val apiList = new LinkedList<Api>
    
    val ramlModelResult = new RamlModelBuilder().buildApi("./raml/helloworld.raml")
    if (ramlModelResult.hasErrors) {
      ramlModelResult.validationResults.forEach[ logger.error(message) ]
      throw new RuntimeException("Errors on RAML files! See logs...")
    } else {
      val api = ramlModelResult.apiV10
      
      println(api.title.value)
      api.resources.forEach[
        println('''«resourcePath» -> (params: «uriParameters»)''')
        resources.forEach[
          println('''  «resourcePath» -> (params: «uriParameters»)''')
        ]
      ]
      
      apiList.add(api)
    }
    
    return apiList
  }
}