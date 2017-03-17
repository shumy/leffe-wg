package com.github.shumy.leffewg

import io.vertx.core.AbstractVerticle
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import org.slf4j.LoggerFactory

class LeffeVerticle extends AbstractVerticle {
  static val logger = LoggerFactory.getLogger(LeffeVerticle)
  
  var HttpServer server
  
  override def start() {
    val options = new HttpServerOptions => [
      tcpKeepAlive = true
      logActivity = true
    ]
    
    server = vertx.createHttpServer(options)
    server.requestHandler[
      println('Hello world')
      response.statusCode = 200
      response
        .putHeader("content-type", "text/html")
        .end("<html><body><h1>Hello from vert.x!</h1></body></html>")
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