package com.github.shumy.leffewg.plugin

import io.vertx.ext.web.Router

interface IRouterPlugin {
  def String getName()
  
  //this method can be invoked several times depending on the number of locations available for the plugin
  def void config(Location location, Router router)
}