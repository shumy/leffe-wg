package com.github.shumy.leffewg

import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.slf4j.LoggerFactory

@FinalFieldsConstructor
class LeffeVerticle extends AbstractVerticle {
  static val logger = LoggerFactory.getLogger(LeffeVerticle)
  
  val Vertx vertx
  var HttpServer server
  
  override def start() {
    val options = new HttpServerOptions => [
      tcpKeepAlive = true
    ]
    
    server = vertx.createHttpServer(options)
    server.requestHandler[
      println('Hello world')
      response.putHeader("content-type", "text/html").end("<html><body><h1>Hello from vert.x!</h1></body></html>")
    ]
    
    server.listen(9191)[
      if (succeeded) {
        logger.info("Server is now listening on port 9191.")
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