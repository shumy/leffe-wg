package com.github.shumy.leffewg.plugin

import org.eclipse.xtend.lib.annotations.Data
import io.vertx.ext.web.Router

@Data
class Location {
  public String name
  public String description
  public String plugin
  public String uri
  public String config
  
  public Router router
}