package com.github.shumy.leffewg.raml

import org.raml.v2.api.RamlModelBuilder
import org.raml.v2.api.model.v10.api.Api
import org.slf4j.LoggerFactory

class RamlReader {
  static val logger = LoggerFactory.getLogger(RamlReader)
  
  static def Api readConfig(String file) {
    val ramlModelResult = new RamlModelBuilder().buildApi("./raml/" + file)
    if (ramlModelResult.hasErrors) {
      ramlModelResult.validationResults.forEach[ logger.error(message) ]
      throw new RuntimeException("Errors on RAML files! See logs...")
    }
    
    return ramlModelResult.apiV10
  }
}