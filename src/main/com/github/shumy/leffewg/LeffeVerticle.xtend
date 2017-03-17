package com.github.shumy.leffewg

import com.github.shumy.leffewg.raml.RamlReader
import io.vertx.core.AbstractVerticle
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import io.vertx.ext.web.Router
import org.slf4j.LoggerFactory
import com.github.shumy.leffewg.raml.RamlParamTransform

class LeffeVerticle extends AbstractVerticle {
  static val logger = LoggerFactory.getLogger(LeffeVerticle)
  
  var HttpServer server
  
  override def start() {
    val options = new HttpServerOptions => [
      tcpKeepAlive = true
      logActivity = true
    ]
    
    val router = configRouter()
    server = vertx.createHttpServer(options).requestHandler[
      router.accept(it) //forward request to router...
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
  
  private def Router configRouter() {
    val mainRouter = Router.router(vertx)
    RamlReader.readAll.forEach[ api |
      logger.info("ADD-SubRouter -> {}", api.baseUri.value)
      val router = Router.router(vertx)
      api.resources.forEach[ resource |
        val path = RamlParamTransform.transform(resource.resourcePath)
        logger.info("ADD-Route -> {}", path)
        router.route(resource.resourcePath).handler[
          response.end('''{ "message": "Hello", "path": «path» }''')
        ]
      ]
      
      mainRouter.mountSubRouter(api.baseUri.value, router)
    ]
    
    return mainRouter
  }
}