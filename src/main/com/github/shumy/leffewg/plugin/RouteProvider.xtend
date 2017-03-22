package com.github.shumy.leffewg.plugin

import io.vertx.core.Vertx
import io.vertx.core.http.HttpServerRequest
import io.vertx.ext.web.Router
import java.io.FileInputStream
import java.util.Collections
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.slf4j.LoggerFactory
import org.yaml.snakeyaml.Yaml

@FinalFieldsConstructor
class RouteProvider {
  static val logger = LoggerFactory.getLogger(RouteProvider)
  
  val List<IRouterPlugin> plugins
  
  val Vertx vertx //used also to synchronize locations
  var List<Location> locations = Collections.EMPTY_LIST
  
  def RouteProvider init() {
    //TODO: check for locations updates!
    readLocations
    return this
  }
  
  def void bind(IRouterPlugin plugin) {
    logger.info("Plugin bind: {}", plugin.name)
    locations.forEach[ loc |
      if (loc.plugin == plugin.name) {
        synchronized(loc) {
          plugin.config(loc)
        }
      }
    ]
  }
  
  def void unbind(String name) {
    logger.info("Plugin unbind: {}", name)
    
    //TODO: how to remove plugin routes of the router location?
    locations.forEach[ loc |
      println('''location «loc.uri»''')
      loc.router.routes.forEach[
        println('''  route «path»''')
      ]
    ]
  }
  
  def void route(HttpServerRequest request) {
    val loc = locations.findFirst[ request.uri.startsWith(uri) ]
    if (loc === null) {
      request.response.statusCode = 404
      request.response.end('No route found!')
      return
    }
    
    loc.router.accept(request)
  }
  
  def void readLocations() {
    synchronized(vertx) {
      val input = new FileInputStream('locations.yaml')
      val data = new Yaml().load(input) as Map<String, Object>
      
      locations = data.keySet.map[
        val map = data.get(it) as Map<String, String>
        new Location(it, map.get('description'), map.get('plugin'), map.get('uri'), map.get('config'), Router.router(vertx))
      ].filter[ loc |
        //filter all invalid locations!
        if (loc.name === null || loc.description === null || loc.uri === null || loc.plugin === null || loc.config === null) {
          logger.error("Location '{}' is invalid!", loc.name)
          return false
        }
        
        return true
      ].toList
    }
  }
}