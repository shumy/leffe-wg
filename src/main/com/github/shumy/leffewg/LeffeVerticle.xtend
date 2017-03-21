package com.github.shumy.leffewg

import com.github.shumy.leffewg.plugin.PluginProvider
import io.vertx.core.AbstractVerticle
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.slf4j.LoggerFactory

@FinalFieldsConstructor
class LeffeVerticle extends AbstractVerticle {
  static val logger = LoggerFactory.getLogger(LeffeVerticle)
  
  val PluginProvider provider
  var HttpServer server
  
  override def start() {
    val options = new HttpServerOptions => [
      tcpKeepAlive = true
      logActivity = true
    ]
    
    server = vertx.createHttpServer(options).requestHandler[
      println('REQUEST: ' + uri)
      val routers = provider.routers.filter[ path, router | uri.startsWith(path) ]
      if (routers.empty) {
        response.statusCode = 404
        response.end('No route found!')
        return
      }
      
      routers.forEach[ path, router |
        router.accept(it)
      ]
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