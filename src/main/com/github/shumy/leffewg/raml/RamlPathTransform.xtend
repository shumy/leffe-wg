package com.github.shumy.leffewg.raml

class RamlPathTransform {
  static def String toSimpleRest(String path) {
  	/*
  	val matcher = Pattern.compile("\\{(.*)}\\}").matcher(path)
    
    var result = path
    if (matcher.find)
      for(var i=1; i<=matcher.groupCount; i++) {
        println('''«i» - «matcher.group(i)» («matcher.start(i)» - «matcher.end(i)»)''')
        result = result.repla
      }
      
    
    return result
    */
    return path.replace('{', ':').replace('}', '')
  }
}