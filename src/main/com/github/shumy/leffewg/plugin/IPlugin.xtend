package com.github.shumy.leffewg.plugin

import io.vertx.ext.web.Router

interface IPlugin {
  def String getName()
  def void config(Location location, Router router)
}