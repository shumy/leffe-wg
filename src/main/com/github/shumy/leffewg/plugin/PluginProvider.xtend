package com.github.shumy.leffewg.plugin

import io.vertx.core.Vertx
import io.vertx.ext.web.Router
import java.io.FileInputStream
import java.util.Collections
import java.util.List
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.slf4j.LoggerFactory
import org.yaml.snakeyaml.Yaml

@FinalFieldsConstructor
class PluginProvider {
  static val logger = LoggerFactory.getLogger(PluginProvider)
  
  val List<IPlugin> plugins
  
  val Vertx vertx //used also to synchronize locations
  var List<Location> locations = Collections.EMPTY_LIST
  
  @Accessors val routers = new ConcurrentHashMap<String, Router>        //<uri-from-location, Router>
  
  def PluginProvider init() {
    //TODO: check for locations updates!
    readLocations
    return this
  }
  
  def void bind(IPlugin plugin) {
    logger.info("Plugin bind: {}", plugin.name)
    locations.forEach[ loc |
      if (loc.plugin == plugin.name) {
        val router = routers.get(loc.uri) ?: {
          val rt = Router.router(vertx)
          routers.put(loc.uri, rt)
          rt
        }
        
        plugin.config(loc, router)
      }
    ]
  }
  
  def void unbind(String name) {
    logger.info("Plugin unbind: {}", name)
    //TODO: remove all routes of the plugin
  }
  
  def void readLocations() {
    synchronized(vertx) {
      val input = new FileInputStream('locations.yaml')
      val data = new Yaml().load(input) as Map<String, Object>
      
      locations = data.keySet.map[
        val map = data.get(it) as Map<String, String>
        new Location(it, map.get('description'), map.get('plugin'), map.get('uri'), map.get('config'))
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