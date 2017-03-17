package com.github.shumy.leffewg

import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import java.util.LinkedList
import org.osgi.service.component.annotations.Activate
import org.osgi.service.component.annotations.Component
import org.osgi.service.component.annotations.Deactivate

@Component
class LeffeStarter {
  var Vertx vertx
  val verticles = new LinkedList<AbstractVerticle>
  
  @Activate
  def void start() {
    System.setProperty("vertx.disableDnsResolver", "true")
    
    this.vertx = Vertx.vertx
    verticles.add(new LeffeVerticle)
    
    verticles.forEach[ vertx.deployVerticle(it) ]
  }

  @Deactivate
  def void stop() {
    vertx.close
  }
}