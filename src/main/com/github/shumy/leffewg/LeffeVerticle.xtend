package com.github.shumy.leffewg

import io.vertx.core.AbstractVerticle
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.slf4j.LoggerFactory
import com.github.shumy.leffewg.plugin.RouteProvider

@FinalFieldsConstructor
class LeffeVerticle extends AbstractVerticle {
  static val logger = LoggerFactory.getLogger(LeffeVerticle)
  
  val RouteProvider provider
  var HttpServer server
  
  override def start() {
    val options = new HttpServerOptions => [
      tcpKeepAlive = true
      logActivity = true
    ]
    
    server = vertx.createHttpServer(options).requestHandler[
      logger.debug("REQUEST: {} {}", method, uri)
      provider.route(it)
    ]
    
    server.listen(9191)[
      if (succeeded) {
        logger.info("LEEFE - Web Gateway (9191)")
      } else {
        logger.error("Fail to bind on port 9191: ")
        cause.printStackTrace
      }
    ]
  }
  
  override def stop() {
    server.close
  }
}