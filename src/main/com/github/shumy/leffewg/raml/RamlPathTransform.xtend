package com.github.shumy.leffewg.raml

class RamlPathTransform {
  static def String toSimpleRest(String path) {
    return path.replace('{', ':').replace('}', '')
  } 
}
