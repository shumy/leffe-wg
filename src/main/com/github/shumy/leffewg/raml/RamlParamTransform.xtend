package com.github.shumy.leffewg.raml

import java.util.regex.Pattern

class RamlParamTransform {
  static def String transform(String path) {
    val matcher = Pattern.compile("\\{(.*)\\}").matcher(path)
    
    if (matcher.find)
      for(var i=1; i<=matcher.groupCount; i++) {
        println(matcher.group(i))
      }
        
    
    return path.replaceAll("\\{.*\\}", "x")
  }
}