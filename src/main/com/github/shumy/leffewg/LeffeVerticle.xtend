package com.github.shumy.leffewg

import com.github.shumy.leffewg.raml.RamlPathTransform
import com.github.shumy.leffewg.raml.RamlReader
import io.vertx.core.AbstractVerticle
import io.vertx.core.http.HttpServer
import io.vertx.core.http.HttpServerOptions
import io.vertx.ext.web.Router
import org.slf4j.LoggerFactory
import io.vertx.core.http.HttpMethod

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
        val path = RamlPathTransform.toSimpleRest(resource.resourcePath)
        resource.methods.forEach[ meth |
        	val method = meth.method.methodfromString
	        logger.info("ADD-Route -> {} {}", method, path)
	        router.route(method, path).handler[
	          response.end('''{ "message": "Hello", "path": «path» }''')
	        ]	
        ]
      ]
      
      mainRouter.mountSubRouter(api.baseUri.value, router)
    ]
    
    return mainRouter
  }
  
  private def HttpMethod methodfromString(String method) {
  	switch method.toUpperCase {
  		case "GET": HttpMethod.GET
  		case "POST": HttpMethod.POST
  		case "PUT": HttpMethod.PUT
  		case "PATCH": HttpMethod.PATCH
  		case "DELETE": HttpMethod.DELETE
  		case "OPTIONS": HttpMethod.OPTIONS
  		case "HEAD": HttpMethod.HEAD
  		case "TRACE": HttpMethod.TRACE
  		case "CONNECT": HttpMethod.CONNECT
  		case "OTHER": HttpMethod.OTHER
  	}
  }
}