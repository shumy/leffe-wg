package com.github.shumy.leffewg.raml

import com.github.shumy.leffewg.plugin.IRouterPlugin
import com.github.shumy.leffewg.plugin.Location
import io.vertx.core.Vertx
import io.vertx.core.http.HttpClient
import io.vertx.core.http.HttpClientOptions
import io.vertx.core.streams.Pump
import io.vertx.ext.web.Router
import java.net.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.osgi.service.component.annotations.Component
import org.osgi.service.component.annotations.Reference
import org.raml.v2.api.model.v10.resources.Resource
import org.slf4j.LoggerFactory

@Component
class RamlProxyPlugin implements IRouterPlugin {
  static val logger = LoggerFactory.getLogger(RamlProxyPlugin)
  
  @Accessors val String name = "raml-proxy"
  @Reference Vertx vertx
  
  override config(Location location) {
    println('raml-proxy-config: ' + location.name)
    
    val api = RamlReader.readConfig(location.config)
    val client = vertx.createHttpClient(new HttpClientOptions)
    api.resources.forEach[ configResource(location.uri, location.router, client) ]
  }
  
  def void configResource(Resource resource, String baseUri, Router router, HttpClient client) {
    val path = baseUri +  RamlPathTransform.toSimpleRest(resource.resourcePath)
    resource.annotations.forEach[ ann |
      if (ann.annotation.displayName.value == 'ProxyPass') {
        val urlPass = ann.structuredValue.value as String
        println('''«path» --(ProxyPass)--> «urlPass»''')
        router.configProxy(client, path, urlPass)
      }
    ]
    
    /*resource.methods.forEach[ meth |
      val method = HttpMethod.valueOf(meth.method.toUpperCase)
      println('''  «method» «path»''')
      router.route(method, path).handler[
        response.end('''{ "message": "Hello", "path": «path» }''')
      ]
    ]*/
    
    resource.resources.forEach[ configResource(baseUri, router, client) ]
  }
  
  def void configProxy(Router router, HttpClient client, String from, String to) {
    val pURL = to.decodeProxyURL
    
    router.route(from).handler[ ctx |
      logger.debug("Proxy-Request {} -> {}", from, to)
      /*ctx.request.headers.forEach[
        println('''  «key»: «value»''')
      ]*/
      
      val cRequest = client.request(ctx.request.method, pURL.port, pURL.host, pURL.uri)[ cResponse |
        logger.debug('Proxy-Response {} -> {}', to, cResponse.statusCode)
        /*cResponse.headers.forEach[
          println('''  «key»: «value»''')
        ]*/
        
        ctx.response => [
          chunked = true
          statusCode = cResponse.statusCode
          statusMessage = cResponse.statusMessage
          headers.all = cResponse.headers
        ]
        
        //transmit response data until end...
        Pump.pump(cResponse, ctx.response).start
        cResponse.endHandler[ ctx.response.end ]
        cResponse.exceptionHandler[ logger.error("Proxy-Response-Error {}", message) ]
      ]
      
      cRequest => [
        chunked = true
        headers.all = ctx.request.headers
        headers.set('Host', pURL.hostAndPort)
      ]
      
      //transmit request data until end...
      Pump.pump(ctx.request, cRequest).start
      ctx.request.endHandler[ cRequest.end ]
      ctx.request.exceptionHandler[ logger.error("Proxy-Request-Error {}", message) ]
    ]
  }
  
  def decodeProxyURL(String pURL) {
    val url = new URI(pURL)
    
    val scheme = url.scheme ?: 'http'
    val host = url.host ?: 'localhost'
    
    var port = url.port
    if (url.port === -1) {
      if (scheme == 'http')
        port = 80
      if (scheme == 'https')
        port = 443
    }
    
    val uri = if (url.path == "") "/" else url.path
    return new ProxyURL(scheme, host, port, uri, host + ":" + port)
  }
}

@Data
class ProxyURL {
  public String   scheme
  public String   host
  public Integer  port
  public String   uri
  
  public String   hostAndPort
  
}